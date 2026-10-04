import 'package:flutter/material.dart';
import '../database/app_database.dart';

class MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;
  const MemberCard({super.key, required this.member, this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundImage: member.photoPath != null ? NetworkImage(member.photoPath!) : null,
          backgroundColor: cs.primary.withOpacity(0.15),
          child: member.photoPath == null
              ? Text(member.name.isNotEmpty ? member.name[0] : '?')
              : null,
        ),
        title: Text(member.name),
        subtitle: Text('${member.sport} • ${member.membershipType}'),
        trailing: Chip(
          label: Text(member.isActive ? 'فعال' : 'غیرفعال', style: const TextStyle(fontSize: 11)),
          backgroundColor: member.isActive
              ? cs.primary.withOpacity(0.15)
              : cs.error.withOpacity(0.15),
        ),
      ),
    );
  }
}
