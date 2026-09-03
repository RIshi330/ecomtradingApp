import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/widgets/personalize_feed_dialog.dart';

import '../services/auth_User_and_Business_Session.dart';

const String _kMasked = "••••••••••••••••";

// update_site_details expects multipart/form-data ($_FILES), which the
// JSON-only Database().getData() helper used elsewhere in this screen can't
// send. This posts directly with package:http instead.
// TODO: point this at your real API host — same one Database().getData()
// uses under the hood (visible in your debug logs as something like
// "http://YOUR_DOMAIN/seller/android/?endpoint=...").
const String _kApiBaseUrl = 'http://1jammu.in/seller/android/';
Uri _apiUri(String endpoint) => Uri.parse('$_kApiBaseUrl?endpoint=$endpoint');

// The PHP authenticates purely on admin_id (it resolves vendor_id from it
// server-side and ignores any vendor_id sent in the payload). Every call
// below must include this or the API responds 401 regardless of what else
// is sent.
// TODO: confirm this getter name matches your UserSessionSet class — it
// mirrors the existing `UserSessionSet.instance.vendorId` pattern used
// elsewhere in the app.
int get _adminId => int.tryParse(UserSessionSet.instance.vendorId.toString()) ?? 0;

class SiteSettingsScreen extends StatefulWidget {
  final bool isEmbedded;
  const SiteSettingsScreen({super.key, this.isEmbedded = false});

  @override
  State<SiteSettingsScreen> createState() => _SiteSettingsScreenState();
}

class _SiteSettingsScreenState extends State<SiteSettingsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = true;
  bool _isSaving = false;

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

  // city/pin have no fields in this form but update_general_settings
  // overwrites them unconditionally, so we round-trip whatever the server
  // returned instead of blanking them on every save.
  String _fetchedCity = '';
  String _fetchedPin = '';

  // Logo upload state. Server URLs come back from get_general_settings;
  // local File previews show immediately after picking, before the upload
  // finishes, so the tap feels responsive.
  final ImagePicker _imagePicker = ImagePicker();
  String? _siteLogoUrl;
  String? _footerLogoUrl;
  File? _pickedSiteLogo;
  File? _pickedFooterLogo;
  bool _uploadingSiteLogo = false;
  bool _uploadingFooterLogo = false;

  // Snapshot of the payment section as loaded, so we know whether the user
  // actually changed anything before calling update_razorpay (which does a
  // full overwrite of both key+secret, not a partial update).
  bool _originalUseParentPaymentGateway = false;

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
        'admin_id': _adminId,
      }, endpoint: 'new_apis/site_settings_api.php');

      if (res != null && res['success'] == true) {
        final data = res['data'] ?? {};
        setState(() {
          _siteNameController.text = data['site_name']?.toString() ?? '';
          _tagLineController.text = data['tag_line']?.toString() ?? '';
          _aboutSiteController.text = data['about_site']?.toString() ?? '';
          _addressController.text = data['state']?.toString() ?? '';

          // Not shown in this form, but must be preserved on save.
          _fetchedCity = data['city']?.toString() ?? '';
          _fetchedPin = data['pin']?.toString() ?? '';

          _siteLogoUrl = data['site_logo']?.toString();
          _footerLogoUrl = data['footer_logo']?.toString();
          // A fresh fetch means we have the real server URL now, so drop
          // any local preview from a just-completed upload.
          _pickedSiteLogo = null;
          _pickedFooterLogo = null;

          _linkedinController.text = data['linkedin_link']?.toString() ?? '';
          _twitterController.text = data['twitter_link']?.toString() ?? '';
          _instagramController.text = data['insta_link']?.toString() ?? '';
          _youtubeController.text = data['youtube_link']?.toString() ?? '';
          _facebookController.text = data['fb_link']?.toString() ?? '';

          // These are encrypted on the server, so we show a masked
          // placeholder rather than the real value. If the user leaves a
          // field showing this exact string, we treat it as "unchanged".
          _googleClientIdController.text = _hasValue(data['google_app']) ? _kMasked : "";
          _googleSecretController.text = _hasValue(data['google_secret']) ? _kMasked : "";
          _googleCloudKeyController.text = _hasValue(data['google_api_key']) ? _kMasked : "";
          _linkedinKeyController.text = _hasValue(data['linkedin_app']) ? _kMasked : "";
          _zoomApiKeyController.text = _hasValue(data['zoom_client_id']) ? _kMasked : "";
          _zoomSecretController.text = _hasValue(data['zoom_secret_key']) ? _kMasked : "";

          _useParentPaymentGateway = (int.tryParse(data['use_parent_payment']?.toString() ?? '0') ?? 0) == 1;
          _originalUseParentPaymentGateway = _useParentPaymentGateway;
          _razorpayClientIdController.text = _hasValue(data['razorpay_key']) ? _kMasked : "";
          _razorpaySecretController.text = _hasValue(data['razorpay_secret']) ? _kMasked : "";

          _analyticCodeController.text = data['ga_code']?.toString() ?? '';
          _adSenseCodeController.text = data['gad_code']?.toString() ?? '';
          _seoKeywordsController.text = data['seo_keywords']?.toString() ?? '';
          _seoDescriptionController.text = data['seo_description']?.toString() ?? '';
        });

        // Clear any password fields left over from a previous attempt.
        _oldPasswordController.clear();
        _adminPasswordController.clear();
        _confirmPasswordController.clear();
      } else if (res != null && res['success'] == false) {
        _showErrorSnack(res['message']?.toString() ?? 'Failed to load settings');
      }
    } catch (e) {
      print("Error fetching settings: $e");
      _showErrorSnack('Failed to load settings. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  bool _hasValue(dynamic v) => v != null && v.toString().trim().isNotEmpty;

  void _showErrorSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  /// Checks the sections whose API actions do a full overwrite of paired
  /// fields (Zoom, Razorpay) rather than a partial update, and blocks the
  /// save with a clear message instead of silently corrupting stored data
  /// by sending one real value and one blanked-out placeholder.
  List<String> _validateBeforeSave() {
    final errors = <String>[];

    final zoomKey = _zoomApiKeyController.text.trim();
    final zoomSecret = _zoomSecretController.text.trim();
    final zoomKeyChanged = zoomKey.isNotEmpty && zoomKey != _kMasked;
    final zoomSecretChanged = zoomSecret.isNotEmpty && zoomSecret != _kMasked;
    if (zoomKeyChanged != zoomSecretChanged) {
      errors.add('Enter both the Zoom API Key and Zoom API Secret together (or leave both unchanged).');
    }

    if (!_useParentPaymentGateway) {
      final rzpKey = _razorpayClientIdController.text.trim();
      final rzpSecret = _razorpaySecretController.text.trim();
      final rzpKeyChanged = rzpKey.isNotEmpty && rzpKey != _kMasked;
      final rzpSecretChanged = rzpSecret.isNotEmpty && rzpSecret != _kMasked;
      if (rzpKeyChanged != rzpSecretChanged) {
        errors.add('Enter both the Razorpay Client ID and Secret Key together (or leave both unchanged).');
      }
    }

    final oldPwd = _oldPasswordController.text.trim();
    final newPwd = _adminPasswordController.text.trim();
    final confirmPwd = _confirmPasswordController.text.trim();
    final anyPwdField = oldPwd.isNotEmpty || newPwd.isNotEmpty || confirmPwd.isNotEmpty;
    final allPwdFields = oldPwd.isNotEmpty && newPwd.isNotEmpty && confirmPwd.isNotEmpty;
    if (anyPwdField && !allPwdFields) {
      errors.add('Fill in all three password fields to change your password, or leave them all blank.');
    }
    if (allPwdFields && newPwd != confirmPwd) {
      errors.add('New password and confirm password do not match.');
    }

    return errors;
  }

  /// fieldKey must be the exact $_FILES key the PHP checks for:
  /// 'siteLogo' or 'footerLogo' (there's also 'siteFavicon' if you add a
  /// favicon uploader later the same way).
  Future<void> _pickAndUploadLogo({required String fieldKey}) async {
    final isSiteLogo = fieldKey == 'siteLogo';

    final XFile? picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (picked == null) return; // user cancelled

    final file = File(picked.path);

    setState(() {
      if (isSiteLogo) {
        _pickedSiteLogo = file;
        _uploadingSiteLogo = true;
      } else {
        _pickedFooterLogo = file;
        _uploadingFooterLogo = true;
      }
    });

    try {
      final request = http.MultipartRequest('POST', _apiUri('new_apis/site_settings_api.php'))
        ..fields['action'] = 'update_site_details'
        ..fields['admin_id'] = _adminId.toString()
      // update_site_details re-saves these text fields on every call
      // regardless of which image was uploaded, so send the form's
      // current values to avoid overwriting them with blanks.
        ..fields['siteName'] = _siteNameController.text.trim()
        ..fields['about_site'] = _aboutSiteController.text.trim()
        ..fields['tag_line'] = _tagLineController.text.trim()
        ..fields['address'] = _addressController.text.trim()
        ..fields['city'] = _fetchedCity
        ..fields['PIN'] = _fetchedPin
        ..files.add(await http.MultipartFile.fromPath(fieldKey, file.path));

      final streamed = await request.send();
      final response = await http.Response.fromStream(streamed);

      Map<String, dynamic>? decoded;
      try {
        if (response.body.isNotEmpty) {
          final parsed = jsonDecode(response.body);
          if (parsed is Map<String, dynamic>) decoded = parsed;
        }
      } catch (_) {
        decoded = null;
      }

      final success = decoded != null && decoded['success'] == true;
      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isSiteLogo ? 'Logo updated' : 'Footer logo updated')),
        );
        // Pull the real hosted URL back down so the preview matches what's
        // actually saved (and so other screens reading site_logo agree).
        await _fetchSettings();
      } else {
        _showErrorSnack(decoded?['message']?.toString() ?? 'Failed to upload image');
        setState(() {
          if (isSiteLogo) {
            _pickedSiteLogo = null;
          } else {
            _pickedFooterLogo = null;
          }
        });
      }
    } catch (e) {
      print('Error uploading $fieldKey: $e');
      if (!mounted) return;
      _showErrorSnack('Failed to upload image. Please try again.');
      setState(() {
        if (isSiteLogo) {
          _pickedSiteLogo = null;
        } else {
          _pickedFooterLogo = null;
        }
      });
    } finally {
      if (mounted) {
        setState(() {
          if (isSiteLogo) {
            _uploadingSiteLogo = false;
          } else {
            _uploadingFooterLogo = false;
          }
        });
      }
    }
  }

  Future<void> _saveAllSettings() async {
    final validationErrors = _validateBeforeSave();
    if (validationErrors.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Please fix the following'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: validationErrors.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $e'),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final failures = <String>[];

    try {
      final db = Database();

      // 1. General Settings — city/pin round-tripped from the last fetch
      // so this section (which has no UI for them) doesn't blank them out.
      final generalRes = await db.getData({
        'action': 'update_general_settings',
        'admin_id': _adminId,
        'site_name': _siteNameController.text.trim(),
        'tag_line': _tagLineController.text.trim(),
        'about_site': _aboutSiteController.text.trim(),
        'state': _addressController.text.trim(),
        'city': _fetchedCity,
        'pin': _fetchedPin,
      }, endpoint: 'new_apis/site_settings_api.php');
      if (generalRes != null && generalRes['success'] == false) {
        failures.add('General settings: ${generalRes['message'] ?? 'failed'}');
      }

      // 2. Social Settings — every field is present in this form, so a full
      // overwrite here is correct and intended.
      final socialRes = await db.getData({
        'action': 'update_social_links',
        'admin_id': _adminId,
        'linkedin_link': _linkedinController.text.trim(),
        'twitter_link': _twitterController.text.trim(),
        'insta_link': _instagramController.text.trim(),
        'youtube_link': _youtubeController.text.trim(),
        'fb_link': _facebookController.text.trim(),
      }, endpoint: 'new_apis/site_settings_api.php');
      if (socialRes != null && socialRes['success'] == false) {
        failures.add('Social links: ${socialRes['message'] ?? 'failed'}');
      }

      // 3. API Keys — KNOWN LIMITATION: update_social_api overwrites
      // fb_app/fb_secret/twitter_app/twitter_secret unconditionally, but
      // this form has no fields for them, so calling this action clears
      // them. We only call it when Google/LinkedIn actually changed to
      // minimize how often that happens, but it isn't fully avoidable
      // without the API accepting partial updates (like
      // update_website_settings already does). See the info note under
      // this section in the UI.
      final googleClientId = _googleClientIdController.text.trim();
      final googleSecret = _googleSecretController.text.trim();
      final googleCloudKey = _googleCloudKeyController.text.trim();
      final linkedinKey = _linkedinKeyController.text.trim();

      final socialApiChanged = googleClientId != _kMasked ||
          googleSecret != _kMasked ||
          googleCloudKey != _kMasked ||
          linkedinKey != _kMasked;

      if (socialApiChanged) {
        final apiRes = await db.getData({
          'action': 'update_social_api',
          'admin_id': _adminId,
          'google_app_id': googleClientId == _kMasked ? "" : googleClientId,
          'google_secret_key': googleSecret == _kMasked ? "" : googleSecret,
          'google_api_key': googleCloudKey == _kMasked ? "" : googleCloudKey,
          'linkedin_app_id': linkedinKey == _kMasked ? "" : linkedinKey,
        }, endpoint: 'new_apis/site_settings_api.php');
        if (apiRes != null && apiRes['success'] == false) {
          failures.add('API keys: ${apiRes['message'] ?? 'failed'}');
        }
      }

      // 4. Zoom Credentials — only call when both changed together
      // (validated above), so we never send one real value + one blank.
      final zoomKey = _zoomApiKeyController.text.trim();
      final zoomSecret = _zoomSecretController.text.trim();
      final zoomChanged = zoomKey.isNotEmpty && zoomKey != _kMasked;
      if (zoomChanged) {
        final zoomRes = await db.getData({
          'action': 'set_zoom_credentials',
          'admin_id': _adminId,
          'client_id': zoomKey,
          'secret_id': zoomSecret,
        }, endpoint: 'new_apis/site_settings_api.php');
        if (zoomRes != null && zoomRes['success'] == false) {
          failures.add('Zoom credentials: ${zoomRes['message'] ?? 'failed'}');
        }
      }

      // 5. Payment Settings — only call if the toggle changed or the key
      // pair actually changed together (validated above). This is the fix
      // for the bug where saving with untouched masked fields wiped the
      // stored Razorpay key/secret.
      final rzpKey = _razorpayClientIdController.text.trim();
      final rzpSecret = _razorpaySecretController.text.trim();
      final rzpKeysChanged = rzpKey.isNotEmpty && rzpKey != _kMasked;
      final paymentToggleChanged = _useParentPaymentGateway != _originalUseParentPaymentGateway;

      if (paymentToggleChanged || rzpKeysChanged) {
        final paymentRes = await db.getData({
          'action': 'update_razorpay',
          'admin_id': _adminId,
          'use_parent_payment': _useParentPaymentGateway ? 1 : 0,
          'razorpay_key': rzpKey == _kMasked ? "" : rzpKey,
          'razorpay_secret': rzpSecret == _kMasked ? "" : rzpSecret,
        }, endpoint: 'new_apis/site_settings_api.php');
        if (paymentRes != null && paymentRes['success'] == false) {
          failures.add('Payment settings: ${paymentRes['message'] ?? 'failed'}');
        }
      }

      // 6. Account Password Settings
      final oldPassword = _oldPasswordController.text.trim();
      final newPassword = _adminPasswordController.text.trim();
      final confirmPassword = _confirmPasswordController.text.trim();
      if (oldPassword.isNotEmpty && newPassword.isNotEmpty && confirmPassword.isNotEmpty) {
        final pwdRes = await db.getData({
          'action': 'update_password',
          'admin_id': _adminId,
          'old_password': oldPassword,
          'new_password': newPassword,
          'confirm_password': confirmPassword,
        }, endpoint: 'new_apis/site_settings_api.php');

        if (pwdRes != null && pwdRes['success'] == false) {
          failures.add('Password: ${pwdRes['message'] ?? 'failed'}');
        } else {
          _oldPasswordController.clear();
          _adminPasswordController.clear();
          _confirmPasswordController.clear();
        }
      }

      // 7. SEO Settings — every field is present in this form.
      final seoRes = await db.getData({
        'action': 'update_google_settings',
        'admin_id': _adminId,
        'ga_code': _analyticCodeController.text.trim(),
        'gad_code': _adSenseCodeController.text.trim(),
        'seo_keywords': _seoKeywordsController.text.trim(),
        'seo_description': _seoDescriptionController.text.trim(),
      }, endpoint: 'new_apis/site_settings_api.php');
      if (seoRes != null && seoRes['success'] == false) {
        failures.add('SEO settings: ${seoRes['message'] ?? 'failed'}');
      }

      if (failures.isEmpty) {
        _showSuccessDialog("All site configurations saved successfully!");
      } else {
        _showFailureDialog(failures);
      }
      await _fetchSettings(); // Refresh from server either way
    } catch (e) {
      print("Error saving settings: $e");
      _showErrorSnack("An error occurred while saving settings");
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
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

  void _showFailureDialog(List<String> failures) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red),
              SizedBox(width: 8),
              Text("Some sections failed to save"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: failures.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text('• $f'),
            )).toList(),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
          ],
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
                    // _buildSection(
                    //   sectionKey: 'personalize',
                    //   title: "Personalize Feed",
                    //   icon: Icons.tune_rounded,
                    //   child: const PersonalizeFeedDialog(isEmbedded: true),
                    // ),

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
  Widget _buildLogoUploadBox({
    required String? imageUrl,
    required File? localFile,
    required bool isUploading,
    required IconData placeholderIcon,
    required String placeholderLabel,
    required VoidCallback onTap,
  }) {
    final hasLocalFile = localFile != null;
    final hasRemoteUrl = imageUrl != null && imageUrl.isNotEmpty;

    Widget imageChild;
    if (hasLocalFile) {
      imageChild = Image.file(localFile, fit: BoxFit.contain);
    } else if (hasRemoteUrl) {
      imageChild = Image.network(
        imageUrl,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(placeholderIcon, size: 24, color: const Color(0xff006565)),
            Text(placeholderLabel, style: const TextStyle(fontSize: 10, color: Color(0xff3e4949))),
          ],
        ),
      );
    } else {
      imageChild = Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(placeholderIcon, size: 24, color: const Color(0xff006565)),
          Text(placeholderLabel, style: const TextStyle(fontSize: 10, color: Color(0xff3e4949))),
        ],
      );
    }

    return InkWell(
      onTap: isUploading ? null : onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 80,
        width: double.infinity,
        padding: (hasLocalFile || hasRemoteUrl) ? const EdgeInsets.all(6) : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: const Color(0xffeff4ff),
          border: Border.all(color: const Color(0xffbdc9c8)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Center(child: imageChild),
            if (isUploading)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xff006565)),
                  ),
                ),
              )
            else if (hasLocalFile || hasRemoteUrl)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(color: Color(0xff006565), shape: BoxShape.circle),
                  child: const Icon(Icons.edit, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }

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
                  const Text("Site Logo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949))),
                  const SizedBox(height: 6),
                  _buildLogoUploadBox(
                    imageUrl: _siteLogoUrl,
                    localFile: _pickedSiteLogo,
                    isUploading: _uploadingSiteLogo,
                    placeholderIcon: Icons.upload_file,
                    placeholderLabel: "Upload Main Logo",
                    onTap: () => _pickAndUploadLogo(fieldKey: 'siteLogo'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Footer Logo", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xff3e4949))),
                  const SizedBox(height: 6),
                  _buildLogoUploadBox(
                    imageUrl: _footerLogoUrl,
                    localFile: _pickedFooterLogo,
                    isUploading: _uploadingFooterLogo,
                    placeholderIcon: Icons.file_upload,
                    placeholderLabel: "Upload Footer Logo",
                    onTap: () => _pickAndUploadLogo(fieldKey: 'footerLogo'),
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
        Container(
          padding: const EdgeInsets.all(10),
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: const Color(0xfffff3e0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xffffcc80)),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Color(0xffb26a00)),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "This section only manages Google & LinkedIn keys. Saving it will also clear stored Facebook/Twitter API keys on the server, since this screen has no fields for those.",
                  style: TextStyle(fontSize: 11, color: Color(0xffb26a00)),
                ),
              ),
            ],
          ),
        ),
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
            onPressed: _isSaving ? null : _fetchSettings, // Refresh settings back from DB
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
            onPressed: _isSaving ? null : _saveAllSettings,
            child: _isSaving
                ? const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
                : const Text("Save All Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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