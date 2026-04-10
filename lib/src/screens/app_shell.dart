import 'package:flutter/material.dart';

import '../data/studyflow_store.dart';
import 'calendar_screen.dart';
import 'dashboard_screen.dart';
import 'feature_screens.dart';
import 'focus_screen.dart';
import 'tasks_screen.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    final store = StudyFlowScope.of(context);
    final pages = const [
      DashboardScreen(),
      CalendarScreen(),
      TasksScreen(),
      FocusScreen(),
      MoreScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: store.selectedTab, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: store.selectedTab,
        onDestinationSelected: store.selectTab,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Tổng quan',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Lịch',
          ),
          NavigationDestination(
            icon: Icon(Icons.assignment_outlined),
            selectedIcon: Icon(Icons.assignment_turned_in_rounded),
            label: 'Deadline',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Focus',
          ),
          NavigationDestination(
            icon: Icon(Icons.grid_view_rounded),
            selectedIcon: Icon(Icons.dashboard_customize_rounded),
            label: 'Thêm',
          ),
        ],
      ),
    );
  }
}
