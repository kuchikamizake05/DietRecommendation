# Sistem Pakar Rekomendasi Diet Sehat

Ini adalah proyek Sistem Pakar berbasis **CLIPS** (C Language Integrated Production System) yang menggunakan metode **Forward Chaining** (Runutan Maju) untuk memberikan rekomendasi diet yang sehat. 

Sistem pakar ini akan merekomendasikan program diet yang sesuai berdasarkan beberapa faktor profil pengguna, seperti kondisi medis, tujuan berat badan, dan preferensi makanan.

## 📋 Fitur / Input Sistem

Sistem akan menanyakan 5 aspek dari pengguna saat dijalankan:
1. **Tujuan Utama Diet**: `turun` | `naik` | `tetap`
2. **Tingkat Aktivitas Fisik**: `tinggi` | `sedang` | `rendah`
3. **Kondisi Medis**: `diabetes` | `hipertensi` | `normal`
4. **Preferensi Makanan**: `vegetarian` | `biasa`
5. **Alergi Susu (Laktosa)**: `ya` | `tidak`

## 💡 Output Prediksi Diet (Rules)

Beberapa contoh rekomendasi program diet yang dihasilkan oleh sistem:
- **Diet Karbohidrat Kompleks & Rendah Gula** (Khusus penderita diabetes)
- **Diet DASH** (Khusus penderita hipertensi)
- **Diet Vegetarian Defisit Kalori** (Untuk turun berat badan dengan preferensi vegetarian)
- **Diet Defisit Kalori Bebas Laktosa** (Untuk turun berat badan bagi yang alergi laktosa)
- **Diet Defisit Kalori Kaya Protein / Fat Loss** (Diet reguler turun berat badan)
- **Diet Surplus Kalori Bersih / Clean Bulking** 
- **Diet Mediterania / Gizi Seimbang** (Maintenance rutin)
- dan lain-lain.

## 🚀 Cara Menjalankan Program

1. Pastikan Anda sudah menginstal **CLIPS** di komputer Anda.
2. Buka environment CLIPS IDE atau terminal yang mendukung CLIPS.
3. Muat file program dengan perintah:
   ```clips
   (load "DietSehat.clp")
   ```
4. Reset sistem agar memori memuat fakta ke kondisi awal:
   ```clips
   (reset)
   ```
5. Jalankan sistem pakar:
   ```clips
   (run)
   ```
6. Jawablah pertanyaan-pertanyaan yang muncul di terminal/konsol dengan mengetikkan opsi yang tersedia lalu tekan Enter.
7. Di akhir sesi, sistem akan menampilkan hasil rekomendasi diet sehat lengkap beserta anjuran/penjelasannya.

---
*Dibuat untuk keperluan pembelajaran/mata kuliah AI*
