import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:url_launcher/url_launcher.dart';

class EnrolledTrainingsCustomScreen extends StatefulWidget {
  final bool isEmbedded;
  const EnrolledTrainingsCustomScreen({super.key, this.isEmbedded = false});

  @override
  State<EnrolledTrainingsCustomScreen> createState() => _EnrolledTrainingsCustomScreenState();
}

class _EnrolledTrainingsCustomScreenState extends State<EnrolledTrainingsCustomScreen> {
  String selectedTab = "White Label";

  List<dynamic> _whiteLabelTrainings = [];
  List<dynamic> _paidTrainings = [];
  bool _isLoading = true;
  int _wlCount = 0;
  int _paidCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchTrainingsData();
  }

  Future<void> _fetchTrainingsData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final db = Database();
      
      // Fetch Summary
      final summaryRes = await db.getData({
        'action': 'get_summary',
      }, endpoint: 'new_apis/purchase_trainings_api.php');

      if (summaryRes['success'] == true && summaryRes['data'] != null) {
        _wlCount = int.tryParse(summaryRes['data']['white_label_count']?.toString() ?? '0') ?? 0;
        _paidCount = int.tryParse(summaryRes['data']['paid_trainings_count']?.toString() ?? '0') ?? 0;
      }

      // Fetch White Label
      final wlRes = await db.getData({
        'action': 'get_white_label_trainings',
      }, endpoint: 'new_apis/purchase_trainings_api.php');

      if (wlRes['success'] == true && wlRes['data'] != null) {
        _whiteLabelTrainings = List<dynamic>.from(wlRes['data']);
      }

      // Fetch Paid Trainings
      final paidRes = await db.getData({
        'action': 'get_paid_trainings',
      }, endpoint: 'new_apis/purchase_trainings_api.php');

      if (paidRes['success'] == true && paidRes['data'] != null) {
        _paidTrainings = List<dynamic>.from(paidRes['data']);
      }

    } catch (e) {
      debugPrint("Error fetching trainings: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showMaterialsSheet(int mtid, String trainingTitle) {
    List<dynamic> materials = [];
    bool isMaterialsLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> fetchMaterials() async {
              try {
                final response = await Database().getData({
                  'action': 'get_training_materials',
                  'mtid': mtid.toString(),
                  'course_type': 'courseMaterial',
                }, endpoint: 'new_apis/purchase_trainings_api.php');

                if (response['success'] == true && response['data'] != null) {
                  setModalState(() {
                    materials = List<dynamic>.from(response['data']);
                    isMaterialsLoading = false;
                  });
                }
              } catch (e) {
                debugPrint("Error fetching materials: $e");
                setModalState(() {
                  isMaterialsLoading = false;
                });
              }
            }

            if (isMaterialsLoading && materials.isEmpty) {
              fetchMaterials();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        "Materials: $trainingTitle",
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                      ),
                    ),
                    IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                  ],
                ),
                const Divider(),
                const Text("AVAILABLE RESOURCES", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
                const SizedBox(height: 12),
                
                if (isMaterialsLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                else if (materials.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No course materials published for this training.", style: TextStyle(color: Colors.grey, fontSize: 12))))
                else
                  Container(
                    constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: materials.length,
                      itemBuilder: (context, index) {
                        final mat = materials[index];
                        final name = mat['material_name'] ?? 'Resource';
                        final type = mat['material_type'] ?? 'File';
                        final url = mat['resource_url'] ?? '';
                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.description, color: AppTheme.primary),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Text(type, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.download, color: AppTheme.primary),
                                onPressed: () async {
                                  if (url.isNotEmpty) {
                                    final uri = Uri.parse(url);
                                    if (await canLaunchUrl(uri)) {
                                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text("Could not open link: $url"), backgroundColor: Colors.red),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showJoinSessionSheet(int mtid, String trainingTitle) {
    bool isDetailsLoading = true;
    bool isAvailable = false;
    String platform = "Virtual Room";
    String joinLink = "";
    String appointmentDate = "";

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> fetchJoinInfo() async {
              try {
                final response = await Database().getData({
                  'action': 'get_training_join_info',
                  'mtid': mtid.toString(),
                }, endpoint: 'new_apis/purchase_trainings_api.php');

                if (response['success'] == true && response['data'] != null) {
                  setModalState(() {
                    isAvailable = response['data']['available'] == true || response['data']['available'] == 1;
                    platform = response['data']['platform']?.toString() ?? "Virtual Room";
                    joinLink = response['data']['join_link']?.toString() ?? "";
                    appointmentDate = response['data']['appointment_date']?.toString() ?? "";
                    isDetailsLoading = false;
                  });
                }
              } catch (e) {
                debugPrint("Error fetching join info: $e");
                setModalState(() {
                  isDetailsLoading = false;
                });
              }
            }

            if (isDetailsLoading) {
              fetchJoinInfo();
            }

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.video_camera_back, size: 48, color: AppTheme.primary),
                const SizedBox(height: 12),
                Text(trainingTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                
                if (isDetailsLoading)
                  const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                else if (!isAvailable)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Join details are not available yet. The provider has not generated the live link.",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else ...[
                  Text("Live session starting on $platform. Ensure your mic is muted upon entry.", style: const TextStyle(color: Colors.grey, fontSize: 12), textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("APPOINTMENT TIME", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(appointmentDate, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        if (joinLink.isNotEmpty) {
                          final uri = Uri.parse(joinLink);
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Could not launch link: $joinLink"), backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                      child: const Text("Launch Session"),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
              ],
            );
          },
        ),
      ),
    );
  }

  void _showCertificateDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.all(24),
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.primary, width: 3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium, color: Colors.amber, size: 64),
              const SizedBox(height: 12),
              const Text("CERTIFICATE", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primary)),
              const Text("OF COMPLETION", style: TextStyle(fontSize: 10, letterSpacing: 1.5, color: Colors.grey)),
              const SizedBox(height: 16),
              const Text("This acknowledges that", style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12)),
              const SizedBox(height: 8),
              const Text("PREMIER VENDOR", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              const Text("has successfully completed the training for", style: TextStyle(fontSize: 12)),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary, fontSize: 14), textAlign: TextAlign.center),
              const Divider(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Date Issued", style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text("Aug 12, 2026", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade800)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Certificate ID", style: TextStyle(fontSize: 9, color: Colors.grey)),
                      Text("CRT-NEG-2026-X99", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey.shade800)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Certificate PDF downloaded successfully!"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Download PDF"),
          ),
        ],
      ),
    );
  }

  void _showTicketDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Entrance Pass", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.qr_code_2, size: 140, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            const Text("Seat: Executive VIP - Seat 4G", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Added to secure Wallet!"), backgroundColor: Colors.green),
              );
            },
            child: const Text("Add to Wallet"),
          ),
        ],
      ),
    );
  }

  void _showReplayDialog(String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Replay Session", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(Icons.play_circle_fill, color: Colors.white, size: 48),
                  Positioned(
                    bottom: 8,
                    left: 8,
                    right: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("12:45 / 45:00", style: TextStyle(color: Colors.white, fontSize: 10)),
                        Icon(Icons.fullscreen, color: Colors.white, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 6),
            const Text("Course Chapters:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 4),
            const Text("00:00 - Introduction & Foundations\n08:20 - Core Negotiation Framework\n22:15 - Handling Resistance Tactics", style: TextStyle(fontSize: 11, height: 1.4)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Trainings Hub", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: Column(
        children: [
          // Header summary card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primary, AppTheme.primaryContainer],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.school, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("My Trainings Hub", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 2),
                      Text("White Label: $_wlCount • Paid Trainings: $_paidCount", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tab bar selection
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = "White Label"),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: selectedTab == "White Label" ? AppTheme.primary : Colors.transparent, width: 2)),
                      ),
                      child: Text("White Label", style: TextStyle(fontWeight: selectedTab == "White Label" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "White Label" ? AppTheme.primary : AppTheme.textSecondary)),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => selectedTab = "Paid Trainings"),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        border: Border(bottom: BorderSide(color: selectedTab == "Paid Trainings" ? AppTheme.primary : Colors.transparent, width: 2)),
                      ),
                      child: Text("Paid Trainings", style: TextStyle(fontWeight: selectedTab == "Paid Trainings" ? FontWeight.bold : FontWeight.normal, color: selectedTab == "Paid Trainings" ? AppTheme.primary : AppTheme.textSecondary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main content switcher
          Expanded(
            child: selectedTab == "White Label"
                ? (_whiteLabelTrainings.isEmpty
                    ? const Center(child: Text("No White Label trainings purchased yet.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _whiteLabelTrainings.length,
                        itemBuilder: (context, index) {
                          final course = _whiteLabelTrainings[index];
                          final title = course['training_title'] ?? 'Training';
                          final category = course['category']?.toString() ?? 'STRATEGIC GROWTH';
                          final desc = course['description'] ?? '';
                          final owner = course['owner_name'] ?? 'Provider';
                          final date = course['purchased_date']?.toString().split(' ').first ?? '';
                          final mtid = int.tryParse(course['mtid']?.toString() ?? '') ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                                  child: Text(category, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                ),
                                const SizedBox(height: 8),
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Text(desc, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text("Owner: $owner", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                    Text("Date: $date", style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  ],
                                ),
                                const Divider(height: 24),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showMaterialsSheet(mtid, title),
                                    icon: const Icon(Icons.folder_open_outlined, size: 18),
                                    label: const Text("Access Materials"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ))
                : (_paidTrainings.isEmpty
                    ? const Center(child: Text("No paid trainings registered yet.", style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _paidTrainings.length,
                        itemBuilder: (context, index) {
                          final course = _paidTrainings[index];
                          final title = course['training_title'] ?? 'Training';
                          
                          final modes = course['modes'] as List<dynamic>? ?? ['online'];
                          final isOnline = modes.contains('online');
                          final type = isOnline ? 'Online' : 'Onsite';

                          final city = course['city'] ?? '';
                          final state = course['state'] ?? '';
                          final location = isOnline ? 'Virtual Classroom' : "$city, $state";

                          final startDate = course['start_date']?.toString().split(' ').first ?? '';
                          final endDate = course['end_date']?.toString().split(' ').first ?? '';
                          final dateRange = "$startDate to $endDate";

                          final amount = course['amount_paid'] ?? 0.0;
                          final feeText = "₹$amount";

                          final orderId = "#ORD-${course['order_id'] ?? ''}";
                          final isCompleted = course['completed'] == true || course['completed'] == 1 || course['completed'] == "1";
                          final mtid = int.tryParse(course['mtid']?.toString() ?? '') ?? 0;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                              boxShadow: AppTheme.cardShadow,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: type == "Onsite" ? Colors.teal.shade50 : Colors.blue.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        type.toString().toUpperCase(),
                                        style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: type == "Onsite" ? Colors.teal : Colors.blue),
                                      ),
                                    ),
                                    Text(orderId, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(type == "Onsite" ? Icons.location_on_outlined : Icons.devices_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(location, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.event_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(dateRange, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.payments_outlined, size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("$feeText (Paid)", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const Divider(height: 24),
                                Row(
                                  children: [
                                    if (isCompleted == true) ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showReplayDialog(title),
                                          icon: const Icon(Icons.play_circle_outline, size: 16),
                                          label: const Text("Replay"),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showCertificateDialog(title),
                                          icon: const Icon(Icons.workspace_premium_outlined, size: 16),
                                          label: const Text("Certificate"),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                    ] else ...[
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => _showMaterialsSheet(mtid, title),
                                          icon: const Icon(Icons.description_outlined, size: 16),
                                          label: const Text("Materials"),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      if (type == "Onsite") ...[
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () => _showTicketDialog(title),
                                            icon: const Icon(Icons.confirmation_number_outlined, size: 16),
                                            label: const Text("Ticket"),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                      ] else ...[
                                        Expanded(
                                          child: FilledButton.icon(
                                            onPressed: () => _showJoinSessionSheet(mtid, title),
                                            icon: const Icon(Icons.videocam_outlined, size: 16),
                                            label: const Text("Join Live"),
                                            style: FilledButton.styleFrom(
                                              backgroundColor: AppTheme.primary,
                                              padding: const EdgeInsets.symmetric(vertical: 8),
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      )),
          ),
        ],
      ),
    );
  }
}
