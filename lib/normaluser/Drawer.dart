import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/admin/my_Activity.dart';
import 'package:trading_ecommerce_admin/normaluser/referal.dart';

import '../admin/explore_communities_screen.dart';
import '../admin/membership_plans_screen.dart';
import '../admin/my-network.dart';
import '../admin/wallet_admin_screen.dart';
import '../common/logout.dart';
import '../common/offers_screen.dart';
import '../user/seller_bank_accounts_screen.dart';
import '../widgets/personalize_feed_dialog.dart';
import 'Explore_Marketplace.dart';
import 'Manage_Address.dart';
import 'Terms&condition.dart';
import 'TranningScreen.dart';

/// Shared drawer for the bottom-nav flow (Home / Activity / Profile / Settings).
/// Opened from any tab's hamburger icon via Scaffold.of / a GlobalKey on the
/// parent Scaffold in UserMainScreen.
///
/// - [selectedIndex] lets the drawer highlight which bottom-nav tab is active.
/// - [onGoToTab] is called for menu items that map onto an existing bottom
///   nav tab (Home Feed, My Activities, Profile, Settings) — it both
///   switches the tab AND closes the drawer.
/// - Items that don't have a bottom-nav tab yet (My Network, Explore
///   Communities, Explore Marketplaces, Payment & Billings sub-items, the
///   Settings sub-items) push a placeholder route — swap
///   `_PlaceholderScreen` for your real screens as you build them.
class CustomCommonDrawer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onGoToTab;

  const CustomCommonDrawer({
    super.key,
    required this.selectedIndex,
    required this.onGoToTab,
  });

  static const Color _tealDark = Color(0xFF0F6E6A);
  static const Color _tealLight = Color(0xFF14A098);

  // void _push(BuildContext context, String title) {
  //   Navigator.pop(context); // close drawer first
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (_) => _PlaceholderScreen(title: title)),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [_tealLight, _tealDark],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: _tealDark, size: 36),
            ),
            accountName: const Text(
              'Biswajit Sinha',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            accountEmail: const Text('biswajit@example.com'),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: 'Home Feed',
                  selected: selectedIndex == 0,
                  onTap: () => onGoToTab(0),
                ),
                _DrawerItem(
                  icon: Icons.groups_outlined,
                  label: 'My Network',
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const MyNetworkScreen()),
                    );
                  },
                ),

                _DrawerItem(
                  icon: Icons.diversity_3_outlined,
                  label: 'Explore Communities',
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExploreCommunitiesScreen()),
                    );
                  },
                ),
                //       _DrawerItem(
                //         icon: Icons.storefront_outlined,
                //         label: 'Explore Marketplaces',
                //
                //           onTap: () {
                // Navigator.pop(context); // close the drawer first
                // Navigator.push(
                // context,
                // MaterialPageRoute(builder: (_) => const ExploreMarketplaceuser()),
                // );
                // },
                //       ),
                _DrawerItem(
                  icon: Icons.bolt_outlined,
                  label: 'My Activities',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const MyActivity(isEmbedded: false,)),
                    );
                  },
                ),

                const Divider(height: 1),

                // Profile group
                ExpansionTile(
                  leading: const Icon(Icons.person_outline),
                  title: const Text('Profile'),
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    _DrawerItem(
                      icon: Icons.edit_outlined,
                      label: 'Edit Profile',
                      dense: true,
                      selected: selectedIndex == 2,
                      onTap: () => {},
                    ),
                  ],
                ),

                // Payment & Billings group
                ExpansionTile(
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Payment & Billings'),
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    _DrawerItem(
                      icon: Icons.card_membership_outlined,
                      label: 'Membership Plans',
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // close the drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => MembershipPlansScreen()),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Wallet',
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // close the drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WalletAdminScreen(isEmbedded:false,)),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.account_balance_outlined,
                      label: 'Bank Account',
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // close the drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => SellerBankAccountsScreen()),
                        );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.location_on_outlined,
                      label: 'My Addresses',
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // close the drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ManageAddressScreen()),
                        );
                      },
                    ),
                  ],
                ),

                // Settings group
                ExpansionTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Settings'),
                  childrenPadding: const EdgeInsets.only(left: 16),
                  children: [
                    _DrawerItem(
                      icon: Icons.favorite_border_rounded,
                      label: 'Interests',
                      dense: true,
                      onTap: () {
                        Navigator.pop(context); // close the drawer first
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (_) => PersonalizeFeedDialog()),
                        // );
                      },
                    ),
                    _DrawerItem(
                      icon: Icons.factory_outlined,
                      label: 'Industries',
                      dense: true,
                      onTap: () => {},
                    ),
                  ],
                ),
                _DrawerItem(
                  icon: Icons.info,
                  label: 'Offer',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const OffersScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.info,
                  label: 'Offer',
                  selected: selectedIndex == 2,
                  onTap: () {
                    final navigator = Navigator.of(context);
                    navigator.pop(); // close drawer
                    navigator.push(
                      MaterialPageRoute(builder: (_) => const TranningSection()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.earbuds,
                  label: 'Refer & Earn',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReferAndEarnScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.info,
                  label: 'Term & condition',
                  selected: selectedIndex == 1,
                  onTap: () {
                    Navigator.pop(context); // close the drawer first
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TermsAndConditionsScreen ()),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _DrawerItem(
            icon: Icons.logout_rounded,
            label: 'Logout',
            iconColor: Colors.redAccent,
            labelColor: Colors.redAccent,
            onTap: () {
              Navigator.pop(context);
              showLogoutConfirmationDialog(context)   ;

              // TODO: wire up your real logout logic (clear session, etc.)
              // then navigate to the login/root route, e.g.:
              // Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool dense;
  final Color? iconColor;
  final Color? labelColor;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.dense = false,
    this.iconColor,
    this.labelColor,
  });

  static const Color _tealDark = Color(0xFF0F6E6A);
  static const Color _selectedBg = Color(0xFFE3FFFC);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: dense,
      selected: selected,
      selectedTileColor: _selectedBg,
      leading: Icon(icon, color: selected ? _tealDark : iconColor),
      title: Text(
        label,
        style: TextStyle(
          color: selected ? _tealDark : labelColor,
          fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
        ),
      ),
      onTap: onTap,
    );
  }
}
