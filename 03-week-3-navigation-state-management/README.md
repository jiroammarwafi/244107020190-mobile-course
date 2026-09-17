## Praktikum 3 - Uji Ketiga State
1. (Screenshot: run week3_todo) terdapat state loading dengan animasi bulatan yang berputar selama 2 detik, dan menampilkan state success dengan menampilkan daftar produk.
2. (Screeshot: run week3_todo_error_build) Layar akan menampilkan teks "Gagal memuat: Exception: gagal terhubung ke server" beserta tombol coba lagi (state error)
3. Perubahan build() dari state error sebelumnya, dan mengembalikan state build semula. State berubah ketika tombol coba lagi ditekan, dan menjalaankan ref.invalidate di product_page.dart
4. Menampilkan data lama (stale data) dengan indikator refresh menjaga kenyamanan visual pengguna karena mencegah layar kosong saat proses sinkronisasi berlangsung. Pengguna tetap bisa membaca konten yang ada tanpa gangguan. Pola ini sangat penting untuk diterapkan pada fitur pembaruan berkala—seperti pull-to-refresh, linimasa media sosial, dan data harga (real-time)—terutama di kondisi jaringan yang lambat atau tidak stabil.

## AI Prompt Challenge
