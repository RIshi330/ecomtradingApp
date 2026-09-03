import 'package:flutter/material.dart';

// TODO: adjust these imports to match your actual project structure

import '../normaluser/UsermainScreen.dart';
import '../services/auth_User_and_Business_Session.dart';
import 'community Dashboard.dart';
import 'seller_dashboard.dart';
class VendorAccount {
  final int vendorId;
  final String vendorType;
  final String role;
  final String name;
  final String email;

  VendorAccount({
    required this.vendorId,
    required this.vendorType,
    required this.role,
    required this.name,
    required this.email,
  });

  factory VendorAccount.fromJson(Map<String, dynamic> json) {
    return VendorAccount(
      vendorId: int.tryParse(json['vendor_id']?.toString() ?? '0') ?? 0,
      vendorType: json['vendor_type']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}
/// Static display metadata for known vendor_type values.
/// Add new entries here whenever a new business role/vendor_type is introduced.
class _RoleDisplay {
  final String title;
  final String description;
  final IconData icon;

  const _RoleDisplay({
    required this.title,
    required this.description,
    required this.icon,
  });
}

const Map<String, _RoleDisplay> _roleDisplayMap = {
  '500': _RoleDisplay(
    title: 'Normal User',
    description: 'Browse and use the app as a regular user.',
    icon: Icons.person_outline,
  ),
  '5': _RoleDisplay(
    title: 'Seller',
    description: 'Manage your store, products, and orders.',
    icon: Icons.storefront_outlined,
  ),
  '200': _RoleDisplay(
    title: 'Community Admin',
    description: 'Moderate discussions and manage community.',
    icon: Icons.forum_outlined,
  ),
};

_RoleDisplay _displayFor(VendorAccount account) {
  return _roleDisplayMap[account.vendorType] ??
      _RoleDisplay(
        title: account.role.isNotEmpty ? account.role : 'Account',
        description: 'Continue with this account.',
        icon: Icons.account_circle_outlined,
      );
}

class BusinessRoleSelectionScreen extends StatefulWidget {
  final List<VendorAccount> accounts;
  final String sessionId;

  const BusinessRoleSelectionScreen({
    super.key,
    required this.accounts,
    required this.sessionId,
  });

  @override
  State<BusinessRoleSelectionScreen> createState() =>
      _BusinessRoleSelectionScreenState();
}

class _BusinessRoleSelectionScreenState
    extends State<BusinessRoleSelectionScreen> {
  late VendorAccount _selectedAccount;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.accounts.first;
  }

  Future<void> _confirmAndRedirect() async {
    setState(() => _isSubmitting = true);

    try {
      await UserSessionSet.instance.saveLoginData(
        sessionId: widget.sessionId,
        vendorId: _selectedAccount.vendorId.toString(),
        vendorType: _selectedAccount.vendorType,
      );

      if (!mounted) return;

      switch (_selectedAccount.vendorType) {
        case '500':
          print("500");
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const UserMainScreen()),
                (route) => false,
          );
          break;
        case '200':
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => const CommunityDashboardScreen(),
            ),
                (route) => false,
          );
          break;
        case '5':
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const SellerDashboard()),
                (route) => false,
          );
          break;
        default:
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No dashboard configured for role "${_selectedAccount.role}".',
              ),
              backgroundColor: Colors.red,
            ),
          );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFF006565);
    const primaryContainer = Color(0xFF008080);
    const outlineVariant = Color(0xFFBDC9C8);
    const borderSubtle = Color(0xFFE2E8F0);
    const surfaceContainerLowest = Color(0xFFFFFFFF);
    const surfaceContainerLow = Color(0xFFF1F4F6);
    const surfaceContainerHigh = Color(0xFFE5E9EB);
    const tealLight = Color(0xFFE6F2F2);
    const onSurface = Color(0xFF181C1E);
    const onSurfaceVariant = Color(0xFF3E4949);
    const secondaryColor = Color(0xFF555F71);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(color: onSurface.withOpacity(0.40)),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Container(
                constraints: const BoxConstraints(maxWidth: 448),
                decoration: BoxDecoration(
                  color: surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderSubtle),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4A5568).withOpacity(0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Header
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      decoration: const BoxDecoration(
                        color: surfaceContainerLow,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(15),
                        ),
                        border: Border(bottom: BorderSide(color: borderSubtle)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select Role',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w600,
                              color: onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This account has multiple roles. Choose one to continue.',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Accounts list (built from real API data)
                    Flexible(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: widget.accounts.map((account) {
                            final display = _displayFor(account);
                            final isSelected =
                                _selectedAccount.vendorType ==
                                    account.vendorType &&
                                    _selectedAccount.vendorId ==
                                        account.vendorId;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: InkWell(
                                onTap: () {
                                  setState(() => _selectedAccount = account);
                                },
                                borderRadius: BorderRadius.circular(12),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? tealLight.withOpacity(0.3)
                                        : surfaceContainerLowest,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isSelected
                                          ? primaryContainer
                                          : outlineVariant,
                                      width: isSelected ? 2.0 : 1.0,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: isSelected
                                              ? primaryContainer
                                              : surfaceContainerHigh,
                                        ),
                                        child: Icon(
                                          display.icon,
                                          size: 22,
                                          color: isSelected
                                              ? Colors.white
                                              : secondaryColor,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              display.title,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.w600,
                                                color: isSelected
                                                    ? primaryContainer
                                                    : onSurface,
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              display.description,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: onSurfaceVariant,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      AnimatedContainer(
                                        duration:
                                        const Duration(milliseconds: 200),
                                        width: 20,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: isSelected
                                                ? primaryContainer
                                                : outlineVariant,
                                            width: 2,
                                          ),
                                          color: surfaceContainerLowest,
                                        ),
                                        child: isSelected
                                            ? Center(
                                          child: Container(
                                            width: 10,
                                            height: 10,
                                            decoration:
                                            const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: primaryContainer,
                                            ),
                                          ),
                                        )
                                            : null,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),

                    // Footer
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 20.0,
                      ),
                      decoration: const BoxDecoration(
                        color: surfaceContainerLowest,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.circular(15),
                        ),
                        border: Border(top: BorderSide(color: borderSubtle)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed:
                            _isSubmitting ? null : _confirmAndRedirect,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(160, 44),
                              backgroundColor: primaryColor,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isSubmitting
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                                : const Text('Confirm & Continue'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}