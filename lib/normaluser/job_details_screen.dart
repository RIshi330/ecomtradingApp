import 'dart:convert'; // Required for base64 encoding
import 'package:flutter/material.dart';
import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';

/// ============================================================
/// API ENDPOINT
/// ============================================================
const String jobDetailEndpoint = 'new_apis/jobDetailAPI.php';

/// ------------------------------------------------------------
/// MODELS
/// ------------------------------------------------------------
class JobDetailData {
  final String id;
  final String title;
  final String category;
  final String positionLevel;
  final String workType;
  final String workPlace;
  final String expMin;
  final String expMax;
  final String salMin;
  final String salMax;
  final String jobDesc;
  final List<String> skillsRequired;
  final int views;
  final String createdDate;
  final String timeAgo;

  // Vendor / Company Details
  final String vendorId;
  final String vendorName;
  final String companyName;
  final String companyLogo;
  final String vendorBio;

  // Related Opportunities
  final List<RelatedJob> relatedJobs;

  JobDetailData({
    required this.id,
    required this.title,
    required this.category,
    required this.positionLevel,
    required this.workType,
    required this.workPlace,
    required this.expMin,
    required this.expMax,
    required this.salMin,
    required this.salMax,
    required this.jobDesc,
    required this.skillsRequired,
    required this.views,
    required this.createdDate,
    required this.timeAgo,
    required this.vendorId,
    required this.vendorName,
    required this.companyName,
    required this.companyLogo,
    required this.vendorBio,
    required this.relatedJobs,
  });

  factory JobDetailData.fromJson(Map json) {
    final vendorMap = json['vendor'] is Map ? json['vendor'] as Map : {};
    final rawSkills = json['skills_required'] is List ? json['skills_required'] as List : [];
    final rawRelated = json['related_jobs'] is List ? json['related_jobs'] as List : [];

    String displayCompany = 'Company';
    if (vendorMap['company_name']?.toString().trim().isNotEmpty == true) {
      displayCompany = vendorMap['company_name'].toString();
    } else if (vendorMap['name']?.toString().trim().isNotEmpty == true) {
      displayCompany = vendorMap['name'].toString();
    }

    return JobDetailData(
      id: json['id']?.toString() ?? '',
      title: json['job_title']?.toString() ?? 'Untitled Role',
      category: json['job_category']?.toString() ?? 'General',
      positionLevel: json['position_lvl']?.toString() ?? '',
      workType: json['work_type']?.toString() ?? '',
      workPlace: json['work_place']?.toString() ?? '',
      expMin: json['reqd_exp_min']?.toString() ?? '0',
      expMax: json['reqd_exp_max']?.toString() ?? '0',
      salMin: json['sal_min']?.toString() ?? '0',
      salMax: json['sal_max']?.toString() ?? '0',
      jobDesc: json['job_desc']?.toString() ?? 'No detailed description available.',
      skillsRequired: rawSkills.map((e) => e.toString()).toList(),
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      createdDate: json['created_date']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
      vendorId: vendorMap['id']?.toString() ?? '',
      vendorName: vendorMap['name']?.toString() ?? '',
      companyName: displayCompany,
      companyLogo: vendorMap['company_logo']?.toString() ?? '',
      vendorBio: vendorMap['bio']?.toString() ?? '',
      relatedJobs: rawRelated.map((e) => RelatedJob.fromJson(e as Map)).toList(),
    );
  }

  String get salaryRange {
    final minNum = double.tryParse(salMin) ?? 0;
    final maxNum = double.tryParse(salMax) ?? 0;

    if (minNum == 0 && maxNum == 0) return 'Undisclosed';
    if (minNum > 0 && maxNum > 0) return '₹$salMin - ₹$salMax';
    return '₹${minNum > 0 ? salMin : salMax}';
  }

  String get experienceText {
    final minE = double.tryParse(expMin) ?? 0;
    final maxE = double.tryParse(expMax) ?? 0;

    if (minE == 0 && maxE == 0) return 'Freshers / Any';
    if (minE > 0 && maxE > 0) return '$expMin - $expMax Years';
    return '$expMin+ Years';
  }
}

class RelatedJob {
  final String id;
  final String title;
  final String companyName;
  final String companyLogo;
  final String timeAgo;

  RelatedJob({
    required this.id,
    required this.title,
    required this.companyName,
    required this.companyLogo,
    required this.timeAgo,
  });

  factory RelatedJob.fromJson(Map json) {
    return RelatedJob(
      id: json['id']?.toString() ?? '',
      title: json['job_title']?.toString() ?? '',
      companyName: json['company_name']?.toString() ?? 'Company',
      companyLogo: json['company_logo']?.toString() ?? '',
      timeAgo: json['time_ago']?.toString() ?? '',
    );
  }
}

/// ------------------------------------------------------------
/// JOB DETAIL SCREEN
/// ------------------------------------------------------------
class JobDetailScreen extends StatefulWidget {
  final String jobId;
  final String currentUserId; // Pass the active user ID from session/auth

  const JobDetailScreen({
    super.key,
    required this.jobId,
    required this.currentUserId,
  });

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  final Database _db = Database();

  bool _isBookmarked = false;
  bool _isLoading = true;
  String? _errorMessage;
  JobDetailData? _jobDetail;

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  /// Fetch full job details via GET request
  Future<void> _fetchJobDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Encode jobId to base64 to match PHP backend decoding logic
      final encodedJobId = base64Encode(utf8.encode(widget.jobId));

      final result = await _db.getJsonData(
        {},
        endpoint: '$jobDetailEndpoint?id=${Uri.encodeComponent(encodedJobId)}',
      );

      if (result['success'] == true && result['data'] != null) {
        setState(() {
          _jobDetail = JobDetailData.fromJson(result['data'] as Map);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ?? 'Failed to load job details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  /// Submit Job Application via POST request
  Future<bool> _submitApplication(String resumeId) async {
    try {
      final body = {
        'action': 'apply',
        'job_id': widget.jobId,
        'resume_id': resumeId,
        'user_id': widget.currentUserId,
        'vendor_id': UserSessionSet.instance.vendorId,

      };

      final result = await _db.getJsonData(body, endpoint: jobDetailEndpoint);

      if (result['success'] == true) {
        return true;
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result['message']?.toString() ?? 'Application failed.')),
          );
        }
        return false;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 768;

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF3E4949)),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _jobDetail?.title ?? 'Job Opportunity',
          style: const TextStyle(
            color: Color(0xFF1A1C1C),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Color(0xFF3E4949)),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? const Color(0xFF006565) : const Color(0xFF3E4949),
            ),
            onPressed: () {
              setState(() {
                _isBookmarked = !_isBookmarked;
              });
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF006565)))
            : _errorMessage != null
            ? Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
                const SizedBox(height: 12),
                Text(_errorMessage!, textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
                  onPressed: _fetchJobDetails,
                  child: const Text('Retry', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        )
            : Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 896),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroSection(isDesktop),
                      const SizedBox(height: 24),
                      _buildOverviewGrid(isDesktop),
                      const SizedBox(height: 32),
                      const Divider(color: Color(0xFFBDC9C8)),
                      const SizedBox(height: 24),
                      _buildJobDescriptionSection(),
                      const SizedBox(height: 32),
                      if (_jobDetail!.relatedJobs.isNotEmpty) ...[
                        const Divider(color: Color(0xFFBDC9C8)),
                        const SizedBox(height: 24),
                        _buildSimilarOpportunitiesSection(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildStickyBottomBar(context, isDesktop),
            ),
          ],
        ),
      ),
    );
  }

  // --- Header Section ---
  Widget _buildHeroSection(bool isDesktop) {
    final detail = _jobDetail!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3F3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBDC9C8)),
          ),
          child: detail.companyLogo.isNotEmpty
              ? ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              detail.companyLogo,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40, color: Color(0xFF006565)),
            ),
          )
              : const Center(
            child: Icon(
              Icons.business,
              size: 40,
              color: Color(0xFF006565),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3FFFE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      detail.category.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006565),
                      ),
                    ),
                  ),
                  if (detail.positionLevel.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF3E0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        detail.positionLevel.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                detail.title,
                style: TextStyle(
                  fontSize: isDesktop ? 28 : 22,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF1A1C1C),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${detail.companyName}${detail.workPlace.isNotEmpty ? " • ${detail.workPlace}" : ""}',
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF3E4949),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Key Metric Cards Grid ---
  Widget _buildOverviewGrid(bool isDesktop) {
    final detail = _jobDetail!;
    final metrics = [
      {'label': 'WORK TYPE', 'value': detail.workType.isNotEmpty ? detail.workType : 'Full-time', 'icon': Icons.schedule},
      {'label': 'EXPERIENCE', 'value': detail.experienceText, 'icon': Icons.work_history_outlined},
      {'label': 'SALARY', 'value': detail.salaryRange, 'icon': Icons.payments_outlined},
    ];

    if (isDesktop) {
      return Row(
        children: metrics
            .map((m) => Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: _buildMetricCard(m['label'] as String, m['value'] as String, m['icon'] as IconData),
          ),
        ))
            .toList(),
      );
    }

    return Column(
      children: metrics
          .map((m) => Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: _buildMetricCard(m['label'] as String, m['value'] as String, m['icon'] as IconData),
      ))
          .toList(),
    );
  }

  Widget _buildMetricCard(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE3FFFE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF006565), size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF3E4949),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1C1C),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // --- Description & Skills Section ---
  Widget _buildJobDescriptionSection() {
    final detail = _jobDetail!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'About the Role',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
        ),
        const SizedBox(height: 8),
        Text(
          detail.jobDesc,
          style: const TextStyle(fontSize: 15, color: Color(0xFF3E4949), height: 1.5),
        ),
        if (detail.skillsRequired.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'Required Skills',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: detail.skillsRequired
                .map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFE3FFFE),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFBDC9C8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_outline, color: Color(0xFF006565), size: 16),
                  const SizedBox(width: 6),
                  Text(
                    skill,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF006565),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
        if (detail.vendorBio.isNotEmpty) ...[
          const SizedBox(height: 24),
          const Text(
            'About the Recruiter',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF006565)),
          ),
          const SizedBox(height: 8),
          Text(
            detail.vendorBio,
            style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949), fontStyle: FontStyle.italic),
          ),
        ],
      ],
    );
  }

  // --- Related Opportunities Slider ---
  Widget _buildSimilarOpportunitiesSection() {
    final list = _jobDetail!.relatedJobs;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar Opportunities',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: list.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              final item = list[index];
              return InkWell(
                onTap: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => JobDetailScreen(
                        jobId: item.id,
                        currentUserId: widget.currentUserId,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 260,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item.companyName,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item.timeAgo,
                            style: const TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic),
                          ),
                          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF006565)),
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  // --- Fixed Bottom Navigation Bar ---
  Widget _buildStickyBottomBar(BuildContext context, bool isDesktop) {
    final detail = _jobDetail!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFBDC9C8))),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 896),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isDesktop)
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      detail.salaryRange,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Posted ${detail.timeAgo}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              Expanded(
                flex: isDesktop ? 0 : 1,
                child: SizedBox(
                  width: isDesktop ? 220 : double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => _openApplyBottomSheet(context),
                    child: const Text(
                      'Apply Now',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // --- Application Bottom Sheet ---
  void _openApplyBottomSheet(BuildContext context) {
    String selectedResumeId = "1"; // Default resume ID value
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF9F9F9),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Submit Application', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  const Text('SELECT RESUME FROM PROFILE',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 8),
                  RadioListTile<String>(
                    value: "1",
                    groupValue: selectedResumeId,
                    title: const Text('Main_Resume.pdf', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Primary Active Resume', style: TextStyle(fontSize: 12)),
                    activeColor: const Color(0xFF006565),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedResumeId = val);
                    },
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF006565)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancel', style: TextStyle(color: Color(0xFF006565))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: isSubmitting
                              ? null
                              : () async {
                            setModalState(() => isSubmitting = true);
                            final success = await _submitApplication(selectedResumeId);
                            setModalState(() => isSubmitting = false);
                            if (success && mounted) {
                              Navigator.pop(context);
                              _showSuccessToast(context);
                            }
                          },
                          child: isSubmitting
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                              : const Text('Submit Application'),
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

  void _showSuccessToast(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.greenAccent),
            SizedBox(width: 12),
            Text('Application submitted successfully!'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF2F3131),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        margin: const EdgeInsets.only(bottom: 80, left: 20, right: 20),
      ),
    );
  }
}