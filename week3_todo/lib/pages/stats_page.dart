import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

// ConsumerWidget memungkinkan halaman membaca perubahan state dari Riverpod.
class StatsPage extends ConsumerWidget {
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membuat UI dibangun ulang setiap kali status provider berubah.
    final statsAsync = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      // when memetakan tiga kemungkinan AsyncValue: loading, error, dan data.
      body: statsAsync.when(
        // Spinner ditampilkan selama proses pengambilan data berlangsung.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan tombol retry memberi pengguna jalan untuk mencoba lagi.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat: $error'),
              const SizedBox(height: 12),
              FilledButton(
                // invalidate membuang state lama dan memulai build() kembali.
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // ListView menampilkan tepat tiga data statistik dari notifier.
        data: (stats) => ListView.builder(
          itemCount: stats.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.analytics_outlined),
            title: Text(stats[index]),
          ),
        ),
      ),
    );
  }
}
