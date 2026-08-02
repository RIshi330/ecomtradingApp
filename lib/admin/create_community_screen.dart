import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// This endpoint (new_apis/create_community_API.php) is shared for every
/// action used on this screen. Keeping it in one place avoids typos.
const String _kCommunityApiEndpoint = 'new_apis/community_app_api_v6.php';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;
  bool _isLoadingOptions = true;

  // Form Fields
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _tagInputController = TextEditingController();

  // Tags = free-form labels (kept separate from Industries, which the API
  // treats as its own column and uses for "communities_for_you" matching).
  final List<String> _tags = ["Networking"];
  String _selectedType = "Professional";
  String _visibility = "public"; // "public" or "private"
  String _joiningRule = "free"; // "free", "approval", "invite", "paid"
  String _communityStructure = "Centralized"; // UI-only, not yet stored by the API

  // ---- Industries: sourced live from action=get_job_industries ----
  List<Map<String, dynamic>> _jobIndustries = [];
  final List<String> _selectedIndustries = [];
  final TextEditingController _industrySearchController = TextEditingController();
  String _industrySearchQuery = "";

  // ---- "Community For" (vendor type): sourced live from action=get_vendor_types ----
  // The API validates these as numeric vendor_type IDs (see validateVendorTypeIds
  // in the PHP), so this MUST be an id-based multi-select, not free text.
  List<Map<String, dynamic>> _vendorTypeOptions = [];
  final List<int> _selectedVendorTypeIds = [];
  final TextEditingController _vendorTypeSearchController = TextEditingController();
  String _vendorTypeSearchQuery = "";

  // Community Module Template dropdown.
  // The PHP only accepts: 'social_feed' | 'marketplace' | 'hybrid'.
  // We show friendly labels and map them right before sending.
  String _moduleTemplate = "Social Community Feed";
  final List<String> _moduleTemplateList = [
    "Social Community Feed",
    "Marketplace",
    "Hybrid",
  ];
  static const Map<String, String> _moduleTemplateApiValues = {
    "Social Community Feed": "social_feed",
    "Marketplace": "marketplace",
    "Hybrid": "hybrid",
  };

  // Paid Membership Fields
  final _feeController = TextEditingController(text: "0.00");
  String _billingType = "Recurring"; // UI-only, not yet stored by the API
  String _duration = "Monthly"; // UI-only, not yet stored by the API

  // Target Audience Fields (UI-only for now — the API has no columns for
  // these yet, so they are not sent. Left in place for when the backend
  // adds support, so no data entered by the user is silently discarded
  // without at least being visible to them here.)
  String _ageGroup = "All Ages";
  String _gender = "All";
  final _professionController = TextEditingController();
  final _interestsController = TextEditingController();
  final _locationController = TextEditingController();

  // Branding Uploads (file name/mock paths)
  String? _logoName;
  String? _coverName;
  String? _logoPath;
  String? _coverPath;

  final _descriptionQuillController = QuillController.basic();

  final List<String> _communityTypes = [
    "Professional", "Business", "NGO", "Educational", "Sports", "Religious",
    "Local", "Startup", "Women", "Kids", "Alumni", "Hobby", "Club", "Other"
  ];

  final List<String> _categoriesList = [
    "Networking", "Mentorship", "Job Opportunities", "B2B Collaboration",
    "Events & Meetups", "Skill Development", "Support & Wellness", "General Discussion"
  ];

  @override
  void initState() {
    super.initState();
    _fetchFormOptions();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _tagInputController.dispose();
    _feeController.dispose();
    _professionController.dispose();
    _interestsController.dispose();
    _locationController.dispose();
    _descriptionQuillController.dispose();
    _industrySearchController.dispose();
    _vendorTypeSearchController.dispose();
    super.dispose();
  }

  /// Loads the real industry list (action=get_job_industries) and the real
  /// vendor-type list (action=get_vendor_types) from the backend so the user
  /// picks values the API will actually accept, instead of typing free text.
  Future<void> _fetchFormOptions() async {
    setState(() => _isLoadingOptions = true);

    try {
      final industriesResp = await Database().getData(
        {'action': 'get_job_industries'},
        endpoint: _kCommunityApiEndpoint,
      );
      if (industriesResp['success'] == true) {
        final list = (industriesResp['data']?['industries'] as List?) ?? [];
        _jobIndustries = list
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (e) {
      debugPrint("Failed to load industries: $e");
    }

    try {
      final vendorResp = await Database().getData(
        {'action': 'get_vendor_types'},
        endpoint: _kCommunityApiEndpoint,
      );
      if (vendorResp['success'] == true) {
        final list = (vendorResp['data']?['marketplace_list'] as List?) ?? [];
        _vendorTypeOptions = list
            .whereType<Map>()
            .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
            .toList();
      }
    } catch (e) {
      debugPrint("Failed to load vendor types: $e");
    }

    if (mounted) setState(() => _isLoadingOptions = false);
  }

  // ---- Filtered views used by the searchable selectors below ----

  List<Map<String, dynamic>> get _filteredIndustries {
    final query = _industrySearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _jobIndustries;
    return _jobIndustries.where((row) {
      final title = (row['industry_title'] ?? '').toString().toLowerCase();
      return title.contains(query);
    }).toList();
  }

  List<Map<String, dynamic>> get _filteredVendorTypes {
    final query = _vendorTypeSearchQuery.trim().toLowerCase();
    if (query.isEmpty) return _vendorTypeOptions;
    return _vendorTypeOptions.where((row) {
      final label = (row['display_name'] ?? row['marketplace_name'] ?? '')
          .toString()
          .toLowerCase();
      return label.contains(query);
    }).toList();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() {
        _logoName = result.files.single.name;
        _logoPath = result.files.single.path;
      });
    }
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() {
        _coverName = result.files.single.name;
        _coverPath = result.files.single.path;
      });
    }
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  void _toggleIndustry(String title) {
    setState(() {
      if (_selectedIndustries.contains(title)) {
        _selectedIndustries.remove(title);
      } else {
        _selectedIndustries.add(title);
      }
    });
  }

  void _toggleVendorType(int id) {
    setState(() {
      if (_selectedVendorTypeIds.contains(id)) {
        _selectedVendorTypeIds.remove(id);
      } else {
        _selectedVendorTypeIds.add(id);
      }
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final double fee = double.tryParse(_feeController.text) ?? 0.0;

      // Keys below match exactly what create_community_API.php reads from
      // $input. Anything not read by the PHP is intentionally left out so
      // the payload reflects what is actually persisted.
      final Map<String, dynamic> payload = {
        'action': 'create_community',
        'title': _nameController.text.trim(),
        'description': _getHtmlFromQuill(_descriptionQuillController),
        'type': _selectedType,
        'module_template': _moduleTemplateApiValues[_moduleTemplate] ?? 'social_feed',
        'visibility': _visibility,
        'joining_rule': _joiningRule,
        'joining_fee': fee.toStringAsFixed(2),
        if (_logoName != null) 'logo': _logoName,
        if (_coverName != null) 'cover_image': _coverName,
        if (_tags.isNotEmpty) 'tags': _tags.join(','),
        if (_selectedIndustries.isNotEmpty) 'industries': _selectedIndustries.join(','),
        if (_selectedVendorTypeIds.isNotEmpty)
          'for_vendor_type': _selectedVendorTypeIds.join(','),
      };

      final response = await Database().getData(
        payload,
        endpoint: _kCommunityApiEndpoint,
      );

      if (!mounted) return;

      final bool success = response['success'] == true;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Community created successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        final message = (response['message'] ?? "Failed to create community").toString();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const accentBg = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: accentBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Initialize New Community",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "COMMUNITY FORGE",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          "Step 1 of 2",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Color(0xFFEEEEED),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Community Identity Section
                _buildCardSection(
                  title: "Community Identity",
                  icon: Icons.fingerprint_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branding Uploads
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Upload
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "COMMUNITY LOGO ",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickLogo,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F3F3),
                                      border: Border.all(color: const Color(0xFFBDC9C8)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: _logoPath != null
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_logoPath!),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : _logoName != null
                                          ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _logoName!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                          : Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: const [
                                          Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                                          SizedBox(height: 4),
                                          Text("Upload Logo", style: TextStyle(fontSize: 9, color: Colors.grey)),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Cover Photo Upload
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "COVER PHOTO",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickCover,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F3F3),
                                      border: Border.all(color: const Color(0xFFBDC9C8)),
                                      borderRadius: BorderRadius.circular(12),
                                      image: _coverName != null || _coverPath != null
                                          ? null
                                          : const DecorationImage(
                                        image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCeZ8lweaK-XBVEvbJU6Igx-guIJrTT17cYHZ0FirV5uij6XqYsGN5Z8GiRpf21SFtyHu3mXxemren3yXQ3joQmu021Nu_g90zotvdidTguBezYMeTlxI45j7tN3iNRjQA4VQZYSZ8_uXlTqXPAb_PWkKxw3pAC7Q7O5wLF2AW2bTDCxUKAcqNVzahbb6jOsTdvt26lXGvDAZxYcX6l49nHhhbDRWjHgdNCaGW8C4eHcgUedwJFWZ49"),
                                        fit: BoxFit.cover,
                                        opacity: 0.15,
                                      ),
                                    ),
                                    child: Center(
                                      child: _coverPath != null
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.file(
                                          File(_coverPath!),
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      )
                                          : _coverName != null
                                          ? Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          _coverName!,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                                        ),
                                      )
                                          : const Text(
                                        "Tap to replace Cover",
                                        style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Industries — loaded live from action=get_job_industries.
                      // Searchable multi-select chips, sent to the API as the
                      // `industries` CSV field (used for "communities_for_you"
                      // matching).
                      const Text(
                        "INDUSTRIES",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildSearchableMultiSelect(
                        isLoading: _isLoadingOptions,
                        emptyMessage: "No industries available from the server.",
                        searchController: _industrySearchController,
                        searchHint: "Search industries...",
                        onSearchChanged: (val) => setState(() => _industrySearchQuery = val),
                        allOptionsEmpty: _jobIndustries.isEmpty,
                        selectedChips: _selectedIndustries.map((title) {
                          return _buildSelectedChip(
                            label: title,
                            onRemove: () => _toggleIndustry(title),
                          );
                        }).toList(),
                        filteredOptions: _filteredIndustries,
                        optionLabel: (row) => (row['industry_title'] ?? '').toString(),
                        isOptionSelected: (row) =>
                            _selectedIndustries.contains((row['industry_title'] ?? '').toString()),
                        onOptionTap: (row) {
                          final title = (row['industry_title'] ?? '').toString();
                          if (title.isNotEmpty) _toggleIndustry(title);
                        },
                        noMatchMessage: "No industries match your search.",
                      ),
                      const SizedBox(height: 16),

                      // Category — UI convenience only; folded into Tags
                      // since the API has no separate category column.
                      const Text(
                        "SELECT CATEGORY",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFF4F3F3),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          hintText: "Choose Category...",
                          hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                        items: _categoriesList.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, style: const TextStyle(color: Colors.black, fontSize: 14)),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null && !_tags.contains(val)) {
                            setState(() {
                              _tags.add(val);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      // Identity Inputs
                      _buildTextField(
                        controller: _nameController,
                        label: "COMMUNITY NAME",
                        hint: "e.g. Global Tech Innovators",
                        validator: (v) => v!.isEmpty ? "Community name is required" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _taglineController,
                        label: "COMMUNITY TAGLINE",
                        hint: "e.g. The future starts here",
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "DESCRIPTION",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildQuillField(
                        controller: _descriptionQuillController,
                        hint: "Briefly describe the purpose and goals of this community...",
                      ),
                      const SizedBox(height: 16),

                      // Tags input
                      const Text(
                        "TAGS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _tags.map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFF306E6D))),
                                  backgroundColor: const Color(0xFFB0EEED),
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(t);
                                    });
                                  },
                                  side: BorderSide.none,
                                  deleteIconColor: const Color(0xFF306E6D),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                )).toList(),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagInputController,
                                    decoration: const InputDecoration(
                                      hintText: "Add tag...",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: primaryColor),
                                  onPressed: _addTag,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Type & Visibility Section
                _buildCardSection(
                  title: "Community Type",
                  icon: Icons.category_rounded,
                  child: DropdownButtonFormField<String>(
                    value: _selectedType,
                    isExpanded: true,
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _communityTypes.map((t) => DropdownMenuItem(
                      value: t,
                      child: Text(t, overflow: TextOverflow.ellipsis),
                    )).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _selectedType = val;
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // "Community For" (vendor type) & Module Template
                _buildCardSection(
                  title: "Community For & Template",
                  icon: Icons.store_mall_directory_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "COMMUNITY FOR (VENDOR TYPE)",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Loaded live from action=get_vendor_types. The backend
                      // validates for_vendor_type as numeric IDs, so this is
                      // a real searchable multi-select against server data,
                      // not free text.
                      _buildSearchableMultiSelect(
                        isLoading: _isLoadingOptions,
                        emptyMessage: "No vendor types available from the server.",
                        searchController: _vendorTypeSearchController,
                        searchHint: "Search vendor types...",
                        onSearchChanged: (val) => setState(() => _vendorTypeSearchQuery = val),
                        allOptionsEmpty: _vendorTypeOptions.isEmpty,
                        selectedChips: _selectedVendorTypeIds.map((id) {
                          final match = _vendorTypeOptions.firstWhere(
                                (row) => (int.tryParse((row['id'] ?? '').toString()) ?? -1) == id,
                            orElse: () => {},
                          );
                          final label = (match['display_name'] ??
                              match['marketplace_name'] ??
                              'Vendor Type $id')
                              .toString();
                          return _buildSelectedChip(
                            label: label,
                            onRemove: () => _toggleVendorType(id),
                          );
                        }).toList(),
                        filteredOptions: _filteredVendorTypes,
                        optionLabel: (row) => (row['display_name'] ??
                            row['marketplace_name'] ??
                            'Vendor Type ${row['id']}')
                            .toString(),
                        isOptionSelected: (row) {
                          final id = int.tryParse((row['id'] ?? '').toString()) ?? -1;
                          return _selectedVendorTypeIds.contains(id);
                        },
                        onOptionTap: (row) {
                          final id = int.tryParse((row['id'] ?? '').toString()) ?? -1;
                          if (id >= 0) _toggleVendorType(id);
                        },
                        noMatchMessage: "No vendor types match your search.",
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "SELECT COMMUNITY MODULE TEMPLATE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _moduleTemplate,
                        isExpanded: true,
                        decoration: InputDecoration(
                          fillColor: const Color(0xFFF4F3F3),
                          filled: true,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        items: _moduleTemplateList.map((t) => DropdownMenuItem(
                          value: t,
                          child: Text(t, overflow: TextOverflow.ellipsis),
                        )).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setState(() {
                              _moduleTemplate = val;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                _buildCardSection(
                  title: "Visibility",
                  icon: Icons.visibility_rounded,
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: "public",
                        groupValue: _visibility,
                        title: const Text("Public", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Anyone can see/join", style: TextStyle(fontSize: 10)),
                        onChanged: (val) => setState(() => _visibility = val!),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: "private",
                        groupValue: _visibility,
                        title: const Text("Private", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Hidden from search", style: TextStyle(fontSize: 10)),
                        onChanged: (val) => setState(() => _visibility = val!),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Community Structure Section (UI-only — no matching column
                // in marketplace_communities yet).
                _buildCardSection(
                  title: "Community Structure",
                  icon: Icons.hub_rounded,
                  child: Column(
                    children: [
                      RadioListTile<String>(
                        value: "Centralized",
                        groupValue: _communityStructure,
                        title: const Text("Centralized", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Decisions made by a central authority/admin group", style: TextStyle(fontSize: 10)),
                        onChanged: (val) => setState(() => _communityStructure = val!),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: "Decentralized",
                        groupValue: _communityStructure,
                        title: const Text("Decentralized", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Distributed power and peer-to-peer operations", style: TextStyle(fontSize: 10)),
                        onChanged: (val) => setState(() => _communityStructure = val!),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                      RadioListTile<String>(
                        value: "Hybrid",
                        groupValue: _communityStructure,
                        title: const Text("Hybrid", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        subtitle: const Text("Combination of centralized coordination and decentralized operations", style: TextStyle(fontSize: 10)),
                        onChanged: (val) => setState(() => _communityStructure = val!),
                        activeColor: primaryColor,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 3. Joining Rules Section
                _buildCardSection(
                  title: "Joining Rules",
                  icon: Icons.policy_rounded,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildRuleCard(
                            value: "free",
                            title: "Free",
                            subtitle: "Open Access",
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          _buildRuleCard(
                            value: "approval",
                            title: "Request Approval",
                            subtitle: "Admin Review",
                            icon: Icons.verified_user_outlined,
                          ),
                          _buildRuleCard(
                            value: "invite",
                            title: "Invite Only",
                            subtitle: "Exclusive",
                            icon: Icons.mail_outline_rounded,
                          ),
                          _buildRuleCard(
                            value: "paid",
                            title: "Paid Membership",
                            subtitle: "Monetized",
                            icon: Icons.monetization_on_outlined,
                          ),
                        ],
                      ),
                      if (_joiningRule == "paid") ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFBDC9C8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "MEMBERSHIP FEE (INR)",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _feeController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixText: "₹ ",
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
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
                                        const Text(
                                          "BILLING TYPE",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _billingType,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(value: "Recurring", child: Text("Recurring", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "One-time", child: Text("One-time", overflow: TextOverflow.ellipsis)),
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          onChanged: (val) => setState(() => _billingType = val!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "DURATION",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _duration,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(value: "Monthly", child: Text("Monthly", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Quarterly", child: Text("Quarterly", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Annual", child: Text("Annual", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Lifetime", child: Text("Lifetime", overflow: TextOverflow.ellipsis)),
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          onChanged: (val) => setState(() => _duration = val!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Target Audience Section (UI-only — no matching columns
                // in marketplace_communities yet).
                _buildCardSection(
                  title: "Target Audience",
                  icon: Icons.group_rounded,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AGE GROUP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _ageGroup,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: "All Ages", child: Text("All Ages", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "18-24", child: Text("18-24", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "25-34", child: Text("25-34", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "35-44", child: Text("35-44", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "45+", child: Text("45+", overflow: TextOverflow.ellipsis)),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) => setState(() => _ageGroup = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("GENDER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: "All", child: Text("All", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Male", child: Text("Male", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Female", child: Text("Female", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Non-binary", child: Text("Non-binary", overflow: TextOverflow.ellipsis)),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) => setState(() => _gender = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _professionController,
                        label: "PROFESSION",
                        hint: "e.g. Software Engineers, Marketers",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _interestsController,
                        label: "INTERESTS",
                        hint: "Design, AI, Sustainable Energy...",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _locationController,
                        label: "LOCATION COVERAGE",
                        hint: "Global / Remote / Specific City",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6E7979)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Save as Draft",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                            : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Text("Create Community", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    const primaryColor = Color(0xFF006565);
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  /// A reusable "search + scrollable chip list + selected chips" control.
  ///
  /// Used for both Industries and Community-For (Vendor Type) so the form
  /// no longer dumps every option from the database onto the screen at
  /// once — instead the user types to filter, and taps to select/deselect.
  /// `T` is the raw option row (a `Map<String, dynamic>` in both call sites).
  Widget _buildSearchableMultiSelect<T>({
    required bool isLoading,
    required bool allOptionsEmpty,
    required String emptyMessage,
    required TextEditingController searchController,
    required String searchHint,
    required ValueChanged<String> onSearchChanged,
    required List<Widget> selectedChips,
    required List<T> filteredOptions,
    required String Function(T) optionLabel,
    required bool Function(T) isOptionSelected,
    required void Function(T) onOptionTap,
    required String noMatchMessage,
  }) {
    const primaryColor = Color(0xFF006565);

    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 18,
          width: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (allOptionsEmpty) {
      return Text(
        emptyMessage,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (selectedChips.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: selectedChips,
          ),
          const SizedBox(height: 10),
        ],

        // Search box
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3F3),
            border: Border.all(color: const Color(0xFFBDC9C8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                icon: const Icon(Icons.close, size: 18, color: Colors.grey),
                onPressed: () {
                  searchController.clear();
                  onSearchChanged('');
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            ),
          ),
        ),
        const SizedBox(height: 8),

        // Bounded-height results list so the page doesn't grow with the
        // full database list — it scrolls internally instead.
        Container(
          constraints: const BoxConstraints(maxHeight: 180),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFBDC9C8)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: filteredOptions.isEmpty
              ? Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              noMatchMessage,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          )
              : Scrollbar(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 4),
              itemCount: filteredOptions.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: Color(0xFFEEEEED)),
              itemBuilder: (context, index) {
                final option = filteredOptions[index];
                final label = optionLabel(option);
                final selected = isOptionSelected(option);
                return InkWell(
                  onTap: () => onOptionTap(option),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        Icon(
                          selected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                          size: 18,
                          color: selected ? primaryColor : Colors.grey,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: 13,
                              color: selected ? primaryColor : Colors.black,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedChip({required String label, required VoidCallback onRemove}) {
    return Chip(
      label: Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF306E6D))),
      backgroundColor: const Color(0xFFB0EEED),
      onDeleted: onRemove,
      side: BorderSide.none,
      deleteIconColor: const Color(0xFF306E6D),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            fillColor: const Color(0xFFF4F3F3),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _joiningRule == value;
    const primaryColor = Color(0xFF006565);

    return InkWell(
      onTap: () {
        setState(() {
          _joiningRule = value;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F5F5) : const Color(0xFFF4F3F3),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFBDC9C8),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getHtmlFromQuill(QuillController controller) {
    try {
      final delta = controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List.castFrom(delta),
        ConverterOptions.forEmail(),
      );
      return converter.convert();
    } catch (e) {
      debugPrint("Error converting Quill to HTML: $e");
      return "";
    }
  }

  Widget _buildQuillField({
    required QuillController controller,
    required String hint,
    double height = 150,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
        color: const Color(0xFFF4F3F3),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showAlignmentButtons: true,
              showLeftAlignment: true,
              showCenterAlignment: true,
              showRightAlignment: true,
              showJustifyAlignment: true,
              showHeaderStyle: false,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: true,
              showUndo: true,
              showRedo: true,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              multiRowsDisplay: false,
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFBDC9C8)),
          Container(
            height: height,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: QuillEditor.basic(
              controller: controller,
              config: QuillEditorConfig(
                placeholder: hint,
                autoFocus: false,
                expands: true,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}