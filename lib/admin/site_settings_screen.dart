import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/widgets/personalize_feed_dialog.dart';

class SiteSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const SiteSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends State<SiteSettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;

  // Scroll Keys
  final Map<String, GlobalKey> _sectionKeys = {
    'general': GlobalKey(),
    'social': GlobalKey(),
    'api': GlobalKey(),
    'payment': GlobalKey(),
    'account': GlobalKey(),
    'seo': GlobalKey(),
    'personalize': GlobalKey(),
  };

  String _activeTab = 'general';

  // Form Controllers
  final _siteNameController = TextEditingController();
  final _tagLineController = TextEditingController();
  final _aboutSiteController = TextEditingController();
  final _addressController = TextEditingController();

  final _linkedinController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _facebookController = TextEditingController();

  final _googleClientIdController = TextEditingController();
  final _googleSecretController = TextEditingController();
  final _googleCloudKeyController = TextEditingController();
  final _linkedinKeyController = TextEditingController();
  final _zoomApiKeyController = TextEditingController();
  final _zoomSecretController = TextEditingController();

  bool _useParentPaymentGateway = false;
  final _razorpayClientIdController = TextEditingController();
  final _razorpaySecretController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _analyticCodeController = TextEditingController();
  final _adSenseCodeController = TextEditingController();
  final _seoKeywordsController = TextEditingController();
  final _seoDescriptionController = TextEditingController();

  // Accordion expansion states controlled parent-side to force expand on scroll jump
  final Map<String, bool> _accordionStates = {
    'general': true,
    'social': false,
    'api': false,
    'payment': false,
    'account': false,
    'seo': false,
    'personalize': false,
  };

  @override
  void initState() {
    super.initState();
    _fetchSettings();
  }

  Future<void> _fetchSettings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final res = await Database().getData({
        'action': 'get_general_settings',
      }, endpoint: 'new_apis/site_settings_api.php');

      if (res != null && res['success'] == true) {
        final data = res['data'] ?? {};
        setState(() {
          _siteNameController.text = data['site_name']?.toString() ?? '';
          _tagLineController.text = data['tag_line']?.toString() ?? '';
          _aboutSiteController.text = data['about_site']?.toString() ?? '';
          _addressController.text = data['state']?.toString() ?? '';

          _linkedinController.text = data['linkedin_link']?.toString() ?? '';
          _twitterController.text = data['twitter_link']?.toString() ?? '';
          _instagramController.text = data['insta_link']?.toString() ?? '';
          _youtubeController.text = data['youtube_link']?.toString() ?? '';
          _facebookController.text = data['fb_link']?.toString() ?? '';

          // These are encrypted on the server, we show a placeholder value or decrypted placeholder
          _googleClientIdController.text = data['google_app'] != null && data['google_app'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _googleSecretController.text = data['google_secret'] != null && data['google_secret'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _googleCloudKeyController.text = data['google_api_key'] != null && data['google_api_key'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _linkedinKeyController.text = data['linkedin_app'] != null && data['linkedin_app'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _zoomApiKeyController.text = data['zoom_client_id'] != null && data['zoom_client_id'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _zoomSecretController.text = data['zoom_secret_key'] != null && data['zoom_secret_key'].toString().isNotEmpty ? "••••••••••••••••" : "";

          _useParentPaymentGateway = (int.tryParse(data['use_parent_payment']?.toString() ?? '0') ?? 0) == 1;
          _razorpayClientIdController.text = data['razorpay_key'] != null && data['razorpay_key'].toString().isNotEmpty ? "••••••••••••••••" : "";
          _razorpaySecretController.text = data['razorpay_secret'] != null && data['razorpay_secret'].toString().isNotEmpty ? "••••••••••••••••" : "";

          _analyticCodeController.text = data['ga_code']?.toString() ?? '';
          _adSenseCodeController.text = data['gad_code']?.toString() ?? '';
          _seoKeywordsController.text = data['seo_keywords']?.toString() ?? '';
          _seoDescriptionController.text = data['seo_description']?.toString() ?? '';
        });
      }
    } catch (e) {
      print("Error fetching settings: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveAllSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final db = Database();

      // 1. General Settings
      await db.getData({
        'action': 'update_general_settings',
        'site_name': _siteNameController.text.trim(),
        'tag_line': _tagLineController.text.trim(),
        'about_site': _aboutSiteController.text.trim(),
        'state': _addressController.text.trim(),
        'city': '',
        'pin': '',
      }, endpoint: 'new_apis/site_settings_api.php');

      // 2. Social Settings
      await db.getData({
        'action': 'update_social_links',
        'linkedin_link': _linkedinController.text.trim(),
        'twitter_link': _twitterController.text.trim(),
        'insta_link': _instagramController.text.trim(),
        'youtube_link': _youtubeController.text.trim(),
        'fb_link': _facebookController.text.trim(),
      }, endpoint: 'new_apis/site_settings_api.php');

      // 3. API Keys (Only update if user typed something other than "••••••••••••••••")
      final googleClientId = _googleClientIdController.text.trim();
      final googleSecret = _googleSecretController.text.trim();
      final googleCloudKey = _googleCloudKeyController.text.trim();
      final linkedinKey = _linkedinKeyController.text.trim();

      if (googleClientId != "••••••••••••••••" || googleSecret != "••••••••••••••••" || googleCloudKey != "••••••••••••••••" || linkedinKey != "••••••••••••••••") {
        await db.getData({
          'action': 'update_social_api',
          'google_app_id': googleClientId == "••••••••••••••••" ? "" : googleClientId,
          'google_secret_key': googleSecret == "••••••••••••••••" ? "" : googleSecret,
          'google_api_key': googleCloudKey == "••••••••••••••••" ? "" : googleCloudKey,
          'linkedin_app_id': linkedinKey == "••••••••••••••••" ? "" : linkedinKey,
        }, endpoint: 'new_apis/site_settings_api.php');
      }

      // 4. Zoom Credentials
      final zoomKey = _zoomApiKeyController.text.trim();
      final zoomSecret = _zoomSecretController.text.trim();
      if ((zoomKey.isNotEmpty && zoomKey != "••••••••••••••••") || (zoomSecret.isNotEmpty && zoomSecret != "••••••••••••••••")) {
        await db.getData({
          'action': 'set_zoom_credentials',
          'client_id': zoomKey == "••••••••••••••••" ? "" : zoomKey,
          'secret_id': zoomSecret == "••••••••••••••••" ? "" : zoomSecret,
        }, endpoint: 'new_apis/site_settings_api.php');
      }

      // 5. Payment Settings
      final rzpKey = _razorpayClientIdController.text.trim();
      final rzpSecret = _razorpaySecretController.text.trim();
      await db.getData({
        'action': 'update_razorpay',
        'use_parent_payment': _useParentPaymentGateway ? 1 : 0,
        'razorpay_key': rzpKey == "••••••••••••••••" ? "" : rzpKey,
        'razorpay_secret': rzpSecret == "••••••••••••••••" ? "" : rzpSecret,
      }, endpoint: 'new_apis/site_settings_api.php');

      // 6. Account Password Settings
      final oldPassword = _oldPasswordController.text.trim();
      final newPassword = _adminPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      if (oldPassword.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
        final pwdRes = await db.getData({
          'action': 'update_password',
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }, endpoint: 'new_apis/site_settings_api.php');

        if (pwdRes != null && pwdRes['success'] == false) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Password update failed: ${pwdRes['message']}"), backgroundColor: Colors.red),
          );
        }
      }

      // 7. SEO Settings
      await db.getData({
        'action': 'update_google_settings',
        'ga_code': _analyticCodeController.text.trim(),
        'gad_code': _adSenseCodeController.text.trim(),
        'seo_keywords': _seoKeywordsController.text.trim(),
        'seo_description': _seoDescriptionController.text.trim(),
      }, endpoint: 'new_apis/site_settings_api.php');

      _showSuccessDialog("All site configurations saved successfully!");
      _fetchSettings(); // Refresh
    } catch (e) {
      print("Error saving settings: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("An error occurred while saving settings"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _scrollToSection(String tabName) {
    setState(() {
      _activeTab = tabName;
      _accordionStates[tabName] = true; // Auto expand when jumping
    });

    final key = _sectionKeys[tabName];
    if (key != null && key.currentContext != null) {
      Scrollable.ensureVisible(
        key.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 54),
              const SizedBox(height: 16),
              const Text(
                "Success!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xff0b1c30)),
              ),
              const SizedBox(height: 8),
              Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff006565),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _siteNameController.dispose();
    _tagLineController.dispose();
    _aboutSiteController.dispose();
    _addressController.dispose();
    _linkedinController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    _googleClientIdController.dispose();
    _googleSecretController.dispose();
    _googleCloudKeyController.dispose();
    _linkedinKeyController.dispose();
    _zoomApiKeyController.dispose();
    _zoomSecretController.dispose();
    _razorpayClientIdController.dispose();
    _razorpaySecretController.dispose();
    _oldPasswordController.dispose();
    _adminPasswordController.dispose();
    _confirmPasswordController.dispose();
    _analyticCodeController.dispose();
    _adSenseCodeController.dispose();
    _seoKeywordsController.dispose();
    _seoDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f9ff),
      appBar: widget.isEmbedded
          ? null
          : AppBar(
              backgroundColor: const Color(0xfff8f9ff),
              elevation: 0,
              centerTitle: true,
              title: const Text(
                "Site Settings",
                style: TextStyle(
                  color: Color(0xff006565),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              leading: Navigator.canPop(context)
                  ? IconButton(
                      icon: const Icon(Icons.arrow_back, color: Color(0xff006565)),
                      onPressed: () => Navigator.pop(context),
                    )
                  : const Icon(Icons.menu, color: Color(0xff006565)),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 64),
        child: FloatingActionButton.extended(
          backgroundColor: const Color(0xff006565),
          foregroundColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Feature: Explore Marketplace Photographers is coming soon!"),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          icon: const Icon(Icons.photo_camera, size: 18),
          label: const Text("Explore Photographers", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xff006565)),
              ),
            )
          : Column(
              children: [
                // Quick Jump Anchor Menu
                _buildQuickJumpMenu(),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchSettings,
                    color: const Color(0xff006565),
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          // Section 1: General
                          _buildSection(
                            sectionKey: 'general',
                            title: "General Settings",
                            icon: Icons.settings,
                            child: _buildGeneralSettingsForm(),
                          ),

                          // Section 2: Social
                          _buildSection(
                            sectionKey: 'social',
                            title: "Social Settings",
                            icon: Icons.share,
                            child: _buildSocialSettingsForm(),
                          ),

                          // Section 3: API Integration
                          _buildSection(
                            sectionKey: 'api',
                            title: "API Integration",
                            icon: Icons.integration_instructions,
                            child: _buildApiSettingsForm(),
                          ),

                          // Section 4: Payment
                          _buildSection(
                            sectionKey: 'payment',
                            title: "Payment Integration",
                            icon: Icons.payments,
                            child: _buildPaymentSettingsForm(),
                          ),

                          // Section 5: Account Settings
                          _buildSection(
                            sectionKey: 'account',
                            title: "Account Settings",
                            icon: Icons.lock,
                            child: _buildAccountSettingsForm(),
                          ),

                          // Section 6: SEO Settings
                          _buildSection(
                            sectionKey: 'seo',
                            title: "SEO Settings",
                            icon: Icons.search,
                            child: _buildSeoSettingsForm(),
                          ),

                          // Section 7: Personalize Feed
                          _buildSection(
                            sectionKey: 'personalize',
                            title: "Personalize Feed",
                            icon: Icons.tune_rounded,
                            child: const PersonalizeFeedDialog(isEmbedded: true),
                          ),

                          // Footer Buttons
                          const SizedBox(height: 16),
                          _buildFooterButtons(),
                          const SizedBox(height: 80),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildQuickJumpMenu() {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: const Color(0xffbdc9c8).withOpacity(0.3)),
        ),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          _buildJumpTab('general', 'General'),
          _buildJumpTab('social', 'Social'),
          _buildJumpTab('api', 'API'),
          _buildJumpTab('payment', 'Payment'),
          _buildJumpTab('account', 'Account'),
          _buildJumpTab('seo', 'SEO'),
          _buildJumpTab('personalize', 'Personalize Feed'),
        ],
      ),
    );
  }

  Widget _buildJumpTab(String key, String label) {
    final bool isActive = _activeTab == key;
    return GestureDetector(
      onTap: () => _scrollToSection(key),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xffc6e9e9) : const Color(0xffeff4ff),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? const Color(0xff006565) : const Color(0xff3e4949),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String sectionKey,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final bool isExpanded = _accordionStates[sectionKey] ?? false;
    return Container(
      key: _sectionKeys[sectionKey],
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xffbdc9c8), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                _accordionStates[sectionKey] = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: const Color(0xff006565)),
                      const SizedBox(width: 12),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff0b1c30),
                        ),
                      ),
                    ],
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.expand_more, color: Color(0xff3e4949)),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(color: const Color(0xffbdc9c8).withOpacity(0.3)),
                ),
              ),
              child: child,
            ),
            crossFadeState: isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 250),
          ),
        ],
      ),
    );
  }

  // Forms Construction
  Widget _buildGeneralSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_siteNameController, "Site Name", "Enter site name"),
        const SizedBox(height: 12),
        _buildTextField(_tagLineController, "Tag Line", "Site motto or slogan"),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Logo Placeholder", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949))),
                  const SizedBox(height: 6),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xffeff4ff),
                      border: Border.all(color: const Color(0xffbdc9c8), style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.upload_file, size: 24, color: Color(0xff006565)),
                          Text("Upload Main Logo", style: TextStyle(fontSize: 10, color: Color(0xff3e4949))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Footer Logo Placeholder", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949))),
                  const SizedBox(height: 6),
                  Container(
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xffeff4ff),
                      border: Border.all(color: const Color(0xffbdc9c8), style: BorderStyle.solid),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.file_upload, size: 24, color: Color(0xff006565)),
                          Text("Upload Footer Logo", style: TextStyle(fontSize: 10, color: Color(0xff3e4949))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildTextField(_aboutSiteController, "About Site", "Brief description...", maxLines: 3),
        const SizedBox(height: 12),
        _buildTextField(_addressController, "Address", "Physical business address"),
      ],
    );
  }

  Widget _buildSocialSettingsForm() {
    return Column(
      children: [
        _buildIconTextField(_linkedinController, "LinkedIn", Icons.link, "https://linkedin.com/in/..."),
        const SizedBox(height: 12),
        _buildIconTextField(_twitterController, "Twitter", Icons.alternate_email, "https://twitter.com/..."),
        const SizedBox(height: 12),
        _buildIconTextField(_instagramController, "Instagram", Icons.camera_alt_outlined, "https://instagram.com/..."),
        const SizedBox(height: 12),
        _buildIconTextField(_youtubeController, "YouTube", Icons.smart_display_outlined, "https://youtube.com/..."),
        const SizedBox(height: 12),
        _buildIconTextField(_facebookController, "Facebook", Icons.public, "https://facebook.com/..."),
      ],
    );
  }

  Widget _buildApiSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(_googleClientIdController, "Google Client ID", "Enter ID"),
        const SizedBox(height: 12),
        _buildTextField(_googleSecretController, "Google Client Secret", "••••••••", obscureText: true),
        const SizedBox(height: 12),
        _buildTextField(_googleCloudKeyController, "Google Cloud Keys", "Enter key"),
        const SizedBox(height: 12),
        _buildTextField(_linkedinKeyController, "LinkedIn Keys", "Enter key"),
        const SizedBox(height: 16),
        const Divider(),
        const SizedBox(height: 12),
        const Text(
          "Video Call Settings (Zoom)",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xff006565)),
        ),
        const SizedBox(height: 12),
        _buildTextField(_zoomApiKeyController, "Zoom API Key", "Enter key"),
        const SizedBox(height: 12),
        _buildTextField(_zoomSecretController, "Zoom API Secret", "••••••••", obscureText: true),
      ],
    );
  }

  Widget _buildPaymentSettingsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: const Color(0xffeff4ff),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "Use Payment Gateway of parent site?",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xff0b1c30)),
                    ),
                    SizedBox(height: 2),
                    Text(
                      "If enabled, transactions will bypass local keys.",
                      style: TextStyle(fontSize: 11, color: Color(0xff3e4949)),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _useParentPaymentGateway,
                activeColor: const Color(0xff006565),
                onChanged: (val) {
                  setState(() {
                    _useParentPaymentGateway = val;
                  });
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Opacity(
          opacity: _useParentPaymentGateway ? 0.5 : 1.0,
          child: AbsorbPointer(
            absorbing: _useParentPaymentGateway,
            child: Column(
              children: [
                _buildTextField(_razorpayClientIdController, "Razorpay Client ID", "rzp_live_..."),
                const SizedBox(height: 12),
                _buildTextField(_razorpaySecretController, "Razorpay Secret Key", "••••••••", obscureText: true),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAccountSettingsForm() {
    return Column(
      children: [
        _buildTextField(_oldPasswordController, "Old Password", "Verify current password", obscureText: true),
        const SizedBox(height: 12),
        _buildTextField(_adminPasswordController, "New Administrative Password", "Update password", obscureText: true),
        const SizedBox(height: 12),
        _buildTextField(_confirmPasswordController, "Confirm Password", "Repeat password", obscureText: true),
      ],
    );
  }

  Widget _buildSeoSettingsForm() {
    return Column(
      children: [
        _buildTextField(_analyticCodeController, "Google Analytic Code", "Paste script tag here...", maxLines: 4, isMono: true),
        const SizedBox(height: 12),
        _buildTextField(_adSenseCodeController, "Google Ad Sense Code", "Paste ad script here...", maxLines: 3, isMono: true),
        const SizedBox(height: 12),
        _buildTextField(_seoKeywordsController, "SEO Keywords", "Keyword1, Keyword2, Keyword3...", maxLines: 2),
        const SizedBox(height: 12),
        _buildTextField(_seoDescriptionController, "SEO Description", "Maximum 160 characters for search results"),
      ],
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xff006565),
              side: const BorderSide(color: Color(0xff006565)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _fetchSettings, // Refresh settings back from DB
            child: const Text("Discard Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff006565),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: _saveAllSettings,
            child: const Text("Save All Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String hint, {
    int maxLines = 1,
    bool obscureText = false,
    bool isMono = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          style: TextStyle(
            fontSize: 13,
            fontFamily: isMono ? 'monospace' : null,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            fillColor: Colors.white,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xff006565), width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xffbdc9c8), width: 1.2),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIconTextField(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          width: 40,
          height: 40,
          margin: const EdgeInsets.only(bottom: 2),
          decoration: BoxDecoration(
            color: const Color(0xffeff4ff),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffbdc9c8), width: 1.2),
          ),
          child: Icon(icon, color: const Color(0xff006565), size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildTextField(controller, label, hint),
        ),
      ],
    );
  }
}
