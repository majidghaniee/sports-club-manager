import 'package:drift/drift.dart' hide isNull;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/app_database.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('در main با override مقداردهی شود (اختیاری)');
});

final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) => ThemeModeNotifier());

class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.system) {
    _load();
  }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('themeMode') ?? 'system';
    state = v == 'dark' ? ThemeMode.dark : (v == 'light' ? ThemeMode.light : ThemeMode.system);
  }
  Future<void> set(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeMode',
        mode == ThemeMode.dark ? 'dark' : (mode == ThemeMode.light ? 'light' : 'system'));
  }
}

/// تنظیمات باشگاه
final clubSettingsProvider =
    StateNotifierProvider<ClubSettingsNotifier, ClubSettings>((ref) => ClubSettingsNotifier());

class ClubSettings {
  final String clubName;
  final bool enableNotifications;
  ClubSettings({this.clubName = 'باشگاه ورزشی', this.enableNotifications = true});
}

class ClubSettingsNotifier extends StateNotifier<ClubSettings> {
  ClubSettingsNotifier() : super(ClubSettings()) { _load(); }
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = ClubSettings(
      clubName: prefs.getString('clubName') ?? 'باشگاه ورزشی',
      enableNotifications: prefs.getBool('enableNotifications') ?? true,
    );
  }
  Future<void> setClubName(String name) async {
    state = ClubSettings(clubName: name, enableNotifications: state.enableNotifications);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('clubName', name);
  }
  Future<void> setNotifications(bool v) async {
    state = ClubSettings(clubName: state.clubName, enableNotifications: v);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', v);
  }
}
