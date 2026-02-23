;;;======================================================
;;;   Sistem Pakar Penentuan Diet Sehat
;;;   Berdasarkan Kebutuhan Gizi
;;;   (Aturan Berbasis Fakta / Forward Chaining)
;;;
;;;   Deskripsi:
;;;     Sistem ini menentukan rekomendasi diet yang sehat
;;;     berdasarkan tujuan, aktivitas, kondisi medis,
;;;     preferensi makanan, dan alergi dari pengguna.
;;;
;;;   Cara menjalankan:
;;;     (load "DietSehat.clp")
;;;     (reset)
;;;     (run)
;;;======================================================

;;;*****************************************************
;;;* DEFTEMPLATES - Definisi Struktur Fakta            *
;;;*****************************************************

;;; Template untuk profil nutrisi pengguna
(deftemplate profil-pengguna
   (slot tujuan-diet)      ; turun / naik / tetap
   (slot tingkat-aktivitas); tinggi / sedang / rendah
   (slot kondisi-medis)    ; diabetes / hipertensi / normal
   (slot preferensi-makan) ; vegetarian / biasa
   (slot alergi-susu))     ; ya / tidak

;;; Template untuk hasil prediksi / rekomendasi diet
(deftemplate rekomendasi
   (slot hasil)             ; hasil program diet
   (slot penjelasan))       ; alasan mengapa diet tersebut dipilih

;;;*****************************************************
;;;* DEFFUNCTIONS - Fungsi Bantu                       *
;;;*****************************************************

;;; Fungsi interaktif untuk menanyakan pertanyaan
(deffunction ask-question (?question $?allowed)
   (printout t ?question " " $?allowed ": ")
   (bind ?answer (read))
   (if (lexemep ?answer)
      then (bind ?answer (lowcase ?answer)))
   (while (not (member$ ?answer ?allowed)) do
      (printout t "  Jawaban tidak valid." crlf)
      (printout t ?question " " $?allowed ": ")
      (bind ?answer (read))
      (if (lexemep ?answer)
         then (bind ?answer (lowcase ?answer))))
   ?answer)

;;;*****************************************************
;;;* QUERY RULES - Aturan Pengumpulan Fakta            *
;;;*****************************************************

;;; Rule ditugaskan menanyai input awal
(defrule tanya-profil-pengguna
   (declare (salience 100))
   (not (profil-pengguna))
   =>
   (printout t crlf)
   (printout t "=============================================" crlf)
   (printout t "  SISTEM PAKAR PENENTUAN DIET SEHAT" crlf)
   (printout t "=============================================" crlf)
   (printout t "Diet adalah pengaturan pola makan dan jenis makanan yang dikonsumsi secara teratur untuk mencapai tujuan tertentu, seperti menjaga kesehatan, menurunkan atau menambah berat badan, serta mengelola penyakit. Diet bukan sekadar mengurangi porsi, melainkan pola hidup untuk memenuhi nutrisi seimbang, bukan hanya tentang menurunkan berat badan." crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)

   ;; Tanya tujuan diet
   (bind ?tujuan
      (ask-question "Apa tujuan utama diet Anda?"
         turun naik tetap))

   ;; Tanya tingkat aktivitas fisik
   (bind ?aktivitas
      (ask-question "Bagaimana tingkat aktivitas fisik harian Anda?"
         tinggi sedang rendah))

   ;; Tanya kondisi medis
   (bind ?medis
      (ask-question "Apakah Anda memiliki kondisi medis tertentu?"
         diabetes hipertensi normal))

   ;; Tanya preferensi makanan
   (bind ?preferensi
      (ask-question "Apakah Anda memiliki preferensi makanan khusus?"
         vegetarian biasa))

   ;; Tanya toleransi terhadap laktosa
   (bind ?alergi
      (ask-question "Apakah Anda memiliki alergi terhadap susu (laktosa)?"
         ya tidak))

   (printout t crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t "Menganalisis kebutuhan gizi Anda..." crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)

   ;; Record profil pengguna
   (assert (profil-pengguna
      (tujuan-diet ?tujuan)
      (tingkat-aktivitas ?aktivitas)
      (kondisi-medis ?medis)
      (preferensi-makan ?preferensi)
      (alergi-susu ?alergi))))

;;;*****************************************************
;;;* PREDICTION RULES - Aturan Inferensi Diet          *
;;;*****************************************************

;;; ---- RULE 1: Kondisi Spesifik (Diabetes) ----
;;; Jika pengguna menderita diabetes, rekomendasi harus memprioritaskan kontrol gula darah.
(defrule prediksi-diet-diabetes
   (declare (salience 50))
   (profil-pengguna (kondisi-medis diabetes))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Karbohidrat Kompleks & Rendah Gula (Pendekatan Diabetes)")
      (penjelasan "Karena kondisi diabetes, diet memprioritaskan pengontrolan kadar gula darah. Fokus pada karbohidrat kompleks (oat, quinoa, sayur), hindari gula sederhana, dan perhatikan indeks glikemik makanan Anda."))))

;;; ---- RULE 2: Kondisi Spesifik (Hipertensi) ----
;;; Jika pengguna menderita hipertensi, prioritas pada reduksi natrium
(defrule prediksi-diet-hipertensi
   (declare (salience 45))
   (profil-pengguna (kondisi-medis hipertensi))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet DASH (Dietary Approaches to Stop Hypertension)")
      (penjelasan "Diet DASH dirancang khusus untuk mengelola tekanan darah. Diet ini membatasi asupan natrium (garam) dan meningkatkan porsi sayuran, buah utuh, dan biji-bijian yang kaya kalium dan magnesium."))))

;;; ---- RULE 3: Turun Berat Badan, Vegetarian ----
(defrule prediksi-turun-bb-vegetarian
   (declare (salience 40))
   (profil-pengguna
      (tujuan-diet turun)
      (preferensi-makan vegetarian))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Vegetarian Defisit Kalori")
      (penjelasan "Penerapan defisit kalori digabung pola makan nabati. Anda bisa memenuhi kebutuhan protein dan zat besi dari tempe, tahu, polong-polongan, dan biji-bijian. Serat nabati tinggi membantu kenyang lebih lama."))))

;;; ---- RULE 4: Turun Berat Badan, Alergi Susu ----
(defrule prediksi-turun-bb-alergi
   (declare (salience 35))
   (profil-pengguna
      (tujuan-diet turun)
      (preferensi-makan biasa)
      (alergi-susu ya))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Defisit Kalori Bebas Laktosa")
      (penjelasan "Diet berfokus pada asupan defisit tanpa olahan susu. Asupan kalsium dan probiotik dapat didapat dari bayam, ikan teri, sarden, serta minuman nabati yang sudah difortifikasi."))))

;;; ---- RULE 5: Turun Berat Badan Reguler ----
;;; Fokus defisit kalori normal dengan protein tinggi
(defrule prediksi-turun-bb-biasa
   (declare (salience 30))
   (profil-pengguna
      (tujuan-diet turun)
      (kondisi-medis normal))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Defisit Kalori Kaya Protein (Fat Loss)")
      (penjelasan "Memutar defisit kalori (300-500 kalori lebih sedikit) dengan menjaga asupan protein tinggi (daging bebas lemak, telur). Hal ini menjaga massa otot tidak terbuang selama fase penurunan berat badan."))))

;;; ---- RULE 6: Naik Berat Badan, Aktivitas Tinggi ----
(defrule prediksi-naik-bb-aktivitas-tinggi
   (declare (salience 25))
   (profil-pengguna
      (tujuan-diet naik)
      (tingkat-aktivitas tinggi))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Surplus Kalori Bersih (Clean Bulking)")
      (penjelasan "Surplus kalori difokuskan karena aktivitas tubuh membakar banyak kalori. Kebutuhan diisi oleh protein hewani/nabati berkualitas serta karbohidrat yang padat agar otot berkembang sempurna."))))

;;; ---- RULE 7: Naik Berat Badan Sedang-Rendah (Reguler) ----
(defrule prediksi-naik-bb-biasa
   (declare (salience 20))
   (profil-pengguna
      (tujuan-diet naik))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Surplus Kalori Moderat")
      (penjelasan "Diet ditujukan agar berat naik bukan sekadar lemak, melainkan otot. Konsumsi bahan super padat kalori berkualitas seperti alpukat, selai kacang murni, daging utuh, dan pisang."))))

;;; ---- RULE 8: Menjaga Berat Badan, Vegetarian ----
(defrule prediksi-tetap-vegetarian
   (declare (salience 15))
   (profil-pengguna
      (tujuan-diet tetap)
      (preferensi-makan vegetarian))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Maintenance Nabati Seimbang")
      (penjelasan "Porsi kalori menyesuaikan batas Total Daily Energy Expenditure (TDEE). Menggabungkan berbagai jenis sumber protein nabati sangat dianjurkan untuk mendulang kombinasi asam amino pembangun yang lengkap."))))

;;; ---- RULE 9: Menjaga Berat Badan Reguler ----
(defrule prediksi-tetap-biasa
   (declare (salience 10))
   (profil-pengguna
      (tujuan-diet tetap))
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Mediterania / Gizi Seimbang")
      (penjelasan "Diet ideal untuk mempertahankan kondisi vitalitas prima. Komposisi terbagi atas makronutrien sehat; karbohidrat utuh berpadu lemak sehat seperti olive oil dan konsumsi ikan segar."))))

;;;*****************************************************
;;;* DEFAULT RULE                                      *
;;;*****************************************************

;;; Tangkapan default jika kombinasi rule di atas tidak terpenuhi
(defrule prediksi-default
   (declare (salience 5))
   (profil-pengguna)
   (not (rekomendasi))
   =>
   (assert (rekomendasi
      (hasil "Diet Gizi Universal (Isi Piringku)")
      (penjelasan "Pola makan dengan gizi standar. Terapkan proporsi 1/2 isi piring dari sayur & buah-buahan, 1/4 karbohidrat, dan 1/4 protein. Direkomendasikan evaluasi spesifik dengan nutrisionis."))))

;;;*****************************************************
;;;* OUTPUT RULE                                       *
;;;*****************************************************

(defrule tampilkan-hasil
   (declare (salience 1))
   (profil-pengguna
      (tujuan-diet ?t)
      (tingkat-aktivitas ?a)
      (kondisi-medis ?m)
      (preferensi-makan ?p)
      (alergi-susu ?l))
   (rekomendasi
      (hasil ?hasil)
      (penjelasan ?alasan))
   =>
   (printout t "=============================================" crlf)
   (printout t "       HASIL REKOMENDASI DIET SEHAT" crlf)
   (printout t "=============================================" crlf)
   (printout t crlf)
   (printout t "  Profil Nutrisi Anda:" crlf)
   (printout t "  - Tujuan Berat Badan : " ?t crlf)
   (printout t "  - Tingkat Aktivitas  : " ?a crlf)
   (printout t "  - Kondisi Medis      : " ?m crlf)
   (printout t "  - Preferensi Makanan : " ?p crlf)
   (printout t "  - Alergi Laktosa     : " ?l crlf)
   (printout t crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t "  >> Rekomendasi Program : " ?hasil crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)
   (printout t "  Penjelasan & Anjuran:" crlf)
   (printout t "  " ?alasan crlf)
   (printout t crlf)
   (printout t "=============================================" crlf)
   (printout t "  Tetap semangat dan jaga kesehatan berkelanjutan!" crlf)
   (printout t "=============================================" crlf)
   (printout t crlf))

;;;======================================================
;;;   AKHIR FILE - DietSehat.clp
;;;======================================================
