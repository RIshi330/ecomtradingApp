import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ---------- MODELS ----------
class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String location;
  final String joined;
  final List<Document> docs;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.location,
    required this.joined,
    required this.docs,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    return Vendor(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      location: json['location'] ?? '',
      joined: json['joined'] ?? '',
      docs: (json['docs'] as List?)
          ?.map((d) => Document.fromJson(d))
          .toList() ??
          [],
    );
  }
}

class Document {
  final String id;
  final String name;
  final String type;
  final String url;
  final String status; // 'approved', 'pending', 'rejected'
  final String verificationRequest;
  final String notes;
  final String description;
  final String uploaded;

  Document({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    required this.status,
    required this.verificationRequest,
    required this.notes,
    required this.description,
    required this.uploaded,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      url: json['url'] ?? '',
      status: json['status'] ?? 'pending',
      verificationRequest: json['verification_request'] ?? '',
      notes: json['notes'] ?? '',
      description: json['description'] ?? '',
      uploaded: json['uploaded'] ?? '',
    );
  }
}

// ---------- API SERVICE ----------
class ApiService {
  static const String baseUrl = 'https://your-domain.com/api/'; // Replace with your actual API URL

  Future<Map<String, dynamic>> _post(String endpoint, Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token') ?? '';

    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(data),
    );

    if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    }

    return json.decode(response.body);
  }

  Future<List<Vendor>> getVendorsDocuments({int? vendorId}) async {
    final data = {
      'action': 'get_vendors_documents',
      if (vendorId != null) 'vendor_id': vendorId,
    };

    final response = await _post('', data);

    if (response['success'] == true) {
      final vendorsData = response['data'] as List;
      return vendorsData.map((v) => Vendor.fromJson(v)).toList();
    } else {
      throw Exception(response['message'] ?? 'Failed to fetch vendors');
    }
  }

  Future<void> approveDocument(String docId) async {
    final data = {
      'action': 'approve_document',
      'doc_id': int.parse(docId),
    };

    final response = await _post('', data);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to approve document');
    }
  }

  Future<void> rejectDocument(String docId, String reason) async {
    final data = {
      'action': 'reject_document',
      'doc_id': int.parse(docId),
      'reason': reason,
    };

    final response = await _post('', data);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to reject document');
    }
  }

  Future<int> bulkApprove(List<String> docIds) async {
    final data = {
      'action': 'bulk_approve',
      'doc_ids': docIds.map((id) => int.parse(id)).toList(),
    };

    final response = await _post('', data);

    if (response['success'] == true) {
      return response['data']['count'] ?? 0;
    } else {
      throw Exception(response['message'] ?? 'Failed to bulk approve');
    }
  }

  Future<void> postOpportunity({
    required String vendorId,
    required String docId,
    required String title,
    required String description,
    required int budget,
  }) async {
    final data = {
      'action': 'post_opportunity',
      'vendor_id': int.parse(vendorId),
      'doc_id': int.parse(docId),
      'title': title,
      'description': description,
      'budget': budget,
    };

    final response = await _post('', data);

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Failed to post opportunity');
    }
  }
}

class vendorForm extends StatefulWidget {
  const vendorForm({super.key});

  @override
  State<vendorForm> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<vendorForm> {
  final ApiService _api = ApiService();
  List<Vendor> _vendors = [];
  final List<String> _selectedDocIds = [];
  bool _isLoading = true;
  String _error = '';

  // Modal controllers
  final TextEditingController _rejectReasonController = TextEditingController();
  String? _rejectDocId;

  final TextEditingController _opportunityTitleController =
  TextEditingController();
  final TextEditingController _scopeController = TextEditingController();
  final TextEditingController _budgetController = TextEditingController();
  String? _opportunityVendorId;
  String? _opportunityDocId;

  // UI State for expansion
  final Set<String> _expandedVendors = {};

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      final vendors = await _api.getVendorsDocuments();
      setState(() {
        _vendors = vendors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _toggleVendor(String vendorId) {
    setState(() {
      if (_expandedVendors.contains(vendorId)) {
        _expandedVendors.remove(vendorId);
      } else {
        _expandedVendors.add(vendorId);
      }
    });
  }

  void _toggleDocumentSelection(String docId) {
    setState(() {
      if (_selectedDocIds.contains(docId)) {
        _selectedDocIds.remove(docId);
      } else {
        _selectedDocIds.add(docId);
      }
    });
  }

  void _deselectAll() {
    setState(() {
      _selectedDocIds.clear();
    });
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: isError ? Colors.red : Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFBA1A1A) : const Color(0xFF006565),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _approveDocument(String docId) async {
    try {
      await _api.approveDocument(docId);
      _showToast('Document $docId approved successfully.');
      await _loadVendors();
    } catch (e) {
      _showToast('Failed to approve: ${e.toString()}', isError: true);
    }
  }

  void _openRejectModal(String docId) {
    _rejectDocId = docId;
    _rejectReasonController.clear();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _RejectModal(
        docId: docId,
        reasonController: _rejectReasonController,
        onReject: () async {
          if (_rejectReasonController.text.trim().isEmpty) {
            _showToast('Please provide a reason for rejection.', isError: true);
            return;
          }
          try {
            await _api.rejectDocument(
              _rejectDocId!,
              _rejectReasonController.text.trim(),
            );
            _showToast('Document $_rejectDocId rejected. Reason logged.');
            Navigator.pop(context);
            await _loadVendors();
          } catch (e) {
            _showToast('Failed to reject: ${e.toString()}', isError: true);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _openOpportunityModal(String vendorId, String docId) {
    _opportunityVendorId = vendorId;
    _opportunityDocId = docId;
    _opportunityTitleController.clear();
    _scopeController.clear();
    _budgetController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _OpportunityModal(
        vendorId: vendorId,
        docId: docId,
        titleController: _opportunityTitleController,
        scopeController: _scopeController,
        budgetController: _budgetController,
        onSubmit: () async {
          final title = _opportunityTitleController.text.trim();
          final description = _scopeController.text.trim();
          final budget = int.tryParse(_budgetController.text.trim()) ?? 0;

          if (title.isEmpty || description.isEmpty || budget <= 0) {
            _showToast('Please fill all fields correctly.', isError: true);
            return;
          }

          try {
            await _api.postOpportunity(
              vendorId: _opportunityVendorId!,
              docId: _opportunityDocId!,
              title: title,
              description: description,
              budget: budget,
            );
            final id = 'OPP-${1000 + (DateTime.now().millisecondsSinceEpoch % 9000)}';
            _showToast('Opportunity created successfully with ID: $id');
            Navigator.pop(context);
          } catch (e) {
            _showToast('Failed to post opportunity: ${e.toString()}',
                isError: true);
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  Future<void> _bulkApprove() async {
    if (_selectedDocIds.isEmpty) return;

    try {
      final count = await _api.bulkApprove(_selectedDocIds);
      _showToast('Batch processing complete: $count documents approved successfully.');
      _deselectAll();
      await _loadVendors();
    } catch (e) {
      _showToast('Failed to bulk approve: ${e.toString()}', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isBulkActive = _selectedDocIds.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 64,
        title: const Text(
          'Serene Commerce',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF006565),
            fontFamily: 'Manrope',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFF006565)),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF006565)),
            onPressed: _loadVendors,
          ),
          Container(
            width: 40,
            height: 40,
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFBDC9C8)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuAcW-kobPLh9svhTZe-DXE6bEHXK9MNZhLP465XDatgqQUxod0A6D30rD_MpUvnSHA_wmMjXcYrKATGmNu7Cg7mWZK0R6zLVZP7WFe_0F6xGr2N5NuHp-c5IOFxiB1jtPnB-7S0XEtljTJKH2CjjmF7alkbixuRbC27ZgxK3SOTXG7sRg_tv2ciGfWgULQga6kOcjcKRn72wmckWK0InqayQOwUWppuBzQRuXzu41Rej6DCLQXNZzZj',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.person),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(0),
          child: Container(
            height: 1,
            color: const Color(0xFFBDC9C8),
          ),
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Search bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEEEED),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search vendors by ID or name...',
                        hintStyle: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3E4949),
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(0xFF3E4949),
                          size: 20,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                ),
                // Page Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Document Verification',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006565),
                          fontFamily: 'Manrope',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage vendor documentation compliance and distribute high-value business opportunities within your partner ecosystem.',
                        style: TextStyle(
                          fontSize: 16,
                          color: const Color(0xFF3E4949),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
                // Vendor List
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _error.isNotEmpty
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: Colors.red[300]),
                        const SizedBox(height: 16),
                        Text(
                          _error,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadVendors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                      : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _vendors.length,
                    itemBuilder: (context, index) {
                      final vendor = _vendors[index];
                      final isExpanded =
                      _expandedVendors.contains(vendor.id);

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: const Color(0xFFBDC9C8)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Vendor Header
                            InkWell(
                              onTap: () => _toggleVendor(vendor.id),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 56,
                                      height: 56,
                                      decoration: BoxDecoration(
                                        color:
                                        const Color(0xFFEEEEED),
                                        borderRadius:
                                        BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(
                                              0xFFBDC9C8),
                                        ),
                                      ),
                                      child: Center(
                                        child: Text(
                                          vendor.name.substring(0, 2),
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight:
                                            FontWeight.w700,
                                            color:
                                            Color(0xFF006565),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            vendor.name,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight:
                                              FontWeight.w700,
                                              color:
                                              Color(0xFF1A1C1C),
                                              fontFamily: 'Manrope',
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Wrap(
                                            spacing: 12,
                                            runSpacing: 2,
                                            children: [
                                              _buildInfoChip(
                                                Icons.fingerprint,
                                                vendor.id,
                                              ),
                                              _buildInfoChip(
                                                Icons.location_on,
                                                vendor.location,
                                              ),
                                              _buildInfoChip(
                                                Icons.calendar_today,
                                                vendor.joined,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          'Documents (${vendor.docs.length})',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight:
                                            FontWeight.w600,
                                            color: Color(0xFF006565),
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color:
                                          const Color(0xFF006565),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Expanded Documents
                            if (isExpanded)
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: const BoxDecoration(
                                  border: Border(
                                    top: BorderSide(
                                      color: Color(0xFFBDC9C8),
                                    ),
                                  ),
                                  color: Color(0xFFEEEEED),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'COMPLIANCE DOCUMENTATION',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5,
                                        color: Color(0xFF3E4949),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ...vendor.docs.map(
                                          (doc) => _DocumentCard(
                                        doc: doc,
                                        isSelected: _selectedDocIds
                                            .contains(doc.id),
                                        onSelect: () =>
                                            _toggleDocumentSelection(
                                                doc.id),
                                        onApprove: () =>
                                            _approveDocument(doc.id),
                                        onReject: () =>
                                            _openRejectModal(doc.id),
                                        onPostOpportunity: () =>
                                            _openOpportunityModal(
                                                vendor.id, doc.id),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                // Bottom padding for bulk bar
                const SizedBox(height: 80),
              ],
            ),
          ),
          // Bulk Action Bar
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: isBulkActive ? 0 : -80,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF9F9F9),
                border: const Border(
                  top: BorderSide(color: Color(0xFFBDC9C8)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF006565),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${_selectedDocIds.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Documents Selected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF006565),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: _deselectAll,
                        child: const Text(
                          'Deselect All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _bulkApprove,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Bulk Approve',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF3E4949)),
        const SizedBox(width: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949)),
        ),
      ],
    );
  }
}

// ---------- DOCUMENT CARD ----------
class _DocumentCard extends StatelessWidget {
  final Document doc;
  final bool isSelected;
  final VoidCallback onSelect;
  final VoidCallback onApprove;
  final VoidCallback onReject;
  final VoidCallback onPostOpportunity;

  const _DocumentCard({
    required this.doc,
    required this.isSelected,
    required this.onSelect,
    required this.onApprove,
    required this.onReject,
    required this.onPostOpportunity,
  });

  @override
  Widget build(BuildContext context) {
    final isApproved = doc.status == 'approved';
    final isPending = doc.status == 'pending';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF006565).withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              doc.type == 'PDF'
                  ? Icons.picture_as_pdf
                  : doc.type == 'JPG'
                  ? Icons.image
                  : Icons.assignment,
              color: const Color(0xFF006565),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: isSelected,
                      onChanged: (_) => onSelect(),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: Color(0xFFBDC9C8)),
                      activeColor: const Color(0xFF006565),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doc.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1C1C),
                            ),
                          ),
                          Text(
                            '${doc.type} • Uploaded ${doc.uploaded}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                          if (doc.notes.isNotEmpty)
                            Text(
                              'Note: ${doc.notes}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF6E7979),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isApproved
                            ? const Color(0xFF008080).withOpacity(0.08)
                            : isPending
                            ? const Color(0xFFB45309).withOpacity(0.08)
                            : const Color(0xFFBA1A1A).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        doc.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isApproved
                              ? const Color(0xFF008080)
                              : isPending
                              ? const Color(0xFFB45309)
                              : const Color(0xFFBA1A1A),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        if (isPending || doc.status == 'rejected')
                          IconButton(
                            onPressed: onApprove,
                            icon: const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFF006565),
                              padding: const EdgeInsets.all(4),
                              minimumSize: const Size(32, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        if (isPending)
                          IconButton(
                            onPressed: onReject,
                            icon: const Icon(
                              Icons.close,
                              color: Color(0xFFBA1A1A),
                              size: 18,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: const Color(0xFFBA1A1A)
                                  .withOpacity(0.08),
                              padding: const EdgeInsets.all(4),
                              minimumSize: const Size(32, 32),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        const SizedBox(width: 4),
                        if (isPending || isApproved)
                          ElevatedButton(
                            onPressed: onPostOpportunity,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xE3FFFE),
                              foregroundColor: const Color(0xFF306E6D),
                              side: const BorderSide(
                                color: Color(0xFF006565),
                                width: 0.5,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            child: const Text(
                              'POST OPPORTUNITY',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------- REJECT MODAL ----------
class _RejectModal extends StatelessWidget {
  final String docId;
  final TextEditingController reasonController;
  final VoidCallback onReject;
  final VoidCallback onCancel;

  const _RejectModal({
    required this.docId,
    required this.reasonController,
    required this.onReject,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_outlined, color: Color(0xFF006565)),
              SizedBox(width: 8),
              Text(
                'Rejection Reason',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF006565),
                  fontFamily: 'Manrope',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide a reason for rejecting document $docId. The vendor will be notified immediately.',
            style: const TextStyle(
              fontSize: 14,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: reasonController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'e.g. Document is expired or signature is missing...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF006565)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: onCancel,
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF3E4949),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onReject,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBA1A1A),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Reject Document',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- OPPORTUNITY MODAL ----------
class _OpportunityModal extends StatelessWidget {
  final String vendorId;
  final String docId;
  final TextEditingController titleController;
  final TextEditingController scopeController;
  final TextEditingController budgetController;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _OpportunityModal({
    required this.vendorId,
    required this.docId,
    required this.titleController,
    required this.scopeController,
    required this.budgetController,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Post Strategic Opportunity',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006565),
                fontFamily: 'Manrope',
              ),
            ),
            const Text(
              'Transform approved compliance into a business partnership.',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF3E4949),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'VENDOR ID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4949),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: Text(
                          vendorId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3E4949),
                          ),
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
                        'SOURCE DOC ID',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF3E4949),
                          letterSpacing: 0.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: Text(
                          docId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'OPPORTUNITY TITLE',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E4949),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'e.g. EU Logistics Route Expansion Q4',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF006565)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'SCOPE DESCRIPTION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E4949),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: scopeController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Detail the strategic requirements...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF006565)),
                ),
                contentPadding: const EdgeInsets.all(10),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'BUDGET ALLOCATION (USD)',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Color(0xFF3E4949),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            TextField(
              controller: budgetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: '\$ ',
                hintText: '0.00',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(6),
                  borderSide: const BorderSide(color: Color(0xFF006565)),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onCancel,
                  child: const Text(
                    'Discard',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF3E4949),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: onSubmit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Post Opportunity',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
}