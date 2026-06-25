import 'package:flutter/material.dart';
import '../model/opportunity_model.dart';
import '../widgets/opportunity_card.dart';
import '../widgets/featured_banner.dart';
import '../widgets/filter_bottom_sheet.dart';
import '../Database/Database.dart';
import '../index.dart'; // To use AppRoutes for navigation connection

class ManageOpportunitiesScreen extends StatefulWidget {
  final bool isTab;
  const ManageOpportunitiesScreen({super.key, this.isTab = false});

  @override
  State<ManageOpportunitiesScreen> createState() =>
      _ManageOpportunitiesScreenState();
}

class _ManageOpportunitiesScreenState extends State<ManageOpportunitiesScreen> {
  int currentIndex = 2; // My Hub is selected by default
  bool _isLoading = false;

  // Filtering criteria state
  String filterStatus = "All";
  String filterCategory = "All";
  String filterType = "All";
  String searchQuery = "";

  final searchController = TextEditingController();

  // Dynamic source list of opportunities from backend
  List<OpportunityModel> opportunitiesList = [];

  @override
  void initState() {
    super.initState();
    _fetchOpportunities();
  }

  Future<void> _fetchOpportunities() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_all_opportunities',
        'search': searchQuery,
        'type': filterType == 'All' ? '' : filterType,
        'status': filterStatus == 'All' ? '' : (filterStatus == 'Active' ? '1' : (filterStatus == 'Pending' ? '0' : '-1')),
      }, endpoint: 'new_apis/manage_opportunities_api 1.php');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> listData = data['opportunities'] ?? [];
        setState(() {
          opportunitiesList = listData.map((item) {
            final opp = item['opportunity'] as Map<String, dynamic>;
            final totalApps = item['total_applications'] ?? 0;
            
            final rawStatus = opp['status']?.toString() ?? '1';
            String statusString = "Active";
            if (rawStatus == "0") {
              statusString = "Pending";
            } else if (rawStatus == "-1") {
              statusString = "Unpublished";
            }

            return OpportunityModel(
              title: opp['title'] ?? 'Untitled',
              reference: opp['reference'] ?? '#OP-${opp['id'] ?? ""}',
              location: opp['location'] ?? 'Remote',
              type: opp['type'] ?? 'Full-time',
              category: opp['category_title'] ?? 'Tech & Product',
              status: statusString,
              views: int.tryParse(opp['views']?.toString() ?? '0') ?? 0,
              responses: int.tryParse(totalApps.toString()) ?? 0,
              date: opp['created_at'] ?? 'Just now',
            );
          }).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching opportunities: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FilterBottomSheet(
          initialStatus: filterStatus,
          initialCategory: filterCategory,
          initialType: filterType,
          onApply: (status, category, type) {
            setState(() {
              filterStatus = status;
              filterCategory = category;
              filterType = type;
            });
            _fetchOpportunities();
          },
        );
      },
    );
  }

  void _showAddOpportunityDialog() {
    final titleCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    String typeVal = "Full-time";
    String catVal = "Tech & Product";
    String statusVal = "Active";

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              title: const Text(
                "List New Opportunity",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleCtrl,
                      decoration: const InputDecoration(labelText: "Opportunity Title"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: locCtrl,
                      decoration: const InputDecoration(labelText: "Location (e.g. Remote, City)"),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: typeVal,
                      decoration: const InputDecoration(labelText: "Job Type"),
                      items: ["Full-time", "Part-time", "Hybrid", "Contract", "Volunteer"]
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          typeVal = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: catVal,
                      decoration: const InputDecoration(labelText: "Category"),
                      items: ["Tech & Product", "Non-Profit", "Marketing", "Design", "Finance"]
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          catVal = val!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: statusVal,
                      decoration: const InputDecoration(labelText: "Status"),
                      items: ["Active", "Pending", "Unpublished"]
                          .map((val) => DropdownMenuItem(value: val, child: Text(val)))
                          .toList(),
                      onChanged: (val) {
                        setDialogState(() {
                          statusVal = val!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    if (titleCtrl.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Title cannot be empty"), backgroundColor: Colors.red),
                      );
                      return;
                    }
                    
                    final response = await Database().getData({
                      "action": "create_opportunity",
                      "title": titleCtrl.text.trim(),
                      "location": locCtrl.text.trim().isEmpty ? "Remote" : locCtrl.text.trim(),
                      "type": typeVal,
                      "organization": "Luxe Partner",
                      "payout_amount": "Flexible",
                      "label": statusVal == "Active" ? 1 : (statusVal == "Pending" ? 2 : 3),
                    }, endpoint: "new_apis/marketplace_opportunity_api.php");

                    if (!context.mounted) return;
                    if (response['success'] == true) {
                      Navigator.pop(ctx);
                      _fetchOpportunities();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Opportunity created successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Failed to create opportunity: ${response['message'] ?? 'Error'}"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCF9F8),
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                "My Opportunities",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.filter_list, color: Color(0xff006565)),
                  onPressed: _showFilterBottomSheet,
                ),
              ],
            ),

      floatingActionButton: widget.isTab
          ? null
          : FloatingActionButton(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.createOpportunity).then((didCreate) {
                  if (didCreate == true) {
                    _fetchOpportunities();
                  }
                });
              },
              child: const Icon(Icons.add),
            ),
      body: RefreshIndicator(
        onRefresh: _fetchOpportunities,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Promotive Feature banner
              FeaturedBanner(
                onBoostTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Visibility boost subscription activated!"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Search Bar
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      onChanged: (val) {
                        setState(() {
                          searchQuery = val;
                        });
                        _fetchOpportunities();
                      },
                      decoration: InputDecoration(
                        hintText: "Search title or reference...",
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, color: Colors.grey),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    searchQuery = "";
                                  });
                                  _fetchOpportunities();
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE6E6F0)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: Color(0xFFE6E6F0)),
                        ),
                      ),
                    ),
                  ),
                  if (widget.isTab) ...[
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _showFilterBottomSheet,
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xff006565).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(Icons.tune, color: Color(0xff006565)),
                      ),
                    )
                  ]
                ],
              ),
              const SizedBox(height: 20),

              // Filter status summary indicator chips row
              if (filterStatus != "All" || filterCategory != "All" || filterType != "All") ...[
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (filterStatus != "All")
                      Chip(
                        label: Text("Status: $filterStatus"),
                        onDeleted: () {
                          setState(() {
                            filterStatus = "All";
                          });
                          _fetchOpportunities();
                        },
                      ),
                    if (filterCategory != "All")
                      Chip(
                        label: Text("Category: $filterCategory"),
                        onDeleted: () {
                          setState(() {
                            filterCategory = "All";
                          });
                          _fetchOpportunities();
                        },
                      ),
                    if (filterType != "All")
                      Chip(
                        label: Text("Type: $filterType"),
                        onDeleted: () {
                          setState(() {
                            filterType = "All";
                          });
                          _fetchOpportunities();
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 16),
              ],

              // Opportunities list heading
              const Text(
                "All Opportunities",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Loading Spinner or Card list with empty state helper
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: CircularProgressIndicator(color: const Color(0xff006565)),
                  ),
                )
              else if (opportunitiesList.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 48),
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_outlined, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        "No matching opportunities found",
                        style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: opportunitiesList.length,
                  itemBuilder: (context, index) {
                    final opp = opportunitiesList[index];
                    return OpportunityCard(
                      opportunity: opp,
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.opportunityActionHub,
                        );
                      },
                    );
                  },
                ),
              const SizedBox(height: 80), // spacer for bottom elements
            ],
          ),
        ),
      ),
    );
  }
}
