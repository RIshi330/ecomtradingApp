import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

// ============================================================================
// SHARED DESIGN TOKENS
// ============================================================================
class _OppColors {
  static const primary = Color(0xFF002B2F);
  static const primaryContainer = Color(0xFF004349);
  static const onPrimary = Color(0xFFFFFFFF);
  static const onPrimaryContainer = Color(0xFF90D2DA);
  static const primaryFixed = Color(0xFFABEEF6);
  static const primaryFixedDim = Color(0xFF9AD0D7);
  static const secondary = Color(0xFF4A626D);
  static const secondaryContainer = Color(0xFFCDE6F4);
  static const onSecondary = Color(0xFFFFFFFF);
  static const onSecondaryContainer = Color(0xFF506873);
  static const tertiary = Color(0xFF192929);
  static const surface = Color(0xFFF8FAFA);
  static const background = Color(0xFFF8FAFA);
  static const onSurface = Color(0xFF191C1C);
  static const onSurfaceVariant = Color(0xFF404849);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF2F4F4);
  static const surfaceContainer = Color(0xFFECEEEE);
  static const surfaceContainerHigh = Color(0xFFE6E8E8);
  static const outline = Color(0xFF70797A);
  static const outlineVariant = Color(0xFFBFC8C9);
  static const error = Color(0xFFBA1A1A);
  static const errorContainer = Color(0xFFFFDAD6);
  static const onErrorContainer = Color(0xFF93000A);
  static const successMuted = Color(0xFFE8F5E9);
}

BoxConstraints _responsiveDialogConstraints(
    BuildContext context, {
      double maxWidth = 460,
      double maxHeight = 680,
    }) {
  final size = MediaQuery.of(context).size;
  return BoxConstraints(
    maxWidth: min(maxWidth, size.width * 0.94),
    maxHeight: min(maxHeight, size.height * 0.9),
  );
}

// ============================================================================
// API SERVICE
// ============================================================================
class OpportunityActionException implements Exception {
  final String message;
  OpportunityActionException(this.message);
  @override
  String toString() => message;
}

class OpportunityActionApiService {
  OpportunityActionApiService._internal();
  static final OpportunityActionApiService instance =
  OpportunityActionApiService._internal();

  static const String _endpoint = 'new_apis/opportunity_details_api.php';
  final Database _db = Database();

  Future<Map<String, dynamic>> _call(Map<String, dynamic> body) async {
    final result = await _db.getData(body, endpoint: _endpoint);
    if (result == null) {
      throw OpportunityActionException('No response from server.');
    }
    if (result['success'] != true) {
      throw OpportunityActionException(
        result['message']?.toString() ?? 'Request failed. Please try again.',
      );
    }
    return Map<String, dynamic>.from(result);
  }

  int get _vendorId =>
      int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;
  int get _adminId =>
      int.tryParse(UserSessionSet.instance.adminId.toString()) ?? 0;
  Map<String, dynamic> _opportunityRefs(dynamic opportunityId) => {
    'opportunity_id': opportunityId,
    'item_id': opportunityId,
    'marketplace_id': opportunityId,
    'request_id': opportunityId,
  };

  Future<int> apply({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    String message = '',
    String coverLetter = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'apply',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'cover_letter': coverLetter.isNotEmpty ? coverLetter : message,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> fetchSavedAttachments() async {
    try {
      final res = await _call({
        'action': 'fetch_vendor_attachments',
        'admin_id': _adminId,
        'vendor_id': _vendorId,
      });
      final raw = res['data'];
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<int> appointment({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String date,
    required String time,
    String purpose = '',
    String notes = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'appointment',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'date': date,
      'time': time,
      'purpose': purpose,
      'notes': notes,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<List<String>> fetchAvailableSlots(dynamic opportunityId) async {
    try {
      final res = await _call({
        'action': 'fetch_available_slots',
        ..._opportunityRefs(opportunityId),
      });
      final raw = res['data'];
      if (raw is List) return raw.map((e) => e.toString()).toList();
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<int> callback({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String preferredTime,
    String subject = '',
    String notes = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'callback',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'preferred_time': preferredTime,
      'subject': subject,
      'notes': notes,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> donate({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required double amount,
    String notes = '',
    String attachment = '',
    bool anonymous = false,
  }) async {
    final res = await _call({
      'action': 'donate',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'amount': amount,
      'notes': notes,
      'attachment': attachment,
      'anonymous': anonymous ? 1 : 0,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> enroll({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String batch,
    String programId = '',
    String emergencyName = '',
    String emergencyPhone = '',
    String birthDate = '',
    String notes = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'enroll',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'batch': batch,
      'batch_id': programId,
      'program_id': programId,
      'emergency_name': emergencyName,
      'emergency_phone': emergencyPhone,
      'birth_date': birthDate,
      'notes': notes,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> proposal({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String type,
    required num price,
    String title = '',
    String terms = '',
    String notes = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'proposal',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'type': type,
      'proposal_title': title,
      'price': price,
      'budget': price,
      'terms': terms,
      'notes': notes,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> register({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String ticket,
    String ticketId = '',
    String notes = '',
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'register',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'ticket': ticket,
      'ticket_id': ticketId,
      'notes': notes,
      'attachment': attachment,
      'admin_id': _adminId,
      'vendor_id': _vendorId,
    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<List<Map<String, dynamic>>> fetchTicketTypes(
      dynamic opportunityId) async {
    try {
      final res = await _call({
        'action': 'fetch_ticket_types',
        ..._opportunityRefs(opportunityId),
      });
      final raw = res['data'];
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchPrograms(
      dynamic opportunityId) async {
    try {
      final res = await _call({
        'action': 'fetch_programs',
        ..._opportunityRefs(opportunityId),
      });
      final raw = res['data'];
      if (raw is List) {
        return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      }
      return const [];
    } catch (_) {
      return const [];
    }
  }
}

// ============================================================================
// MODAL BUILDING BLOCKS
// ============================================================================
class _ModalHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;
  const _ModalHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _OppColors.surfaceContainerLowest,
        border: Border(
          bottom: BorderSide(color: _OppColors.secondary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: _OppColors.primary,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close,
                color: _OppColors.onSurfaceVariant, size: 20),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _ModalFooter extends StatelessWidget {
  final bool submitting;
  final String submitLabel;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  const _ModalFooter({
    required this.submitting,
    required this.submitLabel,
    required this.onCancel,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _OppColors.surfaceContainerLowest,
        border: Border(
          top: BorderSide(color: _OppColors.secondary.withOpacity(0.15)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: submitting ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: _OppColors.primary,
                side: BorderSide(color: _OppColors.primary.withOpacity(0.3)),
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('CANCEL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: submitting ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _OppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              child: submitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : Text(submitLabel,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalLabel extends StatelessWidget {
  final String text;
  const _ModalLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.8,
        color: _OppColors.secondary,
      ),
    ),
  );
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: const TextStyle(fontSize: 13, color: _OppColors.outline),
  filled: true,
  fillColor: _OppColors.surfaceContainerLow,
  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:
    BorderSide(color: _OppColors.outlineVariant.withOpacity(0.6)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:
    BorderSide(color: _OppColors.outlineVariant.withOpacity(0.6)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide:
    const BorderSide(color: _OppColors.primaryContainer, width: 1.5),
  ),
);

class _ContactFields extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController phoneCtrl;
  const _ContactFields({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.phoneCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ModalLabel('FULL NAME'),
        TextField(
            controller: nameCtrl,
            decoration: _fieldDecoration('Enter your name')),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 320;
            final emailField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ModalLabel('EMAIL'),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _fieldDecoration('email@example.com'),
                ),
              ],
            );
            final phoneField = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _ModalLabel('PHONE'),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: _fieldDecoration('+1...'),
                ),
              ],
            );
            if (narrow) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  emailField,
                  const SizedBox(height: 14),
                  phoneField,
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: emailField),
                const SizedBox(width: 12),
                Expanded(child: phoneField),
              ],
            );
          },
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

Future<void> showOpportunityActionSuccess(
    BuildContext context, {
      required String title,
      required String message,
    }) {
  return showDialog(
    context: context,
    builder: (context) => Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints:
        _responsiveDialogConstraints(context, maxWidth: 380, maxHeight: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: _OppColors.primaryFixedDim.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded,
                    color: _OppColors.primary, size: 40),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                  color: _OppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13,
                    color: _OppColors.onSurfaceVariant,
                    height: 1.4),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _OppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('BACK TO OPPORTUNITY',
                      style:
                      TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

// ============================================================================
// MODAL DIALOG IMPLEMENTATIONS
// ============================================================================
class ApplyModal extends StatefulWidget {
  final dynamic opportunityId;
  final String opportunityTitle;
  const ApplyModal(
      {super.key, required this.opportunityId, required this.opportunityTitle});

  @override
  State<ApplyModal> createState() => _ApplyModalState();
}

class _ApplyModalState extends State<ApplyModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _statementCtrl = TextEditingController();
  final _newCvCtrl = TextEditingController();

  bool _loadingAttachments = true;
  List<Map<String, dynamic>> _savedAttachments = [];
  String? _selectedAttachment;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAttachments();
  }

  Future<void> _loadAttachments() async {
    final attachments = await _api.fetchSavedAttachments();
    if (!mounted) return;
    setState(() {
      _savedAttachments = attachments;
      _loadingAttachments = false;
    });
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final msg = _statementCtrl.text.trim();
      await _api.apply(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        message: msg,
        coverLetter: msg,
        attachment: _newCvCtrl.text.trim().isNotEmpty
            ? _newCvCtrl.text.trim()
            : (_selectedAttachment ?? ''),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Application Submitted!',
        message: 'Your application has been received and logged successfully.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Apply for Opportunity',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.opportunityTitle.isNotEmpty) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _OppColors.surfaceContainerLow,
                          border: const Border(
                              left: BorderSide(
                                  color: _OppColors.primaryContainer,
                                  width: 3)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text.rich(
                          TextSpan(
                            style: const TextStyle(
                                fontSize: 12.5,
                                color: _OppColors.onSurfaceVariant),
                            children: [
                              const TextSpan(text: 'Applying for: '),
                              TextSpan(
                                text: widget.opportunityTitle,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: _OppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    const _ModalLabel('STATEMENT OF INTEREST'),
                    TextField(
                      controller: _statementCtrl,
                      maxLines: 4,
                      decoration:
                      _fieldDecoration('Explain your qualifications...'),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingAttachments) ...[
                      const _ModalLabel('CHECKING SAVED FILES...'),
                      const LinearProgressIndicator(
                          minHeight: 2, color: _OppColors.primary),
                      const SizedBox(height: 8),
                    ] else if (_savedAttachments.isNotEmpty) ...[
                      const _ModalLabel('ATTACH SAVED DOSSIER'),
                      ..._savedAttachments.map((f) {
                        final name = (f['name'] ?? f['url'] ?? '').toString();
                        return RadioListTile<String>(
                          value: (f['url'] ?? name).toString(),
                          groupValue: _selectedAttachment,
                          onChanged: (v) =>
                              setState(() => _selectedAttachment = v),
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          activeColor: _OppColors.primary,
                          title: Text(name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13)),
                        );
                      }),
                      const SizedBox(height: 8),
                    ],
                    const _ModalLabel('OR PROVIDE FILE URL / DOCUMENT IDENTIFIER'),
                    TextField(
                      controller: _newCvCtrl,
                      decoration: _fieldDecoration(
                          'e.g., https://... or document.pdf'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'SUBMIT APPLICATION',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class AppointmentModal extends StatefulWidget {
  final dynamic opportunityId;
  const AppointmentModal({super.key, required this.opportunityId});
  @override
  State<AppointmentModal> createState() => _AppointmentModalState();
}

class _AppointmentModalState extends State<AppointmentModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _purposeCtrl = TextEditingController();
  final _customTimeCtrl = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  bool _loadingSlots = true;
  List<String> _availableSlots = [];
  String? _selectedSlot;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSlots();
  }

  Future<void> _loadSlots() async {
    final slots = await _api.fetchAvailableSlots(widget.opportunityId);
    if (!mounted) return;
    setState(() {
      _availableSlots = slots;
      _selectedSlot = slots.isNotEmpty ? slots.first : null;
      _loadingSlots = false;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    final time = _selectedSlot ?? _customTimeCtrl.text.trim();
    if (time.isEmpty) {
      setState(() => _error = 'Please choose or enter a preferred time.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final dateStr =
          '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      await _api.appointment(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        date: dateStr,
        time: time,
        purpose: _purposeCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Appointment Scheduled',
        message: 'Your meeting has been booked for $dateStr at $time.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Schedule Appointment',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    const _ModalLabel('SELECT DATE'),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: _OppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _OppColors.outlineVariant
                                  .withOpacity(0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today,
                                size: 17, color: _OppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_loadingSlots) ...[
                      const _ModalLabel('AVAILABLE SLOTS...'),
                      const LinearProgressIndicator(
                          minHeight: 2, color: _OppColors.primary),
                    ] else if (_availableSlots.isNotEmpty) ...[
                      const _ModalLabel('AVAILABLE TIMES'),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _availableSlots.map((slot) {
                          final selected = slot == _selectedSlot;
                          return ChoiceChip(
                            label: Text(slot,
                                style: const TextStyle(fontSize: 12)),
                            selected: selected,
                            selectedColor: _OppColors.primaryContainer
                                .withOpacity(0.15),
                            labelStyle: TextStyle(
                              color: selected
                                  ? _OppColors.primary
                                  : _OppColors.onSurfaceVariant,
                              fontWeight: selected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                              side: BorderSide(
                                color: selected
                                    ? _OppColors.primary
                                    : _OppColors.outlineVariant,
                              ),
                            ),
                            onSelected: (_) =>
                                setState(() => _selectedSlot = slot),
                          );
                        }).toList(),
                      ),
                    ] else ...[
                      const _ModalLabel('PREFERRED TIME'),
                      TextField(
                        controller: _customTimeCtrl,
                        decoration: _fieldDecoration('e.g., 10:30 AM'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const _ModalLabel('PURPOSE OF MEETING'),
                    TextField(
                      controller: _purposeCtrl,
                      decoration: _fieldDecoration('Meeting objective...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ADDITIONAL NOTES'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration:
                      _fieldDecoration('Any specific agenda points...'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'CONFIRM APPOINTMENT',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class CallbackModal extends StatefulWidget {
  final dynamic opportunityId;
  const CallbackModal({super.key, required this.opportunityId});
  @override
  State<CallbackModal> createState() => _CallbackModalState();
}

class _CallbackModalState extends State<CallbackModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  String _preferredTime = 'afternoon';
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _phoneCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and phone are required.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.callback(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        preferredTime: _preferredTime,
        subject: _subjectCtrl.text.trim(),
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Callback Requested',
        message: 'A representative will reach out in the $_preferredTime.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Request a Callback',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModalLabel('SUBJECT OF INQUIRY'),
                    TextField(
                      controller: _subjectCtrl,
                      decoration: _fieldDecoration('Inquiry subject...'),
                    ),
                    const SizedBox(height: 16),
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    const _ModalLabel('PREFERRED TIME WINDOW'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: ['morning', 'afternoon', 'evening'].map((t) {
                        final selected = t == _preferredTime;
                        return ChoiceChip(
                          label: Text(t[0].toUpperCase() + t.substring(1),
                              style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          selectedColor: _OppColors.primaryContainer
                              .withOpacity(0.15),
                          labelStyle: TextStyle(
                            color: selected
                                ? _OppColors.primary
                                : _OppColors.onSurfaceVariant,
                            fontWeight: selected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                              color: selected
                                  ? _OppColors.primary
                                  : _OppColors.outlineVariant,
                            ),
                          ),
                          onSelected: (_) => setState(() => _preferredTime = t),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ADDITIONAL NOTES'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration:
                      _fieldDecoration('Provide additional details...'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'SUBMIT REQUEST',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class DonateModal extends StatefulWidget {
  final dynamic opportunityId;
  const DonateModal({super.key, required this.opportunityId});
  @override
  State<DonateModal> createState() => _DonateModalState();
}

class _DonateModalState extends State<DonateModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _customAmountCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _anonymous = false;
  bool _submitting = false;
  String? _error;

  double? get _amount => double.tryParse(_customAmountCtrl.text.trim());

  Future<void> _submit() async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please enter a valid donation amount.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.donate(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        amount: amount,
        notes: _notesCtrl.text.trim(),
        anonymous: _anonymous,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Thank You for Donating!',
        message:
        'Your contribution of \$${amount.toStringAsFixed(2)} has been recorded.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Support Opportunity',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModalLabel('CONTRIBUTION AMOUNT (USD)'),
                    TextField(
                      controller: _customAmountCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration('Enter amount')
                          .copyWith(prefixText: '\$ '),
                    ),
                    const SizedBox(height: 16),
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    const _ModalLabel('ADDITIONAL NOTES / MESSAGE'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration:
                      _fieldDecoration('Optional message or note...'),
                    ),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _anonymous,
                      onChanged: (v) => setState(() => _anonymous = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _OppColors.primary,
                      title: const Text('Donate anonymously',
                          style: TextStyle(fontSize: 13)),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'DONATE NOW',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class EnrollModal extends StatefulWidget {
  final dynamic opportunityId;
  const EnrollModal({super.key, required this.opportunityId});
  @override
  State<EnrollModal> createState() => _EnrollModalState();
}

class _EnrollModalState extends State<EnrollModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emergencyNameCtrl = TextEditingController();
  final _emergencyPhoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime? _birthDate;
  bool _loadingPrograms = true;
  List<Map<String, dynamic>> _programs = [];
  String? _selectedProgramId;
  final _customBatchCtrl = TextEditingController();
  bool _agreedToTerms = false;
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPrograms();
  }

  Future<void> _loadPrograms() async {
    final programs = await _api.fetchPrograms(widget.opportunityId);
    if (!mounted) return;
    setState(() {
      _programs = programs;
      _selectedProgramId =
      programs.isNotEmpty ? (programs.first['id']?.toString()) : null;
      _loadingPrograms = false;
    });
  }

  String _programLabel(Map<String, dynamic> p) =>
      (p['name'] ?? p['title'] ?? p['batch'] ?? 'Batch Option').toString();

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _error = 'Please agree to the enrollment terms.');
      return;
    }
    final selectedProgram = _programs.firstWhere(
          (p) => p['id']?.toString() == _selectedProgramId,
      orElse: () => const {},
    );
    final batch = selectedProgram.isNotEmpty
        ? _programLabel(selectedProgram)
        : _customBatchCtrl.text.trim();
    if (batch.isEmpty) {
      setState(() => _error = 'Please select or enter a program.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final birthStr = _birthDate == null
          ? ''
          : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
      await _api.enroll(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        batch: batch,
        programId: _selectedProgramId ?? '',
        emergencyName: _emergencyNameCtrl.text.trim(),
        emergencyPhone: _emergencyPhoneCtrl.text.trim(),
        birthDate: birthStr,
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Enrollment Confirmed!',
        message: 'You have been enrolled into $batch.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Program Enrollment',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    if (_loadingPrograms) ...[
                      const _ModalLabel('LOADING PROGRAMS...'),
                      const LinearProgressIndicator(
                          minHeight: 2, color: _OppColors.primary),
                    ] else if (_programs.isNotEmpty) ...[
                      const _ModalLabel('SELECT BATCH / PROGRAM'),
                      DropdownButtonFormField<String>(
                        value: _selectedProgramId,
                        isExpanded: true,
                        decoration: _fieldDecoration('Choose program'),
                        items: _programs
                            .map((p) => DropdownMenuItem(
                          value: p['id']?.toString(),
                          child: Text(_programLabel(p),
                              overflow: TextOverflow.ellipsis),
                        ))
                            .toList(),
                        onChanged: (v) =>
                            setState(() => _selectedProgramId = v),
                      ),
                    ] else ...[
                      const _ModalLabel('BATCH NAME'),
                      TextField(
                        controller: _customBatchCtrl,
                        decoration:
                        _fieldDecoration('Enter program batch name'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const _ModalLabel('DATE OF BIRTH'),
                    InkWell(
                      onTap: _pickBirthDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        decoration: BoxDecoration(
                          color: _OppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _OppColors.outlineVariant
                                  .withOpacity(0.6)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.cake_outlined,
                                size: 17, color: _OppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              _birthDate == null
                                  ? 'Select birth date'
                                  : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                fontWeight: _birthDate != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontSize: 13,
                                color: _birthDate != null
                                    ? _OppColors.onSurface
                                    : _OppColors.outline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('EMERGENCY CONTACT'),
                    TextField(
                      controller: _emergencyNameCtrl,
                      decoration: _fieldDecoration('Contact Name'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emergencyPhoneCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: _fieldDecoration('Contact Phone'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ADDITIONAL NOTES'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 2,
                      decoration:
                      _fieldDecoration('Any extra details or notes...'),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _agreedToTerms,
                      onChanged: (v) =>
                          setState(() => _agreedToTerms = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _OppColors.primary,
                      title: const Text('I agree to the enrollment terms.',
                          style: TextStyle(fontSize: 12)),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'ENROLL NOW',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class ProposalModal extends StatefulWidget {
  final dynamic opportunityId;
  const ProposalModal({super.key, required this.opportunityId});
  @override
  State<ProposalModal> createState() => _ProposalModalState();
}

class _ProposalModalState extends State<ProposalModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _typeCtrl = TextEditingController();
  final _summaryCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty ||
        _titleCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name, email and proposal title are required.');
      return;
    }
    final budget = num.tryParse(_budgetCtrl.text.trim()) ?? 0;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.proposal(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        title: _titleCtrl.text.trim(),
        type: _typeCtrl.text.trim(),
        price: budget,
        terms: _titleCtrl.text.trim(),
        notes: _summaryCtrl.text.trim(),
        attachment: _attachmentCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Proposal Submitted',
        message:
        'Your commercial proposal "${_titleCtrl.text.trim()}" has been lodged.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Submit Commercial Proposal',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    const _ModalLabel('PROPOSAL TITLE'),
                    TextField(
                      controller: _titleCtrl,
                      decoration: _fieldDecoration('Proposal title...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('PROPOSAL / VENDOR TYPE'),
                    TextField(
                      controller: _typeCtrl,
                      decoration:
                      _fieldDecoration('e.g., Direct Bid, Consignment...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('EXECUTIVE SUMMARY & DELIVERABLES'),
                    TextField(
                      controller: _summaryCtrl,
                      maxLines: 4,
                      decoration: _fieldDecoration(
                          'Outline volume, delivery timelines, scope...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ESTIMATED PROPOSAL BUDGET (USD)'),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                      decoration:
                      _fieldDecoration('0.00').copyWith(prefixText: '\$ '),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('PROPOSAL DOSSIER LINK / FILENAME'),
                    TextField(
                      controller: _attachmentCtrl,
                      decoration: _fieldDecoration('e.g., proposal.pdf'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'LODGE PROPOSAL',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

class RegisterModal extends StatefulWidget {
  final dynamic opportunityId;
  const RegisterModal({super.key, required this.opportunityId});
  @override
  State<RegisterModal> createState() => _RegisterModalState();
}

class _RegisterModalState extends State<RegisterModal> {
  final _api = OpportunityActionApiService.instance;
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loadingTickets = true;
  List<Map<String, dynamic>> _tickets = [];
  String? _selectedTicketId;
  final _customTicketCtrl = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    final tickets = await _api.fetchTicketTypes(widget.opportunityId);
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _selectedTicketId =
      tickets.isNotEmpty ? tickets.first['id']?.toString() : null;
      _loadingTickets = false;
    });
  }

  String _ticketLabel(Map<String, dynamic> t) {
    final name = (t['name'] ?? t['title'] ?? 'Access Pass').toString();
    final price = t['price'];
    return price != null && price.toString().isNotEmpty ? '$name — $price' : name;
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Name and email are required.');
      return;
    }
    final selected = _tickets.firstWhere(
          (t) => t['id']?.toString() == _selectedTicketId,
      orElse: () => const {},
    );
    final ticket =
    selected.isNotEmpty ? _ticketLabel(selected) : _customTicketCtrl.text.trim();
    if (ticket.isEmpty) {
      setState(() => _error = 'Please select or enter a pass tier.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await _api.register(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        ticket: ticket,
        ticketId: _selectedTicketId ?? '',
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Registration Complete',
        message: 'Your registration ($ticket) has been recorded.',
      );
    } on OpportunityActionException catch (e) {
      setState(() {
        _submitting = false;
        _error = e.message;
      });
    } catch (e) {
      setState(() {
        _submitting = false;
        _error = 'Something went wrong. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: _OppColors.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: ConstrainedBox(
        constraints: _responsiveDialogConstraints(context, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(
                title: 'Event Registration',
                onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(
                        nameCtrl: _nameCtrl,
                        emailCtrl: _emailCtrl,
                        phoneCtrl: _phoneCtrl),
                    if (_loadingTickets) ...[
                      const _ModalLabel('CHECKING PASS TIERS...'),
                      const LinearProgressIndicator(
                          minHeight: 2, color: _OppColors.primary),
                    ] else if (_tickets.isNotEmpty) ...[
                      const _ModalLabel('PASS TIER'),
                      DropdownButtonFormField<String>(
                        value: _selectedTicketId,
                        isExpanded: true,
                        decoration: _fieldDecoration('Select tier'),
                        items: _tickets
                            .map((t) => DropdownMenuItem(
                          value: t['id']?.toString(),
                          child: Text(_ticketLabel(t),
                              overflow: TextOverflow.ellipsis),
                        ))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedTicketId = v),
                      ),
                    ] else ...[
                      const _ModalLabel('PASS TIER'),
                      TextField(
                        controller: _customTicketCtrl,
                        decoration: _fieldDecoration('Enter pass type'),
                      ),
                    ],
                    const SizedBox(height: 16),
                    const _ModalLabel('SPECIAL REQUIREMENTS'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: _fieldDecoration(
                          'Any requirements for the organizers?'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!,
                          style: const TextStyle(
                              color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'REGISTER NOW',
              onCancel: () => Navigator.pop(context),
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// OPPORTUNITY DETAILS SCREEN
// ============================================================================
class OpportunityDetailsScreen extends StatefulWidget {
  final dynamic opportunityId;
  const OpportunityDetailsScreen({super.key, this.opportunityId});

  @override
  State<OpportunityDetailsScreen> createState() =>
      _OpportunityDetailsScreenState();
}

class _OpportunityDetailsScreenState extends State<OpportunityDetailsScreen> {
  static const String _endpoint = 'new_apis/opportunity_details_api.php';
  static const String _marketplaceEndpoint =
      'new_apis/marketplace_opportunity_api.php';

  int get _vendorId =>
      int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;
  int get _adminId =>
      int.tryParse(UserSessionSet.instance.adminId.toString()) ?? 0;

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _opportunity;
  Map<String, dynamic>? _vendor;
  Map<String, dynamic>? _compensation;
  Map<String, dynamic>? _application;
  Map<String, dynamic>? _media;

  Map<String, dynamic>? _stats;
  bool _statsLoading = false;

  List<Map<String, dynamic>> _similarOpportunities = [];
  bool _similarLoading = false;
  bool _similarLoaded = false;

  bool _isBookmarked = false;
  bool _togglingBookmark = false;

  static const Map<int, String> _labelMap = {
    1: 'Featured',
    2: 'Sponsored',
    3: 'Premium',
  };

  // Normalized action key mapping
  static const Map<String, String> _actionAliases = {
    'apply': 'apply',
    'appointment': 'appointment',
    'request callback': 'callback',
    'callback': 'callback',
    'contact': 'callback',
    'donate': 'donate',
    'enroll': 'enroll',
    'proposal': 'proposal',
    'register': 'register',
  };

  String get _actionType {
    final raw = _opportunity?['preferred_actions']?.toString().trim().toLowerCase();
    if (raw != null && _actionAliases.containsKey(raw)) {
      return _actionAliases[raw]!;
    }
    return 'apply';
  }

  static const Map<String, String> _actionLabels = {
    'apply': 'Apply',
    'appointment': 'Schedule',
    'callback': 'Callback',
    'donate': 'Donate',
    'enroll': 'Enroll',
    'proposal': 'Proposal',
    'register': 'Register',
  };

  static const Map<String, IconData> _actionIcons = {
    'apply': Icons.payments_outlined,
    'appointment': Icons.event,
    'callback': Icons.call,
    'donate': Icons.volunteer_activism,
    'enroll': Icons.how_to_reg,
    'proposal': Icons.description_outlined,
    'register': Icons.confirmation_number_outlined,
  };

  String get _actionLabel => _actionLabels[_actionType] ?? 'Apply';
  IconData get _actionIcon =>
      _actionIcons[_actionType] ?? Icons.payments_outlined;

  @override
  void initState() {
    super.initState();
    _fetchDetails();

  }

  Map<String, dynamic>? _asMap(dynamic input) {
    if (input == null) return null;
    if (input is Map) {
      return Map<String, dynamic>.from(input);
    }
    return null;
  }

  Future<void> _fetchDetails() async {
    if (widget.opportunityId == null) {
      setState(() {
        _isLoading = false;
        _error = "No opportunity specified.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print(_adminId);
      print(_vendorId);
      final response = await Database().getData({
        'action': 'get_opportunity_details',
        'opportunity_id': widget.opportunityId,
        'item_id': widget.opportunityId,
        'marketplace_id': widget.opportunityId,
        'admin_id': _adminId,
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response == null ||
          response['success'] != true ||
          response['data'] == null) {
        final msg = response?['message']?.toString();
        throw Exception(
            msg != null && msg.isNotEmpty ? msg : 'Failed to load opportunity');
      }

      final data = _asMap(response['data']);
      if (data == null) {
        throw Exception('Invalid data structure received from server.');
      }

      Map<String, dynamic>? opp = _asMap(data['opportunity']);

      if (opp == null && (data.containsKey('title') || data.containsKey('id'))) {
        opp = data;
      }

      if (opp == null) {
        throw Exception('Opportunity details not found in response.');
      }

      if (!mounted) return;
      setState(() {
        _opportunity = opp;
        _vendor = _asMap(data['vendor']);
        _compensation = _asMap(data['compensation']);
        _application = _asMap(data['application']);
        _media = _asMap(data['media']);
        _isBookmarked =
            (int.tryParse(_opportunity?['is_bookmarked']?.toString() ?? '0') ??
                0) >
                0;
        _isLoading = false;
      });

      unawaited(_fetchStats());
      unawaited(_fetchSimilarOpportunities());
    } catch (e, stackTrace) {
      debugPrint("Error loading details: $e\n$stackTrace");
      if (mounted) {
        setState(() {
          _error =
          "Could not load opportunity details: ${e.toString().replaceAll('Exception: ', '')}";
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _fetchStats() async {
    if (widget.opportunityId == null) return;
    setState(() => _statsLoading = true);
    try {
      final response = await Database().getData({
        'action': 'get_opportunity_stats',
        'opportunity_id': widget.opportunityId,
        'admin_id': _adminId,
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
        if (!mounted) return;
        setState(() {
          _stats = Map<String, dynamic>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint("Error fetching stats: $e");
    } finally {
      if (mounted) setState(() => _statsLoading = false);
    }
  }

  Future<void> _fetchSimilarOpportunities() async {
    if (widget.opportunityId == null) return;
    setState(() => _similarLoading = true);
    try {
      final response = await Database().getData({
        'action': 'get_similar_opportunities',
        'opportunity_id': widget.opportunityId,
        'admin_id': _adminId,
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null &&
          response['success'] == true &&
          response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        final list = data['similar'];
        if (!mounted) return;
        setState(() {
          _similarOpportunities = list is List
              ? list.map((e) => Map<String, dynamic>.from(e as Map)).toList()
              : <Map<String, dynamic>>[];
          _similarLoaded = true;
        });
      } else if (mounted) {
        setState(() => _similarLoaded = true);
      }
    } catch (e) {
      debugPrint("Error fetching similar: $e");
      if (mounted) setState(() => _similarLoaded = true);
    } finally {
      if (mounted) setState(() => _similarLoading = false);
    }
  }

  Future<void> _toggleBookmark() async {
    if (_togglingBookmark || widget.opportunityId == null) return;
    final postId = int.tryParse(widget.opportunityId.toString()) ?? 0;
    if (postId == 0) return;

    setState(() => _togglingBookmark = true);
    try {
      final res = await Database().getData({
        'action': 'toggle_bookmark',
        'post_id': postId,
        'opportunity_id': postId,
        'admin_id': _adminId,
        'vendor_id': _vendorId,
      }, endpoint: _marketplaceEndpoint);

      if (res != null && res['success'] == true) {
        setState(() => _isBookmarked = res['data']?['bookmarked'] == true);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text(res?['message']?.toString() ?? 'Could not update bookmark.')),
        );
      }
    } catch (e) {
      debugPrint('Error toggling bookmark: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to update bookmark.')),
        );
      }
    } finally {
      if (mounted) setState(() => _togglingBookmark = false);
    }
  }

  Future<void> _openActionModal(String action) async {
    if (widget.opportunityId == null) return;
    switch (action) {
      case 'apply':
        await showDialog(
          context: context,
          builder: (_) => ApplyModal(
              opportunityId: widget.opportunityId,
              opportunityTitle: _title),
        );
        break;
      case 'appointment':
        await showDialog(
          context: context,
          builder: (_) =>
              AppointmentModal(opportunityId: widget.opportunityId),
        );
        break;
      case 'callback':
        await showDialog(
          context: context,
          builder: (_) => CallbackModal(opportunityId: widget.opportunityId),
        );
        break;
      case 'donate':
        await showDialog(
          context: context,
          builder: (_) => DonateModal(opportunityId: widget.opportunityId),
        );
        break;
      case 'enroll':
        await showDialog(
          context: context,
          builder: (_) => EnrollModal(opportunityId: widget.opportunityId),
        );
        break;
      case 'proposal':
        await showDialog(
          context: context,
          builder: (_) => ProposalModal(opportunityId: widget.opportunityId),
        );
        break;
      case 'register':
        await showDialog(
          context: context,
          builder: (_) => RegisterModal(opportunityId: widget.opportunityId),
        );
        break;
    }
    if (mounted) _fetchDetails();
  }

  String get _title => (_opportunity?['title'] ?? '').toString().trim();

  String get _rfqNumber {
    final raw = _opportunity?['rfq_number'] ??
        _opportunity?['code'] ??
        _opportunity?['rfq_id'];
    return (raw != null && raw.toString().trim().isNotEmpty)
        ? 'RFQ #${raw.toString().trim()}'
        : '';
  }

  String get _categoryTag =>
      (_opportunity?['category_title'] ?? '').toString().trim().toUpperCase();

  String get _pricingTag {
    final p = (_opportunity?['pricing_type'] ?? '').toString().trim();
    return p.isNotEmpty ? '${p.toUpperCase()} OPPORTUNITY' : '';
  }

  String get _labelName =>
      (_opportunity?['label_name'] ?? '').toString().trim();

  String get _companyName {
    final company = (_vendor?['company_name'] ?? '').toString().trim();
    if (company.isNotEmpty) return company;
    return (_vendor?['name'] ?? '').toString().trim();
  }

  String get _companyInitials {
    final name = _companyName;
    if (name.isEmpty) return '';
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, min(2, name.length)).toUpperCase();
  }

  bool get _isVendorVerified {
    final v = _vendor?['verified'] ?? _vendor?['verify'];
    return v == 1 || v == '1' || v == true;
  }

  int get _totalApplications =>
      int.tryParse('${_opportunity?['total_applications'] ?? 0}') ?? 0;

  String? get _totalLikesText {
    final raw = _stats?['total_likes'];
    if (raw == null) return null;
    final parsed = int.tryParse('$raw');
    return parsed != null ? '$parsed' : raw.toString();
  }

  String? get _totalViewsText {
    final raw = _stats?['total_views'];
    if (raw == null) return null;
    final parsed = int.tryParse('$raw');
    return parsed != null ? '$parsed' : raw.toString();
  }

  bool get _alreadyApplied =>
      (_opportunity?['application_status'] ?? '').toString() == 'applied';

  List<String> get _skills {
    final raw = _opportunity?['skills_array'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<String> get _certifications {
    final raw =
        _opportunity?['certifications_array'] ?? _opportunity?['certifications'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((c) => c.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split(',')
          .map((e) => e.trim())
          .where((c) => c.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<Map<String, dynamic>> get _requiredDocuments {
    final raw = _opportunity?['documents_array'];
    if (raw is List) {
      return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return const [];
  }

  String get _requiredTier => (_opportunity?['required_tier'] ??
      _opportunity?['membership_tier'] ??
      '')
      .toString()
      .trim();

  String get _targetAudience =>
      (_opportunity?['target_audience'] ?? '').toString().trim();

  String get _locationLine {
    final parts = [
      (_vendor?['city'] ?? '').toString().trim(),
      (_vendor?['state'] ?? '').toString().trim(),
      (_vendor?['country'] ?? '').toString().trim(),
    ].where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : '';
  }

  String get _moduleMapping {
    final raw =
        _opportunity?['module_mapping'] ?? _opportunity?['module_code'];
    return (raw != null && raw.toString().trim().isNotEmpty)
        ? raw.toString().trim()
        : '';
  }

  String get _priceAmountText {
    final raw = _opportunity?['price_amount'] ??
        _opportunity?['budget'] ??
        _compensation?['budget'];
    if (raw == null) return '';
    final amount = num.tryParse(raw.toString());
    if (amount == null) return raw.toString();
    return '\₹${_formatAmount(amount)}';
  }

  String _formatAmount(num amount) {
    if (amount >= 1000000) {
      final m = amount / 1000000;
      return '${m % 1 == 0 ? m.toStringAsFixed(0) : m.toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      final k = amount / 1000;
      return '${k % 1 == 0 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
    }
    return amount.toStringAsFixed(0);
  }

  String get _postedRelative {
    final raw = _opportunity?['created_at'];
    if (raw == null) return '';
    final date = DateTime.tryParse(raw.toString());
    if (date == null) return '';
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return 'Posted ${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours >= 1) return 'Posted ${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inMinutes >= 1) return 'Posted ${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    return 'Posted just now';
  }

  String get _description {
    for (final key in [
      'short_description',
      'full_description',
      'requirement',
      'opportunity_description'
    ]) {
      final v = _opportunity?[key];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return '';
  }

  List<String> get _complianceMilestones {
    final raw =
        _opportunity?['milestones_array'] ?? _opportunity?['milestones'];
    if (raw is List) {
      return raw
          .map((e) => e.toString().trim())
          .where((m) => m.isNotEmpty)
          .toList();
    }
    if (raw is String && raw.trim().isNotEmpty) {
      return raw
          .split('\n')
          .map((e) => e.trim())
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return const [];
  }

  List<Map<String, String>> get _vettingCriteria {
    final list = <Map<String, String>>[];
    final vintage = _opportunity?['min_vintage']?.toString().trim();
    if (vintage != null && vintage.isNotEmpty) {
      list.add({'title': 'MIN. VINTAGE', 'value': vintage, 'sub': 'Operating history'});
    }
    final turnover = _opportunity?['min_turnover']?.toString().trim();
    if (turnover != null && turnover.isNotEmpty) {
      list.add({'title': 'ANNUAL TURNOVER', 'value': turnover, 'sub': 'Verified Revenue'});
    }
    final geo = _opportunity?['geo_eligibility']?.toString().trim();
    if (geo != null && geo.isNotEmpty) {
      list.add({'title': 'GEO ELIGIBILITY', 'value': geo, 'sub': 'Allowed Region'});
    }
    final score = _opportunity?['min_trust_score']?.toString().trim();
    if (score != null && score.isNotEmpty) {
      list.add({'title': 'TRUST SCORE', 'value': score, 'sub': 'Account Standing'});
    }
    return list;
  }

  List<Map<String, String>> get _repeatableFinancialTerms {
    final terms = <Map<String, String>>[];
    final commFlat = _compensation?['commission_flat']?.toString().trim();
    if (commFlat != null && commFlat.isNotEmpty) {
      terms.add({
        'label': 'Commission (Flat)',
        'amount': commFlat,
        'note': _compensation?['commission_flat_terms']?.toString().trim() ?? ''
      });
    }
    final commPercent = _compensation?['commission_percent']?.toString().trim();
    if (commPercent != null && commPercent.isNotEmpty) {
      terms.add({
        'label': 'Commission (%)',
        'amount': commPercent.endsWith('%') ? commPercent : '$commPercent%',
        'note': _compensation?['commission_percent_terms']?.toString().trim() ?? ''
      });
    }
    return terms;
  }

  @override
  Widget build(BuildContext context) {
    final hasStats = (_totalLikesText != null ||
        _totalViewsText != null ||
        _totalApplications > 0);

    return Scaffold(
      backgroundColor: _OppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Container(
          decoration: BoxDecoration(
            color: _OppColors.background.withOpacity(0.95),
            border: Border(
              bottom: BorderSide(color: _OppColors.secondary.withOpacity(0.15)),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: _OppColors.primary, size: 22),
                  onPressed: () => Navigator.maybePop(context),
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Opportunity Details',
                        style: TextStyle(
                          color: _OppColors.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: -0.2,
                        ),
                      ),
                      if (_rfqNumber.isNotEmpty)
                        Text(
                          _rfqNumber,
                          style: const TextStyle(
                            color: _OppColors.secondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            letterSpacing: 0.5,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: _OppColors.primary,
                    size: 25,
                  ),
                  onPressed: _togglingBookmark ? null : _toggleBookmark,
                ),
              ],
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
          child: CircularProgressIndicator(color: _OppColors.primary))
          : RefreshIndicator(
        color: _OppColors.primary,
        onRefresh: _fetchDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _OppColors.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: _OppColors.onErrorContainer, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                                color: _OppColors.onErrorContainer,
                                fontSize: 13),
                          ),
                        ),
                        TextButton(
                          onPressed: _fetchDetails,
                          child: const Text('Retry',
                              style: TextStyle(
                                  color: _OppColors.onErrorContainer)),
                        ),
                      ],
                    ),
                  ),
                ),
              if (_title.isNotEmpty || _categoryTag.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF002B2F),
                        Color(0xFF004349),
                        Color(0xFF053237),
                      ],
                    ),
                    border: Border(
                      bottom: BorderSide(color: Color(0x33002B2F)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (_categoryTag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.15)),
                              ),
                              child: Text(
                                _categoryTag,
                                style: const TextStyle(
                                  color: _OppColors.primaryFixed,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (_pricingTag.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _OppColors.successMuted,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _pricingTag,
                                style: const TextStyle(
                                  color: _OppColors.primaryContainer,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          if (_labelName.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                    color: Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(
                                _labelName.toUpperCase(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                        ],
                      ),
                      if (_title.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          _title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.4,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (_description.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          _description,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13.5,
                            color: Colors.white.withOpacity(0.85),
                            height: 1.4,
                          ),
                        ),
                      ],
                      if (_companyName.isNotEmpty ||
                          _postedRelative.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.only(top: 12),
                          decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    color: Colors.white.withOpacity(0.15))),
                          ),
                          child: Row(
                            children: [
                              if (_companyInitials.isNotEmpty)
                                Container(
                                  width: 34,
                                  height: 34,
                                  margin:
                                  const EdgeInsets.only(right: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: Colors.white
                                            .withOpacity(0.2)),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    _companyInitials,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    if (_companyName.isNotEmpty)
                                      Row(
                                        children: [
                                          Flexible(
                                            child: Text(
                                              _companyName,
                                              overflow: TextOverflow
                                                  .ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight
                                                    .w600,
                                                fontSize: 13,
                                              ),
                                            ),
                                          ),
                                          if (_isVendorVerified) ...[
                                            const SizedBox(width: 4),
                                            const Icon(Icons.verified,
                                                color: _OppColors
                                                    .primaryFixed,
                                                size: 15),
                                          ],
                                        ],
                                      ),
                                    if (_postedRelative.isNotEmpty)
                                      Text(
                                        _postedRelative,
                                        style: TextStyle(
                                          color: Colors.white
                                              .withOpacity(0.7),
                                          fontSize: 11,
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    if (hasStats) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: _OppColors.secondary
                                  .withOpacity(0.15)),
                        ),
                        child: Row(
                          children: [
                            if (_totalLikesText != null)
                              Expanded(
                                child: _buildMetricItem(
                                    Icons.thumb_up_outlined,
                                    _totalLikesText!,
                                    'LIKES'),
                              ),
                            if (_totalLikesText != null &&
                                _totalViewsText != null)
                              Container(
                                height: 32,
                                width: 1,
                                color: _OppColors.secondary
                                    .withOpacity(0.15),
                              ),
                            if (_totalViewsText != null)
                              Expanded(
                                child: _buildMetricItem(
                                    Icons.visibility_outlined,
                                    _totalViewsText!,
                                    'VIEWS'),
                              ),
                            if (_totalApplications > 0) ...[
                              Container(
                                height: 32,
                                width: 1,
                                color: _OppColors.secondary
                                    .withOpacity(0.15),
                              ),
                              Expanded(
                                child: _buildMetricItem(
                                    Icons.description_outlined,
                                    '$_totalApplications',
                                    'APPLICATIONS'),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_description.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.inventory_2_outlined,
                                        color: _OppColors.primaryContainer,
                                        size: 20),
                                    SizedBox(width: 8),
                                    Text(
                                      'Procurement Scope & Deliverables',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: _OppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                if (_rfqNumber.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _OppColors.surfaceContainerLow,
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _rfqNumber,
                                      style: const TextStyle(
                                        fontFamily: 'monospace',
                                        fontSize: 10.5,
                                        color: _OppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(
                                height: 24,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            Text(
                              _description,
                              style: const TextStyle(
                                fontSize: 13.5,
                                height: 1.5,
                                color: _OppColors.onSurfaceVariant,
                              ),
                            ),
                            if (_complianceMilestones.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: _OppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _OppColors.outlineVariant
                                          .withOpacity(0.5)),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.verified,
                                            color: _OppColors
                                                .primaryContainer,
                                            size: 18),
                                        SizedBox(width: 6),
                                        Text(
                                          'Key Milestones',
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: _OppColors
                                                .primaryContainer,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    ..._complianceMilestones
                                        .map(_buildBulletPoint),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_skills.isNotEmpty || _requiredTier.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'ALLOWED VENDOR TYPES',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _OppColors.secondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Icon(Icons.shield_outlined,
                                    color: _OppColors.primaryContainer,
                                    size: 17),
                              ],
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            if (_skills.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: _skills.map((skill) {
                                  return Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color:
                                      _OppColors.surfaceContainerLow,
                                      borderRadius:
                                      BorderRadius.circular(4),
                                      border: Border.all(
                                          color: _OppColors
                                              .primaryContainer
                                              .withOpacity(0.2)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                            Icons.factory_outlined,
                                            size: 16,
                                            color: _OppColors
                                                .primaryContainer),
                                        const SizedBox(width: 6),
                                        Text(
                                          skill,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: _OppColors.primary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            if (_requiredTier.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _OppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: _OppColors.outlineVariant
                                          .withOpacity(0.6)),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: const [
                                        Icon(Icons.lock_outline,
                                            size: 15,
                                            color: _OppColors
                                                .primaryContainer),
                                        SizedBox(width: 6),
                                        Text(
                                          'REQUIRED MEMBERSHIP TIER',
                                          style: TextStyle(
                                            fontSize: 10.5,
                                            fontWeight: FontWeight.bold,
                                            color: _OppColors.secondary,
                                            letterSpacing: 0.8,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _requiredTier,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.bold,
                                        color: _OppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_certifications.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'MANDATORY CERTIFICATIONS',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _OppColors.secondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Icon(Icons.verified_outlined,
                                    color: _OppColors.primaryContainer,
                                    size: 17),
                              ],
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _certifications
                                  .map((cert) => _CertBadge(label: cert))
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_vettingCriteria.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: const [
                                Text(
                                  'VENDOR VETTING & OPERATIONAL CRITERIA',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: _OppColors.secondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                Icon(Icons.tune,
                                    color: _OppColors.secondary, size: 17),
                              ],
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            GridView.builder(
                              shrinkWrap: true,
                              physics:
                              const NeverScrollableScrollPhysics(),
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                childAspectRatio: 1.6,
                              ),
                              itemCount: _vettingCriteria.length,
                              itemBuilder: (context, index) {
                                final c = _vettingCriteria[index];
                                return _CriteriaTile(
                                  title: c['title'] ?? '',
                                  value: c['value'] ?? '',
                                  sub: c['sub'] ?? '',
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_requiredDocuments.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.folder_open,
                                        color: _OppColors.primaryContainer,
                                        size: 18),
                                    SizedBox(width: 6),
                                    Text(
                                      'REQUIRED & LINKED DOCUMENTS',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: _OppColors.secondary,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_requiredDocuments.length} Documents',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _OppColors.outline),
                                ),
                              ],
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            ..._requiredDocuments.map((doc) {
                              final isReq = (doc['required']
                                  ?.toString()
                                  .toLowerCase() ??
                                  'true') !=
                                  'false';
                              final note = (doc['note'] ??
                                  doc['format'] ??
                                  '')
                                  .toString();
                              return Container(
                                margin: const EdgeInsets.only(bottom: 10),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _OppColors.surfaceContainerLow,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _OppColors.outlineVariant
                                          .withOpacity(0.6)),
                                ),
                                child: Row(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.description_outlined,
                                        color:
                                        _OppColors.primaryContainer,
                                        size: 22),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            (doc['name'] ?? 'Document')
                                                .toString(),
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                              color: _OppColors.onSurface,
                                            ),
                                          ),
                                          if (note.isNotEmpty) ...[
                                            const SizedBox(height: 2),
                                            Text(
                                              note,
                                              style: const TextStyle(
                                                  fontSize: 11.5,
                                                  color:
                                                  _OppColors.outline),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: isReq
                                            ? _OppColors.errorContainer
                                            : _OppColors
                                            .surfaceContainerHigh,
                                        borderRadius:
                                        BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        isReq ? 'REQUIRED' : 'OPTIONAL',
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.bold,
                                          color: isReq
                                              ? _OppColors.onErrorContainer
                                              : _OppColors
                                              .onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_priceAmountText.isNotEmpty ||
                        _repeatableFinancialTerms.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Pricing & Remuneration',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: _OppColors.primary,
                                  ),
                                ),
                                if (_pricingTag.isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _OppColors.successMuted,
                                      borderRadius:
                                      BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      _pricingTag,
                                      style: const TextStyle(
                                        color: _OppColors.primaryContainer,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            if (_priceAmountText.isNotEmpty) ...[
                              const Text(
                                'PRICE / ESTIMATE',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _OppColors.secondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _priceAmountText,
                                style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: _OppColors.primary,
                                ),
                              ),
                            ],
                            if (_repeatableFinancialTerms.isNotEmpty) ...[
                              const SizedBox(height: 14),
                              const Text(
                                'FINANCIAL TERMS',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _OppColors.secondary,
                                  letterSpacing: 0.8,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._repeatableFinancialTerms.map((t) =>
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        bottom: 8.0),
                                    child: _buildTermRow(
                                        t['label']!,
                                        t['amount']!,
                                        t['note']!),
                                  )),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_targetAudience.isNotEmpty ||
                        _locationLine.isNotEmpty ||
                        _moduleMapping.isNotEmpty) ...[
                      _buildSectionCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'COMMERCIAL SCOPE & TARGET',
                              style: TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.bold,
                                color: _OppColors.secondary,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const Divider(
                                height: 20,
                                thickness: 1,
                                color: Color(0x1F4A626D)),
                            if (_targetAudience.isNotEmpty) ...[
                              _buildScopeItem(
                                Icons.groups_outlined,
                                'Target Audience',
                                _targetAudience,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_locationLine.isNotEmpty) ...[
                              _buildScopeItem(
                                Icons.public,
                                'Locations',
                                _locationLine,
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (_moduleMapping.isNotEmpty)
                              _buildScopeItem(
                                Icons.account_tree_outlined,
                                'Module Mapping',
                                _moduleMapping,
                                isMono: true,
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    if (_similarOpportunities.isNotEmpty) ...[
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Similar Opportunities',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: _OppColors.primary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildSimilarSection(),
                      const SizedBox(height: 80),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomSheet: _isLoading
          ? null
          : Container(
        padding:
        const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          border: Border(
              top: BorderSide(
                  color: _OppColors.secondary.withOpacity(0.15))),
          boxShadow: [
            BoxShadow(
              color: _OppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: SafeArea(
          child: Row(
            children: [
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _openActionModal('callback'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _OppColors.surfaceContainerLow,
                    border: Border.all(
                        color: _OppColors.outlineVariant
                            .withOpacity(0.6)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.chat_bubble_outline,
                      size: 20, color: _OppColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: () => _openActionModal('proposal'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor:
                    _OppColors.secondaryContainer.withOpacity(0.6),
                    foregroundColor: _OppColors.primary,
                    side: BorderSide(
                        color: _OppColors.primaryContainer
                            .withOpacity(0.2)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  child: const FittedBox(
                    child: Text('Proposal',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: (_actionType == 'apply' && _alreadyApplied)
                      ? null
                      : () => _openActionModal(_actionType),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _OppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    elevation: 1,
                  ),
                  icon: Icon(
                    (_actionType == 'apply' && _alreadyApplied)
                        ? Icons.check_circle
                        : _actionIcon,
                    size: 18,
                  ),
                  label: FittedBox(
                    child: Text(
                      (_actionType == 'apply' && _alreadyApplied)
                          ? 'Already Applied'
                          : (_priceAmountText.isNotEmpty
                          ? '$_actionLabel ($_priceAmountText)'
                          : _actionLabel),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13.5),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _OppColors.secondary.withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _buildMetricItem(IconData icon, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 17, color: _OppColors.secondary),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: _OppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: _OppColors.onSurfaceVariant,
            letterSpacing: 0.8,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ",
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: _OppColors.onSurface)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                  fontSize: 12.5, color: _OppColors.onSurface, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermRow(String label, String amount, String note) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _OppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _OppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13.5)),
              Text(amount,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: _OppColors.primary)),
            ],
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(note,
                style: const TextStyle(fontSize: 11.5, color: _OppColors.outline)),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeItem(IconData icon, String title, String body,
      {bool isMono = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: _OppColors.primary),
            const SizedBox(width: 6),
            Text(
              title,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                  color: _OppColors.onSurfaceVariant),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: _OppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: _OppColors.outlineVariant.withOpacity(0.4)),
          ),
          child: Text(
            body,
            style: TextStyle(
              fontSize: isMono ? 12 : 13,
              fontWeight: FontWeight.bold,
              color: _OppColors.onSurface,
              fontFamily: isMono ? 'monospace' : null,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSimilarSection() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarOpportunities.length,
        itemBuilder: (context, index) {
          final item = _similarOpportunities[index];
          final title = (item['title'] ?? '').toString();
          final industry = (item['industry'] ?? item['type'] ?? '').toString();
          final likes = item['likes'] ?? item['total_likes'];
          final views = item['views'] ?? item['total_views'];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OpportunityDetailsScreen(
                      opportunityId: item['id']),
                ),
              );
            },
            child: Container(
              width: 220,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: _OppColors.secondary.withOpacity(0.15)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 70,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: _OppColors.surfaceContainerLow,
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(8)),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.business_center_outlined,
                        color: _OppColors.secondary, size: 28),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (industry.isNotEmpty)
                          Text(
                            industry.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.bold,
                              color: _OppColors.secondary,
                              fontFamily: 'monospace',
                            ),
                          ),
                        const SizedBox(height: 2),
                        Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            if (likes != null) ...[
                              const Icon(Icons.thumb_up_outlined,
                                  size: 13, color: _OppColors.outline),
                              const SizedBox(width: 3),
                              Text('$likes',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _OppColors.outline)),
                              const SizedBox(width: 10),
                            ],
                            if (views != null) ...[
                              const Icon(Icons.visibility_outlined,
                                  size: 13, color: _OppColors.outline),
                              const SizedBox(width: 3),
                              Text('$views',
                                  style: const TextStyle(
                                      fontSize: 11,
                                      color: _OppColors.outline)),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CertBadge extends StatelessWidget {
  final String label;
  const _CertBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _OppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _OppColors.outlineVariant.withOpacity(0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_outline,
              color: _OppColors.primaryContainer, size: 16),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: _OppColors.primary),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _CriteriaTile extends StatelessWidget {
  final String title;
  final String value;
  final String sub;
  const _CriteriaTile(
      {required this.title, required this.value, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: _OppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _OppColors.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: _OppColors.outline,
                fontFamily: 'monospace'),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: _OppColors.primary),
          ),
          if (sub.isNotEmpty)
            Text(
              sub,
              style: const TextStyle(
                  fontSize: 10.5, color: _OppColors.onSurfaceVariant),
            ),
        ],
      ),
    );
  }
}