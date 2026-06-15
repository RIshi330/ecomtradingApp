import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/screens/enroll_payment_screen.dart';

class OpportunityDetailScreen extends StatefulWidget {
  const OpportunityDetailScreen({super.key});

  @override
  State<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends State<OpportunityDetailScreen> {
  bool bookmarked = false;

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

  Future<void> submitApplication(String oppId, String name, String email, String phone, String notes) async {
    final response = await Database().getData({
      "action": "apply",
      "item_id": oppId,
      "name": name,
      "email": email,
      "phone": phone,
      "message": notes,
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Application submitted successfully!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Enrollment completed successfully!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Investment offer submitted!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Donation recorded. Thank you for your support!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Sponsorship submitted!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Message sent successfully!"), backgroundColor: Colors.green),
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
    }, endpoint: "new_apis/opportunity_details_api.php");
    
    if (response['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Quotation request submitted!"), backgroundColor: Colors.green),
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundImage: (recruiterPic != null && recruiterPic.isNotEmpty)
                    ? NetworkImage(recruiterPic)
                    : null,
                child: (recruiterPic == null || recruiterPic.isEmpty)
                    ? const Icon(Icons.person)
                    : null,
              ),
              title: Text(recruiterName, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Online Now", style: TextStyle(color: Colors.green, fontSize: 12)),
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Typical response time: ~4 hours",
                style: TextStyle(color: Color(0xff474DC5), fontWeight: FontWeight.w500, fontSize: 13),
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
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff474DC5),
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
    String selectedCv = "Sarah_UX_2024.pdf";
    String? uploadedCvName;

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
                        uploadedCvName = "Resume_Uploaded_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}.pdf";
                        selectedCv = uploadedCvName!;
                      });
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: const Color(0xff474DC5),
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xffF9F9FF),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.upload_file, size: 36, color: Color(0xff474DC5)),
                          const SizedBox(height: 8),
                          Text(
                            uploadedCvName != null ? "Change Resume" : "Upload Resume",
                            style: const TextStyle(color: Color(0xff474DC5), fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (uploadedCvName != null) ...[
                    RadioListTile<String>(
                      value: uploadedCvName!,
                      groupValue: selectedCv,
                      activeColor: const Color(0xff474DC5),
                      onChanged: (value) {
                        setModalState(() {
                          selectedCv = value!;
                        });
                      },
                      title: Text(uploadedCvName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      subtitle: const Text("Uploaded just now", style: TextStyle(color: Colors.green)),
                    ),
                  ],
                  RadioListTile<String>(
                    value: "Sarah_UX_2024.pdf",
                    groupValue: selectedCv,
                    activeColor: const Color(0xff474DC5),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCv = value!;
                      });
                    },
                    title: const Text("Sarah_UX_2024.pdf"),
                    subtitle: const Text("Updated 2 days ago"),
                  ),
                  RadioListTile<String>(
                    value: "Product_Design_Lead.pdf",
                    groupValue: selectedCv,
                    activeColor: const Color(0xff474DC5),
                    onChanged: (value) {
                      setModalState(() {
                        selectedCv = value!;
                      });
                    },
                    title: const Text("Product_Design_Lead.pdf"),
                    subtitle: const Text("Updated 1 month ago"),
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
                  backgroundColor: const Color(0xff474DC5),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  submitApplication(_oppId, "", "", "", "Attached Resume: $selectedCv");
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
                    value: selectedDuration,
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
                    value: selectedBudget,
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
                  backgroundColor: const Color(0xff474DC5),
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
    final desc = opp['short_description']?.toString() ?? 'Master advanced UX methodologies and financial product design.';
    final duration = opp['program_duration']?.toString() ?? '8 Weeks Duration';
    final price = compensation['payout_amount']?.toString() ?? opp['payout_amount']?.toString() ?? '₹2,499';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Enrollment Details", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F2FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xff474DC5),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    desc,
                    style: const TextStyle(fontSize: 13, height: 1.4, color: Colors.black87),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const CircleAvatar(
                backgroundColor: Color(0xffF1F2FF),
                child: Icon(Icons.calendar_today, color: Color(0xff474DC5)),
              ),
              title: Text(duration.contains('Duration') ? duration : "$duration Duration"),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(0xffF1F2FF),
                child: Icon(Icons.workspace_premium, color: Color(0xff474DC5)),
              ),
              title: Text("Industry Certificate"),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: Color(0xffF1F2FF),
                child: Icon(Icons.group, color: Color(0xff474DC5)),
              ),
              title: Text("1-on-1 Mentorship"),
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              price.startsWith('₹') ? price : "₹$price",
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xff474DC5),
              ),
            ),
          ],
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
              backgroundColor: const Color(0xff474DC5),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              // Navigate to payment screen with enrollment data
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EnrollPaymentScreen(),
                  settings: RouteSettings(
                    arguments: {
                      'title': title,
                      'batch': 'Online Batch',
                      'price': price.replaceAll(RegExp(r'[^\d.]'), ''),
                      'marketplace_id': _oppId,
                      'request_id': '0',
                    },
                  ),
                ),
              );
            },
            child: const Text("Proceed to Payment"),
          ),
        ],
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
                decoration: const InputDecoration(labelText: "Investor Name"),
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
                decoration: const InputDecoration(labelText: "Investment Amount (₹)"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: termsController,
                decoration: const InputDecoration(labelText: "Proposed Terms"),
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
              backgroundColor: const Color(0xff474DC5),
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
        title: const Text("Donate", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: "Donor Name"),
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
                decoration: const InputDecoration(labelText: "Custom Amount (₹)"),
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
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff474DC5),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              submitDonation(nameController.text, emailController.text, phoneController.text, amountController.text, notesController.text);
            },
            child: const Text("Donate"),
          ),
        ],
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
              backgroundColor: const Color(0xff474DC5),
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
          title: const Text("Opportunity Details"),
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
        label: Text(opp['type'].toString(), style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xffFFF3CD),
        side: BorderSide.none,
      ));
    }
    if (opp['location'] != null && opp['location'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(opp['location'].toString(), style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xffE6F6F6),
        side: BorderSide.none,
      ));
    }
    if (opp['industry'] != null && opp['industry'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(opp['industry'].toString(), style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xffF1F2FF),
        side: BorderSide.none,
      ));
    }
    if (opp['opportunity_for'] != null && opp['opportunity_for'].toString().isNotEmpty) {
      chips.add(Chip(
        label: Text(opp['opportunity_for'].toString(), style: const TextStyle(fontSize: 12)),
        backgroundColor: const Color(0xffE2F9F3),
        side: BorderSide.none,
      ));
    }
    if (opp['tags'] != null && opp['tags'].toString().isNotEmpty) {
      for (var tag in opp['tags'].toString().split(',')) {
        tag = tag.trim();
        if (tag.isNotEmpty) {
          chips.add(Chip(
            label: Text(tag, style: const TextStyle(fontSize: 12)),
            backgroundColor: const Color(0xffF5F5F5),
            side: BorderSide.none,
          ));
        }
      }
    }
    if (chips.isEmpty) {
      chips.add(const Chip(
        label: Text("Featured", style: TextStyle(fontSize: 12)),
        backgroundColor: Color(0xffF1F2FF),
        side: BorderSide.none,
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

    final positions = opp['positions'] ?? compensation['positions'] ?? 1;
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

    final matchScore = opp['label_name']?.toString() ?? '85%';
    final description = opp['full_description']?.toString().isNotEmpty == true
        ? opp['full_description'].toString()
        : (opp['short_description']?.toString() ?? 'No description provided.');

    final galleryList = media['gallery'] as List<dynamic>? ?? [];

    final String oppType = (opp['type'] ?? '').toString().toLowerCase();
    final String oppFor = (opp['opportunity_for'] ?? '').toString().toLowerCase();

    // Check if the API explicitly enables/disables the action (1 or true)
    // If not present in the API response, fallback to matching the type of opportunity
    final bool showApply = (opp['allow_apply'] == 1 || opp['allow_apply'] == '1' || opp['allow_apply'] == true) ||
        (oppType.contains('job') || oppType.contains('work') || oppType.contains('career') || oppType.contains('apply') || oppFor.contains('job')) ||
        (!opp.containsKey('allow_apply') && !opp.containsKey('allow_enroll') && !opp.containsKey('allow_invest') && !opp.containsKey('allow_donate') && !opp.containsKey('allow_sponsor'));

    final bool showEnroll = (opp['allow_enroll'] == 1 || opp['allow_enroll'] == '1' || opp['allow_enroll'] == true) ||
        (oppType.contains('course') || oppType.contains('program') || oppType.contains('learn') || oppType.contains('enroll') || oppFor.contains('course'));

    final bool showInvest = (opp['allow_invest'] == 1 || opp['allow_invest'] == '1' || opp['allow_invest'] == true) ||
        (oppType.contains('invest') || oppType.contains('funding') || oppType.contains('startup') || oppType.contains('equity') || oppFor.contains('invest') || opp['funding_goal'] != null);

    final bool showDonate = (opp['allow_donate'] == 1 || opp['allow_donate'] == '1' || opp['allow_donate'] == true) ||
        (oppType.contains('donate') || oppType.contains('charity') || oppType.contains('donation') || oppType.contains('cause') || oppFor.contains('donate'));

    final bool showSponsor = (opp['allow_sponsor'] == 1 || opp['allow_sponsor'] == '1' || opp['allow_sponsor'] == true) ||
        (oppType.contains('sponsor') || oppType.contains('sponsorship') || oppType.contains('partner') || oppFor.contains('sponsor'));

    return Scaffold(
      backgroundColor: const Color(0xffF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Opportunity Details",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xff474DC5)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(
              bookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: const Color(0xff474DC5),
            ),
            onPressed: () {
              setState(() {
                bookmarked = !bookmarked;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.share, color: Color(0xff474DC5)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Share Link Copied!")),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              color: Colors.black12,
              offset: Offset(0, -2),
            )
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              if (showApply) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff474DC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: showApplyDialog,
                  icon: const Icon(Icons.send, size: 18),
                  label: const Text("Apply Now"),
                ),
                const SizedBox(width: 8),
              ],
              if (showEnroll) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff474DC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: showEnrollDialog,
                  icon: const Icon(Icons.school, size: 18),
                  label: const Text("Enroll Now"),
                ),
                const SizedBox(width: 8),
              ],
              if (showInvest) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff474DC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: showInvestDialog,
                  icon: const Icon(Icons.trending_up, size: 18),
                  label: const Text("Invest Now"),
                ),
                const SizedBox(width: 8),
              ],
              if (showDonate) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff474DC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: showDonateDialog,
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text("Donate Now"),
                ),
                const SizedBox(width: 8),
              ],
              if (showSponsor) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff474DC5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: showSponsorDialog,
                  icon: const Icon(Icons.handshake, size: 18),
                  label: const Text("Sponsor"),
                ),
                const SizedBox(width: 8),
              ],
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xff474DC5),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: showQuotationDialog,
                icon: const Icon(Icons.request_quote, size: 18),
                label: const Text("Quotation"),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 260,
              width: double.infinity,
              decoration: BoxDecoration(
                color: const Color(0xffDCE2F3),
                image: (coverImage != null && coverImage.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(coverImage),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (coverImage != null && coverImage.isNotEmpty)
                  ? null
                  : const Center(
                      child: Icon(
                        Icons.business,
                        size: 120,
                        color: Color(0xff474DC5),
                      ),
                    ),
            ),
            Transform.translate(
              offset: const Offset(0, -40),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: const Color(0xffF1F2FF),
                          backgroundImage: (companyLogo != null && companyLogo.isNotEmpty)
                              ? NetworkImage(companyLogo)
                              : null,
                          child: (companyLogo == null || companyLogo.isEmpty)
                              ? const Icon(Icons.person, size: 36, color: Color(0xff474DC5))
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "$orgName • Posted $postedDate",
                                style: const TextStyle(color: Colors.grey, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xffF1F2FF),
                          ),
                          child: Text(
                            matchScore,
                            style: const TextStyle(
                              color: Color(0xff474DC5),
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: chips,
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: showContactDialog,
                      icon: const Icon(Icons.chat, color: Color(0xff474DC5)),
                      label: const Text("Contact Recruiter"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xff474DC5),
                        side: const BorderSide(color: Color(0xff474DC5)),
                        minimumSize: const Size(double.infinity, 44),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                Text(
                                  payoutType,
                                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  payoutAmount,
                                  style: const TextStyle(
                                    color: Color(0xff474DC5),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  paymentFrequency,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Applicants",
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "${opp['total_applications'] ?? 0}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  opp['status'] == 1 ? 'Active' : 'Closed',
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 1,
                            height: 60,
                            color: Colors.grey.shade300,
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                const Text(
                                  "Positions",
                                  style: TextStyle(color: Colors.grey, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "$positions",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  duration,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildSectionTitle("About the Role"),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      margin: const EdgeInsets.only(top: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(5),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Text(
                        description,
                        style: const TextStyle(height: 1.6, color: Colors.black87),
                      ),
                    ),
                    if (opp['benefits'] != null && opp['benefits'].toString().isNotEmpty) ...[
                      const SizedBox(height: 24),
                      buildSectionTitle("Benefits & Perks"),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        margin: const EdgeInsets.only(top: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(5),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            )
                          ],
                        ),
                        child: Text(
                          opp['benefits'].toString(),
                          style: const TextStyle(height: 1.6, color: Colors.black87),
                        ),
                      ),
                    ],
                    if (galleryList.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      buildSectionTitle("Gallery"),
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
                                borderRadius: BorderRadius.circular(12),
                                image: DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    buildSectionTitle("Requirements"),
                    const SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.3,
                      children: requirements,
                    ),
                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xff474DC5),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            backgroundColor: const Color(0xffF1F2FF),
            child: Icon(
              icon,
              color: const Color(0xff474DC5),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
