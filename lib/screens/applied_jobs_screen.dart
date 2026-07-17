import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

import 'package:trading_ecommerce_admin/Database/Database.dart';

class AppliedJobsScreen extends StatefulWidget {
  final bool isEmbedded;
  const AppliedJobsScreen({super.key, this.isEmbedded = false});

  @override
  State<AppliedJobsScreen> createState() => _AppliedJobsScreenState();
}

class _AppliedJobsScreenState extends State<AppliedJobsScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Applied", "Shortlisted"];

  List<dynamic> _appliedJobs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchAppliedJobs();
  }

  Future<void> _fetchAppliedJobs() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_applied_jobs',
      }, endpoint: 'new_apis/applied_jobs_API.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _appliedJobs = List<dynamic>.from(response['data']);
        });
      }
    } catch (e) {
      debugPrint("Error fetching applied jobs: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showWithdrawDialog(int responseId, String jobTitle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Withdraw Application?"),
        content: Text("Are you sure you want to withdraw your application for '$jobTitle'? This action cannot be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            onPressed: () async {
              Navigator.pop(context);
              try {
                final response = await Database().getData({
                  'action': 'withdraw_application',
                  'response_id': responseId.toString(),
                }, endpoint: 'new_apis/applied_jobs_API.php');

                if (response['success'] == true) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Application withdrawn successfully."), backgroundColor: AppTheme.error),
                  );
                  _fetchAppliedJobs();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(response['message']?.toString() ?? "Failed to withdraw application."), backgroundColor: Colors.red),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Withdraw"),
          ),
        ],
      ),
    );
  }

  void _showChatDialog(int companyVendorId, int jobId, String recruiterName, String companyName) {
    final messageController = TextEditingController();
    List<dynamic> chatMessages = [];
    bool isChatLoading = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> fetchChat() async {
              try {
                final response = await Database().getData({
                  'action': 'get_messages',
                  'company_vendor_id': companyVendorId.toString(),
                  'jobid': jobId.toString(),
                }, endpoint: 'new_apis/applied_jobs_API.php');

                if (response['success'] == true && response['data'] != null) {
                  setModalState(() {
                    chatMessages = List<dynamic>.from(response['data']);
                    isChatLoading = false;
                  });
                }
              } catch (e) {
                debugPrint("Error fetching chat: $e");
                setModalState(() {
                  isChatLoading = false;
                });
              }
            }

            if (isChatLoading && chatMessages.isEmpty) {
              fetchChat();
            }

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: AppTheme.primary.withOpacity(0.1),
                            child: Text(recruiterName.isNotEmpty ? recruiterName[0] : "R", style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("$recruiterName (Recruiter)", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                              Text(companyName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text("Latest Messages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 12),
                  if (isChatLoading)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: CircularProgressIndicator()))
                  else if (chatMessages.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(16.0), child: Text("No messages yet. Send a message to start the conversation.", style: TextStyle(color: Colors.grey, fontSize: 12))))
                  else
                    Container(
                      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.3),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = chatMessages[index];
                          final bool isOutgoing = msg['outgoing'] == true || msg['outgoing'] == 1 || msg['outgoing'] == "1";
                          return Align(
                            alignment: isOutgoing ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: isOutgoing ? AppTheme.primary : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                msg['message'] ?? "",
                                style: TextStyle(color: isOutgoing ? Colors.white : Colors.black87, fontSize: 13),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Your Message",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: () async {
                          final text = messageController.text.trim();
                          if (text.isEmpty) return;

                          setModalState(() {
                            isChatLoading = true;
                          });

                          try {
                            final response = await Database().getData({
                              'action': 'send_message',
                              'vendorid': companyVendorId.toString(),
                              'jobid': jobId.toString(),
                              'msg': text,
                            }, endpoint: 'new_apis/applied_jobs_API.php');

                            if (response['success'] == true) {
                              messageController.clear();
                              await fetchChat();
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(response['message']?.toString() ?? "Failed to send message."), backgroundColor: Colors.red),
                              );
                              setModalState(() {
                                isChatLoading = false;
                              });
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                            );
                            setModalState(() {
                              isChatLoading = false;
                            });
                          }
                        },
                        child: const Text("Send Message"),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String type) {
    switch (type) {
      case "Interview":
        return const Color(0xFF008080);
      case "Shortlisted":
        return const Color(0xFF607773);
      case "Offer":
        return Colors.green;
      default:
        return Colors.grey.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredJobs = selectedFilter == "All"
        ? _appliedJobs
        : _appliedJobs.where((job) {
            final label = job['status_label']?.toString() ?? '';
            if (selectedFilter == "Shortlisted") {
              return label == "Shortlisted";
            } else {
              return label == "In Review" || label == "Applied";
            }
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Applied Jobs", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: Column(
        children: [
          // Filter Chips Section
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            height: 64,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filters.length,
              itemBuilder: (context, index) {
                final filter = filters[index];
                final isSelected = selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => selectedFilter = filter);
                      }
                    },
                    selectedColor: AppTheme.primary,
                    disabledColor: Colors.white,
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppTheme.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),
          // Jobs Grid / List
          Expanded(
            child: filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.work_off_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text("No jobs found in this category", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = filteredJobs[index];
                      final title = job['job_title'] ?? 'Job Title';
                      final company = job['company_name'] ?? 'Company';
                      final category = job['job_category'] ?? '';
                      final daysAgo = job['applied_days_ago'];
                      final rawDate = job['applied_date'];
                      final statusLabel = job['status_label'] ?? 'In Review';
                      final statusType = statusLabel == 'Shortlisted' ? 'Shortlisted' : 'Interview';
                      
                      final companyVendorId = int.tryParse(job['company_vendor_id']?.toString() ?? '') ?? 0;
                      final jobId = int.tryParse(job['job_id']?.toString() ?? '') ?? 0;
                      final responseId = int.tryParse(job['response_id']?.toString() ?? '') ?? 0;

                      final logoText = company.isNotEmpty ? (company.length >= 2 ? company.substring(0, 2).toUpperCase() : company.substring(0, 1).toUpperCase()) : "CO";

                      String appliedText = "";
                      if (daysAgo != null) {
                        final parsedDays = int.tryParse(daysAgo.toString());
                        if (parsedDays != null) {
                          if (parsedDays == 0) appliedText = "Today";
                          else if (parsedDays == 1) appliedText = "1 day ago";
                          else appliedText = "$parsedDays days ago";
                        }
                      }
                      if (appliedText.isEmpty && rawDate != null) {
                        appliedText = rawDate.toString().split(' ').first;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
                          boxShadow: AppTheme.cardShadow,
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
                                  decoration: BoxDecoration(
                                    color: AppTheme.primary.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  clipBehavior: Clip.antiAlias,
                                  child: (job['company_logo'] != null && job['company_logo'].toString().isNotEmpty)
                                      ? Image.network(
                                          job['company_logo'].toString(),
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => Center(
                                            child: Text(logoText, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                          ),
                                        )
                                      : Center(
                                          child: Text(logoText, style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold)),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        title,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "$company • $category",
                                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(Icons.calendar_today_outlined, size: 12, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            "Applied: $appliedText",
                                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(statusType).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      color: _getStatusColor(statusType),
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () => _showChatDialog(companyVendorId, jobId, company, company),
                                    icon: const Icon(Icons.mail_outline, size: 16),
                                    label: const Text("Messages"),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () => _showWithdrawDialog(responseId, title),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: AppTheme.outline.withOpacity(0.6)),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.delete_outline, color: AppTheme.error, size: 20),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
