# AI Challenge: REST API posts

## Prompt

> Bangun aplikasi Flutter daftar data dari REST API dummy JSONPlaceholder
> `/posts`. Gunakan Dio terpusat (base URL, timeout, logging interceptor),
> repository + Riverpod, model `fromJson` yang aman untuk null, empat state UI
> (loading, error dengan retry, empty, success), dan infinite scroll
> server-side 10 item per halaman dengan guard request ganda. Sertakan unit
> test model/error mapping dan test provider menggunakan repository palsu.
> Dokumentasikan implementasi, hasil verifikasi AI, perbaikan, keputusan
> teknis, serta refleksi di README dan `docs/`.

## Hasil AI

Implementasi awal menyediakan pemisahan UI/repository, Dio client, Riverpod,
pagination, pesan error, dan beberapa tes. Review hasil awal menemukan bahwa
validasi yang hanya memeriksa compile/test sederhana belum membuktikan semua
state UI atau race conditions pagination. Bila halaman berikutnya diminta
selagi request pertama masih berjalan, nomor halaman dapat belum siap. State
empty yang tidak eksplisit juga bisa disalahartikan sebagai loading.

## Perbaikan yang diterapkan

- Menambahkan guard first-page dan load-more agar scroll berulang tidak
  mengirim request ganda atau meminta halaman sebelum halaman awal siap.
- Memisahkan error awal (dengan tombol retry) dan error load-more (mempertahankan
  item yang telah tampil serta menyediakan retry halaman).
- Menampilkan loading, empty, sukses, dan indikator akhir data secara terpisah.
- Menguji provider dengan repository palsu, error mapping, model dengan data
  hilang/tidak valid, pagination append/guard, dan state widget error/empty/data.
- Menjalankan seluruh test dengan repository palsu supaya hasil tidak bergantung
  pada koneksi internet atau server pihak ketiga.

## Keputusan teknis

- JSONPlaceholder mendukung `_page` dan `_limit`; server pagination dipakai agar
  client tidak perlu mengunduh seluruh dataset sebelum menampilkan daftar.
- Ukuran halaman ditetapkan 10 sesuai kriteria tugas.
- Dio dibuat melalui satu provider dan dipakai repository. Timeout connect,
  send, dan receive diatur pada base options agar konsisten.
- State pagination menggunakan notifier eksplisit karena load-more perlu
  mempertahankan item lama ketika gagal. UI tidak menangani detail HTTP.
- Data model memberi default aman untuk field hilang, null, atau bertipe tidak
  sesuai, sehingga satu field bermasalah tidak merusak seluruh daftar.

## Refleksi

UI yang memanggil Dio akan mencampur presentasi dengan transport, menyulitkan
pengujian offline, dan menggandakan parsing/error handling. Client-side
pagination cukup untuk dataset kecil yang sudah dimiliki client; untuk API
besar, server pagination mengurangi transfer dan memori. Future yang gagal pada
`AsyncNotifier.build` otomatis tersedia sebagai `AsyncError`; try/catch tetap
dibutuhkan pada operasi imperatif seperti load-more saat state lama harus
dipertahankan.
