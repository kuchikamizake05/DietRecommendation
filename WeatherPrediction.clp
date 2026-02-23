;;;======================================================
;;;   Sistem Pakar Prediksi Cuaca Sederhana
;;;   Menggunakan Aturan Berbasis Fakta (Forward Chaining)
;;;
;;;   Deskripsi:
;;;     Sistem ini memprediksi kondisi cuaca berdasarkan
;;;     input pengguna mengenai suhu, kelembapan,
;;;     tekanan udara, kondisi langit, dan kecepatan angin.
;;;
;;;   Prediksi yang tersedia:
;;;     1. Hujan
;;;     2. Cerah
;;;     3. Mendung
;;;     4. Hujan Lebat (Badai)
;;;     5. Berawan Sebagian
;;;
;;;   Cara menjalankan:
;;;     (load "WeatherPrediction.clp")
;;;     (reset)
;;;     (run)
;;;======================================================

;;;*****************************************************
;;;* DEFTEMPLATES - Definisi Struktur Fakta            *
;;;*****************************************************

;;; Template untuk menyimpan atribut cuaca yang diinput pengguna
(deftemplate atribut-cuaca
   (slot suhu)              ; tinggi / sedang / rendah
   (slot kelembapan)        ; tinggi / rendah
   (slot tekanan-udara)     ; tinggi / rendah / normal
   (slot kondisi-langit)    ; cerah / berawan
   (slot kecepatan-angin))  ; kencang / lemah

;;; Template untuk menyimpan hasil prediksi cuaca
(deftemplate prediksi
   (slot hasil)             ; hasil prediksi cuaca
   (slot penjelasan))       ; penjelasan mengapa prediksi tersebut dipilih

;;;*****************************************************
;;;* DEFFUNCTIONS - Fungsi Bantu                       *
;;;*****************************************************

;;; Fungsi untuk menanyakan pertanyaan dengan pilihan jawaban
;;; Parameter:
;;;   ?question  - teks pertanyaan yang ditampilkan
;;;   $?allowed  - daftar jawaban yang diperbolehkan
;;; Return: jawaban yang valid dari pengguna
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
;;;* Salience tinggi agar dijalankan terlebih dahulu   *
;;;*****************************************************

;;; Rule untuk menanyakan semua kondisi cuaca kepada pengguna
;;; Salience 100 memastikan rule ini berjalan pertama kali
(defrule tanya-kondisi-cuaca
   (declare (salience 100))
   (not (atribut-cuaca))
   =>
   (printout t crlf)
   (printout t "=============================================" crlf)
   (printout t "  SISTEM PAKAR PREDIKSI CUACA SEDERHANA" crlf)
   (printout t "=============================================" crlf)
   (printout t crlf)
   (printout t "Jawab pertanyaan berikut untuk memprediksi cuaca." crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)

   ;; Tanya suhu
   (bind ?suhu
      (ask-question "Bagaimana suhu saat ini?"
         tinggi sedang rendah))

   ;; Tanya kelembapan
   (bind ?kelembapan
      (ask-question "Bagaimana kelembapan udara saat ini?"
         tinggi rendah))

   ;; Tanya tekanan udara
   (bind ?tekanan
      (ask-question "Bagaimana tekanan udara saat ini?"
         tinggi rendah normal))

   ;; Tanya kondisi langit
   (bind ?langit
      (ask-question "Bagaimana kondisi langit saat ini?"
         cerah berawan))

   ;; Tanya kecepatan angin
   (bind ?angin
      (ask-question "Bagaimana kecepatan angin saat ini?"
         kencang lemah))

   (printout t crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t "Menganalisis kondisi cuaca..." crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)

   ;; Simpan semua jawaban sebagai fakta
   (assert (atribut-cuaca
      (suhu ?suhu)
      (kelembapan ?kelembapan)
      (tekanan-udara ?tekanan)
      (kondisi-langit ?langit)
      (kecepatan-angin ?angin))))

;;;*****************************************************
;;;* PREDICTION RULES - Aturan Inferensi Prediksi      *
;;;* Salience 50 agar berjalan setelah pengumpulan     *
;;;* fakta dan sebelum menampilkan hasil               *
;;;*****************************************************

;;; ---- RULE 1: Prediksi HUJAN LEBAT (BADAI) ----
;;; Kondisi: suhu tinggi, kelembapan tinggi, tekanan udara rendah,
;;;          langit berawan, angin kencang
(defrule prediksi-hujan-lebat
   (declare (salience 50))
   (atribut-cuaca
      (suhu tinggi)
      (kelembapan tinggi)
      (tekanan-udara rendah)
      (kondisi-langit berawan)
      (kecepatan-angin kencang))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "HUJAN LEBAT (BADAI)")
      (penjelasan "Suhu tinggi dengan kelembapan tinggi menyebabkan banyak uap air. Tekanan udara rendah menandakan sistem cuaca buruk. Langit berawan dan angin kencang mengindikasikan potensi badai."))))

;;; ---- RULE 2: Prediksi HUJAN ----
;;; Kondisi: kelembapan tinggi, tekanan udara rendah, langit berawan
(defrule prediksi-hujan
   (declare (salience 45))
   (atribut-cuaca
      (kelembapan tinggi)
      (tekanan-udara rendah)
      (kondisi-langit berawan))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "HUJAN")
      (penjelasan "Kelembapan tinggi berarti banyak uap air di atmosfer. Tekanan udara rendah menandakan massa udara naik membentuk awan. Langit berawan menunjukkan awan sudah terbentuk dan siap menurunkan hujan."))))

;;; ---- RULE 3: Prediksi HUJAN (alternatif) ----
;;; Kondisi: suhu sedang, kelembapan tinggi, langit berawan, angin kencang
(defrule prediksi-hujan-alt
   (declare (salience 44))
   (atribut-cuaca
      (suhu sedang)
      (kelembapan tinggi)
      (kondisi-langit berawan)
      (kecepatan-angin kencang))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "HUJAN")
      (penjelasan "Suhu sedang dengan kelembapan tinggi dan langit berawan menunjukkan adanya akumulasi awan hujan. Angin kencang dapat membawa awan hujan dari daerah lain."))))

;;; ---- RULE 4: Prediksi HUJAN (alternatif 2) ----
;;; Kondisi: suhu rendah, kelembapan tinggi, tekanan udara rendah
(defrule prediksi-hujan-alt2
   (declare (salience 43))
   (atribut-cuaca
      (suhu rendah)
      (kelembapan tinggi)
      (tekanan-udara rendah))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "HUJAN")
      (penjelasan "Suhu rendah dengan kelembapan tinggi menyebabkan kondensasi uap air. Tekanan udara rendah mendukung pembentukan awan hujan."))))

;;; ---- RULE 5: Prediksi CERAH ----
;;; Kondisi: kelembapan rendah, tekanan udara tinggi, langit cerah
(defrule prediksi-cerah
   (declare (salience 40))
   (atribut-cuaca
      (kelembapan rendah)
      (tekanan-udara tinggi)
      (kondisi-langit cerah))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "CERAH")
      (penjelasan "Kelembapan rendah berarti sedikit uap air di udara. Tekanan udara tinggi menandakan cuaca stabil. Langit cerah menunjukkan tidak ada awan yang menghalangi sinar matahari."))))

;;; ---- RULE 6: Prediksi CERAH (alternatif) ----
;;; Kondisi: suhu tinggi, kelembapan rendah, langit cerah, angin lemah
(defrule prediksi-cerah-alt
   (declare (salience 39))
   (atribut-cuaca
      (suhu tinggi)
      (kelembapan rendah)
      (kondisi-langit cerah)
      (kecepatan-angin lemah))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "CERAH")
      (penjelasan "Suhu tinggi dengan kelembapan rendah dan langit cerah menunjukkan cuaca panas yang stabil. Angin lemah menandakan tidak ada gangguan cuaca."))))

;;; ---- RULE 7: Prediksi CERAH (alternatif 2) ----
;;; Kondisi: suhu sedang, kelembapan rendah, tekanan udara normal, langit cerah
(defrule prediksi-cerah-alt2
   (declare (salience 38))
   (atribut-cuaca
      (suhu sedang)
      (kelembapan rendah)
      (tekanan-udara normal)
      (kondisi-langit cerah))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "CERAH")
      (penjelasan "Suhu sedang dengan kelembapan rendah dan tekanan udara normal menunjukkan kondisi atmosfer yang stabil. Langit cerah menandakan cuaca yang baik."))))

;;; ---- RULE 8: Prediksi MENDUNG ----
;;; Kondisi: kelembapan tinggi, tekanan udara normal, langit berawan, angin lemah
(defrule prediksi-mendung
   (declare (salience 35))
   (atribut-cuaca
      (kelembapan tinggi)
      (tekanan-udara normal)
      (kondisi-langit berawan)
      (kecepatan-angin lemah))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "MENDUNG")
      (penjelasan "Kelembapan tinggi menyebabkan pembentukan awan. Tekanan udara normal menandakan belum ada sistem cuaca buruk. Angin lemah berarti awan cenderung diam dan bertahan. Kondisi ini menghasilkan langit mendung tanpa hujan."))))

;;; ---- RULE 9: Prediksi MENDUNG (alternatif) ----
;;; Kondisi: suhu sedang, kelembapan tinggi, langit berawan
(defrule prediksi-mendung-alt
   (declare (salience 34))
   (atribut-cuaca
      (suhu sedang)
      (kelembapan tinggi)
      (kondisi-langit berawan))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "MENDUNG")
      (penjelasan "Suhu sedang dengan kelembapan tinggi mendukung pembentukan awan di atmosfer. Langit berawan menunjukkan kondisi mendung, namun belum cukup kondisi untuk terjadinya hujan."))))

;;; ---- RULE 10: Prediksi MENDUNG (alternatif 2) ----
;;; Kondisi: suhu rendah, tekanan udara normal, langit berawan
(defrule prediksi-mendung-alt2
   (declare (salience 33))
   (atribut-cuaca
      (suhu rendah)
      (tekanan-udara normal)
      (kondisi-langit berawan))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "MENDUNG")
      (penjelasan "Suhu rendah dengan tekanan udara normal menunjukkan kondisi yang stabil namun cenderung sejuk. Langit berawan mengindikasikan cuaca mendung."))))

;;; ---- RULE 11: Prediksi BERAWAN SEBAGIAN ----
;;; Kondisi: kelembapan rendah, langit berawan, tekanan udara tinggi
(defrule prediksi-berawan-sebagian
   (declare (salience 30))
   (atribut-cuaca
      (kelembapan rendah)
      (kondisi-langit berawan)
      (tekanan-udara tinggi))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "BERAWAN SEBAGIAN")
      (penjelasan "Kelembapan rendah dan tekanan udara tinggi menandakan cuaca stabil, namun langit berawan menunjukkan adanya awan tipis. Kombinasi ini menghasilkan kondisi berawan sebagian."))))

;;; ---- RULE 12: Prediksi BERAWAN SEBAGIAN (alternatif) ----
;;; Kondisi: langit berawan, kelembapan rendah, tekanan udara normal
(defrule prediksi-berawan-sebagian-alt
   (declare (salience 29))
   (atribut-cuaca
      (kelembapan rendah)
      (kondisi-langit berawan)
      (tekanan-udara normal))
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "BERAWAN SEBAGIAN")
      (penjelasan "Kelembapan rendah dengan tekanan udara normal menunjukkan kondisi atmosfer yang cukup stabil. Langit berawan mengindikasikan adanya awan, namun tidak tebal sehingga cuaca berawan sebagian."))))

;;;*****************************************************
;;;* DEFAULT RULE - Prediksi Default                   *
;;;* Salience rendah agar menjadi pilihan terakhir     *
;;;*****************************************************

;;; Rule default jika tidak ada rule prediksi lain yang cocok
(defrule prediksi-default
   (declare (salience 10))
   (atribut-cuaca)
   (not (prediksi))
   =>
   (assert (prediksi
      (hasil "TIDAK DAPAT DITENTUKAN")
      (penjelasan "Kombinasi kondisi cuaca yang diberikan tidak cocok dengan pola cuaca yang dikenali oleh sistem. Silakan konsultasikan dengan prakiraan cuaca resmi untuk informasi lebih lanjut."))))

;;;*****************************************************
;;;* OUTPUT RULE - Menampilkan Hasil Prediksi          *
;;;* Salience paling rendah agar berjalan terakhir     *
;;;*****************************************************

;;; Rule untuk menampilkan hasil prediksi akhir
;;; Hanya akan berjalan setelah prediksi telah ditentukan
(defrule tampilkan-hasil
   (declare (salience 1))
   (atribut-cuaca
      (suhu ?s)
      (kelembapan ?k)
      (tekanan-udara ?t)
      (kondisi-langit ?l)
      (kecepatan-angin ?a))
   (prediksi
      (hasil ?hasil)
      (penjelasan ?alasan))
   =>
   (printout t "=============================================" crlf)
   (printout t "         HASIL PREDIKSI CUACA" crlf)
   (printout t "=============================================" crlf)
   (printout t crlf)
   (printout t "  Data Input:" crlf)
   (printout t "  - Suhu           : " ?s crlf)
   (printout t "  - Kelembapan     : " ?k crlf)
   (printout t "  - Tekanan Udara  : " ?t crlf)
   (printout t "  - Kondisi Langit : " ?l crlf)
   (printout t "  - Kecepatan Angin: " ?a crlf)
   (printout t crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t "  >> Prediksi Cuaca: " ?hasil crlf)
   (printout t "---------------------------------------------" crlf)
   (printout t crlf)
   (printout t "  Penjelasan:" crlf)
   (printout t "  " ?alasan crlf)
   (printout t crlf)
   (printout t "=============================================" crlf)
   (printout t "  Terima kasih telah menggunakan sistem ini!" crlf)
   (printout t "=============================================" crlf)
   (printout t crlf))

;;;======================================================
;;;   AKHIR FILE - WeatherPrediction.clp
;;;======================================================