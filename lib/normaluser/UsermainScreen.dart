import 'package:flutter/material.dart';
import 'package:trading_ecommerce_admin/normaluser/userProfile.dart';
import 'package:trading_ecommerce_admin/normaluser/user_myactivity.dart';

import '../admin/feed_Screen.dart';
import '../admin/my_Activity.dart';
import 'Dashbord_Screen.dart';
import 'Drawer.dart';
import 'Explore_Marketplace.dart';
import 'Wallet.dart';

class ActivityScreen extends StatelessWidget {
  final VoidCallback onMenuPressed;
  const ActivityScreen({super.key, required this.onMenuPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.white),
          onPressed: onMenuPressed,
        ),
      ),
      body: const Center(
        child: Text(
          'Activity Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

// class SettingsScreena extends StatelessWidget {
//   final VoidCallback onMenuPressed;
//   const SettingsScreena({super.key, required this.onMenuPressed});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Settings'),
//         backgroundColor: Colors.orange,
//         leading: IconButton(
//           icon: const Icon(Icons.menu_rounded, color: Colors.white),
//           onPressed: onMenuPressed,
//         ),
//       ),
//       body: const Center(
//         child: Text(
//           'Settings Screen',
//           style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//         ),
//       ),
//     );
//   }
// }

class DetailsScreen extends StatelessWidget {
  const DetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Details Screen"),
        backgroundColor: Colors.red,
      ),
      body: const Center(
        child: Text(
          "Welcome to the Details Screen!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}

/// ══════════════════════════════════════════════════════════
/// The ONE Scaffold for the whole bottom-nav flow.
/// It owns the drawer. Every tab below is now just a *body* —
/// no more nested Scaffold/AppBar per tab — so the drawer is
/// truly shared across Home / Activity / Profile / Settings.
/// ══════════════════════════════════════════════════════════
class UserMainScreen extends StatefulWidget {
  const UserMainScreen({super.key});

  @override
  State<UserMainScreen> createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  /// Lets the drawer jump straight to a bottom-nav tab
  /// (e.g. "Home Feed", "My Activities", "Profile", "Settings")
  /// and close itself.
  void _goToTab(int index) {
    Navigator.pop(context); // close drawer
    setState(() => _selectedIndex = index);
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    // Bodies only — each screen no longer wraps itself in a Scaffold.
    final List<Widget> screens = [
      userDashboardscreen(onMenuPressed: _openDrawer),
      userMyActivity(onMenuPressed: _openDrawer,),
      ExploreMarketplaceUser(onMenuPressed: _openDrawer),
      MemberProfileScreen(onMenuPressed: _openDrawer),
      FinancialOverviewScreen(onMenuPressed: _openDrawer),
    ];

    return Scaffold(
      key: _scaffoldKey,
      drawer: CustomCommonDrawer(
        selectedIndex: _selectedIndex,
        onGoToTab: _goToTab,
      ),
      body: screens[_selectedIndex],
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Colors.blue.withOpacity(0.2),
          labelTextStyle: WidgetStateProperty.all(
            const TextStyle(fontSize: 12),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined),
              selectedIcon: Icon(Icons.analytics),
              label: 'Activity',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_sharp),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'Shop',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
            NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet),
              label: 'Wallet',
            ),
          ],
        ),
      ),
    );
  }
}