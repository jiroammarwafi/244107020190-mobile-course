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