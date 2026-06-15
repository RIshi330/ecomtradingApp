import '../core/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../Database/Database.dart';

class ExploreTalentScreen extends StatefulWidget {
  const ExploreTalentScreen({super.key});

  @override
  State<ExploreTalentScreen> createState() => _ExploreTalentScreenState();
}

class _ExploreTalentScreenState extends State<ExploreTalentScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoadingProfiles = false;
  bool _isLoadingFilters = false;
  bool _isLoadingPackages = false;

  List<TalentProfile> _profiles = [];
  List<dynamic> _featuredPackages = [];

  // Filter Options (fetched from API)
  List<String> _streams = [];
  List<String> _availabilities = [];
  List<String> _colleges = [];
  List<String> _skillsList = [];

  // Selected Filters
  final searchController = TextEditingController();
  final List<String> _selectedStreams = [];
  final List<String> _selectedAvails = [];
  final List<String> _selectedSkills = [];
  String _selectedCollege = "";
  String _selectedSort = "recent";

  bool _showDrawer = false;
  int _activeTab = 0; // 0: Swipe Cards, 1: Hiring Packages

  double xOffset = 0;
  double yOffset = 0;

  @override
  void initState() {
    super.initState();
    _loadFilters();
    _loadProfiles();
    _loadPackages();
  }

  Future<void> _loadFilters() async {
    setState(() {
      _isLoadingFilters = true;
    });
    try {
      final response = await Database().getData({
        'action': 'get_filters',
      }, endpoint: 'new_apis/marketplace_talent_API.php');

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          _streams = List<String>.from(data['streams'] ?? []);
          _availabilities = List<String>.from(data['availability'] ?? []);
          _colleges = List<String>.from(data['colleges'] ?? []);
          _skillsList = List<String>.from(data['skills'] ?? []);
        });
      }
    } catch (e) {
      debugPrint("Error loading filters: $e");
    } finally {
      setState(() {
        _isLoadingFilters = false;
      });
    }
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoadingProfiles = true;
    });
    try {
      final Map<String, dynamic> body = {
        'action': 'load_profiles',
        'search': searchController.text.trim(),
        'sort': _selectedSort,
      };

      if (_selectedStreams.isNotEmpty) {
        body['selected_streams'] = jsonEncode(_selectedStreams);
      }
      if (_selectedAvails.isNotEmpty) {
        body['selected_avail'] = jsonEncode(_selectedAvails);
      }
      if (_selectedSkills.isNotEmpty) {
        body['selected_skills'] = jsonEncode(_selectedSkills);
      }
      if (_selectedCollege.isNotEmpty) {
        body['college'] = _selectedCollege;
      }

      final response = await Database().getData(
        body,
        endpoint: 'new_apis/marketplace_talent_API.php',
      );

      if (response['success'] == true || response.containsKey('profiles')) {
        final List<dynamic> list = response['profiles'] ?? [];
        setState(() {
          _profiles = list.map((item) {
            final id = item['id'] is int
                ? item['id']
                : int.tryParse(item['id']?.toString() ?? '0') ?? 0;
            final name = item['name'] ?? 'Talent Seeker';
            final college = item['college'] ?? 'Not specified';
            final stream = item['stream'] ?? 'General';
            final batch = item['batch'] ?? '';
            final List<dynamic> skillsData = item['skills'] ?? [];
            final skills = skillsData.map((e) => e.toString()).toList();
            final availability = item['availability'] ?? 'Open';
            final avatar = item['avatar'] ?? '';
            final verified = item['verified'] ?? false;
            final bio = item['bio'] ?? '';

            return TalentProfile(
              id: id,
              name: name,
              role: stream,
              location: college,
              rate: availability,
              description: bio,
              skills: skills,
              image: avatar,
              premium: verified,
            );
          }).toList();
          xOffset = 0;
          yOffset = 0;
        });
      }
    } catch (e) {
      debugPrint("Error loading profiles: $e");
    } finally {
      setState(() {
        _isLoadingProfiles = false;
      });
    }
  }

  Future<void> _loadPackages() async {
    setState(() {
      _isLoadingPackages = true;
    });
    try {
      final response = await Database().getData({
        'action': 'load_packages',
      }, endpoint: 'new_apis/marketplace_talent_API.php');

      if (response['success'] == true) {
        final data = response['data'] ?? {};
        setState(() {
          _featuredPackages = data['packages'] ?? [];
        });
      }
    } catch (e) {
      debugPrint("Error loading packages: $e");
    } finally {
      setState(() {
        _isLoadingPackages = false;
      });
    }
  }

  Future<void> _sendInvite(
      int id, String name, String email, String message) async {
    try {
      final response = await Database().getData({
        'action': 'send_invite',
        'id': id.toString(),
        'name': name,
        'email': email,
        'message': message,
      }, endpoint: 'new_apis/marketplace_talent_API.php');

      if (mounted) {
        if (response['success'] == true || response['status'] == 'ok') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Invitation sent to $name successfully!"),
              backgroundColor: AppTheme.primary,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response['message'] ?? "Error sending invitation"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error sending invite: $e");
    }
  }

  void _nextCard() {
    if (_profiles.isEmpty) return;
    setState(() {
      _profiles.removeAt(0);
      xOffset = 0;
      yOffset = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF9F9FF),
      body: Stack(
        children: [
          Column(
            children: [
              /// APPBAR
              Container(
                color: Colors.white,
                padding: const EdgeInsets.only(
                  top: 55,
                  left: 16,
                  right: 16,
                  bottom: 12,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.menu,
                        color: AppTheme.primary,
                      ),
                      onPressed: () {
                        setState(() {
                          _showDrawer = true;
                        });
                      },
                    ),
                    const Expanded(
                      child: Text(
                        "Talent Marketplace",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            _activeTab == 0
                                ? Icons.view_carousel
                                : Icons.card_giftcard,
                            color: AppTheme.primary,
                          ),
                          onPressed: () {
                            setState(() {
                              _activeTab = _activeTab == 0 ? 1 : 0;
                            });
                          },
                        ),
                        const CircleAvatar(
                          radius: 18,
                          child: Icon(Icons.person, size: 18),
                        ),
                      ],
                    )
                  ],
                ),
              ),

              Expanded(
                child: _activeTab == 0
                    ? _buildSwipeCardsTab()
                    : _buildHiringPackagesTab(),
              ),
            ],
          ),
          if (_showDrawer) _buildFilterDrawerWidget(),
        ],
      ),
    );
  }

  Widget _buildSwipeCardsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// SEARCH
          TextField(
            controller: searchController,
            onSubmitted: (v) => _loadProfiles(),
            decoration: InputDecoration(
              hintText: "Search roles or skills...",
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        _loadProfiles();
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  searchController.text.isEmpty
                      ? "Finding matches for Talent"
                      : "Matches for: ${searchController.text}",
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              DropdownButton<String>(
                value: _selectedSort,
                underline: const SizedBox(),
                style: const TextStyle(
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13),
                icon:
                    const Icon(Icons.sort, color: AppTheme.primary, size: 16),
                items: const [
                  DropdownMenuItem(
                      value: "recent", child: Text("Sort: Recent")),
                  DropdownMenuItem(value: "name_asc", child: Text("Sort: A-Z")),
                  DropdownMenuItem(
                      value: "name_desc", child: Text("Sort: Z-A")),
                ],
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _selectedSort = v;
                    });
                    _loadProfiles();
                  }
                },
              )
            ],
          ),

          const SizedBox(height: 12),

          /// SWIPE STACK
          Expanded(
            child: _isLoadingProfiles
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : _profiles.isEmpty
                    ? _buildSwipeEmptyState()
                    : _buildSwipeCardStackWidget(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No More Profiles",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Check back later or change your filters.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary),
            onPressed: () {
              setState(() {
                _selectedStreams.clear();
                _selectedAvails.clear();
                _selectedSkills.clear();
                _selectedCollege = "";
                searchController.clear();
              });
              _loadProfiles();
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
            label: const Text("Reset Filters",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCardStackWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        if (_profiles.length > 2)
          Transform.scale(
            scale: .92,
            child: TalentCard(
              profile: _profiles[2],
            ),
          ),
        if (_profiles.length > 1)
          Transform.scale(
            scale: .96,
            child: TalentCard(
              profile: _profiles[1],
            ),
          ),
        GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              xOffset += details.delta.dx;
              yOffset += details.delta.dy;
            });
          },
          onPanEnd: (_) {
            if (xOffset > 120) {
              // Shortlist (opens dialog to invite)
              _showInviteDialogOnSwipe(_profiles.first);
            } else if (xOffset < -120) {
              // Pass
              _nextCard();
            } else {
              setState(() {
                xOffset = 0;
                yOffset = 0;
              });
            }
          },
          child: Transform.translate(
            offset: Offset(xOffset, yOffset),
            child: Transform.rotate(
              angle: xOffset / 500,
              child: Stack(
                children: [
                  TalentCard(
                    profile: _profiles.first,
                  ),
                  if (xOffset > 50)
                    Positioned(
                      top: 40,
                      left: 30,
                      child: _buildSwipeIndicator("SHORTLIST", Colors.green),
                    ),
                  if (xOffset < -50)
                    Positioned(
                      top: 40,
                      right: 30,
                      child: _buildSwipeIndicator("PASS", Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwipeIndicator(String text, Color color) {
    return Transform.rotate(
      angle: -.3,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          color: Colors.white.withAlpha(220),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
      ),
    );
  }

  Widget _buildHiringPackagesTab() {
    return RefreshIndicator(
      onRefresh: _loadPackages,
      color: AppTheme.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Featured Hiring Packages",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _activeTab = 0;
                  });
                },
                icon: const Icon(Icons.arrow_back,
                    size: 16, color: AppTheme.primary),
                label: const Text("Swipe Talent",
                    style: TextStyle(color: AppTheme.primary)),
              )
            ],
          ),
          const SizedBox(height: 12),
          if (_isLoadingPackages)
            const Center(
                child: CircularProgressIndicator(color: AppTheme.primary))
          else if (_featuredPackages.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Text("No packages available currently."),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _featuredPackages.length,
              itemBuilder: (context, index) {
                final pkg = _featuredPackages[index];
                return _buildPackageItemTile(pkg);
              },
            )
        ],
      ),
    );
  }

  Widget _buildPackageItemTile(dynamic pkg) {
    final title = pkg['title'] ?? 'Talent Package';
    final desc = pkg['desc'] ?? '';
    final slots = pkg['slots'] ?? 0;
    final price = pkg['price'] ?? 'Contact';
    final company = pkg['company'] ?? '';

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppTheme.primary),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(company,
                style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 10),
            Text(desc,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$slots slots available",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 12)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showPackageContractConfirmation(pkg),
                  child: const Text("Hire Package",
                      style: TextStyle(color: Colors.white)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _showPackageContractConfirmation(dynamic pkg) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text("Hiring Hub Request"),
          content: Text(
              "Do you want to request a contract for the package '${pkg['title']}'?\nPrice: ${pkg['price']}"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        "Hiring contract inquiry submitted! Our coordinators will contact you."),
                    backgroundColor: AppTheme.primary,
                  ),
                );
              },
              child:
                  const Text("Request", style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  void _showInviteDialogOnSwipe(TalentProfile profile) {
    final emailController =
        TextEditingController(text: "talent${profile.id}@ccbul.com");
    final messageController = TextEditingController(
        text:
            "Hi ${profile.name},\n\nWe would love to invite you to collaborate on our upcoming project tasks.");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text("Invite ${profile.name}"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: "Talent Email"),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: "Invitation Message",
                  border: OutlineInputBorder(),
                ),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // If they cancel, reset card coordinates
                setState(() {
                  xOffset = 0;
                  yOffset = 0;
                });
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary),
              onPressed: () {
                final email = emailController.text.trim();
                final message = messageController.text.trim();
                if (email.isEmpty || message.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Email and message are required")),
                  );
                  return;
                }
                Navigator.pop(context);
                _sendInvite(profile.id, profile.name, email, message);
                _nextCard();
              },
              child: const Text("Send Invite",
                  style: TextStyle(color: Colors.white)),
            )
          ],
        );
      },
    );
  }

  Widget _buildFilterDrawerWidget() {
    return Material(
      color: Colors.black45,
      child: Row(
        children: [
          Container(
            width: 320,
            color: Colors.white,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          "Refine Search",
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() {
                            _showDrawer = false;
                          });
                        },
                      )
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text("Select College",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value:
                            _selectedCollege.isEmpty ? null : _selectedCollege,
                        decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding:
                                EdgeInsets.symmetric(horizontal: 10)),
                        items: [
                          const DropdownMenuItem(
                              value: "", child: Text("All Colleges")),
                          ..._colleges.map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c, overflow: TextOverflow.ellipsis))),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _selectedCollege = v ?? "";
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text("Streams / Interests",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _streams.map((stream) {
                          final isSelected = _selectedStreams.contains(stream);
                          return FilterChip(
                            label: Text(stream),
                            selected: isSelected,
                            selectedColor:
                                AppTheme.primary.withAlpha(50),
                            checkmarkColor: AppTheme.primary,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedStreams.add(stream);
                                } else {
                                  _selectedStreams.remove(stream);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      const Text("Availability Type",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 10),
                      ..._availabilities.map((avail) {
                        final isSelected = _selectedAvails.contains(avail);
                        return CheckboxListTile(
                          title:
                              Text(avail, style: const TextStyle(fontSize: 13)),
                          value: isSelected,
                          onChanged: (selected) {
                            setState(() {
                              if (selected == true) {
                                _selectedAvails.add(avail);
                              } else {
                                _selectedAvails.remove(avail);
                              }
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                          contentPadding: EdgeInsets.zero,
                          dense: true,
                        );
                      }),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedStreams.clear();
                              _selectedAvails.clear();
                              _selectedCollege = "";
                              _showDrawer = false;
                            });
                            _loadProfiles();
                          },
                          child: const Text("Reset"),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: SizedBox(
                          height: 45,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary),
                            onPressed: () {
                              setState(() {
                                _showDrawer = false;
                              });
                              _loadProfiles();
                            },
                            child: const Text("Apply",
                                style: TextStyle(color: Colors.white)),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showDrawer = false;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TalentCard extends StatelessWidget {
  final TalentProfile profile;

  const TalentCard({
    super.key,
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 7,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(30)),
                  child: profile.image.isNotEmpty
                      ? Image.network(
                          profile.image,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        )
                      : _buildImagePlaceholder(),
                ),
                if (profile.premium)
                  Positioned(
                    top: 15,
                    left: 15,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "PREMIUM TALENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: AppTheme.primary, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.rate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 15,
                  right: 15,
                  bottom: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(140),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "${profile.role} • ${profile.location}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: profile.skills.map((e) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: Chip(
                            label:
                                Text(e, style: const TextStyle(fontSize: 10)),
                            backgroundColor:
                                AppTheme.primary.withAlpha(25),
                            labelStyle:
                                const TextStyle(color: AppTheme.primary),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Text(
                      profile.description,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 13,
                          height: 1.4),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: Colors.indigo.shade50,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person, size: 80, color: AppTheme.primary),
          SizedBox(height: 10),
          Text("No Avatar Photo", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class TalentProfile {
  final int id;
  final String name;
  final String role;
  final String location;
  final String rate;
  final String description;
  final String image;
  final bool premium;
  final List<String> skills;

  TalentProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.location,
    required this.rate,
    required this.description,
    required this.image,
    required this.skills,
    this.premium = false,
  });
}
