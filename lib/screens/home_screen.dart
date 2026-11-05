import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/app_provider.dart';
import 'report_screen.dart';
import 'incidents_list_screen.dart';
import 'staff_dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = context.watch<AppProvider>();
    final isStaff = appProvider.currentUser?.role == 'staff';

    final screens = [
      const IncidentsListScreen(),
      const ReportScreen(),
      if (isStaff) const StaffDashboardScreen(),
    ];

    final destinations = [
      const NavigationDestination(icon: Icon(Icons.list_outlined), label: 'Incidents'),
      const NavigationDestination(icon: Icon(Icons.add_circle_outline), label: 'Report'),
      if (isStaff)
        const NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
    ];

    // Ensure _selectedIndex doesn't exceed valid bounds
    final safeIndex = _selectedIndex < screens.length ? _selectedIndex : 0;

    return Scaffold(
      body: IndexedStack(
        index: safeIndex,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: safeIndex,
        onDestinationSelected: _onItemTapped,
        destinations: destinations,
      ),
    );
  }
}
