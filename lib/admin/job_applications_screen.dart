import 'package:flutter/material.dart';

import '../Database/Database.dart';

/// ---------------------------------------------------------------------
/// STATUS MAPPING
///
/// jobresponse.php stores `response.status` as a numeric string but the
/// PHP never spells out what each number means — the only clue is that
/// jobs.php sums statuses 0..6 into `count_applied`. This map is a BEST
/// GUESS based on the UI's own pipeline stages (Applied -> ... ->
/// Rejected). Please confirm against your `response` table / backend
/// logic and adjust the codes here — everything else in this file reads
/// status through this single map, so it only needs fixing in one place.
/// ---------------------------------------------------------------------
class ApplicantStatus {
  static const applied = '0';
  static const screening = '1';
  static const shortlisted = '2';
  static const interview = '3';
  static const offer = '4';
  static const hired = '5';
  static const rejected = '6';

  static String label(String code) {
    switch (code) {
      case screening:
        return 'In Screening';
      case shortlisted:
        return 'Shortlisted';
      case interview:
        return 'Interview Scheduled';
      case offer:
        return 'Offer Sent';
      case hired:
        return 'Hired';
      case rejected:
        return 'Rejected';
      case applied:
      default:
        return 'Pending Review';
    }
  }

  static Color color(String code) {
    switch (code) {
      case screening:
        return const Color(0xFF006565);
      case shortlisted:
      case interview:
        return const Color(0xFF6750A4);
      case offer:
      case hired:
        return const Color(0xFF2E7D32);
      case rejected:
        return const Color(0xFF6E7979);
      case applied:
      default:
        return const Color(0xFFB45309);
    }
  }

  static bool isClosed(String code) => code == rejected;
}

/// ---------------------------------------------------------------------
/// DATA MODEL — maps a single item from jobresponse.php's
/// data.responses[] array.
/// ---------------------------------------------------------------------
class JobApplicant {
  final String id;
  final String vendorId;
  final String message;
  final String statusCode;
  final String createdDate;
  final String name;
  final String email;
  final String avatarUrl;
  final List<String> skills;
  final String cvUrl;
  final String interviewSchedule;

  const JobApplicant({
    required this.id,
    required this.vendorId,
    required this.message,
    required this.statusCode,
    required this.createdDate,
    required this.name,
    required this.email,
    required this.avatarUrl,
    required this.skills,
    required this.cvUrl,
    required this.interviewSchedule,
  });

  factory JobApplicant.fromJson(Map<String, dynamic> json) {
    final vendorInfo = json['vendor_info'] is Map
        ? Map<String, dynamic>.from(json['vendor_info'] as Map)
        : <String, dynamic>{};
    final seekerInfo = json['seeker_info'] is Map
        ? Map<String, dynamic>.from(json['seeker_info'] as Map)
        : <String, dynamic>{};
    final rawSkills = json['skills'];

    final name = (vendorInfo['company_name'] ??
        seekerInfo['name'] ??
        seekerInfo['full_name'] ??
        'Candidate')
        .toString();

    return JobApplicant(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      statusCode: json['status']?.toString() ?? ApplicantStatus.applied,
      createdDate: json['created_date']?.toString() ?? '',
      name: name,
      email: vendorInfo['email']?.toString() ?? '',
      avatarUrl: vendorInfo['profile_pic']?.toString() ?? '',
      skills: rawSkills is List
          ? rawSkills.map((e) => e.toString().trim()).where((s) => s.isNotEmpty).toList()
          : const [],
      cvUrl: json['cv_url']?.toString() ?? '',
      interviewSchedule: json['interview_schedule']?.toString() ?? '',
    );
  }

  JobApplicant copyWith({String? statusCode}) {
    return JobApplicant(
      id: id,
      vendorId: vendorId,
      message: message,
      statusCode: statusCode ?? this.statusCode,
      createdDate: createdDate,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      skills: skills,
      cvUrl: cvUrl,
      interviewSchedule: interviewSchedule,
    );
  }

  String get appliedDateLabel {
    final parsed = DateTime.tryParse(createdDate);
    if (parsed == null) return createdDate;
    final days = DateTime.now().difference(parsed).inDays;
    if (days <= 0) return 'Applied today';
    if (days == 1) return 'Applied 1 day ago';
    if (days < 14) return 'Applied $days days ago';
    final weeks = (days / 7).floor();
    return 'Applied $weeks week${weeks == 1 ? '' : 's'} ago';
  }
}

class JobApplicationsScreen extends StatefulWidget {
  final String jobId;
  final String? jobTitle;
  final String? jobLocation;

  const JobApplicationsScreen({
    super.key,
    required this.jobId,
    this.jobTitle,
    this.jobLocation,
  });

  @override
  State<JobApplicationsScreen> createState() => _JobApplicationsScreenState();
}

class _JobApplicationsScreenState extends State<JobApplicationsScreen> {
  final Database _db = Database();

  bool _isLoading = true;
  String? _error;
  String? _jobTitleFromApi;
  List<JobApplicant> _applicants = [];

  int _page = 1;
  int _lastPage = 1;
  int _totalResponses = 0;

  JobApplicant? _selectedApplicant;
  bool _isScheduleModalVisible = false;
  bool _isContactModalVisible = false;
  bool _isCvModalVisible = false;

  String get _jobTitle => widget.jobTitle ?? _jobTitleFromApi ?? 'Job Posting';

  @override
  void initState() {
    super.initState();
    _fetchApplicants();
  }

  Future<void> _fetchApplicants({bool append = false}) async {
    setState(() => _isLoading = true);

    final result = await _db.getJobResponses(jobId: widget.jobId, page: _page);

    if (!mounted) return;

    if (result['success'] == true) {
      final data = Map<String, dynamic>.from(result['data'] as Map? ?? {});
      final rawResponses = (data['responses'] as List?) ?? [];
      final pagination = Map<String, dynamic>.from(data['pagination'] as Map? ?? {});

      final fetched = rawResponses
          .map((e) => JobApplicant.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      setState(() {
        _applicants = append ? [..._applicants, ...fetched] : fetched;
        _jobTitleFromApi = data['job_title']?.toString();
        _totalResponses = (pagination['total_responses'] as num?)?.toInt() ?? fetched.length;
        _lastPage = (pagination['total_pages'] as num?)?.toInt() ?? 1;
        _error = null;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error = result['message']?.toString() ?? 'Failed to load candidates';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_page >= _lastPage || _isLoading) return;
    _page++;
    await _fetchApplicants(append: true);
  }

  void _toggleSchedule({JobApplicant? applicant}) {
    setState(() {
      _selectedApplicant = applicant ?? _selectedApplicant;
      _isScheduleModalVisible = !_isScheduleModalVisible;
    });
  }

  void _toggleContact({JobApplicant? applicant}) {
    setState(() {
      _selectedApplicant = applicant ?? _selectedApplicant;
      _isContactModalVisible = !_isContactModalVisible;
    });
  }

  void _toggleCv({JobApplicant? applicant}) {
    setState(() {
      _selectedApplicant = applicant ?? _selectedApplicant;
      _isCvModalVisible = !_isCvModalVisible;
    });
  }

  /// Handles a status-dropdown change for a given candidate.
  /// "Interview" is special-cased to open the scheduling modal instead of
  /// immediately posting a status update, matching the original UI intent.
  Future<void> _handleStatusChange(JobApplicant applicant, String value) async {
    if (value == ApplicantStatus.interview) {
      _toggleSchedule(applicant: applicant);
      return;
    }
    await _updateStatus(applicant, value);
  }

  Future<void> _updateStatus(JobApplicant applicant, String statusCode) async {
    final result = await _db.updateApplicantStatus(
      vendorId: applicant.vendorId,
      itemId: widget.jobId,
      status: statusCode,
    );

    if (!mounted) return;

    if (result['success'] == true) {
      setState(() {
        _applicants = _applicants
            .map((a) => a.id == applicant.id ? a.copyWith(statusCode: statusCode) : a)
            .toList();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to ${ApplicantStatus.label(statusCode)}'),
          backgroundColor: const Color(0xFF006565),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Failed to update status'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    }
  }

  Future<void> _confirmSchedule({
    required String date,
    required String time,
    required String mode,
    required String message,
  }) async {
    final applicant = _selectedApplicant;
    if (applicant == null) return;

    final schedule = '$date $time:00';
    final result = await _db.scheduleInterview(
      vendorId: applicant.vendorId,
      itemId: widget.jobId,
      schedule: schedule,
      platform: mode,
      message: message,
    );

    if (!mounted) return;
    _toggleSchedule();

    if (result['success'] == true) {
      await _updateStatus(applicant, ApplicantStatus.interview);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Interview Invitation Sent!'),
          backgroundColor: Color(0xFF006565),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']?.toString() ?? 'Failed to schedule interview'),
          backgroundColor: const Color(0xFFBA1A1A),
        ),
      );
    }
  }

  Future<void> _sendMessage(String message) async {
    final applicant = _selectedApplicant;
    if (applicant == null) return;

    final result = await _db.sendMessage(vendorId: applicant.vendorId, message: message);

    if (!mounted) return;
    _toggleContact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result['success'] == true
            ? 'Message sent to ${applicant.name}'
            : (result['message']?.toString() ?? 'Failed to send message')),
        backgroundColor:
        result['success'] == true ? const Color(0xFF006565) : const Color(0xFFBA1A1A),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvoked: (didPop) {
        if (_isScheduleModalVisible || _isContactModalVisible || _isCvModalVisible) {
          setState(() {
            _isScheduleModalVisible = false;
            _isContactModalVisible = false;
            _isCvModalVisible = false;
          });
        }
      },
      child: Scaffold(
        appBar: _buildTopAppBar(),
        body: SafeArea(
          child: RefreshIndicator(
            color: const Color(0xFF006565),
            onRefresh: () {
              _page = 1;
              return _fetchApplicants();
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  JobContextHeader(
                    jobTitle: _jobTitle,
                    jobLocation: widget.jobLocation ?? '',
                  ),
                  const SizedBox(height: 24),
                  _buildPipelineHeader(),
                  const SizedBox(height: 16),
                  _buildPipelineBody(),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: const SizedBox.shrink(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      ),
    );
  }

  Widget _buildPipelineHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Candidate Pipeline ($_totalResponses)',
          style: const TextStyle(
            fontFamily: 'Manrope',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.filter_list),
              style: IconButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBDC9C8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search),
              style: IconButton.styleFrom(
                side: const BorderSide(color: Color(0xFFBDC9C8)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPipelineBody() {
    if (_isLoading && _applicants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator(color: Color(0xFF006565))),
      );
    }

    if (_error != null && _applicants.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFBA1A1A), size: 32),
            const SizedBox(height: 12),
            Text(_error!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: Color(0xFF3E4949))),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                _page = 1;
                _fetchApplicants();
              },
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_applicants.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(
          child: Text(
            'No candidates have applied yet.',
            style: TextStyle(fontSize: 13, color: Color(0xFF3E4949)),
          ),
        ),
      );
    }

    return Column(
      children: [
        Column(
          children: [
            for (final applicant in _applicants) ...[
              CandidateCard(
                applicant: applicant,
                onViewCv: () => _toggleCv(applicant: applicant),
                onContact: () => _toggleContact(applicant: applicant),
                onStatusChange: (value) => _handleStatusChange(applicant, value),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
        if (_page < _lastPage)
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _loadMore,
              child: _isLoading
                  ? const SizedBox(
                  width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Load more candidates'),
            ),
          ),
        _ScheduleModal(
          isVisible: _isScheduleModalVisible,
          candidateName: _selectedApplicant?.name ?? 'Candidate',
          onClose: () => _toggleSchedule(),
          onConfirm: _confirmSchedule,
        ),
        _ContactModal(
          isVisible: _isContactModalVisible,
          candidate: _selectedApplicant?.name ?? 'Candidate',
          candidateEmail: _selectedApplicant?.email ?? '',
          onClose: () => _toggleContact(),
          onSend: _sendMessage,
        ),
        _CvModal(
          isVisible: _isCvModalVisible,
          candidate: _selectedApplicant?.name ?? 'Candidate',
          cvUrl: _selectedApplicant?.cvUrl ?? '',
          skills: _selectedApplicant?.skills ?? const [],
          onClose: () => _toggleCv(),
        ),
      ],
    );
  }

  PreferredSizeWidget _buildTopAppBar() {
    return AppBar(
      title: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFB0EEED),
            child: Icon(Icons.person, color: Color(0xFF006565)),
          ),
          const SizedBox(width: 12),
          const Text(
            'Serene Recruiter',
            style: TextStyle(
              fontFamily: 'Manrope',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF006565),
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings),
          color: const Color(0xFF006565),
          style: IconButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFBDC9C8)),
      ),
    );
  }
}

class JobContextHeader extends StatelessWidget {
  final String jobTitle;
  final String jobLocation;

  const JobContextHeader({super.key, required this.jobTitle, required this.jobLocation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVE RECRUITMENT',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.05,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            jobTitle,
            style: const TextStyle(
              fontFamily: 'Manrope',
              fontSize: 28,
              fontWeight: FontWeight.w600,
              color: Color(0xFF006565),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              if (jobLocation.isNotEmpty) ...[
                const Icon(Icons.location_on, size: 18, color: Color(0xFF3E4949)),
                const SizedBox(width: 4),
                Text(jobLocation, style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949))),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(color: Color(0xFF6E7979), shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
              ],
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(color: Color(0xFF006565), shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              const Text(
                'Active',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF006565)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFBDC9C8)),
                    foregroundColor: const Color(0xFF006565),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Edit Job',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('Share Listing',
                      style: TextStyle(fontFamily: 'Manrope', fontSize: 14, fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CandidateCard extends StatelessWidget {
  final JobApplicant applicant;
  final VoidCallback onViewCv;
  final VoidCallback onContact;
  final ValueChanged<String> onStatusChange;

  const CandidateCard({
    super.key,
    required this.applicant,
    required this.onViewCv,
    required this.onContact,
    required this.onStatusChange,
  });

  @override
  Widget build(BuildContext context) {
    final isRejected = ApplicantStatus.isClosed(applicant.statusCode);
    final statusColor = ApplicantStatus.color(applicant.statusCode);
    final statusLabel = ApplicantStatus.label(applicant.statusCode);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isRejected ? const Color(0xFFF9F9F9) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: const Color(0xFFE2E2E2),
                  image: applicant.avatarUrl.isNotEmpty
                      ? DecorationImage(
                      image: NetworkImage(applicant.avatarUrl), fit: BoxFit.cover)
                      : null,
                ),
                child: applicant.avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Color(0xFF6E7979))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      applicant.name,
                      style: const TextStyle(
                          fontFamily: 'Manrope', fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(applicant.appliedDateLabel,
                        style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949))),
                    if (applicant.skills.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: applicant.skills.map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(skill,
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF454747))),
                          );
                        }).toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ActionButton(icon: Icons.description, label: 'View CV', onPressed: onViewCv),
                        const SizedBox(width: 16),
                        _ActionButton(icon: Icons.mail_outline, label: 'Contact', onPressed: onContact),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFBDC9C8), height: 1),
          const SizedBox(height: 16),
          if (isRejected)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Not a fit for this role',
                  style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Color(0xFF3E4949)),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(statusLabel,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: statusColor)),
                  ],
                ),
              ],
            )
          else
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    value: applicant.statusCode,
                    items: const [
                      DropdownMenuItem(value: ApplicantStatus.applied, child: Text('Pending Review')),
                      DropdownMenuItem(value: ApplicantStatus.screening, child: Text('Screening')),
                      DropdownMenuItem(value: ApplicantStatus.shortlisted, child: Text('Shortlisted')),
                      DropdownMenuItem(value: ApplicantStatus.interview, child: Text('Schedule Interview')),
                      DropdownMenuItem(value: ApplicantStatus.offer, child: Text('Send Offer')),
                      DropdownMenuItem(value: ApplicantStatus.hired, child: Text('Hired')),
                      DropdownMenuItem(value: ApplicantStatus.rejected, child: Text('Rejected')),
                    ],
                    onChanged: (value) {
                      if (value != null) onStatusChange(value);
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF4F3F3),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF006565)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                    icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text(statusLabel,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: statusColor)),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF006565)),
          const SizedBox(width: 4),
          Text(label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF006565))),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------
// Modals — now stateful so they can collect input and hand it back to
// the parent screen, which is the one that actually calls the API.
// ---------------------------------------------------------------------

class _ScheduleModal extends StatefulWidget {
  final bool isVisible;
  final String candidateName;
  final VoidCallback onClose;
  final Future<void> Function({
  required String date,
  required String time,
  required String mode,
  required String message,
  }) onConfirm;

  const _ScheduleModal({
    required this.isVisible,
    required this.candidateName,
    required this.onClose,
    required this.onConfirm,
  });

  @override
  State<_ScheduleModal> createState() => _ScheduleModalState();
}

class _ScheduleModalState extends State<_ScheduleModal> {
  final _dateController = TextEditingController(text: '2026-07-15');
  final _timeController = TextEditingController(text: '14:30');
  String _mode = 'Remote (Video)';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.tryParse(_dateController.text) ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      _dateController.text =
      '${picked.year.toString().padLeft(4, '0')}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (picked != null) {
      _timeController.text =
      '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Schedule Interview',
                    style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.w600)),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 4),
            Text('with ${widget.candidateName}',
                style: const TextStyle(fontSize: 13, color: Color(0xFF3E4949))),
            const SizedBox(height: 16),
            const Text('Select Date',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Color(0xFF3E4949))),
            const SizedBox(height: 4),
            TextField(
              readOnly: true,
              onTap: _pickDate,
              controller: _dateController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F3F3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                suffixIcon: const Icon(Icons.calendar_today, size: 20),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Time',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05,
                              color: Color(0xFF3E4949))),
                      const SizedBox(height: 4),
                      TextField(
                        readOnly: true,
                        onTap: _pickTime,
                        controller: _timeController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF4F3F3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          suffixIcon: const Icon(Icons.access_time, size: 20),
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
                      const Text('Mode',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.05,
                              color: Color(0xFF3E4949))),
                      const SizedBox(height: 4),
                      DropdownButtonFormField<String>(
                        value: _mode,
                        items: const [
                          DropdownMenuItem(value: 'Remote (Video)', child: Text('Remote (Video)')),
                          DropdownMenuItem(
                              value: 'In-person (NY Office)', child: Text('In-person (NY Office)')),
                          DropdownMenuItem(value: 'Phone Call', child: Text('Phone Call')),
                        ],
                        onChanged: (v) => setState(() => _mode = v ?? _mode),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: const Color(0xFFF4F3F3),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                color: const Color(0xFFF4F3F3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Invitation will include the link to the company\'s serene video platform.',
                style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBDC9C8)),
                      foregroundColor: const Color(0xFF006565),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                      setState(() => _isSubmitting = true);
                      await widget.onConfirm(
                        date: _dateController.text,
                        time: _timeController.text,
                        mode: _mode,
                        message:
                        'You have been invited to interview for this role. Please confirm your availability.',
                      );
                      if (mounted) setState(() => _isSubmitting = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Send Invite'),
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

class _ContactModal extends StatefulWidget {
  final bool isVisible;
  final String candidate;
  final String candidateEmail;
  final VoidCallback onClose;
  final Future<void> Function(String message) onSend;

  const _ContactModal({
    required this.isVisible,
    required this.candidate,
    required this.candidateEmail,
    required this.onClose,
    required this.onSend,
  });

  @override
  State<_ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<_ContactModal> {
  late TextEditingController _messageController;
  String _template = 'Initial Reach Out';
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController(
      text:
      'Hello ${widget.candidate}, I\'ve reviewed your profile and would love to discuss your experience in more detail...',
    );
  }

  @override
  void didUpdateWidget(covariant _ContactModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.candidate != widget.candidate) {
      _messageController.text =
      'Hello ${widget.candidate}, I\'ve reviewed your profile and would love to discuss your experience in more detail...';
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Message Candidate',
                    style: TextStyle(
                        fontFamily: 'Manrope',
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF006565))),
                IconButton(onPressed: widget.onClose, icon: const Icon(Icons.close)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('To',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Color(0xFF3E4949))),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: const Color(0xFFF4F3F3), borderRadius: BorderRadius.circular(8)),
              child: Text(widget.candidateEmail.isNotEmpty
                  ? '${widget.candidate} <${widget.candidateEmail}>'
                  : widget.candidate),
            ),
            const SizedBox(height: 16),
            const Text('Template',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Color(0xFF3E4949))),
            const SizedBox(height: 4),
            DropdownButtonFormField<String>(
              value: _template,
              items: const [
                DropdownMenuItem(value: 'Initial Reach Out', child: Text('Initial Reach Out')),
                DropdownMenuItem(value: 'Follow-up Question', child: Text('Follow-up Question')),
                DropdownMenuItem(value: 'Schedule Availability', child: Text('Schedule Availability')),
              ],
              onChanged: (v) => setState(() => _template = v ?? _template),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F3F3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
            ),
            const SizedBox(height: 16),
            const Text('Message Body',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.05,
                    color: Color(0xFF3E4949))),
            const SizedBox(height: 4),
            TextField(
              maxLines: 6,
              controller: _messageController,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF4F3F3),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                hintText: 'Write your message here...',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : widget.onClose,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFBDC9C8)),
                      foregroundColor: const Color(0xFF006565),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Discard'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () async {
                      setState(() => _isSubmitting = true);
                      await widget.onSend(_messageController.text);
                      if (mounted) setState(() => _isSubmitting = false);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Text('Send Message'),
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

class _CvModal extends StatelessWidget {
  final bool isVisible;
  final String candidate;
  final String cvUrl;
  final List<String> skills;
  final VoidCallback onClose;

  const _CvModal({
    required this.isVisible,
    required this.candidate,
    required this.cvUrl,
    required this.skills,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.85,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          cvUrl.isNotEmpty ? 'Resume — $candidate' : 'No résumé on file',
                          style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF006565)),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (cvUrl.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            // TODO: open `cvUrl` externally, e.g. via the
                            // url_launcher package:
                            //   launchUrl(Uri.parse(cvUrl));
                            // Not wired up here since url_launcher isn't
                            // yet a dependency of this project.
                          },
                          icon: const Icon(Icons.download, size: 20),
                          color: const Color(0xFF006565),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                  style: IconButton.styleFrom(backgroundColor: const Color(0xFFE2E2E2)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.only(bottom: 16),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF006565), width: 2)),
                        ),
                        child: Text(
                          candidate,
                          style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1C1C)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'SKILLS',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 0.05, color: Color(0xFF1A1C1C)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        skills.isNotEmpty ? skills.join(', ') : 'No skills listed.',
                        style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                      ),
                      const SizedBox(height: 20),
                      if (cvUrl.isEmpty)
                        const Text(
                          'This candidate has not uploaded a résumé yet.',
                          style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                        )
                      else
                        Text(
                          'Full résumé: $cvUrl',
                          style: const TextStyle(fontSize: 13, color: Color(0xFF006565)),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}