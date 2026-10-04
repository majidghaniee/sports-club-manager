import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../screens/shell/app_shell.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/members/members_screen.dart';
import '../screens/members/member_form_screen.dart';
import '../screens/members/member_detail_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/attendance/qr_scan_screen.dart';
import '../screens/payments/payments_screen.dart';
import '../screens/payments/payment_form_screen.dart';
import '../screens/insurance/insurance_screen.dart';
import '../screens/insurance/insurance_form_screen.dart';
import '../screens/reports/reports_screen.dart';
import '../screens/settings/settings_screen.dart';

final _rootKey = GlobalKey<NavigatorState>();
final _shellKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootKey,
    initialLocation: '/dashboard',
    routes: [
      ShellRoute(
        navigatorKey: _shellKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', name: 'dashboard',
              builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/members', name: 'members',
              builder: (_, __) => const MembersScreen()),
          GoRoute(path: '/attendance', name: 'attendance',
              builder: (_, __) => const AttendanceScreen()),
          GoRoute(path: '/payments', name: 'payments',
              builder: (_, __) => const PaymentsScreen()),
          GoRoute(path: '/insurance', name: 'insurance',
              builder: (_, __) => const InsuranceScreen()),
          GoRoute(path: '/reports', name: 'reports',
              builder: (_, __) => const ReportsScreen()),
        ],
      ),
      GoRoute(path: '/members/add', name: 'member-add',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const MemberFormScreen()),
      GoRoute(path: '/members/:id/edit', name: 'member-edit',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => MemberFormScreen(memberId: int.parse(s.pathParameters['id']!))),
      GoRoute(path: '/members/:id', name: 'member-detail',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => MemberDetailScreen(memberId: int.parse(s.pathParameters['id']!))),
      GoRoute(path: '/attendance/scan', name: 'qr-scan',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const QrScanScreen()),
      GoRoute(path: '/payments/add', name: 'payment-add',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => PaymentFormScreen(
              memberId: s.uri.queryParameters['memberId'] != null
                  ? int.tryParse(s.uri.queryParameters['memberId']!) : null)),
      GoRoute(path: '/payments/:id/edit', name: 'payment-edit',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => PaymentFormScreen(paymentId: int.parse(s.pathParameters['id']!))),
      GoRoute(path: '/insurance/add', name: 'insurance-add',
          parentNavigatorKey: _rootKey,
          builder: (_, s) => InsuranceFormScreen(
              memberId: s.uri.queryParameters['memberId'] != null
                  ? int.tryParse(s.uri.queryParameters['memberId']!) : null)),
      GoRoute(path: '/settings', name: 'settings',
          parentNavigatorKey: _rootKey,
          builder: (_, __) => const SettingsScreen()),
    ],
  );
});
