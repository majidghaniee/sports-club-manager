import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' hide isNull;
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import '../../database/app_database.dart';
import '../../providers/database_provider.dart';

const sports = ['فوتبال', 'ووشو', 'کشتی', 'بدنسازی', 'شنا', 'تکواندو', 'عمومی'];
const membershipTypes = ['عادی', 'ویژه', 'ماهانه', 'سالانه'];

class MemberFormScreen extends ConsumerStatefulWidget {
  final int? memberId;
  const MemberFormScreen({super.key, this.memberId});
  @override
  ConsumerState<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends ConsumerState<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name, _phone, _nationalId, _birthDate, _expiry;
  String _sport = 'عمومی';
  String _membershipType = 'عادی';
  String? _photoPath;
  bool _isActive = true;
  Member? _existing;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController();
    _phone = TextEditingController();
    _nationalId = TextEditingController();
    _birthDate = TextEditingController();
    _expiry = TextEditingController();
    _load();
  }

  Future<void> _load() async {
    if (widget.memberId == null) return;
    final m = await ref.read(databaseProvider).membersDao.getById(widget.memberId!);
    _existing = m;
    _name.text = m.name; _phone.text = m.phone ?? '';
    _nationalId.text = m.nationalId ?? '';
    _birthDate.text = m.birthDate ?? ''; _expiry.text = m.membershipExpiry ?? '';
    _photoPath = m.photoPath; _isActive = m.isActive;
    _sport = m.sport; _membershipType = m.membershipType;
    setState(() {});
  }

  @override
  void dispose() {
    _name.dispose(); _phone.dispose(); _nationalId.dispose();
    _birthDate.dispose(); _expiry.dispose();
    super.dispose();
  }

  Future<void> _pickDate(TextEditingController c) async {
    // انتخابگر شمسی ساده: انتخاب تاریخ میلادی و تبدیل
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1930),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      final j = picked.toJalali();
      final s = '${j.year}/${j.month.toString().padLeft(2, '0')}/${j.day.toString().padLeft(2, '0')}';
      setState(() => c.text = s);
    }
  }

  Future<void> _pickPhoto() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (x != null) setState(() => _photoPath = x.path);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final db = ref.read(databaseProvider);
    final companion = MembersTableCompanion(
      name: Value(_name.text.trim()),
      phone: Value(_phone.text.trim().isEmpty ? null : _phone.text.trim()),
      nationalId: Value(_nationalId.text.trim().isEmpty ? null : _nationalId.text.trim()),
      birthDate: Value(_birthDate.text.isEmpty ? null : _birthDate.text),
      sport: Value(_sport),
      membershipType: Value(_membershipType),
      membershipExpiry: Value(_expiry.text.isEmpty ? null : _expiry.text),
      photoPath: Value(_photoPath),
      isActive: Value(_isActive),
    );
    if (_existing == null) {
      await db.membersDao.insertMember(companion);
    } else {
      await db.membersDao.updateMember(_existing!.copyWith(companion));
    }
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_existing == null ? 'افزودن عضو' : 'ویرایش عضو')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 44,
                  backgroundImage: _photoPath != null ? NetworkImage(_photoPath!) : null,
                  child: _photoPath == null
                      ? const Icon(Icons.camera_alt, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(labelText: 'نام و نام خانوادگی *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'نام الزامی است' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _phone,
              decoration: const InputDecoration(labelText: 'تلفن همراه'),
              keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            TextFormField(controller: _nationalId,
              decoration: const InputDecoration(labelText: 'کد ملی'),
              keyboardType: TextInputType.number),
            const SizedBox(height: 12),
            TextFormField(controller: _birthDate, readOnly: true,
              onTap: () => _pickDate(_birthDate),
              decoration: const InputDecoration(labelText: 'تاریخ تولد (شمسی)',
                  suffixIcon: Icon(Icons.calendar_month))),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _sport,
              decoration: const InputDecoration(labelText: 'رشته ورزشی'),
              items: sports.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _sport = v ?? _sport),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _membershipType,
              decoration: const InputDecoration(labelText: 'نوع عضویت'),
              items: membershipTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (v) => setState(() => _membershipType = v ?? _membershipType),
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _expiry, readOnly: true,
              onTap: () => _pickDate(_expiry),
              decoration: const InputDecoration(labelText: 'انقضای عضویت (شمسی)',
                  suffixIcon: Icon(Icons.calendar_month))),
            SwitchListTile(
              title: const Text('عضو فعال است'),
              value: _isActive, onChanged: (v) => setState(() => _isActive = v),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save), label: const Text('ذخیره')),
          ],
        ),
      ),
    );
  }
}
