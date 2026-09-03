import 'dart:ui';

import 'package:flutter/material.dart';


class GrowCommunityApp extends StatelessWidget {
  const GrowCommunityApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grow Community - Serene Corporate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006565),
          primary: const Color(0xFF006565),
          secondary: const Color(0xFF296767),
          surface: const Color(0xFFF9F9F9),
        ),
        fontFamily: 'Inter',
      ),
      home: const CommunityScreen(),
    );
  }
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _openChatModal(String memberName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChatBottomSheet(memberName: memberName),
    );
  }

  void _openActionSheet(String memberName) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ActionSheet(
        memberName: memberName,
        onBlock: () {
          Navigator.pop(context);
          _showBlockDialog(memberName);
        },
        onPromote: () {
          Navigator.pop(context);
          _showPromoteModal(memberName);
        },
      ),
    );
  }

  void _showBlockDialog(String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Block Member?'),
        content: Text('Are you sure you want to block $memberName? They will no longer have access.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('$memberName has been blocked');
            },
            child: const Text('BLOCK'),
          ),
        ],
      ),
    );
  }

  void _showPromoteModal(String memberName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Promote to Sub-Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are elevating $memberName to a sub-administrator role.'),
            const SizedBox(height: 16),
            const TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Add a welcome message...',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565), foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('$memberName promoted to Sub-Admin');
            },
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hub Banner Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF006565),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.hub, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Executive Strategy Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('A high-stakes network for marketing executives.', style: TextStyle(color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Quick Share Row
            const Center(child: Text('QUICK SHARE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Colors.grey))),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildShareButton(Icons.share),
                const SizedBox(width: 16),
                _buildShareButton(Icons.link),
                const SizedBox(width: 16),
                _buildShareButton(Icons.email),
              ],
            ),
            const SizedBox(height: 24),

            // Suggested Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Suggested Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: const Text('VIEW ALL')),
              ],
            ),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  _buildMemberTile('Sarah Jenkins', 'VP of Operations @ Zenith', true, () {}),
                  const Divider(height: 1),
                  _buildMemberTile('David Chen', 'Strategic Advisor', true, () {}),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Community Members Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Community Members', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const Text('114 Members', style: TextStyle(color: Colors.grey, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: Colors.grey.shade300)),
              child: Column(
                children: [
                  _buildCommunityMemberTile('Sarah Jenkins', 'VP of Operations', () => _openChatModal('Sarah Jenkins'), () => _openActionSheet('Sarah Jenkins')),
                  const Divider(height: 1),
                  _buildCommunityMemberTile('David Chen', 'Strategic Advisor', () => _openChatModal('David Chen'), () => _openActionSheet('David Chen')),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fab_link',
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.link, color: Colors.black),
            onPressed: () => _showSnackBar('Link copied to clipboard'),
          ),
          Padding(
            padding: const EdgeInsets.all(5.0),
            child: FloatingActionButton(
              heroTag: 'fab_copy',
              backgroundColor: const Color(0xFF006565),
              child: const Icon(Icons.content_copy, color: Colors.white),
              onPressed: () => _showSnackBar('Content copied to clipboard'),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildShareButton(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Icon(icon, color: Colors.grey.shade700),
    );
  }

  Widget _buildMemberTile(String name, String subtitle, bool isInvite, VoidCallback onAction) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: Text(name[0])),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006565), foregroundColor: Colors.white),
        onPressed: onAction,
        child: const Text('INVITE'),
      ),
    );
  }

  Widget _buildCommunityMemberTile(String name, String subtitle, VoidCallback onChat, VoidCallback onMore) {
    return ListTile(
      leading: CircleAvatar(backgroundColor: Colors.grey.shade300, child: Text(name[0])),
      title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(icon: const Icon(Icons.chat, color: Color(0xFF006565)), onPressed: onChat),
          IconButton(icon: const Icon(Icons.more_vert), onPressed: onMore),
        ],
      ),
    );
  }
}

class ChatBottomSheet extends StatelessWidget {
  final String memberName;
  const ChatBottomSheet({super.key, required this.memberName});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Chat with $memberName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: Center(child: Text('Start a secure conversation...')),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF006565),
                  child: IconButton(icon: const Icon(Icons.send, color: Colors.white, size: 18), onPressed: () {}),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ActionSheet extends StatelessWidget {
  final String memberName;
  final VoidCallback onBlock;
  final VoidCallback onPromote;

  const ActionSheet({super.key, required this.memberName, required this.onBlock, required this.onPromote});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 12),
          Text(memberName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.admin_panel_settings, color: Color(0xFF006565)),
            title: const Text('Promote to Sub-Admin'),
            onTap: onPromote,
          ),
          ListTile(
            leading: const Icon(Icons.block, color: Colors.red),
            title: const Text('Block Member', style: TextStyle(color: Colors.red)),
            onTap: onBlock,
          ),
        ],
      ),
    );
  }
}