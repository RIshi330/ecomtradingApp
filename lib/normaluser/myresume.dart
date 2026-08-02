import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // Add file_picker package to pubspec.yaml
import '../Database/Database.dart'; // Adjust path according to your project structure

/// API Endpoint for Resume Operations
const String resumesEndpoint = 'new_apis/resumes_API.php'; // Adjust path if needed

class AppColors {
  static const Color primary = Color(0xFF006565);
  static const Color primaryContainer = Color(0xFF008080);
  static const Color onPrimaryContainer = Color(0xFFE3FFFE);
  static const Color mintTint = Color(0xFFEBFDFC);
  static const Color secondaryContainer = Color(0xFFB0EEED);
  static const Color surface = Color(0xFFF9F9F9);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1A1C1C);
  static const Color onSurfaceVariant = Color(0xFF3E4949);
  static const Color outlineVariant = Color(0xFFBDC9C8);
  static const Color statusPending = Color(0xFFB45309);
  static const Color error = Color(0xFFBA1A1A);
}

/// Resume Data Model matching PHP response
class ResumeItem {
  final String id;
  final String title;
  final String url;
  final String agoTime;
  final bool isDefault;

  ResumeItem({
    required this.id,
    required this.title,
    required this.url,
    required this.agoTime,
    required this.isDefault,
  });

  factory ResumeItem.fromJson(Map<String, dynamic> json) {
    return ResumeItem(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Document',
      url: json['url']?.toString() ?? '',
      agoTime: json['ago_time']?.toString() ?? '',
      isDefault: json['is_default'] == true,
    );
  }

  bool get isPdf => url.toLowerCase().endsWith('.pdf') || title.toLowerCase().endsWith('.pdf');
}

class MyResumesScreen extends StatefulWidget {
  const MyResumesScreen({Key? key}) : super(key: key);

  @override
  State<MyResumesScreen> createState() => _MyResumesScreenState();
}

class _MyResumesScreenState extends State<MyResumesScreen> {
  final Database _db = Database();
  final TextEditingController _searchController = TextEditingController();

  List<ResumeItem> _resumes = [];
  List<ResumeItem> _filteredResumes = [];
  bool _isLoading = true;
  bool _isSearching = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchResumes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 1. Fetch Resumes from Backend (action: list_resumes)
  Future<void> _fetchResumes() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final response = await _db.getJsonData(
        {'action': 'list_resumes'},
        endpoint: resumesEndpoint,
      );

      if (response['success'] == true && response['data'] is List) {
        final List rawData = response['data'];
        setState(() {
          _resumes = rawData.map((e) => ResumeItem.fromJson(e as Map<String, dynamic>)).toList();
          _filteredResumes = List.from(_resumes);
          _isLoading = false;
        });

        // Re-apply search filter if user already typed something
        if (_searchController.text.isNotEmpty) {
          _filterLocalResumes(_searchController.text);
        }
      } else {
        setState(() {
          _errorMessage = response['message']?.toString() ?? 'Failed to load resumes.';
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

  /// 2. Search Resume in API (action: search)
  Future<void> _performApiSearch(String searchText) async {
    final query = searchText.trim();
    if (query.isEmpty) return;

    setState(() => _isSearching = true);

    try {
      final response = await _db.getJsonData(
        {
          'action': 'search',
          'text': query,
        },
        endpoint: resumesEndpoint,
      );

      if (response['success'] == true) {
        final bool exists = response['data']?['exists'] == true;
        if (!exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No exact match found on server for "$query"'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      // Handle network issue quietly or via notification
    } finally {
      if (mounted) {
        setState(() => _isSearching = false);
      }
    }
  }

  /// Filter local list & trigger API search
  void _onSearchChanged(String query) {
    _filterLocalResumes(query);
    if (query.trim().isNotEmpty) {
      _performApiSearch(query);
    }
  }

  void _filterLocalResumes(String query) {
    final cleanQuery = query.toLowerCase().trim();
    setState(() {
      if (cleanQuery.isEmpty) {
        _filteredResumes = List.from(_resumes);
      } else {
        _filteredResumes = _resumes
            .where((item) => item.title.toLowerCase().contains(cleanQuery))
            .toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    _filterLocalResumes('');
  }

  /// 3. Delete Resume (action: delete_resume)
  Future<void> _deleteResume(String resumeId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Resume'),
        content: const Text('Are you sure you want to delete this resume?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final response = await _db.getJsonData(
        {
          'action': 'delete_resume',
          'resume_id': resumeId,
        },
        endpoint: resumesEndpoint,
      );

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume deleted successfully.')),
        );
        _fetchResumes(); // Refresh list
      } else {
        _showErrorSnackBar(response['message']?.toString() ?? 'Failed to delete resume.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  /// 4. Upload File Handler (action: unique & upload)
  Future<void> _pickAndUploadFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result == null || result.files.single.path == null) return;

    final File selectedFile = File(result.files.single.path!);
    final String fileName = result.files.single.name;

    final String? customTitle = await _showTitleInputDialog(defaultTitle: fileName);
    if (customTitle == null || customTitle.trim().isEmpty) return;

    // Check file uniqueness on server
    final uniqueCheck = await _db.getJsonData(
      {
        'action': 'unique',
        'nameResume': fileName,
      },
      endpoint: resumesEndpoint,
    );

    if (uniqueCheck['data']?['unique'] == false) {
      _showErrorSnackBar('A file with this name already exists in your vault.');
      return;
    }

    // Perform Upload
    try {
      final uploadRes = await _db.uploadFile(
        endpoint: resumesEndpoint,
        file: selectedFile,
        body: {
          'action': 'upload',
          'newResumeTitle': customTitle.trim(),
        },
      );

      if (uploadRes['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Resume uploaded successfully!')),
        );
        _fetchResumes();
      } else {
        _showErrorSnackBar(uploadRes['message']?.toString() ?? 'Upload failed.');
      }
    } catch (e) {
      _showErrorSnackBar('Upload error: $e');
    }
  }

  Future<String?> _showTitleInputDialog({required String defaultTitle}) async {
    final controller = TextEditingController(text: defaultTitle);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Name Your Resume'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Resume Title',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Upload', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'My Resumes',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: RefreshIndicator(
              onRefresh: _fetchResumes,
              child: ListView(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 32.0 : 16.0,
                  vertical: 16.0,
                ),
                children: [
                  _buildMarketplaceBanner(context, isTablet),
                  const SizedBox(height: 20),

                  // --- Search Section Widget ---
                  _buildSearchBar(),
                  const SizedBox(height: 24),

                  // --- Header Row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Flexible(
                        child: Text(
                          'Manage Documents',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IntrinsicWidth(
                            child: OutlinedButton.icon(
                              onPressed: _pickAndUploadFile,
                              icon: const Icon(Icons.upload_file, size: 18),
                              label: Text(isTablet ? 'Upload New' : 'Upload'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                minimumSize: const Size(0, 40),
                                side: const BorderSide(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // --- Dynamic Resume Documents List ---
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: CircularProgressIndicator(color: AppColors.primary),
                      ),
                    )
                  else if (_errorMessage != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Column(
                        children: [
                          Text(_errorMessage!, style: const TextStyle(color: AppColors.error)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: _fetchResumes,
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    )
                  else if (_filteredResumes.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: Text(
                            _searchController.text.isNotEmpty
                                ? 'No resumes matching "${_searchController.text}".'
                                : 'No resumes uploaded yet.',
                            style: const TextStyle(color: AppColors.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredResumes.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final resume = _filteredResumes[index];
                          return ResumeItemCard(
                            title: resume.title,
                            uploadDate: resume.agoTime,
                            isPdf: resume.isPdf,
                            onDelete: () => _deleteResume(resume.id),
                            onDownload: () {
                              // Implement File download / Open URL logic here
                            },
                          );
                        },
                      ),

                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: _pickAndUploadFile,
                    child: _buildUploadDashedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Search Bar UI Component
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        onSubmitted: (value) => _performApiSearch(value),
        decoration: InputDecoration(
          hintText: 'Search resumes by title...',
          hintStyle: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          prefixIcon: _isSearching
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            ),
          )
              : const Icon(Icons.search, color: AppColors.primary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, color: AppColors.onSurfaceVariant, size: 20),
            onPressed: _clearSearch,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildMarketplaceBanner(BuildContext context, bool isTablet) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Elevate Your Presence',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Discover professional designs in our Resume Template Marketplace.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerLowest,
              foregroundColor: AppColors.primary,
              elevation: 0,
            ),
            child: const Text('Browse Templates'),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadDashedBox() {
    return CustomPaint(
      painter: DashedRectPainter(
        color: AppColors.outlineVariant,
        strokeWidth: 2,
        gap: 6,
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          children: const [
            Icon(Icons.post_add, size: 36, color: AppColors.onSurfaceVariant),
            SizedBox(height: 8),
            Text(
              'Tap or drag and drop files here to upload',
              style: TextStyle(fontSize: 13, color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class ResumeItemCard extends StatelessWidget {
  final String title;
  final String uploadDate;
  final bool isPdf;
  final VoidCallback onDelete;
  final VoidCallback onDownload;

  const ResumeItemCard({
    Key? key,
    required this.title,
    required this.uploadDate,
    required this.isPdf,
    required this.onDelete,
    required this.onDownload,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.mintTint,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              isPdf ? Icons.picture_as_pdf : Icons.description,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  uploadDate.isNotEmpty ? uploadDate : 'Recently uploaded',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 18),
            onPressed: onDownload,
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 18, color: AppColors.error),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class DashedRectPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double gap;

  DashedRectPainter({
    required this.color,
    this.strokeWidth = 1.0,
    this.gap = 5.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    final Path path = Path()..addRRect(rrect);
    final Path dashPath = Path();

    double distance = 0.0;
    for (final PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + gap),
          Offset.zero,
        );
        distance += gap * 2;
      }
    }
    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}