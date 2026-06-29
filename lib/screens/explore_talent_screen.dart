import '../core/theme/app_theme.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import '../Database/Database.dart';

class ExploreTalentScreen extends StatefulWidget {
  final bool isEmbedded;
  const ExploreTalentScreen({super.key, this.isEmbedded = false});

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
      backgroundColor: const Color(0xffFCF9F8),
      body: Column(
        children: [
          /// APPBAR
          if (!widget.isEmbedded)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.only(
                top: 48,
                left: 12,
                right: 12,
                bottom: 8,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Navigator.canPop(context)
                          ? Icons.arrow_back_rounded
                          : Icons.menu_rounded,
                      color: AppTheme.primary,
                    ),
                    onPressed: () {
                      if (Navigator.canPop(context)) {
                        Navigator.pop(context);
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                  ),
                  const Expanded(
                    child: Text(
                      "Talent Marketplace",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        _activeTab == 0 ? "Talents" : "Hiring Packages",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _activeTab == 0
                              ? Icons.people_outline
                              : Icons.card_giftcard,
                          color: AppTheme.primary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _activeTab = _activeTab == 0 ? 1 : 0;
                          });
                        },
                      ),
                    ],
                  )
                ],
              ),
            )
          else
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _activeTab == 0 ? "Talent Profiles" : "Featured Packages",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primary,
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      setState(() {
                        _activeTab = _activeTab == 0 ? 1 : 0;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _activeTab == 0
                                ? Icons.card_giftcard
                                : Icons.people_outline,
                            color: AppTheme.primary,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _activeTab == 0 ? "Packages" : "Profiles",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
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
    );
  }

  Widget _buildSwipeCardsTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          /// SEARCH & FILTER ROW
          Row(
            children: [
              Expanded(
                child: TextField(
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
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showFilterBottomSheet(),
                child: Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.tune, color: AppTheme.primary),
                ),
              ),
            ],
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

          /// LIST OF TALENTS (replaces swipe stack)
          Expanded(
            child: _isLoadingProfiles
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : _profiles.isEmpty
                    ? _buildSwipeEmptyState()
                    : ListView.builder(
                        itemCount: _profiles.length,
                        itemBuilder: (context, index) {
                          final profile = _profiles[index];
                          return Container(
                            height: 360,
                            margin: const EdgeInsets.only(bottom: 16),
                            child: TalentCard(
                              profile: profile,
                              onInvite: () => _showInviteDialogOnSwipe(profile),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeEmptyState() {
    final hasFilters = _selectedStreams.isNotEmpty ||
        _selectedAvails.isNotEmpty ||
        _selectedSkills.isNotEmpty ||
        _selectedCollege.isNotEmpty ||
        searchController.text.isNotEmpty;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline_rounded,
              size: 80, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text(
            "No Profiles Found",
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87),
          ),
          const SizedBox(height: 8),
          const Text(
            "Try adjusting your filters or search query.",
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (hasFilters)
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
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        fontSize: 14,
                        color: AppTheme.primary),
                  ),
                ),
                Text(
                  price,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(company,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 8),
            Text(desc,
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("$slots slots available",
                    style: const TextStyle(
                        fontWeight: FontWeight.w500, fontSize: 11)),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    minimumSize: const Size(80, 30),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () => _showPackageContractConfirmation(pkg),
                  child: const Text("Hire Package",
                      style: TextStyle(color: Colors.white, fontSize: 11)),
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

  void _showFilterBottomSheet() {
    String tempCollege = _selectedCollege;
    List<String> tempStreams = List.from(_selectedStreams);
    List<String> tempAvails = List.from(_selectedAvails);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final hasActiveFilters = tempCollege.isNotEmpty || tempStreams.isNotEmpty || tempAvails.isNotEmpty;
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Filter Talent",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (hasActiveFilters)
                          TextButton(
                            onPressed: () {
                              setSheetState(() {
                                tempCollege = "";
                                tempStreams.clear();
                                tempAvails.clear();
                              });
                            },
                            child: const Text(
                              "Reset",
                              style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 12),
                    const Text(
                      "Select College",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: tempCollege.isEmpty ? null : tempCollege,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: [
                        const DropdownMenuItem(value: "", child: Text("All Colleges")),
                        ..._colleges.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(c, overflow: TextOverflow.ellipsis))),
                      ],
                      onChanged: (v) {
                        setSheetState(() {
                          tempCollege = v ?? "";
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Streams / Interests",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _streams.map((stream) {
                        final isSelected = tempStreams.contains(stream);
                        return FilterChip(
                          label: Text(stream),
                          selected: isSelected,
                          selectedColor: AppTheme.primary.withOpacity(0.15),
                          checkmarkColor: AppTheme.primary,
                          side: BorderSide.none,
                          onSelected: (selected) {
                            setSheetState(() {
                              if (selected) {
                                tempStreams.add(stream);
                              } else {
                                tempStreams.remove(stream);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Availability Type",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    ..._availabilities.map((avail) {
                      final isSelected = tempAvails.contains(avail);
                      return CheckboxListTile(
                        title: Text(avail, style: const TextStyle(fontSize: 14)),
                        value: isSelected,
                        activeColor: AppTheme.primary,
                        onChanged: (selected) {
                          setSheetState(() {
                            if (selected == true) {
                              tempAvails.add(avail);
                            } else {
                              tempAvails.remove(avail);
                            }
                          });
                        },
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        dense: true,
                      );
                    }),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          setState(() {
                            _selectedCollege = tempCollege;
                            _selectedStreams.clear();
                            _selectedStreams.addAll(tempStreams);
                            _selectedAvails.clear();
                            _selectedAvails.addAll(tempAvails);
                          });
                          _loadProfiles();
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
}

class TalentCard extends StatelessWidget {
  final TalentProfile profile;
  final VoidCallback onInvite;

  const TalentCard({
    super.key,
    required this.profile,
    required this.onInvite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
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
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "PREMIUM TALENT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                          color: AppTheme.primary, width: 1.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      profile.rate,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primary,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 10,
                  right: 10,
                  bottom: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          "${profile.role} • ${profile.location}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
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
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                                Text(e, style: const TextStyle(fontSize: 9)),
                            backgroundColor:
                                AppTheme.primary.withOpacity(0.1),
                            labelStyle:
                                const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.bold),
                            padding: EdgeInsets.zero,
                            side: BorderSide.none,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      profile.description,
                      style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 11,
                          height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    height: 34,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      onPressed: onInvite,
                      child: const Text(
                        "Invite",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
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
      color: const Color(0xffe5f7f7),
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
