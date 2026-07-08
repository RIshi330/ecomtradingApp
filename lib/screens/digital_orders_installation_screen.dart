import 'dart:async';
import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/core/theme/app_theme.dart';

class DigitalOrdersInstallationScreen extends StatefulWidget {
  final String orderId;
  final double amount;
  final String productName;

  const DigitalOrdersInstallationScreen({
    super.key,
    required this.orderId,
    required this.amount,
    required this.productName,
  });

  @override
  State<DigitalOrdersInstallationScreen> createState() => _DigitalOrdersInstallationScreenState();
}

class _DigitalOrdersInstallationScreenState extends State<DigitalOrdersInstallationScreen> {
  // Domain Configuration States
  bool hasDomain = true;
  final TextEditingController domainController = TextEditingController(text: "pending.serene.com");
  final TextEditingController vanityController = TextEditingController(text: "serene-shop");
  
  String currentDomain = "pending.serene.com";
  String websiteStatus = "Missing"; // Missing, Installing, Live
  double deploymentProgress = 0.0;
  int deploymentStep = 1;
  String deploymentStepText = "Initializing...";

  bool isDeploying = false;

  void _saveDomainSettings() {
    setState(() {
      currentDomain = hasDomain ? domainController.text : "${vanityController.text}.serene.com";
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Domain settings updated to: $currentDomain"),
        backgroundColor: const Color(0xFF006565),
      ),
    );
  }

  void _startDeploymentAnimation() {
    setState(() {
      isDeploying = true;
      deploymentProgress = 0.0;
      deploymentStep = 1;
      websiteStatus = "Installing";
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogStateContext, setDialogState) {
            Timer? timer;
            
            // Start local periodic tick to simulate deployment progress
            if (timer == null) {
              const tick = Duration(milliseconds: 150);
              timer = Timer.periodic(tick, (t) {
                if (!mounted || !isDeploying) {
                  t.cancel();
                  return;
                }
                
                setDialogState(() {
                  deploymentProgress += 0.02;
                  if (deploymentProgress >= 1.0) {
                    deploymentProgress = 1.0;
                    t.cancel();
                    
                    // Finish deployment
                    Future.delayed(const Duration(milliseconds: 500), () {
                      if (mounted) {
                        Navigator.pop(dialogContext); // Close modal
                        setState(() {
                          isDeploying = false;
                          websiteStatus = "Live";
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Website deployed successfully! Status is now LIVE."),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    });
                  }

                  // Update steps based on progress percent
                  if (deploymentProgress < 0.3) {
                    deploymentStep = 1;
                    deploymentStepText = "Selecting Components...";
                  } else if (deploymentProgress < 0.6) {
                    deploymentStep = 2;
                    deploymentStepText = "Writing Codes & Configuration...";
                  } else if (deploymentProgress < 0.85) {
                    deploymentStep = 3;
                    deploymentStepText = "Migrating Database & Schema...";
                  } else {
                    deploymentStep = 4;
                    deploymentStepText = "Verifying Services & DNS...";
                  }
                });
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              contentPadding: const EdgeInsets.all(24),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "System Deployment",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  IconButton(
                    onPressed: () {
                      timer?.cancel();
                      setState(() {
                        isDeploying = false;
                        websiteStatus = "Missing";
                      });
                      Navigator.pop(dialogContext);
                    },
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        deploymentStepText,
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF006565), fontSize: 13),
                      ),
                      Text(
                        "Step $deploymentStep of 4",
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: deploymentProgress,
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF006565)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Step 1 status line
                  _buildModalStepRow(
                    stepNum: "1",
                    title: "Selecting Components",
                    isActive: deploymentStep == 1,
                    isDone: deploymentStep > 1,
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 2 status line
                  _buildModalStepRow(
                    stepNum: "2",
                    title: "Writing Codes",
                    isActive: deploymentStep == 2,
                    isDone: deploymentStep > 2,
                    subtitle: "Injecting core logic and security wrappers...",
                  ),
                  const SizedBox(height: 12),
                  
                  // Step 3 status line
                  _buildModalStepRow(
                    stepNum: "3",
                    title: "Database Migration",
                    isActive: deploymentStep == 3,
                    isDone: deploymentStep > 3,
                  ),
                  const SizedBox(height: 12),

                  // Step 4 status line
                  _buildModalStepRow(
                    stepNum: "4",
                    title: "Final Verification",
                    isActive: deploymentStep == 4,
                    isDone: deploymentProgress >= 1.0,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.pop(dialogContext); // Background mode
                  },
                  child: const Text("Run in Background", style: TextStyle(color: Colors.grey)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildModalStepRow({
    required String stepNum,
    required String title,
    required bool isActive,
    required bool isDone,
    String? subtitle,
  }) {
    double opacity = 0.3;
    if (isActive) opacity = 1.0;
    if (isDone) opacity = 0.6;

    return Opacity(
      opacity: opacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone ? const Color(0xFF006565) : (isActive ? const Color(0xFF006565) : Colors.transparent),
              border: Border.all(color: const Color(0xFF006565), width: 1.5),
            ),
            alignment: Alignment.center,
            child: isDone
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    stepNum,
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF006565),
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                if (subtitle != null && isActive)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text("Command Center", style: TextStyle(fontWeight: FontWeight.bold, color: primaryColor)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Overview Bento Card
            _buildOverviewCard(primaryColor),
            const SizedBox(height: 16),

            // Domain Registry Config Card
            _buildDomainRegistryCard(primaryColor),
            const SizedBox(height: 16),

            // Installation Details Card
            _buildInstallationStatusCard(primaryColor),
            const SizedBox(height: 24),

            // Purchased Modules List
            const Text(
              "Purchased Modules",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            _buildModulesGrid(primaryColor),
            const SizedBox(height: 24),

            // Pre-Installation Checklist
            _buildChecklistCard(primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(left: BorderSide(color: Color(0xFF008080), width: 4)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "ORDER OVERVIEW",
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.productName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 2),
                      Text("Order ID: #${widget.orderId}", style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: websiteStatus == "Live"
                        ? Colors.green.shade50
                        : (websiteStatus == "Installing" ? Colors.blue.shade50 : Colors.amber.shade50),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: websiteStatus == "Live"
                          ? Colors.green.shade200
                          : (websiteStatus == "Installing" ? Colors.blue.shade200 : Colors.amber.shade200),
                    ),
                  ),
                  child: Text(
                    websiteStatus == "Live" ? "Completed" : (websiteStatus == "Installing" ? "Deploying" : "Processing"),
                    style: TextStyle(
                      color: websiteStatus == "Live"
                          ? Colors.green.shade700
                          : (websiteStatus == "Installing" ? Colors.blue.shade700 : const Color(0xFFB45309)),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("PURCHASE DATE", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      "${DateTime.now().day} ${_getMonthName(DateTime.now().month)}, ${DateTime.now().year}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text("TOTAL AMOUNT", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 2),
                    Text(
                      "₹${widget.amount.toStringAsFixed(0)}",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: primaryColor),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDomainRegistryCard(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.language, color: Color(0xFF008080)),
                SizedBox(width: 8),
                Text(
                  "Domain Registry",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "DO YOU HAVE A REGISTERED DOMAIN?",
              style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Row(
                  children: [
                    Radio<bool>(
                      value: true,
                      groupValue: hasDomain,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          hasDomain = val ?? true;
                        });
                      },
                    ),
                    const Text("Yes", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(width: 24),
                Row(
                  children: [
                    Radio<bool>(
                      value: false,
                      groupValue: hasDomain,
                      activeColor: primaryColor,
                      onChanged: (val) {
                        setState(() {
                          hasDomain = val ?? false;
                        });
                      },
                    ),
                    const Text("No", style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (hasDomain) ...[
              const Row(
                children: [
                  Text("DOMAIN NAME", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
                  SizedBox(width: 4),
                  Icon(Icons.info_outline, size: 12, color: Colors.grey),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: domainController,
                decoration: InputDecoration(
                  hintText: "e.g. example.com",
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ] else ...[
              const Text("VANITY URL", style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: vanityController,
                      textAlign: TextAlign.right,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(".serene.com", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey)),
                ],
              ),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: _saveDomainSettings,
                child: const Text("Save Domain Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstallationStatusCard(Color primaryColor) {
    bool isLive = websiteStatus == "Live";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      color: const Color(0xFFF4F3F3),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isLive ? Icons.check_circle : Icons.warning_amber_rounded,
                  color: isLive ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  isLive ? "Website Live & Active" : "Installation Pending",
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Domain:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                Text(currentDomain, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Status:", style: TextStyle(fontSize: 13, color: Colors.black54)),
                Row(
                  children: [
                    Icon(
                      isLive ? Icons.cloud_done : Icons.cloud_off,
                      color: isLive ? Colors.green : Colors.red,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      isLive ? "Live" : "Missing",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isLive ? Colors.green : Colors.red),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 16),
            const Text(
              "STATUS OVERVIEW",
              style: TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildStatusDotIndicator("Domain Status", Colors.amber.shade100, const Color(0xFFB45309)),
                const SizedBox(width: 16),
                _buildStatusDotIndicator(
                  "Website Status",
                  isLive ? Colors.green.shade100 : Colors.grey.shade300,
                  isLive ? Colors.green : Colors.grey.shade600,
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: isLive ? null : _startDeploymentAnimation,
                child: Text(
                  isLive ? "WEBSITE INSTALLED" : "INSTALL WEBSITE",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusDotIndicator(String label, Color bgColor, Color borderDotColor) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: borderDotColor),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildModulesGrid(Color primaryColor) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 0.82,
      children: [
        _buildModuleCard(
          category: "Security",
          tag: "New",
          title: "User Authentication",
          desc: "OAuth 2.0 & Multi-factor auth layers.",
          primaryColor: primaryColor,
        ),
        _buildModuleCard(
          category: "Database",
          tag: "Active",
          title: "Backup & Restore",
          desc: "Automated daily snaps & cloud sync.",
          primaryColor: primaryColor,
        ),
      ],
    );
  }

  Widget _buildModuleCard({
    required String category,
    required String tag,
    required String title,
    required String desc,
    required Color primaryColor,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  category.toUpperCase(),
                  style: const TextStyle(fontSize: 8, color: Colors.grey, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEEEED),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(fontSize: 8, color: Colors.black54, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: Text(
                desc,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 32,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: () {},
                      child: const Text("Integrate", style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFBDC9C8)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.info_outline, size: 16, color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistCard(Color primaryColor) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFBDC9C8)),
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pre-Installation Checklist",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildChecklistItem("Ensure custom domain is pointed to Serene NS records."),
            const SizedBox(height: 8),
            _buildChecklistItem("Minimum PHP 8.1 compatibility for backend integration."),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFBDC9C8)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {},
                child: const Text("Download PDF Checklist", style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 11)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklistItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Color(0xFF008080), size: 16),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  String _getMonthName(int month) {
    const months = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
    return months[month - 1];
  }
}
