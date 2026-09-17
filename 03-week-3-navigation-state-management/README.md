# ToDo Navigation & Riverpod

Proyek mini minggu ke-3: aplikasi ToDo dengan navigasi dua halaman, state management Riverpod, dan simulasi pemuatan statistik secara asynchronous.

## Tujuan

Mempraktikkan navigasi deklaratif, state immutable, serta penanganan state `loading`, `error`, dan `success` pada aplikasi Flutter yang sederhana tetapi bisa diuji.

## Fitur Utama

- Daftar tugas: tambah, tandai selesai, hapus, dan filter semua/aktif/selesai.
- Navigasi GoRouter dengan halaman ToDo dan Statistik.
- Halaman Statistik mensimulasikan request selama dua detik dan memiliki kemungkinan error 30%.
- Tombol retry menjalankan `ref.invalidate(statsProvider)` untuk memuat ulang data.
- Widget test untuk alur tambah tugas dan perpindahan halaman.

## Stack Teknologi

- Flutter dan Dart
- `flutter_riverpod` dengan `Notifier`, `AsyncNotifier`, dan `ConsumerWidget`
- `go_router` dengan `StatefulShellRoute.indexedStack`
- `flutter_test`

## Cara Menjalankan

Dari folder ini:

```powershell
flutter pub get
flutter run
```

Validasi kualitas kode dan test:

```powershell
flutter analyze
flutter test
```

## Hasil yang Dicapai

Implementasi memenuhi dua halaman yang dapat dinavigasi, state ToDo berbasis `Notifier`, simulasi async dengan tiga state `AsyncValue`, dan test widget yang lulus. Hasil akhir terakhir: `flutter test` menghasilkan `+2: All tests passed!`.

## AI Challenge

Prompt, output awal AI, perbaikan, alasan keputusan teknis, dan checklist verifikasi dicatat di [`tugas/docs/ai-verification.md`](tugas/docs/ai-verification.md).

Folder `screenshots/` disediakan sebagai tempat bukti visual untuk state loading, error, success, dan daftar ToDo.
