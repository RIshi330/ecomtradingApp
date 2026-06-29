import 'package:flutter/material.dart';

class SellerManagementScreen extends StatefulWidget {
  final bool isEmbedded;
  const SellerManagementScreen({super.key, this.isEmbedded = false});

  @override
  State<SellerManagementScreen> createState() =>
      _SellerManagementScreenState();
}

class _SellerManagementScreenState
    extends State<SellerManagementScreen> {

  int currentIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFCF9F8),

      drawer: widget.isEmbedded ? null : Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xff006565),
              ),
              child: Text(
                "Serene Admin",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: const Text("Dashboard"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.storefront),
              title: const Text("Sellers"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text("Orders"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.inventory_2),
              title: const Text("Inventory"),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),

      appBar: widget.isEmbedded ? null : AppBar(
        backgroundColor: Colors.white,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                onPressed: () => Navigator.pop(context),
              )
            : null,
        title: const Text(
          "Seller Management",
          style: TextStyle(
            color: Color(0xff006565),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 12),
            child: CircleAvatar(
              child: Icon(Icons.person),
            ),
          )
        ],
      ),

      bottomNavigationBar: widget.isEmbedded ? null : BottomNavigationBar(
        currentIndex: currentIndex,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: "Stats",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: "Sellers",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: "Orders",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: "Inventory",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Row(
              children: [

                const Text(
                  "Pending Approvals",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xff008080),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Text(
                    "4 NEW",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: const [

                  ApprovalCard(
                    sellerName:
                        "Verdant Living",
                    category:
                        "Home & Garden",
                    icon: Icons.eco,
                  ),

                  SizedBox(width: 12),

                  ApprovalCard(
                    sellerName:
                        "Chrono Artisans",
                    category:
                        "Luxury Accessories",
                    icon: Icons.watch,
                  ),

                  SizedBox(width: 12),

                  ApprovalCard(
                    sellerName:
                        "Urban Pantry",
                    category:
                        "Gourmet Foods",
                    icon: Icons.restaurant,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Seller Directory",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              decoration: InputDecoration(
                hintText:
                    "Search sellers...",
                prefixIcon:
                    const Icon(Icons.search),
                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(14),
                ),
              ),
            ),

            const SizedBox(height: 20),

            const SellerTile(
              name: "Marcus Sterling",
              email:
                  "marcus@sterlinggoods.com",
              status: "Active",
              badge: "Gold",
            ),

            const SellerTile(
              name: "Elena Vance",
              email:
                  "e.vance@chromalabs.io",
              status: "Suspended",
              badge: "Silver",
            ),

            const SellerTile(
              name: "Julian Cross",
              email:
                  "j.cross@urbanpantry.co",
              status: "Pending",
              badge: "Premium",
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void showProfileDialog() {
    showDialog(
      context: context,
      builder: (_) => const AlertDialog(
        title: Text("Seller Profile"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 40),
            SizedBox(height: 12),
            Text("Marcus Sterling"),
            Text("Gold Seller"),
            SizedBox(height: 12),
            Text("Orders: 1284"),
            Text("Rating: 4.9/5"),
            Text("Revenue: ₹42k"),
          ],
        ),
      ),
    );
  }
}

class ApprovalCard extends StatelessWidget {
  final String sellerName;
  final String category;
  final IconData icon;

  const ApprovalCard({
    super.key,
    required this.sellerName,
    required this.category,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          Row(
            children: [
              CircleAvatar(
                backgroundColor:
                    const Color(0xffD4E6E5),
                child: Icon(
                  icon,
                  color: const Color(0xff006565),
                ),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      sellerName,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    Text(category),
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          const Text(
            "Seller waiting for approval.",
          ),

          const Spacer(),

          Row(
            children: [

              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Approve"),
                ),
              ),

              const SizedBox(width: 8),

              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.close),
              ),

              IconButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => const ChatSheet(),
                  );
                },
                icon: const Icon(Icons.chat),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class SellerTile extends StatelessWidget {
  final String name;
  final String email;
  final String status;
  final String badge;

  const SellerTile({
    super.key,
    required this.name,
    required this.email,
    required this.status,
    required this.badge,
  });

  Color get statusColor {
    switch (status) {
      case "Active":
        return Colors.green;
      case "Suspended":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: const CircleAvatar(
          radius: 28,
          child: Icon(Icons.person),
        ),

        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),

        subtitle: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            Text(email),

            const SizedBox(height: 4),

            Row(
              children: [

                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),

                const SizedBox(width: 6),

                Text(status),
              ],
            ),
          ],
        ),

        trailing: PopupMenuButton(
          itemBuilder: (context) => [

            const PopupMenuItem(
              value: "profile",
              child: Text(
                "View Profile",
              ),
            ),

            const PopupMenuItem(
              value: "documents",
              child: Text(
                "Documents",
              ),
            ),

            const PopupMenuItem(
              value: "chat",
              child: Text("Chat"),
            ),

            const PopupMenuItem(
              value: "team",
              child: Text(
                "Add To Team",
              ),
            ),

            const PopupMenuItem(
              value: "task",
              child: Text(
                "Assign Task",
              ),
            ),

            const PopupMenuItem(
              value: "partner",
              child: Text(
                "Invite Partner",
              ),
            ),

            const PopupMenuItem(
              value: "suspend",
              child: Text(
                "Suspend Account",
              ),
            ),
          ],

          onSelected: (value) {

            if (value == "chat") {
              showModalBottomSheet(
                context: context,
                builder: (_) => const ChatSheet(),
              );
            }

            if (value == "team") {
              showDialog(
                context: context,
                builder: (_) => const TeamDialog(),
              );
            }

            if (value == "task") {
              showDialog(
                context: context,
                builder: (_) => const TaskDialog(),
              );
            }
          },
        ),
      ),
    );
  }
}

class ChatSheet extends StatelessWidget {
  const ChatSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 450,
      child: Column(
        children: [

          const ListTile(
            leading: CircleAvatar(),
            title: Text("Marcus"),
            subtitle: Text("Online"),
          ),

          const Expanded(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Chip(
                      label: Text(
                        "Hello! I have a question.",
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: Chip(
                      label: Text(
                        "Sure, how can I help?",
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Type a message...",
                suffixIcon: Icon(Icons.send),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class TeamDialog extends StatelessWidget {
  const TeamDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      title: Text("Assign To Team"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          CheckboxListTile(
            value: false,
            onChanged: null,
            title: Text("Support Team"),
          ),

          CheckboxListTile(
            value: false,
            onChanged: null,
            title: Text("Sales Team"),
          ),

          CheckboxListTile(
            value: false,
            onChanged: null,
            title: Text("Logistics Team"),
          ),
        ],
      ),
    );
  }
}

class TaskDialog extends StatelessWidget {
  const TaskDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Assign Task"),

      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          TextField(
            decoration: InputDecoration(
              labelText: "Task Description",
            ),
          ),

          SizedBox(height: 12),

          TextField(
            decoration: InputDecoration(
              labelText: "Due Date",
            ),
          ),
        ],
      ),

      actions: [

        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),

        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Assign"),
        ),
      ],
    );
  }
}
