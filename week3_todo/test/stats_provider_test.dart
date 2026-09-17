import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week3_todo/providers/stats_provider.dart';

void main() {
  test(
    'notifier mengembalikan tiga statistik saat pengambilan berhasil',
    () async {
      // ProviderContainer menjalankan notifier tanpa perlu membangun widget.
      final container = ProviderContainer(
        overrides: [
          statsProvider.overrideWith(
            () => StatsNotifier(nextRandom: () => 0.9, delay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      // future menunggu sampai AsyncNotifier selesai memproses build().
      final stats = await container.read(statsProvider.future);

      expect(stats, hasLength(3));
      expect(stats.first, 'Pengguna aktif: 1.248');
    },
  );

  test('notifier menghasilkan error ketika simulasi jaringan gagal', () async {
    // Nilai di bawah 0.3 memaksa cabang kegagalan 30 persen.
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(nextRandom: () => 0.2, delay: Duration.zero),
        ),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen(
      statsProvider,
      (previous, next) {},
      fireImmediately: true,
    );
    addTearDown(subscription.close);

    // Satu giliran event loop memberi waktu bagi build() untuk mengubah state.
    await Future<void>.delayed(Duration.zero);
    final state = container.read(statsProvider);

    expect(state.hasError, isTrue);
    expect(state.error, isA<Exception>());
  });
}
