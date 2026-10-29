# Praktikum 3: Simulasi offline dan antrean sync

## Langkah pengujian

1. Jalankan aplikasi dan buka tab **Catatan**.
2. Tambahkan catatan. Pastikan catatan tampil dengan status **Belum
   disinkronkan**.
3. Aktifkan switch **Simulasi offline**. Label berubah menjadi **Mode offline
   aktif** dan tombol sinkronisasi tidak bisa ditekan.
4. Tutup dan buka kembali aplikasi. Catatan tetap ada di SQLite dan tetap
   berstatus **Belum disinkronkan**.
5. Matikan **Simulasi offline**. Label berubah menjadi **Mode online aktif**.
   Tekan tombol sinkronisasi; setelah simulasi server selesai, catatan berubah
   menjadi **Tersinkron**.
6. Buka tab **Posts API**. Saat offline, aplikasi hanya membaca cache dan
   tidak mengirim request baru. Setelah online aktif, cache dibaca kembali
   lalu diperbarui dari `GET /posts`.

## Hasil observasi

- Catatan disimpan lokal, sehingga data dan status dirty bertahan setelah
  aplikasi dimulai ulang.
- Mode offline mencegah refresh API dan sinkronisasi catatan; catatan dirty
  tidak ditandai bersih ketika offline.
- Setelah mode online aktif, proses sinkronisasi menandai catatan dirty sebagai
  tersinkron.
- Test otomatis mencakup cache-first, perubahan mode offline ke online,
  perlindungan sinkronisasi saat offline, dan toggle mode pada UI.

## Screenshot

Simpan bukti visual dari emulator di folder ini:

- `offline-before.png`: catatan berstatus **Belum disinkronkan** sebelum
  sinkronisasi.
- `offline-mode.png`: **Mode offline aktif** dengan catatan dirty tetap ada.
- `online-after-sync.png`: **Mode online aktif** dan catatan berstatus
  **Tersinkron** setelah sinkronisasi.

File gambar perlu diambil dari emulator/perangkat yang menjalankan aplikasi;
hasil gambar tidak dibuat atau direkayasa oleh test otomatis.
