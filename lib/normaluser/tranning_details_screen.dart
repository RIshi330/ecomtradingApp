import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Database/Database.dart';
import '../common/payment_screen.dart';
import '../model/module_model.dart';
import 'TranningScreen.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final String trainingId;

  const TrainingDetailsScreen({
    super.key,
    required this.trainingId,
  });

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  final Database _db = Database();

  bool _isLoading = true;
  String? _errorMessage;
  TrainingDetails? _details;
  List<SimilarTraining> _similarTrainings = [];

  final List<bool> _accordionExpanded = [false, false, false];

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final Map<String, dynamic> body = {
        'action': 'getTrainingDetails',
        'id': widget.trainingId,
      };

      final result = await _db.getJsonData(body, endpoint: trainingEndpoint);

      if (result['success'] == true) {
        final data = result['data'] as Map? ?? {};
        final trainingJson = data['training'] as Map? ?? {};
        final similarList = (data['similar_trainings'] as List? ?? [])
            .map((e) => SimilarTraining.fromJson(e as Map))
            .toList();

        setState(() {
          _details = TrainingDetails.fromJson(trainingJson);
          _similarTrainings = similarList;
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = result['message']?.toString() ?? 'Failed to load details.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Training Details',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: _details != null ? _buildBottomCTA() : null,
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF006565)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(_errorMessage!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _fetchDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final d = _details!;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 240,
                width: double.infinity,
                color: const Color(0xFFEFF4FF),
                child: d.imageUrl.isNotEmpty
                    ? Image.network(
                  d.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_outlined,
                    size: 64,
                    color: Color(0xFF006565),
                  ),
                )
                    : const Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: Color(0xFF006565),
                ),
              ),
              Positioned(
                bottom: 12,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF006565),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'BESTSELLER',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  d.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, size: 18, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      d.avgRating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(${d.reviewCount} reviews)',
                      style: const TextStyle(
                        color: Color(0xFF3E4949),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFC6E9E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.videocam_outlined, size: 18, color: Color(0xFF4A6A6A)),
                      const SizedBox(width: 6),
                      Text(
                        d.mode.isNotEmpty ? d.mode : 'Online / Live Session',
                        style: const TextStyle(
                          color: Color(0xFF4A6A6A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5EEFF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        '₹${d.fee}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006565),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        '₹10,000',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Special Offer',
                        style: TextStyle(
                          color: Color(0xFF006565),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'MASTER INSTRUCTOR',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF3E4949),
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFF008080),
                        child: Icon(Icons.person, color: Colors.white, size: 32),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d.vendorName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0B1C30),
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Senior Subject Expert',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF3E4949),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'About Training',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  d.description,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF3E4949),
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFF4FF),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.calendar_today, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Training Period',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3E4949),
                                ),
                              ),
                              Text(
                                '${d.startDate} - ${d.endDate}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B1C30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Divider(height: 1, color: Color(0xFFBDC9C8)),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF008080),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.schedule, color: Colors.white, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Weekly Schedule',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF3E4949),
                                ),
                              ),
                              Text(
                                d.scheduleTime,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0B1C30),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Curriculum Breakdown',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0B1C30),
                  ),
                ),
                const SizedBox(height: 12),
                _buildAccordionItem(
                  index: 0,
                  numStr: '01',
                  title: 'Introduction & Core Foundations',
                  content: 'Understanding core concepts, domain scope, setup required for live hands-on practice, and defining industry workflows.',
                ),
                _buildAccordionItem(
                  index: 1,
                  numStr: '02',
                  title: 'In-depth Practical Deep Dive',
                  content: 'Applying strategic solutions, real-world case studies, handling edge scenarios, and team collaboration setups.',
                ),
                _buildAccordionItem(
                  index: 2,
                  numStr: '03',
                  title: 'Advanced Capstone & Delivery',
                  content: 'Building high-quality deliverables, performance evaluation, code/design review sessions, and career readiness.',
                ),
                const SizedBox(height: 28),
                if (_similarTrainings.isNotEmpty) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Similar Trainings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1C30),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text(
                          'View All',
                          style: TextStyle(color: Color(0xFF006565)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _similarTrainings.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final sim = _similarTrainings[index];
                        return _buildSimilarCard(sim);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccordionItem({
    required int index,
    required String numStr,
    required String title,
    required String content,
  }) {
    final isExpanded = _accordionExpanded[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBDC9C8)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _accordionExpanded[index] = !_accordionExpanded[index];
              });
            },
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: const Color(0xFFC6E9E9),
                    child: Text(
                      numStr,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF006565),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0B1C30),
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF3E4949),
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text(
                content,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF3E4949),
                  height: 1.4,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSimilarCard(SimilarTraining sim) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingDetailsScreen(trainingId: sim.id),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFBDC9C8)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 100,
                width: double.infinity,
                color: const Color(0xFFEFF4FF),
                child: sim.imageUrl.isNotEmpty
                    ? Image.network(
                  sim.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.school_outlined,
                    color: Color(0xFF006565),
                  ),
                )
                    : const Icon(
                  Icons.school_outlined,
                  color: Color(0xFF006565),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sim.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        sim.avgRating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₹${sim.fee}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF006565),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomCTA() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Fee',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  '₹${_details!.fee}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006565),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 20),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  if (_details == null) return;

                  // Supply default / dummy values for required fields in ModuleModel
                  final selectedModule = ModuleModel(
                    id: _details!.id,
                    title: _details!.title,
                    price: "₹${_details!.fee}",
                    discountPrice: "₹${_details!.fee}",
                    icon: Icons.school,
                    badge: 'BESTSELLER',
                    category: _details!.mode.isNotEmpty ? _details!.mode : 'Training',
                    features: const [],
                    iconName: 'school',
                    installs: '0',
                    rating: _details!.avgRating.toString(),
                  );

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentScreen(module: selectedModule),
                    ),
                  );
                },                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Enroll Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String category;
  final String mode;
  final String? badge;
  final double rating;
  final String reviews;
  final String price;
  final String? originalPrice;
  final String? savings;
  final String imageUrl;

  const CourseCard({
    super.key,
    required this.title,
    required this.category,
    required this.mode,
    this.badge,
    required this.rating,
    required this.reviews,
    required this.price,
    this.originalPrice,
    this.savings,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFBDC9C8), width: 0.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                  child: imageUrl.isEmpty
                      ? Container(
                    color: const Color(0xFFEFF4FF),
                    child: const Icon(Icons.school_outlined, color: Color(0xFF006565), size: 32),
                  )
                      : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: const Color(0xFFEFF4FF),
                      child: const Icon(Icons.broken_image_outlined, color: Color(0xFF006565)),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: Column(
                  children: [
                    _buildGlassIconButton(Icons.favorite_border),
                    const SizedBox(height: 6),
                    _buildGlassIconButton(Icons.compare_arrows),
                  ],
                ),
              ),
              if (badge != null)
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF006565).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badge!.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4E6E6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          category.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4D5D5E),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          '• $mode',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0B1C30),
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 2),
                      Text(
                        rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '($reviews)',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF3E4949),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        price,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006565),
                        ),
                      ),
                      if (originalPrice != null) ...[
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            originalPrice!,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF3E4949),
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (savings != null) ...[
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006565).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        savings!,
                        style: const TextStyle(
                          fontSize: 8.5,
                          color: Color(0xFF006565),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassIconButton(IconData icon) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 16, color: const Color(0xFF006565)),
    );
  }
}

class NavigationDrawerWidget extends StatelessWidget {
  const NavigationDrawerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF8F9FF),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFF008080),
                    child: Text('JD', style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('B2B Manager', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('Enterprise Account', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  )
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.leaderboard),
              title: const Text('Leadership'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.terminal),
              title: const Text('Tech Stack'),
              selectedTileColor: const Color(0xFF008080).withOpacity(0.1),
              selected: true,
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.gavel),
              title: const Text('Compliance'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.psychology),
              title: const Text('Soft Skills'),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.payments),
              title: const Text('Sales'),
              onTap: () {},
            ),
            const Spacer(),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'PREMIUM TIER',
                  style: TextStyle(
                    color: Color(0xFF006565),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FilterBottomSheet extends StatefulWidget {
  final List<String> modes;
  final List<String> types;
  final List<String> cities;
  final double initialMaxPrice;
  final List<String> initialModes;
  final List<String> initialTypes;
  final List<String> initialCities;

  const FilterBottomSheet({
    super.key,
    this.modes = const [],
    this.types = const [],
    this.cities = const [],
    this.initialMaxPrice = 50000,
    this.initialModes = const [],
    this.initialTypes = const [],
    this.initialCities = const [],
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late double _priceRange;
  late List<String> _selectedModes;
  late List<String> _selectedTypes;
  late List<String> _selectedCities;

  @override
  void initState() {
    super.initState();
    _priceRange = widget.initialMaxPrice;
    _selectedModes = List<String>.from(widget.initialModes);
    _selectedTypes = List<String>.from(widget.initialTypes);
    _selectedCities = List<String>.from(widget.initialCities);
  }

  void _resetAll() {
    setState(() {
      _priceRange = 50000;
      _selectedModes = [];
      _selectedTypes = [];
      _selectedCities = [];
    });
  }

  void _apply() {
    Navigator.pop(context, {
      'maxPrice': _priceRange,
      'modes': _selectedModes,
      'types': _selectedTypes,
      'cities': _selectedCities,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFF8F9FF),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFBDC9C8),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filters',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: _resetAll,
                  child: const Text('Reset All', style: TextStyle(color: Color(0xFF006565))),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (widget.types.isNotEmpty) ...[
              const Text('Type', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.types.map((type) {
                  final isSelected = _selectedTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedTypes.add(type);
                        } else {
                          _selectedTypes.remove(type);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF006565).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF006565),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            if (widget.cities.isNotEmpty) ...[
              const Text('City', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.cities.map((city) {
                  final isSelected = _selectedCities.contains(city);
                  return FilterChip(
                    label: Text(city),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedCities.add(city);
                        } else {
                          _selectedCities.remove(city);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF006565).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF006565),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Price Range', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('₹0 - ₹${_priceRange.round()}+', style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Slider(
              value: _priceRange,
              min: 0,
              max: 50000,
              activeColor: const Color(0xFF006565),
              onChanged: (val) => setState(() => _priceRange = val),
            ),
            const SizedBox(height: 16),
            if (widget.modes.isNotEmpty) ...[
              const Text('Learning Mode', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.modes.map((mode) {
                  final isSelected = _selectedModes.contains(mode);
                  return FilterChip(
                    label: Text(mode),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedModes.add(mode);
                        } else {
                          _selectedModes.remove(mode);
                        }
                      });
                    },
                    selectedColor: const Color(0xFF006565).withOpacity(0.15),
                    checkmarkColor: const Color(0xFF006565),
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _apply,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF006565),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Apply Filters'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}