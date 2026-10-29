# Docs:  
1. AI_CHALLENGE.md -> Output prompt AI

# AI VERIFICATION CHECKLIST
1. Catatan di SharedPreferences (Ditolak): SharedPreferences hanya digunakan untuk preferensi skalar tunggal. Menyimpan daftar catatan dalam JSON string ditolak karena memicu I/O bottleneck (baca/tulis ulang seluruh file saat ada mutasi), ketiadaan indeks query/sorting, serta rentan korup tanpa transaksi ACID.

2. Dukungan Antrean Sinkronisasi (Diperbaiki): Rekomendasi CRUD polos AI ditolak. Skema diperbaiki dengan menambahkan kolom dirty INTEGER NOT NULL DEFAULT 0 sebagai antrean sinkronisasi lokal dan updated_at TEXT NOT NULL sebagai penentu resolusi konflik Last-Write-Wins (LWW), dilengkapi indeks B-Tree untuk performa 1000+ data.

3. Klaim Reaktivitas "Real-Time" (Dikoreksi): sqflite tidak memiliki stream reaktif bawaan. Reaktivitas pada aplikasi ini dicapai melalui state management Riverpod (AsyncNotifier) yang menginvalidasi provider setelah mutasi, bukan dari driver database seperti fitur .watch() pada Drift atau Hive.

4. Estimasi Boilerplate & Instalasi: AI meremehkan kompleksitas Drift dan Hive yang membutuhkan dependensi berat dan pipeline build_runner. Penggunaan sqflite + path jauh lebih efisien (zero code-generation), instalasi instan, dan proses kompilasi tetap cepat.

5. Keputusan Final: Memilih kombinasi SharedPreferences untuk pengaturan preferensi aplikasi (tema gelap, simulasi forceOffline, riwayat waktu buka) dan sqflite (SQLite) untuk persistensi catatan serta cache data API (cache-first read). Kombinasi ini memberikan performa optimal, kemudahan pengujian unit via fake repository, serta stabilitas tanpa ketergantungan codegen.