import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_ecommerce_admin/common/growCommunities.dart';
import 'package:trading_ecommerce_admin/services/auth_User_and_Business_Session.dart';
import 'package:trading_ecommerce_admin/widgets/stat_card.dart';
import 'package:trading_ecommerce_admin/widgets/personalize_feed_dialog.dart';
import 'package:trading_ecommerce_admin/widgets/create_post_dialog.dart';
import 'package:trading_ecommerce_admin/admin/explore_communities_screen.dart';
import 'package:trading_ecommerce_admin/admin/site_settings_screen.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/screens/membership_payment_modal.dart';
import 'package:trading_ecommerce_admin/admin/profile_screen.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/common/chat_screen.dart';
import 'package:trading_ecommerce_admin/common/community_inbox_screen.dart';
import 'package:trading_ecommerce_admin/widgets/account_actions.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';
import 'package:trading_ecommerce_admin/admin/seller_orders_screen.dart';
import 'package:trading_ecommerce_admin/admin/schedule_campaign_screen.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:trading_ecommerce_admin/admin/wallet_admin_screen.dart';
import 'package:trading_ecommerce_admin/admin/membership_plans_screen.dart';
import 'package:trading_ecommerce_admin/admin/community_monetization_screen.dart';
import 'package:trading_ecommerce_admin/admin/manage_promotional_packages_screen.dart';
import 'package:trading_ecommerce_admin/admin/promotional_package_orders_screen.dart';
import 'package:trading_ecommerce_admin/common/notification_screen.dart';

import '../admin/platform_settings_screen.dart';
import '../common/Industry_interest.dart';
import '../common/community_app_interest.dart';
import '../common/logout.dart';


class CommunityDashboardScreen extends StatefulWidget {
  const CommunityDashboardScreen({super.key});

  @override
  State<CommunityDashboardScreen> createState() => _CommunityDashboardScreenState();
}

class _CommunityDashboardScreenState extends State<CommunityDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int _currentIndex = 0;
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _memberSearchController = TextEditingController();


  final List<String> _sarahComments = [
    "Excellent insights on the governance shift. Looking forward to the full report."
  ];

  String? _extractYoutubeId(String text) {
    final RegExp regExp = RegExp(
      r'(?:https?://)?(?:www\.)?(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  String? _extractTwitterVideoUrl(String text) {
    final RegExp regExp = RegExp(
      r'(https?://(?:twitter\.com|x\.com)/[a-zA-Z0-9_]+/status/[0-9]+)',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(text);
    return match?.group(1);
  }

  Widget _buildYoutubePreview(String youtubeId) {
    final String thumbnailUrl = "https://img.youtube.com/vi/$youtubeId/0.jpg";
    final Uri youtubeUri = Uri.parse("https://www.youtube.com/watch?v=$youtubeId");

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrl(youtubeUri)) {
            await launchUrl(youtubeUri, mode: LaunchMode.externalApplication);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.black12,
                    child: const Icon(Icons.video_library_rounded, size: 48, color: Colors.grey),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 36,
              ),
            ),
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                color: Colors.black87,
                child: const Text(
                  "WATCH ON YOUTUBE",
                  style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwitterPreview(String xUrl) {
    final Uri xUri = Uri.parse(xUrl);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: InkWell(
        onTap: () async {
          if (await canLaunchUrl(xUri)) {
            await launchUrl(xUri, mode: LaunchMode.externalApplication);
          }
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "WATCH VIDEO ON X / TWITTER",
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Tap to watch directly on the X application.",
                    style: TextStyle(color: Colors.white70, fontSize: 10),
                  ),
                ],
              ),
            ),
            const Icon(Icons.open_in_new_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }

  static const Color primaryPurple = Color(0xFF006565);
  static const Color accentPurple = Color(0xFF008080);
  static const Color bgDark = Color(0xFF1E1E2C);
  static const Color bgLight = Color(0xFFF4F6FC);
  static const Color cardColor = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textLight = Color(0xFF757575);

  List<dynamic> _matchingMemberships = [];

  List<dynamic> _feedPosts = [];
  bool _isLoadingFeed = false;
  final Set<int> _expandedPostComments = {};
  final Map<int, TextEditingController> _commentControllers = {};
  final TextEditingController _postController = TextEditingController();

  int _totalMembers = 42800;
  int _totalPaidMembers = 8500;
  double _totalRevenue = 52400.0;
  int _pendingApprovalsCount = 124;
  bool _isLoadingStats = false;
  bool _isLoadingApprovals = false;
  List<dynamic> _pendingApprovals = [];
  int? _activeCommunityId;
  String _activeCommunityTitle = "Select Community";
  List<dynamic> _myCommunities = [];

  Future<void> _checkAndShowPersonalizeFeedModal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final bool hasPersonalized = prefs.getBool('has_personalized_feed') ?? false;
    if (!hasPersonalized) {
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const PersonalizeFeedDialog(),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchMyCommunities();
    _fetchHomeFeed();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAndShowPersonalizeFeedModal();
    });
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        final route = ModalRoute.of(context);
        if (route != null && route.isCurrent) {
          //_checkMembershipStatus();
        }
      }
    });
  }

  // Future<void> _checkMembershipStatus() async {
  //   final Vendorid=await UserSessionSet.instance.getVendorId();
  //   try {
  //
  //     final response = await Database().getData({
  //       'action': 'check_membership_status',
  //       'vendor_id': Vendorid,
  //
  //        if (Vendorid != null) 'admin_id': Vendorid.toString(),
  //     }, endpoint: 'new_apis/menu_apis.php');
  //
  //     if (response['success'] == true && response['data'] != null) {
  //       final showModal = response['data']['show_modal'] ?? false;
  //       final list = response['data']['memberships'] as List<dynamic>? ?? [];
  //       if (showModal && list.isNotEmpty) {
  //         setState(() {
  //           _matchingMemberships = list;
  //         });
  //         _showMembershipUpsellDialog();
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("Error checking membership status: $e");
  //   }
  // }

  Color _getMembershipColor(String title) {
    final t = title.toUpperCase();
    if (t.contains("GOLD")) return const Color(0xFFB45309);
    if (t.contains("SILVER")) return const Color(0xff006565);
    if (t.contains("BRONZE")) return Colors.grey.shade400;
    return const Color(0xff006565);
  }

  void _openCheckoutSheet(Map<String, dynamic> plan) {
    showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MembershipPaymentModal(
        planId: plan['id'],
        planTitle: plan['title'] ?? 'Membership',
        totalRawPrice: double.tryParse(plan['final_price']?.toString() ?? '') ?? 0.0,
        themeColor: const Color(0xff006565),
      ),
    ).then((success) {
      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Membership purchased successfully!"),
            backgroundColor: Color(0xff006565),
          ),
        );
        _fetchMyCommunities();
      }
    });
  }

  void _showMembershipUpsellDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 900,
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: const [
                            Icon(Icons.verified, color: Color(0xff006565), size: 20),
                            SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                "Serene Membership",
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xff006565),
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "SKIP FOR NOW",
                          style: TextStyle(
                            color: Color(0xFF3E4949),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        const Text(
                          "Unlock your ecosystem's full potential with a Serene Membership.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1C1B1B),
                            fontFamily: 'Manrope',
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "Get exclusive access to strategic partnerships, priority placement, and dedicated support designed for high-stakes administrative environments.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                        ),
                        const SizedBox(height: 32),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            if (_matchingMemberships.isEmpty) {
                              return const Center(
                                child: Text("No matching membership plans available"),
                              );
                            }

                            bool isWide = constraints.maxWidth > 850;
                            final cards = _matchingMemberships.map<Widget>((plan) {
                              final title = plan['title']?.toString() ?? 'Plan';
                              final double price = double.tryParse(plan['price']?.toString() ?? '0') ?? 0.0;
                              final double finalPrice = double.tryParse(plan['final_price']?.toString() ?? '0') ?? 0.0;
                              final double discount = double.tryParse(plan['discount']?.toString() ?? '0') ?? 0.0;

                              String validityText = plan['validity'].toString() == 'Unlimited'
                                  ? 'Lifetime Validity'
                                  : '${plan['validity']} Days Validity';

                              final List<String> features = [];
                              final details = plan['details'] as List<dynamic>? ?? [];
                              for (var det in details) {
                                features.add("${det['posts']} posts on ${det['display_name']}");
                              }
                              if (plan['include_team_members'] == 1 || plan['include_team_members'].toString() == '1') {
                                features.add("Includes ${plan['team_member_count']} team members");
                                features.add("Add member at ₹${plan['additional_member_price']}");
                              }

                              final color = _getMembershipColor(title);

                              return _buildPlanCard(
                                plan: Map<String, dynamic>.from(plan),
                                title: title,
                                price: "₹${finalPrice.toStringAsFixed(0)}",
                                validity: validityText,
                                oldPrice: discount > 0 ? "₹${price.toStringAsFixed(0)}" : "",
                                features: features,
                                color: color,
                                isFeatured: plan == _matchingMemberships.first,
                              );
                            }).toList();

                            return isWide
                                ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: cards.map((c) => Expanded(child: c)).toList(),
                            )
                                : Column(
                              children: cards.expand((c) => [c, const SizedBox(height: 16)]).toList()..removeLast(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xff006565),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Redirecting to all membership plans..."),
                                backgroundColor: Color(0xff006565),
                              ),
                            );
                          },
                          icon: const Text("View All Membership Plans", style: TextStyle(fontWeight: FontWeight.bold)),
                          label: const Icon(Icons.arrow_forward),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: const Color(0xFF3E4949)),
                        onPressed: () => Navigator.pop(context),
                        child: const Text(
                          "Not interested right now, take me to my dashboard",
                          textAlign: TextAlign.center,
                          style: TextStyle(decoration: TextDecoration.underline, fontSize: 13),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanCard({
    required Map<String, dynamic> plan,
    required String title,
    required String price,
    required String validity,
    required String oldPrice,
    required List<String> features,
    required Color color,
    bool isFeatured = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isFeatured ? const Color(0xff006565) : Colors.grey.shade200, width: isFeatured ? 2.5 : 1),
        boxShadow: isFeatured
            ? [BoxShadow(color: const Color(0xff006565).withOpacity(0.1), blurRadius: 16, offset: const Offset(0, 8))]
            : [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isFeatured) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: const Color(0xff006565), borderRadius: BorderRadius.circular(8)),
              child: const Text("MOST STRATEGIC CHOICE", style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
            ),
            const SizedBox(height: 8),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(title, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5)),
              ),
              Icon(Icons.workspace_premium, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(price, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1C1B1B))),
              if (oldPrice.isNotEmpty) ...[
                const SizedBox(width: 8),
                Text(
                  oldPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              ],
            ],
          ),
          Text(validity, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949), fontWeight: FontWeight.w600)),
          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 16),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Color(0xff006565), size: 16),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 12, color: Color(0xFF1C1B1B)))),
              ],
            ),
          )),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: color),
                foregroundColor: color,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                backgroundColor: isFeatured ? color.withOpacity(0.05) : Colors.transparent,
              ),
              onPressed: () {
                Navigator.pop(context);
                _openCheckoutSheet(plan);
              },
              child: Text(plan['is_purchased'] == 1 || plan['is_purchased'].toString() == '1' ? "Purchased" : "Select $title", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  Future<void> _fetchMyCommunities() async {

    try {
      final response = await Database().getData({
        'action': 'fetch_shared_invites_admin',
        'vendor_id': UserSessionSet.instance.vendorId,
      }, endpoint: 'new_apis/community_dashboard_api.php');

      if (response['success'] == true && response['data'] != null) {
        final List<dynamic> data = response['data'] ?? [];
        setState(() {
          _myCommunities = data;
          if (data.isNotEmpty) {
            _activeCommunityId = int.tryParse(data[0]['community_id']?.toString() ?? '');
            _activeCommunityTitle = data[0]['community_title']?.toString() ?? 'Community';
          }
        });
        if (_activeCommunityId != null) {
          _fetchCommunityStats(_activeCommunityId!);
          _fetchCommunityMembers(_activeCommunityId!);
        }
      }
    } catch (e) {
      print("Error fetching my communities: $e");
    }
  }

  Future<void> _fetchCommunityStats(int communityId) async {

    setState(() {
      _isLoadingStats = true;
    });
    try {
      final response = await Database().getData({
        'action': 'getCommunityStats',
        'community_id': communityId.toString(),
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/community_dashboard_api.php');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        setState(() {
          _totalMembers = int.tryParse(data['total_members']?.toString() ?? '0') ?? 0;
          _totalPaidMembers = int.tryParse(data['total_paid_members']?.toString() ?? '0') ?? 0;
          _totalRevenue = double.tryParse(data['total_revenue']?.toString() ?? '0.0') ?? 0.0;
        });
      }
    } catch (e) {
      print("Error fetching community stats: $e");
    } finally {
      setState(() {
        _isLoadingStats = false;
      });
    }
  }

  Future<void> _fetchCommunityMembers(int communityId) async {

    setState(() {
      _isLoadingApprovals = true;
    });
    try {
      final response = await Database().getData({
        'action': 'fetch_community_members',
        'community_id': communityId.toString(),
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/community_dashboard_api.php');

      if (response['success'] == true && response['data'] != null) {
        final data = response['data'];
        final List<dynamic> members = data['members'] ?? [];

        setState(() {
          _pendingApprovals = members.where((m) => m['join_status']?.toString() == 'pending').toList();
          _pendingApprovalsCount = _pendingApprovals.length;

          final approved = members.where((m) => m['join_status']?.toString() == 'approved').toList();
          for (var m in approved) {
            final details = m['vendor_details'] ?? {};
            final name = details['name']?.toString() ?? 'Unknown Member';
            final role = m['member_id'].toString() == '1' ? 'Admin' : 'Member';

          }
        });
      }
    } catch (e) {
      print("Error fetching community members: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingApprovals = false;
        });
      }
    }
  }

  Future<void> _updateMemberStatus(int memberId, String status) async {

    try {
      final response = await Database().getData({
        'action': 'update_member_status',
        'member_id': memberId.toString(),
        'vendor_id': UserSessionSet.instance.vendorId,

        'status': status,
      }, endpoint: 'new_apis/community_dashboard_api.php');

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Member status updated to $status successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        if (_activeCommunityId != null) {
          _fetchCommunityMembers(_activeCommunityId!);
          _fetchCommunityStats(_activeCommunityId!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message']?.toString() ?? "Failed to update member status"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      print("Error updating member status: $e");
    }
  }

  Future<void> _fetchHomeFeed() async {

    if (!mounted) return;
    setState(() {
      _isLoadingFeed = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_feed',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/social_feed_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _feedPosts = response['data'] ?? [];
        });
      }
    } catch (e) {
      print("Error fetching home feed: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFeed = false;
        });
      }
    }
  }

  Future<void> _toggleLike(int postId) async {

    try {
      final response = await Database().getData({
        'action': 'post_engagement',
        'post_id': postId.toString(),
        'engagement_type': 'like',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error toggling like: $e");
    }
  }

  Future<void> _addComment(int postId, String message) async {

    if (message.trim().isEmpty) return;
    try {
      final response = await Database().getData({
        'action': 'add_comment',
        'post_id': postId.toString(),
        'message': message,
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  Future<void> _sharePost(int postId) async {

    try {
      final response = await Database().getData({
        'action': 'post_engagement',
        'post_id': postId.toString(),
        'engagement_type': 'share',
        'vendor_id': UserSessionSet.instance.vendorId,

      }, endpoint: 'new_apis/social_app_api_v2_API.php');
      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post shared successfully!"),
              backgroundColor: Color(0xFF006565),
            ),
          );
        }
        _fetchHomeFeed();
      }
    } catch (e) {
      print("Error sharing post: $e");
    }
  }

  Future<bool> _showExitConfirmation() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Exit App',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          content: const Text(
            'Are you sure you want to exit the app?',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black54,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actionsPadding: EdgeInsets.zero,
          actions: [
            Divider(height: 1, color: Colors.grey.shade200),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.black54, fontSize: 16),
                    ),
                  ),
                ),
                Container(
                  width: 1,
                  height: 48,
                  color: Colors.grey.shade200,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        } else {
          return await _showExitConfirmation();
        }
      },
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: bgLight,
        floatingActionButton: _buildCommunityAdminFAB(),
        appBar: (_currentIndex == 0 || _currentIndex == 50)
            ? _buildSellerHeader()
            : AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
            onPressed: () {
              setState(() {
                _currentIndex = 0;
              });
            },
          ),
          centerTitle: true,
          title: Text(
            _getAppBarTitle(),
            style: const TextStyle(
              color: Color(0xFF006565),
              fontWeight: FontWeight.w600,
              fontSize: 19,
            ),
          ),
          actions: [
            if (_currentIndex == 27)
              IconButton(
                icon: const Icon(Icons.calendar_month_rounded, color: Color(0xFF006565)),
                tooltip: "Campaign Scheduler",
                onPressed: () => Navigator.pushNamed(context, AppRoutes.campaignScheduler),
              ),
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.notifications_outlined, color: Color(0xFF006565)),
                  onPressed: () => {},
                ),
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.person_outline, color: Color(0xFF006565)),
              onPressed: () {
                setState(() => _currentIndex = 11);
              },
            ),
          ],
        ),
        drawer: Drawer(
          backgroundColor: Colors.white,
          child: SafeArea(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundImage: NetworkImage(
                          "https://i.pravatar.cc/150",
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Elite Partner",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1C1B1B),
                              ),
                            ),
                            Row(
                              children: const [
                                Icon(
                                  Icons.verified,
                                  color: Color(0xFF006565),
                                  size: 16,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Verified B2B",
                                  style: TextStyle(
                                    color: Color(0xFF3E4949),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            const Text(
                              "Mumbai, India",
                              style: TextStyle(
                                color: Color(0xFF3E4949),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildDrawerItem(0, Icons.dashboard_rounded, "Community Dashboard"),
                      _buildDrawerItem(19, Icons.forum_rounded, "Manage Communities"),
                      _buildDrawerItem(51, Icons.explore_rounded, "Explore Communities"),
                      _buildDrawerItem(99, Icons.group_work, "Grow Communities"),
                      _buildDrawerItem(15, Icons.people_rounded, "Manage Members"),
                      _buildDrawerItem(20, Icons.post_add_rounded, "Manage Posts"),
                      _buildDrawerItem(10, Icons.monetization_on_rounded, "Community Monetization"),
                      _buildDrawerItem(52, Icons.card_membership_rounded, "Membership Plans"),
                      _buildDrawerItem(7, Icons.wallet_rounded, "Wallet"),
                      _buildDrawerItem(9, Icons.account_balance_rounded, "Bank Details"),
                      _buildDrawerItem(3, Icons.receipt_long_rounded, "Orders"),
                      _buildDrawerItem(27, Icons.campaign_rounded, "Schedule Campaigns"),
                      // _buildDrawerItem(6, Icons.settings_rounded, "Settings"),
                      Theme(
                        data: Theme.of(context).copyWith(
                          dividerColor: Colors.transparent,
                          listTileTheme: const ListTileThemeData(
                            horizontalTitleGap: 8,
                            dense: true,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(left: 8, right: 8, top: 4, bottom: 4),
                          child: ExpansionTile(
                            shape: const Border(),
                            collapsedShape: const Border(),
                            tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                            leading: const Icon(Icons.settings_rounded, color: textLight, size: 24),
                            title: const Text("General Settings", style: TextStyle(fontSize: 14, color: textDark)),
                            children: [
                              _buildDrawerItem(100, Icons.settings_rounded, "Interest  Preferences", isSubItem: true),
                              _buildDrawerItem(101, Icons.settings_accessibility, "Industry pretences", isSubItem: true),
                              _buildDrawerItem(102, Icons.settings_bluetooth_sharp, "Platform Setting", isSubItem: true),

                            ],
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color(0xFFBA1A1A),
                  ),
                  title: const Text(
                    "Sign Out",
                    style: TextStyle(color: Color(0xFFBA1A1A)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // AccountActions.showLogoutSheet(context);
                    showLogoutConfirmationDialog(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
              return Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  ...previousChildren,
                  if (currentChild != null) currentChild,
                ],
              );
            },
            child: _buildBodyContent(),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _getBottomNavBarIndex(),
          onTap: (index) {
            _setTabFromBottomNav(index);
          },
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: primaryPurple,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: "Dashboard"),
            BottomNavigationBarItem(icon: Icon(Icons.people_rounded), label: "Members"),
            BottomNavigationBarItem(icon: Icon(Icons.card_membership_rounded), label: "Packages"),
            BottomNavigationBarItem(icon: Icon(Icons.forum_rounded), label: "Communities"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
          ],
        ),
      ),
    );
  }

  int _getBottomNavBarIndex() {
    if (_currentIndex == 0) return 0;
    if (_currentIndex == 15) return 1;
    if (_currentIndex == 10) return 2;
    if (_currentIndex == 19) return 3;
    if (_currentIndex == 11) return 4;
    return 0;
  }

  void _setTabFromBottomNav(int bottomIndex) {
    setState(() {
      switch (bottomIndex) {
        case 0:
          _currentIndex = 0;
          break;
        case 1:
          _currentIndex = 15;
          break;
        case 2:
          _currentIndex = 10;
          break;
        case 3:
          _currentIndex = 19;
          break;
        case 4:
          _currentIndex = 11;
          break;
      }
    });
  }

  Widget _buildDrawerItem(int index, IconData icon, String title, {bool isSubItem = false}) {
    final bool isSelected = _currentIndex == index;
    return Container(
      margin: EdgeInsets.only(left: isSubItem ? 16 : 8, right: 8, top: 4, bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? primaryPurple : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isSelected
            ? [
          BoxShadow(
            color: primaryPurple.withAlpha(60),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ]
            : null,
      ),
      child: ListTile(
        dense: true,
        visualDensity: VisualDensity.compact,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        horizontalTitleGap: 8,
        leading: Icon(icon, color: isSelected ? Colors.white : const Color(0xFF3E4949), size: isSubItem ? 20 : 24),
        title: Text(
          title,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1C1B1B),
            fontSize: isSubItem ? 13 : 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          setState(() => _currentIndex = index);
        },
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentIndex) {
      case 0:
      case 50:
        return "Community Intelligence";
      case 19:
        return "Manage Communities";
      case 51:
        return "Explore Communities";
      case 15:
        return "Manage Members";
      case 20:
        return "Manage Posts";
      case 10:
        return "Community Monetization";
      case 52:
        return "Membership Plans";
      case 7:
        return "Wallet";
      case 9:
        return "Bank Details";
      case 11:
        return "Profile";
      case 3:
        return "Orders";
      case 27:
        return "Schedule Campaigns";
      case 6:
        return "Settings";
      case 102:
        return"Platform Setting";
      default:
        return "Serene Commerce";
    }
  }

  Widget _buildBodyContent() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardView();
      case 50:
        return _buildHomeFeedView();
      case 51:
        return const ExploreCommunitiesScreen(isEmbedded: true,);
      case 52:
        return const MembershipPlansScreen(isEmbedded: true);
      case 11:
        return const ProfileScreen();
      case 3:
        return const PromotionalPackageOrdersScreen(isEmbedded: true);
      case 7:
        return const WalletAdminScreen(isEmbedded: true);
      case 10:
        return const ManagePromotionalPackagesScreen(isEmbedded: true);
      case 15:
        return _buildCommunityApprovalsView();
      case 27:
        return const ScheduleCampaignScreen(isEmbedded: true);
      case 99:
        return const GrowCommunityApp();
      case 100:
        return const PersonalizeFeedDialog();
      case 101:
        return const PersonalizeIndustryDialog();
      case 102:
        return const PlatformSettingsScreen(isEmbedded: true,);
      default:
        return _buildDashboardView();
    }
  }

  PreferredSizeWidget _buildSellerHeader() {
    return AppBar(
      backgroundColor: Colors.teal,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => Scaffold.of(context).openDrawer(),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          constraints: const BoxConstraints(minWidth: 40),
        ),
      ),
      leadingWidth: 40,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              "Community Dashboard",
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 40,
              height: 55,
              child: IconButton(
                icon: const Icon(Icons.party_mode, color: Colors.white, size: 22),
                onPressed: () {
                  setState(() {
                    _currentIndex = 50;
                  });
                },
                tooltip: "Home Feed",
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 40,
              height: 55,
              child: IconButton(
                icon: const Icon(Icons.chat, color: Colors.white, size: 22),
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).push(
                    MaterialPageRoute(
                      builder: (context) => const ChatListScreen(),
                    ),
                  );
                },
                tooltip: "Chat Messages",
                padding: EdgeInsets.zero,
              ),
            ),
            SizedBox(
              width: 40,
              height: 50,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationsScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                  Positioned(
                    right: 7,
                    top: 7,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ],
      titleSpacing: 0,
    );
  }

  Widget _buildDashboardView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_myCommunities.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _activeCommunityId,
                  items: _myCommunities.map((c) {
                    return DropdownMenuItem<int>(
                      value: int.tryParse(c['community_id']?.toString() ?? ''),
                      child: Text(
                        c['community_title']?.toString() ?? 'Community',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: primaryPurple),
                      ),
                    );
                  }).toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() {
                        _activeCommunityId = val;
                        final selected = _myCommunities.firstWhere((c) => int.tryParse(c['community_id']?.toString() ?? '') == val);
                        _activeCommunityTitle = selected['community_title']?.toString() ?? 'Community';
                      });
                      _fetchCommunityStats(val);
                      _fetchCommunityMembers(val);
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          const Text(
            "CORE PERFORMANCE",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDossierStatCard("Total Members", _totalMembers.toString(), trend: "", hasAccent: true),
                const SizedBox(width: 12),
                _buildDossierActiveCard("Paid Members", _totalPaidMembers.toString(), progress: 1.0),
                const SizedBox(width: 12),
                _buildDossierTextCard("Pending", _pendingApprovalsCount.toString(), "Review required", valColor: const Color(0xFFB45309)),
                const SizedBox(width: 12),
                _buildDossierTextCard("Net Revenue", "₹${_totalRevenue.toStringAsFixed(1)}", "Lifetime Earnings", valColor: const Color(0xFF1C1B1B)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildDossierCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Global Visitor Map",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1C1C),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.more_vert, color: Color(0xFF3E4949)),
                        onPressed: () {},
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEEEED),
                          borderRadius: const BorderRadius.vertical(bottom: Radius.circular(4)),
                          image: const DecorationImage(
                            image: NetworkImage(
                              "https://lh3.googleusercontent.com/aida-public/AB6AXuBKyWKzKAApID2AoWsIhWnAdfXvmMVtpWXIcqleHqvNo5cVgsYfMKwaR8OjzmTSQh-A_-umlsOzY6ZFOdKfVwlzfZ4_nLk6p4mE-cUL1rBMU8l0V9jBMVcB0P8K8OD4HHvn2LNkkfg28qMK2tDSlMwHOZc3DUNqzqkVsva3Oa1SByDJysgb8IDUP-YT-ro7Z_ZEGfwzhJMfESS19CE_F8qyj7CaxU8JFUC8VCT4pZlUed0CU6JY_Kxh",
                            ),
                            fit: BoxFit.cover,
                            opacity: 0.6,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 40,
                      left: 80,
                      child: _buildMapPulseMarker(),
                    ),
                    Positioned(
                      top: 100,
                      left: 180,
                      child: _buildMapPulseMarker(size: 14),
                    ),
                    Positioned(
                      top: 60,
                      right: 90,
                      child: _buildMapPulseMarker(size: 8),
                    ),
                    Positioned(
                      bottom: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                        ),
                        child: const Text(
                          "Real-time Activity: 1,204 nodes",
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "ANALYTICAL INSIGHTS",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                const SizedBox(width: 12),
                _buildSalesTrendChartCard(),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "New Member Approvals",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildMemberApprovalCard(
                  name: "Jordan Smith",
                  role: "Senior Architect",
                  avatarUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuBU6C9nJEUf6OeahCGdO0Dq54LFMAAkDfJyyTT5HnNdMFh1U5Tk5gEw5x5Ybn9hjaWDQcVfz1GHfGI7OD_EyBLaN-5IDaVI5ERFYP6clT6jyYUcjQAPX3E5cRTW5nPlzVb2nq8RXOc7Lm6n7izg_ataQFkHt-B2Uti1tJPSkPXOFTDDTnqXG_UHVlxKgtm5xQ0LeT6phH-NhxUAORGrTxFlwtm9ROcnvYTdB7Y9O6uLgp4fQP0Z1xeN",
                ),
                const SizedBox(width: 12),
                _buildMemberApprovalCard(
                  name: "Sarah Chen",
                  role: "Product Lead",
                  avatarUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuAJTrFHxrrETppbTZT7wfYief4z063tC9ynwUDfY0Zauhsm4wzu-QMoLFzssELj8jhQ3elurvFmovcp4WBvUcXFJ7Y9Holeb1zEbvI3rRg_HNJWs11jfqFO9hV6StzNUXjwAP-2olmk8iCp8D33m5WkLjR_osII-lgrvrlGu2xvlPMGmhEgXjW_4oum1mc40hjY8ah6M2V3QstbrVI4AnrPRq_PlQvfJoM6y302jZ8A_Tc42w1nnvKP",
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "New Post Approvals",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          _buildPostApprovalItem("Tech Strategy for Q4", "Mike Donnovan", Icons.article_outlined),
          const SizedBox(height: 8),
          _buildPostApprovalItem("Upcoming Meetup FAQ", "Elena Rodriguez", Icons.forum_outlined),
          const SizedBox(height: 28),
          const Text(
            "Promotional Package Orders",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 240,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildPromoOrderCard(
                  title: "Premium Growth Pk",
                  orderId: "#782-901",
                  price: r"₹499.00",
                  client: "Alex Rivera",
                  company: "TechFlow Inc.",
                  isPaid: true,
                  accentColor: const Color(0xFF6750A4),
                ),
                const SizedBox(width: 12),
                _buildPromoOrderCard(
                  title: "Basic Engagement",
                  orderId: "#782-895",
                  price: r"₹199.00",
                  client: "Jamie Lee",
                  company: "Creative Co.",
                  isPaid: false,
                  accentColor: const Color(0xFF008080),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            "Articles & Blogs",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 290,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildArticleBlogCard(
                  title: "Scaling Engagement in 202",
                  category: "Community Strategy",
                  authorName: "Sarah Chen",
                  views: "1.2k",
                  likes: "84",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuALNKH8mgdlWgYCTWEeiKzMNRwdndqhgbL_Auuzpkopuk7kKzF53vbfi2ELgFOaXZbIC5OWlPAs0olk5ciM9YAOvVUmcyIhBP1HYFyuyvcUXJbz-8lqE_VE-Upt9vvoI3C_FXXmkmTmxegAW1Ugnab6Ywo6DuZ9GiWXRE_VjxJhFlAKtppocXK3v8uoy6Kl5j-s9yeVaAkSf6KwnB9eOGhixAWX3vw54s0ZA-hbThs9PwFyxnSOoY8N",
                  authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuAJTrFHxrrETppbTZT7wfYief4z063tC9ynwUDfY0Zauhsm4wzu-QMoLFzssELj8jhQ3elurvFmovcp4WBvUcXFJ7Y9Holeb1zEbvI3rRg_HNJWs11jfqFO9hV6StzNUXjwAP-2olmk8iCp8D33m5WkLjR_osII-lgrvrlGu2xvlPMGmhEgXjW_4oum1mc40hjY8ah6M2V3QstbrVI4AnrPRq_PlQvfJoM6y302jZ8A_Tc42w1nnvKP",
                ),
                const SizedBox(width: 12),
                _buildArticleBlogCard(
                  title: "The Rise of Niche Networks",
                  category: "Market Insights",
                  authorName: "Jordan Smith",
                  views: "850",
                  likes: "42",
                  imageUrl: "https://lh3.googleusercontent.com/aida-public/AB6AXuDXGJfZscVmWLX6TJlMlsUcZBvaI-tI25XIIQVdfr-qy83rMuZAXK1WcMdfBZHNVq6hTTXdRFCGVxgZ3VJKsf2B15ZBY5YlaRDbyvZEB_E6KZYJccMf5z0yQMkjlwNsLv7MJJmicBBI4qJ4l9_tuGcy-H3M3amP6LjhEH-kDBT0WVYYb4NK1hjSTLWOrVF-MW23wCepUzXlw3nA6PiY__e5GGpkQbkhz1kLYhE0Of_zdmj4pU3P6U9x",
                  authorAvatar: "https://lh3.googleusercontent.com/aida-public/AB6AXuBU6C9nJEUf6OeahCGdO0Dq54LFMAAkDfJyyTT5HnNdMFh1U5Tk5gEw5x5Ybn9hjaWDQcVfz1GHfGI7OD_EyBLaN-5IDaVI5ERFYP6clT6jyYUcjQAPX3E5cRTW5nPlzVb2nq8RXOc7Lm6n7izg_ataQFkHt-B2Uti1tJPSkPXOFTDDTnqXG_UHVlxKgtm5xQ0LeT6phH-NhxUAORGrTxFlwtm9ROcnvYTdB7Y9O6uLgp4fQP0Z1xeN",
                  isGrowing: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDossierCard({
    required Widget child,
    bool hasAccent = false,
    Color accentColor = const Color(0xFF008080),
    EdgeInsetsGeometry padding = const EdgeInsets.all(16),
  }) {
    final EdgeInsetsGeometry childPadding = hasAccent
        ? padding.add(const EdgeInsets.only(left: 4))
        : padding;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFFBDC9C8)),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Padding(
            padding: childPadding,
            child: child,
          ),
          if (hasAccent)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 4,
              child: Container(
                color: accentColor,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDossierStatCard(String label, String value, {required String trend, bool hasAccent = false}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        hasAccent: hasAccent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(Icons.trending_up, size: 12, color: Color(0xFF15803D)),
                const SizedBox(width: 2),
                Text(
                  trend,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF15803D)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierActiveCard(String label, String value, {required double progress}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: const Color(0xFFEEEEED),
                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF008080)),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDossierTextCard(String label, String value, String description, {Color valColor = const Color(0xFF1A1C1C)}) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Color(0xFF3E4949)),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: valColor),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPulseMarker({double size = 10.0}) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF006565),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF008080).withOpacity(0.6),
            blurRadius: size,
            spreadRadius: size / 2,
          ),
        ],
      ),
    );
  }

  Widget _buildSalesTrendChartCard() {
    return Container(
      width: 320,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Sales Trend (30d)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C)),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 70,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: _buildTrendBar(0.5)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.67)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.5)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.75)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(1.0, isHighlight: true)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.67)),
                  const SizedBox(width: 6),
                  Expanded(child: _buildTrendBar(0.8)),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text("Day 01", style: TextStyle(fontSize: 8, color: Color(0xFF3E4949))),
                Text("Day 30", style: TextStyle(fontSize: 8, color: Color(0xFF3E4949))),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendBar(double fraction, {bool isHighlight = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlight ? const Color(0xFF006565) : const Color(0xFF006565).withOpacity(0.15),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
      height: 70 * fraction,
    );
  }

  Widget _buildMemberApprovalCard({required String name, required String role, required String avatarUrl}) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFBDC9C8)),
                image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 8),
            Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F3F3),
                      foregroundColor: const Color(0xFF1A1C1C),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Contact User: Hello $name, we've reviewed your request..."),
                    child: const Text("Contact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF4F3F3),
                      foregroundColor: const Color(0xFF1A1C1C),
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Rejected $name membership"),
                    child: const Text("Reject", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: EdgeInsets.zero,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                    ),
                    onPressed: () => _showActionAlert("Approved $name membership successfully!"),
                    child: const Text("Approve", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostApprovalItem(String title, String author, IconData icon) {
    return _buildDossierCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: const Color(0xFF006565)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text("by $author", style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
              ],
            ),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red),
                onPressed: () => _showActionAlert("Post rejected"),
              ),
              IconButton(
                icon: const Icon(Icons.check, color: Color(0xFF006565)),
                onPressed: () => _showActionAlert("Post approved successfully!"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPromoOrderCard({
    required String title,
    required String orderId,
    required String price,
    required String client,
    required String company,
    required bool isPaid,
    required Color accentColor,
  }) {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        hasAccent: true,
        accentColor: accentColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isPaid ? "PREMIUM ORDER" : "STANDARD ORDER",
                  style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: accentColor),
                ),
                Text(
                  price,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text("Order ID: $orderId", style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
            const SizedBox(height: 8),
            Container(
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFFBDC9C8))),
              ),
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Client: $client", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  Text("Company: $company", style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPaid ? "Paid" : "Pending",
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isPaid ? const Color(0xFF15803D) : const Color(0xFFB45309),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF006565)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showActionAlert("Order summary: $title for $client. Total: $price"),
                    child: const Text("View Details", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF006565))),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                    ),
                    onPressed: () => _showActionAlert("Reviewing order $orderId"),
                    child: const Text("Review", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleBlogCard({
    required String title,
    required String category,
    required String authorName,
    required String views,
    required String likes,
    required String imageUrl,
    required String authorAvatar,
    bool isGrowing = false,
  }) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(bottom: 4),
      child: _buildDossierCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEED),
                    image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isGrowing ? const Color(0xFF6750A4) : const Color(0xFF006565),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      category.toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 10,
                        backgroundImage: NetworkImage(authorAvatar),
                      ),
                      const SizedBox(width: 6),
                      Text(authorName, style: const TextStyle(fontSize: 11, color: Color(0xFF3E4949))),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.visibility_outlined, size: 12, color: Color(0xFF3E4949)),
                          const SizedBox(width: 2),
                          Text(views, style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949))),
                          const SizedBox(width: 8),
                          const Icon(Icons.favorite_border, size: 12, color: Color(0xFF3E4949)),
                          const SizedBox(width: 2),
                          Text(likes, style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949))),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFFBDC9C8)),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {},
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.share_outlined, size: 12, color: Color(0xFF1A1C1C)),
                              SizedBox(width: 4),
                              Text("Share", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF1A1C1C))),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF006565),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            padding: EdgeInsets.zero,
                          ),
                          onPressed: () {},
                          child: const Text("Read More", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActionAlert(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF006565),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget? _buildCommunityAdminFAB() {
    if (_currentIndex == 0 || _currentIndex == 50) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CreatePostDialog(
              onPostCreated: () {
                _fetchHomeFeed();
              },
            ),
          );
        },
        child: const Icon(Icons.add),
      );
    } else if (_currentIndex == 19) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () => Navigator.pushNamed(context, AppRoutes.createCommunity),
        child: const Icon(Icons.group_add_rounded),
      );
    } else if (_currentIndex == 15) {
      return FloatingActionButton.extended(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () => _showActionAlert("Sent member invite successfully!"),
        icon: const Icon(Icons.person_add_rounded),
        label: const Text("Invite Member"),
      );
    } else if (_currentIndex == 20) {
      return FloatingActionButton.small(
        backgroundColor: primaryPurple,
        foregroundColor: Colors.white,
        onPressed: () {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => CreatePostDialog(
              onPostCreated: () {
                _fetchHomeFeed();
              },
            ),
          );
        },
        child: const Icon(Icons.post_add_rounded),
      );
    }
    return null;
  }

  Widget _buildPendingCard({
    required String name,
    required String role,
    required String avatarUrl,
    required int memberId,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(color: const Color(0xFF006565)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFBDC9C8)),
                        image: DecorationImage(image: NetworkImage(avatarUrl), fit: BoxFit.cover),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1C1B1B))),
                          Text(role, style: const TextStyle(fontSize: 12, color: Color(0xFF3E4949))),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F3F3),
                          foregroundColor: const Color(0xFF1C1B1B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _showActionAlert("Inquiry dossier sent to $name"),
                        child: const Text(
                          "Contact",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF4F3F3),
                          foregroundColor: const Color(0xFF1C1B1B),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateMemberStatus(memberId, 'rejected'),
                        child: const Text(
                          "Reject",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => _updateMemberStatus(memberId, 'approved'),
                        child: const Text(
                          "Approve",
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunityApprovalsView() {
    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    final Widget pendingSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Pending Approval",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1C),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF006565).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                "${_pendingApprovals.length} Pending",
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006565),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_pendingApprovals.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Text("No pending approval requests.", style: TextStyle(color: textLight)),
          )
        else
          ..._pendingApprovals.map((item) {
            final details = item['vendor_details'] ?? {};
            final name = details['name']?.toString() ?? 'No Name';
            final designation = details['designation']?.toString() ?? 'Applicant';
            final avatar = details['profile_pic']?.toString() ?? "https://i.pravatar.cc/150";
            final memberId = int.tryParse(item['member_id']?.toString() ?? '0') ?? 0;
            return _buildPendingCard(
              name: name,
              role: designation,
              avatarUrl: avatar.startsWith('http') ? avatar : "https://i.pravatar.cc/150",
              memberId: memberId,
            );
          }).toList(),
      ],
    );

    final String query = _memberSearchController.text.toLowerCase();
    // final List<Map<String, dynamic>> filteredMembers = _activeMembers.where((m) {
    //   final String name = m["name"].toString().toLowerCase();
    //   final String role = m["role"].toString().toLowerCase();
    //   return name.contains(query) || role.contains(query);
    // }).toList();

    final Widget activeMembersSection = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Active Members",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1C1C),
              ),
            ),
            SizedBox(
              width: 180,
              height: 36,
              child: TextField(
                controller: _memberSearchController,
                onChanged: (val) => setState(() {}),
                style: const TextStyle(fontSize: 12),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 16, color: Color(0xFF3E4949)),
                  hintText: "Filter members...",
                  hintStyle: const TextStyle(fontSize: 11, color: Color(0xFF757575)),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                  filled: true,
                  fillColor: const Color(0xFFF4F3F3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: Color(0xFF006565)),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(
            width: isDesktop ? 900 : 550,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBDC9C8)),
              ),
              child: Column(
                children: [
                  Container(
                    color: const Color(0xFFF4F3F3),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                    child: Row(
                      children: const [
                        Expanded(
                          flex: 4,
                          child: Text("MEMBER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text("STATUS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text("ENGAGEMENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                        ),
                        Expanded(
                          flex: 2,
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Text("ACTIONS", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949), letterSpacing: 0.5)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: Color(0xFFBDC9C8)),
                  // if (filteredMembers.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(32),
                      child: const Center(
                        child: Text("No members match filter query", style: TextStyle(color: Color(0xFF757575), fontSize: 13)),
                      ),
                    )

                    // ...filteredMembers.map((m) {
                    //   return Column(
                    //     children: [
                    //       Padding(
                    //         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    //         child: Row(
                    //           children: [
                    //             Expanded(
                    //               flex: 4,
                    //               child: Row(
                    //                 children: [
                    //                   Container(
                    //                     width: 32,
                    //                     height: 32,
                    //                     decoration: BoxDecoration(
                    //                       color: const Color(0xFFF4F3F3),
                    //                       borderRadius: BorderRadius.circular(6),
                    //                       border: Border.all(color: const Color(0xFFBDC9C8)),
                    //                     ),
                    //                     child: Center(
                    //                       child: Text(
                    //                         m["initials"],
                    //                         style: TextStyle(
                    //                           fontWeight: FontWeight.bold,
                    //                           fontSize: 11,
                    //                           color: m["statusColor"],
                    //                         ),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                   const SizedBox(width: 8),
                    //                   Expanded(
                    //                     child: Column(
                    //                       crossAxisAlignment: CrossAxisAlignment.start,
                    //                       children: [
                    //                         Text(m["name"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF1C1B1B)), overflow: TextOverflow.ellipsis),
                    //                         Text(m["role"], style: const TextStyle(fontSize: 10, color: Color(0xFF3E4949)), overflow: TextOverflow.ellipsis),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //             Expanded(
                    //               flex: 2,
                    //               child: Align(
                    //                 alignment: Alignment.centerLeft,
                    //                 child: Container(
                    //                   padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    //                   decoration: BoxDecoration(
                    //                     color: (m["statusColor"] as Color).withOpacity(0.1),
                    //                     borderRadius: BorderRadius.circular(4),
                    //                   ),
                    //                   child: Text(
                    //                     m["status"],
                    //                     style: TextStyle(
                    //                       fontSize: 8,
                    //                       fontWeight: FontWeight.bold,
                    //                       color: m["statusColor"],
                    //                     ),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               flex: 3,
                    //               child: Align(
                    //                 alignment: Alignment.centerLeft,
                    //                 child: ClipRRect(
                    //                   borderRadius: BorderRadius.circular(4),
                    //                   child: LinearProgressIndicator(
                    //                     value: m["progress"],
                    //                     minHeight: 6,
                    //                     backgroundColor: const Color(0xFFF4F3F3),
                    //                     valueColor: AlwaysStoppedAnimation<Color>(m["statusColor"]),
                    //                   ),
                    //                 ),
                    //               ),
                    //             ),
                    //             Expanded(
                    //               flex: 2,
                    //               child: Row(
                    //                 mainAxisAlignment: MainAxisAlignment.end,
                    //                 children: [
                    //                   IconButton(
                    //                     icon: const Icon(Icons.mail_outline_rounded, size: 16, color: Color(0xFF006565)),
                    //                     onPressed: () => _showActionAlert("Opened mail box for ${m['name']}"),
                    //                     padding: EdgeInsets.zero,
                    //                     constraints: const BoxConstraints(),
                    //                   ),
                    //                   const SizedBox(width: 6),
                    //                   GestureDetector(
                    //                     onTap: () => _showActionAlert("Details page for ${m['name']}"),
                    //                     child: const Text(
                    //                       "VIEW",
                    //                       style: TextStyle(
                    //                         fontSize: 9,
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Color(0xFF006565),
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //       const Divider(height: 1, color: Color(0xFFBDC9C8)),
                    //     ],
                    //   );
                    // }).toList(),
                ],
              ),
            ),
          ),
        ),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Admin Profile Hub",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1C1C),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            "Strategic oversight and dossier management for your community network.",
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF3E4949),
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 110,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildDossierTextCard("TOTAL MEMBERS", "12,482", "4% up", valColor: const Color(0xFF1C1B1B)),
                const SizedBox(width: 12),
                _buildDossierTextCard("NEW REQUESTS", "48", "URGENT", valColor: const Color(0xFFB45309)),
                const SizedBox(width: 12),
                _buildDossierTextCard("ACTIVE TODAY", "3,891", "12% up", valColor: const Color(0xFF008080)),
                const SizedBox(width: 12),
                _buildDossierTextCard("MONTHLY GROWTH", "+842", "Growing", valColor: const Color(0xFF6750A4)),
              ],
            ),
          ),
          const SizedBox(height: 28),
          if (isDesktop)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 4,
                  child: pendingSection,
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 8,
                  child: activeMembersSection,
                ),
              ],
            )
          else ...[
            pendingSection,
            const SizedBox(height: 28),
            activeMembersSection,
          ],
        ],
      ),
    );
  }

  Widget _buildHomeFeedView() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _currentIndex == 50) {
        _checkAndShowPersonalizeFeedModal();
      }
    });

    final bool isDesktop = MediaQuery.of(context).size.width >= 768;

    final Widget mainFeed = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildPersonalizeFeedBanner(),
        const SizedBox(height: 10),
        if (_isLoadingFeed)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(40.0),
              child: CircularProgressIndicator(color: primaryPurple),
            ),
          )
        else if (_feedPosts.isEmpty)
          Center(
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 20),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: const Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  "No updates on your feed yet. Start by writing a post!",
                  style: TextStyle(color: textLight, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          )
        else
          ..._feedPosts.map((post) => _buildDynamicPostCard(post)).toList(),
      ],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1200),
          child: isDesktop
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildPinnedReportsCard(),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                flex: 9,
                child: mainFeed,
              ),
            ],
          )
              : mainFeed,
        ),
      ),
    );
  }

  Widget _buildPersonalizeFeedBanner() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF006565), Color(0xFF008080)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.tune_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Personalize Your Feed",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Choose interests to tailor your business matches and content.",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF006565),
                elevation: 0,
                minimumSize: const Size(0, 0),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const PersonalizeFeedDialog(),
                );
              },
              child: const Text(
                "Personalize",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedReportsCard() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pinned Reports",
              style: TextStyle(
                fontFamily: "Manrope",
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
              ),
            ),
            const SizedBox(height: 12),
            _buildPinnedReportItem("Q3 Market Sentiment"),
            const SizedBox(height: 8),
            _buildPinnedReportItem("Governance Updates"),
          ],
        ),
      ),
    );
  }

  Widget _buildPinnedReportItem(String title) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            const Icon(Icons.description_outlined, size: 16, color: Color(0xFF006565)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3E4949),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDynamicPostCard(dynamic post) {
    final int postId = int.tryParse(post['id']?.toString() ?? '0') ?? 0;
    final String authorName = post['author_name']?.toString() ?? 'Anonymous User';
    final String authorAvatar = post['author_avatar']?.toString() ?? '';
    final String postText = post['label']?.toString() ?? '';
    final String postImage = post['image_url']?.toString() ?? '';
    final String? youtubeId = _extractYoutubeId(postText);
    final String? twitterUrl = youtubeId == null ? _extractTwitterVideoUrl(postText) : null;
    final String createdDate = post['created_date']?.toString().split(' ').first ?? 'Just now';
    final int likesCount = int.tryParse(post['likes_count']?.toString() ?? '0') ?? 0;
    final bool isLiked = int.tryParse(post['is_liked']?.toString() ?? '0') == 1;
    final List<dynamic> comments = post['comments_list'] ?? [];
    final bool commentsExpanded = _expandedPostComments.contains(postId);

    if (!_commentControllers.containsKey(postId)) {
      _commentControllers[postId] = TextEditingController();
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 24),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFBDC9C8)),
      ),
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: bgLight,
                  backgroundImage: authorAvatar.isNotEmpty ? NetworkImage(authorAvatar) : null,
                  radius: 24,
                  child: authorAvatar.isEmpty
                      ? Text(authorName.isNotEmpty ? authorName[0].toUpperCase() : "?",
                      style: const TextStyle(color: primaryPurple, fontWeight: FontWeight.bold))
                      : null,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontFamily: "Manrope",
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    Text(
                      createdDate.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF3E4949),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (postText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                postText,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1C1B1B),
                  height: 1.4,
                ),
              ),
            ),
          if (youtubeId != null)
            _buildYoutubePreview(youtubeId),
          if (twitterUrl != null)
            _buildTwitterPreview(twitterUrl),
          if (postImage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Image.network(
                postImage,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: const BoxDecoration(
              color: Color(0xFFF4F3F3),
              border: Border(
                top: BorderSide(color: Color(0xFFBDC9C8)),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => _toggleLike(postId),
                      child: Row(
                        children: [
                          Icon(
                            isLiked ? Icons.thumb_up_rounded : Icons.thumb_up_outlined,
                            size: 18,
                            color: isLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "$likesCount",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isLiked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () {
                        setState(() {
                          if (commentsExpanded) {
                            _expandedPostComments.remove(postId);
                          } else {
                            _expandedPostComments.add(postId);
                          }
                        });
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 18,
                            color: Color(0xFF3E4949),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${comments.length}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    InkWell(
                      onTap: () => _sharePost(postId),
                      child: Row(
                        children: const [
                          Icon(
                            Icons.share_outlined,
                            size: 18,
                            color: Color(0xFF3E4949),
                          ),
                          SizedBox(width: 4),
                          Text(
                            "Share",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (commentsExpanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFF9F9F9),
                border: Border(
                  top: BorderSide(color: Color(0xFFBDC9C8)),
                ),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (comments.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: comments.length,
                      itemBuilder: (context, index) {
                        final comment = comments[index];
                        final String cUser = comment['user_name']?.toString() ?? 'Anonymous';
                        final String cAvatar = comment['user_avatar']?.toString() ?? '';
                        final String cText = comment['message']?.toString() ?? '';
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: bgLight,
                                backgroundImage: cAvatar.isNotEmpty ? NetworkImage(cAvatar) : null,
                                radius: 16,
                                child: cAvatar.isEmpty
                                    ? Text(cUser.isNotEmpty ? cUser[0].toUpperCase() : "?",
                                    style: const TextStyle(color: primaryPurple, fontSize: 10, fontWeight: FontWeight.bold))
                                    : null,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF4F3F3),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        cUser,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        cText,
                                        style: const TextStyle(fontSize: 13, color: Color(0xFF1C1B1B)),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentControllers[postId],
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: "Write a comment...",
                            hintStyle: const TextStyle(fontSize: 12),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          minimumSize: const Size(0, 0),
                        ),
                        onPressed: () {
                          final msg = _commentControllers[postId]!.text;
                          _addComment(postId, msg);
                          _commentControllers[postId]!.clear();
                        },
                        child: const Text("Post", style: TextStyle(fontSize: 12)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}