import 'package:flutter/material.dart';

class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen> {
  bool twoFactorEnabled = true;

  void showEditProfile() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 20),

                const TextField(
                  decoration: InputDecoration(labelText: "Full Name"),
                ),

                const SizedBox(height: 12),

                const TextField(
                  decoration: InputDecoration(labelText: "Email"),
                ),

                const SizedBox(height: 12),

                const TextField(
                  decoration: InputDecoration(labelText: "Phone"),
                ),

                const SizedBox(height: 12),

                const TextField(
                  maxLines: 4,
                  decoration: InputDecoration(labelText: "Bio"),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text("Save Changes"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showOtpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Security Verification"),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.shield, size: 50, color: Color(0xff006565)),

              const SizedBox(height: 16),

              const Text(
                "Enter Verification Code",
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => SizedBox(
                    width: 35,
                    child: TextField(
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      decoration: const InputDecoration(counterText: ""),
                    ),
                  ),
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
              child: const Text("Verify"),
            ),
          ],
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

        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                onPressed: () => Navigator.pop(context),
              )
            : const Icon(Icons.menu, color: Color(0xff006565)),

        title: const Text(
          "Admin Profile",
          style: TextStyle(
            color: Color(0xFF1C1B1B),
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xff006565)),
            onPressed: () {},
          ),
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: const Color(0xff006565),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          if (index != 3 && Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: "Dashboard",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Users"),
          BottomNavigationBarItem(icon: Icon(Icons.history_edu), label: "Logs"),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: "Profile",
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xff006565), Color(0xff008080)],
                    ),
                  ),
                ),

                Positioned(
                  bottom: -60,
                  child: Stack(
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.white, width: 4),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withAlpha(26),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=300",
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xffD4E6E5),
                                child: const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Color(0xff006565),
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: CircleAvatar(
                          backgroundColor: const Color(0xff006565),
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white),
                            onPressed: showEditProfile,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 70,
            ), // Spacer for the avatar that overflows the stack

            const Text(
              "Alex Johnson",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 4),

            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified, size: 18, color: Color(0xff006565)),

                SizedBox(width: 4),

                Text(
                  "Super Admin",
                  style: TextStyle(
                    color: Color(0xff006565),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),

            const Text("Joined January 12, 2023"),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: const [
                  ProfileStatCard(
                    title: "Communities",
                    value: "24",
                    icon: Icons.hub,
                  ),
                  ProfileStatCard(
                    title: "Active Users",
                    value: "12.8K",
                    icon: Icons.group,
                  ),
                  ProfileStatCard(
                    title: "Score",
                    value: "98.4%",
                    icon: Icons.speed,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const Spacer(),

                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: showEditProfile,
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const InfoTile(label: "Full Name", value: "Alex Johnson"),

                      const InfoTile(
                        label: "Email",
                        value: "alex.j@comm-unity.app",
                      ),

                      const InfoTile(
                        label: "Phone",
                        value: "+1 (555) 000-1234",
                      ),

                      const SizedBox(height: 12),

                      const Text("Bio", style: TextStyle(color: Colors.grey)),

                      const SizedBox(height: 8),

                      Text(
                        "Dedicated community builder and strategic manager with 8+ years experience.",
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.lock_open),
                        title: const Text("Change Password"),
                        subtitle: const Text("Last updated 3 months ago"),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: showOtpDialog,
                      ),

                      SwitchListTile(
                        value: twoFactorEnabled,
                        activeColor: const Color(0xff006565),
                        title: const Text("Two Factor Authentication"),
                        subtitle: const Text("Secure account with 2FA"),
                        onChanged: (value) {
                          setState(() {
                            twoFactorEnabled = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.palette),
                      title: const Text("Theme"),
                      subtitle: const Text("Light Mode"),
                    ),
                    ListTile(
                      leading: const Icon(Icons.notifications),
                      title: const Text("Notifications"),
                      subtitle: const Text("Push, Email & SMS"),
                      trailing: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text("Delete your account permanently"),
                    ),

                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text("Delete"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const ProfileStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xff006565)),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const InfoTile({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Divider(),
        ],
      ),
    );
  }
}
