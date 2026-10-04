import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/members_provider.dart';
import '../../widgets/member_card.dart';

const sportTypes = ['همه', 'فوتبال', 'ووشو', 'کشتی', 'بدنسازی', 'شنا', 'تکواندو', 'عمومی'];

class MembersScreen extends ConsumerStatefulWidget {
  const MembersScreen({super.key});
  @override
  ConsumerState<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends ConsumerState<MembersScreen> {
  String? _search;
  String _sport = 'همه';
  bool? _activeOnly;

  @override
  Widget build(BuildContext context) {
    final members = ref.watch(membersProvider(MembersFilter(search: _search, sport: _sport, activeOnly: _activeOnly)));
    return Scaffold(
      appBar: AppBar(title: const Text('اعضای باشگاه')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/members/add'),
        icon: const Icon(Icons.add), label: const Text('عضو جدید'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: TextField(
              onChanged: (v) => setState(() => _search = v),
              decoration: const InputDecoration(
                hintText: 'جستجو بر اساس نام...', prefixIcon: Icon(Icons.search)),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                FilterChip(
                  selected: _activeOnly == true,
                  label: const Text('فقط فعال'),
                  onSelected: (v) => setState(() => _activeOnly = v ? true : null),
                ),
                const SizedBox(width: 6),
                ...sportTypes.map((s) => Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(s),
                    selected: _sport == s,
                    onSelected: (_) => setState(() => _sport = s),
                  ),
                )),
              ],
            ),
          ),
          Expanded(
            child: members.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('خطا: $e')),
              data: (list) => list.isEmpty
                  ? const Center(child: Text('عضوی یافت نشد'))
                  : ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (_, i) => MemberCard(
                        member: list[i],
                        onTap: () => context.push('/members/${list[i].id}'),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
