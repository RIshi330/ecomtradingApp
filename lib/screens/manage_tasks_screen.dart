import 'package:flutter/material.dart';
import '../Database/Database.dart';
import 'task_submissions_screen.dart';

class ManageTasksScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManageTasksScreen({super.key, this.isEmbedded = false});

  @override
  State<ManageTasksScreen> createState() => _ManageTasksScreenState();
}

class _ManageTasksScreenState extends State<ManageTasksScreen> {
  bool _isLoading = false;
  List<dynamic> _tasks = [];
  List<dynamic> _members = [];
  List<dynamic> _teams = [];

  String _selectedPriorityFilter = "All";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'init',
      }, endpoint: 'new_apis/task_manager_api.php');

      if (response['success'] == true || response['status'] == 'ok') {
        final data = response['data'] ?? {};
        setState(() {
          _tasks = data['tasks'] ?? [];
          _members = data['members'] ?? [];
          _teams = data['teams'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error loading tasks: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<dynamic> get _filteredTasks {
    return _tasks.where((task) {
      final title = (task['title'] ?? '').toString().toLowerCase();
      final desc = (task['desc'] ?? '').toString().toLowerCase();
      final matchesSearch = title.contains(_searchQuery.toLowerCase()) ||
          desc.contains(_searchQuery.toLowerCase());

      if (_selectedPriorityFilter == "All") return matchesSearch;
      final taskPriority = (task['priority'] ?? 'normal').toString().toLowerCase();
      return matchesSearch && taskPriority == _selectedPriorityFilter.toLowerCase();
    }).toList();
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
                "Task Management",
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
              ),
              iconTheme: const IconThemeData(color: Colors.black),
            ),
      body: RefreshIndicator(
        onRefresh: _fetchData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 20),
              _buildSearchAndFilters(),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_filteredTasks.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No tasks found.",
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredTasks.length,
                  itemBuilder: (context, index) {
                    final task = _filteredTasks[index];
                    return _buildTaskCard(task);
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.small(
        backgroundColor: const Color(0xFF006565),
        foregroundColor: Colors.white,
        onPressed: () => _showNewTaskWizard(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Tasks Overview",
          style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          "Manage your daily stitches and team deadlines.",
          style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            onChanged: (v) {
              setState(() {
                _searchQuery = v;
              });
            },
            decoration: InputDecoration(
              hintText: "Search tasks...",
              prefixIcon: const Icon(Icons.search),
              fillColor: Colors.white,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        DropdownButton<String>(
          value: _selectedPriorityFilter,
          underline: const SizedBox(),
          icon: const Icon(Icons.filter_list),
          items: ["All", "Low", "Normal", "High", "Urgent"]
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: (v) {
            setState(() {
              _selectedPriorityFilter = v!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTaskCard(dynamic task) {
    final priority = (task['priority'] ?? 'normal').toString().toUpperCase();
    final title = task['title'] ?? 'Untitled';
    final desc = task['desc'] ?? 'No description provided.';
    final deadline = task['deadline'] ?? '';
    final progress = task['status'] == 2 ? 100 : 40; // Mock progression status

    Color priorityColor = Colors.grey;
    if (priority == "HIGH" || priority == "URGENT") {
      priorityColor = Colors.red;
    } else if (priority == "NORMAL") {
      priorityColor = Colors.orange;
    } else {
      priorityColor = Colors.blue;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TaskSubmissionsScreen(
                taskId: task['id']?.toString() ?? '',
                taskTitle: title,
              ),
            ),
          ).then((_) => _fetchData());
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: priorityColor.withAlpha(25),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      priority,
                      style: TextStyle(
                        color: priorityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      const Icon(Icons.calendar_month, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        deadline,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  )
                ],
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 6),
              Text(
                desc,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                  Text(
                    "$progress%",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006565), fontSize: 12),
                  )
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress / 100.0,
                  backgroundColor: const Color(0xFF006565).withOpacity(0.1),
                  color: const Color(0xFF006565),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Click to View Submissions",
                    style: TextStyle(color: const Color(0xFF006565).withOpacity(0.6), fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 12, color: Color(0xFF006565)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewTaskWizard(BuildContext context) {
    int currentStep = 1;
    String taskType = "Internal"; // "Internal" or "Client"
    String selectedClient = "StitchGlobal";
    List<String> clients = ["StitchGlobal", "Velvet Media"];
    
    final titleController = TextEditingController();
    final descController = TextEditingController();
    final deadlineController = TextEditingController();
    String priority = "Medium";
    final List<dynamic> selectedMembers = [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            Widget buildStepContent() {
              if (currentStep == 1) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Who is this task for?",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                taskType = "Internal";
                                currentStep = 3;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFBDC9C8), width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                children: [
                                  CircleAvatar(child: Icon(Icons.person)),
                                  SizedBox(height: 10),
                                  Text("Myself", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("Internal task", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              setDialogState(() {
                                taskType = "Client";
                                currentStep = 2;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFFBDC9C8), width: 2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Column(
                                children: [
                                  CircleAvatar(child: Icon(Icons.corporate_fare)),
                                  SizedBox(height: 10),
                                  Text("A Client", style: TextStyle(fontWeight: FontWeight.bold)),
                                  Text("External project", style: TextStyle(fontSize: 11, color: Colors.grey)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              } else if (currentStep == 2) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ...clients.map((c) => ListTile(
                          title: Text(c),
                          leading: const Icon(Icons.business),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            setDialogState(() {
                              selectedClient = c;
                              currentStep = 3;
                            });
                          },
                        )),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.add, color: Color(0xFF006565)),
                      title: const Text("Add New Client", style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold)),
                      onTap: () {
                        final clientController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text("New Client"),
                            content: TextField(
                              controller: clientController,
                              decoration: const InputDecoration(labelText: "Client Name"),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () {
                                  if (clientController.text.isNotEmpty) {
                                    setDialogState(() {
                                      clients.add(clientController.text);
                                      selectedClient = clientController.text;
                                      currentStep = 3;
                                    });
                                  }
                                  Navigator.pop(ctx);
                                },
                                child: const Text("Add"),
                              )
                            ],
                          ),
                        );
                      },
                    )
                  ],
                );
              } else {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: "Task Title", hintText: "What needs to be done?"),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: descController,
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: "Description", hintText: "Add context or notes..."),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: deadlineController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: "Deadline", suffixIcon: Icon(Icons.calendar_today)),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 365)),
                              );
                              if (picked != null) {
                                setDialogState(() {
                                  deadlineController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: priority,
                            decoration: const InputDecoration(labelText: "Priority"),
                            items: ["Low", "Medium", "High"]
                                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                                .toList(),
                            onChanged: (v) {
                              setDialogState(() {
                                priority = v!;
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Assign to Team Members", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 50,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _members.length,
                        itemBuilder: (context, idx) {
                          final member = _members[idx];
                          final isSelected = selectedMembers.contains(member['id']);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: FilterChip(
                              label: Text(member['name'] ?? ''),
                              selected: isSelected,
                              onSelected: (selected) {
                                setDialogState(() {
                                  if (selected) {
                                    selectedMembers.add(member['id']);
                                  } else {
                                    selectedMembers.remove(member['id']);
                                  }
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setDialogState(() {
                                if (taskType == "Client") {
                                  currentStep = 2;
                                } else {
                                  currentStep = 1;
                                }
                              });
                            },
                            child: const Text("Back"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              final title = titleController.text.trim();
                              final desc = descController.text.trim();
                              final deadline = deadlineController.text.trim();

                              if (title.isEmpty || deadline.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text("Title and deadline are required")),
                                );
                                return;
                              }

                              final pMap = {"Low": -1, "Medium": 0, "High": 1};
                              final priorityInt = pMap[priority] ?? 0;

                              final response = await Database().getData({
                                'action': 'create_task',
                                'title': title,
                                'desc': desc,
                                'priority': priorityInt,
                                'start_date': DateTime.now().toString().substring(0, 19),
                                'end_date': "$deadline 23:59:59",
                              }, endpoint: 'new_apis/task_manager_api.php');

                              if (response['success'] == true || response['status'] == 'ok') {
                                final newTaskId = response['data'] != null ? response['data']['id'] : null;
                                
                                // Assign to selected members
                                if (newTaskId != null && selectedMembers.isNotEmpty) {
                                  for (var memberId in selectedMembers) {
                                    await Database().getData({
                                      'action': 'assign_task',
                                      'task_id': newTaskId,
                                      'assigned_to': memberId,
                                      'deadline': deadline,
                                    }, endpoint: 'new_apis/task_manager_api.php');
                                  }
                                }

                                if (context.mounted) {
                                  Navigator.pop(context);
                                  _fetchData();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("Task created successfully!")),
                                  );
                                }
                              } else {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(response['message'] ?? "Error creating task")),
                                  );
                                }
                              }
                            },
                            child: const Text("Create"),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currentStep == 1
                        ? "New Task"
                        : (currentStep == 2 ? "Select Client" : "Task Details"),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              content: SingleChildScrollView(
                child: buildStepContent(),
              ),
            );
          },
        );
      },
    );
  }
}
