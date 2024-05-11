import 'package:admin_dashboards/pages/drivers_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_admin_scaffold/admin_scaffold.dart';
import '../pages/dashboard_page.dart';
import '../pages/trips_page.dart';
import '../pages/users_page.dart';

class SideNavigationDrawer extends StatefulWidget {
  const SideNavigationDrawer({super.key});

  @override
  State<SideNavigationDrawer> createState() => _SideNavigationDrawerState();
}

class _SideNavigationDrawerState extends State<SideNavigationDrawer> {
  static const String logoutRoute = '/logout'; // New logout route

  Widget chosenScreen = const DashboardPage();
  String currentRoute = DashboardPage.id;  // Default route

  // Method to confirm logging out
  void showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without doing anything
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                logOutUser(context);
              },
              child: const Text('Yes, Log Out'),
            ),
          ],
        );
      },
    );
  }

  // Perform the logout action
  void logOutUser(BuildContext context) {
    // Perform a mounted check before using the context
    if (!mounted) return;

    // Proceed with logging out
    print('User logged out. Clearing session data...');

    // Safe to use context here because we checked if the widget is still mounted
    Navigator.of(context).pop();  // Close the dialog
    Navigator.of(context).pushReplacementNamed('/login');  // Navigate to login page
  }

  void sendAdminTo(AdminMenuItem selectedPage) {
    if (!mounted) return;  // Check if the widget is still mounted

    setState(() {
      currentRoute = selectedPage.route!;  // Update the current route
      switch (selectedPage.route) {
        case DashboardPage.id:
          setState(() {
            chosenScreen = const DashboardPage();
          });
          break;
        case UsersPage.id:
          setState(() {
            chosenScreen = const UsersPage();
          });
          break;
        case DriversPage.id:
          setState(() {
            chosenScreen = const DriversPage();
          });
          break;
        case TripsPage.id:
          setState(() {
            chosenScreen = const TripsPage();
          });
          break;
        case logoutRoute:
          showLogoutConfirmationDialog(context);  // Show logout confirmation dialog
          break;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return AdminScaffold(
      backgroundColor: const Color.fromRGBO(255, 255, 255, 1),
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade700,
        title: const Text(
          "Admin Web Panel",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
      sideBar: SideBar(
        backgroundColor: Colors.white,  // Default background
        activeBackgroundColor: Colors.white,
        items: const [
          AdminMenuItem(
            title: "Dashboard",
            route: DashboardPage.id,
            icon: CupertinoIcons.chart_bar_fill,

          ),
          AdminMenuItem(
            title: "Users",
            route: UsersPage.id,
            icon: CupertinoIcons.person_2_fill,
          ),
          AdminMenuItem(
            title: "Drivers",
            route: DriversPage.id,
            icon: CupertinoIcons.person_3_fill,
          ),
          AdminMenuItem(
            title: "Trips",
            route: TripsPage.id,
            icon: CupertinoIcons.location_fill,
          ),
          AdminMenuItem(
            title: "Log Out",
            route: logoutRoute,
            icon: Icons.logout,
          ),
        ],
        selectedRoute: currentRoute, // Dynamically set selected route
        onSelected: sendAdminTo,
        header: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.accessibility,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.settings,
                color: Colors.white,
              ),
            ],
          ),
        ),
        footer: Container(
          height: 52,
          width: double.infinity,
          color: Colors.blue.shade500,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.admin_panel_settings_outlined,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Icon(
                Icons.computer,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ),
      body: chosenScreen,
    );
  }
}
