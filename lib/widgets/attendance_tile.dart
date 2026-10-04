import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart' as intl;
import '../database/app_database.dart';
import '../providers/attendance_provider.dart';
import '../providers/members_provider.dart';

class AttendanceTile extends ConsumerWidget {
  final Attendance attendance;
  final int? memberId;
  const AttendanceTile({super.key, required this.attendance, this.memberId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final open = attendance.checkOut == null;
    final inT = intl.DateFormat('HH:mm').format(attendance.checkIn);
    final outT = attendance.checkOut != null ? intl.DateFormat('HH:mm').format(attendance.checkOut!) : '—';
    return Card(
      child: ListTile(
        leading: Icon(open ? Icons.login : Icons.logout, color: open ? cs.primary : cs.outline),
        title: _MemberName(id: memberId ?? attendance.memberId),
        subtitle: Text('${attendance.date} • ورود $inT | خروج $outT'),
        trailing: open
            ? FilledButton.tonal(
                onPressed: () => ref.read(attendanceActionsProvider).checkOut(attendance),
                child: const Text('ثبت خروج'))
            : const Icon(Icons.check_circle_outline),
      ),
    );
  }
}

class _MemberName extends ConsumerWidget {
  final int id;
  const _MemberName({required this.id});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final m = ref.watch(memberByIdProvider(id)).valueOrNull;
    return Text(m?.name ?? 'عضو #$id');
  }
}
