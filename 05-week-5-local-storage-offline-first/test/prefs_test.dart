import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:week5_offline_notes/data/prefs.dart';
import 'package:week5_offline_notes/pages/settings_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PrefsRepository & DarkModeNotifier Unit Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'dark_mode': false,
        'last_opened_at': '2026-10-29T08:00:00.000Z',
      });
    });

    test('getDarkMode membaca nilai boolean awal dengan benar', () async {
      final repo = PrefsRepository();
      final isDark = await repo.getDarkMode();
      expect(isDark, isFalse);
    });

    test('setDarkMode menyimpan preferensi tema baru ke SharedPreferences', () async {
      final repo = PrefsRepository();
      await repo.setDarkMode(true);
      final isDark = await repo.getDarkMode();
      expect(isDark, isTrue);
    });

    test('recordAndGetPreviousOpened mengembalikan waktu sebelumnya dan mengupdate yang baru', () async {
      final repo = PrefsRepository();
      final previous = await repo.recordAndGetPreviousOpened();
      expect(previous, '2026-10-29T08:00:00.000Z');

      final latest = await repo.getLastOpened();
      expect(latest, isNotNull);
      expect(latest, isNot('2026-10-29T08:00:00.000Z'));
    });

    test('DarkModeNotifier mengubah state tema saat ditoggle', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final initial = await container.read(darkModeProvider.future);
      expect(initial, isFalse);

      await container.read(darkModeProvider.notifier).toggle();
      final toggled = container.read(darkModeProvider).requireValue;
      expect(toggled, isTrue);

      await container.read(darkModeProvider.notifier).toggle();
      final toggledBack = container.read(darkModeProvider).requireValue;
      expect(toggledBack, isFalse);
    });
  });
}
