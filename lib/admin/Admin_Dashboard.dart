import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../Database/Database.dart';
import '../services/auth_User_and_Business_Session.dart';

/// Wraps every `action` handled by the admin-dashboard PHP endpoint.
///
/// IMPORTANT: this PHP file lives at a different path than your other
/// endpoints (dashboard.php / seekers.php). `Database.getData` routes by
/// `endpoint` (`$baseUrl?endpoint=...`). Replace `_endpoint` below with
/// whatever value your server-side router expects for this file — I don't
/// have that mapping, so this is a placeholder.
class AdminDashboardService {
  static const String _endpoint = 'new_apis/admin_dashboard_api.php';

  final Database _db = Database();

  Future<Map> _call(Map body) => _db.getData(body, endpoint: _endpoint);

  // ------------------------------------------------------------------
  // Membership
  // ------------------------------------------------------------------
  Future<Map?> getCurrentMembership() async {
    final res = await _call({'action': 'get_current_membership','vendor_id': UserSessionSet.instance.vendorId,
    });
    if (res['success'] != true) return null;
    return res['data'] is Map ? Map.from(res['data']) : null;
  }

  // ------------------------------------------------------------------
  // Space utilization — maps 1:1 onto the "Space Utilization" card
  // ------------------------------------------------------------------
  Future<SpaceUtilization?> getSpaceUtilization() async {
    final res = await _call({'action': 'get_space_utilization','vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true || res['data'] is! Map) return null;
    return SpaceUtilization.fromMap(Map.from(res['data']));
  }

  // ------------------------------------------------------------------
  // Visitor tracking — NOTE: this is total visits per day, site-wide.
  // There is no per-region breakdown in the schema, unlike the mock UI.
  // ------------------------------------------------------------------
  Future<List<VisitDay>> getVisitorTracking({int days = 30, String? vendorId}) async {
    final body = {'action': 'get_visitor_tracking', 'days': days,'vendor_id': UserSessionSet.instance.vendorId,};
    if (vendorId != null) body['vendor_id'] = vendorId;
    final res = await _call(body);
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => VisitDay.fromMap(Map.from(e))).toList();
  }

  // ------------------------------------------------------------------
  // Listing distribution — top 5 listings per marketplace the vendor
  // can sell in. Not a percentage split; there's no "products vs
  // services" ratio available from this endpoint.
  // ------------------------------------------------------------------
  Future<List<MarketplaceListings>> getListingDistribution() async {
    final res = await _call({'action': 'get_listing_distribution','vendor_id': UserSessionSet.instance.vendorId,
    });
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => MarketplaceListings.fromMap(Map.from(e))).toList();
  }

  // ------------------------------------------------------------------
  // Revenue stats — feeds the sparkline directly
  // ------------------------------------------------------------------
  Future<List<RevenuePoint>> getRevenueStats({String range = 'day'}) async {
    final res = await _call({'action': 'get_revenue_stats', 'range': range,'vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => RevenuePoint.fromMap(Map.from(e))).toList();
  }

  // ------------------------------------------------------------------
  // Pending withdrawals (payouts)
  // ------------------------------------------------------------------
  Future<List<Withdrawal>> getPendingWithdrawals() async {
    final res = await _call({'action': 'get_pending_withdrawals','vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => Withdrawal(Map.from(e))).toList();
  }

  /// `status` meaning isn't defined server-side beyond 0 = pending.
  /// Assuming 1 = approved, 2 = disapproved — confirm against your schema.
  Future<bool> updateWithdrawalStatus({required int withdrawId, required int status}) async {
    final res = await _call({
      'action': 'update_withdrawal_status','vendor_id': UserSessionSet.instance.vendorId,
      'withdraw_id': withdrawId,
      'status': status,
    });
    return res['success'] == true;
  }

  // ------------------------------------------------------------------
  // Recent orders
  // ------------------------------------------------------------------
  Future<List<OrderRecord>> getRecentOrders({int limit = 10}) async {
    final res = await _call({'action': 'get_recent_orders', 'limit': limit,'vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => OrderRecord(Map.from(e))).toList();
  }

  // ------------------------------------------------------------------
  // Pending listing approvals
  // ------------------------------------------------------------------
  Future<List<MarketplacePendingGroup>> getPendingListings({int status = 0}) async {
    final res = await _call({'action': 'get_pending_listings', 'status': status,'vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => MarketplacePendingGroup.fromMap(Map.from(e))).toList();
  }

  /// Assuming 1 = approved, -1 = rejected (mirrors the convention used
  /// elsewhere in your marketplace_jobs status column).
  Future<bool> updateListingStatus({
    required String tableName,
    required int itemId,
    required int status,
  }) async {
    final res = await _call({
      'action': 'update_listing_status',
      'table_name': tableName,
      'item_id': itemId,
      'status': status,
      'vendor_id': UserSessionSet.instance.vendorId,
    });
    return res['success'] == true;
  }

  // ------------------------------------------------------------------
  // News & insights
  // ------------------------------------------------------------------
  Future<List<NewsItem>> getNewsInsights() async {
    final res = await _call({'action': 'get_news_insights','vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    final list = List.from(res['data'] ?? []);
    return list.map((e) => NewsItem(Map.from(e))).toList();
  }

  // ------------------------------------------------------------------
  // New seller onboarding — not wired into the dashboard UI yet,
  // exposed here in case you want to add a section for it later.
  // ------------------------------------------------------------------
  Future<List<Map>> getNewSellerOnboarding() async {
    final res = await _call({'action': 'get_new_seller_onboarding','vendor_id': UserSessionSet.instance.vendorId,});
    if (res['success'] != true) return [];
    return List.from(res['data'] ?? []).map((e) => Map.from(e)).toList();
  }

  Future<bool> updateSellerStatus({required int newVendorId, required int status}) async {
    final res = await _call({
      'action': 'update_seller_status',
      'new_vendor_id': newVendorId,
      'status': status,
      'vendor_id': UserSessionSet.instance.vendorId,
    });
    return res['success'] == true;
  }
}

// ========================================================================
// TYPED MODELS
// ========================================================================

class SpaceUtilization {
  final double maxBytes;
  final double usedBytes;
  final double availableBytes;
  final double utilizationPct; // 0..100

  SpaceUtilization({
    required this.maxBytes,
    required this.usedBytes,
    required this.availableBytes,
    required this.utilizationPct,
  });

  factory SpaceUtilization.fromMap(Map m) {
    double _d(dynamic v) => double.tryParse(v?.toString() ?? '') ?? 0;
    return SpaceUtilization(
      maxBytes: _d(m['max_storage_bytes']),
      usedBytes: _d(m['used_storage_bytes']),
      availableBytes: _d(m['available_storage_bytes']),
      utilizationPct: _d(m['utilization_percentage']),
    );
  }

  double get usedTb => usedBytes / (1024 * 1024 * 1024 * 1024);
  double get maxTb => maxBytes / (1024 * 1024 * 1024 * 1024);
}

class VisitDay {
  final String date;
  final int visits;
  VisitDay(this.date, this.visits);

  factory VisitDay.fromMap(Map m) => VisitDay(
    (m['date'] ?? '').toString(),
    int.tryParse(m['visits']?.toString() ?? '') ?? 0,
  );
}

class MarketplaceListings {
  final int marketplaceId;
  final String marketplaceName;
  final String displayName;
  final List<Map> topListings;

  MarketplaceListings({
    required this.marketplaceId,
    required this.marketplaceName,
    required this.displayName,
    required this.topListings,
  });

  factory MarketplaceListings.fromMap(Map m) => MarketplaceListings(
    marketplaceId: int.tryParse(m['marketplace_id']?.toString() ?? '') ?? 0,
    marketplaceName: (m['marketplace_name'] ?? '').toString(),
    displayName: (m['display_name'] ?? m['marketplace_name'] ?? '').toString(),
    topListings: List.from(m['top_listings'] ?? []).map((e) => Map.from(e)).toList(),
  );
}

class RevenuePoint {
  final String period;
  final double revenue;
  RevenuePoint(this.period, this.revenue);

  factory RevenuePoint.fromMap(Map m) => RevenuePoint(
    (m['period'] ?? '').toString(),
    double.tryParse(m['revenue']?.toString() ?? '') ?? 0,
  );
}

class Withdrawal {
  final Map raw;
  Withdrawal(this.raw);

  int get id => int.tryParse(raw['id']?.toString() ?? '') ?? 0;
  int get vendorId => int.tryParse(raw['vendor_id']?.toString() ?? '') ?? 0;
  double get requestedAmount =>
      double.tryParse(raw['requested_amount']?.toString() ?? '') ?? 0;
  String get description => (raw['description'] ?? '').toString();
  String get requestedDate => (raw['requested_date'] ?? '').toString();
}

class OrderRecord {
  final Map raw;
  OrderRecord(this.raw);

  String get id => (raw['id'] ?? '').toString();
  String get itemType => (raw['item_type'] ?? '').toString();
  String get itemId => (raw['item_id'] ?? '').toString();
  double get amount => double.tryParse(raw['amount']?.toString() ?? '') ?? 0;
  String get orderStatus => (raw['order_status'] ?? '').toString();
  String get orderDate => (raw['order_date'] ?? '').toString();
  String get buyerName => (raw['name'] ?? '').toString();
  String get buyerEmail => (raw['email'] ?? '').toString();
}

class MarketplacePendingGroup {
  final int marketplaceId;
  final String marketplaceName;
  final String displayName;
  final String tableName;
  final List<Map> listings;

  MarketplacePendingGroup({
    required this.marketplaceId,
    required this.marketplaceName,
    required this.displayName,
    required this.tableName,
    required this.listings,
  });

  factory MarketplacePendingGroup.fromMap(Map m) => MarketplacePendingGroup(
    marketplaceId: int.tryParse(m['marketplace_id']?.toString() ?? '') ?? 0,
    marketplaceName: (m['marketplace_name'] ?? '').toString(),
    displayName: (m['display_name'] ?? m['marketplace_name'] ?? '').toString(),
    tableName: (m['table_name'] ?? '').toString(),
    listings: List.from(m['listings'] ?? []).map((e) => Map.from(e)).toList(),
  );
}

class NewsItem {
  final Map raw;
  NewsItem(this.raw);

  String get title => (raw['post_title'] ?? '').toString();
  String get description => (raw['post_description'] ?? '').toString();
  String get category => (raw['category'] ?? '').toString();
  String get featuredImage => (raw['featured_image'] ?? '').toString();
}
// ============================================================================
// DESIGN TOKENS
// ============================================================================

class AppColors {
  // Brand
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFFE6F7F5);
  static const Color accent = Color(0xFFC2793D);

  // Neutrals
  static const Color ink = Color(0xFF1A1A2E);
  static const Color inkMuted = Color(0xFF6B7280);
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF8FAFC);
  static const Color outline = Color(0xFFE5E7EB);

  // Status semantics
  static const Color success = Color(0xFF16A34A);
  static const Color successBg = Color(0xFFE7F6EC);
  static const Color warning = Color(0xFFB45309);
  static const Color warningBg = Color(0xFFFDF2E3);
  static const Color danger = Color(0xFFC62828);
  static const Color dangerBg = Color(0xFFFFEBEE);

  static const Color neutralBadge = Color(0xFF4B5563);
  static const Color neutralBadgeBg = Color(0xFFF1F5F9);
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 10;
  static const double lg = 16;
}

class AppText {
  static const String displayFont = 'Manrope';

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.ink,
    fontFamily: displayFont,
  );

  static const TextStyle pageTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.primary,
    fontFamily: displayFont,
  );

  static const TextStyle eyebrow = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.bold,
    color: AppColors.inkMuted,
    letterSpacing: 0.6,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.inkMuted,
  );
}

/// Maps a domain status string to a consistent (foreground, background) pair.
class StatusStyle {
  final Color fg;
  final Color bg;
  const StatusStyle(this.fg, this.bg);

  static StatusStyle of(String status) {
    switch (status.toLowerCase()) {
      case 'fulfilled':
      case 'approved':
      case 'active':
      case 'completed': // real order_status value from the API
        return const StatusStyle(AppColors.success, AppColors.successBg);
      case 'processing':
      case 'pending':
        return const StatusStyle(AppColors.warning, AppColors.warningBg);
      case 'disapproved':
      case 'rejected':
      case 'failed':
      case 'cancelled': // real order_status value from the API
        return const StatusStyle(AppColors.danger, AppColors.dangerBg);
      default:
        return const StatusStyle(AppColors.neutralBadge, AppColors.neutralBadgeBg);
    }
  }
}


// ============================================================================
// MAIN DASHBOARD WIDGET
// ============================================================================

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final AdminDashboardService _service = AdminDashboardService();

  // ==========================================================================
  // STATE VARIABLES
  // ==========================================================================

  bool _isLoading = false;
  bool _isRefreshing = false;
  int _currentIndex = 0;

  // Data state variables — now populated from the API instead of mock data.
  String _currentMembershipTier = "No active membership";

  // Withdrawals rendered as "payout" cards. Each map carries the raw
  // Withdrawal alongside display strings, since the card UI was built
  // around Map<String, dynamic>.
  List<Map<String, dynamic>> _payouts = [];

  List<Map<String, dynamic>> _orders = [];

  // Each listing map carries 'table_name' + numeric 'item_id' so the
  // approve/reject buttons can call updateListingStatus correctly.
  List<Map<String, dynamic>> _listings = [];

  // Repurposed from "region -> {value, percentage}" to "date -> {value,
  // percentage}" since the API has no per-region visit data — see
  // AdminDashboardService.getVisitorTracking.
  Map<String, dynamic> _trafficData = {};

  List<double> _revenueData = [];
  List<String> _revenuePeriodLabels = [];

  double _spaceUtilizationPct = 0.0; // 0..1
  double _spaceUsedTb = 0.0;
  double _spaceTotalTb = 0.0;

  // The "Listing Distribution" card no longer represents a real
  // products-vs-services percentage (the API doesn't expose that split).
  // Instead it shows each marketplace's share of the top-listings the API
  // returned, capped at 5 per marketplace by the backend query itself.
  double _listingDistribution = 0.0;
  String _topMarketplaceLabel = "—";
  String _otherMarketplacesLabel = "Other marketplaces";

  List<Map<String, dynamic>> _news = [];

  // ==========================================================================
  // INITIALIZATION
  // ==========================================================================

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  // ==========================================================================
  // DATA LOADING — replaces the old mock initializers
  // ==========================================================================

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);

    try {
      final results = await Future.wait([
        _service.getCurrentMembership(),
        _service.getSpaceUtilization(),
        _service.getVisitorTracking(days: 28),
        _service.getListingDistribution(),
        _service.getRevenueStats(range: 'day'),
        _service.getPendingWithdrawals(),
        _service.getRecentOrders(limit: 10),
        _service.getPendingListings(status: 0),
        _service.getNewsInsights(),
      ]);

      final membership = results[0] as Map?;
      final space = results[1] as SpaceUtilization?;
      final visits = results[2] as List<VisitDay>;
      final listingDist = results[3] as List<MarketplaceListings>;
      final revenue = results[4] as List<RevenuePoint>;
      final withdrawals = results[5] as List<Withdrawal>;
      final orders = results[6] as List<OrderRecord>;
      final pendingGroups = results[7] as List<MarketplacePendingGroup>;
      final news = results[8] as List<NewsItem>;

      setState(() {
        // Membership
        _currentMembershipTier = membership != null
            ? (membership['membership_code']?.toString() ?? 'Active membership')
            : "No active membership";

        // Space utilization — direct 1:1 mapping
        if (space != null) {
          _spaceUtilizationPct = (space.utilizationPct / 100).clamp(0.0, 1.0);
          _spaceUsedTb = space.usedTb;
          _spaceTotalTb = space.maxTb;
        }

        // Visitor tracking -> reused as "traffic" rows, keyed by date
        // instead of region. Percentage is normalized against the max
        // visits in the returned window so the existing progress-bar UI
        // still makes sense.
        final maxVisits = visits.isEmpty
            ? 1
            : visits.map((v) => v.visits).reduce((a, b) => a > b ? a : b);
        _trafficData = {
          for (final v in visits.reversed.take(3))
            v.date: {
              'value': v.visits,
              'percentage': maxVisits == 0 ? 0.0 : v.visits / maxVisits,
            },
        };

        // Listing distribution -> approximate "share of top listings"
        final totalTopListings =
        listingDist.fold<int>(0, (sum, m) => sum + m.topListings.length);
        if (listingDist.isNotEmpty && totalTopListings > 0) {
          final top = listingDist.reduce(
                  (a, b) => a.topListings.length >= b.topListings.length ? a : b);
          _listingDistribution = top.topListings.length / totalTopListings;
          _topMarketplaceLabel = top.displayName;
          _otherMarketplacesLabel = listingDist.length > 1
              ? "Other marketplaces"
              : "No other marketplaces";
        } else {
          _listingDistribution = 0.0;
          _topMarketplaceLabel = "No listings yet";
        }

        // Revenue -> sparkline + labels
        _revenueData = revenue.map((r) => r.revenue).toList();
        _revenuePeriodLabels = revenue.map((r) => r.period).toList();

        // Pending withdrawals -> payout cards
        // NOTE: vendor name isn't returned by this endpoint (no join to
        // `vendor`), so we can only show the vendor_id here.
        _payouts = withdrawals
            .map((w) => {
          "id": "#WD-${w.id}",
          "withdraw_id": w.id,
          "vendor": "Vendor #${w.vendorId}",
          "amount": "₹${w.requestedAmount.toStringAsFixed(2)}",
          "date": w.requestedDate,
          "method": w.description.isEmpty ? "—" : w.description,
        })
            .toList();

        // Recent orders
        // NOTE: no seller/product-title join either — item_type + item_id
        // stand in for a product name until the backend joins the
        // relevant marketplace table.
        _orders = orders
            .map((o) => {
          "id": "#${o.id}",
          "product": "${o.itemType} #${o.itemId}",
          "seller": "—",
          "buyer": o.buyerName.isEmpty ? o.buyerEmail : o.buyerName,
          "amount": "₹${o.amount.toStringAsFixed(2)}",
          "status": o.orderStatus,
        })
            .toList();

        // Pending listing approvals — flatten grouped marketplaces into
        // individual cards, carrying table_name + item id for the API call.
        _listings = [
          for (final group in pendingGroups)
            for (final item in group.listings)
              {
                "title": (item['title'] ?? 'Untitled').toString(),
                "vendor": group.displayName,
                "icon": _iconForTable(group.tableName),
                "status": "pending",
                "table_name": group.tableName,
                "item_id": int.tryParse(item['id']?.toString() ?? '') ?? 0,
              },
        ];

        // News
        _news = news
            .map((n) => {
          "title": n.title,
          "description": n.description,
          "category": n.category.isEmpty ? "INSIGHT" : n.category.toUpperCase(),
        })
            .toList();

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) _showError("Couldn't load the dashboard. Please try again.");
    }
  }

  IconData _iconForTable(String tableName) {
    switch (tableName) {
      case 'marketplace_products':
      case 'marketplace_packaging':
        return Icons.inventory_2_outlined;
      case 'marketplace_services':
        return Icons.build_outlined;
      case 'marketplace_jobs':
        return Icons.work_outline;
      case 'marketplace_events':
        return Icons.event_outlined;
      case 'marketplace_hotels':
        return Icons.hotel_outlined;
      case 'marketplace_realestate':
        return Icons.home_work_outlined;
      case 'marketplace_trainings':
        return Icons.school_outlined;
      case 'marketplace_gigs':
        return Icons.handyman_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }

  // ==========================================================================
  // REFRESH LOGIC
  // ==========================================================================

  Future<void> _onRefresh() async {
    if (_isRefreshing) return;

    setState(() => _isRefreshing = true);

    try {
      await _loadDashboardData();
      if (mounted) _showSuccess("Dashboard refreshed successfully!");
    } catch (e) {
      if (mounted) _showError("Couldn't refresh the dashboard. Please try again.");
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  // ==========================================================================
  // UI HELPERS
  // ==========================================================================

  void _showSnackBar(String message, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: AppSpacing.sm),
            ],
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
      ),
    );
  }

  void _showSuccess(String message) => _showSnackBar(message, AppColors.success, icon: Icons.check_circle_outline);

  void _showError(String message) => _showSnackBar(message, AppColors.danger, icon: Icons.error_outline);

  void _showMembershipUpsellDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: const Text("Upgrade membership"),
        content: const Text("Upgrade to unlock global node access and premium features."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
            ),
            onPressed: () {
              // No purchase/checkout endpoint was provided in the API file,
              // so this stays a stub — wire it to your actual membership
              // purchase flow when that endpoint exists.
              Navigator.pop(context);
              _showSuccess("Membership upgrade initiated!");
            },
            child: const Text("Upgrade now"),
          ),
        ],
      ),
    );
  }

  BoxDecoration _cardDecoration({Color? borderColor}) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ],
      border: Border.all(color: borderColor ?? Colors.grey.shade100),
    );
  }

  Widget _buildSliderCard({required Widget child, Color? color}) {
    return Container(
      width: 190,
      height: 128,
      decoration: BoxDecoration(
        color: color ?? AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: child,
    );
  }

  Widget _buildProgressRow(String label, String value, double progress) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink)),
            Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: progress),
            duration: const Duration(milliseconds: 600),
            curve: Curves.easeOutCubic,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: Colors.grey.shade100,
            ),
          ),
        ),
      ],
    );
  }

  Widget _statusPill(String label, {Color? fg, Color? bg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg ?? AppColors.primaryLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg ?? AppColors.primary,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _emptyState({required IconData icon, required String message}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.grey.shade300),
            const SizedBox(height: AppSpacing.sm),
            Text(message, style: AppText.caption),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // BUILD METHODS
  // ==========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _payouts.isEmpty && _orders.isEmpty && _listings.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      strokeWidth: 3,
      displacement: 40,
      notificationPredicate: (notification) => notification.depth == 0,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const Divider(height: AppSpacing.xxl),
            _buildPlatformHealthSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildAdvancedAnalyticsSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildPendingWithdrawalsSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildRecentOrdersSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildListingApprovalsSection(),
            const SizedBox(height: AppSpacing.xxl),
            _buildNewsSection(),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // SECTION BUILDERS
  // ==========================================================================

  Widget _buildHeader() {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Strategic Overview", style: AppText.pageTitle),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _isRefreshing
                      ? const Padding(
                    key: ValueKey('spinner'),
                    padding: EdgeInsets.only(left: 12),
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                    ),
                  )
                      : const SizedBox(key: ValueKey('empty')),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              "Enhanced executive insights and operational flows.",
              style: AppText.caption,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlatformHealthSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Platform Health & Access", style: AppText.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Current Membership Card
              _buildSliderCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("CURRENT MEMBERSHIP", style: AppText.eyebrow),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          _currentMembershipTier,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        const Text("Unlimited marketplace access", style: AppText.caption),
                      ],
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 25,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                        ),
                        onPressed: _showMembershipUpsellDialog,
                        child: const Text("Upgrade plan", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Space Utilization Card
              _buildSliderCard(
                child: Row(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 54,
                          height: 54,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: _spaceUtilizationPct),
                            duration: const Duration(milliseconds: 700),
                            curve: Curves.easeOutCubic,
                            builder: (context, value, _) => CircularProgressIndicator(
                              value: value,
                              strokeWidth: 5,
                              color: AppColors.primary,
                              backgroundColor: Colors.grey.shade200,
                            ),
                          ),
                        ),
                        Text(
                          "${(_spaceUtilizationPct * 100).toInt()}%",
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink),
                        ),
                      ],
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("SPACE UTILIZATION", style: AppText.eyebrow),
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            "${_spaceUsedTb.toStringAsFixed(1)} / ${_spaceTotalTb.toStringAsFixed(1)} TB",
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Platform Status Card — static; no endpoint provides this.
              _buildSliderCard(
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                      child: const Icon(Icons.verified, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("PLATFORM STATUS", style: AppText.eyebrow),
                          SizedBox(height: AppSpacing.xs),
                          Text(
                            "Enterprise Elite",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Next Milestone Card
              _buildSliderCard(
                color: AppColors.accent,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "NEXT MILESTONE",
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.6),
                        ),
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          "Unlock global node access",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 32,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.white),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _showMembershipUpsellDialog,
                        child: const Text("Upgrade membership", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedAnalyticsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Advanced Analytics", style: AppText.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              // Traffic-by-day card (was "Global Traffic Density" by
              // region — the API only exposes site-wide visits per day).
              Container(
                width: 320,
                height: 260,
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Visitor Traffic", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("VISITS BY DAY (LAST 28 DAYS)", style: AppText.eyebrow),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.only(right: 4),
                              decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                            ),
                            _statusPill("LIVE", fg: AppColors.success, bg: AppColors.successBg),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Expanded(
                      child: _trafficData.isEmpty
                          ? _emptyState(icon: Icons.show_chart, message: "No visitor data yet")
                          : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: _trafficData.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                            child: _buildProgressRow(
                              entry.key,
                              "${entry.value['value']}",
                              (entry.value['percentage'] as num).toDouble(),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Listing Distribution Card — now "share of top listings by
              // marketplace" rather than a products/services percentage.
              Container(
                width: 300,
                height: 260,
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Listing Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Text("TOP MARKETPLACE SHARE", style: AppText.eyebrow),
                    const SizedBox(height: AppSpacing.md),
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: _listingDistribution),
                                duration: const Duration(milliseconds: 700),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, _) => CircularProgressIndicator(
                                  value: value,
                                  strokeWidth: 16,
                                  color: AppColors.primary,
                                  backgroundColor: Colors.grey.shade100,
                                ),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "${(_listingDistribution * 100).toInt()}%",
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
                                ),
                                const Text("TOP MARKET", style: TextStyle(fontSize: 8, color: AppColors.inkMuted, fontWeight: FontWeight.bold)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.lens, color: AppColors.primary, size: 8),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(_topMarketplaceLabel,
                                    style: AppText.caption, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.lens, color: Colors.grey.shade400, size: 8),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(_otherMarketplacesLabel,
                                    style: AppText.caption, overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.lg),

              // Revenue Growth Card
              Container(
                width: 320,
                height: 260,
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Revenue Growth Cycle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            Text("PERFORMANCE OVER TIME", style: AppText.eyebrow),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: Colors.grey.shade200),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            "BY DAY",
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.ink),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: _revenueData.length >= 2
                          ? CustomPaint(
                        size: Size.infinite,
                        painter: SparklinePainter(data: _revenueData),
                      )
                          : _emptyState(icon: Icons.trending_up, message: "Not enough revenue data yet"),
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _periodLabelWidgets(),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Shows up to 4 evenly-spaced period labels under the sparkline,
  /// using whatever periods the API actually returned instead of the
  /// hardcoded "Week 1..4" placeholders.
  List<Widget> _periodLabelWidgets() {
    if (_revenuePeriodLabels.isEmpty) return const [SizedBox.shrink()];
    final labels = _revenuePeriodLabels.length <= 4
        ? _revenuePeriodLabels
        : [
      _revenuePeriodLabels.first,
      _revenuePeriodLabels[_revenuePeriodLabels.length ~/ 3],
      _revenuePeriodLabels[(_revenuePeriodLabels.length * 2) ~/ 3],
      _revenuePeriodLabels.last,
    ];
    return labels
        .map((l) => Text(l, style: const TextStyle(fontSize: 9, color: Colors.grey)))
        .toList();
  }

  Widget _buildPendingWithdrawalsSection() {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            color: AppColors.surfaceSubtle,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Pending Seller Withdrawals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink)),
                    Text("Review and authorize financial payouts", style: AppText.caption),
                  ],
                ),
                _statusPill("${_payouts.length} PENDING"),
              ],
            ),
          ),
          const Divider(height: 1),
          if (_payouts.isEmpty)
            _emptyState(icon: Icons.inbox_outlined, message: "No pending payouts")
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _payouts.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = _payouts[index];
                return Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(AppRadius.md)),
                            child: const Icon(Icons.account_balance, color: AppColors.primary),
                          ),
                          const SizedBox(width: AppSpacing.lg),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item["vendor"],
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        item["id"],
                                        style: TextStyle(fontSize: 8, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  item["amount"],
                                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  "Request date: ${item['date']} • ${item['method']}",
                                  style: const TextStyle(fontSize: 9, color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: AppColors.outline),
                                  foregroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                                  padding: EdgeInsets.zero,
                                ),
                                onPressed: () => _showSuccess("Opening chat with ${item['vendor']}"),
                                child: const Text("Contact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.dangerBg,
                                  foregroundColor: AppColors.danger,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                onPressed: () => _confirmAndRemove(
                                  title: "Disapprove payout?",
                                  message: "${item['vendor']} will be notified that this payout was disapproved.",
                                  confirmLabel: "Disapprove",
                                  confirmColor: AppColors.danger,
                                  onConfirmed: () async {
                                    final ok = await _service.updateWithdrawalStatus(
                                      withdrawId: item['withdraw_id'] as int,
                                      status: 2, // assumed: 2 = disapproved
                                    );
                                    if (ok) {
                                      setState(() => _payouts.removeAt(index));
                                      _showSuccess("Payout request disapproved.");
                                    } else {
                                      _showError("Failed to disapprove payout.");
                                    }
                                  },
                                ),
                                child: const Text("Disapprove", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SizedBox(
                              height: 36,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
                                  padding: EdgeInsets.zero,
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  final ok = await _service.updateWithdrawalStatus(
                                    withdrawId: item['withdraw_id'] as int,
                                    status: 1, // assumed: 1 = approved
                                  );
                                  if (ok) {
                                    setState(() => _payouts.removeAt(index));
                                    _showSuccess("Payout approved successfully!");
                                  } else {
                                    _showError("Failed to approve payout.");
                                  }
                                },
                                child: const Text("Approve", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
        ],
      ),
    );
  }

  Future<void> _confirmAndRemove({
    required String title,
    required String message,
    required String confirmLabel,
    required Color confirmColor,
    required VoidCallback onConfirmed,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
    if (confirmed == true) onConfirmed();
  }

  Widget _buildRecentOrdersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Live Stream: Recent Orders", style: AppText.sectionTitle),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
              onPressed: () => setState(() => _currentIndex = 11),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("View ledger", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.arrow_forward, size: 14),
                ],
              ),
            )
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (_orders.isEmpty)
          Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            child: _emptyState(icon: Icons.receipt_long_outlined, message: "No recent orders"),
          )
        else
          ..._orders.map((order) {
            final statusStyle = StatusStyle.of(order["status"] as String);
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Container(
                width: double.infinity,
                decoration: _cardDecoration(),
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.md)),
                      child: const Icon(Icons.receipt_outlined, color: AppColors.primary),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  order["product"],
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              _statusPill(order["status"], fg: statusStyle.fg, bg: statusStyle.bg),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text("ID: ${order['id']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                          const SizedBox(height: AppSpacing.sm),
                          Wrap(
                            spacing: AppSpacing.lg,
                            runSpacing: AppSpacing.xs,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.person, color: Colors.grey, size: 14),
                                  const SizedBox(width: 4),
                                  const Text("Buyer: ", style: AppText.caption),
                                  Text(order["buyer"], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(order["amount"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
      ],
    );
  }

  Widget _buildListingApprovalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Curated Queue: Listing Approvals", style: AppText.sectionTitle),
            _statusPill("${_listings.length} New", fg: AppColors.danger, bg: AppColors.dangerBg),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (_listings.isEmpty)
          Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            child: _emptyState(icon: Icons.checklist_rtl_outlined, message: "No pending listings"),
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 500;
              final cards = _listings.map((listing) {
                return Container(
                  decoration: _cardDecoration(),
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 100,
                        decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.sm)),
                        alignment: Alignment.center,
                        child: Icon(listing["icon"], color: AppColors.primary, size: 36),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        listing["title"],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text("Marketplace: ${listing['vendor']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        height: 38,
                        child: Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.dangerBg,
                                  foregroundColor: AppColors.danger,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                ),
                                onPressed: () => _confirmAndRemove(
                                  title: "Reject listing?",
                                  message: "\"${listing['title']}\" will be rejected.",
                                  confirmLabel: "Reject",
                                  confirmColor: AppColors.danger,
                                  onConfirmed: () async {
                                    final ok = await _service.updateListingStatus(
                                      tableName: listing['table_name'] as String,
                                      itemId: listing['item_id'] as int,
                                      status: -1, // assumed: -1 = rejected
                                    );
                                    if (ok) {
                                      setState(() => _listings.remove(listing));
                                      _showSuccess("${listing['title']} rejected.");
                                    } else {
                                      _showError("Failed to reject listing.");
                                    }
                                  },
                                ),
                                child: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                                ),
                                onPressed: () async {
                                  final ok = await _service.updateListingStatus(
                                    tableName: listing['table_name'] as String,
                                    itemId: listing['item_id'] as int,
                                    status: 1, // assumed: 1 = approved
                                  );
                                  if (ok) {
                                    setState(() => _listings.remove(listing));
                                    _showSuccess("${listing['title']} approved!");
                                  } else {
                                    _showError("Failed to approve listing.");
                                  }
                                },
                                child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }).toList();

              return isNarrow
                  ? Column(
                children: cards.asMap().entries.map((entry) {
                  return Column(
                    children: [
                      entry.value,
                      if (entry.key < cards.length - 1) const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                }).toList(),
              )
                  : Row(
                children: cards.asMap().entries.map((entry) {
                  return Expanded(
                    child: Row(
                      children: [
                        Expanded(child: entry.value),
                        if (entry.key < cards.length - 1) const SizedBox(width: AppSpacing.lg),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  Widget _buildNewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("News & Global Insights", style: AppText.sectionTitle),
        const SizedBox(height: AppSpacing.md),
        if (_news.isEmpty)
          Container(
            width: double.infinity,
            decoration: _cardDecoration(),
            child: _emptyState(icon: Icons.newspaper_outlined, message: "No news yet"),
          )
        else
          ..._news.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.lg),
            child: Container(
              decoration: _cardDecoration(),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColors.primary.withOpacity(0.85), AppColors.primary.withOpacity(0.4)],
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.newspaper, color: Colors.white, size: 44),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item["category"],
                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.6),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          item["title"],
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          item["description"],
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )),
      ],
    );
  }
}

// ============================================================================
// SPARKLINE PAINTER
// ============================================================================

class SparklinePainter extends CustomPainter {
  final List<double> data;

  SparklinePainter({required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2) return;

    final paint = Paint()
      ..color = AppColors.primary
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final minValue = data.reduce((a, b) => a < b ? a : b);
    final range = maxValue - minValue;

    const padding = 8.0;
    final usableHeight = size.height - padding * 2;
    final usableWidth = size.width - padding * 2;
    final stepX = usableWidth / (data.length - 1);

    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = padding + i * stepX;
      final y = padding + usableHeight - ((data[i] - minValue) / (range == 0 ? 1 : range)) * usableHeight;
      points.add(Offset(x, y));
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final fillPath = Path.from(path)
      ..lineTo(points.last.dx, size.height - padding)
      ..lineTo(points.first.dx, size.height - padding)
      ..close();

    final gradientPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawPath(fillPath, gradientPaint);
    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..color = AppColors.primary
      ..style = PaintingStyle.fill;
    final pointHalo = Paint()..color = Colors.white;

    for (final p in points) {
      canvas.drawCircle(p, 4, pointHalo);
      canvas.drawCircle(p, 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(SparklinePainter oldDelegate) => oldDelegate.data != data;
}

//
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
//
// // ============================================================================
// // DESIGN TOKENS
// // ============================================================================
// //
// // Centralizing color, spacing, radius, and status semantics here means every
// // widget below pulls from the same palette instead of scattering one-off
// // hex codes (e.g. Color(0xFFFFEBEE) inline). Change the brand here once and
// // it propagates everywhere.
//
// class AppColors {
//   // Brand
//   static const Color primary = Color(0xFF0F766E); // deep teal, slightly richer than before
//   static const Color primaryLight = Color(0xFFE6F7F5);
//   static const Color accent = Color(0xFFC2793D); // warm clay accent for highlight moments
//
//   // Neutrals
//   static const Color ink = Color(0xFF1A1A2E);
//   static const Color inkMuted = Color(0xFF6B7280);
//   static const Color surface = Colors.white;
//   static const Color surfaceSubtle = Color(0xFFF8FAFC);
//   static const Color outline = Color(0xFFE5E7EB);
//
//   // Status semantics — used consistently for badges, buttons, and icons
//   static const Color success = Color(0xFF16A34A);
//   static const Color successBg = Color(0xFFE7F6EC);
//   static const Color warning = Color(0xFFB45309);
//   static const Color warningBg = Color(0xFFFDF2E3);
//   static const Color danger = Color(0xFFC62828);
//   static const Color dangerBg = Color(0xFFFFEBEE);
//
//   static const Color neutralBadge = Color(0xFF4B5563);
//   static const Color neutralBadgeBg = Color(0xFFF1F5F9);
// }
//
// class AppSpacing {
//   static const double xs = 4;
//   static const double sm = 8;
//   static const double md = 12;
//   static const double lg = 16;
//   static const double xl = 20;
//   static const double xxl = 28;
// }
//
// class AppRadius {
//   static const double sm = 8;
//   static const double md = 10;
//   static const double lg = 16;
// }
//
// class AppText {
//   static const String displayFont = 'Manrope';
//
//   static const TextStyle sectionTitle = TextStyle(
//     fontSize: 16,
//     fontWeight: FontWeight.bold,
//     color: AppColors.ink,
//     fontFamily: displayFont,
//   );
//
//   static const TextStyle pageTitle = TextStyle(
//     fontSize: 22,
//     fontWeight: FontWeight.bold,
//     color: AppColors.primary,
//     fontFamily: displayFont,
//   );
//
//   static const TextStyle eyebrow = TextStyle(
//     fontSize: 9,
//     fontWeight: FontWeight.bold,
//     color: AppColors.inkMuted,
//     letterSpacing: 0.6,
//   );
//
//   static const TextStyle caption = TextStyle(
//     fontSize: 11,
//     color: AppColors.inkMuted,
//   );
// }
//
// /// Maps a domain status string to a consistent (foreground, background) pair.
// /// Keeping this in one place stops badges from silently drifting out of sync
// /// (previously every status pill rendered in the same teal, so "Processing"
// /// and "Fulfilled" were visually indistinguishable).
// class StatusStyle {
//   final Color fg;
//   final Color bg;
//   const StatusStyle(this.fg, this.bg);
//
//   static StatusStyle of(String status) {
//     switch (status.toLowerCase()) {
//       case 'fulfilled':
//       case 'approved':
//       case 'active':
//         return const StatusStyle(AppColors.success, AppColors.successBg);
//       case 'processing':
//       case 'pending':
//         return const StatusStyle(AppColors.warning, AppColors.warningBg);
//       case 'disapproved':
//       case 'rejected':
//       case 'failed':
//         return const StatusStyle(AppColors.danger, AppColors.dangerBg);
//       default:
//         return const StatusStyle(AppColors.neutralBadge, AppColors.neutralBadgeBg);
//     }
//   }
// }
//
// // ============================================================================
// // MAIN DASHBOARD WIDGET
// // ============================================================================
//
// class AdminDashboard extends StatefulWidget {
//   const AdminDashboard({super.key});
//
//   @override
//   State<AdminDashboard> createState() => _AdminDashboardState();
// }
//
// class _AdminDashboardState extends State<AdminDashboard> {
//   // ==========================================================================
//   // STATE VARIABLES
//   // ==========================================================================
//
//   bool _isLoading = false;
//   bool _isRefreshing = false;
//   int _currentIndex = 0;
//
//   // Data state variables
//   String _currentMembershipTier = "Enterprise Pro";
//   List<Map<String, dynamic>> _mockPayouts = [];
//   List<Map<String, dynamic>> _mockOrders = [];
//   List<Map<String, dynamic>> _mockListings = [];
//   Map<String, dynamic> _trafficData = {};
//   List<double> _revenueData = [];
//   double _spaceUtilizationPct = 0.75; // 0..1
//   double _spaceUsedTb = 6.4;
//   double _spaceTotalTb = 8.0;
//   double _listingDistribution = 0.45;
//
//   // ==========================================================================
//   // INITIALIZATION
//   // ==========================================================================
//
//   @override
//   void initState() {
//     super.initState();
//     _initializeMockData();
//   }
//
//   void _initializeMockData() {
//     _mockPayouts = [
//       {
//         "id": "#PAY-001",
//         "vendor": "TechNexus Solutions",
//         "amount": "₹48,500.00",
//         "date": "2026-07-01",
//         "method": "Bank Transfer"
//       },
//       {
//         "id": "#PAY-002",
//         "vendor": "Creative Labs Studio",
//         "amount": "₹32,200.00",
//         "date": "2026-07-02",
//         "method": "UPI"
//       },
//     ];
//
//     _mockOrders = [
//       {
//         "id": "#ORD-22910",
//         "product": "Zen Series Wireless Earbuds",
//         "seller": "Urban Electronics",
//         "buyer": "Sarah Jenkins",
//         "amount": "₹18,900.00",
//         "status": "Fulfilled"
//       },
//       {
//         "id": "#ORD-22911",
//         "product": "Smart Home Hub Pro",
//         "seller": "SmartLiving Inc",
//         "buyer": "Michael Chen",
//         "amount": "₹24,500.00",
//         "status": "Processing"
//       },
//     ];
//
//     _mockListings = [
//       {
//         "title": "Premium Soundbar Pro",
//         "vendor": "TechNexus",
//         "icon": Icons.speaker,
//         "status": "pending"
//       },
//       {
//         "title": "Brand Strategy Workshop",
//         "vendor": "Creative Labs",
//         "icon": Icons.brush,
//         "status": "pending"
//       },
//     ];
//
//     _trafficData = {
//       "North America": {"value": 42500, "percentage": 0.85},
//       "Europe": {"value": 38200, "percentage": 0.76},
//       "Asia Pacific": {"value": 24100, "percentage": 0.48},
//     };
//
//     _revenueData = [12000, 18000, 15000, 22000];
//   }
//
//   // ==========================================================================
//   // REFRESH LOGIC
//   // ==========================================================================
//
//   Future<void> _onRefresh() async {
//     if (_isRefreshing) return;
//
//     setState(() {
//       _isRefreshing = true;
//       _isLoading = true;
//     });
//
//     try {
//       await Future.delayed(const Duration(seconds: 2));
//       await _refreshDashboardData();
//
//       setState(() {
//         _isRefreshing = false;
//         _isLoading = false;
//       });
//
//       if (mounted) {
//         _showSuccess("Dashboard refreshed successfully!");
//       }
//     } catch (e) {
//       setState(() {
//         _isRefreshing = false;
//         _isLoading = false;
//       });
//
//       if (mounted) {
//         _showError("Couldn't refresh the dashboard. Please try again.");
//       }
//     }
//   }
//
//   Future<void> _refreshDashboardData() async {
//     await Future.delayed(const Duration(milliseconds: 500));
//
//     _currentMembershipTier = "Enterprise Pro";
//
//     if (_mockPayouts.isEmpty) {
//       _mockPayouts = [
//         {
//           "id": "#PAY-001",
//           "vendor": "TechNexus Solutions",
//           "amount": "₹48,500.00",
//           "date": "2026-07-01",
//           "method": "Bank Transfer"
//         },
//         {
//           "id": "#PAY-002",
//           "vendor": "Creative Labs Studio",
//           "amount": "₹32,200.00",
//           "date": "2026-07-02",
//           "method": "UPI"
//         },
//       ];
//     }
//
//     _mockOrders = [
//       {
//         "id": "#ORD-22910",
//         "product": "Zen Series Wireless Earbuds",
//         "seller": "Urban Electronics",
//         "buyer": "Sarah Jenkins",
//         "amount": "₹18,900.00",
//         "status": "Fulfilled"
//       },
//       {
//         "id": "#ORD-22911",
//         "product": "Smart Home Hub Pro",
//         "seller": "SmartLiving Inc",
//         "buyer": "Michael Chen",
//         "amount": "₹24,500.00",
//         "status": "Processing"
//       },
//       {
//         "id": "#ORD-22912",
//         "product": "Portable SSD 2TB",
//         "seller": "DataStore Co",
//         "buyer": "Alex Rivera",
//         "amount": "₹12,800.00",
//         "status": "Pending"
//       },
//     ];
//
//     // Nudge utilization within a believable band instead of the previous
//     // magic-number formula (6.4 + (_util - 0.75) * 10) which tied storage
//     // TB directly to a percentage in a way that was hard to follow.
//     _spaceUtilizationPct = (0.75 + (DateTime.now().millisecond % 5) * 0.01).clamp(0.0, 0.95);
//     _spaceTotalTb = 8.0;
//     _spaceUsedTb = _spaceUtilizationPct * _spaceTotalTb;
//
//     _listingDistribution = 0.45 + (DateTime.now().second % 3) * 0.02;
//     if (_listingDistribution > 0.60) _listingDistribution = 0.45;
//
//     _trafficData = {
//       "North America": {"value": 42500 + DateTime.now().minute * 10, "percentage": 0.85},
//       "Europe": {"value": 38200 + DateTime.now().minute * 8, "percentage": 0.76},
//       "Asia Pacific": {"value": 24100 + DateTime.now().minute * 5, "percentage": 0.48},
//     };
//
//     _revenueData = [12000, 18000, 15000, 22000 + DateTime.now().minute * 20.0];
//   }
//
//   // ==========================================================================
//   // UI HELPERS
//   // ==========================================================================
//
//   void _showSnackBar(String message, Color color, {IconData? icon}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Row(
//           children: [
//             if (icon != null) ...[
//               Icon(icon, color: Colors.white, size: 18),
//               const SizedBox(width: AppSpacing.sm),
//             ],
//             Expanded(child: Text(message)),
//           ],
//         ),
//         backgroundColor: color,
//         duration: const Duration(seconds: 2),
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//       ),
//     );
//   }
//
//   void _showSuccess(String message) => _showSnackBar(message, AppColors.success, icon: Icons.check_circle_outline);
//
//   void _showError(String message) => _showSnackBar(message, AppColors.danger, icon: Icons.error_outline);
//
//   void _showMembershipUpsellDialog() {
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
//         title: const Text("Upgrade membership"),
//         content: const Text("Upgrade to unlock global node access and premium features."),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Cancel"),
//           ),
//           FilledButton(
//             style: FilledButton.styleFrom(
//               backgroundColor: AppColors.primary,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//               _showSuccess("Membership upgrade initiated!");
//             },
//             child: const Text("Upgrade now"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   BoxDecoration _cardDecoration({Color? borderColor}) {
//     return BoxDecoration(
//       color: AppColors.surface,
//       borderRadius: BorderRadius.circular(AppRadius.lg),
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.05),
//           blurRadius: 12,
//           offset: const Offset(0, 2),
//         ),
//       ],
//       border: Border.all(color: borderColor ?? Colors.grey.shade100),
//     );
//   }
//
//   Widget _buildSliderCard({required Widget child, Color? color}) {
//     return Container(
//       width: 190,
//       height: 128,
//       decoration: BoxDecoration(
//         color: color ?? AppColors.surface,
//         borderRadius: BorderRadius.circular(AppRadius.lg),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//         border: Border.all(color: Colors.grey.shade100),
//       ),
//       padding: const EdgeInsets.all(AppSpacing.lg),
//       child: child,
//     );
//   }
//
//   Widget _buildProgressRow(String label, String value, double progress) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.ink)),
//             Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
//           ],
//         ),
//         const SizedBox(height: AppSpacing.xs),
//         ClipRRect(
//           borderRadius: BorderRadius.circular(4),
//           child: TweenAnimationBuilder<double>(
//             tween: Tween(begin: 0, end: progress),
//             duration: const Duration(milliseconds: 600),
//             curve: Curves.easeOutCubic,
//             builder: (context, value, _) => LinearProgressIndicator(
//               value: value,
//               minHeight: 6,
//               color: AppColors.primary,
//               backgroundColor: Colors.grey.shade100,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   /// Small pill used for statuses, counts, and tags. Centralizing this stops
//   /// each section from hand-rolling its own padding/radius/typography combo.
//   Widget _statusPill(String label, {Color? fg, Color? bg}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
//       decoration: BoxDecoration(
//         color: bg ?? AppColors.primaryLight,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Text(
//         label,
//         style: TextStyle(
//           color: fg ?? AppColors.primary,
//           fontSize: 9,
//           fontWeight: FontWeight.bold,
//           letterSpacing: 0.4,
//         ),
//       ),
//     );
//   }
//
//   Widget _emptyState({required IconData icon, required String message}) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 40),
//       child: Center(
//         child: Column(
//           children: [
//             Icon(icon, size: 32, color: Colors.grey.shade300),
//             const SizedBox(height: AppSpacing.sm),
//             Text(message, style: AppText.caption),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================================
//   // BUILD METHODS
//   // ==========================================================================
//
//   @override
//   Widget build(BuildContext context) {
//     return RefreshIndicator(
//       onRefresh: _onRefresh,
//       color: AppColors.primary,
//       backgroundColor: Colors.white,
//       strokeWidth: 3,
//       displacement: 40,
//       notificationPredicate: (notification) => notification.depth == 0,
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.all(AppSpacing.xl),
//         physics: const AlwaysScrollableScrollPhysics(),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             _buildHeader(),
//             const Divider(height: AppSpacing.xxl),
//             _buildPlatformHealthSection(),
//             const SizedBox(height: AppSpacing.xxl),
//             _buildAdvancedAnalyticsSection(),
//             const SizedBox(height: AppSpacing.xxl),
//             _buildPendingWithdrawalsSection(),
//             const SizedBox(height: AppSpacing.xxl),
//             _buildRecentOrdersSection(),
//             const SizedBox(height: AppSpacing.xxl),
//             _buildListingApprovalsSection(),
//             const SizedBox(height: AppSpacing.xxl),
//             _buildNewsSection(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ==========================================================================
//   // SECTION BUILDERS
//   // ==========================================================================
//
//   Widget _buildHeader() {
//     return Wrap(
//       alignment: WrapAlignment.spaceBetween,
//       crossAxisAlignment: WrapCrossAlignment.center,
//       spacing: AppSpacing.lg,
//       runSpacing: AppSpacing.md,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Text("Strategic Overview", style: AppText.pageTitle),
//                 AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 200),
//                   child: _isRefreshing
//                       ? const Padding(
//                     key: ValueKey('spinner'),
//                     padding: EdgeInsets.only(left: 12),
//                     child: SizedBox(
//                       width: 18,
//                       height: 18,
//                       child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
//                     ),
//                   )
//                       : const SizedBox(key: ValueKey('empty')),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 2),
//             const Text(
//               "Enhanced executive insights and operational flows.",
//               style: AppText.caption,
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPlatformHealthSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Platform Health & Access", style: AppText.sectionTitle),
//         const SizedBox(height: AppSpacing.md),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           child: Row(
//             children: [
//               // Current Membership Card
//               _buildSliderCard(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text("CURRENT MEMBERSHIP", style: AppText.eyebrow),
//                         const SizedBox(height: AppSpacing.xs),
//                         Text(
//                           _currentMembershipTier,
//                           style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: AppSpacing.xs),
//                         const Text("Unlimited marketplace access", style: AppText.caption),
//                       ],
//                     ),
//                     SizedBox(
//                       width: double.infinity,
//                       height: 25,
//                       child: FilledButton(
//                         style: FilledButton.styleFrom(
//                           backgroundColor: AppColors.primary,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                         ),
//                         onPressed: _showMembershipUpsellDialog,
//                         child: const Text("Upgrade plan", style: TextStyle(fontSize: 7, fontWeight: FontWeight.bold)),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.lg),
//
//               // Space Utilization Card
//               _buildSliderCard(
//                 child: Row(
//                   children: [
//                     Stack(
//                       alignment: Alignment.center,
//                       children: [
//                         SizedBox(
//                           width: 54,
//                           height: 54,
//                           child: TweenAnimationBuilder<double>(
//                             tween: Tween(begin: 0, end: _spaceUtilizationPct),
//                             duration: const Duration(milliseconds: 700),
//                             curve: Curves.easeOutCubic,
//                             builder: (context, value, _) => CircularProgressIndicator(
//                               value: value,
//                               strokeWidth: 5,
//                               color: AppColors.primary,
//                               backgroundColor: Colors.grey.shade200,
//                             ),
//                           ),
//                         ),
//                         Text(
//                           "${(_spaceUtilizationPct * 100).toInt()}%",
//                           style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(width: AppSpacing.lg),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text("SPACE UTILIZATION", style: AppText.eyebrow),
//                           const SizedBox(height: AppSpacing.xs),
//                           Text(
//                             "${_spaceUsedTb.toStringAsFixed(1)} / ${_spaceTotalTb.toStringAsFixed(1)} TB",
//                             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.lg),
//
//               // Platform Status Card
//               _buildSliderCard(
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 50,
//                       height: 50,
//                       decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
//                       child: const Icon(Icons.verified, color: AppColors.primary, size: 28),
//                     ),
//                     const SizedBox(width: AppSpacing.lg),
//                     const Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text("PLATFORM STATUS", style: AppText.eyebrow),
//                           SizedBox(height: AppSpacing.xs),
//                           Text(
//                             "Enterprise Elite",
//                             style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink),
//                           ),
//                         ],
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.lg),
//
//               // Next Milestone Card — uses the accent color, not primary, so
//               // it reads as a distinct call-to-action rather than "more of
//               // the same teal" as the surrounding cards.
//               _buildSliderCard(
//                 color: AppColors.accent,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           "NEXT MILESTONE",
//                           style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white70, letterSpacing: 0.6),
//                         ),
//                         SizedBox(height: AppSpacing.xs),
//                         Text(
//                           "Unlock global node access",
//                           style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 32,
//                       child: OutlinedButton(
//                         style: OutlinedButton.styleFrom(
//                           side: const BorderSide(color: Colors.white),
//                           foregroundColor: Colors.white,
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                           padding: const EdgeInsets.symmetric(horizontal: 16),
//                         ),
//                         onPressed: _showMembershipUpsellDialog,
//                         child: const Text("Upgrade membership", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildAdvancedAnalyticsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("Advanced Analytics", style: AppText.sectionTitle),
//         const SizedBox(height: AppSpacing.md),
//         SingleChildScrollView(
//           scrollDirection: Axis.horizontal,
//           physics: const BouncingScrollPhysics(),
//           child: Row(
//             children: [
//               // Global Traffic Density Card
//               Container(
//                 width: 320,
//                 height: 260,
//                 decoration: _cardDecoration(),
//                 padding: const EdgeInsets.all(AppSpacing.xl),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Global Traffic Density", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                             Text("VISITOR CLUSTERS BY REGION", style: AppText.eyebrow),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Container(
//                               width: 6,
//                               height: 6,
//                               margin: const EdgeInsets.only(right: 4),
//                               decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
//                             ),
//                             _statusPill("LIVE", fg: AppColors.success, bg: AppColors.successBg),
//                           ],
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: AppSpacing.lg),
//                     Expanded(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: _trafficData.entries.map((entry) {
//                           return Padding(
//                             padding: const EdgeInsets.only(bottom: AppSpacing.lg),
//                             child: _buildProgressRow(
//                               entry.key,
//                               "${(entry.value['value'] as int).toStringAsFixed(1)}k",
//                               entry.value['percentage'] as double,
//                             ),
//                           );
//                         }).toList(),
//                       ),
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.lg),
//
//               // Listing Distribution Card
//               Container(
//                 width: 300,
//                 height: 260,
//                 decoration: _cardDecoration(),
//                 padding: const EdgeInsets.all(AppSpacing.xl),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text("Listing Distribution", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                     const Text("CATEGORY BREAKDOWN", style: AppText.eyebrow),
//                     const SizedBox(height: AppSpacing.md),
//                     Expanded(
//                       child: Center(
//                         child: Stack(
//                           alignment: Alignment.center,
//                           children: [
//                             SizedBox(
//                               width: 100,
//                               height: 100,
//                               child: TweenAnimationBuilder<double>(
//                                 tween: Tween(begin: 0, end: _listingDistribution),
//                                 duration: const Duration(milliseconds: 700),
//                                 curve: Curves.easeOutCubic,
//                                 builder: (context, value, _) => CircularProgressIndicator(
//                                   value: value,
//                                   strokeWidth: 16,
//                                   color: AppColors.primary,
//                                   backgroundColor: Colors.grey.shade100,
//                                 ),
//                               ),
//                             ),
//                             Column(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 Text(
//                                   "${(_listingDistribution * 100).toInt()}%",
//                                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
//                                 ),
//                                 const Text("PRODUCTS", style: TextStyle(fontSize: 8, color: AppColors.inkMuted, fontWeight: FontWeight.bold)),
//                               ],
//                             )
//                           ],
//                         ),
//                       ),
//                     ),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         Row(
//                           children: const [
//                             Icon(Icons.lens, color: AppColors.primary, size: 8),
//                             SizedBox(width: 4),
//                             Text("Products", style: AppText.caption),
//                           ],
//                         ),
//                         Row(
//                           children: [
//                             Icon(Icons.lens, color: Colors.grey.shade400, size: 8),
//                             const SizedBox(width: 4),
//                             const Text("Services", style: AppText.caption),
//                           ],
//                         ),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//               const SizedBox(width: AppSpacing.lg),
//
//               // Revenue Growth Card
//               Container(
//                 width: 320,
//                 height: 260,
//                 decoration: _cardDecoration(),
//                 padding: const EdgeInsets.all(AppSpacing.xl),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         const Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text("Revenue Growth Cycle", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                             Text("PERFORMANCE OVER TIME", style: AppText.eyebrow),
//                           ],
//                         ),
//                         Container(
//                           padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             border: Border.all(color: Colors.grey.shade200),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: const Text(
//                             "LAST 30 DAYS",
//                             style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppColors.ink),
//                           ),
//                         )
//                       ],
//                     ),
//                     const SizedBox(height: AppSpacing.xl),
//                     // Previously this CustomPaint had its painter commented
//                     // out, so the card rendered an empty box. Wiring it up
//                     // makes the "Revenue Growth Cycle" card actually show
//                     // the sparkline it's labeled for.
//                     Expanded(
//                       child: _revenueData.length >= 2
//                           ? CustomPaint(
//                         size: Size.infinite,
//                         painter: SparklinePainter(data: _revenueData),
//                       )
//                           : const SizedBox.shrink(),
//                     ),
//                     const SizedBox(height: AppSpacing.md),
//                     const Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text("Week 1", style: TextStyle(fontSize: 9, color: Colors.grey)),
//                         Text("Week 2", style: TextStyle(fontSize: 9, color: Colors.grey)),
//                         Text("Week 3", style: TextStyle(fontSize: 9, color: Colors.grey)),
//                         Text("Week 4", style: TextStyle(fontSize: 9, color: Colors.grey)),
//                       ],
//                     )
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildPendingWithdrawalsSection() {
//     return Container(
//       decoration: _cardDecoration(),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Container(
//             padding: const EdgeInsets.all(AppSpacing.lg),
//             color: AppColors.surfaceSubtle,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("Pending Seller Withdrawals", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.ink)),
//                     Text("Review and authorize financial payouts", style: AppText.caption),
//                   ],
//                 ),
//                 _statusPill("${_mockPayouts.length} PENDING"),
//               ],
//             ),
//           ),
//           const Divider(height: 1),
//           if (_mockPayouts.isEmpty)
//             _emptyState(icon: Icons.inbox_outlined, message: "No pending payouts")
//           else
//             ListView.separated(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: _mockPayouts.length,
//               separatorBuilder: (context, index) => const Divider(height: 1),
//               itemBuilder: (context, index) {
//                 final item = _mockPayouts[index];
//                 return Padding(
//                   padding: const EdgeInsets.all(AppSpacing.lg),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Container(
//                             width: 44,
//                             height: 44,
//                             decoration: BoxDecoration(color: AppColors.surfaceSubtle, borderRadius: BorderRadius.circular(AppRadius.md)),
//                             child: const Icon(Icons.account_balance, color: AppColors.primary),
//                           ),
//                           const SizedBox(width: AppSpacing.lg),
//                           Expanded(
//                             child: Column(
//                               crossAxisAlignment: CrossAxisAlignment.start,
//                               children: [
//                                 Row(
//                                   children: [
//                                     Expanded(
//                                       child: Text(
//                                         item["vendor"],
//                                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.ink),
//                                         maxLines: 1,
//                                         overflow: TextOverflow.ellipsis,
//                                       ),
//                                     ),
//                                     const SizedBox(width: AppSpacing.sm),
//                                     Container(
//                                       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
//                                       decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
//                                       child: Text(
//                                         item["id"],
//                                         style: TextStyle(fontSize: 8, color: Colors.grey.shade700, fontWeight: FontWeight.bold),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const SizedBox(height: AppSpacing.xs),
//                                 Text(
//                                   item["amount"],
//                                   style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
//                                 ),
//                                 const SizedBox(height: AppSpacing.xs),
//                                 Text(
//                                   "Request date: ${item['date']} • Method: ${item['method']}",
//                                   style: const TextStyle(fontSize: 9, color: Colors.grey),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: AppSpacing.md),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: SizedBox(
//                               height: 36,
//                               child: OutlinedButton(
//                                 style: OutlinedButton.styleFrom(
//                                   side: const BorderSide(color: AppColors.outline),
//                                   foregroundColor: AppColors.primary,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                                   padding: EdgeInsets.zero,
//                                 ),
//                                 onPressed: () => _showSuccess("Opening chat with ${item['vendor']}"),
//                                 child: const Text("Contact", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: AppSpacing.sm),
//                           Expanded(
//                             child: SizedBox(
//                               height: 36,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.dangerBg,
//                                   foregroundColor: AppColors.danger,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                                   padding: EdgeInsets.zero,
//                                   elevation: 0,
//                                 ),
//                                 onPressed: () => _confirmAndRemove(
//                                   title: "Disapprove payout?",
//                                   message: "${item['vendor']} will be notified that this payout was disapproved.",
//                                   confirmLabel: "Disapprove",
//                                   confirmColor: AppColors.danger,
//                                   onConfirmed: () {
//                                     setState(() => _mockPayouts.removeAt(index));
//                                     _showSuccess("Payout request disapproved.");
//                                   },
//                                 ),
//                                 child: const Text("Disapprove", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                           ),
//                           const SizedBox(width: AppSpacing.sm),
//                           Expanded(
//                             child: SizedBox(
//                               height: 36,
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primary,
//                                   foregroundColor: Colors.white,
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.sm)),
//                                   padding: EdgeInsets.zero,
//                                   elevation: 0,
//                                 ),
//                                 onPressed: () {
//                                   setState(() => _mockPayouts.removeAt(index));
//                                   _showSuccess("Payout approved successfully!");
//                                 },
//                                 child: const Text("Approve", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 );
//               },
//             )
//         ],
//       ),
//     );
//   }
//
//   /// Destructive actions (disapprove/reject) now confirm first instead of
//   /// removing the row on a single tap — a stray tap on a payout list no
//   /// longer silently disapproves someone's withdrawal.
//   Future<void> _confirmAndRemove({
//     required String title,
//     required String message,
//     required String confirmLabel,
//     required Color confirmColor,
//     required VoidCallback onConfirmed,
//   }) async {
//     final confirmed = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
//         title: Text(title),
//         content: Text(message),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
//           FilledButton(
//             style: FilledButton.styleFrom(backgroundColor: confirmColor),
//             onPressed: () => Navigator.pop(context, true),
//             child: Text(confirmLabel),
//           ),
//         ],
//       ),
//     );
//     if (confirmed == true) onConfirmed();
//   }
//
//   Widget _buildRecentOrdersSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text("Live Stream: Recent Orders", style: AppText.sectionTitle),
//             TextButton(
//               style: TextButton.styleFrom(foregroundColor: AppColors.primary),
//               onPressed: () => setState(() => _currentIndex = 11),
//               child: const Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text("View ledger", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                   SizedBox(width: 4),
//                   Icon(Icons.arrow_forward, size: 14),
//                 ],
//               ),
//             )
//           ],
//         ),
//         const SizedBox(height: AppSpacing.sm),
//         if (_mockOrders.isEmpty)
//           Container(
//             width: double.infinity,
//             decoration: _cardDecoration(),
//             child: _emptyState(icon: Icons.receipt_long_outlined, message: "No recent orders"),
//           )
//         else
//           ..._mockOrders.map((order) {
//             final statusStyle = StatusStyle.of(order["status"] as String);
//             return Padding(
//               padding: const EdgeInsets.only(bottom: AppSpacing.md),
//               child: Container(
//                 width: double.infinity,
//                 decoration: _cardDecoration(),
//                 padding: const EdgeInsets.all(AppSpacing.lg),
//                 child: Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Container(
//                       width: 48,
//                       height: 48,
//                       decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.md)),
//                       child: const Icon(Icons.headphones, color: AppColors.primary),
//                     ),
//                     const SizedBox(width: AppSpacing.lg),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   order["product"],
//                                   style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                 ),
//                               ),
//                               const SizedBox(width: AppSpacing.sm),
//                               _statusPill(order["status"], fg: statusStyle.fg, bg: statusStyle.bg),
//                             ],
//                           ),
//                           const SizedBox(height: 2),
//                           Text("ID: ${order['id']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
//                           const SizedBox(height: AppSpacing.sm),
//                           Wrap(
//                             spacing: AppSpacing.lg,
//                             runSpacing: AppSpacing.xs,
//                             crossAxisAlignment: WrapCrossAlignment.center,
//                             children: [
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(Icons.store, color: Colors.grey, size: 14),
//                                   const SizedBox(width: 4),
//                                   const Text("Seller: ", style: AppText.caption),
//                                   Text(order["seller"], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
//                                 ],
//                               ),
//                               Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(Icons.person, color: Colors.grey, size: 14),
//                                   const SizedBox(width: 4),
//                                   const Text("Buyer: ", style: AppText.caption),
//                                   Text(order["buyer"], style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.ink)),
//                                 ],
//                               ),
//                             ],
//                           ),
//                           const Divider(height: 24),
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(order["amount"], style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
//                               TextButton(
//                                 style: TextButton.styleFrom(foregroundColor: AppColors.primary, padding: EdgeInsets.zero, minimumSize: Size.zero),
//                                 onPressed: () => _showSuccess("Contacting seller..."),
//                                 child: const Text("Contact seller", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                               )
//                             ],
//                           )
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }).toList(),
//       ],
//     );
//   }
//
//   Widget _buildListingApprovalsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             const Text("Curated Queue: Listing Approvals", style: AppText.sectionTitle),
//             _statusPill("${_mockListings.length} New", fg: AppColors.danger, bg: AppColors.dangerBg),
//           ],
//         ),
//         const SizedBox(height: AppSpacing.md),
//         if (_mockListings.isEmpty)
//           Container(
//             width: double.infinity,
//             decoration: _cardDecoration(),
//             child: _emptyState(icon: Icons.checklist_rtl_outlined, message: "No pending listings"),
//           )
//         else
//           LayoutBuilder(
//             builder: (context, constraints) {
//               final isNarrow = constraints.maxWidth < 500;
//               final cards = _mockListings.map((listing) {
//                 return Container(
//                   decoration: _cardDecoration(),
//                   padding: const EdgeInsets.all(AppSpacing.md),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Container(
//                         height: 100,
//                         decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(AppRadius.sm)),
//                         alignment: Alignment.center,
//                         child: Icon(listing["icon"], color: AppColors.primary, size: 36),
//                       ),
//                       const SizedBox(height: AppSpacing.sm),
//                       Text(
//                         listing["title"],
//                         style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                       ),
//                       Text("Requested by: ${listing['vendor']}", style: const TextStyle(fontSize: 10, color: Colors.grey)),
//                       const SizedBox(height: AppSpacing.md),
//                       SizedBox(
//                         height: 38,
//                         child: Row(
//                           children: [
//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.dangerBg,
//                                   foregroundColor: AppColors.danger,
//                                   elevation: 0,
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
//                                 ),
//                                 onPressed: () => _confirmAndRemove(
//                                   title: "Reject listing?",
//                                   message: "${listing['vendor']} will be notified that \"${listing['title']}\" was rejected.",
//                                   confirmLabel: "Reject",
//                                   confirmColor: AppColors.danger,
//                                   onConfirmed: () {
//                                     setState(() => _mockListings.remove(listing));
//                                     _showSuccess("${listing['title']} rejected.");
//                                   },
//                                 ),
//                                 child: const Text("Reject", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                               ),
//                             ),
//                             const SizedBox(width: AppSpacing.sm),
//                             Expanded(
//                               child: ElevatedButton(
//                                 style: ElevatedButton.styleFrom(
//                                   backgroundColor: AppColors.primary,
//                                   foregroundColor: Colors.white,
//                                   elevation: 0,
//                                   padding: const EdgeInsets.symmetric(vertical: 8),
//                                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
//                                 ),
//                                 onPressed: () {
//                                   setState(() => _mockListings.remove(listing));
//                                   _showSuccess("${listing['title']} approved!");
//                                 },
//                                 child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
//                               ),
//                             )
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 );
//               }).toList();
//
//               return isNarrow
//                   ? Column(
//                 children: cards.asMap().entries.map((entry) {
//                   return Column(
//                     children: [
//                       entry.value,
//                       if (entry.key < cards.length - 1) const SizedBox(height: AppSpacing.lg),
//                     ],
//                   );
//                 }).toList(),
//               )
//                   : Row(
//                 children: cards.asMap().entries.map((entry) {
//                   return Expanded(
//                     child: Row(
//                       children: [
//                         Expanded(child: entry.value),
//                         if (entry.key < cards.length - 1) const SizedBox(width: AppSpacing.lg),
//                       ],
//                     ),
//                   );
//                 }).toList(),
//               );
//             },
//           ),
//       ],
//     );
//   }
//
//   Widget _buildNewsSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text("News & Global Insights", style: AppText.sectionTitle),
//         const SizedBox(height: AppSpacing.md),
//         Container(
//           decoration: _cardDecoration(),
//           clipBehavior: Clip.antiAlias,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: 140,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [AppColors.primary.withOpacity(0.85), AppColors.primary.withOpacity(0.4)],
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: const Icon(Icons.newspaper, color: Colors.white, size: 44),
//               ),
//               const Padding(
//                 padding: EdgeInsets.all(AppSpacing.lg),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       "FUTURE-PROOFING COMMERCE",
//                       style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 0.6),
//                     ),
//                     SizedBox(height: AppSpacing.xs),
//                     Text(
//                       "Future-proofing commerce: the rise of hybrid supply chains.",
//                       style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.ink),
//                     ),
//                     SizedBox(height: AppSpacing.sm),
//                     Text(
//                       "As global markets evolve, hybrid supply chains are emerging as the new standard for resilient commerce.",
//                       style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
//                     ),
//                   ],
//                 ),
//               )
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ============================================================================
// // SPARKLINE PAINTER
// // ============================================================================
//
// class SparklinePainter extends CustomPainter {
//   final List<double> data;
//
//   SparklinePainter({required this.data});
//
//   @override
//   void paint(Canvas canvas, Size size) {
//     if (data.length < 2) return;
//
//     final paint = Paint()
//       ..color = AppColors.primary
//       ..strokeWidth = 2
//       ..style = PaintingStyle.stroke
//       ..strokeCap = StrokeCap.round;
//
//     final path = Path();
//
//     final maxValue = data.reduce((a, b) => a > b ? a : b);
//     final minValue = data.reduce((a, b) => a < b ? a : b);
//     final range = maxValue - minValue;
//
//     const padding = 8.0;
//     final usableHeight = size.height - padding * 2;
//     final usableWidth = size.width - padding * 2;
//     final stepX = usableWidth / (data.length - 1);
//
//     final points = <Offset>[];
//     for (int i = 0; i < data.length; i++) {
//       final x = padding + i * stepX;
//       final y = padding + usableHeight - ((data[i] - minValue) / (range == 0 ? 1 : range)) * usableHeight;
//       points.add(Offset(x, y));
//       if (i == 0) {
//         path.moveTo(x, y);
//       } else {
//         path.lineTo(x, y);
//       }
//     }
//
//     // Gradient fill under the line
//     final fillPath = Path.from(path)
//       ..lineTo(points.last.dx, size.height - padding)
//       ..lineTo(points.first.dx, size.height - padding)
//       ..close();
//
//     final gradientPaint = Paint()
//       ..shader = LinearGradient(
//         begin: Alignment.topCenter,
//         end: Alignment.bottomCenter,
//         colors: [AppColors.primary.withOpacity(0.25), AppColors.primary.withOpacity(0.0)],
//       ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
//
//     canvas.drawPath(fillPath, gradientPaint);
//     canvas.drawPath(path, paint);
//
//     final pointPaint = Paint()
//       ..color = AppColors.primary
//       ..style = PaintingStyle.fill;
//     final pointHalo = Paint()..color = Colors.white;
//
//     for (final p in points) {
//       canvas.drawCircle(p, 4, pointHalo);
//       canvas.drawCircle(p, 3, pointPaint);
//     }
//   }
//
//   @override
//   bool shouldRepaint(SparklinePainter oldDelegate) => oldDelegate.data != data;
// }
//
// // ============================================================================
// // USAGE EXAMPLE
// // ============================================================================
//
// /*
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Admin Dashboard',
//       theme: ThemeData(
//         colorSchemeSeed: AppColors.primary,
//         fontFamily: 'Manrope',
//         useMaterial3: true,
//       ),
//       home: const Scaffold(
//         backgroundColor: AppColors.surfaceSubtle,
//         body: AdminDashboard(),
//       ),
//     );
//   }
// }
// */
//
// // ============================================================================
// // END OF WIDGET
// // ============================================================================