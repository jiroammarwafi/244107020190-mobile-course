# Dokumentasi Verifikasi AI

## Prompt yang Digunakan

> Buatkan halaman Flutter bernama StatsPage menggunakan flutter_riverpod.
> Requirements:
> - ConsumerWidget dengan satu AsyncNotifierProvider yang mensimulasikan
>   pengambilan data statistik (delay 2 detik, kadang gagal 30%).
> - UI harus menangani loading (spinner), error (pesan + tombol retry),
>   dan success (ListView 3 item).
> - Berikan unit test untuk notifier-nya.
> Jelaskan setiap bagian kode dalam komentar.

## Output Awal AI

AI menambahkan `StatsNotifier` berbasis `AsyncNotifier`, `statsProvider`,
`StatsPage` berbasis `ConsumerWidget`, serta unit test untuk kondisi sukses dan
error. Halaman utama proyek `week3_todo` diarahkan ke `StatsPage`, dan komentar
ditambahkan pada bagian penting kode.

## Perbaikan yang Dilakukan

1. Dependency angka acak dibuat menjadi callback `double Function()` agar test
   dapat menentukan hasil sukses atau gagal tanpa mewarisi interface `Random`
   dari SDK Dart.
2. Delay dapat diinjeksi sehingga test memakai `Duration.zero`, sementara
   perilaku aplikasi tetap delay dua detik.
3. Test error membaca `AsyncValue` setelah event loop berjalan. Ini menghindari
   error lifecycle internal ketika `ProviderContainer` dibuang sebelum
   `AsyncNotifier` selesai mengubah state.
4. Test counter bawaan diganti menjadi smoke test `StatsPage` yang membungkus
   widget dengan `ProviderScope`. Test lama tidak sesuai dengan aplikasi dan
   sebelumnya gagal karena tidak ada provider scope serta tidak ada counter.
5. Checklist verifikasi ditambahkan ke README minggu ini.

## Hasil Testing

Perintah yang dijalankan dari folder `week3_todo`:

```text
flutter analyze
No issues found!

flutter test
00:02 +3: All tests passed!
```

Pada percobaan awal setelah test counter diganti, test menemukan timer delay
dua detik yang masih tertinggal. Test kemudian diperbaiki dengan menunggu delay
notifier sebelum teardown. Hasil final di atas mencakup dua unit test notifier:
data berhasil dan simulasi error 30%, serta satu widget smoke test untuk state
loading `StatsPage`.

## Kesimpulan

Kode memenuhi checklist: state tidak dimutasi langsung, provider bertipe
eksplisit dan tunggal, tiga state `AsyncValue` ditangani, serta API Riverpod
yang dipakai adalah `AsyncNotifier` dan `ConsumerWidget`.