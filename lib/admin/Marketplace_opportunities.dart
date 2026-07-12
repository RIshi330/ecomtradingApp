import 'dart:async';

import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

/// Models mirroring the JSON shapes returned by the marketplace_opportunity
/// PHP API (get_opportunity_filters, get_featured_opportunities,
/// get_opportunity_categories, get_opportunity_skills,
/// get_opportunity_counts, get_all_opportunities).
///
/// Place this file at: lib/models/marketplace_opportunity_models.dart
/// (Database imports it as '../models/marketplace_opportunity_models.dart' —
/// adjust the import path if you put it somewhere else.)

class MarketplaceVendor {
  final String? id;
  final String? name;
  final String? email;
  final String? mobile;
  final String? whatsapp;
  final String? companyName;
  final String? companyLogo;
  final String? website;
  final String? city;
  final String? state;
  final String? country;
  final String? profilePic;
  final String? verified;
  final String? verify;

  MarketplaceVendor({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.whatsapp,
    this.companyName,
    this.companyLogo,
    this.website,
    this.city,
    this.state,
    this.country,
    this.profilePic,
    this.verified,
    this.verify,
  });

  /// Best available display name for "Posted by ..."
  String get displayName {
    if (companyName != null && companyName!.trim().isNotEmpty) return companyName!;
    if (name != null && name!.trim().isNotEmpty) return name!;
    return 'Unknown';
  }

  /// Best available avatar image (falls back to company logo)
  String? get avatarUrl {
    if (profilePic != null && profilePic!.trim().isNotEmpty) return profilePic;
    if (companyLogo != null && companyLogo!.trim().isNotEmpty) return companyLogo;
    return null;
  }

  factory MarketplaceVendor.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketplaceVendor();
    return MarketplaceVendor(
      id: json['id']?.toString(),
      name: json['name']?.toString(),
      email: json['email']?.toString(),
      mobile: json['mobile']?.toString(),
      whatsapp: json['whatsapp']?.toString(),
      companyName: json['company_name']?.toString(),
      companyLogo: json['company_logo']?.toString(),
      website: json['website']?.toString(),
      city: json['city']?.toString(),
      state: json['state']?.toString(),
      country: json['country']?.toString(),
      profilePic: json['profile_pic']?.toString(),
      verified: json['verified']?.toString(),
      verify: json['verify']?.toString(),
    );
  }
}

class MarketplaceCompensation {
  final String? payoutType;
  final String? paymentFrequency;
  final String? amount;
  final Map<String, dynamic> raw;

  MarketplaceCompensation({
    this.payoutType,
    this.paymentFrequency,
    this.amount,
    this.raw = const {},
  });

  factory MarketplaceCompensation.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketplaceCompensation();
    return MarketplaceCompensation(
      payoutType: json['payout_type']?.toString(),
      paymentFrequency: json['payment_frequency']?.toString(),
      amount: (json['amount'] ?? json['payout_amount'])?.toString(),
      raw: json,
    );
  }

  String? get label {
    if (payoutType == null) return null;
    final freq = paymentFrequency != null && paymentFrequency!.isNotEmpty
        ? ' / $paymentFrequency'
        : '';
    final amt = amount != null && amount!.isNotEmpty ? '$amount ' : '';
    return '$amt$payoutType$freq';
  }
}

class MarketplaceMedia {
  final String? coverImage;
  final String? videoUrl;
  final String? attachment;
  final List<String> gallery;

  MarketplaceMedia({
    this.coverImage,
    this.videoUrl,
    this.attachment,
    this.gallery = const [],
  });

  factory MarketplaceMedia.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketplaceMedia();
    return MarketplaceMedia(
      coverImage: json['cover_image']?.toString(),
      videoUrl: json['video_url']?.toString(),
      attachment: json['attachment']?.toString(),
      gallery: (json['gallery'] as List? ?? []).map((e) => e.toString()).toList(),
    );
  }
}

class MarketplaceOpportunity {
  final String id; // encrypted id from server, use as opaque identifier
  final String? title;
  final String? type;
  final String? industry;
  final String? location;
  final String? opportunityFor;
  final String? categoryTitle;
  final String? catId;
  final String? fullDescription;
  final String? skillsRequired;
  final List<String> skillsArray;
  final int label; // 1 Featured, 2 Sponsored, 3 Premium
  final String? labelName;
  final int totalApplications;
  final String? createdAt;
  final MarketplaceVendor vendor;
  final MarketplaceCompensation compensation;
  final MarketplaceMedia media;
  final Map<String, dynamic> raw;

  MarketplaceOpportunity({
    required this.id,
    this.title,
    this.type,
    this.industry,
    this.location,
    this.opportunityFor,
    this.categoryTitle,
    this.catId,
    this.fullDescription,
    this.skillsRequired,
    this.skillsArray = const [],
    this.label = 0,
    this.labelName,
    this.totalApplications = 0,
    this.createdAt,
    MarketplaceVendor? vendor,
    MarketplaceCompensation? compensation,
    MarketplaceMedia? media,
    this.raw = const {},
  })  : vendor = vendor ?? MarketplaceVendor(),
        compensation = compensation ?? MarketplaceCompensation(),
        media = media ?? MarketplaceMedia();

  /// Builds one item from the shape used both by get_all_opportunities and
  /// get_featured_opportunities:
  /// { "opportunity": {...}, "vendor": {...}, "compensation": {...},
  ///   "application": {...}, "media": {...} }
  factory MarketplaceOpportunity.fromApi(Map<String, dynamic> item) {
    final opp = Map<String, dynamic>.from(item['opportunity'] ?? {});

    // created_at / date_added — column name wasn't shown in the provided
    // PHP, so we try a couple of common possibilities and fall back to null.
    final createdAtRaw = opp['created_at'] ??
        opp['date_added'] ??
        opp['created'] ??
        opp['posted_at'];

    return MarketplaceOpportunity(
      id: opp['id']?.toString() ?? '',
      title: opp['title']?.toString(),
      type: opp['type']?.toString(),
      industry: opp['industry']?.toString(),
      location: opp['location']?.toString(),
      opportunityFor: opp['opportunity_for']?.toString(),
      categoryTitle: opp['category_title']?.toString(),
      catId: opp['cat_id']?.toString(),
      fullDescription: opp['full_description']?.toString(),
      skillsRequired: opp['skills_required']?.toString(),
      skillsArray:
      (opp['skills_array'] as List? ?? []).map((e) => e.toString()).toList(),
      label: int.tryParse(opp['label']?.toString() ?? '') ?? 0,
      labelName: opp['label_name']?.toString(),
      totalApplications:
      int.tryParse(opp['total_applications']?.toString() ?? '') ?? 0,
      createdAt: createdAtRaw?.toString(),
      vendor: MarketplaceVendor.fromJson(
          item['vendor'] != null ? Map<String, dynamic>.from(item['vendor']) : null),
      compensation: MarketplaceCompensation.fromJson(item['compensation'] != null
          ? Map<String, dynamic>.from(item['compensation'])
          : null),
      media: MarketplaceMedia.fromJson(
          item['media'] != null ? Map<String, dynamic>.from(item['media']) : null),
      raw: opp,
    );
  }

  /// Display category: prefer the joined category_title, fall back to type
  String get displayCategory {
    if (categoryTitle != null && categoryTitle!.trim().isNotEmpty) return categoryTitle!;
    if (type != null && type!.trim().isNotEmpty) return type!;
    return 'Opportunity';
  }

  /// Human readable relative time, e.g. "2h ago". Returns null if unknown.
  String? get timeAgo {
    if (createdAt == null) return null;
    final dt = DateTime.tryParse(createdAt!);
    if (dt == null) return null;
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 30) return '${diff.inDays}d ago';
    return '${(diff.inDays / 30).floor()}mo ago';
  }
}

class MarketplaceFilters {
  final List<String> types;
  final List<String> industries;
  final List<String> locations;
  final List<String> opportunityFor;
  final List<Map<String, dynamic>> categories; // {id, category_title}
  final List<Map<String, dynamic>> labels; // {id, name}
  final List<String> payoutTypes;
  final List<String> paymentFrequency;
  final List<String> priceModels;

  MarketplaceFilters({
    this.types = const [],
    this.industries = const [],
    this.locations = const [],
    this.opportunityFor = const [],
    this.categories = const [],
    this.labels = const [],
    this.payoutTypes = const [],
    this.paymentFrequency = const [],
    this.priceModels = const [],
  });

  factory MarketplaceFilters.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MarketplaceFilters();

    List<String> strList(dynamic v) =>
        (v as List? ?? []).map((e) => e.toString()).toList();
    List<Map<String, dynamic>> mapList(dynamic v) =>
        (v as List? ?? []).map((e) => Map<String, dynamic>.from(e)).toList();

    return MarketplaceFilters(
      types: strList(json['types']),
      industries: strList(json['industries']),
      locations: strList(json['locations']),
      opportunityFor: strList(json['opportunity_for']),
      categories: mapList(json['categories']),
      labels: mapList(json['labels']),
      payoutTypes: strList(json['payout_types']),
      paymentFrequency: strList(json['payment_frequency']),
      priceModels: strList(json['price_models']),
    );
  }
}
/// Flutter implementation of the Marketplace Opportunities screen.
/// Calls the marketplace_opportunity API the same way
/// BusinessUserProfileScreen calls community_admin_profile.php —
/// Database().getData({'action': ...}, endpoint: _opportunityEndpoint) —
/// no changes to Database itself required.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  // Endpoint that hosts all marketplace opportunity actions used below
  // (get_opportunity_filters, get_featured_opportunities,
  // get_opportunity_categories, get_opportunity_skills,
  // get_opportunity_counts, get_all_opportunities).
  // ADJUST this to the actual path of the PHP file on your server.
  static const String _opportunityEndpoint = 'new_apis/marketplace_opportunity_api.php';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _searchDebounce;

  bool _isFilterVisible = false;

  // ----- Featured -----
  bool _loadingFeatured = true;
  String? _featuredError;
  List<MarketplaceOpportunity> _featured = [];

  // ----- Filters -----
  bool _loadingFilters = true;
  MarketplaceFilters _filters = MarketplaceFilters();
  String? _selectedCategoryId;
  String? _selectedLabel; // '1' Featured, '2' Sponsored, '3' Premium

  // ----- All opportunities (paginated) -----
  bool _loadingList = true;
  bool _loadingMore = false;
  String? _listError;
  List<MarketplaceOpportunity> _opportunities = [];
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalRecords = 0;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadFeatured();
    _loadOpportunities(reset: true);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200 &&
          !_loadingMore &&
          !_loadingList &&
          _currentPage < _totalPages) {
        _loadOpportunities(reset: false);
      }
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------- Data loading ----------------------
  // Every call below mirrors BusinessUserProfileScreen: build the postBody
  // with 'action', hit Database().getData(postBody, endpoint: ...), then
  // check response['success'] and read response['data'].

  Future<void> _loadFilters() async {
    setState(() => _loadingFilters = true);

    final response = await Database().getData({
      'action': 'get_opportunity_filters',
    }, endpoint: _opportunityEndpoint);

    if (!mounted) return;
    setState(() {
      if (response['success'] == true && response['data'] != null) {
        _filters = MarketplaceFilters.fromJson(
            Map<String, dynamic>.from(response['data']));
      }
      _loadingFilters = false;
    });
  }

  Future<void> _loadFeatured() async {
    setState(() {
      _loadingFeatured = true;
      _featuredError = null;
    });

    final response = await Database().getData({
      'action': 'get_featured_opportunities',
      'limit': 10,
    }, endpoint: _opportunityEndpoint);

    if (!mounted) return;
    setState(() {
      _loadingFeatured = false;
      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        _featured = (data['featured_opportunities'] as List? ?? [])
            .map((e) => MarketplaceOpportunity.fromApi(Map<String, dynamic>.from(e)))
            .toList();
      } else {
        _featuredError = response['message']?.toString() ?? 'Failed to load featured opportunities';
      }
    });
  }

  Future<void> _loadOpportunities({required bool reset}) async {
    if (reset) {
      setState(() {
        _loadingList = true;
        _listError = null;
        _currentPage = 1;
      });
    } else {
      setState(() => _loadingMore = true);
    }

    final page = reset ? 1 : _currentPage + 1;
    final search = _searchController.text.trim();

    final postBody = <String, dynamic>{
      'action': 'get_all_opportunities',
      'page': page,
      'limit': 10,
    };
    if (_selectedCategoryId != null) postBody['category_id'] = _selectedCategoryId;
    if (_selectedLabel != null) postBody['label'] = _selectedLabel;
    if (search.isNotEmpty) postBody['search'] = search;

    final response = await Database().getData(postBody, endpoint: _opportunityEndpoint);

    if (!mounted) return;

    setState(() {
      _loadingList = false;
      _loadingMore = false;

      if (response['success'] == true && response['data'] != null) {
        final data = Map<String, dynamic>.from(response['data']);
        final list = (data['opportunities'] as List? ?? [])
            .map((e) => MarketplaceOpportunity.fromApi(Map<String, dynamic>.from(e)))
            .toList();

        _opportunities = reset ? list : [..._opportunities, ...list];
        _currentPage = int.tryParse(data['current_page']?.toString() ?? '') ?? page;
        _totalPages = int.tryParse(data['total_pages']?.toString() ?? '') ?? 1;
        _totalRecords =
            int.tryParse(data['total_records']?.toString() ?? '') ?? _opportunities.length;
      } else {
        if (reset) _opportunities = [];
        _listError = response['message']?.toString() ?? 'Failed to load opportunities';
      }
    });
  }

  Future<void> _refreshAll() async {
    await Future.wait([
      _loadFeatured(),
      _loadOpportunities(reset: true),
    ]);
  }

  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      _loadOpportunities(reset: true);
    });
  }

  void _applyFilters() {
    setState(() => _isFilterVisible = false);
    _loadOpportunities(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: _refreshAll,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  SliverToBoxAdapter(child: _buildFeaturedSection()),
                  SliverToBoxAdapter(child: _buildAllOpportunitiesSection()),
                  if (_loadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 80)),
                ],
              ),
            ),
            if (_isFilterVisible) _buildFilterModal(),
          ],
        ),
      ),
    );
  }

  // ---------------------- Search Bar ----------------------
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFBDC9C8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF6E7979), size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                decoration: const InputDecoration(
                  hintText: 'Search opportunities...',
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFFBDC9C8)),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                ),
                style: const TextStyle(fontSize: 16),
              ),
            ),
            InkWell(
              onTap: () => setState(() => _isFilterVisible = !_isFilterVisible),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: Icon(
                  Icons.tune,
                  color: (_selectedCategoryId != null || _selectedLabel != null)
                      ? const Color(0xFF008080)
                      : const Color(0xFF6E7979),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- Featured Section ----------------------
  Widget _buildFeaturedSection() {
    if (!_loadingFeatured && _featured.isEmpty && _featuredError == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Featured',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF181C1E)),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 280,
          child: _loadingFeatured
              ? const Center(child: CircularProgressIndicator())
              : _featuredError != null
              ? Center(child: Text(_featuredError!, style: const TextStyle(color: Colors.red)))
              : ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _featured.length,
            separatorBuilder: (_, __) => const SizedBox(width: 16),
            itemBuilder: (context, index) => _buildFeaturedCard(_featured[index]),
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(MarketplaceOpportunity item) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tapped: ${item.title ?? 'Opportunity'}')),
        );
      },
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBDC9C8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: item.media.coverImage != null
                      ? Image.network(
                    item.media.coverImage!,
                    height: 160,
                    width: 280,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _imagePlaceholder(160, 280),
                  )
                      : _imagePlaceholder(160, 280),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF008080),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          offset: const Offset(0, 2),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.star, color: Colors.white, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          item.labelName ?? 'Featured',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.displayCategory.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF006565),
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.title ?? 'Untitled opportunity',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF181C1E)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------- All Opportunities Section ----------------------
  Widget _buildAllOpportunitiesSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'All Opportunities',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF181C1E)),
              ),
              Text(
                '$_totalRecords Results',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF3E4949),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_loadingList)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_listError != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Column(
                  children: [
                    Text(_listError!, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _loadOpportunities(reset: true),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (_opportunities.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: Center(child: Text('No opportunities found')),
              )
            else
              ..._opportunities.map((item) => _buildOpportunityCard(item)),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard(MarketplaceOpportunity item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.media.coverImage != null
                    ? Image.network(
                  item.media.coverImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _imagePlaceholder(80, 80),
                )
                    : _imagePlaceholder(80, 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFD9E3F9),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.displayCategory,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF006565)),
                          ),
                        ),
                        if (item.timeAgo != null)
                          Text(
                            item.timeAgo!,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Color(0xFF3E4949)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.title ?? 'Untitled opportunity',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF181C1E)),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: const Color(0xFFE0E3E5),
                          backgroundImage:
                          item.vendor.avatarUrl != null ? NetworkImage(item.vendor.avatarUrl!) : null,
                          onBackgroundImageError: (_, __) {},
                          child: item.vendor.avatarUrl == null
                              ? const Icon(Icons.person, size: 12, color: Color(0xFF6E7979))
                              : null,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text.rich(
                            TextSpan(
                              text: 'Posted by ',
                              style: const TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                              children: [
                                TextSpan(
                                  text: item.vendor.displayName,
                                  style: const TextStyle(fontWeight: FontWeight.w500, color: Color(0xFF181C1E)),
                                ),
                              ],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFBDC9C8), height: 1),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.group, size: 18, color: Color(0xFF6E7979)),
                  const SizedBox(width: 4),
                  Text(
                    '${item.totalApplications} Applicants',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF181C1E)),
                  ),
                ],
              ),
              if (item.compensation.label != null)
                Flexible(
                  child: Text(
                    item.compensation.label!,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF006565)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder(double height, double width) {
    return Container(
      height: height,
      width: width,
      color: const Color(0xFFE0E3E5),
      child: const Icon(Icons.broken_image, color: Color(0xFF6E7979)),
    );
  }

  // ---------------------- Filter Modal (Bottom Sheet) ----------------------
  Widget _buildFilterModal() {
    return GestureDetector(
      onTap: () => setState(() => _isFilterVisible = false),
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.bottomCenter,
            child: StatefulBuilder(
              builder: (context, setModalState) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  height: MediaQuery.of(context).size.height * 0.6,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: 48,
                        height: 4,
                        decoration: BoxDecoration(
                          color: const Color(0xFFBDC9C8),
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Filters', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                            IconButton(
                              onPressed: () => setState(() => _isFilterVisible = false),
                              icon: const Icon(Icons.close),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: _loadingFilters
                            ? const Center(child: CircularProgressIndicator())
                            : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'CATEGORY',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3E4949),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildFilterChip(
                                    'All',
                                    _selectedCategoryId == null,
                                        () => setModalState(() => _selectedCategoryId = null),
                                  ),
                                  ..._filters.categories.map((cat) {
                                    final id = cat['id']?.toString() ?? '';
                                    final title = cat['category_title']?.toString() ?? '';
                                    return _buildFilterChip(
                                      title,
                                      _selectedCategoryId == id,
                                          () => setModalState(() => _selectedCategoryId = id),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'LABEL',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF3E4949),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  _buildFilterChip(
                                    'All',
                                    _selectedLabel == null,
                                        () => setModalState(() => _selectedLabel = null),
                                  ),
                                  ..._filters.labels.map((lbl) {
                                    final id = lbl['id']?.toString() ?? '';
                                    final name = lbl['name']?.toString() ?? '';
                                    return _buildFilterChip(
                                      name,
                                      _selectedLabel == id,
                                          () => setModalState(() => _selectedLabel = id),
                                    );
                                  }),
                                ],
                              ),
                              const SizedBox(height: 32),
                              Row(
                                children: [
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setModalState(() {
                                          _selectedCategoryId = null;
                                          _selectedLabel = null;
                                        });
                                      },
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Color(0xFFBDC9C8)),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                      ),
                                      child: const Text('Clear'),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    flex: 2,
                                    child: ElevatedButton(
                                      onPressed: _applyFilters,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF008080),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        padding: const EdgeInsets.symmetric(vertical: 16),
                                        elevation: 0,
                                      ),
                                      child: const Text(
                                        'Apply Filters',
                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 32),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, bool selected, VoidCallback onTap) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.white,
      selectedColor: const Color(0xFF008080).withOpacity(0.2),
      side: BorderSide(color: selected ? const Color(0xFF008080) : const Color(0xFFBDC9C8)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      labelStyle: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: selected ? const Color(0xFF008080) : const Color(0xFF3E4949),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    );
  }
}