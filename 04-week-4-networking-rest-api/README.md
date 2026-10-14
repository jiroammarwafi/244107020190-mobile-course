# Uji Skenario Error
1. Aplikasi berjalan dengan normal di emulator dan berhasil load 100 post ke dalam aplikasi.

2-1. Aplikasi berjalan tanpa internet membuat data post yang sebelumnya tampil dilayar menjadi hilang, karena proses fetching gagal membaca URL dari file JSON yang bersumber dari internet. Sehingga menampilkan UI friendly di layar, menangani error exception (Connection Error).
2-2. Aplikasi kembali berjalan seperti biasa setelah melakukan pull to refresh/menekan tombol coba lagi, karena internet telah terhubung kembali.

3. Perubahan URL yang salah di baseURL, membuat aplikasi menampilkan error message "Tidak dapat terhubung ke server. Periksa internet Anda". Namun disini dalam kondisi jaringan internet tetap aktif, sedangkan masalah utamanya adalah URL yang tidak valid atau web domain yang dituju tidak ada di internet.


# AI verification checklist
1. Tidak UI memanggil Dio melalui Riverpod dan Repository
2. Comment.fromJson memberi nilai default untuk field yang hilang, null, atau bertipe tak sesuai.
3. Pesan pengguna mencakup timeout, connection error, serta bad response dengan pesan khusus untuk 404 dan 500.
4. baseUrl dan timeout connect/send/receive 10 detik dikonfigurasi terpusat di api_client.dart; konfigurasi per-request di repository dihapus.
5. comment_test.dart menguji field hilang dan edge case null/tipe salah.
6. flutter analyze lulus tanpa warning dan flutter test lulus seluruhnya.

# Stack teknologi

- Flutter dan Dart
- Dio untuk HTTP, timeout, dan logging interceptor
- `flutter_riverpod` untuk dependency injection dan state management
- JSONPlaceholder sebagai API publik tanpa API key

# Struktur project

```text
lib/
  data/
    api_client.dart
    models/post.dart
    network_errors.dart
    paged_posts.dart
    providers.dart
    repositories/post_repository.dart
  pages/post_list_page.dart
  main.dart
test/
  post_test.dart
  paged_posts_test.dart
  widget_test.dart
docs/
  AI_CHALLENGE.md
  AI_VERIFICATION.md
screenshots/
```

## Refleksi

### Mengapa UI tidak memanggil Dio langsung?

UI seharusnya menggambarkan state dan mengirimkan aksi pengguna, bukan mengatur
detail HTTP. Jika widget memanggil Dio langsung, konfigurasi dan parsing mudah
terduplikasi, UI sulit diuji tanpa jaringan, dan perubahan endpoint dapat
menyebar ke banyak widget. Repository menjadi satu batas untuk akses data;
provider mengatur lifecycle dan state yang diamati UI.

### Kapan pagination client-side cukup?

Pagination client-side masuk akal untuk dataset kecil yang sudah tersedia di
memori, misalnya hasil lokal yang terbatas. Untuk daftar server yang besar,
gunakan pagination server seperti `_page`/`_limit` agar aplikasi hanya
mengunduh halaman yang dibutuhkan, menghemat bandwidth dan memori, dan mendapat
data terbaru dari server. Project ini menggunakan pagination server-side.

### Bagaimana exception menjadi state error?

`AsyncNotifier.build()` Riverpod mengubah future yang gagal menjadi
`AsyncError`, sehingga widget dapat menangani error lewat `AsyncValue.when`
tanpa try/catch di setiap widget. Try/catch eksplisit tetap berguna pada aksi
imperatif seperti load-more atau refresh ketika perlu mempertahankan data lama,
mengubah indikator loading, atau menampilkan kontrol retry khusus.

### Bagian AI apa yang diperbaiki?

Implementasi AI sebelumnya memakai state daftar paged kustom, namun pemanggilan
`loadNextPage` sebelum request awal selesai dapat meminta halaman yang salah.
State kosong juga berisiko terlihat seperti loading terus-menerus, dan error
load-more tidak memiliki kontrol retry khusus. Saya memperjelas state awal dan
kosong, menambahkan guard request awal maupun halaman berikutnya, mempertahankan
data saat load-more gagal, serta menambah pengujian untuk overlap, retry, dan
akhir data. Keputusan ini membuat perilaku yang terlihat di UI terverifikasi
dan tidak bergantung pada request jaringan saat dites.