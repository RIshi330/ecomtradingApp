import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import '../Database/Database.dart';
import '../index.dart';

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
  final audienceInputController = TextEditingController();
  final audienceInputFocusNode = FocusNode();
  final List<String> selectedAudiences = [];
  final whoCanApplyController = TextEditingController();

  final detailsQuillController = QuillController.basic();
  final termsQuillController = QuillController.basic();
  final expectationsQuillController = QuillController.basic();
  final eligibilityQuillController = QuillController.basic();
  final prerequisiteQuillController = QuillController.basic();

  final List<String> selectedOfferTypes = [];
  String? currentOfferTypeSelection;

  final List<String> selectedLocations = [];
  String? currentPreferredLocationSelection;

  bool showOtherField = false;
  bool _isSubmitting = false;

  String _getHtmlFromQuill(QuillController controller) {
    try {
      final delta = controller.document.toDelta().toJson();
      final converter = QuillDeltaToHtmlConverter(
        List.castFrom(delta),
        ConverterOptions.forEmail(),
      );
      return converter.convert();
    } catch (e) {
      debugPrint("Error converting Quill to HTML: $e");
      return "";
    }
  }

  Widget _buildQuillField({
    required QuillController controller,
    required String hint,
    double height = 200,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
        color: Colors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          QuillSimpleToolbar(
            controller: controller,
            config: const QuillSimpleToolbarConfig(
              showFontFamily: false,
              showFontSize: false,
              showBoldButton: true,
              showItalicButton: true,
              showSmallButton: false,
              showUnderLineButton: true,
              showStrikeThrough: false,
              showInlineCode: false,
              showColorButton: false,
              showBackgroundColorButton: false,
              showClearFormat: true,
              showAlignmentButtons: true,
              showLeftAlignment: true,
              showCenterAlignment: true,
              showRightAlignment: true,
              showJustifyAlignment: true,
              showHeaderStyle: false,
              showListNumbers: true,
              showListBullets: true,
              showListCheck: false,
              showCodeBlock: false,
              showQuote: false,
              showIndent: false,
              showLink: true,
              showUndo: true,
              showRedo: true,
              showDirection: false,
              showSearchButton: false,
              showSubscript: false,
              showSuperscript: false,
              multiRowsDisplay: false,
            ),
          ),
          const Divider(height: 1, thickness: 1),
          Container(
            height: height,
            padding: const EdgeInsets.all(8.0),
            child: QuillEditor.basic(
              controller: controller,
              config: QuillEditorConfig(
                placeholder: hint,
                autoFocus: false,
                expands: true,
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  final List<String> selectedIndustries = [];
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
    audienceInputController.dispose();
    audienceInputFocusNode.dispose();
    whoCanApplyController.dispose();
    detailsQuillController.dispose();
    termsQuillController.dispose();
    expectationsQuillController.dispose();
    eligibilityQuillController.dispose();
    prerequisiteQuillController.dispose();
    super.dispose();
  }

  Future<void> pickFiles() async {
    final result = await FilePicker.platform.pickFiles(
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
      final detailsHtml = _getHtmlFromQuill(detailsQuillController);
      final termsHtml = _getHtmlFromQuill(termsQuillController);
      final expectationsHtml = _getHtmlFromQuill(expectationsQuillController);
      final eligibilityHtml = _getHtmlFromQuill(eligibilityQuillController);
      final prerequisiteHtml = _getHtmlFromQuill(prerequisiteQuillController);

      final postData = {
        "action": isPublish ? "publish" : "draft",
        "title": titleController.text.trim(),
        "industry": selectedIndustries.isNotEmpty ? selectedIndustries.join(', ') : null,
        "offerType": selectedOfferTypes.isNotEmpty ? selectedOfferTypes.join(', ') : null,
        "opptype": null,
        "other_opp_type": null,
        "details": detailsHtml.trim(),
        "target_audience": selectedAudiences,
        "preferred_locations": selectedLocations,
        "business_terms": termsHtml.trim(),
        "expectations": expectationsHtml.trim(),
        "who_can_apply": whoCanApplyController.text.isNotEmpty
            ? whoCanApplyController.text.split(',').map((e) => e.trim()).toList()
            : [],
        "preferred_actions": selectedActions,
        "eligibility_criteria": eligibilityHtml.trim(),
        "prerequisites": prerequisiteHtml.trim(),
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
        endpoint: "new_apis/oppFormAPI 1 (1).php",
      );

      if (!mounted) return;

      if (response['success'] == true) {
        _showSuccessDialog(isPublish ? "Opportunity Published Successfully" : "Draft Saved Successfully");
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 16),
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFFD4E6E5), // Light teal background matching theme accents
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF006565), // Teal primary color
                    size: 40,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  "Success",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF006565),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx); // Close dialog
                      // Redirect to My Listing screen (and clear/replace current screen from stack)
                      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.manageOpportunities, (route) => false);
                    },
                    child: const Text(
                      "OK",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF006565),
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
                    color: Color(0xFF006565),
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
                  color: Color(0xFF006565),
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
              backgroundColor: const Color(0xFF006565),
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
                  fontSize: 16,
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
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: industries.map((industry) {
                  final selected = selectedIndustries.contains(industry);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    label: Text(
                      industry,
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFF006565).withValues(alpha: 0.12),
                    checkmarkColor: const Color(0xFF006565),
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
                initialValue: currentOfferTypeSelection,
                hint: const Text("Select Offer Type"),
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
                  if (value != null) {
                    setState(() {
                      if (!selectedOfferTypes.contains(value)) {
                        selectedOfferTypes.add(value);
                      }
                      currentOfferTypeSelection = null;
                    });
                  }
                },
              ),
              if (selectedOfferTypes.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: selectedOfferTypes.map((type) {
                    return Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      label: Text(
                        type,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF006565),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFF006565).withValues(alpha: 0.12),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFF006565),
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedOfferTypes.remove(type);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],


              const Text(
                "Opportunity Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuillField(
                controller: detailsQuillController,
                hint: "Describe the solution or brand in detail...",
                height: 250,
              ),
              const SizedBox(height: 24),

              const Text(
                "Financial Offering",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                      icon: const Icon(Icons.add, color: Color(0xFF006565)),
                      label: const Text(
                        "Add More",
                        style: TextStyle(color: Color(0xFF006565), fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "Target Audience",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  audienceInputFocusNode.requestFocus();
                },
                child: Container(
                  constraints: const BoxConstraints(minHeight: 52),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.white,
                  ),
                  child: Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      ...selectedAudiences.map((audience) {
                        return Chip(
                          visualDensity: VisualDensity.compact,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                          label: Text(
                            audience,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF006565),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          backgroundColor: const Color(0xFF006565).withValues(alpha: 0.12),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: 16,
                            color: Color(0xFF006565),
                          ),
                          onDeleted: () {
                            setState(() {
                              selectedAudiences.remove(audience);
                            });
                          },
                        );
                      }),
                      IntrinsicWidth(
                        child: TextField(
                          controller: audienceInputController,
                          focusNode: audienceInputFocusNode,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: selectedAudiences.isEmpty ? "Tech Founders, NGOs" : "",
                            contentPadding: EdgeInsets.zero,
                            isDense: true,
                          ),
                          style: const TextStyle(fontSize: 14),
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              setState(() {
                                if (!selectedAudiences.contains(value.trim())) {
                                  selectedAudiences.add(value.trim());
                                }
                                audienceInputController.clear();
                              });
                            }
                          },
                          onChanged: (value) {
                            if (value.endsWith(',')) {
                              final text = value.substring(0, value.length - 1).trim();
                              if (text.isNotEmpty) {
                                setState(() {
                                  if (!selectedAudiences.contains(text)) {
                                    selectedAudiences.add(text);
                                  }
                                  audienceInputController.clear();
                                });
                              }
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Preferred Locations",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: currentPreferredLocationSelection,
                hint: const Text("Select Preferred Location"),
                decoration: const InputDecoration(
                  labelText: "Preferred Locations",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
                items: const [
                  DropdownMenuItem(value: "Remote", child: Text("Remote")),
                  DropdownMenuItem(value: "Bhagalpur", child: Text("Bhagalpur")),
                  DropdownMenuItem(value: "Jaipur", child: Text("Jaipur")),
                  DropdownMenuItem(value: "Kota", child: Text("Kota")),
                  DropdownMenuItem(value: "Patna", child: Text("Patna")),
                  DropdownMenuItem(value: "Mumbai", child: Text("Mumbai")),
                  DropdownMenuItem(value: "Bengaluru", child: Text("Bengaluru")),
                  DropdownMenuItem(value: "Delhi", child: Text("Delhi")),
                  DropdownMenuItem(value: "USA", child: Text("USA")),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      if (!selectedLocations.contains(value)) {
                        selectedLocations.add(value);
                      }
                      currentPreferredLocationSelection = null;
                    });
                  }
                },
              ),
              if (selectedLocations.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: selectedLocations.map((loc) {
                    return Chip(
                      visualDensity: VisualDensity.compact,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      label: Text(
                        loc,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Color(0xFF006565),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: const Color(0xFF006565).withValues(alpha: 0.12),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      deleteIcon: const Icon(
                        Icons.close,
                        size: 16,
                        color: Color(0xFF006565),
                      ),
                      onDeleted: () {
                        setState(() {
                          selectedLocations.remove(loc);
                        });
                      },
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 24),

              const Text(
                "Business Terms & Duration",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuillField(
                controller: termsQuillController,
                hint: "Duration, renewal, trial terms...",
                height: 200,
              ),
              const SizedBox(height: 24),

              const Text(
                "Expectations From Partner",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuillField(
                controller: expectationsQuillController,
                hint: "Promote, host, distribute, invest...",
                height: 200,
              ),
              const SizedBox(height: 24),

              const Text(
                "Who Can Apply?",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: preferredActions.map((action) {
                  final selected = selectedActions.contains(action);
                  return FilterChip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    label: Text(
                      action,
                      style: const TextStyle(fontSize: 11),
                    ),
                    selected: selected,
                    selectedColor: const Color(0xFF006565).withValues(alpha: 0.12),
                    checkmarkColor: const Color(0xFF006565),
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
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuillField(
                controller: eligibilityQuillController,
                hint: "Must be a registered business...",
                height: 200,
              ),
              const SizedBox(height: 24),

              const Text(
                "Prerequisites",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              _buildQuillField(
                controller: prerequisiteQuillController,
                hint: "Business license, NDA...",
                height: 200,
              ),
              const SizedBox(height: 24),

              const Text(
                "Supporting Material",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
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
                        color: Color(0xFF006565),
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
                spacing: 4,
                runSpacing: 4,
                children: uploadedFiles.map((file) {
                  return Chip(
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    side: BorderSide.none,
                    label: Text(
                      file,
                      style: const TextStyle(fontSize: 11),
                    ),
                    deleteIcon: const Icon(
                      Icons.close,
                      size: 16,
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
