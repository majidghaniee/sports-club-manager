import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AppShell extends ConsumerWidget {
  final Widget child;
  const AppShell({super.key, required this.child});

  static const _tabs = [
    ('/dashboard', 'داشبورد', Icons.dashboard_outlined),
    ('/members', 'اعضا', Icons.groups_outlined),
    ('/attendance', 'حضورغیاب', Icons.fact_check_outlined),
    ('/payments', 'مالی', Icons.payments_outlined),
    ('/insurance', 'بیمه', Icons.health_and_safety_outlined),
    ('/reports', 'گزارشات', Icons.assessment_outlined),
  ];

  int _index(String loc) {
    final i = _tabs.indexWhere((t) => loc.startsWith(t.$1));
    return i < 0 ? 0 : i;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = GoRouterState.of(context).uri.toString();
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index(loc),
        onDestinationSelected: (i) => context.go(_tabs[i].$1),
        destinations: [
          for (final t in _tabs)
            NavigationDestination(icon: Icon(t.$3), selectedIcon: Icon(t.$3, filled: true), label: t.$2),
        ],
      ),
    );
  }
}
