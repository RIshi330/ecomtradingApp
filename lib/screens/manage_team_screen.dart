import 'package:flutter/material.dart';
import '../Database/Database.dart';

class ManageTeamScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManageTeamScreen({super.key, this.isEmbedded = false});

  @override
  State<ManageTeamScreen> createState() => _ManageTeamScreenState();
}

class _ManageTeamScreenState extends State<ManageTeamScreen> {
  String selectedTeam = "All Teams";
  String selectedStatus = "Active";
  bool _isLoading = false;
  List<Member> members = [];
  List<String> teamsList = ["All Teams", "Engineering", "Marketing", "Support"];

  @override
  void initState() {
    super.initState();
    _fetchTeams();
    _fetchMembers();
  }

  Future<void> _fetchTeams() async {
    try {
      final response = await Database().getData({
        'action': 'teamlist',
      }, endpoint: 'new_apis/teambuilding_API.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> teamsData = response['data']['teams'] ?? [];
        final List<String> loadedTeams = ["All Teams"];
        for (var t in teamsData) {
          final title = t['team_title']?.toString();
          if (title != null && !loadedTeams.contains(title)) {
            loadedTeams.add(title);
          }
        }
        setState(() {
          teamsList = loadedTeams;
        });
      }
    } catch (e) {
      debugPrint("Error fetching teams: $e");
    }
  }

  Future<void> _fetchMembers() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_team_members_list',
        'team': selectedTeam == "All Teams" ? "" : selectedTeam,
        'status': selectedStatus,
      }, endpoint: 'new_apis/teambuilding_API.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> listData = response['data'] is List ? response['data'] : (response['data']['members'] ?? []);
        setState(() {
          members = listData.map((item) => Member.fromJson(Map<String, dynamic>.from(item))).toList();
        });
      } else {
        setState(() {
          members = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching members: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              elevation: 0,
              backgroundColor: Colors.white,
              title: const Text(
                "Team Building",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    )
                  : null,
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xFFD4E6E5),
                    child: const Text(
                      "AD",
                      style: TextStyle(
                        color: Color(0xFF006565),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
      body: RefreshIndicator(
        onRefresh: _fetchMembers,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildFilters(),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  _isLoading
                      ? "Loading members..."
                      : "Showing ${members.length} members",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (members.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No members found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    return MemberCard(
                      member: members[index],
                      onRefresh: _fetchMembers,
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: "task",
            onPressed: () {
              showAssignTaskDialog(context, null);
            },
            child: const Icon(Icons.task),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: "member",
            onPressed: () {
              showAddMemberDialog(context);
            },
            child: const Icon(Icons.person_add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.small(
            heroTag: "main",
            backgroundColor: const Color(0xFF006565),
            foregroundColor: Colors.white,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                builder: (context) {
                  return SizedBox(
                    height: 250,
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        ListTile(
                          leading: const Icon(Icons.person_add),
                          title: const Text("Add Member"),
                          onTap: () {
                            Navigator.pop(context);
                            showAddMemberDialog(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.task),
                          title: const Text("New Task"),
                          onTap: () {
                            Navigator.pop(context);
                            showAssignTaskDialog(context, null);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.work),
                          title: const Text("Explore Talent"),
                          onTap: () {},
                        ),
                        ListTile(
                          leading: const Icon(Icons.handshake),
                          title: const Text("Explore Partners"),
                          onTap: () {},
                        ),
                      ],
                    ),
                  );
                },
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
      bottomNavigationBar: widget.isEmbedded
          ? null
          : NavigationBar(
              selectedIndex: 1,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard),
                  label: "Dashboard",
                ),
                NavigationDestination(
                  icon: Icon(Icons.list_alt_outlined),
                  selectedIcon: Icon(Icons.list_alt),
                  label: "Directory",
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined),
                  selectedIcon: Icon(Icons.settings),
                  label: "Settings",
                ),
              ],
            ),
    );
  }

  Widget _buildFilters() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          "Team Directory",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1B1B),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.filter_list, color: Color(0xFF006565)),
          onPressed: () {
            showFilterBottomSheet(context);
          },
        ),
      ],
    );
  }

  void showAddMemberDialog(BuildContext context) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    String selectedRole = "Moderator";
    bool createUserAccount = true;
    bool sendWelcomeEmail = true;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Add New Member",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          hintText: "Email Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: mobileController,
                        decoration: InputDecoration(
                          hintText: "Mobile Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedRole,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "Moderator",
                            child: Text("Moderator"),
                          ),
                          DropdownMenuItem(
                            value: "Growth Specialist",
                            child: Text("Growth Specialist"),
                          ),
                          DropdownMenuItem(
                            value: "Support Specialist",
                            child: Text("Support Specialist"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedRole = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 15),
                      CheckboxListTile(
                        value: createUserAccount,
                        onChanged: (v) {
                          setDialogState(() {
                            createUserAccount = v ?? true;
                          });
                        },
                        title: const Text("Create User Account"),
                      ),
                      CheckboxListTile(
                        value: sendWelcomeEmail,
                        onChanged: (v) {
                          setDialogState(() {
                            sendWelcomeEmail = v ?? true;
                          });
                        },
                        title: const Text("Send Welcome Email"),
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final email = emailController.text.trim();
                            final mobile = mobileController.text.trim();

                            if (name.isEmpty || email.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Name and Email are required"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final response = await Database().getData({
                              'action': 'add_new_team_member',
                              'name': name,
                              'email': email,
                              'mobile': mobile,
                              'role': selectedRole,
                              'create_account': createUserAccount ? "1" : "0",
                              'send_email': sendWelcomeEmail ? "1" : "0",
                            }, endpoint: 'new_apis/teambuilding_API.php');

                            if (response['success'] == true) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                _fetchMembers();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Member added successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response['message'] ?? "Failed to add member"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Add Member"),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }

  void showAssignTaskDialog(BuildContext context, String? memberId) {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final deadlineController = TextEditingController();
    String selectedPriority = "Medium";

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Assign Task",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Task Title",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descController,
                        decoration: InputDecoration(
                          hintText: "Description",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        maxLines: 4,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: deadlineController,
                        decoration: InputDecoration(
                          hintText: "Deadline (YYYY-MM-DD)",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          suffixIcon: const Icon(Icons.calendar_month),
                        ),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          if (date != null) {
                            deadlineController.text = "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedPriority,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: "High",
                            child: Text("High"),
                          ),
                          DropdownMenuItem(
                            value: "Medium",
                            child: Text("Medium"),
                          ),
                          DropdownMenuItem(
                            value: "Low",
                            child: Text("Low"),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) {
                            setDialogState(() {
                              selectedPriority = v;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final title = titleController.text.trim();
                            final description = descController.text.trim();
                            final deadline = deadlineController.text.trim();

                            if (title.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Task title is required"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final response = await Database().getData({
                              'action': 'assign_member_task',
                              'member_id': memberId ?? '',
                              'title': title,
                              'description': description,
                              'deadline': deadline,
                              'priority': selectedPriority,
                            }, endpoint: 'new_apis/teambuilding_API.php');

                            if (response['success'] == true) {
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Task assigned successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response['message'] ?? "Failed to assign task"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text("Assign Task"),
                        ),
                      ),
                    ],
                  ),
                );
              }
            ),
          ),
        );
      },
    );
  }

  void showFilterBottomSheet(BuildContext context) {
    String tempTeam = selectedTeam;
    String tempStatus = selectedStatus;
    double tempPerformance = 50;
    String tempRole = "All Roles";

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Members",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            setSheetState(() {
                              tempTeam = "All Teams";
                              tempStatus = "Active";
                              tempPerformance = 50;
                              tempRole = "All Roles";
                            });
                          },
                          child: const Text(
                            "Reset",
                            style: TextStyle(color: Color(0xFF006565)),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      "Team",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: teamsList.contains(tempTeam) ? tempTeam : "All Teams",
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: teamsList
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(e),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        setSheetState(() {
                          tempTeam = v!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Status",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempStatus,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(value: "Active", child: Text("Active")),
                        DropdownMenuItem(value: "Inactive", child: Text("Inactive")),
                        DropdownMenuItem(value: "Pending", child: Text("Pending")),
                      ],
                      onChanged: (v) {
                        setSheetState(() {
                          tempStatus = v!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Role",
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      initialValue: tempRole,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: "All Roles",
                          child: Text("All Roles"),
                        ),
                        DropdownMenuItem(
                          value: "Moderator",
                          child: Text("Moderator"),
                        ),
                        DropdownMenuItem(
                          value: "Growth Lead",
                          child: Text("Growth Lead"),
                        ),
                        DropdownMenuItem(
                          value: "Support Specialist",
                          child: Text("Support Specialist"),
                        ),
                      ],
                      onChanged: (v) {
                        setSheetState(() {
                          tempRole = v!;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Performance Threshold (${tempPerformance.toInt()}%)",
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    Slider(
                      value: tempPerformance,
                      min: 0,
                      max: 100,
                      activeColor: const Color(0xFF006565),
                      inactiveColor: const Color(0xFF006565).withOpacity(0.2),
                      onChanged: (value) {
                        setSheetState(() {
                          tempPerformance = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedTeam = tempTeam;
                            selectedStatus = tempStatus;
                          });
                          _fetchMembers();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
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
}

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onRefresh;

  const MemberCard({
    super.key,
    required this.member,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundImage: member.image.isNotEmpty
                      ? NetworkImage(member.image)
                      : null,
                  child: member.image.isEmpty
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        member.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      Text(
                        member.role,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case "task":
                        _ManageTeamScreenState().showAssignTaskDialog(context, member.id);
                        break;
                      case "contact":
                        showContactDialog(context, member);
                        break;
                      case "team":
                        showAddToTeamDialog(context, member, onRefresh);
                        break;
                      case "submissions":
                        showSubmissionsDialog(context, member);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: "task",
                      child: Text("Assign Task"),
                    ),
                    const PopupMenuItem(
                      value: "contact",
                      child: Text("Contact"),
                    ),
                    const PopupMenuItem(
                      value: "team",
                      child: Text("Add To Team"),
                    ),
                    const PopupMenuItem(
                      value: "submissions",
                      child: Text("Submissions"),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Created: ${member.createdDate}"),
                Chip(
                  backgroundColor: member.status == "Active"
                      ? Colors.green.shade100
                      : Colors.grey.shade300,
                  label: Text(member.status),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xffe5f7f7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${member.submissions} Submissions",
                          style: const TextStyle(
                            color: Color(0xFF006565),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          member.lastSubmission,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 60,
                    height: 60,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CircularProgressIndicator(
                          value: member.progress / 100,
                          strokeWidth: 6,
                        ),
                        Text("${member.progress}%"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showAddToTeamDialog(BuildContext context, Member member, VoidCallback onRefresh) {
    List<Map<String, dynamic>> teams = [
      {"name": "Engineering", "selected": false},
      {"name": "Product Design", "selected": false},
      {"name": "Customer Success", "selected": false},
      {"name": "Marketing", "selected": false},
    ];

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: StatefulBuilder(
              builder: (context, setDialogState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add ${member.name} To Team",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ...teams.map((t) => CheckboxListTile(
                          value: t['selected'],
                          onChanged: (v) {
                            setDialogState(() {
                              t['selected'] = v ?? false;
                            });
                          },
                          title: Text(t['name']),
                        )),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final selectedTeams = teams
                              .where((element) => element['selected'] == true)
                              .map((element) => element['name'] as String)
                              .toList();

                          final response = await Database().getData({
                            'action': 'add_member_to_team',
                            'member_id': member.id,
                            'teams': selectedTeams.join(','),
                          }, endpoint: 'new_apis/teambuilding_API.php');

                          if (response['success'] == true) {
                            if (context.mounted) {
                              Navigator.pop(context);
                              onRefresh();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Team assignment updated successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } else {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(response['message'] ?? "Failed to assign to team"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                        child: const Text("Confirm Assignment"),
                      ),
                    )
                  ],
                );
              }
            ),
          ),
        );
      },
    );
  }

  void showSubmissionsDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 500,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<Map>(
                future: Database().getData({
                  'action': 'get_member_submissions',
                  'member_id': member.id,
                }, endpoint: 'new_apis/teambuilding_API.php'),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final response = snapshot.data;
                  final List<dynamic> submissions = (response != null && response['success'] == true)
                      ? (response['data'] ?? [])
                      : [];

                  return Column(
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Recent Submissions",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                          )
                        ],
                      ),
                      const Divider(),
                      Expanded(
                        child: submissions.isEmpty
                            ? const Center(child: Text("No submissions found"))
                            : ListView.builder(
                                itemCount: submissions.length,
                                itemBuilder: (context, idx) {
                                  final sub = submissions[idx];
                                  return _submissionTile(
                                    icon: Icons.description,
                                    title: sub['title'] ?? 'Submission',
                                    subtitle: sub['submitted_date'] ?? '',
                                    status: sub['status'] ?? 'Pending Review',
                                  );
                                },
                              ),
                      ),
                    ],
                  );
                }
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _submissionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String status,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: const Color(0xFF006565),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: status == "Approved"
                ? Colors.green.shade100
                : const Color(0xFFD4E6E5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            status,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void showContactDialog(BuildContext context, Member member) {
    final TextEditingController chatController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: SizedBox(
            height: 550,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.black12),
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: const Color(0xFF006565),
                        backgroundImage: member.image.isNotEmpty ? NetworkImage(member.image) : null,
                        child: member.image.isEmpty ? Text(member.name.substring(0, 1).toUpperCase()) : null,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Text(
                              "Online",
                              style: TextStyle(
                                color: Colors.green,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "Hello, I noticed the recent moderation spikes. Good work handling those.",
                          ),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF006565),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: const Text(
                            "Thanks! We've implemented the new filters you suggested.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: chatController,
                          decoration: InputDecoration(
                            hintText: "Type message...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      CircleAvatar(
                        backgroundColor: const Color(0xFF006565),
                        child: IconButton(
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            final msg = chatController.text.trim();
                            if (msg.isEmpty) return;

                            final response = await Database().getData({
                              'action': 'contact_member',
                              'member_id': member.id,
                              'message': msg,
                            }, endpoint: 'new_apis/teambuilding_API.php');

                            if (response['success'] == true) {
                              chatController.clear();
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Message sent successfully!"),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(response['message'] ?? "Failed to send message"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      )
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
}

class Member {
  final String id;
  final String name;
  final String role;
  final String status;
  final int submissions;
  final int progress;
  final String createdDate;
  final String lastSubmission;
  final String image;

  Member({
    required this.id,
    required this.name,
    required this.role,
    required this.status,
    required this.submissions,
    required this.progress,
    required this.createdDate,
    required this.lastSubmission,
    required this.image,
  });

  factory Member.fromJson(Map<String, dynamic> json) {
    return Member(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      status: json['status']?.toString() ?? 'Active',
      submissions: int.tryParse(json['submissions']?.toString() ?? '0') ?? 0,
      progress: int.tryParse(json['progress']?.toString() ?? '0') ?? 0,
      createdDate: json['createdDate']?.toString() ?? '',
      lastSubmission: json['lastSubmission']?.toString() ?? 'No submissions yet',
      image: json['image']?.toString() ?? '',
    );
  }
}
