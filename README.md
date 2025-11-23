# 🏅 **Sporra** — Aplikasi Komunitas & Forum Olahraga

## 👥 **Anggota Kelompok**

| No | Nama Lengkap             | NPM        |
| -- | ------------------------ | ---------- |
| 1  | Afero Aqil Roihan        | 2406352304 |
| 2  | Andi Hakim Himawan       | 2406495792 |
| 3  | Dylan Pirade Ponglabba   | 2406496126 |
| 4  | Farrel Faridzi Liwungang | 2406436240 |
| 5  | Naila Shafa Azizah       | 2406356510 |

---

# 📝 **Deskripsi Aplikasi **

**Sporra** adalah aplikasi mobile yang kami bangun sebagai ruang berkumpulnya para penggemar olahraga.
Di Sporra, siapa pun bisa mengikuti berita terkini, mencari event olahraga terdekat, berdiskusi di forum, hingga membuat aktivitas olahraga bersama.

Sporra hadir untuk menjawab kebutuhan komunitas yang ingin:

* tetap terhubung dengan dunia olahraga,
* mendapatkan update informasi dengan cepat,
* mencari teman olahraga,
* atau sekadar berbagi cerita dan opini.

Kami ingin menciptakan platform yang **hangat, interaktif, dan hidup**, di mana pengguna bisa berkembang bersama komunitas yang memiliki minat serupa.

### 🎉 **Apa yang bisa kamu lakukan di Sporra?**

* Membaca dan berdiskusi tentang berita olahraga terbaru
* Membuat dan mengikuti event olahraga
* Melakukan booking atau pendaftaran event
* Membuat posting forum, komentar, dan upvote
* Mengatur profil dan melihat aktivitas kamu

Aplikasi dibangun secara modular dengan **Django** sebagai backend dan **Flutter** sebagai frontend, sehingga prosesnya efisien dan mudah dikembangkan oleh setiap anggota tim.

---

# ⚙️ **Modul dalam Aplikasi**

### **1. Modul Berita — Farrel Faridzi Liwungang**

Berisi kumpulan berita olahraga terbaru. Pengguna bisa membaca detail berita dan meninggalkan komentar.

### **2. Modul Event — Dylan Pirade Ponglabba**

Menampilkan daftar event olahraga beserta detail lokasi, jadwal, dan deskripsi. Pengguna atau admin dapat membuat event baru.

### **3. Modul Ticketing / Booking Event — Andi Hakim Himawan**

Pengguna dapat mendaftar event, melihat tiket, melakukan check-in, hingga memantau riwayat event yang pernah diikuti.

### **4. Modul Forum Diskusi — Naila Shafa Azizah**

Tempat pengguna berbagi cerita, bertanya, atau memberi opini. Mendukung posting, komentar, balasan, dan upvote.

### **5. Modul Profil Pengguna — Afero Aqil Roihan**

Menampilkan profil pengguna, statistik aktivitas, dan pengaturan akun.

---

# 👤 **Role Pengguna**

### **Admin**

Memiliki kontrol penuh untuk mengelola seluruh modul:

* Mengelola berita, event, dan booking
* Menghapus posting atau komentar bermasalah
* Mengatur kategori, data, atau konten penting lainnya

### **User Biasa**

Pengguna umum dapat:

* Membaca berita dan event
* Membuat posting forum dan komentar
* Mendaftar event dan membuat event
* Membuat tiket terkait event yang mereka buat
* Mengatur profil pribadi

---

# 🔌 **Alur Pengintegrasian Data dengan Web Service (PWS)**

Backend Sporra dibangun menggunakan **Django**, sedangkan frontend menggunakan **Flutter**. Keduanya berkomunikasi melalui **REST API** yang mengirimkan data berupa **JSON**.

Supaya proses integrasi rapi dan konsisten, inilah alur yang kami gunakan:

---

## **1. Backend Menyediakan Data dalam Format JSON**

Tim backend membuat endpoint Django yang:

* Menghasilkan JSON, bukan HTML
* Menggunakan URL routing yang rapi untuk setiap modul
* Bisa menerima dan mengirim data sesuai kebutuhan fitur

Contohnya:
`/news/` → daftar berita
`/events/` → daftar event
`/ticket/my-bookings/` → tiket milik user

---

## **2. Flutter Membuat Model untuk Parsing JSON**

Agar data mudah digunakan di aplikasi:

* Struktur JSON dianalisis
* Dibuat class Dart khusus dengan:

  * `fromJson()` → parsing JSON ke objek Dart
  * `toJson()` → mengubah objek ke JSON saat ingin dikirim ke server
* Pembuatan model terbantu oleh Quicktype agar tidak rawan typo

Model ini memastikan data yang diterima dari Django bisa langsung dipakai di UI.

---

## **3. Autentikasi & State Management dengan Provider + CookieRequest**

Untuk proses login, sesi, serta request ke Django:

* **Provider** menyebarkan data user dan state aplikasi
* **CookieRequest (pbp_django_auth)** menangani:

  * login/logout
  * penyimpanan cookie session
  * pengiriman cookie otomatis saat melakukan request

Ini memastikan bahwa fitur seperti booking, membuat event, atau posting forum dijalankan sebagai user yang benar.

---

## **4. Mengambil Data (GET Request)**

Untuk menampilkan list berita, event, forum, dan tiket:

1. Flutter mengirim **HTTP GET** ke endpoint Django
2. Django merespon JSON
3. JSON diubah menjadi objek Dart
4. UI dibangun dengan **FutureBuilder**, yang menangani:

   * loading
   * data berhasil
   * error

Proses ini membuat aplikasi terasa responsif dan dinamis.

---

## **5. Mengirim Data (POST Request)**

Dipakai ketika user mengisi form seperti:

* membuat event
* booking event
* membuat posting atau komentar
* mengedit profil

Alurnya:

1. Form Flutter mengumpulkan input user
2. Data dikirim ke Django via `request.postJson()`
3. Django memvalidasi input dan menyimpan ke database
4. Django mengirim kembali JSON sebagai respon
5. Flutter memperbarui state dan UI

---

Proses integrasi ini membuat alur aplikasi menjadi **mulus, real-time, dan aman**, serta memudahkan pengembangan berkelanjutan.

---

# 🔗 **Link APK & Desain**

* **Link APK:** *(menyusul)*
* **Link Figma:** *(tambahkan link di sini)*

