import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'training_details_screen.dart';

class EnrolledTrainingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const EnrolledTrainingsScreen({super.key, this.isEmbedded = false});

  @override
  State<EnrolledTrainingsScreen> createState() => _EnrolledTrainingsScreenState();
}

class _EnrolledTrainingsScreenState extends State<EnrolledTrainingsScreen> {
  // Theme styling constants
  static const Color primaryTeal = Color(0xFF006565);
  static const Color selectedBg = Color(0xFFE3FFFE);
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color background = Color(0xFFF8F9FF);

  bool _isLoading = true;
  List<dynamic> _enrolledTrainings = [];

  @override
  void initState() {
    super.initState();
    _fetchEnrolledTrainings();
  }

  Future<void> _fetchEnrolledTrainings() async {
    setState(() => _isLoading = true);
    try {
      final res = await Database().getData({
        'action': 'getEnrolledTrainings',
      }, endpoint: 'new_apis/marketplace_training_API.php');

      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _enrolledTrainings = res['data'];
        });
      }
    } catch (e) {
      debugPrint("Error fetching enrolled trainings: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'N/A';
    try {
      final dt = DateTime.parse(dateStr);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("My Enrolled Trainings", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: primaryTeal,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
      body: _isLoading
          ? _buildLoadingSkeleton()
          : _enrolledTrainings.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  color: primaryTeal,
                  onRefresh: _fetchEnrolledTrainings,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Header
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryTeal, primaryTeal.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryTeal.withOpacity(0.25),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Your Learning Journey",
                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "${_enrolledTrainings.length} course${_enrolledTrainings.length != 1 ? 's' : ''} enrolled",
                                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                "${_enrolledTrainings.length}",
                                style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Enrolled Courses List
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _enrolledTrainings.length,
                          itemBuilder: (context, index) {
                            final training = _enrolledTrainings[index];
                            return _buildEnrolledCard(training);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEnrolledCard(Map<String, dynamic> training) {
    final String title = training['training_title']?.toString() ?? 'Course';
    final String image = training['image_url']?.toString() ?? '';
    final String vendor = training['vendor_name']?.toString() ?? 'Instructor';
    final String mode = training['mode']?.toString() ?? 'Online';
    final String duration = training['duration']?.toString() ?? '—';
    final String enrollDate = _formatDate(training['enroll_date']?.toString());
    final String orderId = training['order_id']?.toString() ?? '';
    final double rating = double.tryParse(training['avg_rating']?.toString() ?? '0') ?? 0.0;
    final int reviews = int.tryParse(training['review_count']?.toString() ?? '0') ?? 0;
    final double fee = double.tryParse(training['fee']?.toString() ?? '0') ?? 0.0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TrainingDetailsScreen(training: training),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: outlineVariant.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image + Badge
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
              child: Stack(
                children: [
                  SizedBox(
                    height: 140,
                    width: double.infinity,
                    child: image.isNotEmpty
                        ? Image.network(
                            image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, o, s) => Container(
                              color: primaryTeal.withOpacity(0.08),
                              child: const Center(child: Icon(Icons.school, color: primaryTeal, size: 48)),
                            ),
                          )
                        : Container(
                            color: primaryTeal.withOpacity(0.08),
                            child: const Center(child: Icon(Icons.school, color: primaryTeal, size: 48)),
                          ),
                  ),
                  // Enrolled badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2E7D32),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            "ENROLLED",
                            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Mode chip
                  Positioned(
                    bottom: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.videocam, color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            mode,
                            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Card Body
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, height: 1.3),
                  ),
                  const SizedBox(height: 8),

                  // Instructor row
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: primaryTeal.withOpacity(0.1),
                        child: const Icon(Icons.person, color: primaryTeal, size: 14),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          vendor,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: textLight, fontSize: 12),
                        ),
                      ),
                      // Rating
                      if (rating > 0) ...[
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(color: textDark, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        Text(
                          " ($reviews)",
                          style: const TextStyle(color: textLight, fontSize: 10),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Divider
                  Container(height: 1, color: outlineVariant.withOpacity(0.3)),
                  const SizedBox(height: 10),

                  // Details row: Duration, Enrolled Date, Order ID
                  Row(
                    children: [
                      _buildDetailChip(Icons.calendar_today, duration),
                      const SizedBox(width: 12),
                      _buildDetailChip(Icons.event_available, enrollDate),
                      const Spacer(),
                      Text(
                        "₹${fee.toStringAsFixed(0)}",
                        style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ],
                  ),

                  if (orderId.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      "Order #$orderId",
                      style: const TextStyle(color: textLight, fontSize: 10, fontStyle: FontStyle.italic),
                    ),
                  ],

                  const SizedBox(height: 12),

                  // Continue Learning CTA
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TrainingDetailsScreen(training: training),
                          ),
                        );
                      },
                      icon: const Icon(Icons.play_circle_fill, size: 18),
                      label: const Text("Continue Learning"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: primaryTeal,
                        side: const BorderSide(color: primaryTeal),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
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

  Widget _buildDetailChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: textLight),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(color: textLight, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: selectedBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.school_outlined, color: primaryTeal, size: 56),
            ),
            const SizedBox(height: 24),
            const Text(
              "No Courses Yet",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: textDark),
            ),
            const SizedBox(height: 8),
            const Text(
              "You haven't enrolled in any training courses yet.\nExplore the marketplace to find courses that match your goals.",
              textAlign: TextAlign.center,
              style: TextStyle(color: textLight, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                // Navigate to marketplace trainings
                Navigator.pop(context);
              },
              icon: const Icon(Icons.explore),
              label: const Text("Browse Courses"),
              style: FilledButton.styleFrom(
                backgroundColor: primaryTeal,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          height: 260,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: outlineVariant.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image placeholder
              Container(
                height: 140,
                decoration: BoxDecoration(
                  color: outlineVariant.withOpacity(0.15),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(primaryTeal),
                    strokeWidth: 2,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 14,
                      width: 200,
                      decoration: BoxDecoration(
                        color: outlineVariant.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 140,
                      decoration: BoxDecoration(
                        color: outlineVariant.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      height: 12,
                      width: 100,
                      decoration: BoxDecoration(
                        color: outlineVariant.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
