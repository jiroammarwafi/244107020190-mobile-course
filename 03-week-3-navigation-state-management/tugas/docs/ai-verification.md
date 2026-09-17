# Dokumentasi AI Challenge

## Prompt

> Bangun aplikasi ToDo Flutter untuk tugas minggu ke-3 dengan minimal dua halaman menggunakan GoRouter. Kelola daftar tugas dengan Riverpod Notifier dan ConsumerWidget. Tambahkan halaman statistik yang memakai AsyncValue dengan simulasi loading dua detik, kemungkinan error, data success, dan tombol retry. Sertakan widget test dan dokumentasikan alasan keputusan teknis.

## Output Awal AI

AI menghasilkan provider ToDo berbasis `Notifier`, halaman ToDo dengan filter,
routing `StatefulShellRoute.indexedStack`, serta `StatsNotifier` berbasis
`AsyncNotifier`. Halaman statistik merender `loading`, `error`, dan `data`
melalui `AsyncValue.when()`.

## Perbaikan yang Dilakukan

1. Dependency angka acak dan durasi delay pada `StatsNotifier` dibuat dapat diinjeksi. Produksi tetap memakai delay dua detik dan peluang error 30%, sedangkan test dapat berjalan deterministik tanpa menunggu lama.
2. Test widget utama diperbarui dari test counter bawaan Flutter menjadi test tambah tugas dan test navigasi ke halaman statistik.
3. Test navigasi memajukan fake clock dua detik agar timer simulasi asynchronous selesai sebelum teardown.
4. Assertion test navigasi disesuaikan karena teks `Statistik` tampil di AppBar dan NavigationBar.
5. README portfolio ditulis ulang agar tujuan, fitur, stack, cara menjalankan, hasil, dan bukti verifikasi terdokumentasi.

## Keputusan Teknis

- `Notifier<List<Todo>>` dipilih karena operasi tambah, toggle, hapus, dan filter membutuhkan state sinkron yang immutable.
- `AsyncNotifier<List<String>>` dipilih untuk merepresentasikan lifecycle request tanpa membuat enum status manual.
- `ConsumerWidget` digunakan agar UI membaca provider melalui `WidgetRef` dan mudah diuji dengan `ProviderScope`.
- `StatefulShellRoute.indexedStack` dipakai agar dua tab mempertahankan state navigasinya ketika pengguna berpindah halaman.

## Checklist Verifikasi

| Pemeriksaan | Hasil |
| --- | --- |
| Dua halaman GoRouter | Lulus: ToDo dan Statistik |
| Riverpod Notifier | Lulus: daftar/filter ToDo memakai `Notifier` |
| ConsumerWidget | Lulus: `MyApp`, `TodoPage`, dan `StatsPage` |
| AsyncValue loading | Lulus: `CircularProgressIndicator` |
| AsyncValue error | Lulus: pesan error dan tombol `Coba lagi` |
| AsyncValue success | Lulus: tiga item statistik |
| Widget test | Lulus: `flutter test` menghasilkan `+2: All tests passed!` |
| Static analysis | Dijalankan pada validasi akhir |