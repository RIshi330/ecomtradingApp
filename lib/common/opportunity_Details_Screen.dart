import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

// ============================================================================
// SHARED DESIGN TOKENS (ported from the Tailwind config in the HTML mockups)
// ============================================================================
class _OppColors {
  static const primary = Color(0xFF002B2F);
  static const primaryContainer = Color(0xFF004349);
  static const primaryFixedDim = Color(0xFF9AD0D7);
  static const onPrimaryContainer = Color(0xFF90D2DA);
  static const secondary = Color(0xFF4A626D);
  static const surface = Color(0xFFF8F9F9);
  static const surfaceContainerLowest = Colors.white;
  static const surfaceContainer = Color(0xFFEDEEEE);
  static const surfaceContainerLow = Color(0xFFF3F4F4);
  static const outlineVariant = Color(0xFFBFC8C9);
  static const outline = Color(0xFF70797A);
  static const error = Color(0xFFBA1A1A);
  static const onSurface = Color(0xFF191C1C);
  static const onSurfaceVariant = Color(0xFF404849);
}

// ============================================================================
// API SERVICE
//
// Every action modal below posts to the SAME endpoint the screen already
// uses to load data (`new_apis/opportunity_details_api.php`), because the
// PHP file you shared handles `get_opportunity_details` AND every action
// (apply / contact / register / enroll / donate / proposal / callback /
// appointment) inside that one file. No new endpoint needed.
//
// NOTE on field mapping (please double-check against your schema):
// The PHP action blocks read `item_id`, `marketplace_id` and `request_id`
// as plain ints (bind_param "i"), but `get_opportunity_details` reads/writes
// opportunity ids through `encryptor()/decryptor()`. Since this screen only
// has a single `opportunityId`, I'm sending it as all three
// (item_id / marketplace_id / request_id) so whichever column your schema
// actually keys off of gets populated — but you should confirm which one(s)
// are correct for your tables and trim the others if they're not needed.
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

  static const String _endpoint = '/new_apis/opportunity_details_api.php';
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
  int get _vendorId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

  Map<String, dynamic> _opportunityRefs(dynamic opportunityId) => {
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
    String attachment = '',
  }) async {
    final res = await _call({
      'action': 'apply',
      ..._opportunityRefs(opportunityId),
      'name': name,
      'email': email,
      'phone': phone,
      'message': message,
      'attachment': attachment,
      'vendor_id': _vendorId,

    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> appointment({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String date,
    required String time,
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
      'notes': notes,
      'attachment': attachment,
      'vendor_id': _vendorId,

    });
    return res['data']?['id'] as int? ?? 0;
  }

  Future<int> callback({
    required dynamic opportunityId,
    required String name,
    required String email,
    required String phone,
    required String preferredTime,
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
      'notes': notes,
      'attachment': attachment,
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
      'anonymous': anonymous,
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
      'notes': notes,
      'attachment': attachment,
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
      'price': price,
      'terms': terms,
      'notes': notes,
      'attachment': attachment,
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
      'notes': notes,
      'attachment': attachment,
      'vendor_id': _vendorId,

    });
    return res['data']?['id'] as int? ?? 0;
  }
}

// ============================================================================
// SHARED MODAL BUILDING BLOCKS
// ============================================================================

/// Header bar reused by every action sheet (matches the HTML "Modal Header").
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
            bottom: BorderSide(color: _OppColors.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: _OppColors.onSurface)),
          IconButton(
            icon: const Icon(Icons.close, color: _OppColors.onSurfaceVariant),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

/// Cancel + Submit footer reused by every action sheet.
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
            top: BorderSide(color: _OppColors.outlineVariant.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: submitting ? null : onCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: _OppColors.primary,
                side: BorderSide(color: _OppColors.primary.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              ),
              child: submitting
                  ? const SizedBox(
                width: 16,
                height: 16,
                child:
                CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
                  : Text(submitLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
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
    child: Text(text,
        style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: _OppColors.secondary)),
  );
}

InputDecoration _fieldDecoration(String hint) => InputDecoration(
  hintText: hint,
  filled: true,
  fillColor: _OppColors.surfaceContainerLow,
  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: _OppColors.secondary.withOpacity(0.3)),
  ),
  enabledBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: BorderSide(color: _OppColors.secondary.withOpacity(0.3)),
  ),
  focusedBorder: OutlineInputBorder(
    borderRadius: BorderRadius.circular(6),
    borderSide: const BorderSide(color: _OppColors.primary, width: 2),
  ),
);

/// Name / Email / Phone block. The PHP action blocks all read these three
/// fields (`$input['name']`, `$input['email']`, `$input['phone']`) even
/// though most HTML mockups didn't render them (they were commented out —
/// presumably meant to auto-fill from a logged-in profile). Since this
/// codebase doesn't expose a profile-fetch API here, they're collected
/// explicitly so every submission actually carries this data.
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
        TextField(controller: nameCtrl, decoration: _fieldDecoration('Enter your name')),
        const SizedBox(height: 14),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModalLabel('EMAIL'),
                  TextField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _fieldDecoration('email@example.com'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _ModalLabel('PHONE'),
                  TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: _fieldDecoration('+1...'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
      ],
    );
  }
}

/// Shared "Response Submitted!" confirmation (ported from the Success Modal
/// HTML mockup). Shown after any action submits successfully.
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
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: _OppColors.primaryFixedDim.withOpacity(0.25),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded,
                  color: _OppColors.primary, size: 44),
            ),
            const SizedBox(height: 20),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: _OppColors.primary)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: _OppColors.onSurfaceVariant)),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _OppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('BACK TO OPPORTUNITY',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ============================================================================
// 1) APPLY  ->  action=apply
// ============================================================================
class ApplyModal extends StatefulWidget {
  final dynamic opportunityId;
  final String opportunityTitle;
  const ApplyModal({super.key, required this.opportunityId, required this.opportunityTitle});

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

  static const _savedCvs = ['CV_Jane_Doe_2023.pdf', 'Resume_Lead_Logistics.pdf'];
  String? _selectedCv = _savedCvs.first;

  bool _submitting = false;
  String? _error;

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
      await _api.apply(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        message: _statementCtrl.text.trim(),
        attachment: _newCvCtrl.text.trim().isNotEmpty ? _newCvCtrl.text.trim() : (_selectedCv ?? ''),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Application Submitted!',
        message: 'Your application has been sent. The vendor will review it and get back to you.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Apply for Opportunity', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _OppColors.surfaceContainer,
                        border: Border(left: BorderSide(color: _OppColors.primary, width: 4)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text.rich(
                        TextSpan(
                          style: const TextStyle(fontSize: 12, color: _OppColors.onSurfaceVariant),
                          children: [
                            const TextSpan(text: 'Applying for: '),
                            TextSpan(
                              text: widget.opportunityTitle,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const TextSpan(text: '. Ensure all details are accurate before submission.'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('STATEMENT OF INTEREST'),
                    TextField(
                      controller: _statementCtrl,
                      maxLines: 4,
                      decoration: _fieldDecoration('Briefly explain your suitability...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('SELECT FROM UPLOADED CVS'),
                    ..._savedCvs.map((cv) => RadioListTile<String>(
                      value: cv,
                      groupValue: _selectedCv,
                      onChanged: (v) => setState(() => _selectedCv = v),
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _OppColors.primary,
                      title: Text(cv, style: const TextStyle(fontSize: 13)),
                    )),
                    const SizedBox(height: 8),
                    const _ModalLabel('OR PASTE A NEW ATTACHMENT URL / FILENAME'),
                    TextField(
                      controller: _newCvCtrl,
                      decoration: _fieldDecoration('e.g. https://... or resume.pdf'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
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

// ============================================================================
// 2) APPOINTMENT  ->  action=appointment
// ============================================================================
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

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  static const _slots = ['09:00 AM', '10:30 AM', '01:00 PM', '02:30 PM'];
  String _selectedSlot = '10:30 AM';
  String _purpose = 'vendor';

  bool _submitting = false;
  String? _error;

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
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final dateStr =
          '${_selectedDate.year.toString().padLeft(4, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      final notes = 'Purpose: $_purpose\n${_notesCtrl.text.trim()}';
      await _api.appointment(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        date: dateStr,
        time: _selectedSlot,
        notes: notes,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Appointment Requested!',
        message: 'Your appointment for $dateStr at $_selectedSlot has been requested.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Schedule Appointment', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('SELECT DATE'),
                    InkWell(
                      onTap: _pickDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: _OppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _OppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: _OppColors.primary),
                            const SizedBox(width: 8),
                            Text(
                              '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('AVAILABLE TIMES'),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _slots.map((slot) {
                        final selected = slot == _selectedSlot;
                        return ChoiceChip(
                          label: Text(slot, style: const TextStyle(fontSize: 12)),
                          selected: selected,
                          selectedColor: _OppColors.primaryContainer.withOpacity(0.12),
                          labelStyle: TextStyle(
                              color: selected ? _OppColors.primary : _OppColors.onSurfaceVariant,
                              fontWeight: selected ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                                color: selected ? _OppColors.primary : _OppColors.outlineVariant),
                          ),
                          onSelected: (_) => setState(() => _selectedSlot = slot),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('PURPOSE OF MEETING'),
                    DropdownButtonFormField<String>(
                      value: _purpose,
                      decoration: _fieldDecoration('Select purpose'),
                      items: const [
                        DropdownMenuItem(value: 'vendor', child: Text('Vendor Review')),
                        DropdownMenuItem(value: 'contract', child: Text('Contract Negotiation')),
                        DropdownMenuItem(value: 'supply', child: Text('Supply Chain Audit')),
                        DropdownMenuItem(value: 'other', child: Text('Other Inquiry')),
                      ],
                      onChanged: (v) => setState(() => _purpose = v ?? 'vendor'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ADDITIONAL NOTES'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: _fieldDecoration('Any specific requirements for this meeting?'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
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

// ============================================================================
// 3) CALLBACK  ->  action=callback
// ============================================================================
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

  String _subject = 'procurement';
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
      final notes = 'Subject: $_subject\n${_notesCtrl.text.trim()}';
      await _api.callback(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        preferredTime: _preferredTime,
        notes: notes,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Callback Requested!',
        message: 'We\'ll call you back during your preferred $_preferredTime slot.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Request a Callback', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModalLabel('SUBJECT OF INQUIRY'),
                    DropdownButtonFormField<String>(
                      value: _subject,
                      decoration: _fieldDecoration('Select a subject'),
                      items: const [
                        DropdownMenuItem(value: 'procurement', child: Text('Procurement & Sourcing')),
                        DropdownMenuItem(value: 'logistics', child: Text('Logistics Planning')),
                        DropdownMenuItem(value: 'billing', child: Text('Billing & Invoicing')),
                        DropdownMenuItem(value: 'support', child: Text('Technical Support')),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _subject = v ?? 'procurement'),
                    ),
                    const SizedBox(height: 16),
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('PREFERRED CALLBACK TIME'),
                    Row(
                      children: ['morning', 'afternoon', 'evening'].map((t) {
                        final selected = t == _preferredTime;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => setState(() => _preferredTime = t),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? _OppColors.primaryContainer.withOpacity(0.1)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                      color: selected
                                          ? _OppColors.primary
                                          : _OppColors.outlineVariant.withOpacity(0.5)),
                                ),
                                child: Text(
                                  t[0].toUpperCase() + t.substring(1),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: selected ? _OppColors.primary : _OppColors.onSurfaceVariant),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('BRIEF NOTE'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: _fieldDecoration('Provide any additional context...'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'REQUEST CALLBACK',
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
// 4) DONATE  ->  action=donate
// ============================================================================
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

  static const _quickAmounts = [10.0, 25.0, 50.0, 100.0];
  double? _selectedAmount = 50.0;
  bool _anonymous = false;

  bool _submitting = false;
  String? _error;

  double? get _amount {
    if (_customAmountCtrl.text.trim().isNotEmpty) {
      return double.tryParse(_customAmountCtrl.text.trim());
    }
    return _selectedAmount;
  }

  Future<void> _submit() async {
    final amount = _amount;
    if (amount == null || amount <= 0) {
      setState(() => _error = 'Please choose or enter a valid amount.');
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
        anonymous: _anonymous,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Thank You for Donating!',
        message: 'Your contribution of \$${amount.toStringAsFixed(2)} has been recorded.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 680),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Donate to Support', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _ModalLabel('AMOUNT'),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.6,
                      children: _quickAmounts.map((amt) {
                        final selected = amt == _selectedAmount && _customAmountCtrl.text.isEmpty;
                        return InkWell(
                          onTap: () => setState(() {
                            _selectedAmount = amt;
                            _customAmountCtrl.clear();
                          }),
                          child: Container(
                            decoration: BoxDecoration(
                              color: selected
                                  ? _OppColors.primaryContainer.withOpacity(0.1)
                                  : Colors.transparent,
                              border: Border.all(
                                  color:
                                  selected ? _OppColors.primary : _OppColors.outlineVariant.withOpacity(0.5)),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            alignment: Alignment.center,
                            child: Text('\$${amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: selected ? _OppColors.primary : _OppColors.onSurfaceVariant)),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customAmountCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration('Other amount').copyWith(prefixText: '\$ '),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 16),
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    CheckboxListTile(
                      value: _anonymous,
                      onChanged: (v) => setState(() => _anonymous = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _OppColors.primary,
                      title: const Text('Donate anonymously', style: TextStyle(fontSize: 13)),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
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

// ============================================================================
// 5) ENROLL  ->  action=enroll
// ============================================================================
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

  DateTime? _birthDate;
  String _program = 'p1';
  bool _agreedToTerms = false;

  bool _submitting = false;
  String? _error;

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1930),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _birthDate = picked);
  }

  static const _programLabels = {
    'p1': 'Procurement Fundamentals',
    'p2': 'Advanced Logistics Planning',
    'p3': 'Vendor Management Intensive',
  };

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Participant name and email are required.');
      return;
    }
    if (!_agreedToTerms) {
      setState(() => _error = 'Please agree to the Terms & Conditions to continue.');
      return;
    }
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final birth = _birthDate == null
          ? ''
          : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
      final notes = 'Birth Date: $birth\n'
          'Emergency Contact: ${_emergencyNameCtrl.text.trim()} (${_emergencyPhoneCtrl.text.trim()})';
      await _api.enroll(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        batch: _programLabels[_program] ?? _program,
        notes: notes,
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Enrollment Confirmed!',
        message: 'You\'re enrolled in ${_programLabels[_program]}. A confirmation email is on its way.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Program Enrollment', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('BIRTH DATE'),
                    InkWell(
                      onTap: _pickBirthDate,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: _OppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: _OppColors.secondary.withOpacity(0.3)),
                        ),
                        child: Text(
                          _birthDate == null
                              ? 'Select birth date'
                              : '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('PROGRAM SELECTION'),
                    DropdownButtonFormField<String>(
                      value: _program,
                      decoration: _fieldDecoration('Select a program'),
                      items: _programLabels.entries
                          .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                          .toList(),
                      onChanged: (v) => setState(() => _program = v ?? 'p1'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('EMERGENCY CONTACT'),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _OppColors.surfaceContainerLow,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: _OppColors.outlineVariant.withOpacity(0.5)),
                      ),
                      child: Column(
                        children: [
                          TextField(
                              controller: _emergencyNameCtrl,
                              decoration: _fieldDecoration('Contact Name')),
                          const SizedBox(height: 8),
                          TextField(
                              controller: _emergencyPhoneCtrl,
                              keyboardType: TextInputType.phone,
                              decoration: _fieldDecoration('Phone Number')),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      value: _agreedToTerms,
                      onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
                      controlAffinity: ListTileControlAffinity.leading,
                      contentPadding: EdgeInsets.zero,
                      activeColor: _OppColors.primary,
                      title: const Text(
                        'I agree to the Terms & Conditions and privacy policy regarding my enrollment data.',
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 8),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
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

// ============================================================================
// 6) PROPOSAL  ->  action=proposal
// ============================================================================
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
  final _summaryCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();
  final _attachmentCtrl = TextEditingController();

  String _type = 'Partnership';

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
        type: _type,
        price: budget,
        terms: _titleCtrl.text.trim(),
        notes: _summaryCtrl.text.trim(),
        attachment: _attachmentCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Proposal Submitted!',
        message: 'Your proposal "${_titleCtrl.text.trim()}" has been sent for review.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Submit Proposal', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('PROPOSAL TYPE'),
                    DropdownButtonFormField<String>(
                      value: _type,
                      decoration: _fieldDecoration('Select type'),
                      items: const [
                        DropdownMenuItem(value: 'Partnership', child: Text('Partnership')),
                        DropdownMenuItem(value: 'Sponsorship', child: Text('Sponsorship')),
                        DropdownMenuItem(value: 'Vendor Bid', child: Text('Vendor Bid')),
                      ],
                      onChanged: (v) => setState(() => _type = v ?? 'Partnership'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('PROPOSAL TITLE'),
                    TextField(
                      controller: _titleCtrl,
                      decoration: _fieldDecoration('e.g., Q3 Procurement Optimization'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('EXECUTIVE SUMMARY'),
                    TextField(
                      controller: _summaryCtrl,
                      maxLines: 4,
                      decoration: _fieldDecoration('Brief overview of objectives and scope...'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('ESTIMATED BUDGET (USD)'),
                    TextField(
                      controller: _budgetCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _fieldDecoration('0.00').copyWith(prefixText: '\$ '),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('FULL PROPOSAL DOCUMENT (URL / FILENAME)'),
                    TextField(
                      controller: _attachmentCtrl,
                      decoration: _fieldDecoration('e.g. https://... or proposal.pdf'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'SUBMIT RECORD',
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
// 7) REGISTER  ->  action=register
//
// No HTML mockup was provided for this one, so this follows the same
// shape/fields as the PHP `register` block: name, email, phone, ticket, notes.
// ============================================================================
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

  String _ticket = 'General - 499';

  bool _submitting = false;
  String? _error;

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
      await _api.register(
        opportunityId: widget.opportunityId,
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        ticket: _ticket,
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.pop(context);
      await showOpportunityActionSuccess(
        context,
        title: 'Registration Complete!',
        message: 'You\'re registered with the "$_ticket" ticket. Details will be emailed shortly.',
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
        constraints: const BoxConstraints(maxWidth: 460, maxHeight: 640),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ModalHeader(title: 'Event Registration', onClose: () => Navigator.pop(context)),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ContactFields(nameCtrl: _nameCtrl, emailCtrl: _emailCtrl, phoneCtrl: _phoneCtrl),
                    const _ModalLabel('TICKET TYPE'),
                    DropdownButtonFormField<String>(
                      value: _ticket,
                      decoration: _fieldDecoration('Select ticket'),
                      items: const [
                        DropdownMenuItem(value: 'General - 499', child: Text('General — ₹499')),
                        DropdownMenuItem(value: 'VIP - 999', child: Text('VIP — ₹999')),
                      ],
                      onChanged: (v) => setState(() => _ticket = v ?? 'General - 499'),
                    ),
                    const SizedBox(height: 16),
                    const _ModalLabel('NOTES'),
                    TextField(
                      controller: _notesCtrl,
                      maxLines: 3,
                      decoration: _fieldDecoration('Anything the organizers should know?'),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: _OppColors.error, fontSize: 12)),
                    ],
                  ],
                ),
              ),
            ),
            _ModalFooter(
              submitting: _submitting,
              submitLabel: 'REGISTER',
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
  static const String _endpoint = '/new_apis/opportunity_details_api.php';
  int get _vendorId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

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

  static const Map<int, String> _labelMap = {
    1: 'Featured',
    2: 'Sponsored',
    3: 'Premium',
  };

  // The single action this specific opportunity supports (apply /
  // appointment / callback / donate / enroll / proposal / register).
  //
  // NOTE: `get_opportunity_details` in the PHP you shared doesn't return an
  // explicit "which action applies" field, so this checks a few plausible
  // column names (`action_type`, `response_type`, `opportunity_type`,
  // `cta_type`) and falls back to `apply` if none are present. If your
  // `marketplace_opportunity` table uses a different column name for this,
  // just point this getter at that key.
  static const _knownActions = {
    'apply', 'appointment', 'callback', 'donate', 'enroll', 'proposal', 'register',
  };

  String get _actionType {
    for (final key in ['action_type', 'response_type', 'opportunity_type', 'cta_type']) {
      final raw = _opportunity?[key]?.toString().trim().toLowerCase();
      if (raw != null && raw.isNotEmpty && _knownActions.contains(raw)) {
        return raw;
      }
    }
    return 'apply';
  }

  static const Map<String, String> _actionLabels = {
    'apply': 'Apply Now',
    'appointment': 'Schedule Appointment',
    'callback': 'Request Callback',
    'donate': 'Donate Now',
    'enroll': 'Enroll Now',
    'proposal': 'Submit Proposal',
    'register': 'Register Now',
  };

  static const Map<String, IconData> _actionIcons = {
    'apply': Icons.edit_note,
    'appointment': Icons.event,
    'callback': Icons.call,
    'donate': Icons.volunteer_activism,
    'enroll': Icons.how_to_reg,
    'proposal': Icons.description_outlined,
    'register': Icons.confirmation_number_outlined,
  };

  String get _actionLabel => _actionLabels[_actionType] ?? 'Apply Now';
  IconData get _actionIcon => _actionIcons[_actionType] ?? Icons.edit_note;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    if (widget.opportunityId == null) {
      setState(() {
        _isLoading = false;
        _error = "No opportunity was specified to load.";
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      print(widget.opportunityId);
    });

    try {
      final response = await Database().getData({
        'action': 'get_opportunity_details',
        'opportunity_id': widget.opportunityId,
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response == null || response['success'] != true || response['data'] == null) {
        throw Exception(response?['message'] ?? 'Failed to load opportunity');
      }

      final data = Map<String, dynamic>.from(response['data']);

      if (!mounted) return;
      setState(() {
        _opportunity = data['opportunity'] != null
            ? Map<String, dynamic>.from(data['opportunity'])
            : null;
        _vendor = data['vendor'] != null
            ? Map<String, dynamic>.from(data['vendor'])
            : null;
        _compensation = data['compensation'] != null
            ? Map<String, dynamic>.from(data['compensation'])
            : null;
        _application = data['application'] != null
            ? Map<String, dynamic>.from(data['application'])
            : null;
        _media = data['media'] != null
            ? Map<String, dynamic>.from(data['media'])
            : null;
        _isLoading = false;
      });

      unawaited(_fetchStats());
      unawaited(_fetchSimilarOpportunities());
    } catch (e) {
      debugPrint("Error fetching opportunity details: $e");
      if (mounted) {
        setState(() {
          _error = "Couldn't load this opportunity. Pull down to retry.";
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
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null && response['success'] == true && response['data'] != null) {
        if (!mounted) return;
        setState(() {
          _stats = Map<String, dynamic>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint("Error fetching opportunity stats: $e");
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
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null && response['success'] == true && response['data'] != null) {
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
      debugPrint("Error fetching similar opportunities: $e");
      if (mounted) setState(() => _similarLoaded = true);
    } finally {
      if (mounted) setState(() => _similarLoading = false);
    }
  }

  /// Dispatches to the right form modal for a given action, then refreshes
  /// the screen (application counts / status) once it succeeds.
  Future<void> _openActionModal(String action) async {
    if (widget.opportunityId == null) return;

    switch (action) {
      case 'apply':
        await showDialog(
          context: context,
          builder: (_) => ApplyModal(opportunityId: widget.opportunityId, opportunityTitle: _title),
        );
        break;
      case 'appointment':
        await showDialog(
          context: context,
          builder: (_) => AppointmentModal(opportunityId: widget.opportunityId),
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
    // Refresh so total_applications / application_status reflect the new
    // submission (see notes below about a backend table mismatch for `apply`).
    if (mounted) _fetchDetails();
  }

  String get _title => (_opportunity?['title'] ?? '').toString().isNotEmpty
      ? _opportunity!['title'].toString()
      : 'Untitled Opportunity';

  String get _categoryTag =>
      (_opportunity?['category_title'] ?? '').toString().isNotEmpty
          ? _opportunity!['category_title'].toString().toUpperCase()
          : 'GENERAL';

  String get _pricingTag =>
      (_opportunity?['pricing_type'] ?? '').toString().isNotEmpty
          ? _opportunity!['pricing_type'].toString().toUpperCase()
          : 'PAID';

  String get _labelName => (_opportunity?['label_name'] ?? '').toString();

  bool get _isPremium => _labelName.toLowerCase() == 'premium';

  String get _companyName {
    final company = (_vendor?['company_name'] ?? '').toString();
    if (company.isNotEmpty) return company;
    final name = (_vendor?['name'] ?? '').toString();
    return name.isNotEmpty ? name : 'Unknown vendor';
  }

  String get _coverImage {
    final url = (_media?['cover_image'] ?? '').toString();
    if (url.isNotEmpty) return url;
    return 'https://lh3.googleusercontent.com/aida/AEtjO1WR5-fzolRmc9sLTrPZRkcPFlkrV15WuzzUYpFGLHidFGIBlIRpASAywRyqAe9k_35pWP5x0dEX_QI7zPS4EqfKzB1vZ9oZNtUGm2Rh_UGlwgVdikzR6ABJDcNJjMfTaZzUijMCO_e-QUo5GE6N--v3ThfPj2BXqTY4GdlZUNny0AmwOw1_XXl90ezLoEgSMlDWvCT0cfexV5HEmPemFkkdb7h5AwBjlc1PUTkJIxXz9UrpsrrscuDPmbqV';
  }

  int get _totalApplications =>
      int.tryParse('${_opportunity?['total_applications'] ?? 0}') ?? 0;

  String get _totalViewsText {
    final raw = _stats?['total_views'];
    if (raw == null) return _statsLoading ? '…' : '—';
    final parsed = int.tryParse('$raw');
    return parsed != null ? '$parsed' : '—';
  }

  bool get _alreadyApplied =>
      (_opportunity?['application_status'] ?? '').toString() == 'applied';

  List<String> get _skills {
    final raw = _opportunity?['skills_array'];
    if (raw is List) return raw.map((e) => e.toString()).toList();
    return const [];
  }

  String get _locationLine {
    final parts = [
      (_vendor?['city'] ?? '').toString(),
      (_vendor?['state'] ?? '').toString(),
      (_vendor?['country'] ?? '').toString(),
    ].where((p) => p.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : 'Remote';
  }

  String get _priceAmountText {
    final raw = _opportunity?['price_amount'];
    if (raw == null) return '';
    final amount = num.tryParse(raw.toString());
    if (amount == null) return '';
    return '\$${_formatAmount(amount)}';
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
    if (diff.inDays >= 1) return '${diff.inDays} day${diff.inDays == 1 ? '' : 's'} ago';
    if (diff.inHours >= 1) return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} min${diff.inMinutes == 1 ? '' : 's'} ago';
    return 'Just now';
  }

  String get _description {
    for (final key in ['short_description', 'full_description', 'requirement', 'opportunity_description']) {
      final v = _opportunity?[key];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString();
    }
    return 'No description has been added for this opportunity yet.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9F9).withOpacity(0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF404849)),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Details',
          style: TextStyle(
            color: Color(0xFF002B2F),
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF404849)),
            onPressed: () {},
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: const Color(0xFF4A626D).withOpacity(0.15),
            height: 1.0,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF002B2F)))
          : RefreshIndicator(
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
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3F3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 18),
                        const SizedBox(width: 8),
                        Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 13))),
                        TextButton(onPressed: _fetchDetails, child: const Text("Retry")),
                      ],
                    ),
                  ),
                ),

              // Hero Banner Section
              Stack(
                children: [
                  Image.network(
                    _coverImage,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      color: const Color(0xFF004349),
                    ),
                  ),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF002B2F).withOpacity(0.4),
                          const Color(0xFF002B2F).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildTag(
                              _categoryTag,
                              backgroundColor: const Color(0xFF004349),
                              textColor: const Color(0xFF90D2DA),
                            ),
                            _buildTag(
                              _pricingTag,
                              backgroundColor: const Color(0xFFE8F5E9),
                              textColor: const Color(0xFF002B2F),
                            ),
                            if (_labelName.isNotEmpty)
                              _buildTag(
                                '★ ${_labelName.toUpperCase()}',
                                backgroundColor: const Color(0xFF002B2F),
                                textColor: Colors.white,
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.domain, color: Colors.white70, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              _companyName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                            if (_postedRelative.isNotEmpty)
                              Text(
                                ' • $_postedRelative',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: const Color(0xFF4A626D).withOpacity(0.15)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.thumb_up_outlined, '—', 'LIKES'),
                          Container(
                              height: 30,
                              width: 1,
                              color: const Color(0xFF4A626D).withOpacity(0.15)),
                          _buildStatItem(
                              Icons.visibility_outlined, _totalViewsText, 'VIEWS'),
                          Container(
                              height: 30,
                              width: 1,
                              color: const Color(0xFF4A626D).withOpacity(0.15)),
                          _buildStatItem(Icons.description_outlined,
                              '$_totalApplications', 'APPLICATIONS'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Solution Details
                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.info_outline, color: Color(0xFF4A626D)),
                              SizedBox(width: 8),
                              Text(
                                'Solution Details',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF002B2F),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _description,
                            style: const TextStyle(
                                color: Color(0xFF404849), height: 1.4, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_skills.isNotEmpty)
                      _buildCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'WHO CAN APPLY?',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF4A626D),
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _skills.map(_buildChip).toList(),
                            ),
                          ],
                        ),
                      ),
                    if (_skills.isNotEmpty) const SizedBox(height: 16),

                    _buildCard(
                      backgroundColor: const Color(0xFF002B2F).withOpacity(0.03),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'REQUIRED DOCUMENTS',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A626D),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildDocItem('Business License', 'Required',
                              'PDF format only', Icons.description_outlined),
                          _buildDocItem('Project Proposal', 'Required',
                              'PDF or Word allowed', Icons.article_outlined),
                          _buildDocItem('Team Portfolio', 'Optional',
                              'Link or PDF', Icons.folder_shared_outlined,
                              isRequired: false),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isPremium) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF004349),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.workspace_premium,
                                    color: Color(0xFF90D2DA), size: 32),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Premium Opportunity',
                                        style: TextStyle(
                                          color: Color(0xFF90D2DA),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'This high-value project requires a premium membership or a one-time application fee.',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text('Application Fee',
                                          style: TextStyle(
                                              color: Colors.white, fontSize: 13)),
                                      Text(
                                        _priceAmountText.isNotEmpty
                                            ? _priceAmountText
                                            : '\$49.00',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: () => _openActionModal('apply'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF90D2DA),
                                        foregroundColor: const Color(0xFF004349),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                      child: const Text('Pay to Apply',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Or get unlimited access to all premium opportunities.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF90D2DA),
                                  side: const BorderSide(color: Color(0xFF90D2DA)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text('Upgrade Membership'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pricing & Terms',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF002B2F),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text('PRICING MODEL',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A626D))),
                          const SizedBox(height: 2),
                          Text(
                            _pricingTag.isNotEmpty
                                ? '${_pricingTag[0]}${_pricingTag.substring(1).toLowerCase()}'
                                : 'Paid',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          if (_priceAmountText.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF002B2F).withOpacity(0.05),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(_priceAmountText,
                                  style: const TextStyle(
                                      color: Color(0xFF002B2F),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12)),
                            ),
                          ],
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(),
                          ),
                          const Text('FINANCIAL TERMS',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF4A626D))),
                          const SizedBox(height: 8),
                          _buildProgressTerm('30% Upfront', 0.3, const Color(0xFF002B2F)),
                          const SizedBox(height: 8),
                          _buildProgressTerm('70% Milestone', 0.7, const Color(0xFF9AD0D7)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'TARGET & LOCATION',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF4A626D),
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: const [
                              Icon(Icons.track_changes, size: 16, color: Color(0xFF404849)),
                              SizedBox(width: 6),
                              Text('Audience: ', style: TextStyle(color: Color(0xFF404849))),
                              Text('Retailers, B2B', style: TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 16, color: Color(0xFF404849)),
                              const SizedBox(width: 6),
                              const Text('Locations: ', style: TextStyle(color: Color(0xFF404849))),
                              Text(_locationLine, style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Similar Opportunities',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF002B2F),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSimilarOpportunitiesSection(),
                    const SizedBox(height: 80),
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9F9),
          border: Border(
            top: BorderSide(color: const Color(0xFF4A626D).withOpacity(0.15)),
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0D5C63).withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            )
          ],
        ),
        child: Row(
          children: [
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: BorderSide(color: const Color(0xFF002B2F).withOpacity(0.2)),
              ),
              child: const Icon(Icons.bookmark_border, color: Color(0xFF002B2F)),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(12),
                minimumSize: Size.zero,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                side: BorderSide(color: const Color(0xFF002B2F).withOpacity(0.2)),
              ),
              child: const Icon(Icons.share, color: Color(0xFF002B2F)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                // Dynamic: this opens whichever action this opportunity
                // actually needs (apply/appointment/callback/donate/enroll/
                // proposal/register) based on _actionType, instead of a
                // fixed "Apply" button.
                onPressed: (_actionType == 'apply' && _alreadyApplied)
                    ? null
                    : () => _openActionModal(_actionType),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF002B2F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 2,
                ),
                icon: Icon(
                  (_actionType == 'apply' && _alreadyApplied) ? Icons.check_circle : _actionIcon,
                  size: 18,
                ),
                label: Text(
                  (_actionType == 'apply' && _alreadyApplied) ? 'Already Applied' : _actionLabel,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _buildTag(String label,
      {required Color backgroundColor, required Color textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF4A626D), size: 20),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF002B2F))),
        Text(label,
            style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: Color(0xFF404849))),
      ],
    );
  }

  Widget _buildCard({required Widget child, Color backgroundColor = Colors.white}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
      ),
      child: child,
    );
  }

  Widget _buildChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFBFC8C9)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF404849)),
      ),
    );
  }

  Widget _buildDocItem(
      String title, String badgeText, String subtext, IconData icon,
      {bool isRequired = true}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF002B2F), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isRequired
                            ? const Color(0xFFFFDAD6)
                            : const Color(0xFFE6E8E8),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badgeText.toUpperCase(),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isRequired
                              ? const Color(0xFF93000A)
                              : const Color(0xFF404849),
                        ),
                      ),
                    ),
                  ],
                ),
                Text(subtext,
                    style: const TextStyle(color: Color(0xFF70797A), fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTerm(String label, double value, Color color) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: const Color(0xFFEDEEEE),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildSimilarOpportunitiesSection() {
    if (_similarLoading && !_similarLoaded) {
      return const SizedBox(
        height: 140,
        child: Center(
          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF002B2F)),
        ),
      );
    }

    if (_similarLoaded && _similarOpportunities.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFEDEEEE),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          "No similar opportunities right now.",
          style: TextStyle(color: Color(0xFF70797A), fontSize: 13),
        ),
      );
    }

    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _similarOpportunities.length,
        itemBuilder: (context, index) =>
            _buildSimilarOpportunityCard(_similarOpportunities[index]),
      ),
    );
  }

  Widget _buildSimilarOpportunityCard(Map<String, dynamic> item) {
    final title = (item['title'] ?? '').toString().isNotEmpty
        ? item['title'].toString()
        : 'Untitled Opportunity';

    final category = (item['industry'] ?? '').toString().isNotEmpty
        ? item['industry'].toString()
        : (item['type'] ?? '').toString();

    final location = (item['location'] ?? '').toString();

    final labelRaw = int.tryParse('${item['label'] ?? ''}');
    final labelName = labelRaw != null ? _labelMap[labelRaw] : null;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OpportunityDetailsScreen(opportunityId: item['id']),
          ),
        );
      },
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF4A626D).withOpacity(0.15)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (category.isNotEmpty)
              Text(
                category.toUpperCase(),
                style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF4A626D)),
              ),
            const SizedBox(height: 4),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const Spacer(),
            if (location.isNotEmpty)
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF70797A)),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      location,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: Color(0xFF70797A)),
                    ),
                  ),
                ],
              ),
            if (labelName != null) ...[
              const SizedBox(height: 6),
              _buildTag(
                '★ ${labelName.toUpperCase()}',
                backgroundColor: const Color(0xFF002B2F),
                textColor: Colors.white,
              ),
            ],
          ],
        ),
      ),
    );
  }
}