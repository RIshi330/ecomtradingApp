import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';

import '../services/auth_User_and_Business_Session.dart';

class PersonalizeFeedDialog extends StatefulWidget {
  final bool isEmbedded;
  const PersonalizeFeedDialog({super.key, this.isEmbedded = false});

  @override
  State<PersonalizeFeedDialog> createState() => _PersonalizeFeedDialogState();
}

class _PersonalizeFeedDialogState extends State<PersonalizeFeedDialog> {
  static const String _endpoint = 'new_apis/community_app_interest_api.php';

  bool _isLoading = true;
  bool _isSaving = false;
  bool _isClearing = false;
  List<Map<String, dynamic>> _dbInterests = [];
  final Set<int> _selectedInterestIds = {};

  final TextEditingController _customInterestController = TextEditingController();

  String get _vendorId => UserSessionSet.instance.vendorId;

  @override
  void initState() {
    super.initState();
    _fetchInterests();
  }

  @override
  void dispose() {
    _customInterestController.dispose();
    super.dispose();
  }

  /// Fetches the master interests list ('get_interests') and the vendor's
  /// previously saved interests ('get_user_interests') so already-chosen
  /// topics arrive pre-selected (important when this widget is embedded on
  /// a "edit preferences" screen rather than shown as a first-run dialog).
  Future<void> _fetchInterests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final interestsResponse = await Database().getData({
        'action': 'get_interests',
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      List<Map<String, dynamic>> fetchedInterests = [];
      if (interestsResponse != null &&
          interestsResponse['success'] == true &&
          interestsResponse['data'] != null) {
        final List<dynamic> rawData = interestsResponse['data'];
        fetchedInterests = rawData.map((item) {
          return {
            'id': int.parse(item['id'].toString()),
            'title': item['title'].toString(),
            'type': item['type']?.toString() ?? '',
          };
        }).toList();
      }

      final userInterestsResponse = await Database().getData({
        'action': 'get_user_interests',
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      final Set<int> preSelected = {};
      if (userInterestsResponse != null &&
          userInterestsResponse['success'] == true &&
          userInterestsResponse['data'] != null) {
        final List<dynamic> rawUserData = userInterestsResponse['data'];
        for (final item in rawUserData) {
          final id = int.tryParse(item['id'].toString());
          if (id != null) preSelected.add(id);
        }
      }

      if (!mounted) return;
      setState(() {
        _dbInterests = fetchedInterests;
        _selectedInterestIds
          ..clear()
          ..addAll(preSelected);
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching interests: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Shows a dialog to add a new custom interest
  Future<void> _showAddInterestDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Interest'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter a new topic you\'re interested in:',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _customInterestController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'e.g., Organic Farming',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF7F9F9),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onSubmitted: (_) => _addNewInterest(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                _customInterestController.clear();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: _addNewInterest,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF006565),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  /// Adds a new interest to the database
  Future<void> _addNewInterest() async {
    final String title = _customInterestController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a topic name'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if interest already exists
    final bool exists = _dbInterests.any(
            (item) => item['title'].toString().toLowerCase() == title.toLowerCase()
    );
    if (exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This interest already exists'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await Database().getData({
        'action': 'add_interest',
        'title': title,
        'vendor_id': _vendorId,
        'type': 'custom', // or whatever type you want to assign
      }, endpoint: _endpoint);

      if (response != null && response['success'] == true) {
        // Get the new interest ID from response or refetch the list
        final newInterestId = response['data']?['id'] ?? _dbInterests.length + 1;

        // Add the new interest to local list
        final newInterest = {
          'id': newInterestId,
          'title': title,
          'type': 'custom',
        };

        // Also automatically select the new interest
        _selectedInterestIds.add(newInterestId);

        setState(() {
          _dbInterests.add(newInterest);
          _isLoading = false;
        });

        _customInterestController.clear();
        Navigator.of(context).pop(); // Close the dialog

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Interest added successfully!'),
            backgroundColor: Color(0xFF006565),
          ),
        );
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response?['message'] ?? 'Failed to add interest'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding interest: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Saves chosen interest IDs to the backend.
  Future<void> _savePreferences() async {
    if (_selectedInterestIds.length < 3) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final action = widget.isEmbedded ? 'update_user_interests' : 'save_user_interests';

      final response = await Database().getData({
        'action': action,
        'interests': _selectedInterestIds.toList(),
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null && response['success'] == true) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('has_personalized_feed', true);

        if (mounted) {
          if (!widget.isEmbedded) {
            Navigator.of(context).pop();
          } else {
            setState(() {
              _isSaving = false;
            });
          }
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Preferences saved successfully!"),
              backgroundColor: Color(0xFF006565),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to save preferences"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Clears all of the vendor's saved interests via 'delete_user_interests'.
  Future<void> _clearAllInterests() async {
    if (_selectedInterestIds.isEmpty || _isClearing) return;

    setState(() {
      _isClearing = true;
    });

    try {
      final response = await Database().getData({
        'action': 'delete_user_interests',
        'vendor_id': _vendorId,
      }, endpoint: _endpoint);

      if (response != null && response['success'] == true) {
        if (mounted) {
          setState(() {
            _selectedInterestIds.clear();
            _isClearing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Interests cleared"),
              backgroundColor: Color(0xFF006565),
            ),
          );
        }
      } else {
        if (mounted) {
          setState(() {
            _isClearing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to clear interests"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isClearing = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _skipForNow() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_personalized_feed', true);
    if (mounted) {
      if (!widget.isEmbedded) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const surfaceColor = Color(0xFFF7F9F9);
    const outlineVariant = Color(0xFFE0E6E6);
    const textOnSurfaceVariant = Color(0xFF5A6666);

    final Widget content = SizedBox(
      width: MediaQuery.of(context).size.width.clamp(0.0, 600.0),
      height: widget.isEmbedded ? null : MediaQuery.of(context).size.height.clamp(0.0, 750.0),
      child: _isLoading
          ? const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: CircularProgressIndicator(color: primaryColor),
        ),
      )
          : Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Modal Header
          Padding(
            padding: const EdgeInsets.only(top: 28.0, left: 24.0, right: 24.0, bottom: 16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "TAILORED EXPERIENCE",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: primaryColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  "What are you interested in?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E2424),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Select at least 3 topics to tailor your feed and discover valuable partnerships.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    height: 1.4,
                    color: textOnSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: outlineVariant, height: 1),

          // Pure Dynamic Feed based directly on Database Interests API
          Expanded(
            child: _dbInterests.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "No interests found in database.",
                    style: TextStyle(color: textOnSurfaceVariant, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: _showAddInterestDialog,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text("Add First Topic"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 10.0,
                children: [
                  ..._dbInterests.map((item) {
                    final int id = item['id'];
                    final String title = item['title'];
                    final isSelected = _selectedInterestIds.contains(id);

                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterestIds.remove(id);
                          } else {
                            _selectedInterestIds.add(id);
                          }
                        });
                      },
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected ? primaryColor : surfaceColor,
                          border: Border.all(
                            color: isSelected ? primaryColor : outlineVariant,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: isSelected
                              ? [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.2),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            )
                          ]
                              : null,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.label_outline_rounded,
                              size: 16,
                              color: isSelected ? Colors.white : textOnSurfaceVariant,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                color: isSelected ? Colors.white : textOnSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const Divider(color: outlineVariant, height: 1),

          // Modal Footer
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${_selectedInterestIds.length} of 3 required selected",
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: textOnSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: (_selectedInterestIds.length / 3).clamp(0.0, 1.0),
                              backgroundColor: outlineVariant,
                              color: primaryColor,
                              minHeight: 4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.isEmbedded && _selectedInterestIds.isNotEmpty) ...[
                      const SizedBox(width: 16),
                      TextButton(
                        onPressed: _isClearing ? null : _clearAllInterests,
                        child: _isClearing
                            ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.red),
                        )
                            : const Text(
                          "Clear all",
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedInterestIds.length >= 3 ? _savePreferences : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withOpacity(0.35),
                      disabledForegroundColor: Colors.white.withOpacity(0.7),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Save Preferences",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (widget.isEmbedded) return content;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 12,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: content,
    );
  }
}