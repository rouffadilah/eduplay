# EDUPLAY 3D

Game belajar 3D berbasis browser. Siswa membuka **satu link tetap**, dan misinya dibaca dari Google Sheet milik guru. Setiap kali guru menerbitkan misi baru, link yang sama langsung memakai misi itu.

## Link

- **Link siswa:** `https://rouffadilah.github.io/eduplay/` (setelah `config.json` dibuat)
- **Pintu guru:** `https://rouffadilah.github.io/eduplay/?guru` (Teacher Studio dikunci PIN, jangan dibagikan)

## Persiapan sekali saja

1. Buat Google Sheet baru, lalu buka **Ekstensi → Apps Script**.
2. Tempel isi file [`apps-script.gs`](apps-script.gs). Ganti `GANTI_DENGAN_KUNCI_RAHASIA` dengan kata sandi Anda sendiri, lalu simpan.
3. **Terapkan → Deployment baru → Aplikasi web**. Jalankan sebagai: *Saya*. Yang memiliki akses: *Siapa saja*. Salin URL yang berakhiran `/exec`.
4. Buka pintu guru (`?guru`) → **Teacher Studio** → tempel URL itu di kolom Google Sheets → isi **Kunci guru** → **Terbitkan misi ke link siswa**.
5. Buat file `config.json` di repo ini berisi `{"g":"ID_DEPLOYMENT"}` (isi persisnya ditampilkan di Teacher Studio). Setelah itu link utama otomatis menjadi link siswa.

Setiap kali kode Apps Script diganti: **Terapkan → Kelola deployment → Edit → Versi baru → Terapkan**. URL-nya tidak berubah.

## Dunia yang hidup dan bertemu teman

- Setiap dunia punya bentang alam sendiri: sungai berkelok dengan jembatan kayu, danau kecil, bukit dan lembah, tebing di sekeliling pulau, air terjun, dan pegunungan di cakrawala. Bentuknya berbeda di tiap dunia.
- Saat siswa bermain lewat link guru, teman **sekelas** yang memilih dunia yang sama terlihat berjalan dengan nama dan avatarnya masing-masing. Tombol 👥 menunjukkan siapa saja yang ada, dan 👋 untuk melambai. Fitur ini butuh **Apps Script versi 6** dan memakai cache Apps Script, jadi tidak menulis apa pun ke spreadsheet.

## Sumber apa pun jadi dunia

Mode otomatis: unggah file (PDF, Word, PowerPoint, Excel, OpenDocument, EPUB, HTML, TXT/Markdown/CSV, RTF, JSON, subtitle, ZIP berisi dokumen, foto lewat OCR) atau tempel link dari situs mana pun (termasuk Wikipedia, Google Docs/Slides/Sheets/Drive, YouTube). EDUPLAY mengenali mapel dari isi sumber (Informatika, KKA, Matematika, Fisika, Kimia, Biologi, Sejarah, Geografi, Ekonomi, Sosiologi, Pendidikan Pancasila, Bahasa Indonesia, Bahasa Inggris, PAI, Seni Budaya, PJOK, Prakarya), juga topik dan kelas, lalu langsung membuat dunia dengan tema yang cocok. Matikan centang **Langsung buat dunia** jika ingin memeriksa teksnya dulu.

Bank soal bawaan juga tersedia untuk Geografi, Ekonomi, Sosiologi, Pendidikan Pancasila/PPKn, Bahasa Indonesia, PAI, Seni Budaya, PJOK, dan Prakarya. Pilih nama mapel di Teacher Studio; misi otomatis melengkapi soal yang berhasil dibuat dari materi dengan bank soal mapel tersebut.

## Struktur berkas

- `index.html` memuat kerangka halaman dan semua tampilan aplikasi.
- `assets/css/base.css` berisi gaya dasar bersama; `assets/css/pages/` memisahkan gaya permainan, Teacher Studio, hasil, dan bantuan.
- `assets/js/main.js` menjalankan aplikasi dan navigasi antartampilan; `assets/js/questions.js` berisi bank soal dan pemetaan mata pelajaran.

EDUPLAY tetap berupa satu aplikasi halaman tunggal: navigasi permainan, Teacher Studio, hasil, dan bantuan mengganti tampilan tanpa membuka dokumen HTML terpisah.

## Jenis soal, musik, dan avatar

- **8 jenis soal:** pilihan ganda, benar/salah, pilih semua yang tepat, isian (ketik jawaban), susun huruf, susun kata, urutkan, dan pasangkan. Guru memilih jenisnya di Mission Editor atau di kolom **Jenis Soal** pada template Excel (lihat sheet Petunjuk).
- Soal paket perangkat ajar otomatis diolah menjadi beragam jenis. Mode otomatis juga mencampur jenis soal.
- Kelas X tetap mendapat bantuan setelah jawaban salah, disesuaikan dengan jenis soalnya (pilihan disingkirkan, huruf atau langkah dipasang, atau petunjuk huruf).
- **Musik tema:** setiap dunia punya musik sendiri yang dibuat langsung di browser (tanpa file audio). Tombol 🎵 menyalakan atau mematikannya.
- **Avatar:** 24 karakter siap pakai (manusia, hewan, robot, alien, astronot, ninja) dan menu **Buat avatar sendiri** untuk mengatur karakter, rambut atau penutup kepala, warna, tas, dan aksesori.

## Kelas dan pilihan dunia

Siswa memilih kelas dari daftar (X-1, X-2, X-3, XI-A1, XI-1 s.d. XI-4, XII-A1, XII-1 s.d. XII-3), lalu memilih dunia lewat tombol 🌍. Dunia yang muncul hanya untuk tingkat kelasnya: kelas X-1/X-2/X-3 melihat dunia kelas X, dan seterusnya. Dunia buatan guru sendiri tampil paling atas sebagai **Dari guru**. Kemajuan setiap dunia tersimpan terpisah, jadi siswa bisa berpindah dunia tanpa kehilangan progres.

## Paket tema perangkat ajar

Teacher Studio → **📚 Paket perangkat ajar** berisi 36 dunia siap pakai (582 misi) dari perangkat ajar Informatika dan KKA kelas X–XII, satu dunia per bab. Soal diambil dari instrumen asesmen dan bahan ajar, lengkap dengan kunci, pembahasan, dan kode TP.

- **Atur misi** membuka dunia itu di Mission Editor. Pilih **Jumlah misi** (15–50) lalu **Susun ulang misi** untuk membuat dunia hingga **50 misi** dari soal bab itu, atau ubah, tambah, hapus, dan impor misi sendiri. Dunia yang diubah ditandai *Disesuaikan guru*.
- **Terbitkan semua** mengirim semua dunia yang diubah ke link siswa sekaligus. **Kembalikan soal bawaan** menghapus perubahan guru untuk dunia itu.
- **Jadikan dunia guru / Gabungkan** menyalin satu atau beberapa bab menjadi dunia guru sendiri.
- **Excel** mengunduh soal satu dunia dalam format template impor.
- Suasana mengikuti kelas: X siang dengan bantuan (satu pilihan salah disingkirkan setelah jawaban salah), XI senja, XII malam. Nilai tetap dari jawaban benar pada percobaan pertama.
- Menerbitkan misi per dunia dan jenis soal baru butuh **Apps Script versi 6**. Jika masih versi lama, Teacher Studio menampilkan langkah pembaruannya.

## Privasi

- Kunci guru hanya ada di Apps Script milik guru, tidak pernah tersimpan di repositori ini.
- Siswa tidak bisa mengubah misi tanpa kunci guru, dan tidak bisa membaca nilai siswa lain karena spreadsheet tetap privat.
- Misi dikirim ke siswa dalam bentuk tersamar supaya kunci jawaban tidak terbaca langsung.
