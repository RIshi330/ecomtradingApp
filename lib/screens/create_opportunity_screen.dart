import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../Database/Database.dart';

class FinancialOffering {
  String value;

  FinancialOffering({
    this.value = '',
  });
}

class OpportunityFormScreen extends StatefulWidget {
  const OpportunityFormScreen({super.key});

  @override
  State<OpportunityFormScreen> createState() =>
      _OpportunityFormScreenState();
}

class _OpportunityFormScreenState
    extends State<OpportunityFormScreen> {

  final formKey = GlobalKey<FormState>();

  final titleController = TextEditingController();
  final detailsController = TextEditingController();
  final audienceController = TextEditingController();
  final locationController = TextEditingController();
  final termsController = TextEditingController();
  final expectationsController = TextEditingController();
  final eligibilityController = TextEditingController();
  final prerequisiteController = TextEditingController();
  final whoCanApplyController = TextEditingController();
  final otherSpecifyController = TextEditingController();

  String? selectedOfferType;
  bool showOtherField = false;
  bool _isSubmitting = false;

  final List<String> selectedIndustries = [];
  final List<String> selectedOpportunityTypes = [];
  final List<String> selectedActions = [];
  final List<String> uploadedFiles = [];

  final List<FinancialOffering> offerings = [
    FinancialOffering(),
  ];

  final industries = [
    "Media",
    "Real Estate",
    "Hospitality",
    "Tourism",
    "Legal",
    "IT",
    "Marketing",
    "E-commerce",
    "Delivery",
  ];

  final opportunityTypes = [
    "Partnership",
    "Investment",
    "Service Offering",
    "Joint Venture",
    "Other",
  ];

  final preferredActions = [
    "Apply",
    "Enroll",
    "Request Call Back",
    "Book Appointment",
    "Donate",
    "Sponsor",
    "Ask for Quotation",
    "Show Interest",
    "Invest",
  ];

  @override
  void dispose() {
    titleController.dispose();
    detailsController.dispose();
    audienceController.dispose();
    locationController.dispose();
    termsController.dispose();
    expectationsController.dispose();
    eligibilityController.dispose();
    prerequisiteController.dispose();
    whoCanApplyController.dispose();
    otherSpecifyController.dispose();
    super.dispose();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
    );

    if (result != null) {
      setState(() {
        uploadedFiles.addAll(
          result.files
              .map(
                (e) => e.name,
              )
              .toList(),
        );
      });
    }
  }

  void addOffering() {
    setState(() {
      offerings.add(
        FinancialOffering(),
      );
    });
  }

  Future<void> saveDraft() async {
    await _submitOpportunity(false);
  }

  Future<void> publishOpportunity() async {
    await _submitOpportunity(true);
  }

  Future<void> _submitOpportunity(bool isPublish) async {
    if (isPublish && !formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final postData = {
        "action": isPublish ? "publish" : "draft",
        "title": titleController.text.trim(),
        "industry": selectedIndustries.isNotEmpty ? selectedIndustries.join(', ') : null,
        "offerType": selectedOfferType,
        "opptype": selectedOpportunityTypes.isNotEmpty ? selectedOpportunityTypes.join(', ') : null,
        "other_opp_type": showOtherField ? otherSpecifyController.text.trim() : null,
        "details": detailsController.text.trim(),
        "target_audience": audienceController.text.isNotEmpty
            ? audienceController.text.split(',').map((e) => e.trim()).toList()
            : [],
        "preferred_locations": locationController.text.isNotEmpty
            ? locationController.text.split(',').map((e) => e.trim()).toList()
            : [],
        "business_terms": termsController.text.trim(),
        "expectations": expectationsController.text.trim(),
        "who_can_apply": whoCanApplyController.text.isNotEmpty
            ? whoCanApplyController.text.split(',').map((e) => e.trim()).toList()
            : [],
        "preferred_actions": selectedActions,
        "eligibility_criteria": eligibilityController.text.trim(),
        "prerequisites": prerequisiteController.text.trim(),
        "financial_offerings": offerings
            .where((o) => o.value.trim().isNotEmpty)
            .map((o) => {
                  "type": "CUSTOM",
                  "amount": o.value.trim(),
                  "unit": "",
                })
            .toList(),
        "supporting_files": uploadedFiles
            .map((filename) => {
                  "url": "http://127.0.0.1/SetupBackendCCBUL/uploads/$filename",
                  "name": filename,
                })
            .toList(),
      };

      final response = await Database().getJsonData(
        postData,
        endpoint: "new_apis/oppFormAPI 1.php",
      );

      if (!mounted) return;

      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isPublish ? "Opportunity Published Successfully" : "Draft Saved Successfully"),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Return true to trigger lists refresh
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed: ${response['message'] ?? 'Unknown error'}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF474DC5),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create Opportunity",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_isSubmitting)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF474DC5),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: saveDraft,
              child: const Text(
                "Save Draft",
                style: TextStyle(
                  color: Color(0xFF474DC5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF474DC5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _isSubmitting ? null : publishOpportunity,
            child: const Text(
              "Publish Opportunity",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Opportunity Title",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: titleController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return "Required";
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  hintText: "Strategic Expansion Partnership",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Industry",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: industries.map((industry) {
                  final selected = selectedIndustries.contains(industry);
                  return FilterChip(
                    label: Text(industry),
                    selected: selected,
                    selectedColor: const Color(0xFF474DC5).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF474DC5),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedIndustries.add(industry);
                        } else {
                          selectedIndustries.remove(industry);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              DropdownButtonFormField<String>(
                value: selectedOfferType,
                decoration: const InputDecoration(
                  labelText: "Offer Type",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(
                    value: "B2B Partnership",
                    child: Text("B2B Partnership"),
                  ),
                  DropdownMenuItem(
                    value: "Vendor Agreement",
                    child: Text("Vendor Agreement"),
                  ),
                  DropdownMenuItem(
                    value: "Equity Distribution",
                    child: Text("Equity Distribution"),
                  ),
                  DropdownMenuItem(
                    value: "Asset Acquisition",
                    child: Text("Asset Acquisition"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedOfferType = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text(
                "Opportunity Type",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: opportunityTypes.map((type) {
                  final selected = selectedOpportunityTypes.contains(type);
                  return FilterChip(
                    label: Text(type),
                    selected: selected,
                    selectedColor: const Color(0xFF474DC5).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF474DC5),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedOpportunityTypes.add(type);
                        } else {
                          selectedOpportunityTypes.remove(type);
                        }
                        if (type == "Other") {
                          showOtherField = value;
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              if (showOtherField)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: TextFormField(
                    controller: otherSpecifyController,
                    decoration: const InputDecoration(
                      hintText: "Please Specify Type",
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              const Text(
                "Product / Service / Solution Details",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: detailsController,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: "Describe the solution or brand in detail...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Financial Offering",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Column(
                children: [
                  ...offerings.asMap().entries.map((entry) {
                    final index = entry.key;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              initialValue: offerings[index].value,
                              onChanged: (val) {
                                offerings[index].value = val;
                              },
                              decoration: const InputDecoration(
                                hintText: "15% Equity Share",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              setState(() {
                                if (offerings.length > 1) {
                                  offerings.removeAt(index);
                                } else {
                                  offerings[0].value = '';
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  }),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: addOffering,
                      icon: const Icon(Icons.add, color: Color(0xFF474DC5)),
                      label: const Text(
                        "Add More",
                        style: TextStyle(color: Color(0xFF474DC5), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Target Audience",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: audienceController,
                          decoration: const InputDecoration(
                            hintText: "Tech Founders, NGOs",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          "Preferred Locations",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: locationController,
                          decoration: const InputDecoration(
                            hintText: "Remote, USA",
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Business Terms & Duration",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: termsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Duration, renewal, trial terms...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Expectations From Partner",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: expectationsController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: "Promote, host, distribute, invest...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Who Can Apply?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: whoCanApplyController,
                decoration: const InputDecoration(
                  hintText: "Type or Category",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Preferred Actions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: preferredActions.map((action) {
                  final selected = selectedActions.contains(action);
                  return FilterChip(
                    label: Text(action),
                    selected: selected,
                    selectedColor: const Color(0xFF474DC5).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF474DC5),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedActions.add(action);
                        } else {
                          selectedActions.remove(action);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              const Text(
                "Eligibility Criteria",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: eligibilityController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Must be a registered business...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Prerequisites",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: prerequisiteController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText: "Business license, NDA...",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Supporting Material",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: pickFiles,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade400,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 50,
                        color: Color(0xFF474DC5),
                      ),
                      SizedBox(height: 12),
                      Text(
                        "Click to Upload",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        "Brochures, Pitch Decks",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: uploadedFiles.map((file) {
                  return Chip(
                    label: Text(file),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 18,
                    ),
                    onDeleted: () {
                      setState(() {
                        uploadedFiles.remove(file);
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
