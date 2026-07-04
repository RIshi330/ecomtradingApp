import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';

class CreatePostDialog extends StatefulWidget {
  final VoidCallback onPostCreated;
  
  const CreatePostDialog({super.key, required this.onPostCreated});

  @override
  State<CreatePostDialog> createState() => _CreatePostDialogState();
}

class _CreatePostDialogState extends State<CreatePostDialog> {
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _tagController = TextEditingController();
  
  String _visibility = 'public';
  String _location = '';
  String _label = 'Strategic Update'; // Mapped label
  String _imageUrl = '';
  bool _allowComments = true;
  bool _isLoading = false;
  bool _showImageInput = false;
  bool _showLocationInput = false;

  @override
  void dispose() {
    _contentController.dispose();
    _imageUrlController.dispose();
    _locationController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  Future<void> _submitPost() async {
    final String content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Post content cannot be empty"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await AuthService.getCachedUserData();
      final vendorId = userData != null ? userData['id'] : null;

      final Map<String, dynamic> body = {
        'action': 'create_post',
        'content_type': _imageUrl.isNotEmpty ? 'image' : 'text',
        'visibility': _visibility,
        'label': _label,
        'tags': _tagController.text.trim(),
        'location': _location,
        if (_imageUrl.isNotEmpty) ...{
          'image_count': '1',
          'altpostImage1': _imageUrl,
        },
        if (vendorId != null) 'vendor_id': vendorId.toString(),
      };

      final response = await Database().getData(body, endpoint: 'new_apis/social_feed_api.php');

      if (response != null && response['success'] == true) {
        widget.onPostCreated();
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Post published successfully!"),
              backgroundColor: Color(0xFF006565),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response?['message'] ?? "Failed to publish post"),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const surfaceContainerLow = Color(0xFFF4F3F3);
    const outlineVariant = Color(0xFFBDC9C8);
    const textOnSurfaceVariant = Color(0xFF3E4949);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 24,
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: SizedBox(
        width: MediaQuery.of(context).size.width.clamp(0.0, 600.0),
        height: MediaQuery.of(context).size.height.clamp(0.0, 700.0),
        child: _isLoading
            ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(40.0),
                  child: CircularProgressIndicator(color: primaryColor),
                ),
              )
            : Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Modal Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: textOnSurfaceVariant),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        const Text(
                          "Create Post",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _submitPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 0),
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: const Text("Post", style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ),
                  const Divider(color: outlineVariant, height: 1),

                  // Scrollable Content
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // User Profile snippet
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: outlineVariant),
                                  image: const DecorationImage(
                                    image: NetworkImage(
                                      "https://lh3.googleusercontent.com/aida-public/AB6AXuCjROtURqL93PgulLZeoQISnVMbeVSXeJZJjeLS91RV6bmgMKQymFpZ_utBLCs055N5AX4xs0IugklqoBczkEaX0hbcQn_RZBpAJk72jtsnuCW7s4z4j1B1Q12ggbPunW50AZGyoyA8pEUadRV_dLcs0qgNtJaeCt6jVRcs2Q0Dzc25ouX2QwdKAgnSo-A5TgZyuUkeehKO0TeVM-u5ER9Y3fILJHS5AXZriszyEVfacfEVyqX-7qdz",
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Executive User",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 8,
                                      runSpacing: 4,
                                      children: [
                                        // Visibility Dropdown Selector
                                        SizedBox(
                                          width: 130,
                                          child: DropdownButtonHideUnderline(
                                            child: DropdownButton<String>(
                                              value: _visibility,
                                              isExpanded: true,
                                              icon: const Icon(Icons.arrow_drop_down, size: 14, color: primaryColor),
                                              style: const TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: primaryColor,
                                              ),
                                              items: const [
                                                DropdownMenuItem(value: "public", child: Text("PUBLIC")),
                                                DropdownMenuItem(value: "private", child: Text("COMMUNITY ONLY")),
                                              ],
                                              onChanged: (val) {
                                                if (val != null) {
                                                  setState(() {
                                                    _visibility = val;
                                                  });
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                        if (_location.isNotEmpty)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: primaryColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.location_on_rounded, size: 10, color: primaryColor),
                                                const SizedBox(width: 2),
                                                Text(
                                                  _location,
                                                  style: const TextStyle(fontSize: 8, color: primaryColor, fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Text Area
                          TextField(
                            controller: _contentController,
                            maxLines: null,
                            minLines: 4,
                            keyboardType: TextInputType.multiline,
                            style: const TextStyle(fontSize: 16, color: Colors.black),
                            decoration: const InputDecoration(
                              hintText: "What's on your mind?",
                              hintStyle: TextStyle(color: Colors.grey, fontSize: 16),
                              border: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Image URL input field (collapsible)
                          if (_showImageInput) ...[
                            TextField(
                              controller: _imageUrlController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: "Image URL",
                                labelStyle: const TextStyle(color: primaryColor),
                                hintText: "Paste an image web URL here...",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: outlineVariant),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check_rounded, color: primaryColor),
                                  onPressed: () {
                                    setState(() {
                                      _imageUrl = _imageUrlController.text.trim();
                                      _showImageInput = false;
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (val) {
                                setState(() {
                                  _imageUrl = val.trim();
                                  _showImageInput = false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Location input field (collapsible)
                          if (_showLocationInput) ...[
                            TextField(
                              controller: _locationController,
                              style: const TextStyle(fontSize: 13),
                              decoration: InputDecoration(
                                labelText: "Location",
                                labelStyle: const TextStyle(color: primaryColor),
                                hintText: "Enter location (e.g. New York, USA)",
                                hintStyle: const TextStyle(color: Colors.grey, fontSize: 12),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: const BorderSide(color: outlineVariant),
                                ),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.check_rounded, color: primaryColor),
                                  onPressed: () {
                                    setState(() {
                                      _location = _locationController.text.trim();
                                      _showLocationInput = false;
                                    });
                                  },
                                ),
                              ),
                              onSubmitted: (val) {
                                setState(() {
                                  _location = val.trim();
                                  _showLocationInput = false;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                          ],

                          // Image Post Preview
                          if (_imageUrl.isNotEmpty)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: outlineVariant),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    color: surfaceContainerLow,
                                    child: Row(
                                      children: [
                                        const Icon(Icons.visibility_outlined, size: 14, color: textOnSurfaceVariant),
                                        const SizedBox(width: 6),
                                        const Text(
                                          "POST PREVIEW",
                                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: textOnSurfaceVariant),
                                        ),
                                        const Spacer(),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.red),
                                          onPressed: () {
                                            setState(() {
                                              _imageUrl = '';
                                              _imageUrlController.clear();
                                            });
                                          },
                                          constraints: const BoxConstraints(),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                  AspectRatio(
                                    aspectRatio: 16 / 9,
                                    child: Image.network(
                                      _imageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return const Center(
                                          child: Text(
                                            "Invalid Image URL",
                                            style: TextStyle(color: Colors.red, fontSize: 12),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Category label selection
                          const Text(
                            "POST LABEL",
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: textOnSurfaceVariant),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            children: ["Strategic Update", "Insights", "Discussion", "General"].map((label) {
                              final isSelected = _label == label;
                              return ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                onSelected: (val) {
                                  if (val) {
                                    setState(() {
                                      _label = label;
                                    });
                                  }
                                },
                                selectedColor: primaryColor.withOpacity(0.2),
                                backgroundColor: surfaceContainerLow,
                                side: BorderSide.none,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: isSelected ? primaryColor : textOnSurfaceVariant,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(color: outlineVariant, height: 1),

                  // Metadata attachments bar
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Quick pills row
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            // Emoji
                            _buildQuickPill(Icons.sentiment_satisfied_alt_rounded, "Emoji", () {
                              _contentController.text += " 🤝";
                            }),
                            // Mention
                            _buildQuickPill(Icons.alternate_email_rounded, "Mention", () {
                              _contentController.text += "@";
                            }),
                            // Hashtag
                            _buildQuickPill(Icons.tag_rounded, "Hashtag", () {
                              _contentController.text += "#";
                            }),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Actions bar container
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: surfaceContainerLow,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: outlineVariant.withOpacity(0.5)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildAttachmentButton(Icons.image_outlined, "Image", () {
                                setState(() {
                                  _showImageInput = !_showImageInput;
                                });
                              }),
                              _buildAttachmentButton(Icons.videocam_outlined, "Video", () {}),
                              _buildAttachmentButton(Icons.description_outlined, "Doc", () {}),
                              _buildAttachmentButton(Icons.poll_outlined, "Poll", () {}),
                              _buildAttachmentButton(Icons.location_on_outlined, "Location", () {
                                setState(() {
                                  _showLocationInput = !_showLocationInput;
                                });
                              }),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Advanced options section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: const [
                                Icon(Icons.comment_outlined, size: 20, color: textOnSurfaceVariant),
                                SizedBox(width: 8),
                                Text(
                                  "Allow Comments",
                                  style: TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                            Switch(
                              value: _allowComments,
                              onChanged: (val) {
                                setState(() {
                                  _allowComments = val;
                                });
                              },
                              activeColor: primaryColor,
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
  }

  Widget _buildQuickPill(IconData icon, String text, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F3F3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFBDC9C8).withOpacity(0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xFF3E4949)),
            const SizedBox(width: 4),
            Text(
              text,
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF3E4949)),
          const SizedBox(height: 4),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Color(0xFF3E4949)),
          ),
        ],
      ),
    );
  }
}
