import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/app_database.dart';
import 'database_provider.dart';

final membersProvider = StreamProvider.family<List<Member>, MembersFilter>((ref, f) {
  final dao = ref.watch(databaseProvider).membersDao;
  return dao.watchAll(search: f.search, sport: f.sport, activeOnly: f.activeOnly);
});

class MembersFilter {
  final String? search;
  final String? sport;
  final bool? activeOnly;
  const MembersFilter({this.search, this.sport, this.activeOnly});
  MembersFilter copyWith({String? search, String? sport, bool? activeOnly}) =>
      MembersFilter(search: search ?? this.search, sport: sport ?? this.sport,
          activeOnly: activeOnly ?? this.activeOnly);
}

final memberByIdProvider = StreamProvider.family<Member, int>((ref, id) =>
    ref.watch(databaseProvider).membersDao.watchById(id));

final totalMembersProvider = StreamProvider<int>(
    (ref) => ref.watch(databaseProvider).membersDao.watchTotalCount());
