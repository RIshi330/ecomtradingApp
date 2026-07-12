import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/Database/Database.dart';
import 'package:trading_ecommerce_admin/services/auth_service.dart';
import 'package:trading_ecommerce_admin/index.dart';

import 'otp_varification.dart';

class BusinessUserProfileScreen extends StatefulWidget {
  final VoidCallback? onManagePlanTap;
  final VoidCallback? onAddressUpdateTap;
  final VoidCallback? onBankAddTap;
  const BusinessUserProfileScreen({
    super.key,
    this.onManagePlanTap,
    this.onAddressUpdateTap,
    this.onBankAddTap,
  });

  @override
  State<BusinessUserProfileScreen> createState() => _BusinessUserProfileScreenState();
}

class _BusinessUserProfileScreenState extends State<BusinessUserProfileScreen> {
  // Theme constants
  static const Color primaryTeal = Color(0xff006565);
  static const Color accentTeal = Color(0xff008080);
  static const Color containerTeal = Color(0xffe3fffe);
  static const Color surfaceWhite = Colors.white;
  static const Color borderTeal = Color(0xffbdc9c8);
  static const Color textDark = Color(0xff1a1c1c);
  static const Color textMuted = Color(0xff3e4949);
  static const Color bgLight = Color(0xfff9f9f9);
  static const Color errorColor = Color(0xffba1a1a);

  // Endpoint that hosts all the profile/security actions used below
  // (send_update_profile_otp, verify_update_profile_otp, update_profile,
  // send_change_password_otp, verify_change_password_otp, change_password).
  static const String _profileEndpoint = 'new_apis/admin/community_admin_profile.php';

  bool _isLoading = false;

  // State profile values
  String _name = "Alex Stratos";
  String _title = "Principal Strategy Director";
  String _division = "Admin Division";
  String _profileImage = "https://lh3.googleusercontent.com/aida-public/AB6AXuB0sBpNBx1QS11_GtuG8ZvllUABR2Fjuoazj2iYY_2AzMxv0Hb5qVWhqkqFHwJa0jdUlFmuUShxo3PEq1f9ahyaSmIynMU3pgWfgzous6ZsIU7zAPIgt5PEF8oeIxo2A0KH-6mlUdQkx1NUxVNz3_RKqiYNiBnGEaE4F8WOD4YJSO-FiD212jPRPCyatkgTpAiSkS66oFNYXgOzrtuNl-5eeXCTXMq-3EyoEBmh00Zur_HokwvN8TMl";
  String _email = "a.stratos@serene.corp";
  String _mobile = "";
  String _bio = "";
  String _city = "";
  String _state = "";
  String _country = "";

  // Financial values
  double _walletBalance = 142850.00;
  String _bankName = "Universal Trust Bank";
  String _bankAccMasked = "•••• •••• •••• 8821";
  bool _hasBankDetails = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData().then((_) {
      _fetchBalances();
      _fetchLinkedBank();
    });
  }

  Future<void> _loadProfileData() async {
    final cached = await AuthService.getCachedUserData();
    if (cached != null) {
      setState(() {
        _name = cached['name']?.toString() ?? _name;
        _email = cached['email']?.toString() ?? _email;
        _mobile = cached['mobile']?.toString() ?? _mobile;
        _bio = cached['bio']?.toString() ?? _bio;
        _city = cached['city']?.toString() ?? _city;
        _state = cached['state']?.toString() ?? _state;
        _country = cached['country']?.toString() ?? _country;
        if (cached['profile_pic'] != null && cached['profile_pic'].toString().isNotEmpty) {
          _profileImage = cached['profile_pic'].toString();
        }
      });
    }

    try {
      final vendorId = await AuthService.getVendorIdString();
      final response = await Database().getData({
        'action': 'profile_tab',
      }, endpoint: 'new_apis/vendor_details_api.php');

      if (response['success'] == true && response['data'] != null) {
        final profile = response['data']['profile'];
        if (profile != null) {
          setState(() {
            _name = profile['name']?.toString() ?? _name;
            _email = profile['email']?.toString() ?? _email;
            _mobile = profile['mobile']?.toString() ?? _mobile;
            _bio = profile['bio']?.toString() ?? _bio;
            final workPref = profile['work_preference']?.toString() ?? '';
            if (workPref.isNotEmpty) {
              _title = workPref;
            }
            final pic = profile['profile_pic']?.toString() ?? '';
            if (pic.isNotEmpty) {
              _profileImage = pic;
            }
          });
          await AuthService.saveLoginSession(
            vendorId: int.parse(vendorId),
            userData: Map<String, dynamic>.from(profile),
          );
        }
      }
    } catch (e) {
      debugPrint("Error loading profile from API: $e");
    }
  }

  String _stripHtml(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll('&nbsp;', ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"');
  }

  Future<void> _fetchBalances() async {
    try {
      final vendorId = await AuthService.getVendorIdString();
      final balanceRes = await Database().getJsonData({
        'action': 'get_balances',
        'vendor_id': vendorId,
      }, endpoint: 'new_apis/payment_modal_API 1.php');

      if (balanceRes['success'] == true && balanceRes['data'] != null) {
        final data = balanceRes['data'];
        setState(() {
          _walletBalance = double.tryParse(data['ewallet_balance']?.toString() ?? '142850') ?? 142850.0;
        });
      }
    } catch (_) {}
  }

  Future<void> _fetchLinkedBank() async {
    try {
      final vendorId = await AuthService.getVendorIdString();
      final response = await Database().getData({
        'action': 'fetch_all',
        'vendor_id': vendorId,
      }, endpoint: 'new_apis/bank_details_API.php');

      if ((response['success'] == true || response['status'] == 200) && response['data'] != null) {
        final List data = response['data'];
        if (data.isNotEmpty) {
          final defaultAcc = data.firstWhere((acc) => acc['default'] == "1", orElse: () => data.first);
          setState(() {
            _bankName = defaultAcc['bank_name']?.toString() ?? "Universal Trust Bank";
            final rawAcc = defaultAcc['account_number']?.toString() ?? "8821";
            _bankAccMasked = rawAcc.length > 4
                ? "•••• •••• •••• ${rawAcc.substring(rawAcc.length - 4)}"
                : "•••• •••• •••• $rawAcc";
            _hasBankDetails = true;
          });
        }
      }
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // EDIT PROFILE FLOW
  // Step 1: collect edited fields in a form sheet, then request an OTP.
  // Step 2: push the OtpVerificationScreen; its onVerify calls
  //         verify_update_profile_otp then update_profile, matching
  //         community_admin_profile.php exactly (both require the OTP
  //         to be verified in-session before update_profile succeeds).
  // ---------------------------------------------------------------------
  void _startEditProfileFlow() {
    final nameCtrl = TextEditingController(text: _name);
    final mobileCtrl = TextEditingController(text: _mobile);
    final bioCtrl = TextEditingController(text: _bio);
    final cityCtrl = TextEditingController(text: _city);
    final stateCtrl = TextEditingController(text: _state);
    final countryCtrl = TextEditingController(text: _country);
    final titleCtrl = TextEditingController(text: _title);
    String selectedDiv = _division;
    bool isSendingOtp = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            return Container(
              height: MediaQuery.of(sheetContext).size.height * 0.85,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Edit Profile",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'Manrope'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: textMuted),
                        onPressed: () => Navigator.pop(sheetContext),
                      )
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text("FULL NAME", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                          const SizedBox(height: 12),
                          const Text("MOBILE NUMBER", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: mobileCtrl,
                            keyboardType: TextInputType.phone,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                          const SizedBox(height: 12),
                          const Text("BIO", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: bioCtrl,
                            maxLines: 2,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("CITY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: cityCtrl,
                                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text("STATE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                                    const SizedBox(height: 6),
                                    TextField(
                                      controller: stateCtrl,
                                      decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          const Text("COUNTRY", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: countryCtrl,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                          const SizedBox(height: 12),
                          const Text("PROFESSIONAL TITLE", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: titleCtrl,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                          ),
                          const SizedBox(height: 12),
                          const Text("DIVISION", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: selectedDiv,
                            decoration: const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
                            items: const [
                              DropdownMenuItem(value: "Admin Division", child: Text("Admin Division")),
                              DropdownMenuItem(value: "Marketing Division", child: Text("Marketing Division")),
                              DropdownMenuItem(value: "Finance Division", child: Text("Finance Division")),
                              DropdownMenuItem(value: "Operations Division", child: Text("Operations Division")),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setModalState(() => selectedDiv = val);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: containerTeal.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: const [
                                Icon(Icons.info_outline, color: primaryTeal, size: 18),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "An OTP will be sent to your registered email to verify this profile change.",
                                    style: TextStyle(fontSize: 12, color: primaryTeal, fontWeight: FontWeight.w500),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accentTeal,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: isSendingOtp
                                      ? null
                                      : () async {
                                    if (nameCtrl.text.isEmpty) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        const SnackBar(content: Text("Name is required"), backgroundColor: Colors.red),
                                      );
                                      return;
                                    }
                                    setModalState(() => isSendingOtp = true);
                                    try {
                                      final response = await Database().getData({
                                        'action': 'send_update_profile_otp',
                                      }, endpoint: _profileEndpoint);

                                      if (response['success'] == true) {
                                        Navigator.pop(sheetContext); // close the form
                                        _openOtpVerification(
                                          nameCtrl: nameCtrl,
                                          mobileCtrl: mobileCtrl,
                                          bioCtrl: bioCtrl,
                                          cityCtrl: cityCtrl,
                                          stateCtrl: stateCtrl,
                                          countryCtrl: countryCtrl,
                                          titleCtrl: titleCtrl,
                                          selectedDiv: selectedDiv,
                                        );
                                      } else {
                                        ScaffoldMessenger.of(sheetContext).showSnackBar(
                                          SnackBar(
                                            content: Text(response['message']?.toString() ?? "Failed to send OTP"),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    } catch (e) {
                                      ScaffoldMessenger.of(sheetContext).showSnackBar(
                                        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                                      );
                                    } finally {
                                      if (sheetContext.mounted) {
                                        setModalState(() => isSendingOtp = false);
                                      }
                                    }
                                  },
                                  child: isSendingOtp
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                  )
                                      : const Text("Send OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  onPressed: () => Navigator.pop(sheetContext),
                                  child: const Text("Cancel", style: TextStyle(color: textMuted)),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Pushes the OTP screen and wires its verify/resend callbacks straight
  /// to community_admin_profile.php. `onVerify` runs BOTH API calls in
  /// sequence — verify_update_profile_otp, then update_profile — because
  /// the PHP's update_profile action rejects the request unless
  /// `$_SESSION['update_profile_verified']` was just set to true by the
  /// verify step. Throwing inside `onVerify` is caught by the OTP screen
  /// itself and shown as a red snackbar; returning normally auto-pops the
  /// screen with `true`.
  Future<void> _openOtpVerification({
    required TextEditingController nameCtrl,
    required TextEditingController mobileCtrl,
    required TextEditingController bioCtrl,
    required TextEditingController cityCtrl,
    required TextEditingController stateCtrl,
    required TextEditingController countryCtrl,
    required TextEditingController titleCtrl,
    required String selectedDiv,
  }) async {
    final verified = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => OtpVerificationScreen(
          email: _email,
          onVerify: (otp) async {
            final verifyRes = await Database().getData({
              'action': 'verify_update_profile_otp',
              'otp': otp,
            }, endpoint: _profileEndpoint);

            if (verifyRes['success'] != true) {
              throw Exception(verifyRes['message']?.toString() ?? "Invalid or expired OTP");
            }

            final updateRes = await Database().getData({
              'action': 'update_profile',
              'name': nameCtrl.text,
              'mobile': mobileCtrl.text,
              'bio': bioCtrl.text,
              'city': cityCtrl.text,
              'state': stateCtrl.text,
              'country': countryCtrl.text,
            }, endpoint: _profileEndpoint);

            if (updateRes['success'] != true) {
              throw Exception(updateRes['message']?.toString() ?? "Failed to update profile");
            }

            // Reflect the change locally + in cache only after the API confirms it.
            if (mounted) {
              setState(() {
                _name = nameCtrl.text;
                _mobile = mobileCtrl.text;
                _bio = bioCtrl.text;
                _city = cityCtrl.text;
                _state = stateCtrl.text;
                _country = countryCtrl.text;
                _title = titleCtrl.text;
                _division = selectedDiv;
              });
            }

            final vendorId = await AuthService.getVendorIdString();
            final cached = await AuthService.getCachedUserData() ?? <String, dynamic>{};
            cached['name'] = nameCtrl.text;
            cached['mobile'] = mobileCtrl.text;
            cached['bio'] = bioCtrl.text;
            cached['city'] = cityCtrl.text;
            cached['state'] = stateCtrl.text;
            cached['country'] = countryCtrl.text;
            await AuthService.saveLoginSession(
              vendorId: int.tryParse(vendorId) ?? 0,
              userData: cached,
            );
          },
          onResend: () async {
            final res = await Database().getData({
              'action': 'send_update_profile_otp',
            }, endpoint: _profileEndpoint);
            if (res['success'] != true) {
              throw Exception(res['message']?.toString() ?? "Failed to resend OTP");
            }
          },
        ),
      ),
    );

    if (verified == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!"), backgroundColor: Colors.green),
      );
    }
  }

  // ---------------------------------------------------------------------
  // CHANGE PASSWORD FLOW (unchanged from before)
  // ---------------------------------------------------------------------
  void _showChangePasswordModal() {
    int currentStep = 1;
    bool isModalLoading = false;
    final newPassCtrl = TextEditingController();
    final confirmPassCtrl = TextEditingController();
    final otpCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Widget stepContent;

            if (isModalLoading) {
              stepContent = const SizedBox(
                height: 200,
                child: Center(
                  child: CircularProgressIndicator(color: primaryTeal),
                ),
              );
            } else if (currentStep == 1) {
              stepContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("NEW PASSWORD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: newPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "••••••••"),
                  ),
                  const SizedBox(height: 16),
                  const Text("CONFIRM NEW PASSWORD", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: confirmPassCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(border: OutlineInputBorder(), hintText: "••••••••"),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (newPassCtrl.text.isEmpty || confirmPassCtrl.text.isEmpty) return;
                        if (newPassCtrl.text != confirmPassCtrl.text) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Passwords do not match!"), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        setModalState(() {
                          isModalLoading = true;
                        });
                        try {
                          final response = await Database().getData({
                            'action': 'send_change_password_otp',
                          }, endpoint: _profileEndpoint);

                          if (response['success'] == true) {
                            setModalState(() {
                              currentStep = 2;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(response['message']?.toString() ?? "Failed to send OTP"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                          );
                        } finally {
                          setModalState(() {
                            isModalLoading = false;
                          });
                        }
                      },
                      child: const Text("Send OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              );
            } else if (currentStep == 2) {
              stepContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: containerTeal,
                    child: const Icon(Icons.mail_outline_rounded, color: primaryTeal, size: 36),
                  ),
                  const SizedBox(height: 20),
                  const Text("Check your inbox", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  Text(
                    "OTP sent to your registered email: $_email",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                      onPressed: () {
                        setModalState(() {
                          currentStep = 3;
                        });
                      },
                      child: const Text("Enter OTP", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              );
            } else if (currentStep == 3) {
              stepContent = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Please enter the 6-digit code sent to your email.",
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: otpCtrl,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 16),
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      counterText: "",
                      hintText: "000000",
                      hintStyle: TextStyle(color: Colors.grey, letterSpacing: 16),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () async {
                        setModalState(() {
                          isModalLoading = true;
                        });
                        try {
                          final response = await Database().getData({
                            'action': 'send_change_password_otp',
                          }, endpoint: _profileEndpoint);

                          if (response['success'] == true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("OTP resent successfully!"), backgroundColor: Colors.green),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response['message']?.toString() ?? "Failed to resend OTP"), backgroundColor: Colors.red),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                          );
                        } finally {
                          setModalState(() {
                            isModalLoading = false;
                          });
                        }
                      },
                      child: const Text("Resend code", style: TextStyle(color: primaryTeal, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                      onPressed: () async {
                        if (otpCtrl.text.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please enter a 6-digit OTP"), backgroundColor: Colors.red),
                          );
                          return;
                        }
                        setModalState(() {
                          isModalLoading = true;
                        });
                        try {
                          // 1. Verify OTP
                          final verifyRes = await Database().getData({
                            'action': 'verify_change_password_otp',
                            'otp': otpCtrl.text,
                          }, endpoint: _profileEndpoint);

                          if (verifyRes['success'] != true) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(verifyRes['message']?.toString() ?? "Invalid or expired OTP"),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          // 2. Change Password
                          final updateRes = await Database().getData({
                            'action': 'change_password',
                            'new_password': newPassCtrl.text,
                          }, endpoint: _profileEndpoint);

                          if (updateRes['success'] == true) {
                            setModalState(() {
                              currentStep = 4;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(updateRes['message']?.toString() ?? "Failed to update password"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                          );
                        } finally {
                          setModalState(() {
                            isModalLoading = false;
                          });
                        }
                      },
                      child: const Text("Verify & Update", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              );
            } else {
              stepContent = Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(0xffe8f5e9),
                    child: Icon(Icons.check_circle_rounded, color: Colors.green, size: 40),
                  ),
                  const SizedBox(height: 20),
                  const Text("Password Updated", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                  const SizedBox(height: 8),
                  const Text(
                    "Your credentials have been successfully updated. Current session remains active.",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: textMuted),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Back to Profile", style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  )
                ],
              );
            }

            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                top: 20,
                left: 20,
                right: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          currentStep == 1
                              ? "Change Password"
                              : (currentStep == 2 ? "Verify Identity" : (currentStep == 3 ? "Enter Code" : "Success")),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'Manrope'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: textMuted),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    stepContent,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showWithdrawalModal() {
    final amountCtrl = TextEditingController(text: "10000");
    int withdrawStep = 1;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (withdrawStep == 1) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 24,
                  top: 20,
                  left: 20,
                  right: 20,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Withdraw Funds",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal, fontFamily: 'Manrope'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: textMuted),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    const Text("WITHDRAWAL AMOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountCtrl,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: primaryTeal),
                      decoration: const InputDecoration(
                        prefixText: "₹ ",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text("Available: ₹ ${_walletBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: textMuted)),
                    const SizedBox(height: 20),
                    const Text("DESTINATION ACCOUNT", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textMuted)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: containerTeal.withOpacity(0.5),
                        border: Border.all(color: primaryTeal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.account_balance_rounded, color: primaryTeal),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                                Text(_bankAccMasked, style: const TextStyle(fontSize: 11, color: textMuted)),
                              ],
                            ),
                          ),
                          const Icon(Icons.check_circle, color: primaryTeal, size: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: bgLight,
                        border: Border.all(color: borderTeal),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text("Processing Fee", style: TextStyle(fontSize: 13, color: textMuted)),
                              Text("₹ 0.00", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Total to Bank", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                              Text("₹ ${amountCtrl.text}", style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryTeal)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                        onPressed: () async {
                          final withdrawAmount = double.tryParse(amountCtrl.text) ?? 0.0;
                          if (withdrawAmount <= 0) return;

                          try {
                            final res = await Database().getData({
                              'action': 'requestWithdraw',
                              'requestedAmount': withdrawAmount.toString(),
                              'description': 'Dossier withdrawal request',
                              'receiveTo': 'bank',
                            }, endpoint: 'new_apis/withdrawl_request_api.php');

                            if (res['success'] == true || res['status'] == 200) {
                              setState(() {
                                _walletBalance -= withdrawAmount;
                              });
                              setModalState(() {
                                withdrawStep = 2;
                              });
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(res['error']?.toString() ?? "Failed to request withdrawal."), backgroundColor: Colors.red),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Error submitting withdrawal: $e"), backgroundColor: Colors.red),
                            );
                          }
                        },
                        child: const Text("Request Withdrawal", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(
                      radius: 36,
                      backgroundColor: containerTeal,
                      child: Icon(Icons.schedule_rounded, color: primaryTeal, size: 36),
                    ),
                    const SizedBox(height: 20),
                    const Text("Request Submitted", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 8),
                    Text(
                      "Withdrawal of ₹ ${amountCtrl.text} is being processed. Funds typically arrive within 1-2 business days.",
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, color: textMuted),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: accentTeal, foregroundColor: Colors.white),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Done", style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        );
      },
    );
  }

  void _handleLogout() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.power_settings_new_rounded,
                      color: Color(0xFFC62828),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sign Out",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textDark,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          "Confirm account log out",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                "Are you sure you want to sign out of your account?\nYou will need to enter your credentials to log back in.",
                style: TextStyle(
                  fontSize: 13,
                  color: textMuted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        foregroundColor: textDark,
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await AuthService.logout();
                        if (mounted) {
                          Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFEBEE),
                        foregroundColor: const Color(0xFFC62828),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Logout",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgLight,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Profile Header
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderTeal),
              ),
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: containerTeal,
                        backgroundImage: NetworkImage(_profileImage),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 10,
                          backgroundColor: primaryTeal,
                          child: const Icon(Icons.verified, size: 12, color: Colors.white),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: textDark, fontFamily: 'Manrope')),
                        const SizedBox(height: 4),
                        Text("$_title  •  $_division", style: const TextStyle(fontSize: 12, color: textMuted, fontWeight: FontWeight.w500)),
                        if (_mobile.isNotEmpty || _bio.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            _bio.isNotEmpty ? _stripHtml(_bio) : _mobile,
                            style: const TextStyle(fontSize: 11, color: textMuted, fontStyle: FontStyle.italic),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryTeal,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                minimumSize: const Size(0, 36),
                              ),
                              icon: const Icon(Icons.edit, size: 14),
                              label: const Text("Edit Profile", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                              onPressed: _startEditProfileFlow,
                            ),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Security Hub & Membership row
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 195,
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderTeal),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("Security Hub", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                            Icon(Icons.security, color: primaryTeal, size: 20),
                          ],
                        ),
                        const Spacer(),
                        const Text("PASSWORD MANAGEMENT", style: TextStyle(fontSize: 9, color: textMuted, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text("Last changed 24 days ago.", style: TextStyle(fontSize: 11, color: textMuted)),
                        const SizedBox(height: 8),
                        GestureDetector(
                          onTap: _showChangePasswordModal,
                          child: Row(
                            children: const [
                              Text("Change Password", style: TextStyle(color: primaryTeal, fontSize: 12, fontWeight: FontWeight.bold)),
                              SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios, size: 10, color: primaryTeal),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 195,
                    decoration: BoxDecoration(
                      color: surfaceWhite,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderTeal),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Membership", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(color: const Color(0xfffef3c7), borderRadius: BorderRadius.circular(6)),
                              child: const Text("ELITE", style: TextStyle(color: Color(0xffd97706), fontSize: 9, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                        const Spacer(),
                        const Text("CURRENT PLAN", style: TextStyle(fontSize: 9, color: textMuted, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        const Text("Gold Tier", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: primaryTeal)),
                        const Text("Strategic Insights & Markets", style: TextStyle(fontSize: 10, color: textMuted)),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          height: 32,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: borderTeal),
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            onPressed: widget.onManagePlanTap,
                            child: const Text("Manage Plan", style: TextStyle(fontSize: 11, color: textDark, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, AppRoutes.membershipsAndPlans);
                            },
                            child: const Text(
                              "View all Plans",
                              style: TextStyle(
                                fontSize: 11,
                                color: primaryTeal,
                                fontWeight: FontWeight.bold,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16),

            // 3. Financial Suite
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderTeal),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Financial Suite", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: primaryTeal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text("AVAILABLE BALANCE", style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.bold)),
                            Icon(Icons.account_balance_wallet_outlined, color: Colors.white70, size: 24),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text("₹ ${_walletBalance.toStringAsFixed(2)}", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primaryTeal),
                                onPressed: _showWithdrawalModal,
                                child: const Text("Withdraw", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                style: OutlinedButton.styleFrom(side: BorderSide(color: Colors.white.withOpacity(0.3)), foregroundColor: Colors.white),
                                onPressed: () {},
                                child: const Text("History", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Bank Account", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: primaryTeal,
                          minimumSize: const Size(0, 0),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        icon: const Icon(Icons.add, size: 14),
                        label: const Text("Add", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: widget.onBankAddTap,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: bgLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: borderTeal),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 32,
                          decoration: BoxDecoration(color: borderTeal.withOpacity(0.3), borderRadius: BorderRadius.circular(6)),
                          child: const Icon(Icons.account_balance, color: textMuted),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_bankName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                              Text(_bankAccMasked, style: const TextStyle(fontSize: 11, color: textMuted)),
                            ],
                          ),
                        ),
                        const Icon(Icons.lock_outline, size: 14, color: accentTeal),
                      ],
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Address Section
            Container(
              decoration: BoxDecoration(
                color: surfaceWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: borderTeal),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Professional Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                      TextButton.icon(
                        style: TextButton.styleFrom(foregroundColor: primaryTeal),
                        icon: const Icon(Icons.add_location, size: 14),
                        label: const Text("Update", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        onPressed: widget.onAddressUpdateTap,
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: const DecorationImage(
                            image: NetworkImage("https://lh3.googleusercontent.com/aida-public/AB6AXuBwQ8kE9DeabmqvkFI0IW8-6iXTkP3P4lmjXn0ZjFyrFKXwiKZP4Hf8IUJ1B3FV_O9IvbdplqkMOFPV_yGiYq0gaVYMqcr_6lzqf6BI_5nET89EHJWU2N8vHxs_Ie4NZeSmWJCYc5hjC-vSUnFxGUVCGAuAal42tLVv7YkkCZhRyOBXKnjOHmJbLKc1RvYxKmfwi-8JgIx2VffQoXe-hvYuHaHGBuIOjvlKtW6xdq3jrx2y0YdfhLOL"),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _city.isNotEmpty ? _city : "Stratosphere Tower, Suite 402",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark),
                            ),
                            const SizedBox(height: 2),
                            if (_state.isNotEmpty) ...[
                              Text(_state, style: const TextStyle(fontSize: 12, color: textMuted)),
                              const SizedBox(height: 2),
                            ] else ...[
                              const Text("242 Madison Avenue", style: TextStyle(fontSize: 12, color: textMuted)),
                              const SizedBox(height: 2),
                              const Text("New York, NY 10016", style: TextStyle(fontSize: 12, color: textMuted)),
                              const SizedBox(height: 2),
                            ],
                            Text(
                              _country.isNotEmpty ? _country : "United States",
                              style: const TextStyle(fontSize: 12, color: textMuted),
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 5. Sign Out Box
            Container(
              decoration: BoxDecoration(
                color: const Color(0xfffef2f2),
                border: Border.all(color: const Color(0xfffee2e2)),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text("Sign Out of Session", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textDark)),
                        SizedBox(height: 2),
                        Text("Terminate your current administrative access.", style: TextStyle(fontSize: 11, color: textMuted)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: errorColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      minimumSize: const Size(0, 40),
                    ),
                    icon: const Icon(Icons.logout, size: 16),
                    label: const Text("Logout", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    onPressed: _handleLogout,
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}