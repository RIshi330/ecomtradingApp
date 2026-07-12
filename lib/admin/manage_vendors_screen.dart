import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode, debugPrint;
import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

void _log(String tag, String message) {
  if (kDebugMode) {
    debugPrint('[$tag] $message');
  }
}

class VendorApiException implements Exception {
  final String message;
  final int? statusCode;
  VendorApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Vendor API service.
///
/// CHANGED: this no longer builds its own http.Client, cookie jar, or
/// session cache. Every other screen in the app (see
/// BusinessUserProfileScreen) talks to the backend through the single
/// shared `Database` class, which already owns SESSION_ID + raw cookie
/// capture/replay and the 401 -> logout -> redirect flow. Having a second,
/// parallel session mechanism here was the root cause of the flaky 401s:
/// a cookie refresh captured by one class wasn't reliably visible to the
/// other. Now this class is a thin wrapper: pass `action` (+ params) in
/// the body, endpoint is the vendor API's relative path, and Database
/// handles auth end-to-end.
class VendorApiService {
  VendorApiService._internal();
  static final VendorApiService instance = VendorApiService._internal();

  static const String _endpoint = 'new_apis/manage_vendor_api.php';

  final Database _db = Database();

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    _log('VendorApi', 'action=${body['action']} body=$body');

    final result = await _db.getData(body, endpoint: _endpoint);

    _log('VendorApi', 'response status=${result['status']} keys=${result.keys.toList()}');

    // Database() already handles empty-body / invalid-JSON / network errors
    // by returning a Map with status: 300 and an 'error' key — surface that
    // consistently as a VendorApiException instead of letting callers deal
    // with raw Database error shapes.
    if (result['status'] == 300) {
      throw VendorApiException(
        result['error']?.toString() ?? 'Unexpected server response',
        statusCode: 300,
      );
    }

    final bool looksUnauthorized = result['status'] == 401 ||
        (result['message']?.toString().contains('Unauthorized') ?? false) ||
        (result['message']?.toString().contains('Session expired') ?? false) ||
        result.containsKey('logged_out');

    if (looksUnauthorized) {
      _log('VendorApi', 'Session looks expired/unauthorized for action=${body['action']}');
      throw VendorApiException(
        result['message']?.toString() ?? 'Session expired, please log in again.',
        statusCode: 401,
      );
    }

    if (result['success'] != true) {
      _log('VendorApi', 'API returned success=false: ${result['message']}');
      throw VendorApiException(
        result['message']?.toString() ?? 'Request failed',
        statusCode: result['status'] is int ? result['status'] as int : null,
      );
    }

    return Map<String, dynamic>.from(result);
  }

  Future<Map<String, dynamic>> getDashboardStats() =>
      _call({'action': 'get_dashboard_stats'})
          .then((r) => Map<String, dynamic>.from(r['data'] ?? {}));

  Future<Map<String, dynamic>> getVendors({
    String search = '',
    String type = 'all',
    String status = 'all',
    int page = 1,
    int perPage = 8,
  }) =>
      _call({
        'action': 'get_vendors',
        'search': search,
        'type': type,
        'status': status,
        'page': page,
        'per_page': perPage,
      }).then((r) => Map<String, dynamic>.from(r['data'] ?? {}));

  Future<Map<String, dynamic>> getVendorDetails(int vendorId) =>
      _call({'action': 'get_vendor_details', 'vendor_id': vendorId})
          .then((r) => Map<String, dynamic>.from(r['data'] ?? {}));

  Future<void> approveVendor(int vendorId) =>
      _call({'action': 'approve_vendor', 'vendor_id': vendorId});

  Future<void> rejectVendor(int vendorId) =>
      _call({'action': 'reject_vendor', 'vendor_id': vendorId});

  Future<void> suspendVendor(int vendorId) =>
      _call({'action': 'suspend_vendor', 'vendor_id': vendorId});

  Future<void> contactVendor(int vendorId, String message) => _call({
    'action': 'contact_vendor',
    'vendor_id': vendorId,
    'message': message,
  });

  Future<int> addVendor({
    required String name,
    required String email,
    String mobile = '',
    int status = 0,
  }) async {
    final res = await _call({
      'action': 'add_vendor',
      'name': name,
      'email': email,
      'mobile': mobile,
      'status': status,
    });
    return res['data']['vendor_id'] as int;
  }

  Future<void> updateTransactionCharge(int vendorId, double amount) => _call({
    'action': 'update_transaction_charge',
    'vendor_id': vendorId,
    'amount': amount,
  });

  Future<int> bulkUpdateCharges(List<int> vendorIds, double amount) async {
    final res = await _call({
      'action': 'bulk_update_charges',
      'vendor_ids': vendorIds,
      'amount': amount,
    });
    return res['data']['count'] as int;
  }

  Future<void> grantWebsitePermission(int vendorId) =>
      _call({'action': 'grant_website_permission', 'vendor_id': vendorId});

  Future<void> revokeWebsitePermission(int vendorId) =>
      _call({'action': 'revoke_website_permission', 'vendor_id': vendorId});

  Future<int> notifyMembership(List<int> vendorIds, String message) async {
    final res = await _call({
      'action': 'notify_membership',
      'vendor_ids': vendorIds,
      'message': message,
    });
    return res['data']['sent'] as int;
  }
}

class ManageVendorsScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManageVendorsScreen({super.key, this.isEmbedded = false});

  @override
  State<ManageVendorsScreen> createState() => _ManageVendorsScreenState();
}

class _ManageVendorsScreenState extends State<ManageVendorsScreen> {
  static const Color primaryTeal = Color(0xFF008080);
  static const Color secondaryTeal = Color(0xFF296767);
  static const Color containerTeal = Color(0xFFE3FFFE);
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color surfaceWhite = Colors.white;
  static const Color borderTeal = Color(0xFFBDC9C8);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color errorColor = Color(0xFFBA1A1A);

  final VendorApiService _api = VendorApiService.instance;

  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  String _search = '';
  String _typeFilter = 'all';
  String _statusFilter = 'all';

  int _page = 1;
  int _totalPages = 1;
  final int _perPage = 8;

  List<Map<String, dynamic>> _vendors = [];
  List<Map<String, dynamic>> _pendingReviews = [];
  List<Map<String, dynamic>> _vendorTypes = [];

  bool _loadingDashboard = true;
  bool _loadingVendors = true;
  String? _dashboardError;
  String? _vendorsError;

  @override
  void initState() {
    super.initState();
    _log('ManageVendorsScreen', 'initState');
    _loadDashboard();
    _loadVendors();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboard() async {
    _log('ManageVendorsScreen', '_loadDashboard start');
    setState(() {
      _loadingDashboard = true;
      _dashboardError = null;
    });
    try {
      final data = await _api.getDashboardStats();
      final pending = List<Map<String, dynamic>>.from(data['pending_vendors'] ?? []);
      final types = List<Map<String, dynamic>>.from(data['vendor_types'] ?? []);
      _log('ManageVendorsScreen',
          '_loadDashboard OK — pending=${pending.length} types=${types.length}');
      setState(() {
        _pendingReviews = pending;
        _vendorTypes = types;
      });
    } on VendorApiException catch (e) {
      _log('ManageVendorsScreen', '_loadDashboard FAILED: ${e.message}');
      setState(() => _dashboardError = e.message);
    } catch (e, st) {
      _log('ManageVendorsScreen', '_loadDashboard UNEXPECTED ERROR: $e\n$st');
      setState(() => _dashboardError = 'Unexpected error: $e');
    } finally {
      setState(() => _loadingDashboard = false);
    }
  }

  Future<void> _loadVendors() async {
    _log('ManageVendorsScreen',
        '_loadVendors start — search="$_search" type=$_typeFilter status=$_statusFilter page=$_page');
    setState(() {
      _loadingVendors = true;
      _vendorsError = null;
    });
    try {
      final data = await _api.getVendors(
        search: _search,
        type: _typeFilter,
        status: _statusFilter,
        page: _page,
        perPage: _perPage,
      );
      final vendors = List<Map<String, dynamic>>.from(data['vendors'] ?? []);
      _log('ManageVendorsScreen',
          '_loadVendors OK — count=${vendors.length} total_pages=${data['total_pages']}');
      setState(() {
        _vendors = vendors;
        _totalPages = (data['total_pages'] ?? 1) is int
            ? data['total_pages']
            : int.tryParse(data['total_pages'].toString()) ?? 1;
      });
    } on VendorApiException catch (e) {
      _log('ManageVendorsScreen', '_loadVendors FAILED: ${e.message} (status ${e.statusCode})');
      setState(() => _vendorsError = e.message);
    } catch (e, st) {
      _log('ManageVendorsScreen', '_loadVendors UNEXPECTED ERROR: $e\n$st');
      setState(() => _vendorsError = 'Unexpected error: $e');
    } finally {
      setState(() => _loadingVendors = false);
    }
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        _search = value;
        _page = 1;
      });
      _loadVendors();
    });
  }

  void _refreshAll() {
    _log('ManageVendorsScreen', 'manual refresh triggered');
    _loadDashboard();
    _loadVendors();
  }

  void _triggerAction(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.info_outline,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
        backgroundColor: isError ? errorColor : primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _runAction(Future<void> Function() call, String successMsg) async {
    try {
      await call();
      if (!mounted) return;
      _triggerAction(successMsg);
      _refreshAll();
    } on VendorApiException catch (e) {
      if (!mounted) return;
      _triggerAction(e.message, isError: true);
    }
  }

  void _approvePending(Map<String, dynamic> review) {
    final id = review['id'] as int;
    _runAction(() => _api.approveVendor(id),
        'Approved: ${review['name']} added to directory');
  }

  void _rejectPending(Map<String, dynamic> review) {
    _runAction(() => _api.rejectVendor(review['id'] as int),
        'Application for ${review['name']} rejected');
  }

  void _onboardNewVendor() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool createAccount = false;
    bool onboardingSuccess = false;
    bool submitting = false;
    String? formError;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: onboardingSuccess
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: const BoxDecoration(
                            color: containerTeal, shape: BoxShape.circle),
                        child: const Icon(Icons.check_circle_rounded,
                            color: primaryTeal, size: 40),
                      ),
                      const SizedBox(height: 20),
                      const Text('Vendor Onboarded!',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textDark,
                              fontFamily: 'Manrope')),
                      const SizedBox(height: 8),
                      const Text(
                        'The vendor record was created successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: textLight),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text('DONE',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                )
                    : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: primaryTeal,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Onboard New Vendor',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Manrope')),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FULL NAME / COMPANY NAME',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: textLight)),
                            const SizedBox(height: 6),
                            TextField(
                              controller: nameCtrl,
                              style: const TextStyle(fontSize: 13),
                              decoration: const InputDecoration(
                                hintText: 'Enter name...',
                                border: OutlineInputBorder(),
                                contentPadding:
                                EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('EMAIL',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: textLight)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: emailCtrl,
                                        style: const TextStyle(fontSize: 13),
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: const InputDecoration(
                                          hintText: 'email@example.com',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
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
                                      const Text('MOBILE NO',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: textLight)),
                                      const SizedBox(height: 6),
                                      TextField(
                                        controller: phoneCtrl,
                                        style: const TextStyle(fontSize: 13),
                                        keyboardType: TextInputType.phone,
                                        decoration: const InputDecoration(
                                          hintText: '+1...',
                                          border: OutlineInputBorder(),
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 10),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: createAccount,
                                  activeColor: Colors.grey,
                                  onChanged: (val) {
                                    if (val != null) {
                                      setModalState(() => createAccount = val);
                                    }
                                  },
                                ),
                                const Expanded(
                                  child: Text(
                                    'Activate account immediately (else stays pending)',
                                    style: TextStyle(fontSize: 11, color: textLight),
                                  ),
                                ),
                              ],
                            ),
                            if (formError != null) ...[
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: Text(formError!,
                                    style: const TextStyle(fontSize: 11, color: errorColor)),
                              ),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: submitting ? null : () => Navigator.pop(context),
                                    child: const Text('CANCEL',
                                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryTeal,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8)),
                                    ),
                                    onPressed: submitting
                                        ? null
                                        : () async {
                                      if (nameCtrl.text.trim().isEmpty ||
                                          emailCtrl.text.trim().isEmpty) {
                                        setModalState(() =>
                                        formError = 'Name and Email are required.');
                                        return;
                                      }
                                      setModalState(() {
                                        submitting = true;
                                        formError = null;
                                      });
                                      try {
                                        await _api.addVendor(
                                          name: nameCtrl.text.trim(),
                                          email: emailCtrl.text.trim(),
                                          mobile: phoneCtrl.text.trim(),
                                          status: createAccount ? 1 : 0,
                                        );
                                        setModalState(() {
                                          submitting = false;
                                          onboardingSuccess = true;
                                        });
                                        _refreshAll();
                                      } on VendorApiException catch (e) {
                                        setModalState(() {
                                          submitting = false;
                                          formError = e.message;
                                        });
                                      }
                                    },
                                    child: submitting
                                        ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white),
                                    )
                                        : const Text('CREATE ACCOUNT',
                                        style: TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.bold)),
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
              ),
            );
          },
        );
      },
    );
  }

  void _openProfileModal(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _api.getVendorDetails(vendor['id'] as int),
              builder: (context, snapshot) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      decoration: const BoxDecoration(
                        color: primaryTeal,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Vendor Profile',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Manrope')),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white, size: 20),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Builder(builder: (context) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(color: primaryTeal),
                          );
                        }
                        if (snapshot.hasError) {
                          final msg = snapshot.error is VendorApiException
                              ? (snapshot.error as VendorApiException).message
                              : 'Failed to load vendor details';
                          return Text(msg, style: const TextStyle(color: errorColor, fontSize: 13));
                        }
                        final v = snapshot.data ?? {};
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: bgLight,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: borderTeal.withOpacity(0.5)),
                                  ),
                                  child: const Icon(Icons.storefront_rounded,
                                      color: primaryTeal, size: 30),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(v['name']?.toString() ?? '',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                              color: textDark)),
                                      const SizedBox(height: 2),
                                      Text(v['company_name']?.toString() ?? '—',
                                          style: const TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              color: primaryTeal)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _statTile('EMAIL', v['email']?.toString() ?? '—')),
                                const SizedBox(width: 12),
                                Expanded(child: _statTile('MOBILE', v['mobile']?.toString() ?? '—')),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _statTile(
                                    'LOCATION',
                                    [v['city'], v['state']]
                                        .where((e) => e != null && e.toString().isNotEmpty)
                                        .join(', ')
                                        .isEmpty
                                        ? '—'
                                        : [v['city'], v['state']].where((e) => e != null).join(', '),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _statTile('TXN CHARGE', '${v['transaction_charge'] ?? '0'}%'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text('CLOSE PROFILE',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _statTile(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  void _openSuspendModal(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: errorColor.withOpacity(0.1), shape: BoxShape.circle),
                child: const Icon(Icons.warning_amber_rounded, color: errorColor, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Suspend Vendor?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to suspend ${vendor['name']}? They will lose access immediately.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: textLight),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('KEEP ACTIVE',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _runAction(() => _api.suspendVendor(vendor['id'] as int), 'Vendor suspended');
                      },
                      child: const Text('SUSPEND NOW',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openContactModal(Map<String, dynamic> vendor) {
    final msgCtrl = TextEditingController();
    bool sending = false;
    String? error;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Dialog(
            backgroundColor: surfaceWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: const BoxDecoration(
                      color: containerTeal,
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Contact Vendor',
                            style: TextStyle(
                                color: primaryTeal,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Manrope')),
                        IconButton(
                          icon: const Icon(Icons.close, color: primaryTeal, size: 20),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('RECIPIENT',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
                          child: Text(vendor['name']?.toString() ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                        ),
                        const SizedBox(height: 16),
                        const Text('MESSAGE',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: msgCtrl,
                          maxLines: 5,
                          style: const TextStyle(fontSize: 13),
                          decoration: const InputDecoration(
                            hintText: 'Write your message here...',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 8),
                          Text(error!, style: const TextStyle(fontSize: 11, color: errorColor)),
                        ],
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                                onPressed: sending ? null : () => Navigator.pop(context),
                                child: const Text('CLOSE',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryTeal,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: sending
                                    ? null
                                    : () async {
                                  if (msgCtrl.text.trim().isEmpty) {
                                    setModalState(() => error = 'Message cannot be empty.');
                                    return;
                                  }
                                  setModalState(() {
                                    sending = true;
                                    error = null;
                                  });
                                  try {
                                    await _api.contactVendor(
                                        vendor['id'] as int, msgCtrl.text.trim());
                                    if (context.mounted) Navigator.pop(context);
                                    _triggerAction('Message sent successfully!');
                                  } on VendorApiException catch (e) {
                                    setModalState(() {
                                      sending = false;
                                      error = e.message;
                                    });
                                  }
                                },
                                icon: sending
                                    ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                                    : const Icon(Icons.send_rounded, size: 14),
                                label: const Text('SEND MESSAGE',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
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
          );
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    Widget mainContent = RefreshIndicator(
      color: primaryTeal,
      onRefresh: () async => _refreshAll(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isMobile
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Manage Vendors',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
                const SizedBox(height: 6),
                const Text('Oversee strategic partnerships and manage your professional network dossier.',
                    style: TextStyle(fontSize: 12, color: textLight)),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 44),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _onboardNewVendor,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Onboard New Vendor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('VIRTUAL DIRECTORY',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5)),
                      SizedBox(height: 4),
                      Text('Manage Vendors',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
                      SizedBox(height: 6),
                      Text('Oversee strategic partnerships and manage your professional network dossier.',
                          style: TextStyle(fontSize: 12, color: textLight)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryTeal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _onboardNewVendor,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('Onboard New Vendor', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Pending Reviews',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: primaryTeal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text('${_pendingReviews.length} New',
                      style: const TextStyle(fontSize: 9, color: primaryTeal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_loadingDashboard)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Center(child: CircularProgressIndicator(color: primaryTeal)),
              )
            else if (_dashboardError != null)
              _errorBox(_dashboardError!, _loadDashboard)
            else if (_pendingReviews.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    border: Border.all(color: borderTeal.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('No pending reviews remaining for this period.',
                        style: TextStyle(fontSize: 13, color: textLight, fontStyle: FontStyle.italic)),
                  ),
                )
              else
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(children: _pendingReviews.map((rev) => _buildPendingCard(rev)).toList()),
                ),
            const SizedBox(height: 24),

            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                border: Border.all(color: borderTeal),
                borderRadius: BorderRadius.circular(8),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search vendor dossier...',
                  prefixIcon: Icon(Icons.search_rounded, color: textLight),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildTypeDropdown()),
                const SizedBox(width: 12),
                Expanded(child: _buildStatusDropdown()),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Active Vendors',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
            const SizedBox(height: 12),
            if (_loadingVendors)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: CircularProgressIndicator(color: primaryTeal)),
              )
            else if (_vendorsError != null)
              _errorBox(_vendorsError!, _loadVendors)
            else if (_vendors.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: surfaceWhite,
                    border: Border.all(color: borderTeal.withOpacity(0.5)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('No vendors found matching your query.',
                        style: TextStyle(fontSize: 13, color: textLight, fontStyle: FontStyle.italic)),
                  ),
                )
              else ...[
                  Container(
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      border: Border.all(color: borderTeal),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _vendors.length,
                      itemBuilder: (context, idx) => _buildVendorRow(_vendors[idx], idx == _vendors.length - 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildPaginationBar(),
                ],
          ],
        ),
      ),
    );

    if (widget.isEmbedded) return mainContent;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('Manage Vendors', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: secondaryTeal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _refreshAll),
        ],
      ),
      body: SafeArea(child: mainContent),
    );
  }

  Widget _errorBox(String message, VoidCallback onRetry) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.06),
        border: Border.all(color: errorColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: errorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(child: Text(message, style: const TextStyle(fontSize: 12, color: errorColor))),
          TextButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildTypeDropdown() {
    final items = <DropdownMenuItem<String>>[
      const DropdownMenuItem(value: 'all', child: Text('All Types', style: TextStyle(fontSize: 12))),
      ..._vendorTypes.map((t) => DropdownMenuItem(
        value: t['title']?.toString() ?? '',
        child: Text(t['title']?.toString() ?? '', style: const TextStyle(fontSize: 12)),
      )),
    ];
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        border: Border.all(color: borderTeal),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _typeFilter,
          isExpanded: true,
          items: items,
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _typeFilter = val;
              _page = 1;
            });
            _loadVendors();
          },
        ),
      ),
    );
  }

  Widget _buildStatusDropdown() {
    const options = {
      'all': 'All Status',
      'active': 'Active',
      'pending': 'Pending',
      'suspended': 'Suspended',
      'verified': 'Verified',
    };
    return Container(
      decoration: BoxDecoration(
        color: surfaceWhite,
        border: Border.all(color: borderTeal),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _statusFilter,
          isExpanded: true,
          items: options.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value, style: const TextStyle(fontSize: 12))))
              .toList(),
          onChanged: (val) {
            if (val == null) return;
            setState(() {
              _statusFilter = val;
              _page = 1;
            });
            _loadVendors();
          },
        ),
      ),
    );
  }

  Widget _buildPaginationBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          color: primaryTeal,
          onPressed: _page > 1
              ? () {
            setState(() => _page--);
            _loadVendors();
          }
              : null,
        ),
        Text('Page $_page of $_totalPages', style: const TextStyle(fontSize: 12, color: textLight)),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          color: primaryTeal,
          onPressed: _page < _totalPages
              ? () {
            setState(() => _page++);
            _loadVendors();
          }
              : null,
        ),
      ],
    );
  }

  Widget _buildVendorRow(Map<String, dynamic> vendor, bool isLast) {
    final int status = int.tryParse(vendor['status'].toString()) ?? 0;
    final bool isSuspended = status == 2;
    final bool isVerified = (int.tryParse(vendor['verified'].toString()) ?? 0) == 1;
    final String tier = (vendor['type_names'] as List?)?.join(', ') ?? '';

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderTeal.withOpacity(0.5), width: isLast ? 0 : 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: bgLight,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderTeal.withOpacity(0.5)),
            ),
            child: const Icon(Icons.storefront_rounded, color: primaryTeal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        vendor['name']?.toString() ?? '',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isSuspended ? textLight : textDark,
                          decoration: isSuspended ? TextDecoration.lineThrough : null,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(Icons.verified, color: primaryTeal, size: 14),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Type: ${tier.isEmpty ? '—' : tier} • Email: ${vendor['email']}',
                  style: const TextStyle(fontSize: 10, color: textLight),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded, color: textLight),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('View Profile', style: TextStyle(fontSize: 13))),
              const PopupMenuItem(value: 'contact', child: Text('Contact', style: TextStyle(fontSize: 13))),
              const PopupMenuDivider(),
              PopupMenuItem(
                value: 'suspend',
                child: Text(
                  isSuspended ? 'Re-activate' : 'Suspend',
                  style: TextStyle(fontSize: 13, color: isSuspended ? primaryTeal : errorColor),
                ),
              ),
            ],
            onSelected: (action) {
              if (action == 'profile') {
                _openProfileModal(vendor);
              } else if (action == 'contact') {
                _openContactModal(vendor);
              } else if (action == 'suspend') {
                if (isSuspended) {
                  _runAction(() => _api.approveVendor(vendor['id'] as int), 'Vendor re-activated successfully');
                } else {
                  _openSuspendModal(vendor);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map<String, dynamic> review) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review['name']?.toString() ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                (review['created_date']?.toString() ?? '').split(' ').first,
                style: const TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(review['company_name']?.toString() ?? '—', style: const TextStyle(fontSize: 11, color: textLight)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _approvePending(review),
                    child: const Text('Approve', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () => _openContactModal(review),
                  child: const Icon(Icons.mail_outline_rounded, color: textLight, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: errorColor,
                    side: const BorderSide(color: borderTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _rejectPending(review),
                  child: const Icon(Icons.close_rounded, color: errorColor, size: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}