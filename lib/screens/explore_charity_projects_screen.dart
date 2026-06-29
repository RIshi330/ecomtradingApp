import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import '../index.dart';

class ExploreCharityProjectsScreen extends StatefulWidget {
  final bool isEmbedded;
  const ExploreCharityProjectsScreen({super.key, this.isEmbedded = false});

  @override
  State<ExploreCharityProjectsScreen> createState() =>
      _ExploreCharityProjectsScreenState();
}

class _ExploreCharityProjectsScreenState
    extends State<ExploreCharityProjectsScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _urgentOnly = false;
  bool _criticalOnly = false;
  bool _isLoading = true;
  List<dynamic> _apiProjects = [];
  Map<String, int> _categoriesCount = {};

  final Color primaryTeal = const Color(0xFF006565);
  final Color lightTeal = const Color(0xFFD4E6E5);
  final Color bgLight = const Color(0xFFFCF9F8);

  @override
  void initState() {
    super.initState();
    _fetchProjects();
  }

  Future<void> _fetchProjects() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final response = await Database().getJsonData({
        'action': 'get_charities',
        'category': _selectedCategory == 'All' ? '' : _selectedCategory,
      }, endpoint: 'new_apis/donation_shop_api.php');

      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _apiProjects = response['data']['charities'] ?? [];
          final cats = response['data']['categories'] as Map?;
          if (cats != null) {
            _categoriesCount = Map<String, int>.from(cats);
          }
        });
      }
    } catch (e) {
      debugPrint("Error fetching charities: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<dynamic> get _filteredProjects {
    return _apiProjects.where((proj) {
      final title = (proj['fundraiser_title'] ?? '').toString().toLowerCase();
      final desc = (proj['fundraiser_desc'] ?? '').toString().toLowerCase();
      final category = (proj['category'] ?? '').toString().toLowerCase();
      final query = _searchQuery.toLowerCase();

      final matchesSearch = title.contains(query) || desc.contains(query) || category.contains(query);

      // Urgency filter simulation based on progress or type if badge not directly mapped
      final isUrgentBadge = proj['expectation_type'] == 'goods'; // simulate badge logic
      final isCriticalBadge = proj['expectation_type'] == 'cash';

      final matchesUrgent = !_urgentOnly || isUrgentBadge;
      final matchesCritical = !_criticalOnly || isCriticalBadge;

      return matchesSearch && matchesUrgent && matchesCritical;
    }).toList();
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Filters",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1B1B)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.grey),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  const Text("CAMPAIGN FILTERS",
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: Colors.grey)),
                  const SizedBox(height: 12),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Goods Requests Only",
                        style: TextStyle(fontSize: 14)),
                    value: _urgentOnly,
                    onChanged: (val) {
                      setModalState(() => _urgentOnly = val ?? false);
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  CheckboxListTile(
                    activeColor: const Color(0xFF006565),
                    title: const Text("Cash Fundraisers Only",
                        style: TextStyle(fontSize: 14)),
                    value: _criticalOnly,
                    onChanged: (val) {
                      setModalState(() => _criticalOnly = val ?? false);
                      setState(() {});
                    },
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006565),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Apply Filters",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = Scaffold(
      backgroundColor: bgLight,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              title: const Text("Explore Charity Projects",
                  style: TextStyle(
                      color: Color(0xFF006565), fontWeight: FontWeight.bold)),
              iconTheme: const IconThemeData(color: Color(0xFF006565)),
              elevation: 0.5,
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search & Filter header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0EDED),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: "Search items or charities...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterDrawer,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E2E1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.tune, color: Color(0xFF3E4949)),
                  ),
                ),
              ],
            ),
          ),
          // Category Chips List
          SizedBox(
            height: 30,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 16),
              children: ['All', 'Education', 'Medical', 'Emergency', 'Services']
                  .map((cat) {
                final isSelected = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: ChoiceChip(
                    label: Text(
                      cat == 'All' ? 'All Requests' : cat,
                      style: TextStyle(
                        color:
                            isSelected ? Colors.white : const Color(0xFF3E4949),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (val) {
                      setState(() {
                        _selectedCategory = cat;
                      });
                      _fetchProjects();
                    },
                    selectedColor: const Color(0xFF006565),
                    backgroundColor: const Color(0xFFEAE7E7),
                    checkmarkColor: Colors.white,
                    side: BorderSide.none,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          // Projects Grid List
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF006565)),
                  )
                : _filteredProjects.isEmpty
                    ? const Center(
                        child: Text("No charity projects matching details."))
                    : GridView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: _filteredProjects.length,
                        itemBuilder: (context, idx) {
                          final proj = _filteredProjects[idx];
                          final expType = proj['expectation_type'] ?? 'cash';
                          final goodsName = proj['goods_name']?.toString() ?? 'Community Support';
                          final isUrgent = expType == 'goods';
                          final isCritical = expType == 'cash';

                          final expAmount = double.tryParse(proj['expectation_amount']?.toString() ?? '0') ?? 0.0;
                          final raisedAmount = double.tryParse(proj['raised_amount']?.toString() ?? '0') ?? 0.0;
                          final progress = expAmount > 0 ? (raisedAmount / expAmount) : 0.0;

                          return InkWell(
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.charityProjectDetail,
                                arguments: proj),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Cover Image & Badge
                                  Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: const BorderRadius.vertical(
                                            top: Radius.circular(20)),
                                        child: (proj['image_url'] != null && proj['image_url'].toString().isNotEmpty)
                                            ? Image.network(
                                                proj['image_url'],
                                                height: 95,
                                                width: double.infinity,
                                                fit: BoxFit.cover,
                                                errorBuilder:
                                                    (context, error, stackTrace) {
                                                  return Container(
                                                    height: 95,
                                                    color: const Color(0xFF006565)
                                                        .withOpacity(0.08),
                                                    child: const Icon(Icons.image,
                                                        color: Color(0xFF006565)),
                                                  );
                                                },
                                              )
                                            : Container(
                                                height: 95,
                                                width: double.infinity,
                                                color: const Color(0xFF006565)
                                                    .withOpacity(0.08),
                                                child: Center(
                                                  child: Icon(
                                                    expType == 'cash'
                                                        ? Icons.favorite
                                                        : Icons.volunteer_activism,
                                                    size: 40,
                                                    color: const Color(0xFF006565),
                                                  ),
                                                ),
                                              ),
                                      ),
                                      if (isUrgent || isCritical)
                                        Positioned(
                                          top: 8,
                                          left: 8,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: isUrgent
                                                  ? const Color(0xFF006565)
                                                  : const Color(0xFFBA1A1A),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              isUrgent ? "URGENT" : "CRITICAL",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 8,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  // Card Info
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 6.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            proj['fundraiser_title'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF1C1B1B)),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            proj['fundraiser_desc'] ?? '',
                                            style: const TextStyle(
                                                fontSize: 11,
                                                color: Color(0xFF3E4949)),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          // Progress
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "₹${raisedAmount.toStringAsFixed(0)} raised",
                                                  style: const TextStyle(
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      color: Color(0xFF006565)),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                "${(progress * 100).toInt()}%",
                                                style: const TextStyle(
                                                    fontSize: 8,
                                                    color: Colors.grey),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            child: LinearProgressIndicator(
                                              value: progress,
                                              minHeight: 4,
                                              backgroundColor: Colors.grey[100],
                                              valueColor:
                                                  const AlwaysStoppedAnimation<
                                                      Color>(Color(0xFF006565)),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          SizedBox(
                                            width: double.infinity,
                                            height: 26,
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    const Color(0xFF006565),
                                                foregroundColor: Colors.white,
                                                elevation: 0,
                                                padding: EdgeInsets.zero,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(8)),
                                              ),
                                              onPressed: () => Navigator.pushNamed(
                                                  context,
                                                  AppRoutes.charityProjectDetail,
                                                  arguments: proj),
                                              child: Text(
                                                expType == 'cash'
                                                    ? "Donate"
                                                    : "Support",
                                                style: const TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
    return widget.isEmbedded ? content : SafeArea(child: content);
  }
}
