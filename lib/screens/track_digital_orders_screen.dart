import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/theme/app_theme.dart';

class TrackDigitalOrdersScreen extends StatefulWidget {
  final bool isEmbedded;
  const TrackDigitalOrdersScreen({super.key, this.isEmbedded = false});

  @override
  State<TrackDigitalOrdersScreen> createState() => _TrackDigitalOrdersScreenState();
}

class _TrackDigitalOrdersScreenState extends State<TrackDigitalOrdersScreen> {
  final List<Map<String, dynamic>> digitalOrders = [
    {
      "id": "#ORD-DIG-9921",
      "title": "Creative Design Assets Pro",
      "category": "DESIGN ASSETS",
      "date": "Oct 28, 2023",
      "licenseKey": "DS-PRO-8829-109X-99AA",
      "downloadProgress": 1.0,
      "downloaded": true,
      "size": "1.2 GB",
    },
    {
      "id": "#ORD-DIG-9905",
      "title": "DevSuite Database Suite License",
      "category": "SOFTWARE SAAS",
      "date": "Oct 24, 2023",
      "licenseKey": "DEV-SAAS-9921-X109-8802",
      "downloadProgress": 0.45,
      "downloaded": false,
      "size": "650 MB",
    }
  ];

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("License key copied to clipboard!"), backgroundColor: AppTheme.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              title: const Text("Digital Product Orders", style: TextStyle(fontWeight: FontWeight.bold)),
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: digitalOrders.length,
        itemBuilder: (context, index) {
          final order = digitalOrders[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outline.withOpacity(0.4)),
              boxShadow: AppTheme.cardShadow,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: AppTheme.secondaryContainer, borderRadius: BorderRadius.circular(4)),
                      child: Text(order["category"], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                    ),
                    Text(order["id"], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(order["title"], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Purchased on ${order["date"]}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const Divider(height: 24),
                // License key
                const Text("LICENSE KEY", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      const Icon(Icons.vpn_key_outlined, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          order["licenseKey"],
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.copy, size: 16, color: AppTheme.primary),
                        onPressed: () => _copyToClipboard(order["licenseKey"]),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Download progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("DOWNLOAD STATUS", style: TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
                    Text(order["downloaded"] ? "Completed (${order["size"]})" : "Downloading (${(order["downloadProgress"] * 100).toStringAsFixed(0)}%)", style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: order["downloadProgress"],
                    backgroundColor: Colors.grey.shade100,
                    color: AppTheme.primary,
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Connecting to technical support..."), backgroundColor: AppTheme.primary),
                          );
                        },
                        icon: const Icon(Icons.support_agent, size: 16),
                        label: const Text("Get Help"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(order["downloaded"] ? "Accessing files locally..." : "Resuming download..."), backgroundColor: Colors.green),
                          );
                        },
                        icon: Icon(order["downloaded"] ? Icons.folder_open : Icons.play_arrow, size: 16),
                        label: Text(order["downloaded"] ? "Access Files" : "Resume"),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
