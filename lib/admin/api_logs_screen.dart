import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Database/Database.dart';

class ApiLogsScreen extends StatefulWidget {
  const ApiLogsScreen({super.key});

  @override
  State<ApiLogsScreen> createState() => _ApiLogsScreenState();
}

class _ApiLogsScreenState extends State<ApiLogsScreen> {
  String _searchQuery = "";

  void _clearLogs() {
    setState(() {
      Database.apiLogs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredLogs = Database.apiLogs.where((log) {
      final url = log['url']?.toString().toLowerCase() ?? '';
      final body = log['body']?.toString().toLowerCase() ?? '';
      final query = _searchQuery.toLowerCase();
      return url.contains(query) || body.contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          "API Transaction Logs",
          style: TextStyle(
            color: Color(0xFF006565),
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF006565)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined, color: Colors.red),
            onPressed: _clearLogs,
            tooltip: "Clear Logs",
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Color(0xFF006565)),
                hintText: "Search logs by endpoint or body payload...",
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                filled: true,
                fillColor: const Color(0xFFF4F3F3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: filteredLogs.isEmpty
                ? const Center(
                    child: Text(
                      "No matching API logs found",
                      style: TextStyle(color: Color(0xFF757575)),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      final bool isSuccess = log['statusCode'] == 200;
                      final url = log['url'] ?? '';
                      final endpointName = Uri.parse(url).queryParameters['endpoint'] ?? url;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 1,
                        child: ExpansionTile(
                          leading: Container(
                            width: 48,
                            height: 32,
                            decoration: BoxDecoration(
                              color: isSuccess ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Center(
                              child: Text(
                                log['statusCode'].toString(),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isSuccess ? Colors.green : Colors.red,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          title: Text(
                            endpointName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          subtitle: Text(
                            log['timestamp']?.toString().split('.').first ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF757575),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLogDetailItem("Full URL", log['url'] ?? ''),
                                  _buildLogDetailItem("Headers", log['headers'] ?? ''),
                                  _buildLogDetailItem("Request Payload", log['body'] ?? ''),
                                  if (log['error'].toString().isNotEmpty)
                                    _buildLogDetailItem("Exception/Error", log['error'] ?? '', valColor: Colors.red),
                                  _buildLogDetailItem("Raw Response", log['response'] ?? ''),
                                ],
                              ),
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
  }

  Widget _buildLogDetailItem(String title, String val, {Color? valColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Color(0xFF006565),
                letterSpacing: 0.5,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.copy_rounded, size: 14, color: Color(0xFF757575)),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: val));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("$title copied to clipboard!"),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3F3),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            val.isEmpty ? "(empty)" : val,
            style: TextStyle(
              fontSize: 11,
              fontFamily: "monospace",
              color: valColor ?? const Color(0xFF1A1C1C),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
