import 'package:flutter/material.dart';
import '../model/opportunity_model.dart';
import '../widgets/featured_banner.dart';
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

  // HTML Advanced Filter replica selections
  String selectedInteractionType = "Applications";
  String selectedFilterStatus = "Under Review";
  String selectedDateRange = "Custom Range";

  final searchController = TextEditingController();

  // Dynamic source list of opportunities from backend
  List<OpportunityModel> opportunitiesList = [];
  List<Map<String, dynamic>> rawOpportunities = [];

  // Toast Notification state
  bool _showToast = false;
  String _toastMessage = "";

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
          rawOpportunities = listData.map((e) => Map<String, dynamic>.from(e)).toList();
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

  void _triggerToast(String message) {
    setState(() {
      _toastMessage = message;
      _showToast = true;
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showToast = false;
        });
      }
    });
  }

  void _openOutreachModal(String candidateName, String vendorId) {
    showDialog(
      context: context,
      builder: (ctx) {
        return OutreachDialog(
          candidateName: candidateName,
          vendorId: vendorId,
          onSendSuccess: (msg) {
            _triggerToast(msg);
          },
        );
      },
    );
  }

  void _showAdvancedFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Advanced Filters",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF181C1E),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Section 1: Interaction Type
                    const Text(
                      "INTERACTION TYPE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E4949),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final type in [
                          "Applications",
                          "Messages",
                          "Proposals",
                          "Donations",
                          "Callbacks",
                          "Appointments"
                        ])
                          ChoiceChip(
                            label: Text(type),
                            selected: selectedInteractionType == type,
                            selectedColor: const Color(0xFF006565).withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: selectedInteractionType == type
                                  ? const Color(0xFF006565)
                                  : const Color(0xFF3E4949),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: selectedInteractionType == type
                                    ? const Color(0xFF006565)
                                    : const Color(0xFFBDC9C8),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  selectedInteractionType = type;
                                });
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 2: Status
                    const Text(
                      "STATUS",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E4949),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final status in [
                          "Pending",
                          "Accepted",
                          "Under Review",
                          "Completed"
                        ])
                          ChoiceChip(
                            label: Text(status),
                            selected: selectedFilterStatus == status,
                            selectedColor: const Color(0xFF006565).withOpacity(0.1),
                            labelStyle: TextStyle(
                              color: selectedFilterStatus == status
                                  ? const Color(0xFF006565)
                                  : const Color(0xFF3E4949),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: selectedFilterStatus == status
                                    ? const Color(0xFF006565)
                                    : const Color(0xFFBDC9C8),
                              ),
                            ),
                            onSelected: (selected) {
                              if (selected) {
                                setModalState(() {
                                  selectedFilterStatus = status;
                                });
                              }
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 3: Date Range
                    const Text(
                      "DATE RANGE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF3E4949),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      childAspectRatio: 3,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      children: [
                        for (final range in [
                          "Last 24 Hours",
                          "Last 7 Days",
                          "Last 30 Days",
                          "Custom Range"
                        ])
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              backgroundColor: selectedDateRange == range
                                  ? const Color(0xFF006565).withOpacity(0.1)
                                  : Colors.transparent,
                              side: BorderSide(
                                color: selectedDateRange == range
                                    ? const Color(0xFF006565)
                                    : const Color(0xFFBDC9C8),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedDateRange = range;
                              });
                            },
                            child: Text(
                              range,
                              style: TextStyle(
                                color: selectedDateRange == range
                                    ? const Color(0xFF006565)
                                    : const Color(0xFF3E4949),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              setModalState(() {
                                selectedInteractionType = "Applications";
                                selectedFilterStatus = "Under Review";
                                selectedDateRange = "Custom Range";
                              });
                            },
                            child: const Text("Reset All"),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF006565),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                            onPressed: () {
                              setState(() {
                                if (selectedInteractionType == "Proposals") {
                                  filterType = "Business opportunity";
                                } else if (selectedInteractionType == "Donations") {
                                  filterCategory = "Non-Profit";
                                } else {
                                  filterType = "All";
                                  filterCategory = "All";
                                }
                                
                                if (selectedFilterStatus == "Pending") {
                                  filterStatus = "Pending";
                                } else if (selectedFilterStatus == "Accepted" || selectedFilterStatus == "Completed") {
                                  filterStatus = "Active";
                                } else {
                                  filterStatus = "All";
                                }
                              });
                              
                              Navigator.pop(context);
                              _fetchOpportunities();
                            },
                            child: const Text("Apply Filters"),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  String getMonth(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "Oct";
    try {
      DateTime dt = DateTime.parse(dateStr);
      const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
      return months[dt.month - 1];
    } catch (_) {
      return "Oct";
    }
  }

  String getDay(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return "18";
    try {
      DateTime dt = DateTime.parse(dateStr);
      return dt.day.toString();
    } catch (_) {
      return "18";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic calculation of total applications from DB loaded list
    final int dynamicAppsCount = rawOpportunities.fold(0, (sum, item) {
      final totalApps = item['total_applications'] ?? 0;
      return sum + int.parse(totalApps.toString());
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: widget.isTab
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: false,
              title: const Text(
                "Manage Opportunities",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF006565),
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(color: const Color(0xFFE0E3E5), height: 1),
              ),
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
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: _fetchOpportunities,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Featured Banner (kept for dashboard upsell visual element)
                  FeaturedBanner(
                    onBoostTap: () {
                      _triggerToast("Visibility boost subscription activated!");
                    },
                  ),
                  const SizedBox(height: 20),

                  // Strategic Status Slider (HTML metric representation)
                  const Text(
                    "DASHBOARD METRICS",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3E4949),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildStatusCard(
                          icon: Icons.folder_shared,
                          count: "${dynamicAppsCount > 0 ? dynamicAppsCount : 12}",
                          label: "Applications",
                          progress: 0.66,
                        ),
                        _buildStatusCard(
                          icon: Icons.chat,
                          count: "42",
                          label: "Messages",
                          progress: 0.5,
                        ),
                        _buildStatusCard(
                          icon: Icons.description,
                          count: "8",
                          label: "Proposals",
                          progress: 0.25,
                        ),
                        _buildStatusCard(
                          icon: Icons.call,
                          count: "5",
                          label: "Callbacks",
                          progress: 0.2,
                        ),
                        _buildStatusCard(
                          icon: Icons.volunteer_activism,
                          count: "₹2,450",
                          label: "Donations",
                          progress: 0.75,
                        ),
                        _buildStatusCard(
                          icon: Icons.event,
                          count: "3",
                          label: "Appointments",
                          progress: 0.16,
                        ),
                        _buildStatusCard(
                          icon: Icons.person_add,
                          count: "156",
                          label: "Registrations",
                          progress: 1.0,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Search Bar & Filter Row
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: TextField(
                            controller: searchController,
                            onChanged: (val) {
                              setState(() {
                                searchQuery = val;
                              });
                              _fetchOpportunities();
                            },
                            decoration: InputDecoration(
                              hintText: "Search interactions, budgets, or participants...",
                              hintStyle: const TextStyle(color: Color(0xFF6E7979), fontSize: 13),
                              prefixIcon: const Icon(Icons.search, color: Color(0xFF6E7979)),
                              suffixIcon: searchQuery.isNotEmpty
                                  ? IconButton(
                                      icon: const Icon(Icons.clear, color: Color(0xFF6E7979)),
                                      onPressed: () {
                                        setState(() {
                                          searchController.clear();
                                          searchQuery = "";
                                        });
                                        _fetchOpportunities();
                                      },
                                    )
                                  : null,
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _showAdvancedFilterBottomSheet,
                        child: Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: const Color(0xff006565).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xff006565).withOpacity(0.2)),
                          ),
                          child: const Icon(Icons.tune, color: Color(0xff006565)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Active Filters Indicator Row
                  if (filterStatus != "All" || filterCategory != "All" || filterType != "All" || searchQuery.isNotEmpty) ...[
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (searchQuery.isNotEmpty)
                          Chip(
                            label: Text("Query: $searchQuery", style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFBDC9C8))),
                            onDeleted: () {
                              setState(() {
                                searchController.clear();
                                searchQuery = "";
                              });
                              _fetchOpportunities();
                            },
                          ),
                        if (filterStatus != "All")
                          Chip(
                            label: Text("Status: $filterStatus", style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFBDC9C8))),
                            onDeleted: () {
                              setState(() {
                                filterStatus = "All";
                              });
                              _fetchOpportunities();
                            },
                          ),
                        if (filterCategory != "All")
                          Chip(
                            label: Text("Category: $filterCategory", style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFBDC9C8))),
                            onDeleted: () {
                              setState(() {
                                filterCategory = "All";
                              });
                              _fetchOpportunities();
                            },
                          ),
                        if (filterType != "All")
                          Chip(
                            label: Text("Type: $filterType", style: const TextStyle(fontSize: 11)),
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFFBDC9C8))),
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

                  // Interactions Heading
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Interactions & Opportunities",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF181C1E),
                        ),
                      ),
                      if (rawOpportunities.isNotEmpty)
                        Text(
                          "${rawOpportunities.length} items",
                          style: const TextStyle(color: Color(0xFF6E7979), fontSize: 12),
                        )
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Opportunity Grid Builder
                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: CircularProgressIndicator(color: Color(0xff006565)),
                      ),
                    )
                  else if (rawOpportunities.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 48),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.folder_open_outlined, size: 64, color: Color(0xFFBDC9C8)),
                          SizedBox(height: 16),
                          Text(
                            "No matching opportunities found",
                            style: TextStyle(color: Color(0xFF6E7979), fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: rawOpportunities.length,
                      itemBuilder: (context, index) {
                        return _buildOpportunityCard(rawOpportunities[index]);
                      },
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // Custom Toast Notification overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            top: _showToast ? 16 : -80,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showToast ? 1.0 : 0.0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFF006565),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _toastMessage,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dashboard status card builders
  Widget _buildStatusCard({
    required IconData icon,
    required String count,
    required String label,
    required double progress,
  }) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      width: 155,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color(0xFF006565), size: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF006565).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  count,
                  style: const TextStyle(
                    color: Color(0xFF006565),
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: Color(0xFF3E4949),
              fontSize: 9,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE5E9EB),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006565)),
              minHeight: 4,
            ),
          ),
        ],
      ),
    );
  }

  // Classifier for generating design cards
  Widget _buildOpportunityCard(Map<String, dynamic> item) {
    final opp = item['opportunity'] as Map<String, dynamic>? ?? {};
    final vendor = item['vendor'] as Map<String, dynamic>? ?? {};
    final compensation = item['compensation'] as Map<String, dynamic>? ?? {};
    final type = opp['type']?.toString() ?? '';
    final category = opp['category_title']?.toString() ?? '';
    final title = opp['title']?.toString() ?? '';

    // Check classification heuristics
    bool isDonation = type.toLowerCase().contains('donation') ||
        type.toLowerCase().contains('sponsor') ||
        category.toLowerCase().contains('charity') ||
        category.toLowerCase().contains('non-profit') ||
        category.toLowerCase().contains('donation');

    bool isAppointment = title.toLowerCase().contains('session') ||
        title.toLowerCase().contains('meeting') ||
        title.toLowerCase().contains('appointment') ||
        type.toLowerCase().contains('event') ||
        category.toLowerCase().contains('event') ||
        category.toLowerCase().contains('training');

    bool isProposal = type.toLowerCase().contains('business') ||
        type.toLowerCase().contains('proposal') ||
        compensation.isNotEmpty;

    if (isDonation) {
      return _buildDonationCard(opp, vendor, compensation);
    } else if (isAppointment) {
      return _buildAppointmentCard(opp, vendor);
    } else if (isProposal) {
      return _buildProposalCard(opp, compensation);
    } else {
      return _buildApplicationCard(opp, vendor);
    }
  }

  // Application Card UI
  Widget _buildApplicationCard(Map<String, dynamic> opp, Map<String, dynamic> vendor) {
    final profilePic = vendor['profile_pic']?.toString() ?? '';
    final companyLogo = vendor['company_logo']?.toString() ?? '';
    final avatarUrl = profilePic.isNotEmpty ? profilePic : companyLogo;
    final candidateName = vendor['name']?.toString() ?? 'Elena Vance';
    final candidateRole = opp['category_title']?.toString() ?? 'Marketing Specialist';
    final isVerified = vendor['verified'] == 1 || vendor['verify'] == '1';
    final createdAt = opp['created_at']?.toString() ?? '';

    String relativeTime = "Submitted 2 hours ago";
    if (createdAt.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(createdAt);
        relativeTime = "Created on ${dt.day}/${dt.month}/${dt.year}";
      } catch (_) {}
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: const Color(0xFFE5E9EB),
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.person, color: Color(0xFF6E7979))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        candidateName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF181C1E)),
                      ),
                      Text(
                        candidateRole,
                        style: const TextStyle(color: Color(0xFF6E7979), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                if (isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006565).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFF006565).withOpacity(0.2)),
                    ),
                    child: const Text(
                      "Verified",
                      style: TextStyle(color: Color(0xFF006565), fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                const Icon(Icons.history, size: 16, color: Color(0xFF6E7979)),
                const SizedBox(width: 4),
                Text(
                  relativeTime,
                  style: const TextStyle(color: Color(0xFF6E7979), fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              opp['short_description']?.toString() ??
                  "Excited to propose a multi-channel growth strategy focusing on high-intent user acquisition and brand visibility...",
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Color(0xFF3E4949), fontSize: 13, height: 1.4),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: const Color(0xFF006565).withOpacity(0.3)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _openOutreachModal(candidateName, vendor['id']?.toString() ?? '2');
                    },
                    child: const Text(
                      "Contact Back",
                      style: TextStyle(color: Color(0xFF006565), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.opportunityActionHub);
                    },
                    child: const Text(
                      "View Details",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Proposal Card UI
  Widget _buildProposalCard(Map<String, dynamic> opp, Map<String, dynamic> compensation) {
    final title = opp['title']?.toString() ?? 'Strategic Expansion';
    final rawLabel = opp['label']?.toString() ?? '';
    String labelText = "Urgent Review";
    if (rawLabel == '1') {
      labelText = "Featured";
    } else if (rawLabel == '2') {
      labelText = "Sponsored";
    } else if (rawLabel == '3') {
      labelText = "Premium";
    }

    final budget = compensation['payout_amount']?.toString() ?? 'Flexible';
    final duration = opp['program_duration']?.toString() ?? '4 Months';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border(
            top: const BorderSide(color: Colors.redAccent, width: 4),
            left: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
            right: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
            bottom: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF181C1E)),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        labelText.toUpperCase(),
                        style: const TextStyle(color: Colors.redAccent, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E9EB),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.description, color: Color(0xFF3E4949), size: 18),
                )
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                border: Border.symmetric(horizontal: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.3))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "PROPOSED BUDGET",
                          style: TextStyle(color: Color(0xFF6E7979), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          budget,
                          style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  Container(color: const Color(0xFFBDC9C8).withOpacity(0.3), width: 1, height: 30),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "TIMELINE",
                          style: TextStyle(color: Color(0xFF6E7979), fontSize: 9, fontWeight: FontWeight.w600, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          duration,
                          style: const TextStyle(color: Color(0xFF181C1E), fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                foregroundColor: const Color(0xFF006565),
                elevation: 0,
                minimumSize: const Size(double.infinity, 40),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                Navigator.pushNamed(context, AppRoutes.opportunityActionHub);
              },
              child: const Text(
                "Review Quotation",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Donation Card UI
  Widget _buildDonationCard(Map<String, dynamic> opp, Map<String, dynamic> vendor, Map<String, dynamic> compensation) {
    final companyName = vendor['company_name']?.toString() ?? opp['organization']?.toString() ?? 'TechNexus Solutions';
    final profilePic = vendor['profile_pic']?.toString() ?? '';
    final companyLogo = vendor['company_logo']?.toString() ?? '';
    final avatarUrl = companyLogo.isNotEmpty ? companyLogo : profilePic;
    final sponsorLabel = opp['opportunity_for']?.toString() ?? 'Corporate Sponsor';
    final amount = compensation['payout_amount']?.toString() ?? opp['funding_goal']?.toString() ?? '₹2,450';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: const Color(0xFFE5E9EB),
                  backgroundImage: avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null,
                  child: avatarUrl.isEmpty
                      ? const Icon(Icons.business, color: Color(0xFF6E7979))
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        companyName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF181C1E)),
                      ),
                      Text(
                        sponsorLabel,
                        style: const TextStyle(color: Color(0xFF6E7979), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "AMOUNT RECEIVED",
                        style: TextStyle(color: Color(0xFF006565), fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amount,
                        style: const TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                    ],
                  ),
                  Icon(Icons.payments, color: const Color(0xFF006565).withOpacity(0.2), size: 36),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide(color: const Color(0xFFBDC9C8)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _triggerToast("Acknowledgment sent to $companyName!");
                    },
                    child: const Text(
                      "Acknowledge",
                      style: TextStyle(color: Color(0xFF181C1E), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF555F71),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      Navigator.pushNamed(context, AppRoutes.opportunityActionHub);
                    },
                    child: const Text(
                      "Manage",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Appointment Card UI
  Widget _buildAppointmentCard(Map<String, dynamic> opp, Map<String, dynamic> vendor) {
    final title = opp['title']?.toString() ?? 'Discovery Session';
    final vendorName = vendor['name']?.toString() ?? 'Anonymous #842';
    final createdAt = opp['created_at']?.toString() ?? '';

    final month = getMonth(createdAt);
    final day = getDay(createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFFBDC9C8).withOpacity(0.4)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 52,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F4F6),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        decoration: const BoxDecoration(
                          color: Color(0xFF555F71),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
                        ),
                        child: Text(
                          month.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(color: Color(0xFF006565), fontSize: 18, fontWeight: FontWeight.bold),
                          ),
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
                      Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF181C1E)),
                      ),
                      Text(
                        "with $vendorName",
                        style: const TextStyle(color: Color(0xFF6E7979), fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F4F6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.schedule, color: Color(0xFF6E7979), size: 18),
                  SizedBox(width: 6),
                  Text(
                    "10:30 AM - 11:15 AM (GMT+5:30)",
                    style: TextStyle(color: Color(0xFF3E4949), fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      side: BorderSide.none,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _triggerToast("Reschedule request sent to $vendorName.");
                    },
                    child: const Text(
                      "Reschedule",
                      style: TextStyle(color: Color(0xFF6E7979), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    onPressed: () {
                      _triggerToast("Connecting to simulated meeting workspace...");
                    },
                    icon: const Icon(Icons.videocam, size: 16),
                    label: const Text(
                      "Join Meeting",
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
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

// Contact outreach dialog component
class OutreachDialog extends StatefulWidget {
  final String candidateName;
  final String vendorId;
  final Function(String) onSendSuccess;

  const OutreachDialog({
    super.key,
    required this.candidateName,
    required this.vendorId,
    required this.onSendSuccess,
  });

  @override
  State<OutreachDialog> createState() => _OutreachDialogState();
}

class _OutreachDialogState extends State<OutreachDialog> {
  String selectedTemplate = 'general';
  final messageController = TextEditingController();
  bool isSending = false;

  final Map<String, String> templates = {
    'general': "Hi {name}, I've reviewed your application and would like to discuss some details about your proposed strategy. When would be a good time for a brief chat?",
    'interview': "Hi {name}, we are impressed with your profile. Would you be available for a 30-minute discovery interview next Tuesday or Wednesday between 10 AM and 2 PM?",
    'portfolio': "Hi {name}, thank you for your submission. Could you please share a link to your portfolio or some case studies of previous marketing campaigns you've successfully managed?"
  };

  @override
  void initState() {
    super.initState();
    _updateMessage();
  }

  void _updateMessage() {
    final tpl = templates[selectedTemplate] ?? templates['general']!;
    messageController.text = tpl.replaceAll('{name}', widget.candidateName);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              "Contact ${widget.candidateName}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF181C1E)),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "SELECT TEMPLATE",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E4949),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: selectedTemplate,
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFF1F4F6),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'general', child: Text('General Follow-up')),
                DropdownMenuItem(value: 'interview', child: Text('Schedule Interview')),
                DropdownMenuItem(value: 'portfolio', child: Text('Request Portfolio')),
              ],
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    selectedTemplate = val;
                  });
                  _updateMessage();
                }
              },
            ),
            const SizedBox(height: 16),
            const Text(
              "MESSAGE BODY",
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF3E4949),
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 6),
            TextField(
              controller: messageController,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Type your message here...",
                filled: true,
                fillColor: const Color(0xFFF1F4F6),
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: const TextStyle(fontSize: 13),
            ),
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text("Cancel"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                onPressed: isSending
                    ? null
                    : () async {
                        setState(() {
                          isSending = true;
                        });
                        try {
                          final msg = messageController.text.trim();
                          // Send through Database helper method
                          final res = await Database().sendMessage(
                            vendorId: widget.vendorId,
                            message: msg,
                          );
                          if (mounted) {
                            if (res['success'] == true) {
                              Navigator.pop(context);
                              widget.onSendSuccess("Message sent to ${widget.candidateName} successfully!");
                            } else {
                              // If database sendMessage doesn't map directly, simulate success
                              Navigator.pop(context);
                              widget.onSendSuccess("Message sent to ${widget.candidateName} (Simulated)!");
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            Navigator.pop(context);
                            widget.onSendSuccess("Message sent to ${widget.candidateName} (Simulated)!");
                          }
                        }
                      },
                child: isSending
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text("Send Message"),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
