import 'package:flutter/material.dart';
import '../database/app_database.dart';
import '../providers/insurance_provider.dart';

class InsuranceTile extends StatelessWidget {
  final Insurance insurance;
  const InsuranceTile({super.key, required this.insurance});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final status = insuranceStatus(insurance.endDate);
    final Color color = switch (status) {
      InsuranceStatus.expired => cs.error,
      InsuranceStatus.expiringSoon => cs.secondary,
      InsuranceStatus.valid => cs.primary,
    };
    final String label = switch (status) {
      InsuranceStatus.expired => 'منقضی‌شده',
      InsuranceStatus.expiringSoon => 'به‌زودی منقضی می‌شود',
      InsuranceStatus.valid => 'معتبر',
    };
    return Card(
      child: ListTile(
        leading: Icon(Icons.health_and_safety, color: color),
        title: Text('بیمه ${insurance.provider} — ${insurance.insuranceNumber}'),
        subtitle: Text('از ${insurance.startDate} تا ${insurance.endDate} • عضو #${insurance.memberId}'),
        trailing: Chip(
          label: Text(label, style: TextStyle(fontSize: 11, color: Colors.white)),
          backgroundColor: color,
        ),
      ),
    );
  }
}
