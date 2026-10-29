# AI Challenge: Perbandingan Local Storage & Rekomendasi Arsitektur

Dokumen ini berisi pencatatan prompt, analisis komparasi teknis mendalam antara **SharedPreferences**, **Hive**, **sqflite (SQLite)**, dan **Drift**, rekomendasi final untuk aplikasi Flutter **Offline Notes**, serta skema data untuk skala 1000+ catatan.

---

## 1. Prompt yang Digunakan

```text
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

---

## 2. Tabel Perbandingan Berdasarkan 6 Kriteria

| Kriteria | SharedPreferences | Hive (NoSQL Key-Value) | sqflite (Raw SQLite) | Drift (Type-Safe SQLite) |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | **Sangat Rendah**: Hanya *get/set* per key (`getString`, `setBool`). Tidak ada filtering atau sortir. | **Rendah – Sedang**: Mendukung *key-lookup* instan. Filtering/sorting majemuk harus diproses manual di RAM via manipulasi List Dart. | **Tinggi**: Mendukung SQL ANSI penuh (`WHERE`, `ORDER BY`, `LIMIT`, `OFFSET`, `LIKE`, agregasi `COUNT`). | **Sangat Tinggi**: Query SQL penuh + Fluent API Dart compile-time yang intuitif, auto-completion, dan validasi sintaks query saat kompilasi. |
| **Kebutuhan Relasi** | **Tidak Mendukung**: Format flat XML/plist tanpa konsep tabel atau pointer entitas. | **Tidak Mendukung**: Penyimpanan berbasis dokumen/objek lepas (*denormalized*). Relasi antar kotak harus dikaitkan manual di kode aplikasi. | **Mendukung Penuh**: Relasi relasional standar via *Foreign Key*, *JOIN* (INNER/LEFT), dan *Cascading Delete*. | **Mendukung Penuh**: Relasi relasional *type-safe* dengan ekspresi JOIN Dart dan navigasi relasi otomatis. |
| **Reaktivitas (Stream)** | **Tidak Ada**: Tidak ada mekanisme event/stream perubahan data bawaan. Perlu trigger manual atau state notifier. | **Native Stream**: Mendukung `box.watch()` per box atau per key secara langsung. | **Tidak Ada Bawaan**: Driver tidak memancarkan stream mutasi tabel. Reaktivitas harus dibangun di level state management (misal: Riverpod invalidation). | **Native Reactive Stream**: Mendukung `.watch()` pada query apa pun. UI otomatis *rebuild* seketika tabel database termutasi. |
| **Type-Safety** | **Lemah**: Mengandalkan konvensi string key dan rawan *type mismatch* runtime (misal `getInt` pada data `String`). | **Sedang**: Mendukung penyimpanan objek kustom, namun membutuhkan registrasi `TypeAdapter` dengan ID numerik statis. | **Lemah**: Bekerja dengan `Map<String, Object?>`. Mapping ke model objek (`fromMap`/`toMap`) ditulis manual dan rentan salah ketik nama kolom. | **Sangat Tinggi (100%)**: Kolom, baris, dan query dipetakan ke kelas Dart hasil *code generation*. Kesalahan tipe langsung terdeteksi saat *compile-time*. |
| **Ukuran Boilerplate** | **Minimal (0 Codegen)**: Cukup inisialisasi `SharedPreferences.getInstance()`. | **Sedang**: Memerlukan konfigurasi `TypeAdapter` (bisa manual atau via `hive_generator` + `build_runner`). | **Sedang (0 Codegen)**: Perlu menulis string DDL `CREATE TABLE`, query mentah, serta fungsi konversi model `toMap`/`fromMap`. | **Tinggi (Wajib Codegen)**: Memerlukan definisi tabel kelas Dart/SQL, eksekusi `build_runner`, dan dependensi tambahan (`drift_dev`). |
| **Kemudahan Testing** | **Sangat Mudah**: Didukung langsung oleh method resmi `SharedPreferences.setMockInitialValues({...})` tanpa menyentuh disk. | **Sedang**: Memerlukan inisialisasi path direktori virtual/sementara (`tempDirectory`) sebelum membuka box. | **Sangat Mudah**: Dapat diisolasi total dengan menginjeksi factory database *in-memory* (`:memory:`) atau *fake repository pattern*. | **Sedang**: Memerlukan *in-memory executor* (`drift/native.dart` via `NativeDatabase.memory()`) dan migrasi skema virtual. |

---

## 3. Penjelasan Trade-Off Setiap Pilihan

### A. SharedPreferences
* **Keunggulan**: Sangat ringan, terpasang langsung di hampir setiap aplikasi Flutter, latensi inisialisasi minimal, tidak memerlukan manajemen skema database.
* **Kelemahan (Trade-off)**: Seluruh file preferensi dibaca ke dalam memori saat aplikasi dibuka. Tidak memiliki mesin pengindeksan (*indexing*). Sangat berbahaya bila dipaksakan menyimpan koleksi data (seperti JSON list catatan); pembacaan/penulisan satu catatan mengharuskan penulisan ulang seluruh file ke disk.

### B. Hive
* **Keunggulan**: Sangat cepat untuk operasi baca/tulis murni NoSQL di memori, tidak membutuhkan parsing SQL, mendukung stream `watch()` bawaan yang memudahkan integrasi UI reaktif.
* **Kelemahan (Trade-off)**: Kurang optimal untuk *dataset* besar yang memerlukan pencarian kompleks (*full-text search* atau pengurutan dinamis). Jika ingin mengurutkan 1000 catatan berdasarkan tanggal, seluruh 1000 objek harus dimuat ke memori terlebih dahulu lalu disortir via Dart.

### C. sqflite (Raw SQLite)
* **Keunggulan**: Menggunakan SQLite mesin native Android/iOS yang teruji puluhan tahun, hemat memori karena mendukung *paging* kursor (*cursor-based pagination* via `LIMIT/OFFSET`), tidak membutuhkan pipeline `build_runner` (proses *build* cepat), dan mendukung indexing B-Tree untuk ribuan data.
* **Kelemahan (Trade-off)**: Tidak ada pengecekan sintaks SQL waktu kompilasi (kesalahan ketik pada nama tabel/kolom baru muncul sebagai *runtime exception*), serta perlu mengelola *serialization/deserialization* secara manual.

### D. Drift
* **Keunggulan**: Solusi paling matang untuk SQLite modern di Flutter. Menggabungkan efisiensi mesin relasional dengan kemudahan *stream watch* dan proteksi tipe data (*compile-time type safety*).
* **Kelemahan (Trade-off)**: Ukuran *boilerplate* dan *overhead build tool* cukup besar. Pengembang wajib menjalankan `dart run build_runner build` setiap kali ada perubahan skema, yang memperlambat siklus kompilasi saat pengembangan awal atau tugas praktikum berdurasi singkat.

---

## 4. Rekomendasi Final

| Kebutuhan Aplikasi | Pilihan Teknologi | Alasan dan Justifikasi Teknis |
| :--- | :--- | :--- |
| **Preferensi Tema & Riwayat Buka** | **SharedPreferences** | Data preferensi hanya berupa nilai skalar primitif (`bool isDarkMode`, `String lastOpenedAt`, `bool forceOffline`). SharedPreferences dirancang spesifik untuk kebutuhan ini dengan *overhead* memori mendekati nol, tidak membutuhkan tabel/skema DDL, dan pengujiannya sangat cepat dengan `setMockInitialValues`. |
| **CRUD Catatan (1000+ Data Offline)** | **sqflite (SQLite)** | Catatan adalah data terstruktur yang membutuhkan pengurutan waktu (`ORDER BY updated_at DESC`), pelacakan antrean sinkronisasi (`WHERE dirty = 1`), dan pencarian teks. SQLite menyimpan data di disk dengan indeks B-Tree tanpa membebani RAM secara berlebihan. Dipilih `sqflite` (dibandingkan Drift) untuk lingkup ini demi menghindari dependensi berat *code-generation* (`build_runner`) sekaligus menjaga arsitektur *clean repository* tetap transparan. |

---

## 5. Skema Tabel & Kotak untuk 1000+ Catatan

Agar aplikasi mampu menangani 1000+ catatan secara instan tanpa *lag* dan mendukung arsitektur **Offline-First (Dirty Flag & Last-Write-Wins)**, skema harus memiliki indeks B-Tree pada kolom pengurutan dan status sinkronisasi.

### A. Skema SQLite (`sqflite` / Drift)

```sql
-- 1. Tabel Utama Catatan
CREATE TABLE notes (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  title TEXT NOT NULL,
  body TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL,  -- Format ISO-8601 (UTC) untuk resolusi konflik Last-Write-Wins
  dirty INTEGER NOT NULL DEFAULT 0 -- 1 = Perlu diunggah (kotor), 0 = Sudah tersinkron (bersih)
);

-- 2. B-Tree Index untuk Performa Skala Besar (1000+ Data)
-- Memastikan query "ORDER BY updated_at DESC" tidak melakukan full table scan
CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);

-- Memastikan query antrean sync "SELECT * FROM notes WHERE dirty = 1" berjalan instan (O(log N))
CREATE INDEX idx_notes_dirty ON notes(dirty);

-- 3. Tabel Cache REST API (Cache-First Read untuk endpoint /posts)
CREATE TABLE cached_posts (
  id INTEGER PRIMARY KEY,
  payload TEXT NOT NULL,
  cached_at TEXT NOT NULL
);
```

#### Representasi Model & Mapping Dart:
```dart
class Note {
  const Note({
    this.id,
    required this.title,
    this.body = '',
    required this.updatedAt,
    this.dirty = false,
  });

  final int? id;
  final String title;
  final String body;
  final DateTime updatedAt;
  final bool dirty;

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'body': body,
    'updated_at': updatedAt.toIso8601String(),
    'dirty': dirty ? 1 : 0,
  };

  factory Note.fromMap(Map<String, Object?> map) => Note(
    id: (map['id'] as num?)?.toInt(),
    title: map['title'] as String? ?? '',
    body: map['body'] as String? ?? '',
    updatedAt: DateTime.tryParse(map['updated_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0),
    dirty: ((map['dirty'] as num?)?.toInt() ?? 0) == 1,
  );
}
```

---

### B. Skema Kotak Hive (Sebagai Alternatif NoSQL)

Jika diimplementasikan pada Hive, wajib menggunakan **`LazyBox`** (bukan reguler `Box`) untuk 1000+ catatan agar nilai teks catatan tidak membebani memori sebelum dibuka.

```dart
import 'package:hive/hive.dart';

part 'note_hive_model.g.dart';

@HiveType(typeId: 1)
class NoteHiveModel extends HiveObject {
  NoteHiveModel({
    required this.id,
    required this.title,
    required this.body,
    required this.updatedAt,
    this.dirty = false,
  });

  @HiveField(0)
  final int id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String body;

  @HiveField(3)
  final DateTime updatedAt;

  @HiveField(4)
  final bool dirty;
}
```

---

## 6. AI Verification Checklist & Temuan Evaluasi Kritis

- **Apakah AI menempatkan daftar catatan di SharedPreferences?**
  **Ditolak.** SharedPreferences tidak cocok untuk data dinamis berbentuk koleksi/list; memicu pemborosan I/O dan memori karena seluruh string JSON harus di-parse ulang setiap ada mutasi.
- **Apakah skema mendukung antrean sync?**
  **Ya.** Kolom `dirty` (INTEGER 0/1) berfungsi sebagai penanda antrean lokal, dan `updated_at` (ISO-8601) menjadi dasar resolusi konflik Last-Write-Wins.
- **Apakah klaim "real-time" didukung stream native?**
  `sqflite` tidak memiliki stream native; reaktivitas dicapai melalui integrasi `Riverpod` (`AsyncNotifier`). Jika menginginkan stream level query database, `Drift` adalah pilihan yang lebih tepat.
- **Estimasi boilerplate:**
  Drift membutuhkan pipeline `build_runner` yang menambah waktu kompilasi. Untuk kebutuhan aplikasi catatan tugas ini, kombinasi `sqflite` + `shared_preferences` memberikan keseimbangan arsitektur yang paling optimal.
