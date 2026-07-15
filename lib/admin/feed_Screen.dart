// import 'package:flutter/material.dart';
//
// import 'create_post.dart';
//
// // ══════════════════════════════════════════════════════════
// // DESIGN SYSTEM — refined tokens, shadows & shared decorations
// // ══════════════════════════════════════════════════════════
// class FeedTheme {
//   static const Color primaryTeal = Color(0xFF0F6E6A);
//   static const Color activeTeal = Color(0xFF14A098);
//   static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
//   static const Color surfaceContainerLow = Color(0xFFF3F6F5);
//   static const Color background = Color(0xFFF6F8F8);
//   static const Color textDark = Color(0xFF17211F);
//   static const Color textLight = Color(0xFF5C6B68);
//   static const Color outlineVariant = Color(0xFFE3EAE8);
//   static const Color statusGrowing = Color(0xFF7C5CFC);
//   static const Color statusModerated = Color(0xFFC2760A);
//   static const Color selectedBg = Color(0xFFE3FFFC);
//   static const Color storyGradient1 = Color(0xFFFF7A6E);
//   static const Color storyGradient2 = Color(0xFFFFC93D);
//   static const Color storyGradient3 = Color(0xFF6C5CE7);
//   static const Color storyGradient4 = Color(0xFF14A098);
//   static const Color likeRed = Color(0xFFEF4B6E);
//
//   static TextStyle heading(double size, {bool bold = true, Color? color}) => TextStyle(
//     fontFamily: 'Manrope',
//     fontSize: size,
//     fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
//     letterSpacing: -0.2,
//     height: 1.2,
//     color: color ?? textDark,
//   );
//
//   static TextStyle body(double size, {Color color = textLight, bool bold = false}) => TextStyle(
//     fontFamily: 'Inter',
//     fontSize: size,
//     fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
//     letterSpacing: 0.1,
//     color: color,
//   );
//
//   /// Soft, layered elevation shadow used across every card for a modern,
//   /// borderless feel (replaces the old flat 1px outline).
//   static List<BoxShadow> get softShadow => [
//     BoxShadow(color: Colors.black.withOpacity(0.045), blurRadius: 20, offset: const Offset(0, 8)),
//     BoxShadow(color: Colors.black.withOpacity(0.025), blurRadius: 4, offset: const Offset(0, 1)),
//   ];
//
//   static BoxDecoration card({double radius = 18, Color color = surfaceContainerLowest}) => BoxDecoration(
//     color: color,
//     borderRadius: BorderRadius.circular(radius),
//     boxShadow: softShadow,
//   );
//
//   static const LinearGradient storyRing = LinearGradient(
//     colors: [storyGradient1, storyGradient2, storyGradient3, storyGradient4],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
//
//   static const LinearGradient brandGradient = LinearGradient(
//     colors: [activeTeal, primaryTeal],
//     begin: Alignment.topLeft,
//     end: Alignment.bottomRight,
//   );
// }
//
// // --- STORY DATA MODEL ---
// class StoryUser {
//   final String id;
//   final String name;
//   final String avatarUrl;
//   final bool hasViewed;
//   final bool isLive;
//   final List<StoryContent> stories;
//   final bool isCloseFriend;
//
//   StoryUser({
//     required this.id,
//     required this.name,
//     required this.avatarUrl,
//     this.hasViewed = false,
//     this.isLive = false,
//     this.stories = const [],
//     this.isCloseFriend = false,
//   });
//
//   bool get hasUnviewedStories => stories.any((story) => !story.isViewed);
//   int get unviewedCount => stories.where((story) => !story.isViewed).length;
// }
//
// class StoryContent {
//   final String id;
//   final String mediaUrl;
//   final StoryType type;
//   final bool isViewed;
//   final DateTime postedAt;
//   final String? caption;
//
//   StoryContent({
//     required this.id,
//     required this.mediaUrl,
//     this.type = StoryType.image,
//     this.isViewed = false,
//     required this.postedAt,
//     this.caption,
//   });
// }
//
// enum StoryType {
//   image,
//   video,
//   text,
// }
//
// class CommunityIntelligenceApp extends StatelessWidget {
//   const CommunityIntelligenceApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final double width = MediaQuery.of(context).size.width;
//     final bool isDesktop = width >= 768;
//
//     return Scaffold(
//       backgroundColor: FeedTheme.background,
//       appBar: AppBar(
//         backgroundColor: Colors.teal,
//         elevation: 0,
//         scrolledUnderElevation: 2,
//         leading: IconButton(
//           splashRadius: 22,
//           icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black, size: 20),
//           onPressed: () => Navigator.maybePop(context),
//         ),
//         title: ShaderMask(
//           shaderCallback: (bounds) => FeedTheme.brandGradient.createShader(bounds),
//           child: Text(
//             'Community Feed',
//             style: FeedTheme.heading(19, bold: false).copyWith(color: Colors.black),
//           ),
//         ),
//         centerTitle: false,
//         actions: [
//           _AppBarIconButton(icon: Icons.add_circle_outline_rounded, onPressed: () {
//             Navigator.push(context, MaterialPageRoute(builder: (context) => CreatePostScreen(),));
//           }),
//           _AppBarIconButton(icon: Icons.chat_bubble_outline_rounded, onPressed: () {}, showDot: true),
//           const SizedBox(width: 6),
//         ],
//       ),
//       body: SafeArea(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(
//             horizontal: isDesktop ? 40.0 : 16.0,
//             vertical: 20.0,
//           ),
//           child: Center(
//             child: Container(
//               constraints: const BoxConstraints(maxWidth: 1280),
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   if (isDesktop) ...[
//                     const Expanded(
//                       flex: 3,
//                       child: SideOverviewPanel(),
//                     ),
//                     const SizedBox(width: 24),
//                   ],
//                   Expanded(
//                     flex: 9,
//                     child: ListView(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       children: const [
//                         StoriesSection(),
//                         SizedBox(height: 20),
//                         PostTextCard(),
//                         SizedBox(height: 20),
//                         SponsoredHorizontalCarousel(),
//                         SizedBox(height: 20),
//                         PostImageCard(),
//                         SizedBox(height: 20),
//                         PostVideoCard(),
//                         SizedBox(height: 20),
//                         DiscoverDynamicGrid(),
//                         SizedBox(height: 20),
//                         PostGalleryCard(),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// class _AppBarIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onPressed;
//   final bool showDot;
//   const _AppBarIconButton({required this.icon, required this.onPressed, this.showDot = false});
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 2),
//       child: Stack(
//         clipBehavior: Clip.none,
//         children: [
//           Material(
//             color: FeedTheme.selectedBg,
//             shape: const CircleBorder(),
//             child: InkWell(
//               customBorder: const CircleBorder(),
//               onTap: onPressed,
//               child: Padding(
//                 padding: const EdgeInsets.all(9),
//                 child: Icon(icon, color: FeedTheme.primaryTeal, size: 20),
//               ),
//             ),
//           ),
//           if (showDot)
//             Positioned(
//               top: 2,
//               right: 2,
//               child: Container(
//                 width: 8,
//                 height: 8,
//                 decoration: BoxDecoration(
//                   color: FeedTheme.likeRed,
//                   shape: BoxShape.circle,
//                   border: Border.all(color: Colors.white, width: 1.5),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // STORIES SECTION
// // ══════════════════════════════════════════════════════════
//
// class StoriesSection extends StatefulWidget {
//   const StoriesSection({super.key});
//
//   @override
//   State<StoriesSection> createState() => _StoriesSectionState();
// }
//
// class _StoriesSectionState extends State<StoriesSection> {
//   late List<StoryUser> _stories;
//
//   @override
//   void initState() {
//     super.initState();
//     _stories = _getSampleStories();
//   }
//
//   List<StoryUser> _getSampleStories() {
//     final now = DateTime.now();
//     return [
//       StoryUser(
//         id: '1',
//         name: 'Your Story',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCjROtURqL93PgulLZeoQISnVMbeVSXeJZJjeLS91RV6bmgMKQymFpZ_utBLCs055N5AX4xs0IugklqoBczkEaX0hbcQn_RZBpAJk72jtsnuCW7s4z4j1B1Q12ggbPunW50AZGyoyA8pEUadRV_dLcs0qgNtJaeCt6jVRcs2Q0Dzc25ouX2QwdKAgnSo-A5TgZyuUkeehKO0TeVM-u5ER9Y3fILJHS5AXZriszyEVfacfEVyqX-7qdz',
//         hasViewed: false,
//         stories: [
//           StoryContent(id: 's1', mediaUrl: 'https://example.com/story1.jpg', postedAt: now.subtract(const Duration(hours: 1))),
//         ],
//       ),
//       StoryUser(
//         id: '2',
//         name: 'Sarah Mitchell',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuAm1Y-cM-txAeQqpeUrttSjZpGFbUAOJvsif64_ecYneK5YroKzXv1DS1ddYVyQWZp1Z3wQgqNdm8AvlqZowiUj0XRrEdT8Fc65ji5AYLFC1wqhiq7xTHHIl68-RwiTYfbnt9NfA3pG7ho--7BIOWutFlpVVf4GDXP0CpVsudogYo2jnf5vGT6faUYh3PQaai8aXvS1xINLwslSx8r0pHtuH_CTyoinVmehyRpP8Myy2mKDsk8HZZJI',
//         hasViewed: false,
//         isLive: true,
//         stories: [
//           StoryContent(id: 's2', mediaUrl: 'https://example.com/story2.jpg', postedAt: now.subtract(const Duration(minutes: 30))),
//           StoryContent(id: 's3', mediaUrl: 'https://example.com/story3.jpg', postedAt: now.subtract(const Duration(minutes: 15))),
//         ],
//       ),
//       StoryUser(
//         id: '3',
//         name: 'David Chen',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCnSNN9Ev9bSWwWJ0jVDJa7v95KZHw03OdmS74O_DUX6cKOqIeGzjd0y6JVJ24p97C2c1tDmdH26A5LA5VyV4nHvrFOVtPImUujWTdavfhUcq412ieukjKH5xlby9dVhcjoEp2gs208yU1gxl2fA1-ogBOj40rw0hgsU74eX829kySW-tRQJKNxPmOZ_TM4UeVfioSyfE-Is-o44UiXGUaUcNiz2q84vAVVfRbgUOMpET5APCsbQ1JO',
//         hasViewed: true,
//         stories: [
//           StoryContent(id: 's4', mediaUrl: 'https://example.com/story4.jpg', postedAt: now.subtract(const Duration(hours: 3)), isViewed: true),
//         ],
//       ),
//       StoryUser(
//         id: '4',
//         name: 'Elena Rodriguez',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCNIS1tQpvP0kkwlBlC26UVrtnoxGPplSnzenXLpyynw_Ch36k33qhSJeT5iyqdpPELxHvZCNktXs-iR9_nfh_SyDwbqtAkK9-WWAvS72EtAwjtskTbJG-fWsPsHV7mq7PTr6PzpfPlsVR9fiWDI6J0cXqtTKQ6MnW7sDVoA017j6Q9urSFpEURSbVtUhrLEVf2T3k08Vhbs8ItNViek4n_-QdnHR_nK9SU5xSae_p0vdD_tioWMSu1',
//         hasViewed: false,
//         isCloseFriend: true,
//         stories: [
//           StoryContent(id: 's5', mediaUrl: 'https://example.com/story5.jpg', postedAt: now.subtract(const Duration(hours: 2))),
//         ],
//       ),
//       StoryUser(
//         id: '5',
//         name: 'Tech Innovation',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBOgKANhjHiOPlvSv4sED6CvcyV5KI3tc3FBKGGFrBUWqgq-PQIIjY5cmd8RPSlS2F1QpETUFl_3UqMU8_jrxNC2GmKLUqpSqakpX12wWDvdMVma40HxkGE5fx77c2QPFBEiQ3Fz0BOhPp9UguJUftrIcE-eUgWwRHlEmJ4d6d-BvHy9qNpwA9SFRfZ_OVDb7AInfLCZdel-VsE00_SuKdGeZ1KFkxFya-LE9suk23SIsUN6FLg8qDq',
//         hasViewed: false,
//         stories: [
//           StoryContent(id: 's6', mediaUrl: 'https://example.com/story6.jpg', postedAt: now.subtract(const Duration(hours: 4))),
//           StoryContent(id: 's7', mediaUrl: 'https://example.com/story7.jpg', postedAt: now.subtract(const Duration(hours: 2))),
//           StoryContent(id: 's8', mediaUrl: 'https://example.com/story8.jpg', postedAt: now.subtract(const Duration(minutes: 45))),
//         ],
//       ),
//       StoryUser(
//         id: '6',
//         name: 'Marketing Team',
//         avatarUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCdukG5Bs5MYrKezSVgml7mh082CzrDdiWUG-blbFr_Gen8Cv8vJoLMA3Y6nukYWyRcyYXb9NzEjwXtN1CzRM7TLk2tO4DkAhJNmAQPqNnzCN9CNLVEjbo_fmEAMR37_LtF0aTndX9xRuIA5PTI6XjAV5u36NzPAGo4wWHHoZPE_RrFxMeysFqgZmucUAVmuBxzymBpxMxtRRUpIB3yjYhSUfgrz7PY3Jp8166tWsIFuWuqQPKAm37i',
//         hasViewed: true,
//         stories: [
//           StoryContent(id: 's9', mediaUrl: 'https://example.com/story9.jpg', postedAt: now.subtract(const Duration(hours: 5)), isViewed: true),
//         ],
//       ),
//     ];
//   }
//
//   void _openStoryViewer(int index) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       barrierColor: Colors.black.withOpacity(0.9),
//       builder: (context) => StoryViewer(
//         stories: _stories,
//         initialIndex: index,
//         onStoryViewed: (storyIndex) {
//           setState(() {
//             _stories[storyIndex] = StoryUser(
//               id: _stories[storyIndex].id,
//               name: _stories[storyIndex].name,
//               avatarUrl: _stories[storyIndex].avatarUrl,
//               hasViewed: true,
//               isLive: _stories[storyIndex].isLive,
//               stories: _stories[storyIndex].stories
//                   .map((s) => StoryContent(
//                 id: s.id,
//                 mediaUrl: s.mediaUrl,
//                 type: s.type,
//                 isViewed: true,
//                 postedAt: s.postedAt,
//                 caption: s.caption,
//               ))
//                   .toList(),
//               isCloseFriend: _stories[storyIndex].isCloseFriend,
//             );
//           });
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 128,
//       decoration: FeedTheme.card(radius: 18),
//       padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
//       child: ListView.builder(
//         scrollDirection: Axis.horizontal,
//         itemCount: _stories.length,
//         physics: const BouncingScrollPhysics(),
//         itemBuilder: (context, index) {
//           final story = _stories[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 6),
//             child: GestureDetector(
//               onTap: () => _openStoryViewer(index),
//               child: SizedBox(
//                 width: 74,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       width: 70,
//                       height: 70,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [
//                           Container(
//                             width: 70,
//                             height: 70,
//                             decoration: BoxDecoration(
//                               shape: BoxShape.circle,
//                               gradient: _shouldShowGradient(story) ? FeedTheme.storyRing : null,
//                               color: _shouldShowGradient(story) ? null : FeedTheme.outlineVariant,
//                               boxShadow: _shouldShowGradient(story)
//                                   ? [
//                                 BoxShadow(
//                                   color: FeedTheme.storyGradient3.withOpacity(0.25),
//                                   blurRadius: 8,
//                                   offset: const Offset(0, 2),
//                                 ),
//                               ]
//                                   : null,
//                             ),
//                             child: Padding(
//                               padding: const EdgeInsets.all(3.0),
//                               child: Container(
//                                 decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(2.0),
//                                   child: ClipOval(
//                                     child: Image.network(
//                                       story.avatarUrl,
//                                       width: 58,
//                                       height: 58,
//                                       fit: BoxFit.cover,
//                                       errorBuilder: (context, error, stackTrace) => Container(
//                                         width: 58,
//                                         height: 58,
//                                         color: FeedTheme.selectedBg,
//                                         child: const Icon(Icons.person, color: FeedTheme.primaryTeal, size: 28),
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                           if (story.isLive)
//                             Positioned(
//                               bottom: 1,
//                               child: Container(
//                                 padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(colors: [Color(0xFFFF3B5C), Color(0xFFFF6B8B)]),
//                                   borderRadius: BorderRadius.circular(4),
//                                   border: Border.all(color: Colors.white, width: 1.5),
//                                   boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.35), blurRadius: 4, offset: const Offset(0, 1))],
//                                 ),
//                                 child: const Text(
//                                   'LIVE',
//                                   style: TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800, letterSpacing: 0.3),
//                                 ),
//                               ),
//                             ),
//                           if (index == 0)
//                             Positioned(
//                               bottom: 0,
//                               right: 0,
//                               child: Container(
//                                 width: 21,
//                                 height: 21,
//                                 decoration: BoxDecoration(
//                                   gradient: FeedTheme.brandGradient,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white, width: 2),
//                                   boxShadow: [BoxShadow(color: FeedTheme.primaryTeal.withOpacity(0.4), blurRadius: 4, offset: const Offset(0, 1))],
//                                 ),
//                                 child: const Icon(Icons.add, color: Colors.white, size: 13),
//                               ),
//                             ),
//                           if (story.isCloseFriend && !story.hasViewed)
//                             Positioned(
//                               top: 1,
//                               right: 1,
//                               child: Container(
//                                 padding: const EdgeInsets.all(2),
//                                 decoration: BoxDecoration(
//                                   color: const Color(0xFF16A34A),
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Colors.white, width: 1),
//                                 ),
//                                 child: const Icon(Icons.star_rounded, color: Colors.white, size: 8),
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     SizedBox(
//                       width: 68,
//                       child: Text(
//                         story.name,
//                         style: FeedTheme.body(10, color: FeedTheme.textDark, bold: index == 0 || story.isLive),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         textAlign: TextAlign.center,
//                       ),
//                     ),
//                     if (!story.hasViewed && story.unviewedCount > 1)
//                       Container(
//                         margin: const EdgeInsets.only(top: 2),
//                         padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
//                         decoration: BoxDecoration(
//                           gradient: FeedTheme.brandGradient,
//                           borderRadius: BorderRadius.circular(4),
//                         ),
//                         child: Text(
//                           '+${story.unviewedCount}',
//                           style: const TextStyle(color: Colors.white, fontSize: 7, fontWeight: FontWeight.w800),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   bool _shouldShowGradient(StoryUser story) {
//     return story.stories.any((s) => !s.isViewed);
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // STORY VIEWER
// // ══════════════════════════════════════════════════════════
//
// class StoryViewer extends StatefulWidget {
//   final List<StoryUser> stories;
//   final int initialIndex;
//   final Function(int) onStoryViewed;
//
//   const StoryViewer({
//     super.key,
//     required this.stories,
//     required this.initialIndex,
//     required this.onStoryViewed,
//   });
//
//   @override
//   State<StoryViewer> createState() => _StoryViewerState();
// }
//
// class _StoryViewerState extends State<StoryViewer> with SingleTickerProviderStateMixin {
//   late int _currentUserIndex;
//   late int _currentStoryIndex;
//   late PageController _pageController;
//   late AnimationController _progressController;
//   bool _isPaused = false;
//   final bool _isVisible = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _currentUserIndex = widget.initialIndex;
//     _currentStoryIndex = 0;
//     _pageController = PageController(initialPage: _currentUserIndex);
//     _progressController = AnimationController(vsync: this, duration: const Duration(seconds: 5))
//       ..addStatusListener((status) {
//         if (status == AnimationStatus.completed && _isVisible) {
//           _nextStory();
//         }
//       });
//     _progressController.forward();
//   }
//
//   @override
//   void dispose() {
//     _pageController.dispose();
//     _progressController.dispose();
//     super.dispose();
//   }
//
//   void _nextStory() {
//     final currentStories = widget.stories[_currentUserIndex].stories;
//     if (_currentStoryIndex < currentStories.length - 1) {
//       setState(() {
//         _currentStoryIndex++;
//         _progressController.reset();
//         _progressController.forward();
//       });
//     } else if (_currentUserIndex < widget.stories.length - 1) {
//       _goToUser(_currentUserIndex + 1);
//     } else {
//       Navigator.pop(context);
//     }
//   }
//
//   void _previousStory() {
//     if (_currentStoryIndex > 0) {
//       setState(() {
//         _currentStoryIndex--;
//         _progressController.reset();
//         _progressController.forward();
//       });
//     } else if (_currentUserIndex > 0) {
//       _goToUser(_currentUserIndex - 1);
//     }
//   }
//
//   void _goToUser(int index) {
//     setState(() {
//       _currentUserIndex = index;
//       _currentStoryIndex = 0;
//       _progressController.reset();
//       _progressController.forward();
//     });
//     _pageController.animateToPage(index, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
//     widget.onStoryViewed(index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: GestureDetector(
//         onTapDown: (details) {
//           final screenWidth = MediaQuery.of(context).size.width;
//           if (details.globalPosition.dx < screenWidth / 2) {
//             _previousStory();
//           } else {
//             _nextStory();
//           }
//         },
//         onLongPress: () => setState(() {
//           _isPaused = true;
//           _progressController.stop();
//         }),
//         onLongPressUp: () => setState(() {
//           _isPaused = false;
//           _progressController.forward();
//         }),
//         child: Stack(
//           children: [
//             PageView(
//               controller: _pageController,
//               physics: const NeverScrollableScrollPhysics(),
//               children: widget.stories.map((user) {
//                 return Container(
//                   decoration: const BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Color(0xFF141414), Colors.black],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                   child: Center(
//                     child: Column(
//                       children: [
//                         const SizedBox(height: 40),
//                         Expanded(
//                           child: Container(
//                             margin: const EdgeInsets.symmetric(horizontal: 16),
//                             decoration: BoxDecoration(
//                               gradient: LinearGradient(
//                                 colors: [Colors.grey[900]!, Colors.grey[850]!],
//                                 begin: Alignment.topLeft,
//                                 end: Alignment.bottomRight,
//                               ),
//                               borderRadius: BorderRadius.circular(18),
//                               boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 24, offset: const Offset(0, 10))],
//                             ),
//                             child: Center(
//                               child: Column(
//                                 mainAxisAlignment: MainAxisAlignment.center,
//                                 children: [
//                                   Container(
//                                     padding: const EdgeInsets.all(3),
//                                     decoration: BoxDecoration(shape: BoxShape.circle, gradient: FeedTheme.storyRing),
//                                     child: ClipOval(
//                                       child: Image.network(
//                                         user.avatarUrl,
//                                         width: 80,
//                                         height: 80,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (context, error, stackTrace) => Container(
//                                           width: 80,
//                                           height: 80,
//                                           color: Colors.grey[800],
//                                           child: const Icon(Icons.person, color: Colors.white, size: 40),
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                   const SizedBox(height: 18),
//                                   Text(
//                                     user.name,
//                                     style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800, letterSpacing: -0.3),
//                                   ),
//                                   const SizedBox(height: 8),
//                                   if (user.stories[_currentStoryIndex].caption != null)
//                                     Padding(
//                                       padding: const EdgeInsets.symmetric(horizontal: 24),
//                                       child: Text(
//                                         user.stories[_currentStoryIndex].caption!,
//                                         style: const TextStyle(color: Colors.white70, fontSize: 15, height: 1.4),
//                                         textAlign: TextAlign.center,
//                                       ),
//                                     ),
//                                   const SizedBox(height: 20),
//                                   Container(
//                                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
//                                     decoration: BoxDecoration(color: Colors.white.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
//                                     child: Text(
//                                       '${_currentStoryIndex + 1}/${user.stories.length}',
//                                       style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         const SizedBox(height: 20),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//             Positioned(
//               top: 40,
//               left: 0,
//               right: 0,
//               child: Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: Row(
//                   children: widget.stories[_currentUserIndex].stories.asMap().entries.map((entry) {
//                     final isCurrent = entry.key == _currentStoryIndex;
//                     final isViewed = entry.value.isViewed || entry.key < _currentStoryIndex;
//                     return Expanded(
//                       child: Container(
//                         height: 3,
//                         margin: const EdgeInsets.symmetric(horizontal: 2),
//                         decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)),
//                         child: isCurrent && !_isPaused
//                             ? AnimatedBuilder(
//                           animation: _progressController,
//                           builder: (context, child) {
//                             return FractionallySizedBox(
//                               widthFactor: _progressController.value,
//                               alignment: Alignment.centerLeft,
//                               child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
//                             );
//                           },
//                         )
//                             : isViewed
//                             ? Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2)))
//                             : null,
//                       ),
//                     );
//                   }).toList(),
//                 ),
//               ),
//             ),
//             Positioned(
//               top: 40,
//               right: 12,
//               child: IconButton(
//                 splashRadius: 22,
//                 icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ),
//             Positioned(
//               top: 80,
//               left: 24,
//               child: Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(1.5),
//                     decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white54, width: 1)),
//                     child: ClipOval(
//                       child: Image.network(
//                         widget.stories[_currentUserIndex].avatarUrl,
//                         width: 30,
//                         height: 30,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) => Container(width: 30, height: 30, color: Colors.grey[800]),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     widget.stories[_currentUserIndex].name,
//                     style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // SIDE OVERVIEW PANEL
// // ══════════════════════════════════════════════════════════
//
// class SideOverviewPanel extends StatelessWidget {
//   const SideOverviewPanel({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           padding: const EdgeInsets.all(18),
//           decoration: BoxDecoration(
//             gradient: const LinearGradient(
//               colors: [FeedTheme.surfaceContainerLowest, FeedTheme.selectedBg],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//             borderRadius: BorderRadius.circular(18),
//             boxShadow: FeedTheme.softShadow,
//           ),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(8),
//                     decoration: BoxDecoration(gradient: FeedTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
//                     child: const Icon(Icons.insights_rounded, color: Colors.white, size: 18),
//                   ),
//                   const SizedBox(width: 10),
//                   Text("Executive Overview", style: FeedTheme.heading(16)),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               Text.rich(
//                 TextSpan(
//                   text: 'Strategic status: ',
//                   style: FeedTheme.body(13),
//                   children: const [
//                     TextSpan(
//                       text: 'Optimal',
//                       style: TextStyle(color: FeedTheme.activeTeal, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(height: 18),
//               _metricRow("Engagement", "+12.4%"),
//               const SizedBox(height: 12),
//               _metricRow("New Members", "+450"),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _metricRow(String label, String value) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label.toUpperCase(), style: FeedTheme.body(11, color: FeedTheme.textLight).copyWith(letterSpacing: 0.6, fontWeight: FontWeight.w600)),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//           decoration: BoxDecoration(color: const Color(0xFF15803D).withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
//           child: Text(value, style: FeedTheme.body(13, color: const Color(0xFF15803D), bold: true)),
//         ),
//       ],
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // QUICK STATUS UPDATE ROW
// // ══════════════════════════════════════════════════════════
//
// class QuickStatusUpdateRow extends StatelessWidget {
//   const QuickStatusUpdateRow({super.key});
//
//   void _openCreatePostModal(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => const CreatePostModal(),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(14),
//       decoration: FeedTheme.card(radius: 18),
//       child: Row(
//         children: [
//           GestureDetector(
//             onTap: () => _openCreatePostModal(context),
//             child: Container(
//               padding: const EdgeInsets.all(2),
//               decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: FeedTheme.outlineVariant, width: 1.5)),
//               child: ClipOval(
//                 child: Image.network(
//                   'https://lh3.googleusercontent.com/aida-public/AB6AXuCjROtURqL93PgulLZeoQISnVMbeVSXeJZJjeLS91RV6bmgMKQymFpZ_utBLCs055N5AX4xs0IugklqoBczkEaX0hbcQn_RZBpAJk72jtsnuCW7s4z4j1B1Q12ggbPunW50AZGyoyA8pEUadRV_dLcs0qgNtJaeCt6jVRcs2Q0Dzc25ouX2QwdKAgnSo-A5TgZyuUkeehKO0TeVM-u5ER9Y3fILJHS5AXZriszyEVfacfEVyqX-7qdz',
//                   width: 40,
//                   height: 40,
//                   fit: BoxFit.cover,
//                 ),
//               ),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: GestureDetector(
//               onTap: () => _openCreatePostModal(context),
//               child: Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
//                 decoration: BoxDecoration(
//                   color: FeedTheme.surfaceContainerLow,
//                   borderRadius: BorderRadius.circular(26),
//                 ),
//                 child: Text("Draft a community update...", style: FeedTheme.body(14)),
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Material(
//             color: Colors.transparent,
//             child: InkWell(
//               borderRadius: BorderRadius.circular(20),
//               onTap: () => _openCreatePostModal(context),
//               child: Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(gradient: FeedTheme.brandGradient, shape: BoxShape.circle),
//                 child: const Icon(Icons.add_rounded, color: Colors.white, size: 22),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // POST CARDS
// // ══════════════════════════════════════════════════════════
//
// class PostTextCard extends StatelessWidget {
//   const PostTextCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: FeedTheme.card(),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAuthorHeader(
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuAm1Y-cM-txAeQqpeUrttSjZpGFbUAOJvsif64_ecYneK5YroKzXv1DS1ddYVyQWZp1Z3wQgqNdm8AvlqZowiUj0XRrEdT8Fc65ji5AYLFC1wqhiq7xTHHIl68-RwiTYfbnt9NfA3pG7ho--7BIOWutFlpVVf4GDXP0CpVsudogYo2jnf5vGT6faUYh3PQaai8aXvS1xINLwslSx8r0pHtuH_CTyoinVmehyRpP8Myy2mKDsk8HZZJI',
//             'Sarah Mitchell',
//             'Director • 2h ago',
//             'Strategic Update',
//             FeedTheme.activeTeal,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//             child: Text(
//               "Following our quarterly review, we are seeing a significant shift in community sentiment towards sustainable governance. I've uploaded the primary findings to the internal dashboard for further review by the committee.",
//               style: FeedTheme.body(15, color: FeedTheme.textDark).copyWith(height: 1.5),
//             ),
//           ),
//           const SizedBox(height: 6),
//           _buildEngagementBar('24', '8', '1.2k Views'),
//         ],
//       ),
//     );
//   }
// }
//
// class PostImageCard extends StatelessWidget {
//   const PostImageCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: FeedTheme.card(),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAuthorHeader(
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuCnSNN9Ev9bSWwWJ0jVDJa7v95KZHw03OdmS74O_DUX6cKOqIeGzjd0y6JVJ24p97C2c1tDmdH26A5LA5VyV4nHvrFOVtPImUujWTdavfhUcq412ieukjKH5xlby9dVhcjoEp2gs208yU1gxl2fA1-ogBOj40rw0hgsU74eX829kySW-tRQJKNxPmOZ_TM4UeVfioSyfE-Is-o44UiXGUaUcNiz2q84vAVVfRbgUOMpET5APCsbQ1JO',
//             'David Chen',
//             'Strategist • 5h ago',
//             'Insights',
//             FeedTheme.statusGrowing,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text('Visualizing the impact of our latest regional campaign.', style: FeedTheme.body(14, color: FeedTheme.textDark)),
//           ),
//           const SizedBox(height: 10),
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Image.network(
//               'https://lh3.googleusercontent.com/aida-public/AB6AXuDNJaxx--dEpn58nLrLsuVU22zy_1B9kd7zR85UVOG6yITw4rFQALVSUXIQ4phjB2Bl2FqW2oHnbxZlKOdpLHQ3-gm2y7zHSSYLjMa6fjTI1bY1H05cwAmcY31C5jwMzodJ5IpQ2E2Mgvx_P7rkSCS5cl50pEdBt9ZRA0XM41zfGW2_9j9_gv0vNqgKKr6DMMPg67-mMAtvgAenuc6d1yFNI3DypCfz7refJD8z1PyhqRzA_Spfpymo',
//               fit: BoxFit.cover,
//             ),
//           ),
//           _buildEngagementBar('142', '32', '3.5k Views'),
//         ],
//       ),
//     );
//   }
// }
//
// class PostVideoCard extends StatelessWidget {
//   const PostVideoCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: FeedTheme.card(),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Row(
//               children: [
//                 Container(
//                   width: 42,
//                   height: 42,
//                   decoration: BoxDecoration(gradient: FeedTheme.brandGradient, borderRadius: BorderRadius.circular(10)),
//                   alignment: Alignment.center,
//                   child: Text('TM', style: FeedTheme.body(14, color: Colors.white, bold: true)),
//                 ),
//                 const SizedBox(width: 12),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Training Media', style: FeedTheme.heading(14)),
//                     Text('Educational Branch • 12h ago', style: FeedTheme.body(11)),
//                   ],
//                 )
//               ],
//             ),
//           ),
//           AspectRatio(
//             aspectRatio: 16 / 9,
//             child: Stack(
//               alignment: Alignment.center,
//               children: [
//                 Image.network(
//                   'https://lh3.googleusercontent.com/aida-public/AB6AXuCure-d83KWmFNlPbJv_xTvE8lu_ElFDWVZh-B6sn3WvUDIE9rR9fyfvscdQuVnOfSumWtQmTwT4Vaze4cXOdgS8U98FNGQsXqjzqDUTI2TYTlzLAPGyZqKMwuZHiSm6tKJRzu-S6i-VxdgWKOWL4D9q5bnXdS7g4Fdkof5fU16OF4VNQe-ZOf4l5Ree9c6w91Pz7P6Mg4nu2JXCOdo1rTiCtiEGtjOQGb6WJ1pFIdDQ4OK-D0KeM0A',
//                   fit: BoxFit.cover,
//                   width: double.infinity,
//                   height: double.infinity,
//                 ),
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.35)],
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   width: 60,
//                   height: 60,
//                   decoration: BoxDecoration(
//                     shape: BoxShape.circle,
//                     gradient: FeedTheme.brandGradient,
//                     boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 14, offset: const Offset(0, 4))],
//                   ),
//                   child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 36),
//                 ),
//                 Positioned(
//                   bottom: 10,
//                   right: 10,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                     decoration: BoxDecoration(color: Colors.black.withOpacity(0.55), borderRadius: BorderRadius.circular(6)),
//                     child: const Text('3:42', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           _buildEngagementBar('98', '12', '5.1k Views'),
//         ],
//       ),
//     );
//   }
// }
//
// class PostGalleryCard extends StatelessWidget {
//   const PostGalleryCard({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: FeedTheme.card(),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           _buildAuthorHeader(
//             'https://lh3.googleusercontent.com/aida-public/AB6AXuCNIS1tQpvP0kkwlBlC26UVrtnoxGPplSnzenXLpyynw_Ch36k33qhSJeT5iyqdpPELxHvZCNktXs-iR9_nfh_SyDwbqtAkK9-WWAvS72EtAwjtskTbJG-fWsPsHV7mq7PTr6PzpfPlsVR9fiWDI6J0cXqtTKQ6MnW7sDVoA017j6Q9urSFpEURSbVtUhrLEVf2T3k08Vhbs8ItNViek4n_-QdnHR_nK9SU5xSae_p0vdD_tioWMSu1',
//             'Elena Rodriguez',
//             'Research Lead • 1d ago',
//             'Gallery',
//             FeedTheme.textLight,
//           ),
//           Padding(
//             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
//             child: Text("Highlights from the 'Intelligence & Community' exhibition last week.", style: FeedTheme.body(14, color: FeedTheme.textDark)),
//           ),
//           const SizedBox(height: 10),
//           Container(
//             height: 240,
//             padding: const EdgeInsets.symmetric(horizontal: 2),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(2),
//                     child: ClipRRect(
//                       borderRadius: BorderRadius.circular(10),
//                       child: Image.network(
//                         'https://lh3.googleusercontent.com/aida-public/AB6AXuA4NcJIhU4VtzQFVkmqGSqR91YX_w2s0P_8z2TcPe2CqJ6pvnq1ZVOPqw3xtxSkHgum_r4i1xvsLk8x81cHQzTV45jZvoBLg3Dmw9Lo8UytngG0niOIE3C150UFfFaoE-Vb33HoS6PS1G6vtPWsO2HX3ZNsWurjPGuv2U3TMYqOd-h69at4esCkF55NPiP2UtyLUbY-hqdet8U4_GrZ-FR_miTi0CpyaxoIc4ef238vyvmnMiSwnZQ2',
//                         fit: BoxFit.cover,
//                         height: double.infinity,
//                       ),
//                     ),
//                   ),
//                 ),
//                 Expanded(
//                   child: Column(
//                     children: [
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(2),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Image.network(
//                               'https://lh3.googleusercontent.com/aida-public/AB6AXuCVJzOk2vRcpvYZRy_usO_rmqdhCAkwg_PzQvYaBsunsTvScU1jAoAxdh4EVUmVhPTTjCgOOE1uYNQG9Yrjh78FdeXhOe5aeVf_TBZMCmUF2KwcMweKrdYZlJRWiIIKJie8HjyHLrgSx6quSHXRlMFq10NPjbNOwXilxttCb4ysbT8R9kBs7rOdn-Vs7Ge1mnkCVB3bIzbm3xACDBCipXMDfgyIi_mctucF7dqS27C0ltHTgzLsxW9D',
//                               fit: BoxFit.cover,
//                               width: double.infinity,
//                             ),
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Padding(
//                           padding: const EdgeInsets.all(2),
//                           child: ClipRRect(
//                             borderRadius: BorderRadius.circular(10),
//                             child: Stack(
//                               fit: StackFit.expand,
//                               children: [
//                                 Image.network(
//                                   'https://lh3.googleusercontent.com/aida-public/AB6AXuBhoDm5e3L6wfu1DqbaUGSpRpUOyKlXuvC0rOvKZyKReQkMyrDaqSDnX-7GwaKXlXwk8ELYMg00kOM92WJ8ytNjsWpaBeW-QRruq1m0J3xk8Xu97NGta_2XJ-JeXVYKtdPGlFiPqDBFzeCDKJ5AeevBjEpZJXeghsCdsuIC7Xj8LpDTVrY5p4043_5YITyZ11Vuvs8Zpkh8FzJ1oTMNnDifkooQPd-ZItCQF6CXSJD3LUu6dIffIWa8',
//                                   fit: BoxFit.cover,
//                                 ),
//                                 Container(
//                                   color: Colors.black.withOpacity(0.5),
//                                   alignment: Alignment.center,
//                                   child: Text('+5 More', style: FeedTheme.body(16, color: Colors.white, bold: true)),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//           _buildEngagementBar('56', '4', '800 Shares'),
//         ],
//       ),
//     );
//   }
// }
//
// class SponsoredHorizontalCarousel extends StatelessWidget {
//   const SponsoredHorizontalCarousel({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: FeedTheme.card(color: FeedTheme.surfaceContainerLow),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text('Sponsored Products', style: FeedTheme.heading(15, bold: true, color: FeedTheme.primaryTeal)),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//                 decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6), boxShadow: FeedTheme.softShadow),
//                 child: Text('Sponsored', style: FeedTheme.body(10, bold: true, color: FeedTheme.textLight)),
//               )
//             ],
//           ),
//           const SizedBox(height: 14),
//           SizedBox(
//             height: 240,
//             child: ListView(
//               scrollDirection: Axis.horizontal,
//               children: [
//                 _productCard(
//                   'https://lh3.googleusercontent.com/aida-public/AB6AXuCdukG5Bs5MYrKezSVgml7mh082CzrDdiWUG-blbFr_Gen8Cv8vJoLMA3Y6nukYWyRcyYXb9NzEjwXtN1CzRM7TLk2tO4DkAhJNmAQPqNnzCN9CNLVEjbo_fmEAMR37_LtF0aTndX9xRuIA5PTI6XjAV5u36NzPAGo4wWHHoZPE_RrFxMeysFqgZmucUAVmuBxzymBpxMxtRRUpIB3yjYhSUfgrz7PY3Jp8166tWsIFuWuqQPKAm37i',
//                   'Focus Pro ANC',
//                   '\$299.00',
//                 ),
//                 const SizedBox(width: 12),
//                 _productCard(
//                   'https://lh3.googleusercontent.com/aida-public/AB6AXuBOgKANhjHiOPlvSv4sED6CvcyV5KI3tc3FBKGGFrBUWqgq-PQIIjY5cmd8RPSlS2F1QpETUFl_3UqMU8_jrxNC2GmKLUqpSqakpX12wWDvdMVma40HxkGE5fx77c2QPFBEiQ3Fz0BOhPp9UguJUftrIcE-eUgWwRHlEmJ4d6d-BvHy9qNpwA9SFRfZ_OVDb7AInfLCZdel-VsE00_SuKdGeZ1KFkxFya-LE9suk23SIsUN6FLg8qDq',
//                   'Precision MX Mouse',
//                   '\$89.00',
//                 ),
//               ],
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _productCard(String img, String name, String price) {
//     return Container(
//       width: 168,
//       clipBehavior: Clip.antiAlias,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: FeedTheme.softShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Full-bleed image with floating badges + quick-add button
//           SizedBox(
//             height: 128,
//             width: double.infinity,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 Image.network(img, fit: BoxFit.cover),
//                 // Bottom gradient so the wishlist icon stays legible
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [Colors.transparent, Colors.black.withOpacity(0.28)],
//                     ),
//                   ),
//                 ),
//                 // "Sale" ribbon
//                 Positioned(
//                   top: 8,
//                   left: 8,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFFEF4B6E),
//                       borderRadius: BorderRadius.circular(6),
//                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 4, offset: const Offset(0, 2))],
//                     ),
//                     child: const Text(
//                       '-20%',
//                       style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800, letterSpacing: 0.2),
//                     ),
//                   ),
//                 ),
//                 // Wishlist toggle
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     padding: const EdgeInsets.all(5),
//                     decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
//                     child: const Icon(Icons.favorite_border_rounded, size: 14, color: FeedTheme.likeRed),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name, style: FeedTheme.heading(13), maxLines: 1, overflow: TextOverflow.ellipsis),
//                 const SizedBox(height: 4),
//                 // Star rating row
//                 Row(
//                   children: [
//                     const Icon(Icons.star_rounded, size: 14, color: Color(0xFFFFC93D)),
//                     const SizedBox(width: 2),
//                     Text('4.8', style: FeedTheme.body(11, color: FeedTheme.textLight, bold: true)),
//                     const SizedBox(width: 4),
//                     Text('(212)', style: FeedTheme.body(10, color: FeedTheme.textLight)),
//                   ],
//                 ),
//                 const SizedBox(height: 8),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(price, style: FeedTheme.body(15, color: FeedTheme.primaryTeal, bold: true)),
//                     Container(
//                       padding: const EdgeInsets.all(6),
//                       decoration: BoxDecoration(gradient: FeedTheme.brandGradient, shape: BoxShape.circle),
//                       child: const Icon(Icons.add_shopping_cart_rounded, size: 14, color: Colors.white),
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class DiscoverDynamicGrid extends StatelessWidget {
//   const DiscoverDynamicGrid({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     final List<Map<String, dynamic>> discoverItems = [
//       {"icon": Icons.work_outline_rounded, "title": "Senior Analyst", "sub": "Regional HQ", "color": FeedTheme.statusGrowing},
//       {"icon": Icons.workspace_premium_outlined, "title": "Annual Summit", "sub": "Transformation", "color": FeedTheme.statusModerated},
//       {"icon": Icons.volunteer_activism_outlined, "title": "Tech For All", "sub": "Goal: 85%", "color": FeedTheme.activeTeal},
//     ];
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: FeedTheme.card(color: FeedTheme.surfaceContainerLow),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text('Discover More', style: FeedTheme.heading(15, color: FeedTheme.primaryTeal)),
//           const SizedBox(height: 14),
//           SizedBox(
//             height: 140,
//             child: ListView.builder(
//               scrollDirection: Axis.horizontal,
//               itemCount: discoverItems.length,
//               itemBuilder: (context, index) {
//                 final item = discoverItems[index];
//                 return Padding(
//                   padding: const EdgeInsets.only(right: 12.0),
//                   child: _marketBadgeCard(
//                     item["icon"] as IconData,
//                     item["title"] as String,
//                     item["sub"] as String,
//                     item["color"] as Color,
//                   ),
//                 );
//               },
//             ),
//           )
//         ],
//       ),
//     );
//   }
//
//   Widget _marketBadgeCard(IconData icon, String title, String sub, Color topColor) {
//     return Container(
//       width: 180,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: FeedTheme.softShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(8),
//             decoration: BoxDecoration(color: topColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
//             child: Icon(icon, color: topColor, size: 22),
//           ),
//           const SizedBox(height: 12),
//           Text(title, style: FeedTheme.heading(13), maxLines: 1, overflow: TextOverflow.ellipsis),
//           const SizedBox(height: 2),
//           Text(sub, style: FeedTheme.body(11), maxLines: 1, overflow: TextOverflow.ellipsis),
//         ],
//       ),
//     );
//   }
// }
//
// class CreatePostModal extends StatefulWidget {
//   const CreatePostModal({super.key});
//
//   @override
//   State<CreatePostModal> createState() => _CreatePostModalState();
// }
//
// class _CreatePostModalState extends State<CreatePostModal> {
//   String _selectedCategory = 'Strategic Update';
//   String _selectedCommunity = 'Global Leadership';
//
//   InputBorder _fieldBorder(Color color) => OutlineInputBorder(
//     borderRadius: BorderRadius.circular(10),
//     borderSide: BorderSide(color: color),
//   );
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//       ),
//       padding: EdgeInsets.only(
//         top: 10,
//         left: 18,
//         right: 18,
//         bottom: MediaQuery.of(context).viewInsets.bottom + 18,
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               width: 40,
//               height: 4,
//               margin: const EdgeInsets.only(bottom: 14),
//               decoration: BoxDecoration(color: FeedTheme.outlineVariant, borderRadius: BorderRadius.circular(2)),
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(7),
//                     decoration: BoxDecoration(gradient: FeedTheme.brandGradient, borderRadius: BorderRadius.circular(8)),
//                     child: const Icon(Icons.edit_square, color: Colors.white, size: 16),
//                   ),
//                   const SizedBox(width: 10),
//                   Text('Draft Community Update', style: FeedTheme.heading(16)),
//                 ],
//               ),
//               IconButton(
//                 splashRadius: 20,
//                 icon: const Icon(Icons.close_rounded, color: FeedTheme.textLight),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//           Row(
//             children: [
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedCategory,
//                   decoration: InputDecoration(
//                     labelText: 'POST CATEGORY',
//                     labelStyle: FeedTheme.body(10, bold: true),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     border: _fieldBorder(FeedTheme.outlineVariant),
//                     enabledBorder: _fieldBorder(FeedTheme.outlineVariant),
//                     focusedBorder: _fieldBorder(FeedTheme.primaryTeal),
//                   ),
//                   items: <String>['Strategic Update', 'Market Insight', 'Community Question', 'Official Announcement']
//                       .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: FeedTheme.body(13, color: FeedTheme.textDark))))
//                       .toList(),
//                   onChanged: (val) => setState(() => _selectedCategory = val!),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedCommunity,
//                   decoration: InputDecoration(
//                     labelText: 'TARGET COMMUNITY',
//                     labelStyle: FeedTheme.body(10, bold: true),
//                     contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                     border: _fieldBorder(FeedTheme.outlineVariant),
//                     enabledBorder: _fieldBorder(FeedTheme.outlineVariant),
//                     focusedBorder: _fieldBorder(FeedTheme.primaryTeal),
//                   ),
//                   items: <String>['Global Leadership', 'Regional Directors', 'Product Strategy']
//                       .map((String value) => DropdownMenuItem<String>(value: value, child: Text(value, style: FeedTheme.body(13, color: FeedTheme.textDark))))
//                       .toList(),
//                   onChanged: (val) => setState(() => _selectedCommunity = val!),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 16),
//           TextField(
//             maxLines: 4,
//             style: FeedTheme.body(14, color: FeedTheme.textDark),
//             decoration: InputDecoration(
//               hintText: 'Share your strategic vision...',
//               hintStyle: FeedTheme.body(14),
//               alignLabelWithHint: true,
//               border: _fieldBorder(FeedTheme.outlineVariant),
//               enabledBorder: _fieldBorder(FeedTheme.outlineVariant),
//               focusedBorder: _fieldBorder(FeedTheme.primaryTeal),
//             ),
//           ),
//           const SizedBox(height: 14),
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.symmetric(vertical: 22),
//             decoration: BoxDecoration(
//               color: FeedTheme.selectedBg,
//               borderRadius: BorderRadius.circular(14),
//               border: Border.all(color: FeedTheme.activeTeal.withOpacity(0.3), width: 1.2),
//             ),
//             child: Column(
//               children: [
//                 const Icon(Icons.cloud_upload_outlined, color: FeedTheme.primaryTeal, size: 28),
//                 const SizedBox(height: 6),
//                 Text('Drop media or documents here to attach', style: FeedTheme.body(12, color: FeedTheme.primaryTeal)),
//               ],
//             ),
//           ),
//           const SizedBox(height: 18),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Row(
//                 children: const [
//                   Icon(Icons.mood_outlined, color: FeedTheme.textLight),
//                   SizedBox(width: 14),
//                   Icon(Icons.location_on_outlined, color: FeedTheme.textLight),
//                   SizedBox(width: 14),
//                   Icon(Icons.alternate_email_outlined, color: FeedTheme.textLight),
//                   SizedBox(width: 14),
//                   Icon(Icons.image_outlined, color: FeedTheme.textLight),
//                 ],
//               ),
//               Container(
//                 decoration: BoxDecoration(
//                   gradient: FeedTheme.brandGradient,
//                   borderRadius: BorderRadius.circular(10),
//                   boxShadow: [BoxShadow(color: FeedTheme.primaryTeal.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
//                 ),
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Colors.transparent,
//                     shadowColor: Colors.transparent,
//                     foregroundColor: Colors.white,
//                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
//                     padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 13),
//                   ),
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text('Publish Post', style: TextStyle(fontWeight: FontWeight.bold)),
//                 ),
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════
// // HELPER FUNCTIONS
// // ══════════════════════════════════════════════════════════
//
// Widget _buildAuthorHeader(String avatar, String name, String sub, String label, Color labelColor) {
//   return Padding(
//     padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10),
//               child: Image.network(avatar, width: 40, height: 40, fit: BoxFit.cover),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(name, style: FeedTheme.heading(14)),
//                 const SizedBox(height: 2),
//                 Text(sub, style: FeedTheme.body(11)),
//               ],
//             )
//           ],
//         ),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
//           decoration: BoxDecoration(color: labelColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
//           child: Text(label, style: FeedTheme.body(11, color: labelColor, bold: true)),
//         )
//       ],
//     ),
//   );
// }
//
// Widget _buildEngagementBar(String likes, String comments, String views) {
//   return Container(
//     padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//     decoration: BoxDecoration(
//       color: FeedTheme.surfaceContainerLow,
//       border: const Border(top: BorderSide(color: FeedTheme.outlineVariant, width: 1)),
//     ),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Row(
//           children: [
//             _engagementChip(Icons.favorite_border_rounded, likes, FeedTheme.likeRed),
//             const SizedBox(width: 8),
//             _engagementChip(Icons.chat_bubble_outline_rounded, comments, FeedTheme.primaryTeal),
//             const SizedBox(width: 8),
//             _engagementChip(Icons.share_outlined, null, FeedTheme.textLight),
//           ],
//         ),
//         Text(views, style: FeedTheme.body(11, color: FeedTheme.textLight)),
//       ],
//     ),
//   );
// }
//
// Widget _engagementChip(IconData icon, String? label, Color color) {
//   return Material(
//     color: Colors.white,
//     borderRadius: BorderRadius.circular(20),
//     child: InkWell(
//       borderRadius: BorderRadius.circular(20),
//       onTap: () {},
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//         decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: FeedTheme.outlineVariant)),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 16, color: color),
//             if (label != null) ...[
//               const SizedBox(width: 5),
//               Text(label, style: FeedTheme.body(12, color: FeedTheme.textDark, bold: true)),
//             ],
//           ],
//         ),
//       ),
//     ),
//   );
// }
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