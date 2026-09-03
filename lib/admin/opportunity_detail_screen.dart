import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends State<OpportunityDetailScreen> {
  bool bookmarked = false;
  String _selectedCv = "Sarah_UX_2024.pdf";
  String? _uploadedCvName;

  Map<String, dynamic>? get _getArguments =>
      ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

  String get _oppId =>
      (_getArguments != null && _getArguments!.containsKey('opportunity'))
          ? (_getArguments!['opportunity']['id']?.toString() ?? '')
          : '';

  Map<String, dynamic> get vendor =>
      (_getArguments != null && _getArguments!.containsKey('vendor'))
          ? (_getArguments!['vendor'] as Map<String, dynamic>? ?? {})
          : {};

  // Dummy image URL
  static const String _dummyImageUrl = 'https://cdn.pixabay.com/photo/2016/09/14/08/26/web-1668927_1280.jpg';

  String _getImageUrl(String? imageUrl) {
    if (imageUrl != null && imageUrl.trim().isNotEmpty) {
      return imageUrl;
    }
    return _dummyImageUrl;
  }

  Widget _buildImage(String? imageUrl, {double? height, double? width, BoxFit fit = BoxFit.cover}) {
    final String url = _getImageUrl(imageUrl);
    return SizedBox(
      height: height,
      width: width,
      child: Image.network(
        url,
        fit: fit, // Use the passed fit parameter
        errorBuilder: (context, error, stackTrace) => Image.network(
          _dummyImageUrl,
          fit: fit, // Use the passed fit parameter
          errorBuilder: (context, error, stackTrace) => Container(
            color: const Color(0xFFE6F2F2),
            child: const Icon(
              Icons.business,
              size: 60,
              color: Color(0xFF006565), // Fixed: was 0xFFF006565
            ),
          ),
        ),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFE6F2F2),
            child: const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF006565), // Fixed: was 0xFFF006565
              ),
            ),
          );
        },
      ),
    );
  }
  void showSuccessOverlay(String title, String subtitle) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xff006565).withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xffe5f7f7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xff006565),
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1B1B),
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.normal,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Great, thanks!",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> submitApplication(String oppId, String name, String email, String phone, String notes) async {
    final response = await Database().getData({
      "action": "apply",
      "item_id": oppId,
      "name": name,
      "email": email,
      "phone": phone,
      "message": notes,
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Application Submitted!",
          "Your application has been successfully sent to the recruiter. We'll notify you of updates.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitEnrollment(String oppId, String name, String email, String phone, String batch, String notes) async {
    final response = await Database().getData({
      "action": "enroll",
      "marketplace_id": oppId,
      "name": name,
      "email": email,
      "phone": phone,
      "batch": batch,
      "notes": notes,
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Enrollment Successful!",
          "You have successfully enrolled in this program. Check your profile for program schedules.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Enrollment failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitInvestment(String oppId, String name, String email, String phone, String amount, String terms, String notes) async {
    final response = await Database().getData({
      "action": "proposal",
      "item_id": oppId,
      "name": name,
      "email": email,
      "phone": phone,
      "price": amount,
      "terms": terms,
      "notes": notes,
      "type": "Investment",
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Investment Offer Sent!",
          "Your investment proposal has been submitted. The business representative will review it shortly.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Investment failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitDonation(String name, String email, String phone, String amount, String notes) async {
    final response = await Database().getData({
      "action": "donate",
      "name": name,
      "email": email,
      "phone": phone,
      "amount": amount,
      "notes": notes,
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Donation Received!",
          "Thank you for your generous support! Your contribution makes a massive difference.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Donation failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitSponsorship(String oppId, String name, String email, String phone, String amount, String notes) async {
    final response = await Database().getData({
      "action": "proposal",
      "item_id": oppId,
      "name": name,
      "email": email,
      "phone": phone,
      "price": amount,
      "notes": notes,
      "type": "Sponsorship",
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Sponsorship Proposal Sent!",
          "Your sponsorship details have been successfully submitted for review.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Sponsorship failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitContactRequest(String message) async {
    final recruiterName = (vendor['name']?.toString() ?? '').isNotEmpty ? vendor['name'].toString() : "Sarah Jenkins";
    final response = await Database().getData({
      "action": "contact",
      "name": "User",
      "email": "",
      "phone": "",
      "subject": "Contacted Recruiter: $recruiterName",
      "message": message,
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Message Sent!",
          "Your message has been delivered to $recruiterName. You'll receive a response in your inbox.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send message: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> submitQuotationRequest(String scope, String duration, String budgetRange) async {
    final response = await Database().getData({
      "action": "proposal",
      "item_id": _oppId,
      "name": "User",
      "email": "",
      "phone": "",
      "price": budgetRange,
      "terms": duration,
      "notes": scope,
      "type": "Quotation",
      'vendor_id': UserSessionSet.instance.vendorId,

    }, endpoint: "new_apis/opportunity_details_api.php");

    if (response['success'] == true) {
      if (mounted) {
        showSuccessOverlay(
          "Quotation Requested!",
          "Your quotation request has been sent. The seller will prepare an estimate shortly.",
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Submission failed: ${response['message'] ?? 'Error'}"), backgroundColor: Colors.red),
        );
      }
    }
  }

  void showContactDialog() {
    final controller = TextEditingController();
    final recruiterName = (vendor['name']?.toString() ?? '').isNotEmpty ? vendor['name'].toString() : "Sarah Jenkins";
    final recruiterPic = vendor['profile_pic']?.toString() ?? vendor['company_logo']?.toString();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Contact $recruiterName", style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: SizedBox(
                  width: 40,
                  height: 40,
                  child: ClipOval(
                    child: (recruiterPic != null && recruiterPic.isNotEmpty)
                        ? Image.network(
                      recruiterPic,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: const Color(0xffe5f7f7),
                        child: const Icon(Icons.person, color: Color(0xff006565)),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: const Color(0xffe5f7f7),
                          child: const Center(
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xff006565)),
                            ),
                          ),
                        );
                      },
                    )
                        : Container(
                      color: const Color(0xffe5f7f7),
                      child: const Icon(Icons.person, color: Color(0xff006565)),
                    ),
                  ),
                ),
                title: Text(recruiterName, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text("Online Now", style: TextStyle(color: Colors.green, fontSize: 12)),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFe5f7f7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "Typical response time: ~4 hours",
                  style: TextStyle(color: Color(0xff006565), fontWeight: FontWeight.w500, fontSize: 13),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: "Hi $recruiterName, I'm interested in the Lead UX role...",
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              if (controller.text.trim().isNotEmpty) {
                submitContactRequest(controller.text);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a message")),
                );
              }
            },
            child: const Text("Send Message"),
          ),
        ],
      ),
    );
  }

  void showApplyDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Apply Now", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: () {
                      setModalState(() {
                        _uploadedCvName = "Resume_Uploaded_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.pdf";
                        _selectedCv = _uploadedCvName!;
                      });
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xff006565),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xffFCF9F8),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file, size: 36, color: Color(0xff006565)),
                          const SizedBox(height: 8),
                          Text(
                            _uploadedCvName != null ? "Change Resume" : "Upload Resume",
                            style: const TextStyle(color: Color(0xff006565), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Using Radio instead of RadioListTile to avoid deprecation warnings
                  if (_uploadedCvName != null) ...[
                    Row(
                      children: [
                        Radio<String>(
                          value: _uploadedCvName!,
                          groupValue: _selectedCv,
                          activeColor: const Color(0xff006565),
                          onChanged: (value) {
                            setModalState(() {
                              _selectedCv = value!;
                            });
                          },
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _uploadedCvName!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                              ),
                              const Text("Uploaded just now", style: TextStyle(color: Colors.green, fontSize: 12)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                  Row(
                    children: [
                      Radio<String>(
                        value: "Sarah_UX_2024.pdf",
                        groupValue: _selectedCv,
                        activeColor: const Color(0xff006565),
                        onChanged: (value) {
                          setModalState(() {
                            _selectedCv = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Sarah_UX_2024.pdf",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13),
                            ),
                            const Text("Updated 2 days ago", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: "Product_Design_Lead.pdf",
                        groupValue: _selectedCv,
                        activeColor: const Color(0xff006565),
                        onChanged: (value) {
                          setModalState(() {
                            _selectedCv = value!;
                          });
                        },
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Product_Design_Lead.pdf",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(fontSize: 13),
                            ),
                            const Text("Updated 1 month ago", style: TextStyle(fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006565),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  submitApplication(_oppId, "", "", "", "Attached Resume: $_selectedCv");
                },
                child: const Text("Submit Application"),
              ),
            ],
          );
        },
      ),
    );
  }

  void showQuotationDialog() {
    final scopeController = TextEditingController();
    String selectedDuration = "1 month";
    String selectedBudget = "₹50k-₹100k";

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Request Quotation", style: TextStyle(fontWeight: FontWeight.bold)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: scopeController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: "Project Scope Description",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedDuration,
                    decoration: const InputDecoration(
                      labelText: "Expected Duration",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "1 week",
                        child: Text("1 week"),
                      ),
                      DropdownMenuItem(
                        value: "2 weeks",
                        child: Text("2 weeks"),
                      ),
                      DropdownMenuItem(
                        value: "1 month",
                        child: Text("1 month"),
                      ),
                      DropdownMenuItem(
                        value: "3 months+",
                        child: Text("3 months+"),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        selectedDuration = val!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedBudget,
                    decoration: const InputDecoration(
                      labelText: "Budget Range",
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: "₹10k-₹30k",
                        child: Text("₹10k-₹30k"),
                      ),
                      DropdownMenuItem(
                        value: "₹30k-₹50k",
                        child: Text("₹30k-₹50k"),
                      ),
                      DropdownMenuItem(
                        value: "₹50k-₹100k",
                        child: Text("₹50k-₹100k"),
                      ),
                      DropdownMenuItem(
                        value: "₹100k+",
                        child: Text("₹100k+"),
                      ),
                    ],
                    onChanged: (val) {
                      setModalState(() {
                        selectedBudget = val!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff006565),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  submitQuotationRequest(scopeController.text, selectedDuration, selectedBudget);
                },
                child: const Text("Submit Request"),
              ),
            ],
          );
        },
      ),
    );
  }

  void showEnrollDialog() {
    final args = _getArguments;
    final opp = args?['opportunity'] as Map<String, dynamic>? ?? {};
    final compensation = args?['compensation'] as Map<String, dynamic>? ?? {};

    final title = opp['title']?.toString() ?? 'Lead UX Designer Certification';
    final desc = opp['short_description']?.toString() ?? opp['full_description']?.toString() ?? 'Master advanced UX methodologies, financial regulations, and accessible design patterns in this comprehensive 8-week program.';
    final duration = opp['program_duration']?.toString() ?? '8 Weeks';
    final price = compensation['payout_amount']?.toString() ?? opp['payout_amount']?.toString() ?? '2,499';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Enrollment Details",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1B1B),
                      ),
                    ),
                    IconButton(
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xffe5f7f7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "COURSE",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff006565),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "TRAINING DETAILS",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xff006565)),
                    const SizedBox(width: 10),
                    Text(
                      duration.contains('Duration') || duration.contains('Week') ? duration : "$duration Duration",
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.workspace_premium_outlined, size: 16, color: Color(0xff006565)),
                    const SizedBox(width: 10),
                    Text(
                      "Industry Certificate",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    Icon(Icons.people_outline, size: 16, color: Color(0xff006565)),
                    const SizedBox(width: 10),
                    Text(
                      "1-on-1 Mentorship",
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Price",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    Text(
                      price.startsWith('₹') ? price : "₹$price",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xff006565),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xff006565),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      final studentName = vendor['name']?.toString() ?? "Student";
                      final studentEmail = vendor['email']?.toString() ?? "";
                      final studentPhone = vendor['phone']?.toString() ?? "";
                      submitEnrollment(
                        _oppId,
                        studentName,
                        studentEmail,
                        studentPhone,
                        "Online Batch",
                        "Completed enrollment from details screen modal",
                      );
                    },
                    child: const Text(
                      "Enroll Now",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void showInvestDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final termsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Investment", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Investor Name",
                  labelStyle: TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Email",
                  labelStyle: TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Phone",
                  labelStyle: TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Investment Amount (₹)",
                  labelStyle: TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: termsController,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  labelText: "Proposed Terms",
                  labelStyle: TextStyle(fontSize: 13),
                  isDense: true,
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              submitInvestment(_oppId, nameController.text, emailController.text, phoneController.text, amountController.text, termsController.text, "Investment Application");
            },
            child: const Text("Invest"),
          ),
        ],
      ),
    );
  }

  void showDonateDialog() {
    final amountController = TextEditingController(text: "1000");
    bool donateAnonymously = false;
    String selectedQuickAmount = "1000";

    final args = _getArguments;
    final opp = args?['opportunity'] as Map<String, dynamic>? ?? {};
    final projectName = opp['title']?.toString() ?? 'Eco-Restore Initiative';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: StatefulBuilder(
          builder: (context, setModalState) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Donate",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1C1B1B),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.close, color: Colors.grey),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xffe5f7f7),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "CURRENT PROJECT",
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xff006565),
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            projectName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Select Amount",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: ["500", "1000", "5000"].map((amountStr) {
                        final isSelected = selectedQuickAmount == amountStr;
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isSelected ? const Color(0xff006565) : Colors.white,
                                foregroundColor: isSelected ? Colors.white : const Color(0xff006565),
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: const BorderSide(
                                    color: Color(0xff006565),
                                    width: 1.2,
                                  ),
                                ),
                              ),
                              onPressed: () {
                                setModalState(() {
                                  selectedQuickAmount = amountStr;
                                  amountController.text = amountStr;
                                });
                              },
                              child: Text(
                                "₹$amountStr",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      onChanged: (val) {
                        setModalState(() {
                          if (["500", "1000", "5000"].contains(val)) {
                            selectedQuickAmount = val;
                          } else {
                            selectedQuickAmount = "";
                          }
                        });
                      },
                      decoration: InputDecoration(
                        prefixIcon: const Icon(
                          Icons.currency_rupee,
                          size: 18,
                          color: Colors.grey,
                        ),
                        hintText: "Custom Amount",
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xff006565)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () {
                        setModalState(() {
                          donateAnonymously = !donateAnonymously;
                        });
                      },
                      child: Row(
                        children: [
                          Checkbox(
                            value: donateAnonymously,
                            activeColor: const Color(0xff006565),
                            onChanged: (val) {
                              setModalState(() {
                                donateAnonymously = val ?? false;
                              });
                            },
                          ),
                          const Text(
                            "Donate Anonymously",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff006565),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          final enteredAmount = amountController.text.trim();
                          if (enteredAmount.isEmpty || double.tryParse(enteredAmount) == null || double.parse(enteredAmount) <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Please enter a valid amount")),
                            );
                            return;
                          }
                          Navigator.pop(context);
                          final donorName = donateAnonymously ? "Anonymous" : (vendor['name']?.toString() ?? "Donor");
                          final donorEmail = donateAnonymously ? "" : (vendor['email']?.toString() ?? "");
                          final donorPhone = donateAnonymously ? "" : (vendor['phone']?.toString() ?? "");
                          submitDonation(
                            donorName,
                            donorEmail,
                            donorPhone,
                            enteredAmount,
                            donateAnonymously ? "Anonymous Donation" : "Eco Donation",
                          );
                        },
                        child: const Text(
                          "Complete Donation",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
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
    );
  }

  void showSponsorDialog() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final amountController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sponsor", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Sponsor Name"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: "Phone"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                decoration: const InputDecoration(labelText: "Sponsorship Amount (₹)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(labelText: "Notes"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Close", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              submitSponsorship(_oppId, nameController.text, emailController.text, phoneController.text, amountController.text, notesController.text);
            },
            child: const Text("Sponsor"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final args = _getArguments;
    if (args == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Opportunity Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: const Center(
          child: Text("No data available"),
        ),
      );
    }

    final opp = args['opportunity'] as Map<String, dynamic>? ?? {};
    final vendor = args['vendor'] as Map<String, dynamic>? ?? {};
    final compensation = args['compensation'] as Map<String, dynamic>? ?? {};
    // ignore: unused_local_variable
    final application = args['application'] as Map<String, dynamic>? ?? {};
    final media = args['media'] as Map<String, dynamic>? ?? {};

    // Dynamic tags/chips list
    final chips = <Widget>[];
    if (opp['type'] != null && opp['type'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(
          opp['type'].toString(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xff006565)),
        ),
        backgroundColor: const Color(0xffe5f7f7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xff006565), width: 0.8),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.zero,
      ));
    }
    if (opp['location'] != null && opp['location'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(
          opp['location'].toString(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xff006565)),
        ),
        backgroundColor: const Color(0xffe5f7f7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xff006565), width: 0.8),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.zero,
      ));
    }
    if (opp['industry'] != null && opp['industry'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(
          opp['industry'].toString(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xff006565)),
        ),
        backgroundColor: const Color(0xffe5f7f7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xff006565), width: 0.8),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.zero,
      ));
    }
    if (opp['opportunity_for'] != null && opp['opportunity_for'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(
          opp['opportunity_for'].toString(),
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xff006565)),
        ),
        backgroundColor: const Color(0xffe5f7f7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xff006565), width: 0.8),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.zero,
      ));
    }
    if (opp['tags'] != null && opp['tags'].toString().isNotEmpty) {
      for (var tag in opp['tags'].toString().split(',')) {
        tag = tag.trim();
        if (tag.isNotEmpty) {
          chips.add(Chip(
            label: Text(
              tag,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Colors.black87),
            ),
            backgroundColor: const Color(0xffF5F5F5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: const BorderSide(color: Color(0xffE0E0E0), width: 0.8),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            labelPadding: EdgeInsets.zero,
          ));
        }
      }
    }
    if (chips.isEmpty) {
      chips.add(Chip(
        label: const Text(
          "Featured",
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: Color(0xff006565)),
        ),
        backgroundColor: const Color(0xffe5f7f7),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: Color(0xff006565), width: 0.8),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        labelPadding: EdgeInsets.zero,
      ));
    }

    // Dynamic requirements grid
    final requirements = <Widget>[];
    if (opp['eligibility'] != null && opp['eligibility'].toString().isNotEmpty) {
      requirements.add(RequirementCard(
        icon: Icons.assignment_ind,
        title: opp['eligibility'].toString(),
      ));
    }
    if (opp['skills_required'] != null && opp['skills_required'].toString().isNotEmpty) {
      final skills = opp['skills_required'].toString().split(',');
      final icons = [Icons.star, Icons.lightbulb, Icons.bolt, Icons.verified_user];
      int iconIdx = 0;
      for (var skill in skills) {
        skill = skill.trim();
        if (skill.isNotEmpty) {
          requirements.add(RequirementCard(
            icon: icons[iconIdx % icons.length],
            title: skill,
          ));
          iconIdx++;
        }
      }
    }
    if (requirements.isEmpty) {
      requirements.addAll([
        const RequirementCard(
          icon: Icons.work,
          title: "Immediate Start",
        ),
        const RequirementCard(
          icon: Icons.task_alt,
          title: "Verify with host",
        ),
      ]);
    }

    final payoutType = compensation['payout_type']?.toString().isNotEmpty == true
        ? compensation['payout_type'].toString()
        : 'Budget';
    final payoutAmount = compensation['payout_amount']?.toString().isNotEmpty == true
        ? compensation['payout_amount'].toString()
        : (opp['payout_amount']?.toString().isNotEmpty == true ? opp['payout_amount'].toString() : 'Flexible');
    final paymentFrequency = compensation['payment_frequency']?.toString().isNotEmpty == true
        ? compensation['payment_frequency'].toString()
        : 'Monthly';

    // Removing unused variable - using underscore
    final _positions = opp['positions'] ?? compensation['positions'] ?? 1;
    final duration = opp['program_duration']?.toString().isNotEmpty == true
        ? opp['program_duration'].toString()
        : 'Immediate';

    final coverImage = media['cover_image']?.toString();
    final companyLogo = vendor['company_logo']?.toString() ?? vendor['profile_pic']?.toString();
    final orgName = opp['organization']?.toString().isNotEmpty == true
        ? opp['organization'].toString()
        : (vendor['company_name']?.toString().isNotEmpty == true
        ? vendor['company_name'].toString()
        : (vendor['name']?.toString() ?? 'Luxe Partner'));

    final title = opp['title']?.toString() ?? 'No Title';
    final postedDate = opp['created_at'] != null
        ? opp['created_at'].toString().split(' ')[0]
        : 'recently';

    // Removing unused variable
    final _matchScore = opp['label_name']?.toString() ?? '85%';
    final description = opp['full_description']?.toString().isNotEmpty == true
        ? opp['full_description'].toString()
        : (opp['short_description']?.toString() ?? 'No description provided.');

    final galleryList = media['gallery'] as List<dynamic>? ?? [];

    final String oppType = (opp['type'] ?? '').toString().toLowerCase();
    final String oppFor = (opp['opportunity_for'] ?? '').toString().toLowerCase();

    final bool showApply = (opp['allow_apply'] == 1 || opp['allow_apply'] == '1' || opp['allow_apply'] == true) ||
        (oppType.contains('job') || oppType.contains('work') || oppType.contains('career') || oppType.contains('apply') || oppFor.contains('job')) ||
        (!opp.containsKey('allow_apply') && !opp.containsKey('allow_enroll') && !opp.containsKey('allow_invest') && !opp.containsKey('allow_donate') && !opp.containsKey('allow_sponsor'));

    final bool showEnroll = (opp['allow_enroll'] == 1 || opp['allow_enroll'] == '1' || opp['allow_enroll'] == true) ||
        (oppType.contains('course') || oppType.contains('program') || oppType.contains('learn') || oppType.contains('enroll') || oppFor.contains('course'));

    // Removing unused variable with underscore
    final _showInvest = (opp['allow_invest'] == 1 || opp['allow_invest'] == '1' || opp['allow_invest'] == true) ||
        (oppType.contains('invest') || oppType.contains('funding') || oppType.contains('startup') || oppType.contains('equity') || oppFor.contains('invest') || opp['funding_goal'] != null);

    final _showDonate = (opp['allow_donate'] == 1 || opp['allow_donate'] == '1' || opp['allow_donate'] == true) ||
        (oppType.contains('donate') || oppType.contains('charity') || oppType.contains('donation') || oppType.contains('cause') || oppFor.contains('donate'));

    final bool showSponsor = (opp['allow_sponsor'] == 1 || opp['allow_sponsor'] == '1' || opp['allow_sponsor'] == true) ||
        (oppType.contains('sponsor') || oppType.contains('sponsorship') || oppType.contains('partner') || oppFor.contains('sponsor'));

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF181C1E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Opportunity Details",
          style: TextStyle(
            color: Color(0xFF181C1E),
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Manrope',
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: const Color(0xFF006565),
            ),
            onPressed: () {
              setState(() {
                bookmarked = !bookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFF181C1E)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("More options")),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (showApply) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: showApplyDialog,
                      icon: const Icon(Icons.description, size: 18),
                      label: const Text("Apply"),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showEnroll) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff006565),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: showEnrollDialog,
                      icon: const Icon(Icons.school, size: 18),
                      label: const Text("Enroll"),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (showSponsor) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff006565),
                        side: const BorderSide(color: Color(0xff006565)),
                        minimumSize: const Size(0, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: showSponsorDialog,
                      icon: const Icon(Icons.handshake, size: 18),
                      label: const Text("Sponsor"),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xff006565),
                      side: const BorderSide(color: Color(0xff006565)),
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: showQuotationDialog,
                    icon: const Icon(Icons.request_quote, size: 18),
                    label: const Text("Quote"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Image
            SizedBox(
              height: 200,
              width: double.infinity,
              child: Stack(
                children: [
                  _buildImage(coverImage, height: 200, width: double.infinity, fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.3),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),            // Info Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                margin: const EdgeInsets.only(top: 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.category,
                                    color: Color(0xFF006565),
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    opp['type']?.toString().toUpperCase() ?? 'Strategic Partnership',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF006565),
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF181C1E),
                                  fontFamily: 'Manrope',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Posted by
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: const Color(0xFFE2E8F0), width: 2),
                          ),
                          child: ClipOval(
                            child: companyLogo != null
                                ? Image.network(
                              companyLogo,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color(0xFFE6F2F2),
                                child: const Icon(Icons.person, color: Color(0xFF006565)),
                              ),
                            )
                                : Container(
                              color: const Color(0xFFE6F2F2),
                              child: const Icon(Icons.person, color: Color(0xFF006565)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Posted ${postedDate} ago by",
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF3E4949),
                              ),
                            ),
                            Text(
                              orgName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181C1E),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Tags
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: chips,
                    ),
                  ],
                ),
              ),
            ),
            // Metadata Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Icon(Icons.schedule, color: Color(0xFF006565), size: 24),
                            const SizedBox(height: 4),
                            const Text(
                              "DURATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E4949),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: const Color(0xFFE2E8F0),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF006565), size: 24),
                            const SizedBox(height: 4),
                            const Text(
                              "LOCATION",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E4949),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              opp['location']?.toString() ?? 'Remote',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: const Color(0xFFE2E8F0),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          children: [
                            const Icon(Icons.payments, color: Color(0xFF006565), size: 24),
                            const SizedBox(height: 4),
                            const Text(
                              "BUDGET",
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF3E4949),
                                letterSpacing: 0.5,
                              ),
                            ),
                            Text(
                              payoutAmount.startsWith('₹') ? payoutAmount : '₹$payoutAmount',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF181C1E),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Engagement Actions
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Icon(Icons.visibility, color: Color(0xFF3E4949), size: 18),
                          const SizedBox(width: 6),
                          Text(
                            '${opp['views'] ?? '1,204'} Views',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF3E4949),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          OutlinedButton.icon(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: const Icon(Icons.share, size: 16, color: Color(0xFF3E4949)),
                            label: const Text(
                              "Share",
                              style: TextStyle(fontSize: 14, color: Color(0xFF3E4949)),
                            ),
                          ),
                          const SizedBox(width: 8),
                          OutlinedButton.icon(
                            onPressed: () {
                              setState(() {
                                bookmarked = !bookmarked;
                              });
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFFE2E8F0)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(
                              bookmarked ? Icons.bookmark : Icons.bookmark_border,
                              size: 16,
                              color: bookmarked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                            ),
                            label: Text(
                              "Save",
                              style: TextStyle(
                                fontSize: 14,
                                color: bookmarked ? const Color(0xFF006565) : const Color(0xFF3E4949),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Dossier Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Opportunity Dossier",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF181C1E),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "OVERVIEW",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF006565),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.6,
                            color: Color(0xFF3E4949),
                          ),
                        ),
                        if (opp['key_objectives'] != null && opp['key_objectives'].toString().isNotEmpty) ...[
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7FAFC),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Key Objectives",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF181C1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                ...opp['key_objectives'].toString().split('\n').map((obj) {
                                  if (obj.trim().isEmpty) return const SizedBox.shrink();
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 4),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Icon(
                                          Icons.check_circle,
                                          color: Color(0xFF006565),
                                          size: 18,
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            obj.trim(),
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Color(0xFF3E4949),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        if (opp['eligibility'] != null && opp['eligibility'].toString().isNotEmpty) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "ELIGIBILITY SPHERE",
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF3E4949),
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        opp['eligibility'].toString(),
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF181C1E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              if (opp['financial_offering'] != null && opp['financial_offering'].toString().isNotEmpty)
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          "FINANCIAL OFFERING",
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF3E4949),
                                            letterSpacing: 0.5,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          opp['financial_offering'].toString(),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF181C1E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Requirements Section
                  const Text(
                    "Requirements",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF181C1E),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    children: requirements.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: r,
                    )).toList(),
                  ),
                  if (galleryList.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      "Gallery",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF181C1E),
                        fontFamily: 'Manrope',
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: galleryList.length,
                        itemBuilder: (context, index) {
                          final imageUrl = galleryList[index].toString();
                          return Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 160,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE6F2F2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: _buildImage(imageUrl, height: 120, width: 160, fit: BoxFit.cover),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RequirementCard extends StatelessWidget {
  final IconData icon;
  final String title;

  const RequirementCard({
    super.key,
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF006565).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF006565),
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Color(0xFF181C1E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}