import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:go_router/go_router.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../database/app_database.dart';
import '../../providers/database_provider.dart';
import '../../providers/payments_provider.dart';

class PaymentFormScreen extends ConsumerStatefulWidget {
  final int? memberId;
  final int? paymentId;
  const PaymentFormScreen({super.key, this.memberId, this.paymentId});
  @override
  ConsumerState<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _description = TextEditingController();
  final _receipt = TextEditingController();
  final _dueDate = TextEditingController();
  int? _memberId;
  bool _isPaid = false;
  List<Member> _members = [];

  @override
  void initState() {
    super.initState();
    _memberId = widget.memberId;
    _load();
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    _members = await db.membersDao.watchAll().first;
    if (widget.paymentId != null) {
      final ps = await db.paymentsDao.watchAll().first;
      final p = ps.firstWhere((x) => x.id == widget.paymentId);
      _amount.text = p.amount.toStringAsFixed(0);
      _description.text = p.description ?? '';
      _receipt.text = p.receiptNumber ?? '';
      _dueDate.text = p.dueDate;
      _memberId = p.memberId; _isPaid = p.isPaid;
    } else {
      final j = Jalali.now().addMonths(1);
      _dueDate.text = '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
    }
    setState(() {});
  }

  @override
  void dispose() {
    _amount.dispose(); _description.dispose(); _receipt.dispose(); _dueDate.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context,
        initialDate: DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2100));
    if (picked != null) {
      final j = picked.toJalali();
      setState(() => _dueDate.text =
          '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}');
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_memberId == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('انتخاب عضو الزامی است')));
      return;
    }
    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    final actions = ref.read(paymentActionsProvider);
    if (widget.paymentId == null) {
      await actions.add(PaymentsTableCompanion(
        memberId: Value(_memberId!),
        amount: Value(amount),
        dueDate: Value(_dueDate.text),
        description: Value(_description.text.trim().isEmpty ? null : _description.text.trim()),
        isPaid: Value(_isPaid),
        receiptNumber: Value(_receipt.text.trim().isEmpty ? null : _receipt.text.trim()),
        paymentDate: Value(_isPaid ? actions.toShamsiNow() : null),
      ));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ثبت پرداخت')),
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
          TextFormField(
            controller: _amount,
            decoration: const InputDecoration(labelText: 'مبلغ (تومان) *', suffixText: 'تومان'),
            keyboardType: TextInputType.number,
            validator: (v) => (double.tryParse(v ?? '') == null) ? 'مبلغ معتبر وارد کنید' : null,
          ),
          const SizedBox(height: 12),
          TextFormField(controller: _dueDate, readOnly: true,
            onTap: _pickDate,
            decoration: const InputDecoration(labelText: 'تاریخ سرسید (شمسی) *',
                suffixIcon: Icon(Icons.calendar_month))),
          const SizedBox(height: 12),
          TextFormField(controller: _description,
            decoration: const InputDecoration(labelText: 'توضیحات')),
          const SizedBox(height: 12),
          TextFormField(controller: _receipt,
            decoration: const InputDecoration(labelText: 'شماره رسید')),
          SwitchListTile(
            title: const Text('پرداخت شده است'),
            value: _isPaid, onChanged: (v) => setState(() => _isPaid = v)),
          const SizedBox(height: 8),
          FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save), label: const Text('ذخیره')),
        ]),
      ),
    );
  }
}
