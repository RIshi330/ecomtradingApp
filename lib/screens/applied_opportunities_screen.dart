import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class AppliedOpportunitiesScreen extends StatefulWidget {
  final bool isEmbedded;
  const AppliedOpportunitiesScreen({super.key, this.isEmbedded = false});

  @override
  State<AppliedOpportunitiesScreen> createState() => _AppliedOpportunitiesScreenState();
}

class _AppliedOpportunitiesScreenState extends State<AppliedOpportunitiesScreen> {
  String selectedFilter = "All";
  final List<String> filters = ["All", "Pending", "Accepted", "Under Review"];

  List<dynamic> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'my_applications',
      }, endpoint: 'new_apis/opportunity_action_detailed_response.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _applications = List<dynamic>.from(response['data']['applications'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error fetching applications: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  final Map<String, bool> expandedStates = {};

  void _showContactAdminSheet(int itemId, int marketplaceId, String title, String adminName) {
    final msgController = TextEditingController(
      text: "Hi $adminName, I am following up on my response for '$title'. I'm available to discuss any additional details you might need regarding the technical implementation phase.",
    );

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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Follow-up Message", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const Text("RECIPIENT", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                child: Text(adminName, style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: msgController,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Your Message", border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: () async {
                      try {
                        final response = await Database().getData({
                          'action': 'send_followup_message',
                          'item_id': itemId.toString(),
                          'marketplace_id': marketplaceId.toString(),
                          'message': msgController.text.trim(),
                        }, endpoint: 'new_apis/opportunity_action_detailed_response.php');

                        if (response['success'] == true) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Follow-up message sent successfully!"), backgroundColor: Colors.green),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(response['message']?.toString() ?? "Failed to send message."), backgroundColor: Colors.red),
                          );
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: const Text("Send Message"),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(int statusCode) {
    if (statusCode == 1) return "Accepted";
    if (statusCode == 2) return "Under Review";
    return "Pending";
  }

  Color _getStatusColor(String status) {

    switch (status) {
      case "Accepted":
        return Colors.green;
      case "Under Review":
        return Colors.orange;
      case "Pending":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final filteredProposals = selectedFilter == "All"
        ? _applications
        : _applications.where((p) {
            final int statusVal = int.tryParse(p['status']?.toString() ?? '0') ?? 0;
            return _getStatusLabel(statusVal) == selectedFilter;
          }).toList();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("My Responses", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: Column(
        children: [
          // Filter Row
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
                      if (selected) setState(() => selectedFilter = filter);
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
          // Responses list
          Expanded(
            child: filteredProposals.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.description_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text("No responses found", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredProposals.length,
                    itemBuilder: (context, index) {
                      final prop = filteredProposals[index];
                      final title = prop["opportunity_title"] ?? "Opportunity Submission";
                      
                      final int statusVal = int.tryParse(prop['status']?.toString() ?? '0') ?? 0;
                      final statusLabel = _getStatusLabel(statusVal);
                      
                      final date = prop["created_date"]?.toString().split(' ').first ?? "";
                      final org = prop["organization"] ?? "N/A";
                      final loc = prop["opportunity_location"] ?? "N/A";
                      
                      final responseText = prop["description"] ?? "";
                      
                      final int itemId = int.tryParse(prop['item_id']?.toString() ?? '') ?? 0;
                      final int marketplaceId = int.tryParse(prop['marketplace_id']?.toString() ?? '') ?? 4; // default to 4 for opportunity

                      final isExpanded = expandedStates[title] ?? false;

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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    title,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.primary),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(statusLabel).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(color: _getStatusColor(statusLabel), fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("ORGANIZATION", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(org, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("LOCATION", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 2),
                                      Text(loc, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            // Collapsible detail box
                            InkWell(
                              onTap: () {
                                setState(() {
                                  expandedStates[title] = !isExpanded;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Row(
                                          children: [
                                            Icon(Icons.description, size: 16, color: AppTheme.primary),
                                            SizedBox(width: 6),
                                            Text("View My Response", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                                          ],
                                        ),
                                        Icon(isExpanded ? Icons.expand_less : Icons.expand_more, size: 18, color: AppTheme.primary),
                                      ],
                                    ),
                                    if (isExpanded) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        responseText,
                                        style: TextStyle(color: Colors.grey.shade800, fontSize: 12, height: 1.4, fontStyle: FontStyle.italic),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            // Actions
                            Row(
                              children: [
                                Expanded(
                                  child: FilledButton.icon(
                                    onPressed: () => _showContactAdminSheet(itemId, marketplaceId, title, org),
                                    icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                    label: const Text("Contact Admin"),
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppTheme.primary,
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
