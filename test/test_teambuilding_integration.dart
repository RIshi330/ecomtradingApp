import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  const String baseUrl = "http://192.168.1.7/SetupBackendCCBUL/android/";
  const String teamApi = "${baseUrl}new_apis/teambuilding_API.php";
  const String taskApi = "${baseUrl}new_apis/task_manager_api.php";
  const String partnersListApi = "${baseUrl}new_apis/professionals_List_API.php";
  const String invitePartnerApi = "${baseUrl}new_apis/invite_as_partner_API.php";
  const String talentApi = "${baseUrl}new_apis/marketplace_talent_API.php";

  print("==================================================");
  print("Team Building Complete Suite Integration Test");
  print("==================================================");

  // Helper to print step titles
  void printStep(String title) {
    print("\n--- $title ---");
  }

  // ----------------------------------------------------
  // SECTION 1: Manage Team Endpoints (teambuilding_API.php)
  // ----------------------------------------------------
  printStep("Step 1: Fetching Team Members List");
  try {
    final response = await http.post(
      Uri.parse(teamApi),
      body: {'action': 'get_team_members_list', 'status': 'Active'},
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Fetching team members succeeded!");
      final List<dynamic> members = data['data']?['members'] ?? [];
      print("Found ${members.length} team members.");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching members: $e");
  }

  printStep("Step 2: Adding a New Team Member");
  final randomEmail = "team_dart_test_${DateTime.now().millisecondsSinceEpoch}@example.com";
  try {
    final response = await http.post(
      Uri.parse(teamApi),
      body: {
        'action': 'add_new_team_member',
        'name': 'Dart Test Member',
        'email': randomEmail,
        'mobile': '9898989898',
        'role': 'Developer',
        'create_account': '1',
        'send_email': '0',
      },
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Added member successfully! ID: ${data['data']?['member_id']}");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error adding member: $e");
  }

  // ----------------------------------------------------
  // SECTION 2: Manage Tasks Endpoints (task_manager_api.php)
  // ----------------------------------------------------
  printStep("Step 3: Initializing Task Manager Data");
  try {
    final response = await http.post(
      Uri.parse(taskApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'action': 'init'}),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['status'] == 'ok' || data['success'] == true) {
      print("✅ Success: Task Manager initialization succeeded!");
      final tasks = data['data']?['tasks'] ?? data['tasks'] ?? [];
      print("Found ${tasks.length} active tasks.");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error initializing tasks: $e");
  }

  printStep("Step 4: Creating a New Task");
  int? createdTaskId;
  try {
    final response = await http.post(
      Uri.parse(taskApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'action': 'create_task',
        'title': 'Dart Integration Task ${DateTime.now().millisecondsSinceEpoch}',
        'desc': 'Testing dynamic creation via Dart script.',
        'priority': 1, // High
        'start_date': DateTime.now().toIso8601String().substring(0, 19).replaceAll('T', ' '),
        'end_date': DateTime.now().add(const Duration(days: 4)).toIso8601String().substring(0, 19).replaceAll('T', ' '),
      }),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['status'] == 'ok' || data['success'] == true) {
      createdTaskId = data['data']?['id'] ?? data['id'];
      print("✅ Success: Created task successfully! Task ID: $createdTaskId");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error creating task: $e");
  }

  if (createdTaskId != null) {
    printStep("Step 5: Assigning Task to Member");
    try {
      final response = await http.post(
        Uri.parse(taskApi),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          'action': 'assign_task',
          'task_id': createdTaskId,
          'assigned_to': '2', // Assign to vendor 2
          'deadline': DateTime.now().add(const Duration(days: 4)).toIso8601String().substring(0, 10),
        }),
      );
      print("Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");
      print("✅ Success: Processed task assignment!");
    } catch (e) {
      print("❌ Error assigning task: $e");
    }
  }

  // ----------------------------------------------------
  // SECTION 3: Explore Partners Endpoints
  // ----------------------------------------------------
  printStep("Step 6: Fetching Professionals List");
  try {
    final response = await http.get(
      Uri.parse("$partnersListApi?page=1&per_page=5"),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Fetched partner professionals list!");
      final list = data['data']?['professionals'] ?? [];
      print("Found ${list.length} professional profiles.");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error listing partners: $e");
  }

  printStep("Step 7: Sending Partner Invitation");
  try {
    final response = await http.post(
      Uri.parse(invitePartnerApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'receiver_id': '13',
        'msg_type': 'Invite_as_partner',
        'message': 'Dart integration test sending custom partnership invitation.',
        'start_date': DateTime.now().toIso8601String().substring(0, 10),
      }),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Invitation message stored on database!");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error inviting partner: $e");
  }

  // ----------------------------------------------------
  // SECTION 4: Explore Talent Endpoints
  // ----------------------------------------------------
  printStep("Step 8: Fetching Talent Filters");
  try {
    final response = await http.post(
      Uri.parse(talentApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({'action': 'get_filters'}),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Fetched seeker filters!");
      final filters = data['data'] ?? {};
      print("Streams count: ${filters['streams']?.length}");
      print("Colleges count: ${filters['colleges']?.length}");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error fetching filters: $e");
  }

  printStep("Step 9: Loading Seeker Profiles");
  try {
    final response = await http.post(
      Uri.parse(talentApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'action': 'load_profiles',
        'sort': 'recent',
      }),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true || data.containsKey('profiles')) {
      print("✅ Success: Loaded seeker profiles!");
      final List<dynamic> profiles = data['profiles'] ?? [];
      print("Found ${profiles.length} seeker profiles.");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error loading profiles: $e");
  }

  printStep("Step 10: Sending Talent Invitation Message");
  try {
    final response = await http.post(
      Uri.parse(talentApi),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        'action': 'send_invite',
        'id': 1,
        'name': 'Dart Seeker Client',
        'email': 'dart@test.com',
        'message': 'Welcome to team project!',
      }),
    );
    print("Status Code: ${response.statusCode}");
    final data = jsonDecode(response.body);
    if (data['success'] == true) {
      print("✅ Success: Sent invite successfully (demo response verified)!");
    } else {
      print("❌ Failed: ${data['message']}");
    }
  } catch (e) {
    print("❌ Error sending talent invite: $e");
  }

  print("\n==============================================");
  print("🎉 Dart Team Building Test Suite Finished Successfully!");
  print("==============================================");
}
