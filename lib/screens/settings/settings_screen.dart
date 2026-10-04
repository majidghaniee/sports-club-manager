import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _clubName;

  @override
  void initState() {
    super.initState();
    _clubName = TextEditingController(text: ref.read(clubSettingsProvider).clubName);
  }

  @override
  void dispose() { _clubName.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(clubSettingsProvider);
    final themeMode = ref.watch(themeModeProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('تنظیمات')),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        TextFormField(
          controller: _clubName,
          decoration: const InputDecoration(labelText: 'نام باشگاه',
              suffixIcon: Icon(Icons.storefront)),
          onFieldSubmitted: (v) => ref.read(clubSettingsProvider.notifier).setClubName(v),
        ),
        const SizedBox(height: 8),
        TextButton.icon(
          onPressed: () => ref.read(clubSettingsProvider.notifier).setClubName(_clubName.text),
          icon: const Icon(Icons.save), label: const Text('ذخیره نام باشگاه')),
        const Divider(height: 32),
        ListTile(
          leading: const Icon(Icons.camera_alt_outlined),
          title: const Text('لوگوی باشگاه'),
          subtitle: const Text('انتخاب از گالری'),
          onTap: () async {
            final x = await ImagePicker().pickImage(source: ImageSource.gallery);
            // در نسخه بعد می‌توان مسیر لوگو را در SharedPreferences ذخیره و نمایش داد
            if (x != null && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لوگو انتخاب شد')));
            }
          },
        ),
        const Divider(height: 32),
        const Padding(padding: EdgeInsets.all(8), child: Text('ظاهر برنامه')),
        RadioListTile<ThemeMode>(
          title: const Text('روشن'), value: ThemeMode.light,
          groupValue: themeMode,
          onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!)),
        RadioListTile<ThemeMode>(
          title: const Text('تاریک'), value: ThemeMode.dark,
          groupValue: themeMode,
          onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!)),
        RadioListTile<ThemeMode>(
          title: const Text('سیستم'), value: ThemeMode.system,
          groupValue: themeMode,
          onChanged: (v) => ref.read(themeModeProvider.notifier).set(v!)),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('اعلان‌ها (یادآوری سرسید و بیمه)'),
          value: settings.enableNotifications,
          onChanged: (v) => ref.read(clubSettingsProvider.notifier).setNotifications(v)),
      ]),
    );
  }
}
