import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

import '../app_constants.dart';
import 'membership_plans_screen.dart';

/// ---------------------------------------------------------------------
/// DEBUG LOGGER
/// ---------------------------------------------------------------------
/// Every meaningful step in this file funnels through here so you get a
/// single, consistently-tagged stream of debug output in the console
/// (Run > Debug Console in VS Code / Android Studio, or `flutter logs`).
void _log(String step, [Object? data]) {
  if (!kDebugMode) return;
  final ts = DateTime.now().toIso8601String();
  if (data != null) {
    debugPrint('[JobForm][$ts] $step -> $data');
  } else {
    debugPrint('[JobForm][$ts] $step');
  }
}


/// ---------------------------------------------------------------------
/// DESIGN TOKENS
/// ---------------------------------------------------------------------
class AppColors {
  static const primary = Color(0xFF006565);
  static const primaryContainer = Color(0xFF008080);
  static const onPrimaryContainer = Color(0xFFE3FFFE);
  static const secondary = Color(0xFF296767);
  static const secondaryContainer = Color(0xFFB0EEED);
  static const onSecondaryContainer = Color(0xFF306E6D);
  static const containerTeal = Color(0xFFE3FFFE);
  static const primaryFixedDim = Color(0xFF76D6D5);

  static const background = Color(0xFFF9F9F9);
  static const surface = Color(0xFFF9F9F9);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F3F3);
  static const surfaceContainer = Color(0xFFEEEEED);
  static const surfaceContainerHigh = Color(0xFFE8E8E8);
  static const surfaceVariant = Color(0xFFE2E2E2);

  static const onSurface = Color(0xFF1A1C1C);
  static const onSurfaceVariant = Color(0xFF3E4949);
  static const outline = Color(0xFF6E7979);
  static const outlineVariant = Color(0xFFBDC9C8);

  static const error = Color(0xFFBA1A1A);
}

/// =======================================================================
/// API LAYER
/// =======================================================================
///
/// EDIT baseUrl to point at your server. The PHP endpoint lives at:
///   ${baseUrl}new_apis/job_from_API.php
/// (the file that does `session_start()` + `$_SESSION['vendor_id']` +
/// the marketplace_jobs INSERT).
class ApiConfig {
  static Uri get postJobUri => Uri.parse('${baseUrl}new_apis/create_job_API.php');
}

/// Holds the PHP session cookie so every request looks like it's coming
/// from the same logged-in vendor. PHP's `session_start()` relies on a
/// `PHPSESSID=...` cookie — grab this from your login call's response
/// headers (`set-cookie`) and store it here (SharedPreferences/secure
/// storage in a real app) before hitting this screen.
class SessionManager {
  SessionManager._();
  static final SessionManager instance = SessionManager._();

  String? _cookie;

  String? get cookie => _cookie;

  void setCookieFromResponse(http.BaseResponse response) {
    final raw = response.headers['set-cookie'];
    if (raw != null && raw.isNotEmpty) {
      // Keep just the "PHPSESSID=xxxx" part, drop attrs like Path/HttpOnly.
      _cookie = raw.split(';').first;
      _log('SessionManager.setCookieFromResponse: cookie captured', _cookie);
    } else {
      _log('SessionManager.setCookieFromResponse: no set-cookie header present');
    }
  }

  void setCookie(String cookie) {
    _cookie = cookie;
    _log('SessionManager.setCookie: cookie set manually', cookie);
  }
}

/// Thin wrapper around the multipart POST to job_from_API.php.
///
/// Every field sent here maps 1:1 to a `$_POST[...]` read in the PHP
/// script, and every file maps to a `$_FILES[...]` read there too:
///
///   Dart field            PHP read
///   --------------------  --------------------------------
///   title                 $_POST['title']
///   company               $_POST['company']
///   job_desc               $_POST['job_desc']
///   job_type               $_POST['job_type']
///   mode                   $_POST['mode']
///   location               $_POST['location']
///   experience             $_POST['experience']
///   openings               $_POST['openings']
///   salary                 $_POST['salary']
///   compensation           $_POST['compensation']
///   payment_type           $_POST['payment_type']
///   salary_amount          $_POST['salary_amount']
///   duration               $_POST['duration']
///   deadline               $_POST['deadline']
///   requirements (JSON)    $_POST['requirements'] (json_decode)
///   skills (JSON)          $_POST['skills'] (json_decode)
///   perks                  $_POST['perks']
///   attachments            $_POST['attachments']
///   logo_file (file)       $_FILES['logo_file']
///   thumbnail_file (file)  $_FILES['thumbnail_file']
///   documents[] (files)    $_FILES['documents']
class JobApiService {
  static Future<JobPostResult> postJob({
    required String title,
    required String company,
    required String jobDesc,
    required String jobType, // 'JOB' | 'INTERNSHIP'
    required String workMode,
    required String location,
    required String experience,
    required int openings,
    required String salary, // display string, e.g. "50000-70000" or "Unpaid"
    required String compensation,
    required String paymentType, // 'free' | 'paid'
    required String salaryAmount, // numeric string used for stipend calc
    required String duration, // internship months, '' for jobs
    required String deadline, // yyyy-MM-dd
    List<String> requirements = const [],
    List<String> skills = const [],
    String perks = '',
    String attachments = '',
    XFile? logoFile,
    XFile? thumbnailFile,
    List<XFile> documentFiles = const [],
  }) async {
    _log('JobApiService.postJob: START');
    _log('JobApiService.postJob: target URL', ApiConfig.postJobUri);

    final request = http.MultipartRequest('POST', ApiConfig.postJobUri);

    final cookie = SessionManager.instance.cookie;
    if (cookie != null) {
      request.headers['Cookie'] = cookie;
      _log('JobApiService.postJob: attached session cookie', cookie);
    } else {
      _log('JobApiService.postJob: WARNING no session cookie set — '
          'PHP will not see \$_SESSION[\'vendor_id\'] and will reject the request');
    }

    final fields = {
      'title': title,
      'company': company,
      'job_desc': jobDesc,
      'job_type': jobType,
      'mode': workMode,
      'location': location,
      'experience': experience,
      'openings': openings.toString(),
      'salary': salary,
      'compensation': compensation,
      'payment_type': paymentType,
      'salary_amount': salaryAmount,
      'duration': duration,
      'deadline': deadline,
      'requirements': jsonEncode(requirements),
      'skills': jsonEncode(skills),
      'perks': perks,
      'attachments': attachments,
    };
    request.fields.addAll(fields);
    _log('JobApiService.postJob: fields attached', fields);

    if (logoFile != null) {
      final part = await _toMultipartFile('logo_file', logoFile);
      request.files.add(part);
      _log('JobApiService.postJob: logo_file attached', logoFile.name);
    } else {
      _log('JobApiService.postJob: no logo_file provided');
    }

    if (thumbnailFile != null) {
      final part = await _toMultipartFile('thumbnail_file', thumbnailFile);
      request.files.add(part);
      _log('JobApiService.postJob: thumbnail_file attached', thumbnailFile.name);
    } else {
      _log('JobApiService.postJob: no thumbnail_file provided');
    }

    if (documentFiles.isEmpty) {
      _log('JobApiService.postJob: no document files provided');
    }
    for (final doc in documentFiles) {
      final part = await _toMultipartFile('documents[]', doc);
      request.files.add(part);
      _log('JobApiService.postJob: document attached', doc.name);
    }

    _log('JobApiService.postJob: sending request',
        'fields=${request.fields.length}, files=${request.files.length}');

    try {
      final streamed = await request.send();
      _log('JobApiService.postJob: response status', streamed.statusCode);

      final response = await http.Response.fromStream(streamed);
      _log('JobApiService.postJob: raw response body', response.body);

      // Capture/refresh session cookie if the server rotated it.
      SessionManager.instance.setCookieFromResponse(response);

      if (response.statusCode != 200) {
        _log('JobApiService.postJob: FAILED non-200 status', response.statusCode);
        return JobPostResult.failure(
            'Server returned status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      _log('JobApiService.postJob: decoded JSON', decoded);

      final success = decoded['success'] == true;
      final message = decoded['message']?.toString() ?? '';
      final jobId = decoded['job_id'];

      if (success) {
        _log('JobApiService.postJob: SUCCESS', 'job_id=$jobId');
        return JobPostResult.success(message, jobId);
      } else {
        _log('JobApiService.postJob: SERVER REPORTED FAILURE', message);
        return JobPostResult.failure(
            message.isNotEmpty ? message : 'Job could not be posted.');
      }
    } on FormatException catch (e) {
      _log('JobApiService.postJob: FormatException parsing response', e);
      return JobPostResult.failure(
          'Unexpected response from server. Please try again.');
    } catch (e) {
      _log('JobApiService.postJob: EXCEPTION', e);
      return JobPostResult.failure('Network error: $e');
    } finally {
      _log('JobApiService.postJob: END');
    }
  }

  static Future<http.MultipartFile> _toMultipartFile(
      String field, XFile file) async {
    _log('JobApiService._toMultipartFile: building part', '$field <- ${file.name}');
    if (kIsWebPlatform) {
      final bytes = await file.readAsBytes();
      _log('JobApiService._toMultipartFile: web bytes read', bytes.length);
      return http.MultipartFile.fromBytes(field, bytes, filename: file.name);
    }
    _log('JobApiService._toMultipartFile: reading from path', file.path);
    return http.MultipartFile.fromPath(field, file.path, filename: file.name);
  }
}

/// Minimal web check without pulling in `dart:html`/`universal_platform`.
bool get kIsWebPlatform => identical(0, 0.0);

class JobPostResult {
  final bool success;
  final String message;
  final dynamic jobId;
  JobPostResult._(this.success, this.message, this.jobId);

  factory JobPostResult.success(String message, dynamic jobId) =>
      JobPostResult._(true, message, jobId);
  factory JobPostResult.failure(String message) =>
      JobPostResult._(false, message, null);
}

/// ---------------------------------------------------------------------
/// MAIN SCREEN
/// ---------------------------------------------------------------------
class PostOpportunityScreen extends StatefulWidget {
  final String? sessionCookie;
  final bool isEmbedded;

  const PostOpportunityScreen({super.key, this.sessionCookie,this.isEmbedded= false});

  @override
  State<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends State<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Text controllers mapped directly to PHP $_POST fields.
  final _titleCtrl = TextEditingController();
  final _companyCtrl = TextEditingController();
  // Job description now uses a rich-text (Quill) editor, same as the
  // "Short Summary" field on the Create Training screen.
  final _descQuillController = QuillController.basic();
  final _locationCtrl = TextEditingController();
  final _openingsCtrl = TextEditingController(text: '1');
  final _salaryMinCtrl = TextEditingController();
  final _salaryMaxCtrl = TextEditingController();
  final _compensationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _stipendCtrl = TextEditingController();

  // NEW: previously collected by the PHP endpoint but never wired up
  // from the UI. Comma-separated free text -> List<String> -> JSON.
  final _requirementsCtrl = TextEditingController(); // -> requirements[]
  final _skillsCtrl = TextEditingController(); // -> skills[]
  final _perksCtrl = TextEditingController(); // -> perks
  final _attachmentsCtrl = TextEditingController(); // -> attachments (notes/links)

  String _opportunityType = 'job'; // 'job' | 'internship'
  String _workMode = 'Remote';
  String _experienceLevel = 'Entry Level';
  String _paymentType = 'free'; // 'free' | 'paid'
  DateTime? _deadline;

  XFile? _logoFile;
  XFile? _thumbnailFile;

  // NEW: supporting documents -> $_FILES['documents'][] on the PHP side.
  final List<XFile> _documentFiles = [];

  bool _submitting = false;

  static const double _tabletBreak = 800;
  static const double _desktopBreak = 1100;

  @override
  void initState() {
    super.initState();
    _log('PostOpportunityScreen.initState');
    if (widget.sessionCookie != null) {
      _log('PostOpportunityScreen.initState: sessionCookie provided via widget');
      SessionManager.instance.setCookie(widget.sessionCookie!);
    } else {
      _log('PostOpportunityScreen.initState: no sessionCookie provided — '
          'expecting SessionManager.instance.setCookie() to have been called already');
    }
  }

  @override
  void dispose() {
    _log('PostOpportunityScreen.dispose');
    _titleCtrl.dispose();
    _companyCtrl.dispose();
    _descQuillController.dispose();
    _locationCtrl.dispose();
    _openingsCtrl.dispose();
    _salaryMinCtrl.dispose();
    _salaryMaxCtrl.dispose();
    _compensationCtrl.dispose();
    _durationCtrl.dispose();
    _stipendCtrl.dispose();
    _requirementsCtrl.dispose();
    _skillsCtrl.dispose();
    _perksCtrl.dispose();
    _attachmentsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDeadline() async {
    _log('_pickDeadline: opening date picker');
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 3),
    );
    if (picked != null) {
      _log('_pickDeadline: date selected', picked);
      setState(() => _deadline = picked);
    } else {
      _log('_pickDeadline: cancelled');
    }
  }

  Future<void> _pickLogo() async {
    _log('_pickLogo: opening gallery');
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _log('_pickLogo: file selected', file.name);
      setState(() => _logoFile = file);
    } else {
      _log('_pickLogo: cancelled');
    }
  }

  Future<void> _pickThumbnail() async {
    _log('_pickThumbnail: opening gallery');
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (file != null) {
      _log('_pickThumbnail: file selected', file.name);
      setState(() => _thumbnailFile = file);
    } else {
      _log('_pickThumbnail: cancelled');
    }
  }

  /// Documents endpoint on the PHP side accepts multiple files
  /// (`$_FILES['documents']['name'][i]` etc). `image_picker`'s
  /// `pickMultiImage` is used here to avoid adding a new dependency;
  /// swap in `file_picker` if you need true non-image documents
  /// (PDF/DOCX) — the API call and PHP handling already support it.
  Future<void> _pickDocuments() async {
    _log('_pickDocuments: opening multi picker');
    final files = await _picker.pickMultiImage();
    if (files.isNotEmpty) {
      _log('_pickDocuments: files selected', files.map((f) => f.name).toList());
      setState(() => _documentFiles.addAll(files));
    } else {
      _log('_pickDocuments: cancelled / nothing selected');
    }
  }

  void _removeDocument(XFile file) {
    _log('_removeDocument', file.name);
    setState(() => _documentFiles.remove(file));
  }

  String _buildSalaryString() {
    if (_paymentType == 'free') return 'Unpaid';
    final min = _salaryMinCtrl.text.trim();
    final max = _salaryMaxCtrl.text.trim();
    if (min.isEmpty && max.isEmpty) return '';
    if (min.isNotEmpty && max.isNotEmpty) return '$min-$max';
    return min.isNotEmpty ? min : max;
  }

  /// Splits a comma-separated field into a clean List<String>, matching
  /// what the PHP side expects to `json_decode` for requirements/skills.
  List<String> _splitCsv(String raw) {
    return raw
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Converts the Quill document (job description) into HTML, the same
  /// way the Create Training screen converts its Short Summary field.
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

  Future<void> _submit() async {
    _log('_submit: START validating form');
    if (!(_formKey.currentState?.validate() ?? false)) {
      _log('_submit: ABORT form validation failed');
      return;
    }
    if (_deadline == null) {
      _log('_submit: ABORT no deadline selected');
      _showError('Please choose an application deadline.');
      return;
    }
    _log('_submit: form valid, deadline present', _deadline);

    final jobDescHtml = _getHtmlFromQuill(_descQuillController);
    if (jobDescHtml.trim().isEmpty ||
        jobDescHtml == "<p></p>" ||
        jobDescHtml == "<p><br></p>") {
      _log('_submit: ABORT job description empty');
      _showError('Job Description is required');
      return;
    }

    setState(() => _submitting = true);

    final deadlineStr =
        '${_deadline!.year}-${_deadline!.month.toString().padLeft(2, '0')}-${_deadline!.day.toString().padLeft(2, '0')}';
    _log('_submit: deadline formatted', deadlineStr);

    final requirements = _splitCsv(_requirementsCtrl.text);
    final skills = _splitCsv(_skillsCtrl.text);
    _log('_submit: requirements parsed', requirements);
    _log('_submit: skills parsed', skills);

    final salaryString = _buildSalaryString();
    _log('_submit: salary string built', salaryString);

    final salaryAmount = _stipendCtrl.text.trim().isNotEmpty
        ? _stipendCtrl.text.trim()
        : _salaryMinCtrl.text.trim();
    _log('_submit: salaryAmount resolved', salaryAmount);

    _log('_submit: calling JobApiService.postJob', {
      'title': _titleCtrl.text.trim(),
      'company': _companyCtrl.text.trim(),
      'jobType': _opportunityType == 'internship' ? 'INTERNSHIP' : 'JOB',
      'workMode': _workMode,
      'location': _locationCtrl.text.trim(),
      'openings': _openingsCtrl.text.trim(),
      'paymentType': _paymentType,
      'documentCount': _documentFiles.length,
      'hasLogo': _logoFile != null,
      'hasThumbnail': _thumbnailFile != null,
    });

    final result = await JobApiService.postJob(
      title: _titleCtrl.text.trim(),
      company: _companyCtrl.text.trim(),
      jobDesc: jobDescHtml,
      jobType: _opportunityType == 'internship' ? 'INTERNSHIP' : 'JOB',
      workMode: _workMode.toLowerCase().replaceAll('-', ''),
      location: _locationCtrl.text.trim(),
      experience: _experienceLevel,
      openings: int.tryParse(_openingsCtrl.text.trim()) ?? 1,
      salary: salaryString,
      compensation: _compensationCtrl.text.trim(),
      paymentType: _paymentType,
      salaryAmount: salaryAmount,
      duration:
      _opportunityType == 'internship' ? _durationCtrl.text.trim() : '',
      deadline: deadlineStr,
      requirements: requirements,
      skills: skills,
      perks: _perksCtrl.text.trim(),
      attachments: _attachmentsCtrl.text.trim(),
      logoFile: _logoFile,
      thumbnailFile: _thumbnailFile,
      documentFiles: _documentFiles,
    );

    _log('_submit: result received', {
      'success': result.success,
      'message': result.message,
      'jobId': result.jobId,
    });

    if (!mounted) {
      _log('_submit: widget unmounted after await, aborting UI update');
      return;
    }
    setState(() => _submitting = false);

    if (result.success) {
      _log('_submit: showing success dialog');
      showDialog(
        context: context,
        builder: (_) => _SuccessDialog(jobId: result.jobId?.toString()),
      );
    } else {
      _log('_submit: showing error handling', result.message);

      // Check if this is a "no posts left" error
      if (result.message.contains("You don't have any posts left for jobs. Please buy a membership or package to post a job.") ||
          result.message.contains('please buy a membership') ||
          result.message.toLowerCase().contains('membership')) {
        _showMembershipRequiredDialog(result.message);
      } else {
        _showError(result.message);
      }
    }
    _log('_submit: END');
  }
  void _showError(String message) {
    _log('_showError', message);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _saveDraft() {
    _log('_saveDraft: tapped (not wired to an endpoint)');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Draft saving is not wired to an endpoint yet.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isTablet = width >= _tabletBreak;
    final isDesktop = width >= _desktopBreak;
    _log('PostOpportunityScreen.build', 'width=$width isTablet=$isTablet isDesktop=$isDesktop');

    return Scaffold(
      appBar: widget.isEmbedded ? null : _TopNavBar(showLinks: isTablet),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: isDesktop ? 40 : 16,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop) ...[
                          const _SidebarNav(),
                          const SizedBox(width: 24),
                        ],
                        Expanded(
                          child: _FormContent(
                            formKey: _formKey,
                            isDesktop: isDesktop,
                            titleCtrl: _titleCtrl,
                            companyCtrl: _companyCtrl,
                            descQuillController: _descQuillController,
                            locationCtrl: _locationCtrl,
                            openingsCtrl: _openingsCtrl,
                            salaryMinCtrl: _salaryMinCtrl,
                            salaryMaxCtrl: _salaryMaxCtrl,
                            compensationCtrl: _compensationCtrl,
                            durationCtrl: _durationCtrl,
                            stipendCtrl: _stipendCtrl,
                            requirementsCtrl: _requirementsCtrl,
                            skillsCtrl: _skillsCtrl,
                            perksCtrl: _perksCtrl,
                            attachmentsCtrl: _attachmentsCtrl,
                            opportunityType: _opportunityType,
                            onTypeChanged: (v) {
                              _log('opportunityType changed', v);
                              setState(() => _opportunityType = v);
                            },
                            workMode: _workMode,
                            onWorkModeChanged: (v) {
                              _log('workMode changed', v);
                              setState(() => _workMode = v ?? _workMode);
                            },
                            experienceLevel: _experienceLevel,
                            onExperienceChanged: (v) {
                              _log('experienceLevel changed', v);
                              setState(() =>
                              _experienceLevel = v ?? _experienceLevel);
                            },
                            paymentType: _paymentType,
                            onPaymentChanged: (v) {
                              _log('paymentType changed', v);
                              setState(() => _paymentType = v);
                            },
                            deadline: _deadline,
                            onPickDeadline: _pickDeadline,
                            logoFile: _logoFile,
                            thumbnailFile: _thumbnailFile,
                            onPickLogo: _pickLogo,
                            onPickThumbnail: _pickThumbnail,
                            documentFiles: _documentFiles,
                            onPickDocuments: _pickDocuments,
                            onRemoveDocument: _removeDocument,
                            submitting: _submitting,
                            onSubmit: _submit,
                            onSaveDraft: _saveDraft,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (_submitting)
              Container(
                color: Colors.black.withOpacity(0.05),
                child: const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }
  void _showMembershipRequiredDialog(String errorMessage) {
    _log('_showMembershipRequiredDialog', errorMessage);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 420,
              maxHeight: 600,
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  /// Header
                  Row(
                    children: [
                      const Icon(
                        Icons.lock_outline,
                        color: AppColors.error,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          "Membership Required",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.error,
                          ),
                        ),
                      ),

                      /// Close Button
                      IconButton(
                        icon: const Icon(Icons.close),
                        splashRadius: 22,
                        onPressed: () {
                          Navigator.pop(dialogContext);
                        },
                      ),
                    ],
                  ),

                  const Divider(),

                  /// Body
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "You have exhausted your job posting credits.",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            errorMessage,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: AppColors.outlineVariant,
                              ),
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Text(
                                  "💡 What you can do",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                SizedBox(height: 12),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Purchase a membership plan",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Buy a job posting package",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(height: 10),

                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green, size: 18),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        "Upgrade your current membership",
                                        style: TextStyle(fontSize: 14),
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
                  ),

                  const SizedBox(height: 20),

                  /// Bottom Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pop(dialogContext);

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MembershipPlansScreen(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("View Plans"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// TOP NAV BAR
/// ---------------------------------------------------------------------
class _TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final bool showLinks;
  const _TopNavBar({required this.showLinks});

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primary),
        onPressed: () {
          _log('_TopNavBar: back pressed');
          Navigator.of(context).maybePop();
        },
      ),
      backgroundColor: AppColors.surface,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      shape: const Border(
        bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
      ),
      titleSpacing: showLinks ? 16 : 8,
      title: const Text(
        'Job Form',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: AppColors.onSurfaceVariant),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  const _NavLink(this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.bold : FontWeight.w500,
          color: active ? AppColors.primary : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// SIDEBAR (desktop only)
/// ---------------------------------------------------------------------
class _SidebarNav extends StatelessWidget {
  const _SidebarNav();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('VENDOR PROFILE',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurfaceVariant)),
                SizedBox(height: 4),
                Text('Global Tech Partners',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 18)),
                Text('Expert Tier Vendor',
                    style: TextStyle(color: AppColors.onSurfaceVariant)),
              ],
            ),
          ),
          _SideNavItem(Icons.add_circle, 'Post Opportunity', active: true),
          _SideNavItem(Icons.dashboard_outlined, 'Dashboard'),
          _SideNavItem(Icons.school_outlined, 'Trainings'),
          _SideNavItem(Icons.leaderboard_outlined, 'Analytics'),
        ],
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  const _SideNavItem(this.icon, this.label, {this.active = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: active ? AppColors.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: active
                ? AppColors.onSecondaryContainer
                : AppColors.onSurfaceVariant),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: active ? FontWeight.w600 : FontWeight.normal,
            color: active
                ? AppColors.onSecondaryContainer
                : AppColors.onSurfaceVariant,
          ),
        ),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        onTap: () {},
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// FORM CONTENT
/// ---------------------------------------------------------------------
class _FormContent extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final bool isDesktop;

  final TextEditingController titleCtrl;
  final TextEditingController companyCtrl;
  // Job description is now backed by a QuillController (rich text),
  // matching the "Short Summary" field on the Create Training screen.
  final QuillController descQuillController;
  final TextEditingController locationCtrl;
  final TextEditingController openingsCtrl;
  final TextEditingController salaryMinCtrl;
  final TextEditingController salaryMaxCtrl;
  final TextEditingController compensationCtrl;
  final TextEditingController durationCtrl;
  final TextEditingController stipendCtrl;
  final TextEditingController requirementsCtrl;
  final TextEditingController skillsCtrl;
  final TextEditingController perksCtrl;
  final TextEditingController attachmentsCtrl;

  final String opportunityType;
  final ValueChanged<String> onTypeChanged;
  final String workMode;
  final ValueChanged<String?> onWorkModeChanged;
  final String experienceLevel;
  final ValueChanged<String?> onExperienceChanged;
  final String paymentType;
  final ValueChanged<String> onPaymentChanged;
  final DateTime? deadline;
  final VoidCallback onPickDeadline;

  final XFile? logoFile;
  final XFile? thumbnailFile;
  final VoidCallback onPickLogo;
  final VoidCallback onPickThumbnail;

  final List<XFile> documentFiles;
  final VoidCallback onPickDocuments;
  final ValueChanged<XFile> onRemoveDocument;

  final bool submitting;
  final VoidCallback onSubmit;
  final VoidCallback onSaveDraft;

  const _FormContent({
    required this.formKey,
    required this.isDesktop,
    required this.titleCtrl,
    required this.companyCtrl,
    required this.descQuillController,
    required this.locationCtrl,
    required this.openingsCtrl,
    required this.salaryMinCtrl,
    required this.salaryMaxCtrl,
    required this.compensationCtrl,
    required this.durationCtrl,
    required this.stipendCtrl,
    required this.requirementsCtrl,
    required this.skillsCtrl,
    required this.perksCtrl,
    required this.attachmentsCtrl,
    required this.opportunityType,
    required this.onTypeChanged,
    required this.workMode,
    required this.onWorkModeChanged,
    required this.experienceLevel,
    required this.onExperienceChanged,
    required this.paymentType,
    required this.onPaymentChanged,
    required this.deadline,
    required this.onPickDeadline,
    required this.logoFile,
    required this.thumbnailFile,
    required this.onPickLogo,
    required this.onPickThumbnail,
    required this.documentFiles,
    required this.onPickDocuments,
    required this.onRemoveDocument,
    required this.submitting,
    required this.onSubmit,
    required this.onSaveDraft,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            runSpacing: 12,
            children: [
              SizedBox(
                width: isDesktop ? 640 : double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Create New Listing',
                        style: TextStyle(
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            fontSize: 28)),
                    SizedBox(height: 4),
                    Text(
                      "Fill in the dossier details to broadcast this opportunity to the network.",
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              // Container(
              //   padding:
              //   const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              //   decoration: BoxDecoration(
              //     color: AppColors.containerTeal,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: AppColors.primaryFixedDim),
              //   ),
              //   child: const Row(
              //     mainAxisSize: MainAxisSize.min,
              //     children: [
              //       Icon(Icons.info_outline,
              //           color: AppColors.primary, size: 18),
              //       SizedBox(width: 8),
              //       Text('8 of 10 Service Posts Remaining',
              //           style: TextStyle(
              //               fontWeight: FontWeight.w600,
              //               color: AppColors.primary,
              //               fontSize: 13)),
              //     ],
              //   ),
              // ),
            ],
          ),
          const SizedBox(height: 16),
          const _JumpToNav(),
          const SizedBox(height: 24),
          LayoutBuilder(builder: (context, constraints) {
            final fields = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  label: '01. IDENTITY & CONTEXT',
                  children: [
                    _ResponsiveRow(children: [
                      _LabeledField(
                        label: 'JOB TITLE *',
                        child: TextFormField(
                          controller: titleCtrl,
                          decoration: const InputDecoration(
                              hintText: 'e.g. Senior Strategy Director'),
                          validator: _required,
                        ),
                      ),
                      _LabeledField(
                        label: 'COMPANY NAME *',
                        child: TextFormField(
                          controller: companyCtrl,
                          decoration: const InputDecoration(
                              hintText: 'Organization Name'),
                          validator: _required,
                        ),
                      ),
                    ]),
                    _LabeledField(
                      label: 'JOB DESCRIPTION & RESPONSIBILITIES *',
                      child: _buildQuillField(
                        controller: descQuillController,
                        hint:
                        'Describe the core mission and daily impact of this role...',
                        height: 200,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  label: '02. LOGISTICS & TERMS',
                  children: [
                    _ResponsiveRow(children: [
                      _LabeledField(
                        label: 'OPPORTUNITY TYPE',
                        child: _SegmentedToggle(
                          value: opportunityType,
                          options: const {
                            'job': 'Job',
                            'internship': 'Internship'
                          },
                          onChanged: onTypeChanged,
                        ),
                      ),
                      _LabeledField(
                        label: 'WORK MODE',
                        child: DropdownButtonFormField<String>(
                          value: workMode,
                          items: const ['Remote', 'On-site', 'Hybrid']
                              .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: onWorkModeChanged,
                        ),
                      ),
                    ]),
                    _ResponsiveRow(flexRatios: const [2, 1], children: [
                      _LabeledField(
                        label: 'LOCATION *',
                        child: TextFormField(
                          controller: locationCtrl,
                          decoration: const InputDecoration(
                            hintText: "City, Country or 'Global'",
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          validator: _required,
                        ),
                      ),
                      _LabeledField(
                        label: 'OPENINGS',
                        child: TextFormField(
                          controller: openingsCtrl,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ]),
                    if (opportunityType == 'internship')
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.outlineVariant),
                        ),
                        child: _ResponsiveRow(children: [
                          _LabeledField(
                            label: 'DURATION (MONTHS)',
                            child: TextFormField(
                              controller: durationCtrl,
                              decoration: const InputDecoration(
                                  hintText: 'e.g. 3-6 months',
                                  fillColor: Colors.white),
                            ),
                          ),
                          _LabeledField(
                            label: 'STIPEND AMOUNT',
                            child: TextFormField(
                              controller: stipendCtrl,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  hintText: 'e.g. 2000',
                                  fillColor: Colors.white),
                            ),
                          ),
                        ]),
                      ),
                    _ResponsiveRow(children: [
                      _LabeledField(
                        label: 'EXPERIENCE LEVEL',
                        child: DropdownButtonFormField<String>(
                          value: experienceLevel,
                          items: const [
                            'Entry Level',
                            'Mid-Level',
                            'Senior',
                            'Executive'
                          ]
                              .map((e) =>
                              DropdownMenuItem(value: e, child: Text(e)))
                              .toList(),
                          onChanged: onExperienceChanged,
                        ),
                      ),
                      _LabeledField(
                        label: 'APPLICATION DEADLINE *',
                        child: InkWell(
                          onTap: onPickDeadline,
                          child: InputDecorator(
                            decoration: const InputDecoration(),
                            child: Text(
                              deadline == null
                                  ? 'Select a date'
                                  : '${deadline!.year}-${deadline!.month.toString().padLeft(2, '0')}-${deadline!.day.toString().padLeft(2, '0')}',
                              style: TextStyle(
                                color: deadline == null
                                    ? AppColors.onSurfaceVariant
                                    : AppColors.onSurface,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  label: '03. COMPENSATION STRUCTURE',
                  children: [
                    _ResponsiveRow(children: [
                      _LabeledField(
                        label: 'PAYMENT TYPE',
                        child: Row(
                          children: [
                            Radio<String>(
                              value: 'free',
                              groupValue: paymentType,
                              activeColor: AppColors.primary,
                              onChanged: (v) => onPaymentChanged(v!),
                            ),
                            const Text('Free / Unpaid'),
                            const SizedBox(width: 12),
                            Radio<String>(
                              value: 'paid',
                              groupValue: paymentType,
                              activeColor: AppColors.primary,
                              onChanged: (v) => onPaymentChanged(v!),
                            ),
                            const Text('Paid Professional'),
                          ],
                        ),
                      ),
                      _ResponsiveRow(children: [
                        _LabeledField(
                          label: 'MIN SALARY',
                          child: TextFormField(
                            controller: salaryMinCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                            const InputDecoration(hintText: '\$ Min'),
                          ),
                        ),
                        _LabeledField(
                          label: 'MAX SALARY',
                          child: TextFormField(
                            controller: salaryMaxCtrl,
                            keyboardType: TextInputType.number,
                            decoration:
                            const InputDecoration(hintText: '\$ Max'),
                          ),
                        ),
                      ]),
                    ]),
                    _LabeledField(
                      label: 'COMPENSATION DETAILS (OPTIONAL)',
                      child: TextFormField(
                        controller: compensationCtrl,
                        decoration: const InputDecoration(
                            hintText:
                            'e.g. Equity, Performance Bonuses, Relocation package'),
                      ),
                    ),
                    _LabeledField(
                      label: 'PERKS (OPTIONAL)',
                      child: TextFormField(
                        controller: perksCtrl,
                        decoration: const InputDecoration(
                            hintText:
                            'e.g. Health insurance, WFH stipend, Learning budget'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  label: '04. REQUIREMENTS & SKILLS',
                  children: [
                    _LabeledField(
                      label: 'REQUIREMENTS (COMMA SEPARATED)',
                      child: TextFormField(
                        controller: requirementsCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            hintText:
                            "e.g. 5+ years experience, Bachelor's degree, Portfolio required"),
                      ),
                    ),
                    _LabeledField(
                      label: 'SKILLS (COMMA SEPARATED)',
                      child: TextFormField(
                        controller: skillsCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                            hintText: 'e.g. Flutter, Dart, REST APIs, Figma'),
                      ),
                    ),
                    _LabeledField(
                      label: 'ADDITIONAL ATTACHMENTS / NOTES (OPTIONAL)',
                      child: TextFormField(
                        controller: attachmentsCtrl,
                        decoration: const InputDecoration(
                            hintText:
                            'Links or notes about supporting materials'),
                      ),
                    ),
                  ],
                ),
              ],
            );

            final sidePanel = Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionCard(
                  label: '05. BRAND ASSETS & DOCUMENTS',
                  children: [
                    const Text('ORGANIZATION LOGO',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _UploadBox(
                      icon: Icons.upload_outlined,
                      caption: 'PNG/SVG',
                      height: 96,
                      width: 96,
                      file: logoFile,
                      onTap: onPickLogo,
                    ),
                    const SizedBox(height: 16),
                    const Text('LISTING THUMBNAIL',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    _UploadBox(
                      icon: Icons.image_outlined,
                      caption: 'Upload Hero Image',
                      subCaption: '1200 x 630 px recommended',
                      height: 160,
                      width: double.infinity,
                      file: thumbnailFile,
                      onTap: onPickThumbnail,
                    ),
                    const SizedBox(height: 16),
                    const Text('SUPPORTING DOCUMENTS',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: onPickDocuments,
                      icon: const Icon(Icons.attach_file, size: 18),
                      label: const Text('Add documents'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: const BorderSide(color: AppColors.secondary),
                      ),
                    ),
                    if (documentFiles.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      ...documentFiles.map((f) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.insert_drive_file_outlined,
                            color: AppColors.outline),
                        title: Text(f.name,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 13)),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          onPressed: () => onRemoveDocument(f),
                        ),
                      )),
                    ],
                  ],
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: submitting ? null : onSubmit,
                          icon: submitting
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                              : const Icon(Icons.send, size: 18),
                          label: Text(
                            submitting ? 'Posting...' : 'Post Opportunity',
                            style:
                            const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: submitting ? null : onSaveDraft,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.secondary,
                            side: const BorderSide(color: AppColors.secondary),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Save as Draft',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'By posting, you agree to the Serene Commerce Professional Conduct Guidelines.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Text('Post Integrity Score',
                              style: TextStyle(fontWeight: FontWeight.w500)),
                          Text('92%',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.92,
                          minHeight: 4,
                          backgroundColor: AppColors.outlineVariant,
                          valueColor: const AlwaysStoppedAnimation(
                              AppColors.primary),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Include specific salary data to reach 100% visibility.',
                        style: TextStyle(
                            fontSize: 11, color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            );

            if (constraints.maxWidth >= 900) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: fields),
                  const SizedBox(width: 24),
                  Expanded(flex: 1, child: sidePanel),
                ],
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                fields,
                const SizedBox(height: 24),
                sidePanel,
                const SizedBox(height: 24),
              ],
            );
          }),
        ],
      ),
    );
  }

  static String? _required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'Required' : null;

  /// Rich-text (Quill) editor used for the Job Description field — same
  /// structure/behavior as the Short Summary field on the Create
  /// Training screen (toolbar + bordered editor area).
  Widget _buildQuillField({
    required QuillController controller,
    required String hint,
    double height = 200,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.outlineVariant),
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
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
          Divider(height: 1, thickness: 1, color: AppColors.outlineVariant),
          Container(
            height: height,
            padding: const EdgeInsets.all(8.0),
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

/// ---------------------------------------------------------------------
/// SMALL REUSABLE PIECES
/// ---------------------------------------------------------------------
class _JumpToNav extends StatelessWidget {
  const _JumpToNav();

  @override
  Widget build(BuildContext context) {
    const items = [
      '01 Identity',
      '02 Logistics',
      '03 Compensation',
      '04 Requirements',
      '05 Assets'
    ];
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final active = i == 0;
          return Chip(
            label: Text(items[i],
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: active
                        ? AppColors.onSecondaryContainer
                        : AppColors.onSurfaceVariant)),
            backgroundColor: active
                ? AppColors.secondaryContainer
                : AppColors.surfaceContainer,
            padding: const EdgeInsets.symmetric(horizontal: 4),
            side: BorderSide.none,
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _SectionCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(width: 4, height: 16, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                      color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 16),
          ..._interleave(children, const SizedBox(height: 20)),
        ],
      ),
    );
  }

  List<Widget> _interleave(List<Widget> items, Widget separator) {
    final result = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      result.add(items[i]);
      if (i != items.length - 1) result.add(separator);
    }
    return result;
  }
}

class _ResponsiveRow extends StatelessWidget {
  final List<Widget> children;
  final List<int>? flexRatios;
  const _ResponsiveRow({required this.children, this.flexRatios});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.maxWidth >= 480) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < children.length; i++) ...[
              Expanded(
                flex: flexRatios != null ? flexRatios![i] : 1,
                child: children[i],
              ),
              if (i != children.length - 1) const SizedBox(width: 16),
            ],
          ],
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            children[i],
            if (i != children.length - 1) const SizedBox(height: 16),
          ],
        ],
      );
    });
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class _SegmentedToggle extends StatelessWidget {
  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  const _SegmentedToggle(
      {required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Row(
        children: options.entries.map((e) {
          final active = e.key == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: active
                      ? [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 4)
                  ]
                      : null,
                ),
                child: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: active
                        ? AppColors.primary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _UploadBox extends StatelessWidget {
  final IconData icon;
  final String caption;
  final String? subCaption;
  final double height;
  final double width;
  final XFile? file;
  final VoidCallback onTap;
  const _UploadBox({
    required this.icon,
    required this.caption,
    this.subCaption,
    required this.height,
    required this.width,
    required this.file,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: height,
        width: width,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant, width: 2),
        ),
        child: file != null
            ? _FilePreview(file: file!)
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.outline),
            const SizedBox(height: 6),
            Text(caption,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurfaceVariant)),
            if (subCaption != null)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(subCaption!,
                    style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.outlineVariant)),
              ),
          ],
        ),
      ),
    );
  }
}

/// Shows a picked image preview cross-platform.
class _FilePreview extends StatelessWidget {
  final XFile file;
  const _FilePreview({required this.file});

  @override
  Widget build(BuildContext context) {
    if (kIsWebPlatform) {
      return FutureBuilder<List<int>>(
        future: file.readAsBytes(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Image.memory(
            Uint8List.fromList(snapshot.data!),
            fit: BoxFit.cover,
          );
        },
      );
    }
    return Image.file(File(file.path), fit: BoxFit.cover);
  }
}

/// ---------------------------------------------------------------------
/// SUCCESS DIALOG
/// ---------------------------------------------------------------------
class _SuccessDialog extends StatelessWidget {
  final String? jobId;
  const _SuccessDialog({this.jobId});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(height: 6, color: AppColors.primary),
            Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                        color: AppColors.containerTeal,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.check_circle,
                        color: AppColors.primary, size: 36),
                  ),
                  const SizedBox(height: 16),
                  const Text('Job Posted Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          fontSize: 22)),
                  const SizedBox(height: 8),
                  Text(
                    jobId != null
                        ? 'Your listing (ID #$jobId) is now live and being distributed to the strategic partner network.'
                        : 'Your listing is now live and being distributed to the strategic partner network.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('View Listing',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.surfaceContainer,
                        foregroundColor: AppColors.onSurfaceVariant,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Post Another',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}