import 'package:flutter/material.dart';

import '../Database/Database.dart';

/// ---------------------------------------------------------------------
/// COLOR TOKENS (unchanged from the original design)
/// ---------------------------------------------------------------------
class AppColors {
  static const onBackground = Color(0xFF1A1C1C);
  static const onSecondary = Color(0xFFFFFFFF);
  static const surfaceContainerLow = Color(0xFFF4F3F3);
  static const surfaceDim = Color(0xFFDADAD9);
  static const primary = Color(0xFF006565);
  static const tertiary = Color(0xFF595B5A);
  static const outline = Color(0xFF6E7979);
  static const error = Color(0xFFBA1A1A);
  static const background = Color(0xFFF9F9F9);
  static const outlineVariant = Color(0xFFBDC9C8);
  static const surfaceContainerHigh = Color(0xFFE8E8E8);
  static const surface = Color(0xFFF9F9F9);
  static const onSurfaceVariant = Color(0xFF3E4949);
  static const onSurface = Color(0xFF1A1C1C);
  static const secondary = Color(0xFF296767);
  static const secondaryContainer = Color(0xFFB0EEED);
  static const onSecondaryContainer = Color(0xFF306E6D);
  static const primaryContainer = Color(0xFF008080);
  static const surfaceContainerLowest = Color(0xFFFFFFFF);
}

BoxDecoration _cardDecoration() {
  return BoxDecoration(
    color: AppColors.surfaceContainerLowest,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: AppColors.outlineVariant),
    boxShadow: const [
      BoxShadow(color: Color(0x0F000000), blurRadius: 4, offset: Offset(0, 1)),
    ],
  );
}

class RecruiterApp extends StatelessWidget {
  final bool isEmbaded;
  const RecruiterApp({super.key, this.isEmbaded = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Serene Commerce Recruiter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.light(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          error: AppColors.error,
          surface: AppColors.surface,
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}

/// ---------------------------------------------------------------------
/// DASHBOARD SCREEN — now backed by DashboardService instead of dummy data
/// ---------------------------------------------------------------------
class DashboardScreen extends StatefulWidget {
  final bool isEmbedded;
  const DashboardScreen({super.key, this.isEmbedded = true});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _service = DashboardService();

  late Future<DashboardStats> _statsFuture;
  late Future<List<CategoryCount>> _categoriesFuture;
  late Future<List<ActivePost>> _activePostsFuture;
  late Future<List<Applicant>> _applicantsFuture;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  void _loadAll() {
    _statsFuture = _service.getDashboardStats();
    _categoriesFuture = _service.getCandidatesByJob();
    _activePostsFuture = _service.getActivePosts();
    _applicantsFuture = _service.getRecentApplicants();
  }

  Future<void> _refresh() async {
    setState(_loadAll);
    await Future.wait([
      _statsFuture,
      _categoriesFuture,
      _activePostsFuture,
      _applicantsFuture,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.isEmbedded ? null : _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: [
              const SizedBox(height: 12),
              _StatsSlider(future: _statsFuture),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _CandidatesByCategoryCard(future: _categoriesFuture),
              ),
              const SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _ActivePostingsCard(future: _activePostsFuture),
              ),
              const SizedBox(height: 24),
              const _SectionHeader(title: 'Recent Applicants'),
              const SizedBox(height: 12),
              _RecentApplicantsSlider(
                future: _applicantsFuture,
                onCandidateBlocked: () => setState(() {
                  _applicantsFuture = _service.getRecentApplicants();
                }),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        elevation: 4,
        onPressed: _refresh,
        child: const Icon(Icons.refresh, size: 28),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.surface.withValues(alpha: 0.9),
      elevation: 0,
      scrolledUnderElevation: 1,
      surfaceTintColor: Colors.transparent,
      titleSpacing: 16,
      title: Row(
        children: [
          const Icon(Icons.dashboard, color: AppColors.primary, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Serene Commerce Recruiter',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20,
                letterSpacing: -0.3,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// SHARED: a small wrapper that turns a Future<T> into loading / error / data
/// ---------------------------------------------------------------------
class _AsyncSection<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext, T) builder;
  final double height;

  const _AsyncSection({
    required this.future,
    required this.builder,
    this.height = 130,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox(
            height: height,
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return SizedBox(
            height: height,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Could not load data: ${snapshot.error}',
                  style: const TextStyle(color: AppColors.error, fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
        return builder(context, snapshot.data as T);
      },
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// ROW 1: STATS SLIDER — from action=dashboard_stats
/// ---------------------------------------------------------------------
class _StatsSlider extends StatelessWidget {
  final Future<DashboardStats> future;
  const _StatsSlider({required this.future});

  @override
  Widget build(BuildContext context) {
    return _AsyncSection<DashboardStats>(
      future: future,
      height: 130,
      builder: (context, stats) {
        final items = [
          (Icons.group, 'TOTAL CANDIDATES', '${stats.totalCandidates}'),
          (Icons.work, 'ACTIVE POSTS', '${stats.activePosts}'),
          (Icons.event, 'INTERVIEWS', '${stats.interviewsScheduled}'),
          (Icons.description, 'OFFERS GIVEN', '${stats.offersGiven}'),
          (Icons.check_circle, 'HIRES COMPLETED', '${stats.hiresCompleted}'),
        ];
        return SizedBox(
          height: 130,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (context, i) {
              final s = items[i];
              return Container(
                width: 170,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: Container(width: 4, color: AppColors.primary),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(s.$1, color: AppColors.primary, size: 22),
                          Text(
                            s.$2,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.6,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            s.$3,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
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
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// CANDIDATES BY CATEGORY — from action=candidate_by_job
/// ---------------------------------------------------------------------
class _CandidatesByCategoryCard extends StatelessWidget {
  final Future<List<CategoryCount>> future;
  const _CandidatesByCategoryCard({required this.future});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Candidates by Category',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          _AsyncSection<List<CategoryCount>>(
            future: future,
            height: 160,
            builder: (context, list) {
              if (list.isEmpty) {
                return const Text('No category data yet.',
                    style: TextStyle(color: AppColors.onSurfaceVariant));
              }
              final maxCount = list
                  .map((c) => c.count)
                  .fold<int>(1, (a, b) => b > a ? b : a);
              return Column(
                children: list.map((c) {
                  final fraction = c.count / maxCount;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(c.category, style: const TextStyle(fontSize: 14)),
                            Text('${c.count}', style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction.clamp(0.0, 1.0),
                            minHeight: 8,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            valueColor:
                            const AlwaysStoppedAnimation(AppColors.primary),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// ACTIVE POSTINGS — from action=active_posts
/// ---------------------------------------------------------------------
class _ActivePostingsCard extends StatelessWidget {
  final Future<List<ActivePost>> future;
  const _ActivePostingsCard({required this.future});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Active Postings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          _AsyncSection<List<ActivePost>>(
            future: future,
            height: 180,
            builder: (context, posts) {
              if (posts.isEmpty) {
                return const Text('No active postings.',
                    style: TextStyle(color: AppColors.onSurfaceVariant));
              }
              return Column(
                children: posts.map((p) {
                  return Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.outlineVariant),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.title,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(p.createdDate,
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${p.applicantCount}',
                                style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary)),
                            const Text('APPLICANTS',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                    color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------
/// RECENT APPLICANTS — from action=recent_applicants
/// Interview button -> action=schedule, Block button -> action=block_candidate
/// ---------------------------------------------------------------------
class _RecentApplicantsSlider extends StatelessWidget {
  final Future<List<Applicant>> future;
  final VoidCallback onCandidateBlocked;

  const _RecentApplicantsSlider({
    required this.future,
    required this.onCandidateBlocked,
  });

  @override
  Widget build(BuildContext context) {
    return _AsyncSection<List<Applicant>>(
      future: future,
      height: 230,
      builder: (context, applicants) {
        if (applicants.isEmpty) {
          return const SizedBox(
            height: 230,
            child: Center(
              child: Text('No recent applicants.',
                  style: TextStyle(color: AppColors.onSurfaceVariant)),
            ),
          );
        }
        return SizedBox(
          height: 230,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: applicants.length,
            separatorBuilder: (_, __) => const SizedBox(width: 24),
            itemBuilder: (context, i) {
              final a = applicants[i];
              return Container(
                width: 300,
                padding: const EdgeInsets.all(16),
                decoration: _cardDecoration(),
                child: Stack(
                  children: [
                    Positioned(
                      left: -16,
                      top: -16,
                      bottom: -16,
                      child: Container(width: 4, color: AppColors.primary),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: AppColors.outlineVariant,
                              child: Text(
                                a.name.isNotEmpty ? a.name[0].toUpperCase() : '?',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(a.name,
                                      style: const TextStyle(
                                          fontSize: 18, fontWeight: FontWeight.w600)),
                                  Text(a.jobTitle,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            a.jobCategory.isEmpty
                                ? 'GENERAL'
                                : a.jobCategory.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                              color: AppColors.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                ),
                                onPressed: () => showInterviewModal(
                                  context,
                                  itemId: a.id.toString(),
                                  candidateName: a.name,
                                  receiver: a.email,
                                ),
                                child: const Text('INTERVIEW',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        letterSpacing: 0.5)),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: 'Block candidate',
                              icon: const Icon(Icons.block, color: AppColors.error),
                              onPressed: () => showBlockModal(
                                context,
                                candidateId: a.id.toString(),
                                onBlocked: onCandidateBlocked,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

/// ---------------------------------------------------------------------
/// MODALS — now actually submit to the API via DashboardService
/// ---------------------------------------------------------------------
void showInterviewModal(
    BuildContext context, {
      required String itemId,
      required String candidateName,
      required String receiver,
    }) {
  final service = DashboardService();
  final subjectCtrl =
  TextEditingController(text: 'Technical Interview - $candidateName');
  final bodyCtrl = TextEditingController(
      text: 'You are invited to interview for the role. Please confirm your availability.');
  final dateCtrl = TextEditingController();
  final timeCtrl = TextEditingController();
  String mode = 'Online (Google Meet)';
  bool submitting = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Schedule Interview',
                  style: TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.primary)),
              const SizedBox(height: 16),
              _fieldLabel('SUBJECT'),
              TextField(controller: subjectCtrl, decoration: _inputDecoration()),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('DATE'),
                        TextField(
                          controller: dateCtrl,
                          readOnly: true,
                          decoration: _inputDecoration(icon: Icons.calendar_today),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: DateTime.now(),
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              dateCtrl.text =
                              '${picked.year}-${picked.month}-${picked.day}';
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _fieldLabel('TIME'),
                        TextField(
                          controller: timeCtrl,
                          readOnly: true,
                          decoration: _inputDecoration(icon: Icons.access_time),
                          onTap: () async {
                            final picked =
                            await showTimePicker(context: ctx, initialTime: TimeOfDay.now());
                            if (picked != null) {
                              timeCtrl.text = picked.format(ctx);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _fieldLabel('MODE'),
              DropdownButtonFormField<String>(
                initialValue: mode,
                decoration: _inputDecoration(),
                items: const [
                  DropdownMenuItem(
                      value: 'Online (Google Meet)', child: Text('Online (Google Meet)')),
                  DropdownMenuItem(
                      value: 'Onsite (HQ Office)', child: Text('Onsite (HQ Office)')),
                  DropdownMenuItem(value: 'Phone Call', child: Text('Phone Call')),
                ],
                onChanged: (v) => setState(() => mode = v ?? mode),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: submitting ? null : () => Navigator.pop(ctx),
                      child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: submitting
                          ? null
                          : () async {
                        if (dateCtrl.text.isEmpty || timeCtrl.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Pick a date and time first')),
                          );
                          return;
                        }
                        setState(() => submitting = true);
                        final ok = await service.scheduleInterview(
                          itemId: itemId,
                          subject: subjectCtrl.text,
                          body: bodyCtrl.text,
                          date: dateCtrl.text,
                          time: timeCtrl.text,
                          receiver: receiver,
                          mode: mode,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Interview scheduled with $candidateName'
                                  : 'Failed to schedule interview'),
                            ),
                          );
                        }
                      },
                      child: submitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('CONFIRM', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }),
  );
}

void showBlockModal(
    BuildContext context, {
      required String candidateId,
      required VoidCallback onBlocked,
    }) {
  final service = DashboardService();
  bool submitting = false;

  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(builder: (ctx, setState) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 56),
              const SizedBox(height: 12),
              const Text('Block Candidate?',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              const Text(
                'This will remove the candidate from all active pipelines and archive their application history permanently.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.onSurfaceVariant,
                        side: const BorderSide(color: AppColors.outline),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: submitting ? null : () => Navigator.pop(ctx),
                      child: const Text('CANCEL', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: submitting
                          ? null
                          : () async {
                        setState(() => submitting = true);
                        final ok =
                        await service.blockCandidate(candidateId: candidateId);
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (ok) onBlocked();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok
                                  ? 'Candidate blocked'
                                  : 'Failed to block candidate'),
                            ),
                          );
                        }
                      },
                      child: submitting
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text('BLOCK', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }),
  );
}

Widget _fieldLabel(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4, top: 4),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
        color: AppColors.onSurfaceVariant,
      ),
    ),
  );
}

InputDecoration _inputDecoration({IconData? icon}) {
  return InputDecoration(
    suffixIcon: icon != null ? Icon(icon, size: 18, color: AppColors.onSurfaceVariant) : null,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.outlineVariant),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  );
}
class DashboardStats {
  final int totalCandidates;
  final int activePosts;
  final int interviewsScheduled;
  final int offersGiven;
  final int hiresCompleted;

  DashboardStats({
    this.totalCandidates = 0,
    this.activePosts = 0,
    this.interviewsScheduled = 0,
    this.offersGiven = 0,
    this.hiresCompleted = 0,
  });

  factory DashboardStats.fromMap(Map map) {
    int _i(dynamic v) => int.tryParse(v?.toString() ?? '') ?? 0;
    return DashboardStats(
      totalCandidates: _i(map['total_candidates']),
      activePosts: _i(map['active_posts']),
      interviewsScheduled: _i(map['interviews_scheduled']),
      offersGiven: _i(map['offers_given']),
      hiresCompleted: _i(map['hires_completed']),
    );
  }
}

class IndustrySlice {
  final String industry;
  final int count;
  IndustrySlice(this.industry, this.count);
}

class PipelineStage {
  final String label;
  final int value;
  PipelineStage(this.label, this.value);
}

class CategoryCount {
  final String category;
  final int count;
  CategoryCount(this.category, this.count);
}

class ActivePost {
  final Map raw;
  ActivePost(this.raw);

  int get id => int.tryParse(raw['id']?.toString() ?? '') ?? 0;
  String get title => (raw['job_title'] ?? 'Untitled Role').toString();
  String get createdDate => (raw['created_date'] ?? '').toString();
  int get applicantCount =>
      int.tryParse(raw['applicant_count']?.toString() ?? '') ?? 0;
}

class Applicant {
  final Map raw;
  Applicant(this.raw);

  int get id => int.tryParse(raw['id']?.toString() ?? '') ?? 0;
  int get vendorId => int.tryParse(raw['vendor_id']?.toString() ?? '') ?? 0;
  String get name => (raw['name'] ?? 'Unknown').toString();
  String get email => (raw['email'] ?? '').toString();
  String get jobTitle => (raw['job_title'] ?? '').toString();
  String get jobCategory => (raw['job_category'] ?? '').toString();
  String get createdDate => (raw['created_date'] ?? '').toString();
}

/// ---------------------------------------------------------------------
/// SERVICE — one method per `action` handled by dashboard.php
/// ---------------------------------------------------------------------
class DashboardService {
  final Database _db = Database();

  Future<DashboardStats> getDashboardStats() async {
    final res = await _db.getData({'action': 'dashboard_stats'});
    if (res['status'] == 300 || res['success'] == false) {
      throw Exception(res['error'] ?? res['message'] ?? 'Failed to load stats');
    }
    return DashboardStats.fromMap(res);
  }

  Future<List<IndustrySlice>> getIndustryPieChart() async {
    final res = await _db.getData({'action': 'industry_pie_chart'});
    if (res['status'] == 300) {
      throw Exception(res['error'] ?? 'Failed to load industry data');
    }
    final industries = List.from(res['industries'] ?? []);
    final counts = List.from(res['counts'] ?? []);
    return List.generate(
      industries.length,
          (i) => IndustrySlice(
        industries[i].toString(),
        int.tryParse(counts.length > i ? counts[i].toString() : '0') ?? 0,
      ),
    );
  }

  Future<List<PipelineStage>> getCandidatePipeline() async {
    final res = await _db.getData({'action': 'candidate_pipeline'});
    if (res['status'] == 300) {
      throw Exception(res['error'] ?? 'Failed to load pipeline');
    }
    final statuses = List.from(res['statuses'] ?? []);
    return statuses
        .map((s) => PipelineStage(
      (s['x'] ?? '').toString(),
      int.tryParse(s['y']?.toString() ?? '') ?? 0,
    ))
        .toList();
  }

  Future<List<CategoryCount>> getCandidatesByJob() async {
    final res = await _db.getData({'action': 'candidate_by_job'});
    if (res['status'] == 300) {
      throw Exception(res['error'] ?? 'Failed to load categories');
    }
    final categories = List.from(res['categories'] ?? []);
    final counts = List.from(res['counts'] ?? []);
    return List.generate(
      categories.length,
          (i) => CategoryCount(
        categories[i].toString(),
        int.tryParse(counts.length > i ? counts[i].toString() : '0') ?? 0,
      ),
    );
  }

  /// active_posts is returned by PHP as a bare JSON array, so Database
  /// wraps it into {success, data, status} — pull the list back out.
  Future<List<ActivePost>> getActivePosts() async {
    final res = await _db.getData({'action': 'active_posts'});
    if (res['status'] == 300) {
      throw Exception(res['error'] ?? 'Failed to load active posts');
    }
    final list = List.from(res['data'] ?? []);
    return list.map((e) => ActivePost(Map.from(e))).toList();
  }

  Future<List<Applicant>> getRecentApplicants() async {
    final res = await _db.getData({'action': 'recent_applicants'});
    if (res['status'] == 300) {
      throw Exception(res['error'] ?? 'Failed to load applicants');
    }
    final list = List.from(res['data'] ?? []);
    return list.map((e) => Applicant(Map.from(e))).toList();
  }

  /// Schedules an interview. Mirrors scheduleInterview() in dashboard.php,
  /// which reads target/subject/body/item_id/date/time/receiver/mode from $_POST.
  Future<bool> scheduleInterview({
    required String itemId,
    required String subject,
    required String body,
    required String date,
    required String time,
    required String receiver,
    required String mode,
    String target = '',
  }) async {
    final res = await _db.getData({
      'action': 'schedule',
      'target': target,
      'subject': subject,
      'body': body,
      'item_id': itemId,
      'date': date,
      'time': time,
      'receiver': receiver,
      'mode': mode,
    });
    return res['success'] == true;
  }

  Future<bool> blockCandidate({required String candidateId}) async {
    final res = await _db.getData({
      'action': 'block_candidate',
      'candidate_id': candidateId,
    });
    return res['success'] == true;
  }

  Future<bool> sendEmail() async {
    final res = await _db.getData({'action': 'emsgsend'});
    return res['success'] == true;
  }
}