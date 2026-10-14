Hasil Verifikasi AI
[x] UI tidak memanggil Dio secara langsung. Halaman mengamati state Riverpod, dan PagedPostsNotifier mendapatkan data melalui PostRepository.
[x] Layar berpaging memiliki state pemuatan (loading), error dengan tombol coba lagi (error-with-retry), kosong (successful-empty), dan sukses dengan data (success-with-data).
[x] Paginasi menambahkan halaman berikutnya, mengabaikan permintaan halaman yang tumpang tindih (overlapping), memblokir permintaan halaman saat halaman pertama sedang dimuat, dan berhenti ketika sebuah halaman berisi kurang dari 10 postingan. UI menampilkan indikator akhir data (end-of-data).
[x] Hasil yang kosong tidak menampilkan indikator pemuatan yang terus-menerus.
[x] Coba lagi (retry) menghapus error awal dan dapat memuat halaman pertama kembali.