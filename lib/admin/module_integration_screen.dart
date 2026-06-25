import 'package:flutter/material.dart';

class ModuleIntegrationScreen extends StatefulWidget {
  final bool isEmbedded;
  const ModuleIntegrationScreen({super.key, this.isEmbedded = false});

  @override
  State<ModuleIntegrationScreen> createState() =>
      _ModuleIntegrationScreenState();
}

class _ModuleIntegrationScreenState
    extends State<ModuleIntegrationScreen> {

  bool autoSync = true;
  bool webhookEnabled = true;

  final TextEditingController webhookController =
      TextEditingController(
    text:
        "https://api.yourplatform.com/webhook",
  );

  final integrations = [
    IntegrationModel(
      name: "Marketplace Engine",
      status: true,
      icon: Icons.shopping_cart,
    ),
    IntegrationModel(
      name: "Job Portal Pro",
      status: true,
      icon: Icons.work,
    ),
    IntegrationModel(
      name: "Event Hub Connect",
      status: false,
      icon: Icons.event,
    ),
  ];

  @override
  void dispose() {
    webhookController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xffFCF9F8),

      appBar: widget.isEmbedded ? null : AppBar(
        title: const Text(
          "Module Integration",
        ),
        actions: [
          IconButton(
            icon:
                const Icon(Icons.refresh),
            onPressed: () {},
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              "Integration Center",
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              "Manage APIs, webhooks and module synchronization.",
            ),

            const SizedBox(height: 24),

            const Text(
              "Connected Modules",
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics:
                  const NeverScrollableScrollPhysics(),
              itemCount:
                  integrations.length,
              itemBuilder:
                  (context, index) {
                return IntegrationCard(
                  integration:
                      integrations[index],
                );
              },
            ),

            const SizedBox(height: 24),            Card(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(
                        16),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [

                    const Text(
                      "Webhook Configuration",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    TextField(
                      controller:
                          webhookController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            "Webhook URL",
                        prefixIcon:
                            Icon(Icons.link),
                      ),
                    ),

                    const SizedBox(
                        height: 16),

                    SwitchListTile(
                      value:
                          webhookEnabled,
                      title: const Text(
                        "Enable Webhooks",
                      ),
                      subtitle:
                          const Text(
                        "Receive real-time events",
                      ),
                      onChanged:
                          (value) {
                        setState(() {
                          webhookEnabled =
                              value;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                        16),
              ),
              child: Column(
                children: [

                  SwitchListTile(
                    value: autoSync,
                    title: const Text(
                      "Auto Sync",
                    ),
                    subtitle:
                        const Text(
                      "Automatically sync connected modules",
                    ),
                    onChanged:
                        (value) {
                      setState(() {
                        autoSync =
                            value;
                      });
                    },
                  ),

                  ListTile(
                    leading: const Icon(
                      Icons.schedule,
                    ),
                    title: const Text(
                      "Sync Frequency",
                    ),
                    subtitle:
                        const Text(
                      "Every 15 Minutes",
                    ),
                    trailing:
                        const Icon(
                      Icons.chevron_right,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Row(
              children: [

                Expanded(
                  child:
                      OutlinedButton.icon(
                    icon: const Icon(
                      Icons.wifi_protected_setup,
                    ),
                    label: const Text(
                      "Test Connection",
                    ),
                    onPressed: () {},
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child:
                      ElevatedButton.icon(
                    icon: const Icon(
                      Icons.save,
                    ),
                    label: const Text(
                      "Save",
                    ),
                    onPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class IntegrationModel {
  final String name;
  final bool status;
  final IconData icon;

  IntegrationModel({
    required this.name,
    required this.status,
    required this.icon,
  });
}

class IntegrationCard extends StatelessWidget {
  final IntegrationModel integration;

  const IntegrationCard({
    super.key,
    required this.integration,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin:
          const EdgeInsets.only(
              bottom: 12),
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
              const Color(0xffe5f7f7),
          child: Icon(
            integration.icon,
            color:
                const Color(0xFF006565),
          ),
        ),

        title:
            Text(integration.name),

        subtitle: Row(
          children: [

            Container(
              width: 8,
              height: 8,
              decoration:
                  BoxDecoration(
                color:
                    integration.status
                        ? Colors.green
                        : Colors.red,
                shape:
                    BoxShape.circle,
              ),
            ),

            const SizedBox(width: 6),

            Text(
              integration.status
                  ? "Connected"
                  : "Disconnected",
            ),
          ],
        ),

        trailing: IconButton(
          icon: const Icon(
            Icons.settings,
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}
