import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/insurance_provider.dart';

class InsuranceFormScreen extends ConsumerStatefulWidget {
  final int? memberId;
  const InsuranceFormScreen({super.key, this.memberId});
  @override
  ConsumerState<InsuranceFormScreen> createState() => _InsuranceFormScreenState();
}

class _InsuranceFormScreenState extends ConsumerState<InsuranceFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _provider = TextEditingController();
  final _amount = TextEditingController();
  final _start = TextEditingController();
  final _end = TextEditingController();
  int? _memberId;
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _memberId = widget.memberId;
    _load();
  }

  Future<void> _load() async {
    _members = await ref.read(databaseProvider).membersDao.watchAll().first;
    final j = Jalali.now();
    _start.text = '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    final e = j.addYears(1);
    _end.text = '${e.year}/${e.month.toString().padLeft(2, '0')}/${e.day.toString().padLeft(2, '0')}';
    setState(() {});
  }

  @override
  void dispose() {
    _number.dispose(); _provider.dispose(); _amount.dispose(); _start.dispose(); _end.dispose();
    super.dispose();
  }

  Future<void> _pick(TextEditingController c) async {
    final picked = await showDatePicker(context: context,
        initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) {
      final j = picked.toJalali();
      setState(() => c.text =
          '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await ref.read(insuranceActionsProvider).add(InsurancesTableCompanion(
      memberId: Value(_memberId!),
      insuranceNumber: Value(_number.text.trim()),
      provider: Value(_provider.text.trim()),
      startDate: Value(_start.text),
      endDate: Value(_end.text),
      amount: Value(double.tryParse(_amount.text) ?? 0),
    ));
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت بیمه')),
      body: Form(
        key: _formKey,
        child: ListView(padding: const EdgeInsets.all(16), children: [
          DropdownButtonFormField<int>(
            value: _memberId,
            decoration: const InputDecoration(labelText: 'عضو *'),
            items: _members.map((m) => DropdownMenuItem(value: m.id, child: Text(m.name))).toList(),
            onChanged: (v) => setState(() => _memberId = v),
            validator: (v) => v == null ? 'انتخاب عضو الزامی است' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _number,
            decoration: const InputDecoration(labelText: 'شماره بیمه *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الزامی است' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _provider,
            decoration: const InputDecoration(labelText: 'شرکت بیمهگر *'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الزامی است' : null),
          const SizedBox(height: 12),
          TextFormField(controller: _start, readOnly: true, onTap: () => _pick(_start),
            decoration: const InputDecoration(labelText: 'تاریخ شروع (شمسی)',
                suffixIcon: Icon(Icons.calendar_month))),
          const SizedBox(height: 12),
          TextFormField(controller: _end, readOnly: true, onTap: () => _pick(_end),
            decoration: const InputDecoration(labelText: 'تاریخ پایان (شمسی)',
                suffixIcon: Icon(Icons.calendar_month))),
          const SizedBox(height: 12),
          TextFormField(controller: _amount, keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'مبلغ (تومان)')),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('ذخیره')),
        ]),
      ),
    );
  }
}
