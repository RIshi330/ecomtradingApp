import 'package:flutter/material.dart';

import '../Database/Database.dart';
import 'create_post.dart';
/// Model for a single row coming back from the `get_feed` action in
/// feed_api.php. The backend returns raw `post_content` rows (plus a
/// joined `image_url` for admin posts, and raw `opp_response` rows for
/// sponsored slots), so this parses defensively — every field falls
/// back to something safe if the key is missing.
class FeedPost {
  final String id;
  final String vendorId;
  final String contentType; // text | image | gallery | video (post_content.content_type)
  final String visibility;
  final String label;
  final String tags;
  final String location;
  final String createdDate;
  final String? imageUrl;
  final String feedType; // admin | personalized | following | community | self | explore | sponsored
  final String vendorName;
  final String? vendorAvatar;
  final int likeCount;
  final int commentCount;
  final bool likedByMe;
  final Map<String, dynamic> raw;

  FeedPost({
    required this.id,
    required this.vendorId,
    required this.contentType,
    required this.visibility,
    required this.label,
    required this.tags,
    required this.location,
    required this.createdDate,
    required this.feedType,
    required this.raw,
    this.imageUrl,
    this.vendorName = '',
    this.vendorAvatar,
    this.likeCount = 0,
    this.commentCount = 0,
    this.likedByMe = false,
  });

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: json['id']?.toString() ?? '',
      vendorId: json['vendor_id']?.toString() ?? '',
      contentType: (json['content_type']?.toString() ?? 'text').toLowerCase(),
      visibility: json['visibility']?.toString() ?? 'public',
      label: json['label']?.toString() ?? '',
      tags: json['tags']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      createdDate: json['created_date']?.toString() ?? '',
      feedType: json['feed_type']?.toString() ?? 'personalized',
      imageUrl: (json['image_url']?.toString().isNotEmpty ?? false) ? json['image_url'].toString() : null,
      // These three come from the vendor JOIN + subquery aggregates
      // added to get_feed — see feed_api.php.
      vendorName: json['vendor_name']?.toString() ?? '',
      vendorAvatar: (json['vendor_avatar']?.toString().isNotEmpty ?? false) ? json['vendor_avatar'].toString() : null,
      likeCount: int.tryParse(json['like_count']?.toString() ?? '') ?? 0,
      commentCount: int.tryParse(json['comment_count']?.toString() ?? '') ?? 0,
      likedByMe: json['liked_by_me'] == true || json['liked_by_me']?.toString() == '1',
      raw: json,
    );
  }

  bool get isSponsored => feedType == 'sponsored';
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Sponsored rows come straight from `opp_response`, whose exact
  /// columns depend on your schema. This grabs a best-effort headline
  /// so the sponsored card has *something* to show without crashing —
  /// adjust the key names here to match your actual opp_response table.
  String get sponsoredHeadline =>
      raw['headline']?.toString() ??
          raw['title']?.toString() ??
          raw['product_name']?.toString() ??
          'Sponsored';

  String get sponsoredImage =>
      raw['image_url']?.toString() ??
          raw['banner_url']?.toString() ??
          raw['product_image']?.toString() ??
          '';
}
// DESIGN SYSTEM — refined tokens, shadows & shared decorations
// ══════════════════════════════════════════════════════════
class FeedTheme {
  static const Color primaryTeal = Color(0xFF0F6E6A);
  static const Color activeTeal = Color(0xFF14A098);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF3F6F5);
  static const Color background = Color(0xFFF6F8F8);
  static const Color textDark = Color(0xFF17211F);
  static const Color textLight = Color(0xFF5C6B68);
  static const Color outlineVariant = Color(0xFFE3EAE8);
  static const Color statusGrowing = Color(0xFF7C5CFC);
  static const Color statusModerated = Color(0xFFC2760A);
  static const Color selectedBg = Color(0xFFE3FFFC);
  static const Color storyGradient1 = Color(0xFFFF7A6E);
  static const Color storyGradient2 = Color(0xFFFFC93D);
  static const Color storyGradient3 = Color(0xFF6C5CE7);
  static const Color storyGradient4 = Color(0xFF14A098);
  static const Color likeRed = Color(0xFFEF4B6E);

  static TextStyle heading(double size, {bool bold = true, Color? color}) => TextStyle(
    fontFamily: 'Manrope',
    fontSize: size,
    fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
    letterSpacing: -0.2,
    height: 1.2,
    color: color ?? textDark,
  );

  static TextStyle body(double size, {Color color = textLight, bool bold = false}) => TextStyle(
    fontFamily: 'Inter',
    fontSize: size,
    fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
    letterSpacing: 0.1,
    color: color,
  );

  static List<BoxShadow> get softShadow => [
    BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 20, offset: const Offset(0, 8)),
    BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 4, offset: const Offset(0, 1)),
  ];

  static BoxDecoration card({double radius = 18, Color color = surfaceContainerLowest}) => BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(radius),
    boxShadow: softShadow,
  );

  static const LinearGradient storyRing = LinearGradient(
    colors: [storyGradient1, storyGradient2, storyGradient3, storyGradient4],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [activeTeal, primaryTeal],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ══════════════════════════════════════════════════════════
// APP ROOT
// ══════════════════════════════════════════════════════════
class CommunityIntelligenceApp extends StatefulWidget {
  const CommunityIntelligenceApp({super.key});

  @override
  State<CommunityIntelligenceApp> createState() => _CommunityIntelligenceAppState();
}

class _CommunityIntelligenceAppState extends State<CommunityIntelligenceApp> {
  // A GlobalKey lets us reach into the FeedPostsList from the AppBar's
  // "new post" button and tell it to refresh after a successful publish.
  final GlobalKey<_FeedPostsListState> _feedListKey = GlobalKey<_FeedPostsListState>();

  Future<void> _openCreatePost() async {
    final published = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const CreatePostScreen()),
    );
    if (published == true) {
      _feedListKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    final double width = MediaQuery.of(context).size.width;
    final bool isDesktop = width >= 768;

    return Scaffold(
      backgroundColor: FeedTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Colors.white, // Back button & default icons
        ),
        title: Text(
          'Community Feed',
          style: FeedTheme.heading(
            19,
            bold: true,
            color: Colors.white,
          ),
        ),
        actions: [
          _AppBarIconButton(
            icon: Icons.add_circle_outline_rounded,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CreatePostScreen()),
              );
            },
          ),
          _AppBarIconButton(
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () {},
            showDot: true,
          ),
          const SizedBox(width: 6),
        ],
      ),      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isDesktop ? 40.0 : 16.0,
            vertical: 20.0,
          ),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1280),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isDesktop) ...[
                    const Expanded(flex: 3, child: SideOverviewPanel()),
                    const SizedBox(width: 24),
                  ],
                  Expanded(
                    flex: 9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // const StoriesSection(),
                        const SizedBox(height: 20),
                        FeedPostsList(key: _feedListKey),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool showDot;
  const _AppBarIconButton({required this.icon, required this.onPressed, this.showDot = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: FeedTheme.selectedBg,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onPressed,
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: Icon(icon, color: FeedTheme.primaryTeal, size: 20),
              ),
            ),
          ),
          if (showDot)
            Positioned(
              top: 2,
              right: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: FeedTheme.likeRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 1.5),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// LIVE FEED LIST — calls Database().getFeed() and renders
// whatever content_type/feed_type each row actually is.
// ══════════════════════════════════════════════════════════
class FeedPostsList extends StatefulWidget {
  const FeedPostsList({super.key});

  @override
  State<FeedPostsList> createState() => _FeedPostsListState();
}

class _FeedPostsListState extends State<FeedPostsList> {
  final Database _db = Database();
  late Future<Map<String, dynamic>> _feedFuture;

  @override
  void initState() {
    super.initState();
    _feedFuture = _db.getFeed();
  }

  void refresh() {
    setState(() {
      _feedFuture = _db.getFeed();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _feedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Center(child: CircularProgressIndicator(color: FeedTheme.primaryTeal)),
          );
        }

        final result = snapshot.data;
        final success = result?['success'] == true;
        final items = (result?['data'] as List?) ?? [];

        if (!success) {
          return _FeedMessage(
            icon: Icons.wifi_off_rounded,
            title: 'Could not load the feed',
            subtitle: result?['message']?.toString() ?? 'Something went wrong. Pull to retry.',
            onRetry: refresh,
          );
        }

        if (items.isEmpty) {
          return _FeedMessage(
            icon: Icons.dynamic_feed_outlined,
            title: 'No posts yet',
            subtitle: 'Be the first to share something with the community.',
            onRetry: refresh,
          );
        }

        final posts = items
            .whereType<Map>()
            .map((e) => FeedPost.fromJson(Map<String, dynamic>.from(e)))
            .toList();

        return Column(
          children: [
            for (final post in posts) ...[
              FeedPostCard(post: post, db: _db),
              const SizedBox(height: 20),
            ],
          ],
        );
      },
    );
  }
}

class _FeedMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRetry;

  const _FeedMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: FeedTheme.card(),
      child: Column(
        children: [
          Icon(icon, size: 40, color: FeedTheme.textLight),
          const SizedBox(height: 12),
          Text(title, style: FeedTheme.heading(15)),
          const SizedBox(height: 6),
          Text(subtitle, style: FeedTheme.body(12), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// ONE FEED CARD — adapts to text / image / gallery / video /
// sponsored, and wires like, comment and share to the API.
// ══════════════════════════════════════════════════════════
class FeedPostCard extends StatefulWidget {
  final FeedPost post;
  final Database db;
  const FeedPostCard({super.key, required this.post, required this.db});

  @override
  State<FeedPostCard> createState() => _FeedPostCardState();
}

class _FeedPostCardState extends State<FeedPostCard> {
  bool _liked = false;
  bool _likeBusy = false;

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() {
      _liked = !_liked; // optimistic
      _likeBusy = true;
    });
    final result = await widget.db.toggleLike(postId: widget.post.id);
    if (!mounted) return;
    setState(() => _likeBusy = false);
    if (result['success'] != true) {
      setState(() => _liked = !_liked); // revert on failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Could not update like')),
      );
    }
  }

  Future<void> _share() async {
    final result = await widget.db.sharePost(postId: widget.post.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result['success'] == true ? 'Shared to your profile' : (result['message']?.toString() ?? 'Share failed'))),
    );
  }

  void _openComments() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CommentSheet(postId: widget.post.id, db: widget.db),
    );
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;

    if (post.isSponsored) {
      return _sponsoredCard(post);
    }

    return Container(
      decoration: FeedTheme.card(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(post),
          if (post.label.isNotEmpty || (post.tags.isNotEmpty))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Text(
                post.tags.isNotEmpty ? post.tags : post.label,
                style: FeedTheme.body(14, color: FeedTheme.textDark),
              ),
            ),
          if (post.location.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: FeedTheme.textLight),
                  const SizedBox(width: 4),
                  Text(post.location, style: FeedTheme.body(11)),
                ],
              ),
            ),
          if (post.hasImage) ...[
            const SizedBox(height: 10),
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: FeedTheme.surfaceContainerLow,
                  alignment: Alignment.center,
                  child: const Icon(Icons.broken_image_outlined, color: FeedTheme.textLight),
                ),
              ),
            ),
          ] else
            const SizedBox(height: 8),
          _engagementBar(),
        ],
      ),
    );
  }

  Widget _header(FeedPost post) {
    final labelColor = switch (post.feedType) {
      'admin' => FeedTheme.activeTeal,
      'following' => FeedTheme.statusGrowing,
      'community' => FeedTheme.statusModerated,
      _ => FeedTheme.textLight,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(gradient: FeedTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
                alignment: Alignment.center,
                child: Text(
                  post.vendorId.isNotEmpty ? post.vendorId.substring(0, 1) : '?',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vendor #${post.vendorId}', style: FeedTheme.heading(14)),
                  Text(post.createdDate, style: FeedTheme.body(11)),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
            decoration: BoxDecoration(color: labelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
            child: Text(post.feedType, style: FeedTheme.body(11, color: labelColor, bold: true)),
          ),
        ],
      ),
    );
  }

  Widget _engagementBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: FeedTheme.surfaceContainerLow,
        border: const Border(top: BorderSide(color: FeedTheme.outlineVariant, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              _chip(
                icon: _liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                color: _liked ? FeedTheme.likeRed : FeedTheme.likeRed,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 8),
              _chip(icon: Icons.chat_bubble_outline_rounded, color: FeedTheme.primaryTeal, onTap: _openComments),
              const SizedBox(width: 8),
              _chip(icon: Icons.share_outlined, color: FeedTheme.textLight, onTap: _share),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chip({required IconData icon, required Color color, required VoidCallback onTap}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: FeedTheme.outlineVariant)),
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  Widget _sponsoredCard(FeedPost post) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: FeedTheme.card(color: FeedTheme.surfaceContainerLow),
      child: Row(
        children: [
          if (post.sponsoredImage.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                post.sponsoredImage,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 64,
                  height: 64,
                  color: FeedTheme.outlineVariant,
                  child: const Icon(Icons.image_outlined, color: FeedTheme.textLight),
                ),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sponsored', style: FeedTheme.body(10, bold: true, color: FeedTheme.primaryTeal)),
                const SizedBox(height: 2),
                Text(post.sponsoredHeadline, style: FeedTheme.heading(14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommentSheet extends StatefulWidget {
  final String postId;
  final Database db;
  const _CommentSheet({required this.postId, required this.db});

  @override
  State<_CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<_CommentSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _sending = false;

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    final result = await widget.db.addComment(postId: widget.postId, message: text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (result['success'] == true) {
      _controller.clear();
      if (mounted) Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message']?.toString() ?? 'Could not post comment')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Add a comment...', border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(width: 8),
          _sending
              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
              : IconButton(
            icon: const Icon(Icons.send_rounded, color: FeedTheme.primaryTeal),
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// STORIES SECTION (unchanged demo data — wire to a stories
// endpoint the same way as FeedPostsList once you have one)
// ══════════════════════════════════════════════════════════

class StoryUser {
  final String id;
  final String name;
  final String avatarUrl;
  final bool hasViewed;
  final bool isLive;
  final List<StoryContent> stories;
  final bool isCloseFriend;

  StoryUser({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.hasViewed = false,
    this.isLive = false,
    this.stories = const [],
    this.isCloseFriend = false,
  });

  bool get hasUnviewedStories => stories.any((story) => !story.isViewed);
  int get unviewedCount => stories.where((story) => !story.isViewed).length;
}

class StoryContent {
  final String id;
  final String mediaUrl;
  final StoryType type;
  final bool isViewed;
  final DateTime postedAt;
  final String? caption;

  StoryContent({
    required this.id,
    required this.mediaUrl,
    this.type = StoryType.image,
    this.isViewed = false,
    required this.postedAt,
    this.caption,
  });
}

enum StoryType { image, video, text }

class StoriesSection extends StatefulWidget {
  const StoriesSection({super.key});

  @override
  State<StoriesSection> createState() => _StoriesSectionState();
}

class _StoriesSectionState extends State<StoriesSection> {
  late List<StoryUser> _stories;

  @override
  void initState() {
    super.initState();
    _stories = _getSampleStories();
  }

  List<StoryUser> _getSampleStories() {
    final now = DateTime.now();
    return [
      StoryUser(id: '1', name: 'Your Story', avatarUrl: '', hasViewed: false, stories: [
        StoryContent(id: 's1', mediaUrl: '', postedAt: now.subtract(const Duration(hours: 1))),
      ]),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      decoration: FeedTheme.card(radius: 18),
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _stories.length,
        itemBuilder: (context, index) {
          final story = _stories[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: SizedBox(
              width: 74,
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(shape: BoxShape.circle, gradient: FeedTheme.storyRing),
                  ),
                  const SizedBox(height: 4),
                  Text(story.name, style: FeedTheme.body(10, color: FeedTheme.textDark), maxLines: 1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// SIDE OVERVIEW PANEL (unchanged demo widget)
// ══════════════════════════════════════════════════════════

class SideOverviewPanel extends StatelessWidget {
  const SideOverviewPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: FeedTheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: FeedTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Executive Overview', style: FeedTheme.heading(16)),
          const SizedBox(height: 10),
          Text('Strategic status: Optimal', style: FeedTheme.body(13)),
        ],
      ),
    );
  }
}