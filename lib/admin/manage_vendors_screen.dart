import 'package:flutter/material.dart';

class ManageVendorsScreen extends StatefulWidget {
  final bool isEmbedded;
  const ManageVendorsScreen({super.key, this.isEmbedded = false});

  @override
  State<ManageVendorsScreen> createState() => _ManageVendorsScreenState();
}

class _ManageVendorsScreenState extends State<ManageVendorsScreen> {
  // Styling Theme Constants
  static const Color primaryTeal = Color(0xFF008080);
  static const Color secondaryTeal = Color(0xFF296767);
  static const Color containerTeal = Color(0xFFE3FFFE);
  static const Color bgLight = Color(0xFFF9F9F9);
  static const Color surfaceWhite = Colors.white;
  static const Color borderTeal = Color(0xFFBDC9C8);
  static const Color textDark = Color(0xFF1C1B1B);
  static const Color textLight = Color(0xFF3E4949);
  static const Color statusNegotiation = Color(0xFFB45309);
  static const Color errorColor = Color(0xFFBA1A1A);

  String _searchQuery = "";
  String _activePlan = "Silver Tier"; // Silver Tier, Gold Tier, Elite Tier

  // Mock list of pending reviews
  final List<Map<String, String>> _pendingReviews = [
    {
      "id": "pending-1",
      "name": "Lumina Creatives",
      "category": "Branding & Digital Strategy",
      "date": "24 Oct 2023"
    },
    {
      "id": "pending-2",
      "name": "Swift Transit Co.",
      "category": "Logistics & Courier",
      "date": "22 Oct 2023"
    },
    {
      "id": "pending-3",
      "name": "Zenith Events",
      "category": "Hospitality Management",
      "date": "20 Oct 2023"
    }
  ];

  // Mock list of active directory vendors
  final List<Map<String, dynamic>> _activeVendors = [
    {
      "name": "Global Meridian",
      "tier": "Tier 1 Strategic",
      "email": "meridian@global.com",
      "phone": "+1 888 234 567",
      "joined": "12 Aug 2023",
      "status": "Active",
      "verified": true,
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuDalpMFTivchBVCaM_9uR8XORb1hl-T7FL8ZXyRRkxysV6mp8QAP1SLA8PzL2c0C4Hm8fcgTmqoD6u0CUFo6bWeL5-gWwAeUEmhHeq0qo1fvYpfZFcqGpMXsA1zaQiP9gVy_DybevrhXchNNVfGKsbC-_uIIivV-ZzEh2LO73OyIsDkxRhGJf9ehvc9TcBKMfVMcvho9nXdz_hEbhz3BK-zJoTcqWINS3hlwtNfSRjuWWDhrXzd8w0C"
    },
    {
      "name": "EcoScale Dynamics",
      "tier": "Sustainability Advisory",
      "email": "hello@ecoscale.io",
      "phone": "+44 20 7946 0123",
      "joined": "05 Sep 2023",
      "status": "Active",
      "verified": true,
      "imageUrl": "https://lh3.googleusercontent.com/aida-public/AB6AXuCg7hZKQDnwQsba8Xj1LyP_uQm3y26Zhh-R4W4XV27aSwzI_AQ0CLmzcTk98FCbIWBrQKBgk24ckqQNP6_kDuWOO8z9fsC7mZJ05r9BfMjQPoBBy_s6FUiASb4Z-ssnPDLMG-LNoK1n262f1FmtZlacW8UryNJbWsy73Q8Jup0XlDjwNfDpEh7hLfcFCrUR2yH3QJQtwL_c6PniS0SvmbRt5Kubms0NfAuSOBnKKgYwKYJkT0enmX7R"
    }
  ];

  void _triggerAction(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(msg, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
          ],
        ),
        backgroundColor: primaryTeal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _onboardNewVendor() {
    final nameCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    String vendorType = "Strategic Partner";
    String selectedPlan = "Tier 1 - Global Executive";
    bool createAccount = false;
    bool onboardingSuccess = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Dialog(
              backgroundColor: surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: onboardingSuccess
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                color: containerTeal,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_circle_rounded, color: primaryTeal, size: 40),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              "Vendor Onboarded!",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "The invitation and dossier setup instructions have been sent successfully.",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12, color: textLight),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(double.infinity, 44),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("DONE", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                            decoration: const BoxDecoration(
                              color: primaryTeal,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Onboard New Vendor",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              ],
                            ),
                          ),

                          // Form Content
                          Flexible(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("VENDOR TYPE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: vendorType,
                                    style: const TextStyle(fontSize: 13, color: textDark),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: "Strategic Partner", child: Text("Strategic Partner")),
                                      DropdownMenuItem(value: "Logistics Provider", child: Text("Logistics Provider")),
                                      DropdownMenuItem(value: "Curated Agency", child: Text("Curated Agency")),
                                      DropdownMenuItem(value: "Legal Advisory", child: Text("Legal Advisory")),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => vendorType = val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  const Text("FULL NAME / COMPANY NAME", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: nameCtrl,
                                    style: const TextStyle(fontSize: 13),
                                    decoration: const InputDecoration(
                                      hintText: "Enter name...",
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text("EMAIL", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                            const SizedBox(height: 6),
                                            TextField(
                                              controller: emailCtrl,
                                              style: const TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.emailAddress,
                                              decoration: const InputDecoration(
                                                hintText: "email@serene.com",
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                                            const Text("MOBILE NO", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                            const SizedBox(height: 6),
                                            TextField(
                                              controller: phoneCtrl,
                                              style: const TextStyle(fontSize: 13),
                                              keyboardType: TextInputType.phone,
                                              decoration: const InputDecoration(
                                                hintText: "+1...",
                                                border: OutlineInputBorder(),
                                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  const Text("MEMBERSHIP PLAN", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                                  const SizedBox(height: 6),
                                  DropdownButtonFormField<String>(
                                    value: selectedPlan,
                                    style: const TextStyle(fontSize: 13, color: textDark),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                    ),
                                    items: const [
                                      DropdownMenuItem(value: "Tier 1 - Global Executive", child: Text("Tier 1 - Global Executive")),
                                      DropdownMenuItem(value: "Tier 2 - Regional Professional", child: Text("Tier 2 - Regional Professional")),
                                      DropdownMenuItem(value: "Tier 3 - Essential Member", child: Text("Tier 3 - Essential Member")),
                                    ],
                                    onChanged: (val) {
                                      if (val != null) setModalState(() => selectedPlan = val);
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  Row(
                                    children: [
                                      Checkbox(
                                        value: createAccount,
                                        activeColor: primaryTeal,
                                        onChanged: (val) {
                                          if (val != null) setModalState(() => createAccount = val);
                                        },
                                      ),
                                      const Expanded(
                                        child: Text(
                                          "Create professional account and send invite",
                                          style: TextStyle(fontSize: 11, color: textLight),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),

                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text("CANCEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: primaryTeal,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(vertical: 12),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          onPressed: () {
                                            if (nameCtrl.text.trim().isEmpty || emailCtrl.text.trim().isEmpty) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text("Name and Email are required.")),
                                              );
                                              return;
                                            }
                                            // Perform dynamic onboarding update
                                            setState(() {
                                              _activeVendors.insert(0, {
                                                "name": nameCtrl.text.trim(),
                                                "tier": vendorType,
                                                "email": emailCtrl.text.trim(),
                                                "phone": phoneCtrl.text.trim().isEmpty ? "+1 555-0199" : phoneCtrl.text.trim(),
                                                "joined": "Just Now",
                                                "status": "Active",
                                                "verified": false,
                                                "imageUrl": ""
                                              });
                                            });

                                            setModalState(() {
                                              onboardingSuccess = true;
                                            });
                                          },
                                          child: const Text("CREATE ACCOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                        ),
                                      ),
                                    ],
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
        );
      },
    );
  }

  void _openProfileModal(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Vendor Profile",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: bgLight,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: borderTeal.withOpacity(0.5)),
                            ),
                            child: vendor["imageUrl"] != null && (vendor["imageUrl"] as String).isNotEmpty
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(9),
                                    child: Image.network(vendor["imageUrl"], fit: BoxFit.cover),
                                  )
                                : const Icon(Icons.storefront_rounded, color: primaryTeal, size: 30),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vendor["name"] ?? '',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  vendor["tier"] ?? '',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryTeal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("TOTAL PROJECTS", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
                                  SizedBox(height: 4),
                                  Text("128", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: bgLight,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("RATING", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Text("4.9", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark)),
                                      SizedBox(width: 4),
                                      Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      const Text("BIO & DOSSIER", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                      const SizedBox(height: 6),
                      const Text(
                        "Leading international logistics and strategic supply chain management firm specializing in high-value asset transportation and global meridian navigation systems. Established 2018.",
                        style: TextStyle(fontSize: 12, color: textLight, height: 1.4),
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 44),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CLOSE PROFILE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openTeamModal(Map<String, dynamic> vendor) {
    String selectedTeam = "Strategy";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              backgroundColor: surfaceWhite,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              titlePadding: const EdgeInsets.all(20),
              contentPadding: const EdgeInsets.symmetric(horizontal: 20),
              actionsPadding: const EdgeInsets.all(20),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Assign to Team", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
                  const SizedBox(height: 4),
                  Text("Assign ${vendor['name']} to a project team", style: const TextStyle(fontSize: 12, color: textLight)),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<String>(
                    value: "Strategy",
                    groupValue: selectedTeam,
                    activeColor: primaryTeal,
                    title: Row(
                      children: const [
                        Icon(Icons.insights, color: primaryTeal, size: 20),
                        SizedBox(width: 12),
                        Text("Strategy & Growth", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedTeam = val);
                    },
                  ),
                  RadioListTile<String>(
                    value: "Operations",
                    groupValue: selectedTeam,
                    activeColor: primaryTeal,
                    title: Row(
                      children: const [
                        Icon(Icons.precision_manufacturing_rounded, color: primaryTeal, size: 20),
                        SizedBox(width: 12),
                        Text("Operations", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedTeam = val);
                    },
                  ),
                  RadioListTile<String>(
                    value: "Marketing",
                    groupValue: selectedTeam,
                    activeColor: primaryTeal,
                    title: Row(
                      children: const [
                        Icon(Icons.campaign_rounded, color: primaryTeal, size: 20),
                        SizedBox(width: 12),
                        Text("Marketing", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                      ],
                    ),
                    onChanged: (val) {
                      if (val != null) setModalState(() => selectedTeam = val);
                    },
                  ),
                ],
              ),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("CANCEL", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryTeal,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          _triggerAction("Assigned to team successfully");
                        },
                        child: const Text("CONFIRM", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openSuspendModal(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: errorColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, color: errorColor, size: 32),
              ),
              const SizedBox(height: 16),
              const Text("Suspend Vendor?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
              const SizedBox(height: 8),
              Text(
                "Are you sure you want to suspend ${vendor['name']}? They will lose access to the portal immediately.",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: textLight),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("KEEP ACTIVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: errorColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () {
                        setState(() {
                          vendor['status'] = "Suspended";
                        });
                        Navigator.pop(context);
                        _triggerAction("Vendor suspended");
                      },
                      child: const Text("SUSPEND NOW", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDocsModal(Map<String, dynamic> vendor) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: primaryTeal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Verification Dossier",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("OPERATING LICENSE - 2024", style: TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          color: bgLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: borderTeal, width: 2, style: BorderStyle.solid),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.description_rounded, color: borderTeal, size: 48),
                            SizedBox(height: 8),
                            Text("CERT_CORP_00912.pdf", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textDark)),
                            SizedBox(height: 2),
                            Text("UPLOADED 12 OCT 2023", style: TextStyle(fontSize: 9, color: textLight)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: containerTeal.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline, color: primaryTeal, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text("Review Required", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryTeal)),
                                  SizedBox(height: 2),
                                  Text(
                                    "Verify that the digital watermark and expiration dates match the current regional registry standards.",
                                    style: TextStyle(fontSize: 11, color: textLight, height: 1.3),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: errorColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _triggerAction("Document Rejected");
                              },
                              icon: const Icon(Icons.cancel_outlined, size: 16),
                              label: const Text("REJECT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _triggerAction("Document Approved");
                              },
                              icon: const Icon(Icons.verified_outlined, size: 16),
                              label: const Text("APPROVE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openContactModal(String name) {
    final msgCtrl = TextEditingController(
      text: "Hello $name, we are reviewing your application for Serene Commerce. We require some additional documentation regarding your regional compliance certifications. Please provide them at your earliest convenience.",
    );

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: surfaceWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: containerTeal,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Contact Vendor",
                        style: TextStyle(color: primaryTeal, fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Manrope'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: primaryTeal, size: 20),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("RECIPIENT", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                      const SizedBox(height: 6),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          name,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                        ),
                      ),
                      const SizedBox(height: 16),

                      const Text("MESSAGE", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textLight)),
                      const SizedBox(height: 6),
                      TextField(
                        controller: msgCtrl,
                        maxLines: 5,
                        style: const TextStyle(fontSize: 13),
                        decoration: const InputDecoration(
                          hintText: "Write your message here...",
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              style: OutlinedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                              onPressed: () => Navigator.pop(context),
                              child: const Text("CLOSE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                _triggerAction("Message Sent Successfully!");
                              },
                              icon: const Icon(Icons.send_rounded, size: 14),
                              label: const Text("SEND MESSAGE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _approvePending(Map<String, String> review) {
    setState(() {
      _pendingReviews.removeWhere((item) => item['id'] == review['id']);
      _activeVendors.insert(0, {
        "name": review["name"] ?? '',
        "tier": "Tier 1 Strategic",
        "email": "${review['name']?.replaceAll(' ', '').toLowerCase()}@serene.com",
        "phone": "+1 888 234 567",
        "joined": "Just Now",
        "status": "Active",
        "verified": false,
        "imageUrl": ""
      });
    });
    _triggerAction("Approved: ${review['name']} added to directory");
  }

  void _rejectPending(Map<String, String> review) {
    setState(() {
      _pendingReviews.removeWhere((item) => item['id'] == review['id']);
    });
    _triggerAction("Application for ${review['name']} rejected");
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 700;

    final filteredVendors = _activeVendors.where((v) {
      final name = (v["name"] as String).toLowerCase();
      final tier = (v["tier"] as String).toLowerCase();
      final email = (v["email"] as String).toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || tier.contains(query) || email.contains(query);
    }).toList();

    Widget mainContent = SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          isMobile
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "VIRTUAL DIRECTORY",
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Manage Vendors",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Oversee strategic partnerships and manage your professional network dossier.",
                      style: TextStyle(fontSize: 12, color: textLight),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 44),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _onboardNewVendor,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text("Onboard New Vendor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "VIRTUAL DIRECTORY",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryTeal, letterSpacing: 1.5),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Manage Vendors",
                            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope'),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Oversee strategic partnerships and manage your professional network dossier.",
                            style: TextStyle(fontSize: 12, color: textLight),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _onboardNewVendor,
                      icon: const Icon(Icons.add_rounded, size: 20),
                      label: const Text("Onboard New Vendor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
          const SizedBox(height: 24),

          // 1. Membership Plans Section
          const Text("Membership Plans", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPlanCard(
                  tier: "Silver Tier",
                  badge: "BASIC",
                  badgeColor: textLight,
                  badgeBg: borderTeal.withOpacity(0.3),
                  price: "₹49",
                  rate: "5% Commission Rate",
                  isActive: _activePlan == "Silver Tier",
                  onSelect: () => setState(() => _activePlan = "Silver Tier"),
                ),
                _buildPlanCard(
                  tier: "Gold Tier",
                  badge: "POPULAR",
                  badgeColor: Colors.black,
                  badgeBg: Colors.yellow,
                  price: "₹99",
                  rate: "15% Commission Earned",
                  isActive: _activePlan == "Gold Tier",
                  isPremium: true,
                  bannerText: "Upgrade to earn more",
                  bannerIcon: Icons.trending_up,
                  onSelect: () => setState(() => _activePlan = "Gold Tier"),
                ),
                _buildPlanCard(
                  tier: "Elite Tier",
                  badge: "PREMIUM",
                  badgeColor: Colors.white,
                  badgeBg: textDark,
                  price: "₹249",
                  rate: "25% Commission Earned",
                  isActive: _activePlan == "Elite Tier",
                  bannerText: "VIP Support Access",
                  bannerIcon: Icons.star,
                  onSelect: () => setState(() => _activePlan = "Elite Tier"),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Pending Reviews Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Pending Reviews", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryTeal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "${_pendingReviews.length} New",
                  style: const TextStyle(fontSize: 9, color: primaryTeal, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_pendingReviews.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceWhite,
                border: Border.all(color: borderTeal.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "No pending reviews remaining for this period.",
                  style: TextStyle(fontSize: 13, color: textLight, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: _pendingReviews.map((rev) => _buildPendingCard(rev)).toList(),
              ),
            ),
          const SizedBox(height: 24),

          // 3. Search & Filter
          Container(
            decoration: BoxDecoration(
              color: surfaceWhite,
              border: Border.all(color: borderTeal),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
            ),
            child: TextField(
              style: const TextStyle(fontSize: 14),
              decoration: const InputDecoration(
                hintText: "Search vendor dossier...",
                prefixIcon: Icon(Icons.search_rounded, color: textLight),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onChanged: (val) {
                setState(() {
                  _searchQuery = val;
                });
              },
            ),
          ),
          const SizedBox(height: 24),

          // 4. Active Directory
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("Active Directory", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark, fontFamily: 'Manrope')),
            ],
          ),
          const SizedBox(height: 12),
          if (filteredVendors.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: surfaceWhite,
                border: Border.all(color: borderTeal.withOpacity(0.5)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  "No vendors found matching your query.",
                  style: TextStyle(fontSize: 13, color: textLight, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                border: Border.all(color: borderTeal),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredVendors.length,
                itemBuilder: (context, idx) {
                  final vendor = filteredVendors[idx];
                  final isSuspended = vendor['status'] == "Suspended";

                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: borderTeal.withOpacity(0.5),
                          width: idx == filteredVendors.length - 1 ? 0 : 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Avatar
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: bgLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: borderTeal.withOpacity(0.5)),
                          ),
                          child: vendor["imageUrl"] != null && (vendor["imageUrl"] as String).isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(7),
                                  child: Image.network(vendor["imageUrl"], fit: BoxFit.cover),
                                )
                              : const Icon(Icons.storefront_rounded, color: primaryTeal, size: 24),
                        ),
                        const SizedBox(width: 14),

                        // Name & details
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      vendor["name"] ?? '',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                        color: isSuspended ? textLight : textDark,
                                        decoration: isSuspended ? TextDecoration.lineThrough : null,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  if (vendor["verified"] == true) ...[
                                    const SizedBox(width: 4),
                                    const Icon(Icons.verified, color: primaryTeal, size: 14),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                "Tier: ${vendor['tier']} • Email: ${vendor['email']}",
                                style: const TextStyle(fontSize: 10, color: textLight),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),

                        // Action icons or dropdown menu
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (!isSuspended) ...[
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: primaryTeal, size: 20),
                                tooltip: "View Documents",
                                onPressed: () => _openDocsModal(vendor),
                              ),
                            ],
                            PopupMenuButton<String>(
                              icon: const Icon(Icons.more_vert_rounded, color: textLight),
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: "profile", child: Text("View Profile", style: TextStyle(fontSize: 13))),
                                const PopupMenuItem(value: "team", child: Text("Add to Team", style: TextStyle(fontSize: 13))),
                                const PopupMenuItem(value: "contact", child: Text("Contact", style: TextStyle(fontSize: 13))),
                                const PopupMenuItem(value: "docs", child: Text("View Documents", style: TextStyle(fontSize: 13))),
                                const PopupMenuDivider(),
                                PopupMenuItem(
                                  value: "suspend",
                                  child: Text(
                                    isSuspended ? "Re-activate" : "Suspend",
                                    style: TextStyle(fontSize: 13, color: isSuspended ? primaryTeal : errorColor),
                                  ),
                                ),
                              ],
                              onSelected: (action) {
                                if (action == "profile") {
                                  _openProfileModal(vendor);
                                } else if (action == "team") {
                                  _openTeamModal(vendor);
                                } else if (action == "contact") {
                                  _openContactModal(vendor['name']);
                                } else if (action == "docs") {
                                  _openDocsModal(vendor);
                                } else if (action == "suspend") {
                                  if (isSuspended) {
                                    setState(() {
                                      vendor['status'] = "Active";
                                    });
                                    _triggerAction("Vendor re-activated successfully");
                                  } else {
                                    _openSuspendModal(vendor);
                                  }
                                }
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );

    if (widget.isEmbedded) {
      return mainContent;
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text("Manage Vendors", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: secondaryTeal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(child: mainContent),
    );
  }

  Widget _buildPlanCard({
    required String tier,
    required String badge,
    required Color badgeColor,
    required Color badgeBg,
    required String price,
    required String rate,
    required bool isActive,
    bool isPremium = false,
    String? bannerText,
    IconData? bannerIcon,
    required VoidCallback onSelect,
  }) {
    return Container(
      width: 270,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: isPremium ? primaryTeal : surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      tier,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: isPremium ? Colors.white : textDark,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: badgeColor,
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      price,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: isPremium ? Colors.white : primaryTeal,
                      ),
                    ),
                    Text(
                      "/mo",
                      style: TextStyle(
                        fontSize: 12,
                        color: isPremium ? Colors.white.withOpacity(0.7) : textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  rate,
                  style: TextStyle(
                    fontSize: 11,
                    color: isPremium ? Colors.white.withOpacity(0.8) : textLight,
                  ),
                ),
                const SizedBox(height: 16),

                if (bannerText != null && bannerIcon != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: isPremium ? Colors.white.withOpacity(0.15) : containerTeal,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          bannerIcon,
                          color: isPremium ? Colors.white : primaryTeal,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          bannerText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isPremium ? Colors.white : primaryTeal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                SizedBox(
                  width: double.infinity,
                  height: 36,
                  child: isActive
                      ? OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: isPremium ? Colors.white : primaryTeal),
                            foregroundColor: isPremium ? Colors.white : primaryTeal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: null,
                          child: const Text("Active Plan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        )
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPremium ? Colors.white : primaryTeal,
                            foregroundColor: isPremium ? primaryTeal : Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: onSelect,
                          child: const Text("Select Plan", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPendingCard(Map<String, String> review) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16, bottom: 4),
      decoration: BoxDecoration(
        color: surfaceWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderTeal.withOpacity(0.6)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  review["name"] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                review["date"] ?? '',
                style: const TextStyle(fontSize: 9, color: textLight, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            review["category"] ?? '',
            style: const TextStyle(fontSize: 11, color: textLight),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: () => _approvePending(review),
                    child: const Text("Approve", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _openContactModal(review["name"] ?? ''),
                  child: const Icon(Icons.mail_outline_rounded, color: textLight, size: 16),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                width: 36,
                height: 32,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    foregroundColor: errorColor,
                    side: const BorderSide(color: borderTeal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _rejectPending(review),
                  child: const Icon(Icons.close_rounded, color: errorColor, size: 16),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
