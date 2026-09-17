## Praktikum 3 - Uji Ketiga State
1. (Screenshot: run week3_todo) terdapat state loading dengan animasi bulatan yang berputar selama 2 detik, dan menampilkan state success dengan menampilkan daftar produk.
2. (Screeshot: run week3_todo_error_build) Layar akan menampilkan teks "Gagal memuat: Exception: gagal terhubung ke server" beserta tombol coba lagi (state error)
3. Perubahan build() dari state error sebelumnya, dan mengembalikan state build semula. State berubah ketika tombol coba lagi ditekan, dan menjalaankan ref.invalidate di product_page.dart
4. Menampilkan data lama (stale data) dengan indikator refresh menjaga kenyamanan visual pengguna karena mencegah layar kosong saat proses sinkronisasi berlangsung. Pengguna tetap bisa membaca konten yang ada tanpa gangguan. Pola ini sangat penting untuk diterapkan pada fitur pembaruan berkala—seperti pull-to-refresh, linimasa media sosial, dan data harga (real-time)—terutama di kondisi jaringan yang lambat atau tidak stabil.

## AI Prompt Challenge
## AI Verification Checklist

| Pemeriksaan | Temuan | Status |
| --- | --- | --- |
| State immutable | `StatsNotifier` menghasilkan list baru dari `build()` dan tidak memakai `state.add()` atau memutasi list langsung. | Lulus |
| Penggunaan ref | `ref.watch(statsProvider)` hanya dipakai di `StatsPage.build()`. Callback retry memakai `ref.invalidate(statsProvider)` karena tujuannya memulai ulang provider, bukan membaca state. | Lulus |
| Tiga state AsyncValue | `statsAsync.when()` menangani `loading` dengan spinner, `error` dengan pesan dan tombol retry, serta `data` dengan `ListView` tiga item. | Lulus |
| Provider eksplisit dan tunggal | Provider dideklarasikan sebagai `AsyncNotifierProvider<StatsNotifier, List<String>>` dan hanya ada satu `statsProvider` untuk halaman statistik. | Lulus |
| API Riverpod | Tidak ditemukan `StateProvider`, `StateNotifierProvider`, atau `Consumer` bertingkat yang tidak perlu. Pola yang dipakai adalah `AsyncNotifier` dan `ConsumerWidget`. | Lulus |
| Analyzer dan test | `flutter analyze` tidak menghasilkan warning atau error. `flutter test` lulus setelah test counter lama diganti dengan test `StatsPage`. | Lulus |

Rincian prompt, output awal AI, perbaikan, dan bukti testing disimpan di [`tugas/docs/ai-verification.md`](tugas/docs/ai-verification.md).
