import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsNotifier extends AsyncNotifier<List<String>> {
  StatsNotifier({double Function()? nextRandom, Duration? delay})
    : _nextRandom = nextRandom ?? Random().nextDouble,
      _delay = delay ?? const Duration(seconds: 2);

  final double Function() _nextRandom;
  final Duration _delay;

  @override
  Future<List<String>> build() async {
    await Future<void>.delayed(_delay);

    if (_nextRandom() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    return const [
      'Pengguna aktif: 1.248',
      'Pesanan bulan ini: 86',
      'Pendapatan: Rp12,4 jt',
    ];
  }
}

final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);
