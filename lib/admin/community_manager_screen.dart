import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';

class CommunityManagerScreen extends StatefulWidget {
  final bool isEmbedded;
  const CommunityManagerScreen({super.key, this.isEmbedded = false});

  @override
  State<CommunityManagerScreen> createState() => _CommunityManagerScreenState();
}

class _CommunityManagerScreenState extends State<CommunityManagerScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  bool _isLoading = false;
  bool _isGridView = true;
  String _searchQuery = "";
  
  List<dynamic> _pendingCommunities = [];
  List<dynamic> _managedCommunities = [];

  // Filter states
  String _selectedCategory = 'All';
  String _selectedAccess = 'All'; // All, Free, Paid

  @override
  void initState() {
    super.initState();
    _fetchCommunities();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchCommunities() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final pendingResponse = await Database().getData({
        'action': 'fetch_pending_communities',
      }, endpoint: 'new_apis/community_list_api.php');

      final approvedResponse = await Database().getData({
        'action': 'fetch_approve_communities',
      }, endpoint: 'new_apis/community_list_api.php');

      List<dynamic> pending = [];
      List<dynamic> approved = [];

      if (pendingResponse != null && pendingResponse['success'] == true) {
        pending = pendingResponse['data'] ?? [];
      }
      if (approvedResponse != null && approvedResponse['success'] == true) {
        approved = approvedResponse['data'] ?? [];
      }

      setState(() {
        _pendingCommunities = pending;
        _managedCommunities = approved;
      });
    } catch (e) {
      debugPrint("Error fetching communities: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _approveCommunity(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'update_community_status',
        'community_id': id,
        'status': 1,
      }, endpoint: 'new_apis/community_list_api.php');
      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Community approved successfully")),
        );
        _fetchCommunities();
      }
    } catch (e) {
      debugPrint("Error approving community: $e");
    }
  }

  Future<void> _blockCommunity(int id) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'manage_active_community',
        'community_id': id,
        'action_type': 'block',
      }, endpoint: 'new_apis/community_list_api.php');
      if (response != null && response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Community blocked successfully")),
        );
        _fetchCommunities();
      }
    } catch (e) {
      debugPrint("Error blocking community: $e");
    }
  }

  void _openChatModal(String managerName) {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController messageController = TextEditingController();
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    color: Color(0xFF006565),
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.white24,
                        child: Text(
                          managerName.isNotEmpty ? managerName[0].toUpperCase() : 'U',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              managerName,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const Text(
                              "Community Admin",
                              style: TextStyle(color: Colors.white70, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Messages Body
                Container(
                  height: 200,
                  color: const Color(0xFFE5F7F7).withOpacity(0.3),
                  padding: const EdgeInsets.all(16),
                  child: ListView(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE6E6F0)),
                          ),
                          child: Text(
                            "Hello! I'm the administrator for this community. How can I help you today?",
                            style: TextStyle(fontSize: 13, color: Colors.grey[800]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Input Bar
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: "Type a message...",
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE6E6F0)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          minimumSize: const Size(44, 44),
                          padding: EdgeInsets.zero,
                        ),
                        onPressed: () {
                          messageController.clear();
                        },
                        child: const Icon(Icons.send_rounded, size: 20),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 6,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6F0),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filter Communities",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "CATEGORY",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ['All', 'Music', 'Education', 'Tech'].map((cat) {
                      final isSel = _selectedCategory == cat;
                      return ChoiceChip(
                        label: Text(cat),
                        selected: isSel,
                        onSelected: (selected) {
                          if (selected) {
                            setModalState(() => _selectedCategory = cat);
                            setState(() {});
                          }
                        },
                        selectedColor: const Color(0xFF006565).withOpacity(0.15),
                        backgroundColor: const Color(0xFFF9F9FF),
                        labelStyle: TextStyle(
                          color: isSel ? const Color(0xFF006565) : Colors.grey[700],
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(color: isSel ? const Color(0xFF006565) : const Color(0xFFE6E6F0)),
                        ),
                        showCheckmark: false,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "ACCESS TYPE",
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedAccess == 'Free' ? const Color(0xFF006565).withOpacity(0.05) : Colors.transparent,
                            side: BorderSide(color: _selectedAccess == 'Free' ? const Color(0xFF006565) : const Color(0xFFE6E6F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setModalState(() => _selectedAccess = 'Free');
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: _selectedAccess == 'Free' ? const Color(0xFF006565) : Colors.grey,
                          ),
                          label: Text(
                            "Free",
                            style: TextStyle(
                              color: _selectedAccess == 'Free' ? const Color(0xFF006565) : Colors.black,
                              fontWeight: _selectedAccess == 'Free' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            backgroundColor: _selectedAccess == 'Paid' ? const Color(0xFF006565).withOpacity(0.05) : Colors.transparent,
                            side: BorderSide(color: _selectedAccess == 'Paid' ? const Color(0xFF006565) : const Color(0xFFE6E6F0)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          onPressed: () {
                            setModalState(() => _selectedAccess = 'Paid');
                            setState(() {});
                          },
                          icon: Icon(
                            Icons.check_circle_rounded,
                            color: _selectedAccess == 'Paid' ? const Color(0xFF006565) : Colors.grey,
                          ),
                          label: Text(
                            "Paid",
                            style: TextStyle(
                              color: _selectedAccess == 'Paid' ? const Color(0xFF006565) : Colors.black,
                              fontWeight: _selectedAccess == 'Paid' ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Apply Filters", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    
    // Filter logic
    final filteredManaged = _managedCommunities.where((c) {
      final title = (c['community_title'] ?? c['title'] ?? '').toString().toLowerCase();
      final desc = (c['description'] ?? '').toString().toLowerCase();
      final cat = (c['cat_id'] ?? c['category'] ?? '').toString();
      final access = double.tryParse(c['joining_fee']?.toString() ?? '0') == 0 ? 'Free' : 'Paid';
      
      final matchesSearch = title.contains(_searchQuery.toLowerCase()) || desc.contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || cat.toLowerCase() == _selectedCategory.toLowerCase();
      final matchesAccess = _selectedAccess == 'All' || access == _selectedAccess;
      
      return matchesSearch && matchesCategory && matchesAccess;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search & Filter
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 24),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE6E6F0)),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (val) {
                                setState(() {
                                  _searchQuery = val;
                                });
                              },
                              decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.search, color: Colors.grey),
                                hintText: "Search communities...",
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: _showFilterBottomSheet,
                          child: Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE6E6F0)),
                            ),
                            child: const Icon(Icons.filter_list, color: primaryColor),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Pending section
                  if (_pendingCommunities.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "PENDING APPROVAL (${_pendingCommunities.length})",
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                          ),
                          const Text("View All", style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _pendingCommunities.length,
                        itemBuilder: (context, index) {
                          final c = _pendingCommunities[index];
                          final int id = int.tryParse(c['id']?.toString() ?? '0') ?? 0;
                          final String title = c['community_title'] ?? c['title'] ?? 'Community';
                          final String manager = c['manager_name'] ?? 'Owner';
                          return Container(
                            width: 250,
                            margin: const EdgeInsets.only(right: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE6E6F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFE5F7F7),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        title.isNotEmpty ? title[0].toUpperCase() : 'C',
                                        style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                          Text(manager, style: const TextStyle(color: Colors.grey, fontSize: 10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    Expanded(
                                      child: SizedBox(
                                        height: 28,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryColor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                            padding: EdgeInsets.zero,
                                            elevation: 0,
                                          ),
                                          onPressed: () => _approveCommunity(id),
                                          child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () => _openChatModal(manager),
                                      child: Container(
                                        height: 28,
                                        width: 28,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE5F7F7),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(Icons.chat_bubble_outline_rounded, size: 14, color: primaryColor),
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

                  // Managed Title & View Toggle
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20, top: 28, bottom: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Managed Communities",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F7F7),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _isGridView = true),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: _isGridView ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: _isGridView ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                  ),
                                  child: Icon(Icons.grid_view_rounded, size: 18, color: _isGridView ? primaryColor : Colors.grey),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _isGridView = false),
                                child: Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: !_isGridView ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(6),
                                    boxShadow: !_isGridView ? [const BoxShadow(color: Colors.black12, blurRadius: 4)] : null,
                                  ),
                                  child: Icon(Icons.list_rounded, size: 18, color: !_isGridView ? primaryColor : Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Managed Communities Grid/List
                  filteredManaged.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                          child: Center(child: Text("No communities found.", style: TextStyle(color: Colors.grey))),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: filteredManaged.length,
                          itemBuilder: (context, index) {
                            final c = filteredManaged[index];
                            final int id = int.tryParse(c['id']?.toString() ?? '0') ?? 0;
                            final String title = c['community_title'] ?? c['title'] ?? 'Community';
                            final String desc = stripHtml(c['description'] ?? '');
                            String category = c['community_type']?.toString() ?? c['cat_id']?.toString() ?? 'General';
                            if (category.isEmpty || category == '0' || category == 'null') {
                              category = 'General';
                            }
                            final String manager = c['manager_name'] ?? 'Admin';
                            final String members = c['members_count']?.toString() ?? '0';
                            final String views = c['views']?.toString() ?? '0';
                            
                            final double fee = double.tryParse(c['joining_fee']?.toString() ?? '0') ?? 0;
                            final String accessType = fee == 0 ? 'Free' : 'Paid';

                            return Card(
                              margin: const EdgeInsets.only(bottom: 16),
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(color: Color(0xFFE6E6F0)),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(16),
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
                                                color: const Color(0xFFF9F9FF),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                title.isNotEmpty ? title[0].toUpperCase() : 'C',
                                                style: const TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 18),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                                  const SizedBox(height: 4),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFE5F7F7),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(category, style: const TextStyle(color: primaryColor, fontSize: 9, fontWeight: FontWeight.bold)),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: fee == 0 ? Colors.green[50] : const Color(0xFF006565).withOpacity(0.1),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          accessType,
                                                          style: TextStyle(
                                                            color: fee == 0 ? Colors.green[700] : primaryColor,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                            // Actions
                                            PopupMenuButton<String>(
                                              icon: const Icon(Icons.more_vert, color: Colors.grey),
                                              onSelected: (val) {
                                                if (val == 'block') {
                                                  _blockCommunity(id);
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                const PopupMenuItem(
                                                  value: 'promote',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.campaign_outlined, size: 18),
                                                      SizedBox(width: 8),
                                                      Text("Promote"),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'sponsor',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.volunteer_activism_outlined, size: 18),
                                                      SizedBox(width: 8),
                                                      Text("Sponsor"),
                                                    ],
                                                  ),
                                                ),
                                                const PopupMenuItem(
                                                  value: 'block',
                                                  child: Row(
                                                    children: [
                                                      Icon(Icons.block_flipped, size: 18, color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text("Block Community", style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          desc.isNotEmpty ? desc : "No description provided.",
                                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 12),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Managed by $manager",
                                              style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: primaryColor, size: 18),
                                                  onPressed: () => _openChatModal(manager),
                                                ),
                                                IconButton(
                                                  icon: const Icon(Icons.block_outlined, color: Colors.redAccent, size: 18),
                                                  onPressed: () => _blockCommunity(id),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Stats Grid in Grid View Mode
                                  if (_isGridView)
                                    Container(
                                      color: const Color(0xFFF9F9FF).withOpacity(0.5),
                                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      child: GridView.count(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        crossAxisCount: 3,
                                        childAspectRatio: 2.2,
                                        children: [
                                          _buildStatItem("Members", members),
                                          _buildStatItem("Views", views),
                                          _buildStatItem("Events", "0"),
                                          _buildStatItem("Engagement", "100%", color: primaryColor),
                                          _buildStatItem("Posts", "0"),
                                          _buildStatItem("Access", accessType),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatItem(String label, String value, {Color? color}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }

  String stripHtml(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    String stripped = htmlString.replaceAll(exp, '');
    return stripped.trim();
  }
}
