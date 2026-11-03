import 'dart:async';
import 'dart:convert';
import 'package:file_picker/file_picker.dart'; // flutter pub add file_picker
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http; // flutter pub add http

import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';

// ============================================================================
// jobDetailAPI_2_1.php  →  UI
//   get_job_details   page content (+ related jobs)       [id = RAW job id]
//   upload_resume     Apply sheet → "Upload new"          [multipart, field "resume"]
//   apply             Apply sheet → submit                [job_id + resume_id]
//   contact_recruiter "Contact Recruiter" sheet
// ============================================================================

const _kEndpoint = 'new_apis/jobDetailAPI.php';

// Only the resume upload needs this: it must be a multipart POST ($_FILES['resume']),
// which the normal Database helpers can't send. Set it to your API host.
const _kBaseUrl = 'https://YOUR-DOMAIN.com';

const _teal = Color(0xFF006565);
const _tealBg = Color(0xFFE3FFFE);
const _ink = Color(0xFF1A1C1C);
const _muted = Color(0xFF3E4949);
const _line = Color(0xFFBDC9C8);
const _bg = Color(0xFFF9F9F9);
const _red = Color(0xFFBA1A1A);

// ── Helpers ─────────────────────────────────────────────────────────────────
int _i(dynamic v, [int d = 0]) {
  if (v == null) return d;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? double.tryParse(v.toString())?.toInt() ?? d;
}

String _s(dynamic v) => (v ?? '').toString();
Map<String, dynamic> _m(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};
List<dynamic> _l(dynamic v) => v is List ? v : const [];

// The API returns htmlspecialchars()'d text ("R&amp;D"), so decode for display.
String _unescape(String s) => s
    .replaceAll('&lt;', '<')
    .replaceAll('&gt;', '>')
    .replaceAll('&quot;', '"')
    .replaceAll('&#039;', "'")
    .replaceAll('&#39;', "'")
    .replaceAll('&apos;', "'")
    .replaceAll('&nbsp;', ' ')
    .replaceAll('&amp;', '&');

String _htmlToText(String html) {
  var s = _unescape(_unescape(html));
  s = s.replaceAll(RegExp(r'<\s*br\s*/?>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'</\s*(p|div|h[1-6]|ul|ol)\s*>', caseSensitive: false), '\n');
  s = s.replaceAll(RegExp(r'<\s*li[^>]*>', caseSensitive: false), '\n• ');
  s = s.replaceAll(RegExp(r'<[^>]*>'), '');
  s = _unescape(s);
  return s.replaceAll(RegExp(r'[ \t]+'), ' ').replaceAll(RegExp(r'\n\s*\n+'), '\n').trim();
}

String _compactNum(double v) {
  String t(double n) => n == n.roundToDouble() ? n.toStringAsFixed(0) : n.toStringAsFixed(1);
  if (v >= 1e7) return '${t(v / 1e7)}Cr';
  if (v >= 1e5) return '${t(v / 1e5)}L';
  if (v >= 1e3) return '${t(v / 1e3)}k';
  return t(v);
}

String _salary(dynamic min, dynamic max) {
  final a = _s(min).trim(), b = _s(max).trim();
  final x = double.tryParse(a), y = double.tryParse(b);
  String f(double v) => '₹${_compactNum(v)}';
  if (x != null && y != null) {
    if (x <= 0 && y <= 0) return 'Not disclosed';
    if (x <= 0) return 'Up to ${f(y)}';
    if (y <= 0 || y == x) return f(x);
    return '${f(x)} - ${f(y)}';
  }
  if (a.isEmpty && b.isEmpty) return 'Not disclosed';
  return [a, b].where((e) => e.isNotEmpty).map(_unescape).join(' - ');
}

String _experience(dynamic min, dynamic max) {
  final a = _i(min), b = _i(max);
  if (a == 0 && b == 0) return 'Any';
  if (b > a) return '$a-$b years';
  if (a > 0 && (b == 0 || b == a)) return a == b ? '$a years' : '$a+ years';
  return 'Up to $b years';
}

bool _truthy(dynamic v) => v == true || v == 1 || v == '1' || v == 'true';

class _ApiError implements Exception {
  final String message;
  _ApiError(this.message);
  @override
  String toString() => message;
}

String _err(Object e) => e is _ApiError ? e.message : 'Error: $e';

// Resumes uploaded during this app session (the API has no "list my resumes" action).
class _ResumeRef {
  final int id;
  final String title;
  final DateTime at;
  _ResumeRef(this.id, this.title, this.at);
}

final List<_ResumeRef> _sessionResumes = [];
final Set<String> _bookmarks = {}; // local only – the API has no bookmark action

// ============================================================================
// SCREEN
// ============================================================================
class JobDetailsScreen extends StatefulWidget {
  /// RAW numeric job id. The list API returns it base64-encoded – decode before passing.
  final String jobId;

  /// Opens the apply sheet as soon as the job has loaded (used by the list's "Apply" button).
  final bool openApply;

  const JobDetailsScreen({super.key, required this.jobId, this.openApply = false});

  @override
  State<JobDetailsScreen> createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _job = {};
  bool _applied = false;
  bool _autoOpened = false;

  bool get _bookmarked => _bookmarks.contains(widget.jobId);
  Map<String, dynamic> get _vendor => _m(_job['vendor']);
  String get _jobId => _s(_job['id']).isNotEmpty ? _s(_job['id']) : widget.jobId;

  String get _company {
    final c = _unescape(_s(_vendor['company_name'])).trim();
    return c.isNotEmpty ? c : _unescape(_s(_vendor['name'])).trim();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  // ── API ───────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> _call(
      String action, [
        Map<String, dynamic> extra = const {},
        bool write = false,
      ]) async {
    final payload = {
      'action': action,
      'vendor_id': _i(UserSessionSet.instance.vendorId),
      'admin_id': _i(UserSessionSet.instance.adminId),
      ...extra,
    };
    try {
      final dynamic res = write
          ? await Database().getJsonData(payload, endpoint: _kEndpoint)
          : await Database().getData(payload, endpoint: _kEndpoint);
      return res is Map
          ? Map<String, dynamic>.from(res)
          : {'success': false, 'message': 'Invalid server response'};
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent && mounted) setState(() => _loading = true);
    final r = await _call('get_job_details', {'id': widget.jobId});
    if (r['success'] == true) {
      _job = _m(r['data']);
      _error = null;
    } else {
      _error = _s(r['message']).replaceFirst('Error: ', '');
      if (_error!.isEmpty) _error = 'Could not load this job.';
    }
    if (mounted) setState(() => _loading = false);

    if (_error == null && widget.openApply && !_autoOpened) {
      _autoOpened = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showApplyModal();
      });
    }
  }

  // upload_resume (multipart)
  Future<Map<String, dynamic>> _uploadResume(PlatformFile f, String note) async {
    if (_kBaseUrl.contains('YOUR-DOMAIN')) {
      throw _ApiError('Set _kBaseUrl in job_details_screen.dart to your API host.');
    }
    final base = _kBaseUrl.endsWith('/') ? _kBaseUrl : '$_kBaseUrl/';
    final dot = f.name.lastIndexOf('.');
    var title = dot > 0 ? f.name.substring(0, dot) : f.name;
    if (title.length > 50) title = title.substring(0, 50);

    final req = http.MultipartRequest('POST', Uri.parse('$base$_kEndpoint'))
      ..fields['action'] = 'upload_resume'
      ..fields['vendor_id'] = '${_i(UserSessionSet.instance.vendorId)}'
      ..fields['admin_id'] = '${_i(UserSessionSet.instance.adminId)}'
      ..fields['title'] = title
      ..fields['description'] = note
      ..fields['apply'] = 'no'
      ..files.add(http.MultipartFile.fromBytes('resume', f.bytes!, filename: f.name));

    final streamed = await req.send().timeout(const Duration(seconds: 90));
    final body = await streamed.stream.bytesToString();
    try {
      final j = jsonDecode(body);
      if (j is Map) return Map<String, dynamic>.from(j);
    } catch (_) {}
    return {'success': false, 'message': 'Unexpected server response while uploading'};
  }

  // ── UI helpers ────────────────────────────────────────────────────────────
  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
      content: Text(msg),
      behavior: SnackBarBehavior.floating,
      backgroundColor: error ? _red : const Color(0xFF2F3131),
    ));
  }

  Widget _logo(String url, {double size = 72}) {
    final fallback = Icon(Icons.business, size: size * 0.55, color: _teal);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF4F3F3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Center(child: fallback)
          : Image.network(url, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Center(child: fallback)),
    );
  }

  void _share() {
    Clipboard.setData(ClipboardData(
        text: '${_unescape(_s(_job['job_title']))}${_company.isNotEmpty ? ' at $_company' : ''}'));
    _toast('Job details copied');
  }

  void _toggleBookmark() {
    setState(() => _bookmarked ? _bookmarks.remove(widget.jobId) : _bookmarks.add(widget.jobId));
    _toast(_bookmarked ? 'Job saved' : 'Removed from saved jobs');
  }

  // ── Apply sheet (upload_resume → apply) ───────────────────────────────────
  void _showApplyModal() {
    PlatformFile? picked;
    int? selectedId = _sessionResumes.isNotEmpty ? _sessionResumes.first.id : null;
    final note = TextEditingController();
    bool submitting = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        final maxHeight = MediaQuery.of(modalContext).size.height * 0.88;
        final inset = MediaQuery.of(modalContext).viewInsets.bottom;

        return StatefulBuilder(builder: (ctx, setM) {
          Future<void> pick() async {
            try {
              final res = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx'],
                withData: true,
              );
              if (res == null || res.files.isEmpty) return;
              final f = res.files.first;
              if (f.bytes == null) {
                setM(() => error = 'Could not read the selected file');
                return;
              }
              if (f.size > 10 * 1024 * 1024) {
                setM(() => error = 'File is larger than 10MB');
                return;
              }
              setM(() {
                picked = f;
                selectedId = null;
                error = null;
              });
            } catch (e) {
              setM(() => error = 'Could not open the file picker');
            }
          }

          Future<void> submit() async {
            if (picked == null && selectedId == null) {
              setM(() => error = 'Upload a resume or select one below');
              return;
            }
            setM(() {
              submitting = true;
              error = null;
            });
            try {
              int resumeId;
              if (picked != null) {
                final up = await _uploadResume(picked!, note.text.trim());
                if (up['success'] != true) {
                  throw _ApiError(_s(up['message']).replaceFirst('Error: ', ''));
                }
                resumeId = _i(up['resume_id']);
                _sessionResumes.insert(0, _ResumeRef(resumeId, picked!.name, DateTime.now()));
              } else {
                resumeId = selectedId!;
              }

              final r = await _call('apply', {'job_id': _jobId, 'resume_id': resumeId}, true);
              final msg = _s(r['message']);
              if (r['success'] == true) {
                if (modalContext.mounted) Navigator.pop(modalContext);
                if (mounted) setState(() => _applied = true);
                _toast('Application submitted successfully!');
              } else if (msg.toLowerCase().contains('already applied')) {
                if (modalContext.mounted) Navigator.pop(modalContext);
                if (mounted) setState(() => _applied = true);
                _toast(msg);
              } else {
                setM(() {
                  submitting = false;
                  error = msg.replaceFirst('Error: ', '').isEmpty ? 'Could not submit application' : msg.replaceFirst('Error: ', '');
                });
              }
            } catch (e) {
              setM(() {
                submitting = false;
                error = _err(e);
              });
            }
          }

          return Container(
            constraints: BoxConstraints(maxHeight: maxHeight),
            decoration: const BoxDecoration(
              color: _bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: inset + 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('Submit Application',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _ink)),
                    IconButton(
                      icon: const Icon(Icons.close, color: _muted),
                      onPressed: submitting ? null : () => Navigator.pop(modalContext),
                    ),
                  ]),
                  const Divider(color: _line),
                  const SizedBox(height: 12),
                  const Text('OPTION 1: UPLOAD NEW',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: _muted)),
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: submitting ? null : pick,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                      decoration: BoxDecoration(
                        color: picked != null ? _tealBg : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: picked != null ? _teal : _line, width: picked != null ? 1.5 : 1),
                      ),
                      child: Column(children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(color: _tealBg, shape: BoxShape.circle),
                          child: Icon(picked != null ? Icons.description : Icons.upload_file,
                              size: 28, color: _teal),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          picked != null ? picked!.name : 'Tap to choose a file',
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: _ink),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          picked != null
                              ? '${(picked!.size / 1024).toStringAsFixed(0)} KB • tap to change'
                              : 'PDF, DOC, DOCX up to 10MB',
                          style: const TextStyle(fontSize: 12, color: _muted),
                        ),
                      ]),
                    ),
                  ),
                  if (picked != null) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: note,
                      maxLines: 2,
                      decoration: InputDecoration(
                        labelText: 'Note for the recruiter (optional)',
                        isDense: true,
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  const Text('OPTION 2: RECENTLY UPLOADED',
                      style: TextStyle(
                          fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: _muted)),
                  const SizedBox(height: 8),
                  if (_sessionResumes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text('Resumes you upload will appear here so you can reuse them.',
                          style: TextStyle(fontSize: 12, color: _muted)),
                    )
                  else
                    for (final r in _sessionResumes) ...[
                      _resumeOption(
                        title: r.title,
                        subtitle: _ago(r.at),
                        value: r.id,
                        groupValue: picked != null ? null : selectedId,
                        onChanged: submitting
                            ? null
                            : (v) => setM(() {
                          selectedId = v;
                          picked = null;
                          error = null;
                        }),
                      ),
                      const SizedBox(height: 8),
                    ],
                  if (error != null) ...[
                    const SizedBox(height: 8),
                    Text(error!, style: const TextStyle(color: _red, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: _teal),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submitting ? null : () => Navigator.pop(modalContext),
                        child: const Text('Cancel', style: TextStyle(color: _teal, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _teal,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: submitting ? null : submit,
                        child: submitting
                            ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Text('Submit Application',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  static String _ago(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return 'Uploaded just now';
    if (diff.inMinutes < 60) return 'Uploaded ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Uploaded ${diff.inHours}h ago';
    return 'Uploaded ${diff.inDays}d ago';
  }

  Widget _resumeOption({
    required String title,
    required String subtitle,
    required int value,
    required int? groupValue,
    required ValueChanged<int?>? onChanged,
  }) {
    final sel = value == groupValue;
    return Material(
      color: sel ? _tealBg : Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: sel ? _teal : _line, width: sel ? 1.5 : 1.0),
        ),
        child: RadioListTile<int>(
          value: value,
          groupValue: groupValue,
          activeColor: _teal,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          title: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: _ink)),
          subtitle: Text(subtitle, style: const TextStyle(fontSize: 12, color: _muted)),
          secondary: const Icon(Icons.description_outlined, color: _muted),
          onChanged: onChanged,
        ),
      ),
    );
  }

  // ── Contact recruiter sheet (contact_recruiter) ───────────────────────────
  void _showContactSheet() {
    final name = TextEditingController();
    final email = TextEditingController();
    final linkedin = TextEditingController();
    final subject = TextEditingController();
    final message = TextEditingController();
    bool sending = false;
    String? error;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setM) {
        Future<void> send() async {
          final em = email.text.trim();
          if (name.text.trim().isEmpty || message.text.trim().isEmpty) {
            setM(() => error = 'Name and message are required');
            return;
          }
          if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(em)) {
            setM(() => error = 'Enter a valid email address');
            return;
          }
          setM(() {
            sending = true;
            error = null;
          });
          final r = await _call('contact_recruiter', {
            'job_id': _jobId,
            'name': name.text.trim(),
            'email': em,
            'message': message.text.trim(),
            if (subject.text.trim().isNotEmpty) 'title': subject.text.trim(),
            if (linkedin.text.trim().isNotEmpty) 'linkedin_profile': linkedin.text.trim(),
          }, true);
          if (r['success'] == true) {
            if (ctx.mounted) Navigator.pop(ctx);
            _toast('Message sent to the recruiter');
          } else {
            setM(() {
              sending = false;
              error = _s(r['message']).replaceFirst('Error: ', '');
            });
          }
        }

        Widget field(TextEditingController c, String label,
            {TextInputType? type, int lines = 1}) =>
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: c,
                keyboardType: type,
                maxLines: lines,
                decoration: InputDecoration(
                  labelText: label,
                  isDense: true,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            );

        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  const Expanded(
                    child: Text('Contact Recruiter',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _ink)),
                  ),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                ]),
                Text(_unescape(_s(_job['job_title'])), style: const TextStyle(fontSize: 12, color: _muted)),
                const SizedBox(height: 14),
                field(name, 'Your name *'),
                field(email, 'Your email *', type: TextInputType.emailAddress),
                field(subject, 'Subject (optional)'),
                field(linkedin, 'LinkedIn profile (optional)', type: TextInputType.url),
                field(message, 'Message *', lines: 4),
                if (error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(error!, style: const TextStyle(color: _red, fontSize: 12)),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: sending ? null : send,
                    icon: sending
                        ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send, size: 18),
                    label: Text(sending ? 'Sending…' : 'Send Message',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ),
          ),
        );
      }),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final title = _unescape(_s(_job['job_title']));
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _muted),
          onPressed: () {
            if (Navigator.canPop(context)) Navigator.pop(context);
          },
        ),
        title: Text(
          title.isEmpty ? 'Job Details' : title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w600),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: _line, height: 1.0),
        ),
        actions: [
          IconButton(
              icon: const Icon(Icons.share_outlined, color: _muted),
              onPressed: _job.isEmpty ? null : _share),
          IconButton(
            icon: Icon(_bookmarked ? Icons.bookmark : Icons.bookmark_outline,
                color: _bookmarked ? _teal : _muted),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _teal))
          : _error != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.work_off_outlined, size: 40, color: _muted),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton(onPressed: _load, child: const Text('Retry')),
          ]),
        ),
      )
          : RefreshIndicator(
        color: _teal,
        onRefresh: () => _load(silent: true),
        child: _content(),
      ),
      bottomNavigationBar: (_loading || _error != null) ? null : _bottomBar(),
    );
  }

  Widget _content() {
    final j = _job;
    final hideSalary = _truthy(j['do_not_show_publically']);
    final salary = hideSalary ? 'Not disclosed' : _salary(j['sal_min'], j['sal_max']);
    final category = _unescape(_s(j['job_category']));
    final position = _unescape(_s(j['position_lvl']));
    final place = _unescape(_s(j['work_place']));
    final skills = _l(j['skills_required']).map((e) => _unescape(_s(e))).where((e) => e.isNotEmpty).toList();
    final lines = _htmlToText(_s(j['job_desc'])).split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final related = _l(j['related_jobs']).map(_m).toList();
    final views = _i(j['views']);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Hero
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _logo(_s(_vendor['company_logo'])),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Wrap(spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
                if (category.isNotEmpty) _chip(category.toUpperCase()),
                if (position.isNotEmpty)
                  Row(mainAxisSize: MainAxisSize.min, children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(color: Color(0xFFB45309), shape: BoxShape.circle)),
                    const SizedBox(width: 4),
                    Text(position.toUpperCase(),
                        style: const TextStyle(
                            color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold)),
                  ]),
              ]),
              const SizedBox(height: 6),
              Text(_unescape(_s(j['job_title'])),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: _ink)),
              const SizedBox(height: 4),
              Text(
                [if (_company.isNotEmpty) _company, if (place.isNotEmpty) place].join(' • '),
                style: const TextStyle(fontSize: 14, color: _muted),
              ),
              const SizedBox(height: 4),
              Text(
                '${_s(j['time_ago'])}${views > 0 ? ' • $views views' : ''}',
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ]),
          ),
        ]),
        const SizedBox(height: 24),

        // Overview
        Row(children: [
          Expanded(
              child: OverviewMetricCard(
                  title: 'JOB TYPE',
                  value: _unescape(_s(j['work_type'])).isEmpty ? '-' : _unescape(_s(j['work_type'])),
                  icon: Icons.schedule)),
          const SizedBox(width: 8),
          Expanded(
              child: OverviewMetricCard(
                  title: 'EXPERIENCE',
                  value: _experience(j['reqd_exp_min'], j['reqd_exp_max']),
                  icon: Icons.work_history_outlined)),
          const SizedBox(width: 8),
          Expanded(child: OverviewMetricCard(title: 'SALARY', value: salary, icon: Icons.payments_outlined)),
        ]),
        const SizedBox(height: 28),
        const Divider(color: _line),
        const SizedBox(height: 20),

        // Description
        _heading('About the Role'),
        const SizedBox(height: 8),
        if (lines.isEmpty)
          const Text('No description provided.', style: TextStyle(fontSize: 15, color: _muted))
        else
          ..._descriptionWidgets(lines),
        const SizedBox(height: 24),

        // Skills
        if (skills.isNotEmpty) ...[
          _heading('Skills Required'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [for (final s in skills) _skillChip(s)]),
          const SizedBox(height: 24),
        ],

        // Recruiter / company
        _recruiterCard(),
        const SizedBox(height: 28),
        const Divider(color: _line),
        const SizedBox(height: 20),

        // Similar
        if (related.isNotEmpty) ...[
          const Text(
            'Similar Opportunities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: _ink,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 170, // Expanded height to prevent vertical overflow
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: related.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final r = related[i];
                return SimilarOpportunityCard(
                  category: category,
                  title: _unescape(_s(r['job_title'])),
                  company: _unescape(_s(r['company_name'])),
                  posted: _s(r['time_ago']),
                  logo: _s(r['company_logo']),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobDetailsScreen(jobId: _s(r['id'])),
                    ),
                  ),
                );
              },
            ),
          ),
        ] else
          const Text(
            'No similar opportunities right now.',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
        const SizedBox(height: 40),
      ]),
    );
  }

  List<Widget> _descriptionWidgets(List<String> lines) {
    final out = <Widget>[];
    final para = <String>[];
    void flush() {
      if (para.isEmpty) return;
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(para.join('\n'),
            style: const TextStyle(fontSize: 15, height: 1.5, color: _muted)),
      ));
      para.clear();
    }

    for (final l in lines) {
      final bullet = l.startsWith('• ') || l.startsWith('- ') || l.startsWith('* ');
      if (bullet) {
        flush();
        out.add(RequirementTile(icon: Icons.check_circle_outline, text: l.substring(2).trim()));
      } else {
        para.add(l);
      }
    }
    flush();
    return out;
  }

  Widget _recruiterCard() {
    final bio = _htmlToText(_s(_vendor['bio']));
    final name = _unescape(_s(_vendor['name']));
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          _logo(_s(_vendor['company_logo']), size: 44),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(_company.isEmpty ? 'Recruiter' : _company,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _ink)),
              if (name.isNotEmpty && name != _company)
                Text('Posted by $name', style: const TextStyle(fontSize: 12, color: _muted)),
            ]),
          ),
        ]),
        if (bio.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(bio, maxLines: 4, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, height: 1.4, color: _muted)),
        ],
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: _teal,
              side: const BorderSide(color: _teal),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _showContactSheet,
            icon: const Icon(Icons.mail_outline, size: 18),
            label: const Text('Contact Recruiter', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
      ]),
    );
  }

  Widget _heading(String t) =>
      Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _teal));

  Widget _chip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(color: _tealBg, borderRadius: BorderRadius.circular(12)),
    child: Text(t, style: const TextStyle(color: _teal, fontSize: 11, fontWeight: FontWeight.bold)),
  );

  Widget _skillChip(String t) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Text(t, style: const TextStyle(fontSize: 12, color: _ink, fontWeight: FontWeight.w500)),
  );

  Widget _bottomBar() {
    final hide = _truthy(_job['do_not_show_publically']);
    final salary = hide ? 'Salary not disclosed' : '${_salary(_job['sal_min'], _job['sal_max'])} / year';
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: _line))),
        child: Row(children: [
          Expanded(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(salary,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _ink)),
              const SizedBox(height: 2),
              Text('Posted ${_s(_job['time_ago'])}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: _muted)),
            ]),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 140,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _applied ? const Color(0xFF15803D) : _teal,
                disabledBackgroundColor: const Color(0xFF15803D),
                minimumSize: const Size(140, 48),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _applied ? null : _showApplyModal,
              icon: Icon(_applied ? Icons.check_circle : Icons.send, size: 18, color: Colors.white),
              label: Text(_applied ? 'Applied' : 'Apply Now',
                  style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            ),
          ),
        ]),
      ),
    );
  }
}

// ============================================================================
// WIDGETS
// ============================================================================
class OverviewMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const OverviewMetricCard({super.key, required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(
          left: BorderSide(color: _teal, width: 4),
          top: BorderSide(color: _line),
          right: BorderSide(color: _line),
          bottom: BorderSide(color: _line),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _muted)),
        const SizedBox(height: 6),
        Row(children: [
          Icon(icon, color: _teal, size: 16),
          const SizedBox(width: 4),
          Expanded(
            child: Text(value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _ink)),
          ),
        ]),
      ]),
    );
  }
}

class RequirementTile extends StatelessWidget {
  final IconData icon;
  final String text;

  const RequirementTile({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, color: _teal, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 14, color: _muted, height: 1.4))),
      ]),
    );
  }
}

class SimilarOpportunityCard extends StatelessWidget {
  final String category;
  final String title;
  final String company;
  final String posted;
  final String logo;
  final VoidCallback onTap;

  const SimilarOpportunityCard({
    super.key,
    required this.category,
    required this.title,
    required this.company,
    required this.posted,
    required this.logo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        width: 260,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: SizedBox(
                  width: 36,
                  height: 36,
                  child: logo.isEmpty
                      ? const ColoredBox(color: Color(0xFFF4F3F3), child: Icon(Icons.business, size: 20, color: _teal))
                      : Image.network(logo,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const ColoredBox(
                          color: Color(0xFFF4F3F3), child: Icon(Icons.business, size: 20, color: _teal))),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(category.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: _muted)),
                  Text(title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ]),
              ),
            ]),
            Text(company.isEmpty ? '-' : company,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13, color: _muted)),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(
                child: Text(posted,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _teal)),
              ),
              const SizedBox(width: 8),
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _teal),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  minimumSize: const Size(0, 32),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: onTap,
                child: const Text('View', style: TextStyle(fontSize: 12, color: _teal)),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}