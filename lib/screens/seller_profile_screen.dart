import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/app_constants.dart';

class SellerProfileScreen extends StatefulWidget {
  const SellerProfileScreen({super.key});

  @override
  State<SellerProfileScreen> createState() => _SellerProfileScreenState();
}

class _SellerProfileScreenState extends State<SellerProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Database _db = Database();
  String _vendorId = '0';
  bool _isLoading = true;
  String _errorMessage = '';

  // Profile data
  String _name = '';
  String _email = '';
  String _mobile = '';
  String _profilePic = '';
  String _bio = '';
  String _workPreference = 'Remote / Hybrid';
  List<String> _selectedAudiences = [];
  List<dynamic> _digitalLinks = [];

  // Reputation data
  double _averageRating = 0.0;
  int _totalReviews = 0;
  List<dynamic> _reviews = [];
  List<dynamic> _testimonials = [];

  // Stores data
  List<dynamic> _stores = [];

  // Compliance data
  List<dynamic> _complianceDocs = [];

  // Controllers for text editing
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  final List<String> _audienceOptions = [
    'BTC (Consumer)',
    'BTB (Business)',
    'NGO',
    'Government',
    'Startups'
  ];

  final List<String> _workPreferenceOptions = [
    'Remote / Hybrid',
    'On-Site Only',
    'Full Flex'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _initData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _mobileController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _initData() async {
    _vendorId = await AuthService.getVendorIdString();
    await _loadAllData();
  }

  Future<void> _loadAllData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await Future.wait([
        _fetchProfileData(),
        _fetchReputationData(),
        _fetchTestimonials(),
        _fetchStores(),
        _fetchComplianceDocs(),
      ]);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load profile data: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- API Fetches ---

  Future<void> _fetchProfileData() async {
    final response = await _db.getJsonData({
      'action': 'profile_tab',
    }, endpoint: 'new_apis/seller_profile_API.php');

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final profile = data['profile'] ?? {};
      _name = profile['name']?.toString() ?? '';
      _email = profile['email']?.toString() ?? '';
      _mobile = profile['mobile']?.toString() ?? '';
      _profilePic = profile['profile_pic']?.toString() ?? '';
      _bio = profile['bio']?.toString() ?? '';
      _workPreference = profile['work_preference']?.toString() ?? 'Remote / Hybrid';
      
      final allowedTarget = profile['allowed_target']?.toString() ?? '';
      _selectedAudiences = allowedTarget.isNotEmpty
          ? allowedTarget.split(',').map((e) => e.trim()).toList()
          : [];

      _digitalLinks = data['digital_presence'] ?? [];

      _nameController.text = _name;
      _emailController.text = _email;
      _mobileController.text = _mobile;
      _bioController.text = _bio;
    }
  }

  Future<void> _fetchReputationData() async {
    final response = await _db.getJsonData({
      'action': 'reputation_tab',
    }, endpoint: 'new_apis/seller_profile_API.php');

    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      _averageRating = double.tryParse(data['average_rating']?.toString() ?? '0.0') ?? 0.0;
      _totalReviews = int.tryParse(data['total_reviews']?.toString() ?? '0') ?? 0;
      _reviews = data['reviews'] ?? [];
    }
  }

  Future<void> _fetchTestimonials() async {
    final response = await _db.getJsonData({
      'action': 'testimonial_list',
    }, endpoint: 'new_apis/seller_profile_API.php');

    if (response['success'] == true && response['data'] != null) {
      _testimonials = response['data'] ?? [];
    }
  }

  Future<void> _fetchStores() async {
    final response = await _db.getJsonData({
      'action': 'store_list',
    }, endpoint: 'new_apis/seller_profile_API.php');

    if (response['success'] == true && response['data'] != null) {
      _stores = response['data'] ?? [];
    }
  }

  Future<void> _fetchComplianceDocs() async {
    final response = await _db.getJsonData({
      'action': 'compliance_docs_list',
    }, endpoint: 'new_apis/seller_profile_API.php');

    if (response['success'] == true && response['data'] != null) {
      _complianceDocs = response['data'] ?? [];
    }
  }

  // --- Actions ---

  Future<void> _updateProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final response = await _db.getJsonData({
        'action': 'update_profile',
        'name': _nameController.text,
        'mobile': _mobileController.text,
        'profile_pic': _profilePic,
        'bio': _bioController.text,
        'work_preference': _workPreference,
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Profile updated successfully");
        await _fetchProfileData();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to update profile");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateTargetAudiences() async {
    try {
      final response = await _db.getJsonData({
        'action': 'update_business_communities',
        'allowed_target': _selectedAudiences.join(','),
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Target audiences updated");
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to update audiences");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  Future<void> _addDigitalPresence(String type, String url) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'add_digital_presence',
        'links': [
          {'type': type, 'url': url}
        ]
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Link added successfully");
        await _fetchProfileData();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to add link");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteDigitalPresence(int id) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'delete_digital_presence',
        'id': id,
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Link removed");
        await _fetchProfileData();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to remove link");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addTestimonial(String testimonial, String client, String company, String designation) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'add_testimonial',
        'testimonial': testimonial,
        'client_name': client,
        'company_name': company,
        'designation': designation,
        'logo': '',
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Testimonial added successfully");
        await _fetchTestimonials();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to add testimonial");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStore(Map<String, dynamic> store) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'add_store',
        ...store,
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Store created successfully");
        await _fetchStores();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to create store");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStore(int storeId, Map<String, dynamic> store) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'update_store',
        'store_id': storeId,
        ...store,
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Store updated successfully");
        await _fetchStores();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to update store");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteStore(int storeId) async {
    setState(() => _isLoading = true);
    try {
      final response = await _db.getJsonData({
        'action': 'delete_store',
        'store_id': storeId,
      }, endpoint: 'new_apis/seller_profile_API.php');

      if (response['success'] == true) {
        Fluttertoast.showToast(msg: "Store removed");
        await _fetchStores();
      } else {
        Fluttertoast.showToast(msg: response['message']?.toString() ?? "Failed to remove store");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _uploadComplianceDoc(File file, String title) async {
    setState(() => _isLoading = true);
    try {
      final session = await _db.getSessionId();
      final url = Uri.parse('$baseUrlLegacy' + 'new_apis/seller_profile_API.php');

      var request = http.MultipartRequest('POST', url);
      request.headers['SESSION-ID'] = session ?? '';
      request.headers['APP_ID'] = appId.toString();

      request.fields['action'] = 'upload_compliance_docs';
      request.fields['document_title[file]'] = title;

      request.files.add(
        await http.MultipartFile.fromPath('file', file.path),
      );

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      final result = jsonDecode(response.body);
      if (result['success'] == true) {
        Fluttertoast.showToast(msg: "Document uploaded successfully");
        await _fetchComplianceDocs();
      } else {
        Fluttertoast.showToast(msg: result['message']?.toString() ?? "Upload failed");
      }
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- UI Build Helpers ---

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _name.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primary),
        ),
      );
    }

    if (_errorMessage.isNotEmpty && _name.isEmpty) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppTheme.error),
                const SizedBox(height: 16),
                Text(_errorMessage, textAlign: TextAlign.center),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _loadAllData,
                  child: const Text("Retry"),
                )
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Seller Profile",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined, size: 20),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: _tabController.index == 2 ? FloatingActionButton.small(
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        onPressed: () => _showStoreDialog(),
      ) : null,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: _buildProfileHeader(),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverAppBarDelegate(
              TabBar(
                controller: _tabController,
                indicatorColor: AppTheme.primary,
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondary,
                indicatorSize: TabBarIndicatorSize.tab,
                labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.normal),
                tabs: const [
                  Tab(text: "Profile"),
                  Tab(text: "Reputation"),
                  Tab(text: "Stores"),
                  Tab(text: "Compliance"),
                ],
              ),
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProfileTab(),
            _buildReputationTab(),
            _buildStoresTab(),
            _buildComplianceTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary.withOpacity(0.15), width: 3),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: AppTheme.primary.withOpacity(0.05),
                  backgroundImage: _profilePic.isNotEmpty
                      ? CachedNetworkImageProvider(_profilePic)
                      : const CachedNetworkImageProvider('https://lh3.googleusercontent.com/aida-public/AB6AXuByqUOoS2Fmi2YaiKgjMcuPcQZaynkq4Jey0PGhIYRYF_HvxQLf3HROf1s_aTi7Kpq8IeGRczRK3Z9Yk9vQjPVcRZKrQ9IfPuQKi3JCy8GyfS5j3NEdtyPvePoQLu1RzfYVTl3LgAn9rQfx-mVs_eLdyp6kCOPY7lA9zUQjLE5tPEwtcDFKWVwu58OhAG3ev-Gbk6Mrey3bs6ocnba_GIT57wcfrc5oVQ3_LZ78Z9LNmlXP_8qoTFpsZJvHyZzq3D283xJU6alzKZM'),
                ),
              ),
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _name.isNotEmpty ? _name : "Alexander Vance",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  "ELITE SELLER",
                  style: TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                "Joined 2021",
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- PROFILE TAB ---
  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader("Personal Details"),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              side: BorderSide(color: AppTheme.outline.withOpacity(0.3), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  _buildCompactTextField(
                    controller: _nameController,
                    label: "Full Name",
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 10),
                  _buildCompactTextField(
                    controller: _emailController,
                    label: "Email",
                    icon: Icons.mail_outline,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 10),
                  _buildCompactTextField(
                    controller: _mobileController,
                    label: "Mobile",
                    icon: Icons.phone_android_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 10),
                  _buildCompactTextField(
                    controller: _bioController,
                    label: "Bio",
                    icon: Icons.edit_note_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: _workPreference,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "Work Preference",
                      labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      prefixIcon: Icon(Icons.work_outline, size: 16, color: AppTheme.textSecondary),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: _workPreferenceOptions.map((opt) {
                      return DropdownMenuItem(
                        value: opt,
                        child: Text(opt, style: const TextStyle(fontSize: 12)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _workPreference = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 40,
                    child: ElevatedButton(
                      onPressed: _updateProfile,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radius),
                        ),
                      ),
                      child: const Text(
                        "SAVE CHANGES",
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader("Digital Presence"),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 14),
                label: const Text("ADD LINK", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showAddLinkDialog(),
              )
            ],
          ),
          const SizedBox(height: 6),
          _digitalLinks.isEmpty
              ? _buildEmptyState("No digital links found.")
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _digitalLinks.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 6),
                  itemBuilder: (context, index) {
                    final item = _digitalLinks[index];
                    final isSocial = item['type'] == 'social';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: AppTheme.outline.withOpacity(0.2), width: 1),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: AppTheme.primary.withOpacity(0.08),
                          child: Icon(
                            isSocial ? Icons.share_rounded : Icons.language_rounded,
                            color: AppTheme.primary,
                            size: 13,
                          ),
                        ),
                        title: Text(
                          item['url']?.toString() ?? '',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          (item['type']?.toString() ?? 'Website').toUpperCase(),
                          style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 16),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _deleteDigitalPresence(int.parse(item['id'].toString())),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),
          _buildSectionHeader("Target Audiences"),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              side: BorderSide(color: AppTheme.outline.withOpacity(0.3), width: 1),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Wrap(
                spacing: 6.0,
                runSpacing: 6.0,
                children: _audienceOptions.map((opt) {
                  final isSelected = _selectedAudiences.contains(opt);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    label: Text(opt, style: const TextStyle(fontSize: 10)),
                    selected: isSelected,
                    selectedColor: AppTheme.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedAudiences.add(opt);
                        } else {
                          _selectedAudiences.remove(opt);
                        }
                      });
                      _updateTargetAudiences();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildCompactTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        prefixIcon: Icon(icon, size: 16, color: AppTheme.textSecondary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  // --- REPUTATION TAB ---
  Widget _buildReputationTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Metrics Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary,
                  AppTheme.primary.withOpacity(0.85),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                RatingBarIndicator(
                  rating: _averageRating,
                  itemBuilder: (context, index) => const Icon(
                    Icons.star_rounded,
                    color: Colors.amber,
                  ),
                  itemCount: 5,
                  itemSize: 18.0,
                  direction: Axis.horizontal,
                ),
                const SizedBox(height: 6),
                Text(
                  "Based on $_totalReviews client reviews",
                  style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader("Recent Reviews"),
          const SizedBox(height: 8),
          _reviews.isEmpty
              ? _buildEmptyState("No reviews found.")
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _reviews.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _reviews[index];
                    final rating = double.tryParse(item['rating']?.toString() ?? '5.0') ?? 5.0;
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: AppTheme.outline.withOpacity(0.2), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                RatingBarIndicator(
                                  rating: rating,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star_rounded,
                                    color: AppTheme.primary,
                                  ),
                                  itemCount: 5,
                                  itemSize: 11.0,
                                ),
                                Text(
                                  item['created_date']?.toString().split(' ')[0] ?? '',
                                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '"${item['message'] ?? ''}"',
                              style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '- ${item['client_name'] ?? 'Verified Buyer'}',
                              style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, fontWeight: FontWeight.bold),
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSectionHeader("Client Testimonials"),
              TextButton.icon(
                icon: const Icon(Icons.add_circle_outline, size: 14),
                label: const Text("ADD TESTIMONIAL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () => _showAddTestimonialDialog(),
              )
            ],
          ),
          const SizedBox(height: 8),
          _testimonials.isEmpty
              ? _buildEmptyState("No testimonials found.")
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _testimonials.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _testimonials[index];
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: AppTheme.outline.withOpacity(0.2), width: 1),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppTheme.primary.withOpacity(0.08),
                              child: const Icon(Icons.business_rounded, color: AppTheme.primary, size: 14),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item['client_name']?.toString() ?? '',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                                  ),
                                  Text(
                                    '${item['designation'] ?? ''}, ${item['company_name'] ?? ''}',
                                    style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '"${item['testimonial'] ?? ''}"',
                                    style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textPrimary),
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
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // --- STORES TAB ---
  Widget _buildStoresTab() {
    return _stores.isEmpty
        ? Center(child: _buildEmptyState("No stores registered yet."))
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: _stores.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = _stores[index];
              return Card(
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  side: BorderSide(color: AppTheme.outline.withOpacity(0.3), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CachedNetworkImage(
                      imageUrl: item['store_banner']?.toString() ?? 'https://lh3.googleusercontent.com/aida-public/AB6AXuCQE8bDUxvsmdracYR8QmK_g6e4PO1NOfKKUmOEuUdK2irxXZZH3VytWtBoy4C-2ZhuvaMJGegNKXXZUynDkUyOueLrYxoRa481eSmQO1DDZcLeXfxX0wYwfGKyECiA1AW136LbHaS7jKK3QBvO3h1C-3aV06jKQZksNPSVsUl3XEzYtCbar72XBT9kZlRjdYCMqdi1VvM99ti6Qp7hzauMp8pyE-uS_EY_QsivyLaADhzbHsb-gPQKwJ2FYWaQucvoTVSSE0MWYqA',
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(color: Colors.grey.shade100),
                      errorWidget: (context, url, err) => Container(color: Colors.grey.shade100),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item['store_name']?.toString() ?? '',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.textPrimary),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 6,
                                    height: 6,
                                    decoration: const BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    "Active",
                                    style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textSecondary),
                              const SizedBox(width: 4),
                              Text(
                                '${item['city'] ?? ''}, ${item['state'] ?? ''}',
                                style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
                              )
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 32,
                                  child: OutlinedButton(
                                    onPressed: () => _showStoreDialog(store: item),
                                    style: OutlinedButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      side: const BorderSide(color: AppTheme.primary, width: 1),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    child: const Text("EDIT STORE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                height: 32,
                                width: 32,
                                decoration: BoxDecoration(
                                  border: Border.all(color: AppTheme.error.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete_outline_rounded, color: AppTheme.error, size: 16),
                                  padding: EdgeInsets.zero,
                                  onPressed: () => _showDeleteConfirmDialog(int.parse(item['id'].toString())),
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
  }

  // --- COMPLIANCE TAB ---
  Widget _buildComplianceTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload Area
          GestureDetector(
            onTap: _pickAndUploadDoc,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.02),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.25),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  const Icon(Icons.cloud_upload_outlined, size: 36, color: AppTheme.primary),
                  const SizedBox(height: 8),
                  const Text(
                    "Upload Documents",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Supported formats: JPG, PNG, PDF. Max 10MB.",
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 10),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "SELECT FILES",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildSectionHeader("Verification Status"),
          const SizedBox(height: 8),
          _complianceDocs.isEmpty
              ? _buildEmptyState("No compliance documents uploaded.")
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _complianceDocs.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _complianceDocs[index];
                    final isVerified = item['status'] == 1 || item['status'] == '1';
                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radius),
                        side: BorderSide(color: AppTheme.outline.withOpacity(0.2), width: 1),
                      ),
                      child: ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                        leading: CircleAvatar(
                          radius: 14,
                          backgroundColor: isVerified ? Colors.green.withOpacity(0.08) : Colors.amber.withOpacity(0.08),
                          child: Icon(
                            isVerified ? Icons.verified_user_rounded : Icons.description_outlined,
                            color: isVerified ? Colors.green : Colors.amber,
                            size: 14,
                          ),
                        ),
                        title: Text(
                          item['document_title']?.toString() ?? '',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.textPrimary),
                        ),
                        subtitle: Text(
                          item['documenttype']?.toString().toUpperCase() ?? '',
                          style: const TextStyle(fontSize: 8, color: AppTheme.textSecondary),
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isVerified ? Colors.green.withOpacity(0.08) : Colors.amber.withOpacity(0.08),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isVerified ? "VERIFIED" : "PENDING",
                            style: TextStyle(
                              color: isVerified ? Colors.green : Colors.amber.shade800,
                              fontWeight: FontWeight.w700,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(String msg) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Text(
        msg,
        style: const TextStyle(color: AppTheme.textSecondary, fontStyle: FontStyle.italic, fontSize: 11),
      ),
    );
  }

  // --- Dialogs ---

  void _showAddLinkDialog() {
    String type = 'website';
    final ctrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 24,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Add Digital Link", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: type,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "Link Type",
                      labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'website', child: Text("Website", style: TextStyle(fontSize: 12))),
                      DropdownMenuItem(value: 'social', child: Text("Social media / Messenger", style: TextStyle(fontSize: 12))),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => type = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: ctrl,
                    style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      labelText: "URL",
                      labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                      hintText: "https://example.com",
                      hintStyle: TextStyle(fontSize: 11, color: Colors.grey),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("CANCEL", style: TextStyle(fontSize: 11)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            if (ctrl.text.trim().isNotEmpty) {
                              Navigator.pop(context);
                              _addDigitalPresence(type, ctrl.text.trim());
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(40),
                          ),
                          child: const Text("SUBMIT", style: TextStyle(fontSize: 11)),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddTestimonialDialog() {
    final nameCtrl = TextEditingController();
    final companyCtrl = TextEditingController();
    final desCtrl = TextEditingController();
    final textCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Add Testimonial", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                _buildCompactTextField(controller: nameCtrl, label: "Client Name", icon: Icons.person_outline),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: companyCtrl, label: "Company Name", icon: Icons.business_outlined),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: desCtrl, label: "Designation", icon: Icons.badge_outlined),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: textCtrl, label: "Testimonial Text", icon: Icons.format_quote_outlined, maxLines: 3),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text("CANCEL", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty && textCtrl.text.isNotEmpty) {
                            Navigator.pop(context);
                            _addTestimonial(
                              textCtrl.text.trim(),
                              nameCtrl.text.trim(),
                              companyCtrl.text.trim(),
                              desCtrl.text.trim(),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text("SUBMIT", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showStoreDialog({dynamic store}) {
    final isEdit = store != null;
    final nameCtrl = TextEditingController(text: isEdit ? store['store_name']?.toString() : '');
    final typeCtrl = TextEditingController(text: isEdit ? store['store_type']?.toString() : 'physical_store');
    final descCtrl = TextEditingController(text: isEdit ? store['about_business']?.toString() : '');
    final webCtrl = TextEditingController(text: isEdit ? store['website']?.toString() : '');
    final addrCtrl = TextEditingController(text: isEdit ? store['address']?.toString() : '');
    final cityCtrl = TextEditingController(text: isEdit ? store['city']?.toString() : '');
    final stateCtrl = TextEditingController(text: isEdit ? store['state']?.toString() : '');
    final pinCtrl = TextEditingController(text: isEdit ? store['pin_code']?.toString() : '');
    final bannerCtrl = TextEditingController(text: isEdit ? store['store_banner']?.toString() : '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isEdit ? "Edit Store" : "Add Store",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildCompactTextField(controller: nameCtrl, label: "Store Name", icon: Icons.storefront_outlined),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: typeCtrl.text,
                  style: const TextStyle(fontSize: 12, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    labelText: "Store Type",
                    labelStyle: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'physical_store', child: Text("Physical Store", style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'warehouse', child: Text("Warehouse", style: TextStyle(fontSize: 12))),
                    DropdownMenuItem(value: 'factory', child: Text("Factory", style: TextStyle(fontSize: 12))),
                  ],
                  onChanged: (val) {
                    if (val != null) typeCtrl.text = val;
                  },
                ),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: descCtrl, label: "About Business", icon: Icons.info_outline, maxLines: 2),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: webCtrl, label: "Website", icon: Icons.language_outlined),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: addrCtrl, label: "Address", icon: Icons.map_outlined),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(child: _buildCompactTextField(controller: cityCtrl, label: "City", icon: Icons.location_city_outlined)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildCompactTextField(controller: stateCtrl, label: "State", icon: Icons.flag_outlined)),
                  ],
                ),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: pinCtrl, label: "Pin Code", icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                _buildCompactTextField(controller: bannerCtrl, label: "Banner Image URL", icon: Icons.image_outlined),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text("CANCEL", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          if (nameCtrl.text.isNotEmpty) {
                            Navigator.pop(context);
                            final storeData = {
                              'store_name': nameCtrl.text.trim(),
                              'store_type': typeCtrl.text,
                              'about_business': descCtrl.text.trim(),
                              'website': webCtrl.text.trim(),
                              'address': addrCtrl.text.trim(),
                              'city': cityCtrl.text.trim(),
                              'state': stateCtrl.text.trim(),
                              'pin_code': pinCtrl.text.trim(),
                              'store_banner': bannerCtrl.text.trim(),
                            };
                            if (isEdit) {
                              _updateStore(int.parse(store['id'].toString()), storeData);
                            } else {
                              _addStore(storeData);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(40),
                        ),
                        child: const Text("SUBMIT", style: TextStyle(fontSize: 11)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmDialog(int storeId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Store", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          content: const Text("Are you sure you want to permanently delete this store? This action cannot be undone.", style: TextStyle(fontSize: 12)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("CANCEL", style: TextStyle(fontSize: 12)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.error,
                minimumSize: const Size(80, 36),
              ),
              onPressed: () {
                Navigator.pop(context);
                _deleteStore(storeId);
              },
              child: const Text("DELETE", style: TextStyle(fontSize: 12)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickAndUploadDoc() async {
    final titleCtrl = TextEditingController();
    
    final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (pickerResult == null || pickerResult.files.single.path == null) {
      return;
    }

    final File pickedFile = File(pickerResult.files.single.path!);

    if (!mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Document Information", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildCompactTextField(controller: titleCtrl, label: "Document Title", icon: Icons.title_outlined),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text("CANCEL", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (titleCtrl.text.trim().isNotEmpty) {
                          Navigator.pop(context);
                          _uploadComplianceDoc(pickedFile, titleCtrl.text.trim());
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(40),
                      ),
                      child: const Text("UPLOAD", style: TextStyle(fontSize: 11)),
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
