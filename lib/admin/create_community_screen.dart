import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

class CreateCommunityScreen extends StatefulWidget {
  const CreateCommunityScreen({super.key});

  @override
  State<CreateCommunityScreen> createState() => _CreateCommunityScreenState();
}

class _CreateCommunityScreenState extends State<CreateCommunityScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSubmitting = false;

  // Form Fields
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagInputController = TextEditingController();
  
  final List<String> _tags = ["Technology", "Networking"];
  String _selectedType = "Professional";
  String _visibility = "public"; // "public" or "private"
  String _joiningRule = "free"; // "free", "approval", "invite", "paid"
  
  // Paid Membership Fields
  final _feeController = TextEditingController(text: "0.00");
  String _billingType = "Recurring"; // "Recurring", "One-time"
  String _duration = "Monthly"; // "Monthly", "Quarterly", "Annual", "Lifetime"

  // Target Audience Fields
  String _ageGroup = "All Ages";
  String _gender = "All";
  final _professionController = TextEditingController();
  final _interestsController = TextEditingController();
  final _locationController = TextEditingController();

  // Branding Uploads (file name/mock paths)
  String? _logoName;
  String? _coverName;

  final List<String> _communityTypes = [
    "Professional", "Business", "NGO", "Educational", "Sports", "Religious", 
    "Local", "Startup", "Women", "Kids", "Alumni", "Hobby", "Club", "Other"
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _descriptionController.dispose();
    _tagInputController.dispose();
    _feeController.dispose();
    _professionController.dispose();
    _interestsController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() {
        _logoName = result.files.single.name;
      });
    }
  }

  Future<void> _pickCover() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.name.isNotEmpty) {
      setState(() {
        _coverName = result.files.single.name;
      });
    }
  }

  void _addTag() {
    final tag = _tagInputController.text.trim();
    if (tag.isNotEmpty && !_tags.contains(tag)) {
      setState(() {
        _tags.add(tag);
        _tagInputController.clear();
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final double fee = double.tryParse(_feeController.text) ?? 0.0;
      final response = await Database().getData({
        'action': 'create_community',
        'community_title': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'community_type': _selectedType,
        'visibility': _visibility,
        'joining_rule': _joiningRule,
        'joining_fee': fee.toStringAsFixed(2),
        'logo': _logoName ?? 'default_logo.png',
        'cover_image': _coverName ?? 'default_cover.png',
        'tags': _tags.join(','),
        'tagline': _taglineController.text.trim(),
        'age_group': _ageGroup,
        'gender': _gender,
        'profession': _professionController.text.trim(),
        'interests': _interestsController.text.trim(),
        'location_coverage': _locationController.text.trim(),
        'billing_type': _billingType,
        'duration': _duration,
      }, endpoint: 'new_apis/create_community_API.php');

      if (!mounted) return;

      if (response['success'] == true || response['status'] == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Community created successfully!"),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? "Failed to create community"),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Network error: ${e.toString()}"),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const accentBg = Color(0xFFF9F9F9);

    return Scaffold(
      backgroundColor: accentBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          "Initialize New Community",
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: primaryColor),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Progress Bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          "COMMUNITY FORGE",
                          style: TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          "Step 1 of 2",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: const LinearProgressIndicator(
                        value: 0.5,
                        backgroundColor: Color(0xFFEEEEED),
                        valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 1. Community Identity Section
                _buildCardSection(
                  title: "Community Identity",
                  icon: Icons.fingerprint_rounded,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branding Uploads
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Logo Upload
                          Expanded(
                            flex: 1,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "COMMUNITY LOGO (1:1)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickLogo,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F3F3),
                                      border: Border.all(color: const Color(0xFFBDC9C8)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: _logoName != null
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                _logoName!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 10, color: primaryColor, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          : Column(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: const [
                                                Icon(Icons.add_photo_alternate_outlined, color: Colors.grey),
                                                SizedBox(height: 4),
                                                Text("Upload Logo", style: TextStyle(fontSize: 9, color: Colors.grey)),
                                              ],
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Cover Photo Upload
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "COVER PHOTO (16:9)",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                InkWell(
                                  onTap: _pickCover,
                                  child: Container(
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF4F3F3),
                                      border: Border.all(color: const Color(0xFFBDC9C8)),
                                      borderRadius: BorderRadius.circular(12),
                                      image: _coverName != null
                                          ? null
                                          : const DecorationImage(
                                              image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuCeZ8lweaK-XBVEvbJU6Igx-guIJrTT17cYHZ0FirV5uij6XqYsGN5Z8GiRpf21SFtyHu3mXxemren3yXQ3joQmu021Nu_g90zotvdidTguBezYMeTlxI45j7tN3iNRjQA4VQZYSZ8_uXlTqXPAb_PWkKxw3pAC7Q7O5wLF2AW2bTDCxUKAcqNVzahbb6jOsTdvt26lXGvDAZxYcX6l49nHhhbDRWjHgdNCaGW8C4eHcgUedwJFWZ49"),
                                              fit: BoxFit.cover,
                                              opacity: 0.15,
                                            ),
                                    ),
                                    child: Center(
                                      child: _coverName != null
                                          ? Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Text(
                                                _coverName!,
                                                textAlign: TextAlign.center,
                                                style: const TextStyle(fontSize: 12, color: primaryColor, fontWeight: FontWeight.bold),
                                              ),
                                            )
                                          : const Text(
                                              "Tap to replace Cover",
                                              style: TextStyle(fontSize: 11, color: primaryColor, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Identity Inputs
                      _buildTextField(
                        controller: _nameController,
                        label: "COMMUNITY NAME",
                        hint: "e.g. Global Tech Innovators",
                        validator: (v) => v!.isEmpty ? "Community name is required" : null,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _taglineController,
                        label: "COMMUNITY TAGLINE",
                        hint: "e.g. The future starts here",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _descriptionController,
                        label: "DESCRIPTION",
                        hint: "Briefly describe the purpose and goals of this community...",
                        maxLines: 4,
                      ),
                      const SizedBox(height: 16),

                      // Tags input
                      const Text(
                        "TAGS",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF4F3F3),
                          border: Border.all(color: const Color(0xFFBDC9C8)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_tags.isNotEmpty)
                              Wrap(
                                spacing: 8,
                                runSpacing: 4,
                                children: _tags.map((t) => Chip(
                                  label: Text(t, style: const TextStyle(fontSize: 11, color: Color(0xFF306E6D))),
                                  backgroundColor: const Color(0xFFB0EEED),
                                  onDeleted: () {
                                    setState(() {
                                      _tags.remove(t);
                                    });
                                  },
                                  side: BorderSide.none,
                                  deleteIconColor: const Color(0xFF306E6D),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                )).toList(),
                              ),
                            Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _tagInputController,
                                    decoration: const InputDecoration(
                                      hintText: "Add tag...",
                                      border: InputBorder.none,
                                      hintStyle: TextStyle(fontSize: 12, color: Colors.grey),
                                    ),
                                    onSubmitted: (_) => _addTag(),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add, color: primaryColor),
                                  onPressed: _addTag,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 2. Type & Visibility Section
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildCardSection(
                        title: "Community Type",
                        icon: Icons.category_rounded,
                        child: DropdownButtonFormField<String>(
                          value: _selectedType,
                          isExpanded: true,
                          decoration: InputDecoration(
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFBDC9C8)),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                          items: _communityTypes.map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t, overflow: TextOverflow.ellipsis),
                          )).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedType = val;
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildCardSection(
                        title: "Visibility",
                        icon: Icons.visibility_rounded,
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              value: "public",
                              groupValue: _visibility,
                              title: const Text("Public", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              subtitle: const Text("Anyone can see/join", style: TextStyle(fontSize: 10)),
                              onChanged: (val) => setState(() => _visibility = val!),
                              activeColor: primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                            RadioListTile<String>(
                              value: "private",
                              groupValue: _visibility,
                              title: const Text("Private", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                              subtitle: const Text("Hidden from search", style: TextStyle(fontSize: 10)),
                              onChanged: (val) => setState(() => _visibility = val!),
                              activeColor: primaryColor,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Joining Rules Section
                _buildCardSection(
                  title: "Joining Rules",
                  icon: Icons.policy_rounded,
                  child: Column(
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildRuleCard(
                            value: "free",
                            title: "Free",
                            subtitle: "Open Access",
                            icon: Icons.check_circle_outline_rounded,
                          ),
                          _buildRuleCard(
                            value: "approval",
                            title: "Request Approval",
                            subtitle: "Admin Review",
                            icon: Icons.verified_user_outlined,
                          ),
                          _buildRuleCard(
                            value: "invite",
                            title: "Invite Only",
                            subtitle: "Exclusive",
                            icon: Icons.mail_outline_rounded,
                          ),
                          _buildRuleCard(
                            value: "paid",
                            title: "Paid Membership",
                            subtitle: "Monetized",
                            icon: Icons.monetization_on_outlined,
                          ),
                        ],
                      ),
                      if (_joiningRule == "paid") ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: const Color(0xFFBDC9C8)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "MEMBERSHIP FEE (INR)",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        TextFormField(
                                          controller: _feeController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            prefixText: "₹ ",
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "BILLING TYPE",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _billingType,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(value: "Recurring", child: Text("Recurring", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "One-time", child: Text("One-time", overflow: TextOverflow.ellipsis)),
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          onChanged: (val) => setState(() => _billingType = val!),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "DURATION",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey),
                                        ),
                                        const SizedBox(height: 6),
                                        DropdownButtonFormField<String>(
                                          value: _duration,
                                          isExpanded: true,
                                          items: const [
                                            DropdownMenuItem(value: "Monthly", child: Text("Monthly", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Quarterly", child: Text("Quarterly", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Annual", child: Text("Annual", overflow: TextOverflow.ellipsis)),
                                            DropdownMenuItem(value: "Lifetime", child: Text("Lifetime", overflow: TextOverflow.ellipsis)),
                                          ],
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                          ),
                                          onChanged: (val) => setState(() => _duration = val!),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // 4. Target Audience Section
                _buildCardSection(
                  title: "Target Audience",
                  icon: Icons.group_rounded,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("AGE GROUP", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _ageGroup,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: "All Ages", child: Text("All Ages", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "18-24", child: Text("18-24", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "25-34", child: Text("25-34", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "35-44", child: Text("35-44", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "45+", child: Text("45+", overflow: TextOverflow.ellipsis)),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) => setState(() => _ageGroup = val!),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("GENDER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _gender,
                                  isExpanded: true,
                                  items: const [
                                    DropdownMenuItem(value: "All", child: Text("All", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Male", child: Text("Male", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Female", child: Text("Female", overflow: TextOverflow.ellipsis)),
                                    DropdownMenuItem(value: "Non-binary", child: Text("Non-binary", overflow: TextOverflow.ellipsis)),
                                  ],
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                  ),
                                  onChanged: (val) => setState(() => _gender = val!),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _professionController,
                        label: "PROFESSION",
                        hint: "e.g. Software Engineers, Marketers",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _interestsController,
                        label: "INTERESTS",
                        hint: "Design, AI, Sustainable Energy...",
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _locationController,
                        label: "LOCATION COVERAGE",
                        hint: "Global / Remote / Specific City",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Footer Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF6E7979)),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text(
                          "Save as Draft",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: const [
                                  Text("Create Community", style: TextStyle(fontWeight: FontWeight.bold)),
                                  SizedBox(width: 8),
                                  Icon(Icons.arrow_forward),
                                ],
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
      ),
    );
  }

  Widget _buildCardSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    const primaryColor = Color(0xFF006565);
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.black),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
            fillColor: const Color(0xFFF4F3F3),
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF006565), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildRuleCard({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _joiningRule == value;
    const primaryColor = Color(0xFF006565);

    return InkWell(
      onTap: () {
        setState(() {
          _joiningRule = value;
        });
      },
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE5F5F5) : const Color(0xFFF4F3F3),
          border: Border.all(
            color: isSelected ? primaryColor : const Color(0xFFBDC9C8),
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: isSelected ? primaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isSelected ? primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 9,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
