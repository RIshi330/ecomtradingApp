import 'package:flutter/material.dart';

class AppliedJobsScreen extends StatefulWidget {
  const AppliedJobsScreen({super.key});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  String selectedFilter = 'All';

  final List<JobApplication> applications = [
    JobApplication(
      id: '1',
      companyLogo: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBQX7i_zhTb_VU_ZfhCKYzvPRyeO6MvoQst3x4iZ12p6RyP35MCzju45JLqSobO4dMKLHi2EOSNL9v0RWPyTRijPeRmiyVsveM1iFjfSydg7LOIoBAK5IyFWX8BX9zOXCH22IP6p_WuCpHa9fPJ5xDs-zBIqzeHQ3ZGBmQMYkPye40z8crqEvOCeMFwLlIEvpRf7FsLLp_FMrp_koCFnUC4_AEjSlY_dJRqPyhRMrtbO7ms9L7JeE0W',
      companyName: 'TechScale Solutions',
      position: 'Senior UX Designer',
      location: 'Remote',
      appliedDate: 'Oct 12, 2023',
      status: 'Interview Scheduled',
      statusType: JobStatus.interview,
      latestMessage: '"We\'d like to schedule a call for the technical round next Tuesday. Does 2 PM work for you?"',
      recruiterName: 'Sarah Thompson',
      showJoinMeeting: true,
    ),
    JobApplication(
      id: '2',
      companyLogo: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCJZq1urDfzMHX4UqWOA7hNYz-AEhDvM980HF4_TGLqlQSbSOMcn2h-b1HWfinryWLUTBqPFANG-_rtv16dFobTWiuDIsja64Rfh7Xob4qUaryE7U8W_GNGiuDpqPk8ARfXRHiFau_vIxD9wGNSEo2em9d4ljZX7UB9fE6TSeeHEVij4t-PLXuaGChncVRmBjaDHN-_zdLigLBmSIhAQVrWn9lFW-XJmSGwqCjU8dQ5KqbQs4eyGBvX',
      companyName: 'Finovate Global',
      position: 'Product Manager',
      location: 'London, UK',
      appliedDate: 'Oct 08, 2023',
      status: 'Shortlisted',
      statusType: JobStatus.shortlisted,
      latestMessage: '"Your profile has been shortlisted by the hiring manager. We will contact you soon for the next steps."',
      recruiterName: 'Hiring Manager',
      showJoinMeeting: false,
    ),
    JobApplication(
      id: '3',
      companyLogo: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD-k6g47b9DPlSK1Z2-eQrhI1OGrLTEG0RFfpVcAqSg4dx6oKJS82GtmRoWGNjY8Oha5ctuAbUSiEGgA5rlgNC7DNc5ZcjTsP7otVMTMIlZMDodcxKVJ084x8XGQcNbqJOxHXTt_TQhIVHObf9RcVDH1GJmc1sNWzU_PyoKTaZL48M9Trvut3fm2nerSnFGYUzgARZSjZFQhK869iOf5VQfera4UXsmX0M7hiRh8KjKQdpev_5H4Ozf',
      companyName: 'Insight Corp',
      position: 'Data Analyst',
      location: 'Hybrid',
      appliedDate: 'Sep 28, 2023',
      status: 'In Review',
      statusType: JobStatus.review,
      latestMessage: null,
      recruiterName: null,
      showJoinMeeting: false,
    ),
  ];

  List<JobApplication> get filteredApplications {
    if (selectedFilter == 'All') return applications;
    return applications.where((job) {
      switch (selectedFilter) {
        case 'Applied':
          return job.statusType == JobStatus.applied;
        case 'Shortlisted':
          return job.statusType == JobStatus.shortlisted;
        case 'Interview':
          return job.statusType == JobStatus.interview;
        case 'Offer':
          return job.statusType == JobStatus.offer;
        default:
          return true;
      }
    }).toList();
  }

  void _showWithdrawSheet(BuildContext context, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Withdraw Application?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to withdraw your application for this position? This action cannot be undone.',
              style: TextStyle(fontSize: 14, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel', style: TextStyle(color: colorScheme.outline)),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Application withdrawn successfully.'), behavior: SnackBarBehavior.floating),
                    );
                  },
                  style: FilledButton.styleFrom(backgroundColor: colorScheme.error, foregroundColor: colorScheme.onError),
                  child: const Text('Withdraw Application'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showChatSheet(BuildContext context, JobApplication job, ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4))),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      job.recruiterName?.substring(0, 2).toUpperCase() ?? 'RE',
                      style: TextStyle(color: colorScheme.onPrimaryContainer, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(job.recruiterName ?? 'Hiring Workspace', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        Text(job.companyName, style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  _buildBubble('Hi! We\'ve reviewed your portfolio and would like to move forward. Can we chat next week?', '10:45 AM', false, colorScheme),
                  _buildBubble('Hi Sarah, that sounds great. Tuesday morning works best for me. Looking forward to it!', '11:02 AM', true, colorScheme),
                  if (job.latestMessage != null) _buildBubble(job.latestMessage!, 'Just now', false, colorScheme, isHighlighted: true),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: colorScheme.outlineVariant.withOpacity(0.4))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerHigh ?? Colors.grey[100],
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filled(
                    onPressed: () {},
                    icon: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBubble(String text, String time, bool isOwn, ColorScheme colorScheme, {bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isOwn ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isOwn ? colorScheme.primary : (isHighlighted ? colorScheme.primary.withOpacity(0.08) : colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(12),
              border: isHighlighted ? Border.all(color: colorScheme.primary.withOpacity(0.3)) : null,
            ),
            child: Text(text, style: TextStyle(color: isOwn ? colorScheme.onPrimary : colorScheme.onSurface, fontSize: 14)),
          ),
          const SizedBox(height: 4),
          Text(time, style: TextStyle(fontSize: 10, color: colorScheme.outline)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE2E8F0), height: 1),
        ),
        title: Row(
          children: [
            const CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(
                'https://lh3.googleusercontent.com/aida-public/AB6AXuDanVwBdrU1nUbpUZ3TKfhe6seumPDkGipNVtDpZO8gVY9PVR1t_Zjw8jBF4dBcPsZRjxoqXv1i3HNAczZlNdDvLHXgx9u27YitExrfdVjshbbuLpcZVwUQFqk95qPrFZInl9o0UdoyIk1HJo_Vssfj18g4exr6-rvBxpckTGnP7_ByS94b0Wg5ockDTNOSz_KQq_hOfMs3BkUo_sCTTDnq8VBV3C208cBwtvSDZ1MGiWlGrC29WBIt',
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'CareerTrack',
              style: TextStyle(fontFamily: 'Manrope', fontSize: 20, fontWeight: FontWeight.bold, color: colorScheme.primary),
            ),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.notifications_outlined, color: colorScheme.onSurfaceVariant)),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Applied Pipeline', style: TextStyle(fontFamily: 'Manrope', fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildFilterChips(colorScheme),
            const SizedBox(height: 20),
            ...filteredApplications.map((job) => _buildJobCard(context, job, colorScheme)),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(ColorScheme colorScheme) {
    final filters = ['All', 'Applied', 'Shortlisted', 'Interview', 'Offer'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 6.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (val) {
                if (val) setState(() => selectedFilter = filter);
              },
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildJobCard(BuildContext context, JobApplication job, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: colorScheme.surfaceContainerHigh, borderRadius: BorderRadius.circular(10)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    job.companyLogo,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.business),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(job.position, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text('${job.companyName} • ${job.location}', style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant)),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 12, color: colorScheme.outline),
                        const SizedBox(width: 4),
                        Text('Log: ${job.appliedDate}', style: TextStyle(fontSize: 11, color: colorScheme.outline)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              _buildStatusBadge(job.status, job.statusType, colorScheme),
            ],
          ),
          if (job.latestMessage != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MESSAGE LOG', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.primary)),
                  const SizedBox(height: 4),
                  Text(job.latestMessage!, style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          ],
          const Divider(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  OutlinedButton.icon(
                    onPressed: () => _showChatSheet(context, job, colorScheme),
                    style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    icon: const Icon(Icons.chat_bubble_outline, size: 14),
                    label: const Text('Messages', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                  if (job.showJoinMeeting) ...[
                    const SizedBox(width: 6),
                    FilledButton.icon(
                      onPressed: () {},
                      style: FilledButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), backgroundColor: Colors.teal),
                      icon: const Icon(Icons.video_call, size: 14),
                      label: const Text('Join Live', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ] else ...[
                    const SizedBox(width: 6),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      child: const Text('View Details', style: TextStyle(fontSize: 12)),
                    )
                  ]
                ],
              ),
              PopupMenuButton<String>(
                onSelected: (val) {
                  if (val == 'withdraw') _showWithdrawSheet(context, colorScheme);
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'withdraw',
                    child: Text('Withdraw App', style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.w500)),
                  ),
                ],
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String label, JobStatus status, ColorScheme colorScheme) {
    Color base;
    switch (status) {
      case JobStatus.interview:
        base = Colors.purple;
        break;
      case JobStatus.shortlisted:
        base = Colors.blue;
        break;
      case JobStatus.review:
        base = Colors.orange;
        break;
      default:
        base = Colors.grey;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: base.withOpacity(0.08), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: base)),
    );
  }

  // FIXED: Explicit parameter key binding added to resolve compilation faults
  Widget _buildInfoRow(String key, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(key, style: const TextStyle(fontSize: 13, color: Colors.grey)),
          Text(val, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

enum JobStatus { applied, shortlisted, interview, offer, review }

class JobApplication {
  final String id;
  final String companyLogo;
  final String companyName;
  final String position;
  final String location;
  final String appliedDate;
  final String status;
  final JobStatus statusType;
  final String? latestMessage;
  final String? recruiterName;
  final bool showJoinMeeting;

  JobApplication({
    required this.id,
    required this.companyLogo,
    required this.companyName,
    required this.position,
    required this.location,
    required this.appliedDate,
    required this.status,
    required this.statusType,
    this.latestMessage,
    this.recruiterName,
    this.showJoinMeeting = false,
  });
}