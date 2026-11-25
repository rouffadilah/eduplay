# EDUPLAY — Panduan fondasi Supabase

## Status saat ini

EDUPLAY masih berupa aplikasi statis GitHub Pages. Pull request ini menambahkan rancangan skema data dan panduan persiapan, **belum mengaktifkan login, database online, sinkronisasi game, atau CBT pada website**. Jangan menganggap angka dashboard sebagai data nyata sampai integrasi selesai.

## Mengapa Supabase

Supabase menyediakan PostgreSQL, Auth, dan Row Level Security (RLS). Ini cocok untuk model sekolah–guru–kelas–siswa. Data game lokal yang sekarang disimpan browser tidak otomatis berpindah ke cloud; perlu proses migrasi/sinkronisasi terpisah.

## Isi migrasi

File `supabase/migrations/0001_edup​​lay_foundation.sql` (nama file tanpa karakter pemisah tersembunyi; gunakan file di folder migrations) menyiapkan:
- Profil pengguna dan keanggotaan sekolah berbasis peran.
- Kelas, guru kelas, dan pendaftaran siswa.
- Mata pelajaran, course, materi, dan tugas.
- Bank soal, asesmen, percobaan, dan jawaban.
- Progres game serta event aktivitas.
- RLS untuk membatasi data sesuai pengguna/sekolah/kelas.

**Catatan keamanan penting:** kolom `answer_key` pada bank soal tidak boleh dibaca langsung oleh browser siswa. Untuk CBT produksi, buat Supabase Edge Function yang memeriksa hak akses dan mengirim soal tanpa kunci jawaban. Penilaian jawaban juga sebaiknya dilakukan di server. Jangan menyimpan Supabase `service_role` key di HTML/JavaScript.

## Langkah menyiapkan proyek

1. Buat proyek di Supabase dan simpan URL serta anon/publishable key.
2. Buka SQL Editor, jalankan isi file migrasi.
3. Di Authentication → URL Configuration, atur Site URL dan Redirect URLs ke domain GitHub Pages yang benar.
4. Buat akun pertama melalui Authentication. Profil otomatis dibuat dengan peran dasar; peran guru/admin tidak dapat dipilih sendiri oleh pengguna.
5. Tetapkan keanggotaan sekolah dan peran guru/admin dari lingkungan tepercaya (SQL Editor/admin backend), bukan dari formulir publik.
6. Jalankan pemeriksaan RLS dengan dua akun uji: siswa sekolah A dan guru sekolah B. Pastikan keduanya tidak dapat membaca data sekolah lain.
7. Baru setelah itu implementasikan klien Supabase menggunakan anon/publishable key dan sesi Auth.

## Keputusan implementasi yang belum boleh dilewati

- **Pembuatan akun guru/admin:** harus melalui undangan atau penetapan admin tepercaya. Jangan percaya `user_metadata.role` dari browser.
- **CBT:** kunci jawaban tidak boleh dikirim ke browser siswa; gunakan Edge Function untuk pengambilan soal dan penilaian.
- **Progres game:** tentukan skema konversi dari localStorage lama, validasi nilai XP/koin di server, dan hindari menerima skor dari klien tanpa pemeriksaan.
- **Privasi siswa:** kumpulkan data minimum, batasi akses guru ke kelas yang ditugaskan, tetapkan retensi dan prosedur penghapusan.
- **GitHub Pages:** semua JavaScript yang dipublikasikan dapat dibaca. Jangan pernah menaruh secret key atau kredensial admin di repository.

## Tahapan berikutnya

1. Selesaikan review dan merge PR fondasi ini.
2. Buat proyek Supabase dan jalankan migrasi.
3. Implementasikan halaman login + pemulihan sesi.
4. Implementasikan onboarding dan manajemen sekolah/kelas.
5. Hubungkan progres game melalui endpoint aman.
6. Bangun CBT dengan Edge Functions, pengacakan soal, timer, dan penilaian server-side.

## Batasan migrasi ini

Ini adalah fondasi awal, bukan skema produksi yang sudah diaudit. Sebelum dipakai dengan data siswa sungguhan, lakukan pengujian RLS dan peninjauan keamanan oleh pengelola teknis. Kebijakan akses untuk pengelolaan kelas, penugasan, dan penilaian dapat perlu disesuaikan dengan tata kelola sekolah.
