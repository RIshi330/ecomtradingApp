import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';

class CommunityInboxScreen extends StatefulWidget {
  final bool isStandalone;

  const CommunityInboxScreen({
    super.key,
    this.isStandalone = true,
  });

  @override
  State<CommunityInboxScreen> createState() =>
      _CommunityInboxScreenState();
}

class _CommunityInboxScreenState
    extends State<CommunityInboxScreen> {

  List<ChatModel> chats = [];
  bool isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchInboxChats();
  }

  Future<void> _fetchInboxChats() async {
    setState(() => isLoading = true);
    try {
      final database = Database();
      
      final response = await database.getData({
        'action': 'dm_senders_list',
        'search': _searchQuery,
      }, endpoint: 'new_apis/chat_manager_api.php');

      if (response['success'] == true || response['status'] == 200) {
        final List<dynamic> data = response['data'] ?? [];
        if (data.isNotEmpty) {
          setState(() {
            chats = data.map((json) {
              final String id = json['id']?.toString() ?? '';
              final String name = json['name']?.toString() ?? 'Unknown User';
              final String message = json['message']?.toString() ?? 'No messages yet';
              final String createdDate = json['created_date']?.toString() ?? '';
              final String role = json['role']?.toString() ?? 'User';
              final int unreadCount = int.tryParse(json['unread_count']?.toString() ?? '0') ?? 0;
              final String profilePic = json['profile_pic']?.toString() ?? '';

              return ChatModel(
                id: id,
                name: name,
                role: role,
                message: message,
                time: _formatTimeAgo(createdDate),
                unread: unreadCount,
                online: false, // Default online status
                isDraft: false,
                avatarUrl: profilePic,
              );
            }).toList();
            isLoading = false;
          });
          return;
        }
      }
    } catch (e) {
      debugPrint("Error fetching inbox chats: $e");
    }

    // Fallback to mock chats if API is empty/fails
    setState(() {
      chats = _getMockChats();
      isLoading = false;
    });
  }

  static String _formatTimeAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return 'now';
    try {
      final dateTime = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dateTime);
      
      if (difference.inMinutes < 1) return 'now';
      if (difference.inMinutes < 60) return '${difference.inMinutes}m';
      if (difference.inHours < 24) return '${difference.inHours}h';
      if (difference.inDays < 7) return '${difference.inDays}d';
      return '${difference.inDays ~/ 7}w';
    } catch (e) {
      return 'now';
    }
  }

  List<ChatModel> _getMockChats() {
    return [
      ChatModel(
        id: "90001",
        name: "Sarah Jenkins",
        role: "Vendor",
        message: "I've uploaded the new inventory list for the weekend market...",
        time: "14:20",
        unread: 3,
        online: true,
        avatarUrl: "",
      ),
      ChatModel(
        id: "90002",
        name: "Marcus Thorne",
        role: "Business",
        message: "The contract looks good. I'll send the signed copy by EOD.",
        time: "Yesterday",
        avatarUrl: "",
      ),
      ChatModel(
        id: "90003",
        name: "Elena Rodriguez",
        role: "User",
        message: "Thanks for the quick response regarding my membership.",
        time: "Tuesday",
        avatarUrl: "",
      ),
      ChatModel(
        id: "90004",
        name: "John Doe",
        role: "User",
        message: "Hey John, I wanted to follow up on...",
        time: "Draft",
        isDraft: true,
        avatarUrl: "",
      ),
      ChatModel(
        id: "90005",
        name: "David Chen",
        role: "Business",
        message: "The new onboarding flow is much smoother now.",
        time: "Oct 12",
        avatarUrl: "",
      ),
    ];
  }

  List<ChatModel> get _filteredChats {
    if (_searchQuery.isEmpty) return chats;
    return chats.where((chat) {
      return chat.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          chat.message.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bodyContent = Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            onChanged: (v) {
              setState(() {
                _searchQuery = v;
              });
            },
            decoration: InputDecoration(
              hintText: "Search members or messages...",
              prefixIcon: const Icon(Icons.search, color: Color(0xFF006565)),
              filled: true,
              fillColor: const Color(0xFFF5F7F7),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF006565),
                  ),
                )
              : _filteredChats.isEmpty
                  ? const Center(
                      child: Text(
                        "No chats found.",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _fetchInboxChats,
                      color: const Color(0xFF006565),
                      child: ListView.builder(
                        itemCount: _filteredChats.length,
                        itemBuilder: (context, index) {
                          return ChatTile(
                            chat: _filteredChats[index],
                          );
                        },
                      ),
                    ),
        ),
      ],
    );

    if (!widget.isStandalone) {
      return Scaffold(
        backgroundColor: const Color(0xffFCF9F8),
        body: bodyContent,
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Community Admin",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: Color(0xFF006565),
                ),
                onPressed: () => Navigator.pop(context),
              )
            : IconButton(
                icon: const Icon(
                  Icons.menu,
                  color: Color(0xFF006565),
                ),
                onPressed: () {},
              ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(0xFF006565),
            ),
            onPressed: () {},
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF006565),
        onPressed: () {},
        child: const Icon(Icons.edit, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF006565),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: "Inbox",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: "Members",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Catalog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
      body: bodyContent,
    );
  }
}

class ChatModel {
  final String id;
  final String name;
  final String role;
  final String message;
  final String time;
  final int unread;
  final bool online;
  final bool isDraft;
  final String avatarUrl;

  ChatModel({
    required this.id,
    required this.name,
    required this.role,
    required this.message,
    required this.time,
    this.unread = 0,
    this.online = false,
    this.isDraft = false,
    required this.avatarUrl,
  });
}

class ChatTile extends StatelessWidget {
  final ChatModel chat;

  const ChatTile({
    super.key,
    required this.chat,
  });

  Color getBadgeColor() {
    switch (chat.role) {
      case "Vendor":
        return const Color(0xffe5f7f7);
      case "Business":
        return const Color(0xffE8F5E9);
      default:
        return const Color(0xffEEEEEE);
    }
  }

  Color getBadgeTextColor() {
    switch (chat.role) {
      case "Vendor":
        return const Color(0xFF006565);
      case "Business":
        return Colors.green;
      default:
        return Colors.black54;
    }
  }

  String getInitials() {
    final names = chat.name.trim().split(" ");
    if (names.isNotEmpty && names[0].isNotEmpty) {
      if (names.length > 1 && names[1].isNotEmpty) {
        return "${names[0][0]}${names[1][0]}".toUpperCase();
      }
      return names[0][0].toUpperCase();
    }
    return "?";
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFFE5ECEB),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Stack(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xff008080),
              child: ClipOval(
                child: chat.avatarUrl.isNotEmpty
                    ? Image.network(
                        chat.avatarUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Text(
                          getInitials(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : Text(
                        getInitials(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (chat.online)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                chat.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Color(0xFF151C27),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              chat.time,
              style: TextStyle(
                fontSize: 12,
                color: chat.isDraft ? Colors.red : Colors.grey,
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 3,
              ),
              decoration: BoxDecoration(
                color: getBadgeColor(),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                chat.role,
                style: TextStyle(
                  fontSize: 10,
                  color: getBadgeTextColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    chat.message,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: chat.unread > 0 ? Colors.black87 : Colors.grey,
                      fontWeight: chat.unread > 0 ? FontWeight.w600 : FontWeight.normal,
                      fontStyle: chat.isDraft ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
                if (chat.unread > 0)
                  Container(
                    height: 22,
                    width: 22,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Color(0xFF006565),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      chat.unread.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        onTap: () {
          final user = ChatUser(
            id: chat.id,
            name: chat.name,
            lastMessage: chat.message,
            time: chat.time,
            avatarUrl: chat.avatarUrl.isNotEmpty
                ? chat.avatarUrl
                : 'https://i.pravatar.cc/150?img=${chat.id.hashCode.abs() % 70 + 1}',
            isOnline: chat.online,
            isUnread: chat.unread > 0,
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(user: user),
            ),
          );
        },
      ),
    );
  }
}
