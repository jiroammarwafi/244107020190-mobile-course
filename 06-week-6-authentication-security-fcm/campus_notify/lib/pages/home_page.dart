import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../messaging/push_service.dart';
import '../providers/auth_provider.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final displayToken = currentFcmToken != null
        ? '${currentFcmToken!.substring(0, 15)}... (Aktif)'
        : 'Memuat token...';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Notify - Beranda'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => ref.read(authStateProvider.notifier).logout(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            color: Colors.blue.shade800,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Status: Terotentikasi & Siap Menerima Notifikasi',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Perangkat Anda telah berlangganan topik "pengumuman-kampus".',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.key, color: Colors.white70, size: 16),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Token: $displayToken',
                            style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        ),
                        if (currentFcmToken != null)
                          IconButton(
                            icon: const Icon(Icons.copy,
                                color: Colors.white, size: 16),
                            tooltip: 'Salin Token',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: currentFcmToken!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('FCM Token disalin ke clipboard!'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Daftar Pengumuman Terbaru:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.campaign, color: Colors.blue),
            title: const Text('Jadwal Ujian Tengah Semester'),
            subtitle:
                const Text('ID: 101 - Klik untuk melihat rincian deep link'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/pengumuman/101'),
          ),
          const Divider(),
          ListTile(
            leading:
                const Icon(Icons.notifications_active, color: Colors.orange),
            title: const Text('Pengumuman Beasiswa Prestasi'),
            subtitle:
                const Text('ID: 102 - Klik untuk melihat rincian deep link'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.go('/pengumuman/102'),
          ),
        ],
      ),
    );
  }
}
