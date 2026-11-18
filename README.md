# EDUPLAY 3D

Game belajar 3D berbasis browser. Siswa membuka **satu link tetap**, dan misinya dibaca dari Google Sheet milik guru. Setiap kali guru menerbitkan misi baru, link yang sama langsung memakai misi itu.

## Link

- **Link siswa:** `https://rouffadilah.github.io/eduverse/` (setelah `config.json` dibuat)
- **Pintu guru:** `https://rouffadilah.github.io/eduverse/?guru` (Teacher Studio dikunci PIN, jangan dibagikan)

## Persiapan sekali saja

1. Buat Google Sheet baru, lalu buka **Ekstensi → Apps Script**.
2. Tempel isi file [`apps-script.gs`](apps-script.gs). Ganti `GANTI_DENGAN_KUNCI_RAHASIA` dengan kata sandi Anda sendiri, lalu simpan.
3. **Terapkan → Deployment baru → Aplikasi web**. Jalankan sebagai: *Saya*. Yang memiliki akses: *Siapa saja*. Salin URL yang berakhiran `/exec`.
4. Buka pintu guru (`?guru`) → **Teacher Studio** → tempel URL itu di kolom Google Sheets → isi **Kunci guru** → **Terbitkan misi ke link siswa**.
5. Buat file `config.json` di repo ini berisi `{"g":"ID_DEPLOYMENT"}` (isi persisnya ditampilkan di Teacher Studio). Setelah itu link utama otomatis menjadi link siswa.

Setiap kali kode Apps Script diganti: **Terapkan → Kelola deployment → Edit → Versi baru → Terapkan**. URL-nya tidak berubah.

## Kelas dan pilihan dunia

Siswa memilih kelas dari daftar (X-1, X-2, X-3, XI-A1, XI-1 s.d. XI-4, XII-A1, XII-1 s.d. XII-3), lalu memilih dunia lewat tombol 🌍. Dunia yang muncul hanya untuk tingkat kelasnya: kelas X-1/X-2/X-3 melihat dunia kelas X, dan seterusnya. Dunia buatan guru sendiri tampil paling atas sebagai **Dari guru**. Kemajuan setiap dunia tersimpan terpisah, jadi siswa bisa berpindah dunia tanpa kehilangan progres.

## Paket tema perangkat ajar

Teacher Studio → **📚 Paket perangkat ajar** berisi 36 dunia siap pakai (582 misi) dari perangkat ajar Informatika dan KKA kelas X–XII, satu dunia per bab. Soal diambil dari instrumen asesmen dan bahan ajar, lengkap dengan kunci, pembahasan, dan kode TP.

- **Atur misi** membuka dunia itu di Mission Editor. Guru bisa mengubah, menambah, menghapus, atau mengimpor misi hingga **50 misi per dunia**. Dunia yang diubah ditandai *Disesuaikan guru*.
- **Terbitkan semua** mengirim semua dunia yang diubah ke link siswa sekaligus. **Kembalikan soal bawaan** menghapus perubahan guru untuk dunia itu.
- **Jadikan dunia guru / Gabungkan** menyalin satu atau beberapa bab menjadi dunia guru sendiri.
- **Excel** mengunduh soal satu dunia dalam format template impor.
- Suasana mengikuti kelas: X siang dengan bantuan (satu pilihan salah disingkirkan setelah jawaban salah), XI senja, XII malam. Nilai tetap dari jawaban benar pada percobaan pertama.
- Fitur misi per dunia butuh **Apps Script versi 4**. Jika masih versi lama, Teacher Studio menampilkan langkah pembaruannya.

## Privasi

- Kunci guru hanya ada di Apps Script milik guru, tidak pernah tersimpan di repositori ini.
- Siswa tidak bisa mengubah misi tanpa kunci guru, dan tidak bisa membaca nilai siswa lain karena spreadsheet tetap privat.
- Misi dikirim ke siswa dalam bentuk tersamar supaya kunci jawaban tidak terbaca langsung.
