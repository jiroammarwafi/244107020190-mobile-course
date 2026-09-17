import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Notifier ini menyimpan daftar statistik dan status async proses pemuatannya.
class StatsNotifier extends AsyncNotifier<List<String>> {
  // Dependency ini dibuat dapat diinjeksi agar unit test tidak bergantung pada
  // angka acak dan tidak perlu menunggu delay dua detik.
  StatsNotifier({double Function()? nextRandom, Duration? delay})
    : _nextRandom = nextRandom ?? Random().nextDouble,
      _delay = delay ?? const Duration(seconds: 2);

  final double Function() _nextRandom;
  final Duration _delay;

  // build() dipanggil Riverpod saat provider pertama kali digunakan.
  @override
  Future<List<String>> build() async {
    // Delay ini mensimulasikan waktu yang dibutuhkan untuk meminta data ke API.
    await Future<void>.delayed(_delay);

    // Simulasi kegagalan jaringan dengan kemungkinan sebesar 30 persen.
    if (_nextRandom() < 0.3) {
      throw Exception('Gagal mengambil data statistik');
    }

    // Data inilah yang ditampilkan oleh StatsPage ketika statusnya berhasil.
    return const [
      'Pengguna aktif: 1.248',
      'Pesanan bulan ini: 86',
      'Pendapatan: Rp12,4 jt',
    ];
  }
}

// Satu-satunya provider yang dipakai StatsPage untuk membaca data statistik.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);
