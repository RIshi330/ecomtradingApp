import 'package:flutter/material.dart';
import '../Database/Database.dart';

class TaskSubmissionsScreen extends StatefulWidget {
  final String taskId;
  final String taskTitle;

  const TaskSubmissionsScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
  });

  @override
  State<TaskSubmissionsScreen> createState() => _TaskSubmissionsScreenState();
}

class _TaskSubmissionsScreenState extends State<TaskSubmissionsScreen> {
  bool _isLoading = false;
  List<dynamic> _submissions = [];

  @override
  void initState() {
    super.initState();
    _fetchSubmissions();
  }

  Future<void> _fetchSubmissions() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Database().getData({
        'action': 'list_submissions_for_task',
        'task_id': widget.taskId,
      }, endpoint: 'new_apis/task_manager_api.php');

      // Note: list_submissions_for_task returns list of submissions under data key
      if (response['success'] == true || response['status'] == 'ok') {
        setState(() {
          _submissions = response['data'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching submissions: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApproval(String action) async {
    try {
      final response = await Database().getData({
        'action': 'approve_task',
        'task_id': widget.taskId,
        'action_type': action, // approved or rejected
      }, endpoint: 'new_apis/task_manager_api.php');

      if (response['success'] == true || response['status'] == 'ok') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Task successfully ${action == 'approved' ? 'approved' : 'rejected'}!"),
              backgroundColor: action == 'approved' ? Colors.green : Colors.red,
            ),
          );
        }
        _fetchSubmissions();
      }
    } catch (e) {
      debugPrint("Error handling approval: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9FF),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          widget.taskTitle,
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: _fetchSubmissions,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Submissions Received",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                "Review attachments and give feedback or approvals.",
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
              const SizedBox(height: 20),
              if (_isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_submissions.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      "No submissions have been received for this task yet.",
                      style: TextStyle(color: Colors.grey, fontSize: 15),
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _submissions.length,
                  itemBuilder: (context, index) {
                    final submission = _submissions[index];
                    return _buildSubmissionCard(submission);
                  },
                )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmissionCard(dynamic sub) {
    final fileName = sub['fileName'] ?? 'submission.file';
    final path = sub['path'] ?? '';
    final date = sub['at'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      child: Icon(Icons.person, size: 18),
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Team Member",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          "Uploader",
                          style: TextStyle(color: Colors.grey, fontSize: 11),
                        ),
                      ],
                    )
                  ],
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                )
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "NOTES",
              style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 4),
            Text(
              "Review request submitted with attachments. Please review standard checks.",
              style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
            ),
            const SizedBox(height: 16),
            const Text(
              "ATTACHMENTS",
              style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold, fontSize: 11),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.indigo),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName,
                      style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => _handleApproval('approved'),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: const Text("Approve"),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      foregroundColor: Colors.red,
                    ),
                    onPressed: () => _handleApproval('rejected'),
                    icon: const Icon(Icons.cancel, size: 16),
                    label: const Text("Reject"),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () => _showContactDialog(context),
                  icon: const Icon(Icons.mail, color: Colors.indigo),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showContactDialog(BuildContext context) {
    final msgController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Message Team Member"),
          content: TextField(
            controller: msgController,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: "Message",
              hintText: "Type your message here...",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                // Mock message action
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Message sent successfully!")),
                );
              },
              child: const Text("Send"),
            )
          ],
        );
      },
    );
  }
}
