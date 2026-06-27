import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/index.dart';
import 'enroll_payment_screen.dart';

class TrainingDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> training;
  const TrainingDetailsScreen({super.key, required this.training});

  @override
  State<TrainingDetailsScreen> createState() => _TrainingDetailsScreenState();
}

class _TrainingDetailsScreenState extends State<TrainingDetailsScreen> {
  // Theme styling constants
  static const Color primaryTeal = Color(0xFF006565);
  static const Color selectedBg = Color(0xFFE3FFFE);
  static const Color textDark = Color(0xFF0B1C30);
  static const Color textLight = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color background = Color(0xFFF8F9FF);

  bool _isLoading = true;
  bool _isCheckingEnrollment = true;
  bool _isAlreadyEnrolled = false;
  Map<String, dynamic> _details = {};
  List<dynamic> _similarTrainings = [];
  
  // Accordion state tracker
  final Map<int, bool> _accordionStates = {0: true, 1: false, 2: false};

  @override
  void initState() {
    super.initState();
    _fetchDetails();
    _checkEnrollmentStatus();
  }

  Future<void> _checkEnrollmentStatus() async {
    setState(() => _isCheckingEnrollment = true);
    try {
      // Check if this course is already in the list of enrolled trainings for this user
      final res = await Database().getData({
        'action': 'getEnrolledTrainings',
      }, endpoint: 'new_apis/marketplace_training_API.php');

      if (res['success'] == true && res['data'] != null) {
        final List<dynamic> enrolled = res['data'];
        final currentId = widget.training['id']?.toString();
        setState(() {
          _isAlreadyEnrolled = enrolled.any((e) => e['id']?.toString() == currentId);
        });
      }
    } catch (e) {
      debugPrint("Error checking enrollment status: $e");
    } finally {
      setState(() => _isCheckingEnrollment = false);
    }
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final res = await Database().getData({
        'action': 'getTrainingDetails',
        'id': widget.training['id'],
      }, endpoint: 'new_apis/training_details_API.php');

      if (res['success'] == true && res['data'] != null) {
        setState(() {
          _details = res['data']['training'] ?? widget.training;
          _similarTrainings = res['data']['similar_trainings'] ?? [];
        });
      } else {
        setState(() {
          _details = widget.training;
          _similarTrainings = [];
        });
      }
    } catch (e) {
      debugPrint("Error fetching training details: $e");
      setState(() {
        _details = widget.training;
        _similarTrainings = [];
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // Dynamic syllabus generator based on the course category/title
  List<Map<String, String>> _getSyllabus(String category, String title) {
    final catLower = category.toLowerCase();
    if (catLower.contains('design') || title.toLowerCase().contains('ui') || title.toLowerCase().contains('ux')) {
      return [
        {
          "num": "01",
          "title": "Introduction to Advanced UX & Figma Auto Layout",
          "desc": "Master layout grids, complex alignment flows, constraints, and nesting structures within Figma design components."
        },
        {
          "num": "02",
          "title": "Design Systems & Component Libraries",
          "desc": "Learn how to build scalable design tokens, manage component states (Hover, Focus, Pressed), and enforce accessibility compliance."
        },
        {
          "num": "03",
          "title": "Rapid Prototyping & Developer Handoff",
          "desc": "Create interactive prototypes, define motion curves, write descriptive annotations, and hand off assets to engineering cleanly."
        }
      ];
    } else if (catLower.contains('tech') || catLower.contains('it') || title.toLowerCase().contains('flutter') || title.toLowerCase().contains('code')) {
      return [
        {
          "num": "01",
          "title": "State Management & Architecture Setup",
          "desc": "Learn how to set up clean, scalable project folders and implement advanced state management containers like Bloc, Provider, or Riverpod."
        },
        {
          "num": "02",
          "title": "Asynchronous Operations & Backend API Integration",
          "desc": "Implement robust offline-first synchronization, secure tokens storage, error catch boundaries, and JSON deserializers."
        },
        {
          "num": "03",
          "title": "Premium Animations & Custom Painting",
          "desc": "Build smooth transitions, micro-interactions, custom scroll effects, and tailor UI widgets for high-end client applications."
        }
      ];
    } else {
      return [
        {
          "num": "01",
          "title": "Core Concepts & Framework Setup",
          "desc": "Understand the main principles, setting up your environment, and building your first baseline projects."
        },
        {
          "num": "02",
          "title": "Intermediate Techniques & Workflows",
          "desc": "Optimize operations, connect database queries, process complex requests, and resolve potential resource contentions."
        },
        {
          "num": "03",
          "title": "Scale, Security & Best Practices",
          "desc": "Review industry standards, enforce access control, deploy staging environments, and manage releases cleanly."
        }
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = _details.isNotEmpty ? _details : widget.training;
    
    final double fee = double.tryParse(tr['fee']?.toString() ?? '0') ?? 0.0;
    final double origFee = double.tryParse(tr['original_fee']?.toString() ?? (fee * 1.5).toStringAsFixed(0)) ?? (fee * 1.5);
    final double savings = origFee - fee;
    final double savingsPercent = origFee > 0 ? (savings / origFee * 100) : 0;

    final String image = tr['image_url']?.toString() ?? '';
    final String title = tr['training_title']?.toString() ?? 'Professional Course';
    final String cat = tr['cat_id']?.toString() ?? 'Business';
    final String mode = tr['mode']?.toString() ?? 'Online';
    final String desc = tr['description']?.toString() ?? 'Master advanced workflows and acquire professional-tier skills under industry experts. This course covers everything from core fundamentals to clean code integration patterns and production deployments.';
    final String duration = tr['duration']?.toString() ?? '4 Weeks';
    final String vendor = tr['vendor_name']?.toString() ?? 'Expert Academy';

    final double rating = double.tryParse(tr['avg_rating']?.toString() ?? '0') ?? 0.0;
    final int reviews = int.tryParse(tr['review_count']?.toString() ?? '0') ?? 0;
    
    final syllabus = _getSyllabus(cat, title);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text("Training Details", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryTeal)))
          : Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Hero Image
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Stack(
                          children: [
                            image.isNotEmpty
                                ? Image.network(
                                    image,
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, o, s) => Container(
                                      color: primaryTeal.withOpacity(0.1),
                                      child: const Icon(Icons.school, color: primaryTeal, size: 64),
                                    ),
                                  )
                                : Container(
                                    color: primaryTeal.withOpacity(0.1),
                                    child: const Icon(Icons.school, color: primaryTeal, size: 64),
                                  ),
                            Positioned(
                              bottom: 12,
                              left: 16,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: primaryTeal,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  "BESTSELLER",
                                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Title
                            Text(
                              title,
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, height: 1.3),
                            ),
                            const SizedBox(height: 10),

                            // Rating & Mode
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  rating > 0 ? rating.toStringAsFixed(1) : "4.8",
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "(${reviews > 0 ? reviews : 120} reviews)",
                                  style: const TextStyle(fontSize: 12, color: textLight),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: selectedBg,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.videocam, size: 16, color: primaryTeal),
                                      const SizedBox(width: 4),
                                      Text(
                                        mode,
                                        style: const TextStyle(fontSize: 11, color: primaryTeal, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),

                            // Pricing card for Mobile
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineVariant.withOpacity(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Discounted Price", style: TextStyle(color: textLight, fontSize: 11)),
                                      const SizedBox(height: 4),
                                      Row(
                                        textBaseline: TextBaseline.alphabetic,
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        children: [
                                          Text(
                                            "₹${fee.toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTeal),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "₹${origFee.toStringAsFixed(0)}",
                                            style: const TextStyle(fontSize: 14, color: textLight, decoration: TextDecoration.lineThrough),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  if (savingsPercent > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        "Save ${savingsPercent.toStringAsFixed(0)}%",
                                        style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold, fontSize: 12),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Master Instructor
                            const Text(
                              "Master Instructor",
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textLight, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineVariant.withOpacity(0.5)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: primaryTeal.withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.person, color: primaryTeal, size: 28),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vendor,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textDark),
                                        ),
                                        const Text(
                                          "Senior Course Facilitator • 8+ years experience",
                                          style: TextStyle(fontSize: 11, color: textLight),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // About
                            const Text(
                              "About Training",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              desc,
                              style: const TextStyle(fontSize: 14, color: textLight, height: 1.5),
                            ),
                            const SizedBox(height: 24),

                            // Schedule Details Box
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: outlineVariant.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineVariant.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.calendar_today, color: primaryTeal, size: 20),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              const Text("Duration", style: TextStyle(color: textLight, fontSize: 10)),
                                              const SizedBox(height: 2),
                                              Text(duration, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(width: 1, height: 32, color: outlineVariant),
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 12),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.schedule, color: primaryTeal, size: 20),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                const Text("Schedule", style: TextStyle(color: textLight, fontSize: 10)),
                                                const SizedBox(height: 2),
                                                const Text("Flexible / self-paced", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Curriculum Accordions
                            const Text(
                              "Curriculum Breakdown",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: syllabus.length,
                              itemBuilder: (context, idx) {
                                final isExpanded = _accordionStates[idx] ?? false;
                                final module = syllabus[idx];
                                return Card(
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: outlineVariant, width: 0.5),
                                  ),
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        onTap: () {
                                          setState(() {
                                            _accordionStates[idx] = !isExpanded;
                                          });
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: selectedBg,
                                          radius: 14,
                                          child: Text(
                                            module['num']!,
                                            style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                                          ),
                                        ),
                                        title: Text(
                                          module['title']!,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                                        ),
                                        trailing: Icon(
                                          isExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: textLight,
                                        ),
                                      ),
                                      if (isExpanded)
                                        Padding(
                                          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                                          child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              module['desc']!,
                                              style: const TextStyle(color: textLight, fontSize: 12, height: 1.4),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),

                            // Similar recommended trainings
                            if (_similarTrainings.isNotEmpty) ...[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text(
                                    "Similar Trainings",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 210,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _similarTrainings.length,
                                  itemBuilder: (context, idx) {
                                    final item = _similarTrainings[idx];
                                    final double feeItem = double.tryParse(item['fee']?.toString() ?? '0') ?? 0.0;
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => TrainingDetailsScreen(training: item),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        width: 180,
                                        margin: const EdgeInsets.only(right: 12),
                                        child: Card(
                                          color: Colors.white,
                                          elevation: 1,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                          clipBehavior: Clip.antiAlias,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Expanded(
                                                child: item['image_url'] != null && item['image_url'].toString().isNotEmpty
                                                    ? Image.network(item['image_url'].toString(), fit: BoxFit.cover, width: double.infinity)
                                                    : Container(color: primaryTeal.withOpacity(0.1), child: const Icon(Icons.school, color: primaryTeal)),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.all(8.0),
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      item['training_title']?.toString() ?? 'Related Course',
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textDark),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      "₹${feeItem.toStringAsFixed(0)}",
                                                      style: const TextStyle(color: primaryTeal, fontWeight: FontWeight.bold, fontSize: 12),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Bottom CTA Button Bar
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: const Border(top: BorderSide(color: outlineVariant, width: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, -3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text("Course Fee", style: TextStyle(color: textLight, fontSize: 11)),
                              Text(
                                "₹${fee.toStringAsFixed(0)}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: textDark),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        _isCheckingEnrollment
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(primaryTeal))
                            : _isAlreadyEnrolled
                                ? Expanded(
                                    flex: 2,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: Colors.grey,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: null,
                                      child: const Text("Already Purchased", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  )
                                : Expanded(
                                    flex: 2,
                                    child: FilledButton(
                                      style: FilledButton.styleFrom(
                                        backgroundColor: primaryTeal,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () {
                                        Navigator.pushNamed(
                                          context,
                                          AppRoutes.enrollPayment,
                                          arguments: {
                                            'title': title,
                                            'batch': 'Online Batch',
                                            'price': fee.toString(),
                                            'marketplace_id': '28',
                                            'request_id': tr['id']?.toString() ?? '0',
                                          },
                                        ).then((_) {
                                          _checkEnrollmentStatus();
                                        });
                                      },
                                      child: const Text("Enroll Now", style: TextStyle(fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
