import 'package:flutter/material.dart';
import '../Database/Database.dart';

class ExplorePartnersScreen extends StatefulWidget {
  final bool isEmbedded;
  const ExplorePartnersScreen({super.key, this.isEmbedded = false});

  @override
  State<ExplorePartnersScreen> createState() => _ExplorePartnersScreenState();
}

class _ExplorePartnersScreenState extends State<ExplorePartnersScreen> {
  bool _isLoading = false;
  List<dynamic> _partners = [];
  List<String> _topSkills = [];
  
  String _searchQuery = "";
  String _selectedLabel = "All"; // "All", "Corporate", "Individual"
  String _selectedSkill = "All";
  String _locationQuery = "";
  bool _isGridView = true;

  @override
  void initState() {
    super.initState();
    _fetchPartners();
  }

  Future<void> _fetchPartners() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Build query parameters
      String queryParams = "";
      List<String> params = [];
      if (_searchQuery.isNotEmpty) {
        // Ripgrep search filters might map search query to skills/label
      }
      if (_selectedSkill != "All") {
        params.add("skills=${Uri.encodeComponent(_selectedSkill)}");
      }
      if (_locationQuery.isNotEmpty) {
        params.add("location=${Uri.encodeComponent(_locationQuery)}");
      }
      if (_selectedLabel != "All") {
        params.add("label=${Uri.encodeComponent(_selectedLabel)}");
      }
      if (params.isNotEmpty) {
        queryParams = "?${params.join('&')}";
      }

      final response = await Database().getData(
        {},
        endpoint: 'new_apis/professionals_List_API.php$queryParams',
      );

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        final list = data['professionals'] ?? [];
        final skillsMap = data['top_skills'] as Map<dynamic, dynamic>? ?? {};
        
        setState(() {
          _partners = list;
          _topSkills = skillsMap.keys.map<String>((k) => k.toString()).toList();
        });
      }
    } catch (e) {
      debugPrint("Error fetching partners: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredPartners {
    return _partners.where((partner) {
      final name = (partner['name'] ?? '').toString().toLowerCase();
      final label = (partner['label'] ?? '').toString().toLowerCase();
      final skills = (partner['prof_skills'] ?? '').toString().toLowerCase();
      
      final matchesSearch = name.contains(_searchQuery.toLowerCase()) || 
                            skills.contains(_searchQuery.toLowerCase());
      
      if (_selectedLabel == "All") return matchesSearch;
      return matchesSearch && label == _selectedLabel.toLowerCase();
    }).toList();
  }

  Future<void> _sendInvitation({
    required String receiverId,
    required String msgType,
    required String message,
    String? startDate,
    String? endDate,
  }) async {
    try {
      final response = await Database().getJsonData({
        'receiver_id': receiverId,
        'msg_type': msgType,
        'message': message,
        if (startDate != null && startDate.isNotEmpty) 'start_date': startDate,
        if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
      }, endpoint: 'new_apis/invite_as_partner_API.php');

      if (mounted) {
        if (response['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Invitation sent successfully!"),
              backgroundColor: const Color(0xFF006565),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Failed to send invitation"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error sending invitation: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                "Explore Partners",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              actions: [
                IconButton(
                  icon: Icon(_isGridView ? Icons.list : Icons.grid_view, color: Color(0xFF006565)),
                  onPressed: () {
                    setState(() {
                      _isGridView = !_isGridView;
                    });
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.mail_outline, color: Color(0xFF006565)),
                  onPressed: () => _showBulkInviteDialog(),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: _fetchPartners,
        color: const Color(0xFF006565),
        child: Column(
          children: [
            _buildSearchAndFilterHeader(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFF006565)))
                  : _filteredPartners.isEmpty
                      ? _buildEmptyState()
                      : _buildPartnersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    onChanged: (v) {
                      setState(() {
                        _searchQuery = v;
                      });
                    },
                    decoration: const InputDecoration(
                      hintText: "Search by partner name or skill...",
                      prefixIcon: Icon(Icons.search, color: Colors.grey),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(),
                child: Container(
                  height: 45,
                  width: 45,
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.tune, color: Color(0xFF006565)),
                ),
              )
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip("All"),
                _buildFilterChip("Corporate"),
                _buildFilterChip("Individual"),
                if (_topSkills.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(width: 8),
                  ..._topSkills.map((skill) => _buildSkillChip(skill)),
                ]
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedLabel == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedLabel = label;
            });
          }
        },
        selectedColor: const Color(0xFF006565),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildSkillChip(String skill) {
    final isSelected = _selectedSkill == skill;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(skill),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedSkill = selected ? skill : "All";
            _fetchPartners();
          });
        },
        selectedColor: const Color(0xFF006565).withOpacity(0.85),
        side: BorderSide.none,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : const Color(0xFF006565),
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.handshake_outlined, size: 80, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                "No Partners Found",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 8),
              Text(
                "Try tweaking your filters or search query.",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
                onPressed: () {
                  setState(() {
                    _searchQuery = "";
                    _selectedLabel = "All";
                    _selectedSkill = "All";
                    _locationQuery = "";
                  });
                  _fetchPartners();
                },
                child: const Text("Reset Filters", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnersList() {
    if (_isGridView) {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.76,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredPartners.length,
        itemBuilder: (context, index) {
          return _buildPartnerCard(_filteredPartners[index]);
        },
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredPartners.length,
      itemBuilder: (context, index) {
        return _buildPartnerListTile(_filteredPartners[index]);
      },
    );
  }

  Widget _buildPartnerCard(dynamic partner) {
    final name = partner['name'] ?? 'Unknown Partner';
    final location = partner['location'] ?? 'Not specified';
    final label = partner['label'] ?? 'Partner';
    final rawSkills = partner['prof_skills'] ?? '';
    final List<String> skills = rawSkills.isNotEmpty
        ? rawSkills.split(',').map<String>((s) => s.trim().toString()).toList()
        : <String>[];
    final avatar = partner['profile_pic'] ?? '';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showPartnerDetails(partner),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    backgroundColor: const Color(0xFF006565).withOpacity(0.15),
                    child: avatar.isEmpty ? const Icon(Icons.business, color: const Color(0xFF006565)) : null,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006565).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      label,
                      style: TextStyle(color: const Color(0xFF006565), fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 12, color: Colors.grey),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Text(
                      location,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: skills
                      .take(3)
                      .map((s) => Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              s,
                              style: const TextStyle(fontSize: 12, color: Colors.black87),
                            ),
                          ))
                      .toList(),
                ),
              ),
              const Divider(height: 12),
              SizedBox(
                width: double.infinity,
                height: 32,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF006565),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: EdgeInsets.zero,
                  ),
                  onPressed: () => _showInviteDialog(partner),
                  child: const Text("Invite", style: TextStyle(color: Colors.white, fontSize: 14)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartnerListTile(dynamic partner) {
    final name = partner['name'] ?? 'Unknown Partner';
    final location = partner['location'] ?? 'Not specified';
    final label = partner['label'] ?? 'Partner';
    final rawSkills = partner['prof_skills'] ?? '';
    final List<String> skills = rawSkills.isNotEmpty
        ? rawSkills.split(',').map<String>((s) => s.trim().toString()).toList()
        : <String>[];
    final avatar = partner['profile_pic'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
          backgroundColor: const Color(0xFF006565).withOpacity(0.15),
          child: avatar.isEmpty ? const Icon(Icons.business, color: const Color(0xFF006565)) : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                label,
                style: TextStyle(color: const Color(0xFF006565), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(location, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: skills
                  .map((s) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(s, style: const TextStyle(fontSize: 12)),
                      ))
                  .toList(),
            )
          ],
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF006565),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () => _showInviteDialog(partner),
          child: const Text("Invite", style: TextStyle(color: Colors.white)),
        ),
        onTap: () => _showPartnerDetails(partner),
      ),
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
                  const Text("Filter Partners", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  const Text("Location", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) {
                      setModalState(() {
                        _locationQuery = v;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Enter City (e.g. Mumbai, Delhi)",
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _locationQuery = "";
                            });
                            Navigator.pop(context);
                            _fetchPartners();
                          },
                          child: const Text("Clear"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
                          onPressed: () {
                            Navigator.pop(context);
                            _fetchPartners();
                          },
                          child: const Text("Apply", style: TextStyle(color: Colors.white)),
                        ),
                      )
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

  void _showPartnerDetails(dynamic partner) {
    final name = partner['name'] ?? 'Unknown Partner';
    final location = partner['location'] ?? 'Not specified';
    final label = partner['label'] ?? 'Partner';
    final rawSkills = partner['prof_skills'] ?? '';
    final avatar = partner['profile_pic'] ?? '';
    final rate = partner['hourly_rate'] ?? '250'; // mocked default

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 50,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
                        backgroundColor: const Color(0xFF006565).withOpacity(0.15),
                        child: avatar.isEmpty ? const Icon(Icons.business, size: 40, color: const Color(0xFF006565)) : null,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF006565).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                style: TextStyle(color: const Color(0xFF006565), fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("About & Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(
                    "Leading provider of premium workspace resources. Partnering with top corporate brands to scale community tasks and professional stitch deliveries.",
                    style: TextStyle(color: Colors.grey.shade700, height: 1.5),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Color(0xFF006565)),
                    title: const Text("Location"),
                    subtitle: Text(location),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.currency_rupee, color: Color(0xFF006565)),
                    title: const Text("Expected Engagement Rate"),
                    subtitle: Text("₹$rate / hr"),
                  ),
                  const SizedBox(height: 12),
                  const Text("Core Focus Skills", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: rawSkills.split(',').map<Widget>((s) => Chip(
                      label: Text(s.trim()),
                      backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                      side: BorderSide.none,
                    )).toList(),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
                      onPressed: () {
                        Navigator.pop(context);
                        _showInviteDialog(partner);
                      },
                      child: const Text("Invite as Partner", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInviteDialog(dynamic partner) {
    final messageController = TextEditingController(
      text: "Hi ${partner['name'] ?? 'Partner'},\n\nWe are impressed by your credentials and would love to invite you as a partner for our community workspace tasks."
    );
    String msgType = "Invite_as_partner";
    final startController = TextEditingController();
    final endController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Invite ${partner['name'] ?? 'Partner'}"),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      value: msgType,
                      decoration: const InputDecoration(labelText: "Invitation Type"),
                      items: const [
                        DropdownMenuItem(value: "Invite_as_partner", child: Text("Invite as Partner")),
                        DropdownMenuItem(value: "Business_proposal", child: Text("Business Proposal")),
                      ],
                      onChanged: (v) {
                        setDialogState(() {
                          msgType = v!;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: messageController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: "Message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: startController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Expected Start Date (Optional)",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 180)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            startController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: endController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: "Expected End Date (Optional)",
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().add(const Duration(days: 7)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            endController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
                  onPressed: () {
                    final message = messageController.text.trim();
                    if (message.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Please enter an invitation message")),
                      );
                      return;
                    }
                    Navigator.pop(context);
                    _sendInvitation(
                      receiverId: (partner['vendor_id'] ?? '13').toString(),
                      msgType: msgType,
                      message: message,
                      startDate: startController.text,
                      endDate: endController.text,
                    );
                  },
                  child: const Text("Send Invite", style: TextStyle(color: Colors.white)),
                )
              ],
            );
          },
        );
      },
    );
  }

  void _showBulkInviteDialog() {
    final emailsController = TextEditingController();
    final messageController = TextEditingController(
      text: "Hi,\n\nWe are looking to invite you to join our partner ecosystem on the trading ecommerce network. Let us collaborate!"
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Bulk Partner Invite"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailsController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: "Emails (comma-separated)",
                  hintText: "partner1@company.com, partner2@company.com",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Common Message",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565)),
              onPressed: () {
                final emailsStr = emailsController.text.trim();
                final message = messageController.text.trim();
                if (emailsStr.isEmpty || message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Emails and message are required")),
                  );
                  return;
                }
                
                // Demo invite triggers
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Bulk invitation sent to ${emailsStr.split(',').length} addresses!"),
                    backgroundColor: const Color(0xFF006565),
                  ),
                );
              },
              child: const Text("Send Bulk", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }
}
