// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a id locale. All the
// messages from the main program should be duplicated here with the same
// function name.

// Ignore issues from commonly used lints in this file.
// ignore_for_file:unnecessary_brace_in_string_interps, unnecessary_new
// ignore_for_file:prefer_single_quotes,comment_references, directives_ordering
// ignore_for_file:annotate_overrides,prefer_generic_function_type_aliases
// ignore_for_file:unused_import, file_names, avoid_escaping_inner_quotes
// ignore_for_file:unnecessary_string_interpolations, unnecessary_string_escapes

import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';

final messages = new MessageLookup();

typedef String MessageIfAbsent(String messageStr, List<dynamic> args);

class MessageLookup extends MessageLookupByLibrary {
  String get localeName => 'id';

  static String m0(deviceName, os) =>
      "Akun Anda baru saja masuk di ${deviceName} (${os}). Jika bukan Anda, kami sarankan untuk mengubah kata sandi Anda.";

  static String m1(price) => "Harga saat ini: \$${price}";

  static String m2(symbol) => "Peringatan Harga · ${symbol}";

  static String m3(s) => "Kirim ulang dalam ${s}s";

  static String m4(message) => "Pembelian gagal: ${message}";

  static String m5(productId) => "Pembelian berhasil: ${productId}";

  static String m6(productId) => "Dipulihkan: ${productId}";

  static String m7(value) => "Jumlah lebih dari ${value}.";

  static String m8(value) =>
      "Dompet sudah ada, nama dompet adalah \"${value}\"";

  static String m9(value) => "Masukkan jumlah lebih dari ${value}.";

  static String m10(value) => "Alamat duplikat di baris ${value}";

  static String m11(value) =>
      "Saldo tidak mencukupi: jumlah total akan melebihi ${value} yang tersedia";

  static String m12(value) => "Alamat tidak valid di baris ${value}";

  static String m13(value) => "Jumlah tidak valid di baris ${value}";

  static String m14(value) => "Maksimal ${value} penerima";

  static String m15(token) => "Setujui ${token} untuk melanjutkan";

  static String m16(impact) =>
      "Dampak harga tinggi (${impact})! Lanjutkan dengan hati-hati.";

  static String m17(secs) => "Penawaran berakhir dalam ${secs}s";

  static String m18(value) => "Hasilkan hingga ${value}% APY";

  static String m19(value) => "Segarkan otomatis setiap ${value} detik";

  static String m20(address) => "Akun ${address} ditambahkan";

  static String m21(address, network) =>
      "Apakah Anda ingin melacak akun hardware wallet ini?\n\nAlamat: ${address}\nJaringan: ${network}";

  static String m22(app) => "Aplikasi saat ini: ${app}";

  static String m23(days) => "${days} hari yang lalu";

  static String m24(value) => "Gagal mengimpor akun: ${value}";

  static String m25(date) => "Terakhir terhubung: ${date}";

  static String m26(app) => "Pastikan aplikasi ${app} terbuka di Ledger Anda";

  static String m27(name) =>
      "Apakah Anda yakin ingin menghapus \"${name}\" dari perangkat yang disimpan?";

  static String m28(value) => "Dapatkan ${value} poin";

  static String m29(amount, symbol, network) =>
      "Minta ${amount} ${symbol} di ${network}";

  static String m30(value) =>
      "Hapus jaringan kustom ${value}? Saldo pada jaringan ini tidak akan ditampilkan lagi. Aset Anda di blockchain tidak terpengaruh.";

  static String m31(value) => "Perkiraan. gas: ~ unit ${value}";

  static String m32(reason) => "Alasan: ${reason}";

  static String m33(value) => "${value}d terlepas";

  static String m34(value) => "${value} hari tersisa";

  static String m35(value) =>
      "Penghapusan staking membutuhkan waktu ${value} hari. Token Anda akan dikunci selama periode ini.";

  static String m36(value) => "Anda tidak memiliki cukup \"${value}\"";

  static String m37(value) => "Gagal mendapatkan akun \"${value}\"";

  static String m38(value) => "Minimum ${value} XRP untuk transfer pertama";

  static String m39(count) => "Tambahkan (${count})";

  static String m40(count) =>
      "${Intl.plural(count, one: '1 token baru terdeteksi', other: '${count} token baru terdeteksi')} — ketuk untuk meninjau";

  static String m41(value) => "Jaringan ${value} belum ditambahkan.";

  static String m42(value) =>
      "${value} memiliki transaksi yang belum selesai, silakan coba lagi nanti.";

  static String m43(value) => "Tidak ditemukan alamat untuk ${value}.";

  static String m44(value) => "Saldo ${value} tidak mencukupi.";

  static String m45(value, value1) =>
      "Setiap akun XRP harus mencadangkan ${value} XRP (${value1} drops) sebagai dasar, yang tidak dapat dibelanjakan.";

  static String m46(value, value1) =>
      "Untuk setiap objek yang dimiliki akun, ${value} XRP (${value1} drops) ditambahkan ke cadangan.";

  static String m47(value, value1) =>
      "Akun ini memiliki ${value} objek, yang berarti tambahan ${value1} XRP dicadangkan.";

  static String m48(message) => "Gagal masuk ruang\n${message}";

  static String m49(value) => "Pola salah, tersisa ${value} percobaan";

  static String m50(value) => "Pola salah, tersisa ${value} percobaan";

  static String m51(value) =>
      "Anda telah berhasil menyiapkan ${value} dan akan memulai verifikasi dengan N42Wallet!";

  static String m52(value) =>
      "Bergabung dengan grup ${value} saya di @N42Wallet untuk menjadi penambang awal dari blockchain Layer 1, dan dapatkan kripto di ponsel Anda!";

  static String m53(value, value1) =>
      "Apakah Anda yakin ingin mengunci ${value} N hingga ${value1} untuk menjalankan node?";

  static String m54(value) => "Impor gagal:${value}";

  static String m55(value) =>
      "Dibutuhkan saldo staking minimal ${value} untuk mendapatkan hadiah.";

  static String m56(value, value1) =>
      "${value} N setiap ${value1} blok ditambang";

  static String m57(value) => "Harus ${value} karakter";

  static String m58(symbol) => "Jumlah (${symbol})";

  static String m59(amount, symbol) => "Saldo: ${amount} ${symbol}";

  static String m60(label) =>
      "Nyatakan “${label}” menang dan selesaikan? Tidak bisa dibatalkan.";

  static String m61(n) => "${n} mnt";

  static String m62(n) => "Hasil ${n}";

  static String m63(label, pct) => "${label} menang (${pct}%)";

  static String m64(shares, avg, after) =>
      "Est. ${shares} bagian · rata ${avg}% · setelah ${after}%";

  static String m65(reason) => "Penebusan gagal: ${reason}";

  static String m66(label) => "Hasil: ${label}";

  static String m67(n) => "Jual ${n}";

  static String m68(value) => "Saldo ${value} Tidak Mencukupi.";

  static String m69(value) => "${value} masuk...";

  static String m70(value) =>
      "${value} yang di-swap dalam aplikasi akan segera didistribusikan ke dompet Anda dan tidak dapat dijual melalui proses ini. Dapat digunakan untuk menjalankan node.";

  static String m71(value) => "Maksimal ${value} karakter";

  static String m72(value) => "Jaringan ${value} sudah didukung APP!";

  static String m73(value) =>
      "Jaringan ${value} sudah didukung APP, apakah Anda ingin menambahkannya?";

  static String m74(value) => "Uji tautan alamat ${value} gagal!";

  static String m75(value) =>
      "RPC melaporkan ID Jaringan ${value}, yang tidak sesuai dengan nilai yang Anda masukkan.";

  static String m76(asset, contract, address) =>
      "Aset ${asset} (${contract}) belum ditambahkan ke akun ${address}.";

  static String m77(imported, skipped) =>
      "Dompet yang diimpor: ${imported}. Dilewati: ${skipped}.";

  static String m78(value) => "Saldo: ${value}";

  static String m79(value) => "Biaya Dasar: ${value} Gwei";

  static String m80(value) =>
      "Papan klip akan dihapus otomatis dalam ${value}s";

  static String m81(value) => "Baris ${value}: bidang yang hilang";

  static String m82(value) => "${value}h";

  static String m83(value) => "Terhubung ke ${value}";

  static String m84(value) => "Gas: ${value}";

  static String m85(value) => "${value}j";

  static String m86(value) => "Penerima yang valid (${value})";

  static String m87(quote, base) => "Harga Batas (${quote} per ${base})";

  static String m88(value) => "Batas ${value}";

  static String m89(value) => "Pasar (${value})";

  static String m90(value) => "Saldo minimum: ${value}";

  static String m91(value) => "Pesanan (${value})";

  static String m92(value) => "Posisi (${value})";

  static String m93(value) => "Penerima: ${value}";

  static String m94(value) => "Token ditemukan: ${value}";

  static String m95(value) => "Token: ${value}";

  static String m96(value) => "Transaksi: ${value}";

  static String m97(valid, issues) => "Valid: ${valid}. Masalah: ${issues}.";

  static String m98(value) => "… dan ${value} masalah lainnya";

  static String m99(volume, interest) => "Vol: ${volume} · OI: ${interest}";

  static String m100(value) => "Dompet ${value}";

  static String m101(value) => "Diperbarui ${value} jam lalu";

  static String m102(value) => "Diperbarui ${value} menit lalu";

  static String m103(value) => "0~${value} karakter";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Sunting"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verifikasi"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informasi Alamat",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Berhasil disalin"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Salin Alamat"),
    "descO": MessageLookupByLibrary.simpleMessage("Deskripsi (Opsional)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Ubah Kata Sandi",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Mengerti"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Login Perangkat Baru",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Mengajukan"),
    "g_aggregate_cached_balance": MessageLookupByLibrary.simpleMessage(
      "Saldo tersimpan · gagal memperbarui",
    ),
    "g_aggregate_known_balance": MessageLookupByLibrary.simpleMessage(
      "Saldo yang diketahui",
    ),
    "g_aggregate_mainnet_note": MessageLookupByLibrary.simpleMessage(
      "Hanya saldo mainnet. Kueri jaringan yang tidak tersedia atau gagal tidak dihitung sebagai saldo nol.",
    ),
    "g_aggregate_network_balances": MessageLookupByLibrary.simpleMessage(
      "Saldo berdasarkan jaringan",
    ),
    "g_aggregate_no_mainnet": MessageLookupByLibrary.simpleMessage(
      "Tidak ada akun utama aktif untuk jaringan ini",
    ),
    "g_aggregate_not_loaded": MessageLookupByLibrary.simpleMessage(
      "Saldo belum dimuat",
    ),
    "g_aggregate_open_network": MessageLookupByLibrary.simpleMessage(
      "Buka jaringan",
    ),
    "g_aggregate_unavailable": MessageLookupByLibrary.simpleMessage(
      "Aset ini tidak lagi tersedia di dompet yang dipilih. Kembali ke dompet untuk memilih aset.",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Pergi ke Atas ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Turun Di Bawah ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Beritahu saya kapan harganya",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Aktifkan peringatan ini",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan harga valid yang lebih besar dari 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Hapus"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Setel Peringatan"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Harga target (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Perbarui Peringatan",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Token hanya dapat dikirim dalam jaringan yang sama. Pengiriman dari jaringan lain dapat mengakibatkan kehilangan.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Pindai untuk menerima",
    ),
    "g_audit_aa_history_external": MessageLookupByLibrary.simpleMessage(
      "Buka penjelajah blok untuk melihat aktivitas on-chain akun cerdas ini.",
    ),
    "g_audit_about_desc": MessageLookupByLibrary.simpleMessage(
      "Versi, situs web, dan dukungan",
    ),
    "g_audit_activity_error": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat memuat riwayat transaksi.",
    ),
    "g_audit_activity_local": MessageLookupByLibrary.simpleMessage(
      "Riwayat transaksi lokal di seluruh dompet Anda. Buka aset untuk menyinkronkan aktivitas terbaru.",
    ),
    "g_audit_all": MessageLookupByLibrary.simpleMessage("Semua"),
    "g_audit_approval_spender": MessageLookupByLibrary.simpleMessage(
      "Izin pengeluaran untuk",
    ),
    "g_audit_approval_token": MessageLookupByLibrary.simpleMessage(
      "Kontrak token",
    ),
    "g_audit_batch": MessageLookupByLibrary.simpleMessage("Transfer massal"),
    "g_audit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Kirim ke banyak penerima atau impor file CSV",
    ),
    "g_audit_biometrics": MessageLookupByLibrary.simpleMessage(
      "Autentikasi biometrik",
    ),
    "g_audit_biometrics_desc": MessageLookupByLibrary.simpleMessage(
      "Pengaturan Face ID / sidik jari",
    ),
    "g_audit_connections_desc": MessageLookupByLibrary.simpleMessage(
      "Kelola sesi; memutuskan koneksi tidak mencabut persetujuan token.",
    ),
    "g_audit_currency": MessageLookupByLibrary.simpleMessage(
      "Mata uang tampilan",
    ),
    "g_audit_currency_usd": MessageLookupByLibrary.simpleMessage(
      "Nilai portofolio saat ini ditampilkan dalam dolar AS.",
    ),
    "g_audit_defi_error": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat memuat posisi DeFi. Ketuk untuk mencoba lagi.",
    ),
    "g_audit_defi_loading": MessageLookupByLibrary.simpleMessage(
      "Memuat posisi DeFi...",
    ),
    "g_audit_defi_positions": MessageLookupByLibrary.simpleMessage(
      "Posisi DeFi",
    ),
    "g_audit_display_language": MessageLookupByLibrary.simpleMessage(
      "Bahasa tampilan aplikasi",
    ),
    "g_audit_encrypted_backup": MessageLookupByLibrary.simpleMessage(
      "Ekspor cadangan dompet yang terenkripsi",
    ),
    "g_audit_funding": MessageLookupByLibrary.simpleMessage(
      "Tingkat pendanaan saat ini",
    ),
    "g_audit_gas": MessageLookupByLibrary.simpleMessage("Pelacak gas"),
    "g_audit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Biaya jaringan dan pemberitahuan harga",
    ),
    "g_audit_hardware": MessageLookupByLibrary.simpleMessage(
      "Dompet perangkat keras",
    ),
    "g_audit_load_more": MessageLookupByLibrary.simpleMessage(
      "Muat lebih banyak",
    ),
    "g_audit_mainnet": MessageLookupByLibrary.simpleMessage("Jaringan utama"),
    "g_audit_manage_settings": MessageLookupByLibrary.simpleMessage(
      "Kelola dompet dan preferensi Anda",
    ),
    "g_audit_manage_wallets": MessageLookupByLibrary.simpleMessage(
      "Buat, impor, dan kelola dompet",
    ),
    "g_audit_mark_price": MessageLookupByLibrary.simpleMessage("Harga mark"),
    "g_audit_max_leverage": MessageLookupByLibrary.simpleMessage(
      "Leverage maksimum",
    ),
    "g_audit_network_desc": MessageLookupByLibrary.simpleMessage(
      "Kelola jaringan dan titik akhir RPC",
    ),
    "g_audit_open_interest": MessageLookupByLibrary.simpleMessage(
      "Posisi terbuka",
    ),
    "g_audit_oracle_price": MessageLookupByLibrary.simpleMessage(
      "Harga oracle",
    ),
    "g_audit_protect_wallet": MessageLookupByLibrary.simpleMessage(
      "Autentikasi dan perlindungan dompet",
    ),
    "g_audit_quote_changed": MessageLookupByLibrary.simpleMessage(
      "Tawaran harga swap berubah atau kedaluwarsa. Tinjau tawaran harga swap terbaru sebelum konfirmasi.",
    ),
    "g_audit_rate": MessageLookupByLibrary.simpleMessage("Beri penilaian N42"),
    "g_audit_rate_desc": MessageLookupByLibrary.simpleMessage(
      "Buka toko aplikasi",
    ),
    "g_audit_saved_addresses": MessageLookupByLibrary.simpleMessage(
      "Alamat penerima yang telah disimpan",
    ),
    "g_audit_show_less": MessageLookupByLibrary.simpleMessage(
      "Tampilkan lebih sedikit",
    ),
    "g_audit_testnet": MessageLookupByLibrary.simpleMessage("jaringan uji"),
    "g_audit_theme_desc": MessageLookupByLibrary.simpleMessage(
      "Tampilan dan mode tampilan",
    ),
    "g_audit_volume": MessageLookupByLibrary.simpleMessage(
      "Volume 24 jam (USD)",
    ),
    "g_audit_wallet_management": MessageLookupByLibrary.simpleMessage(
      "Manajemen dompet",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Masukkan deskripsi",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Peramban"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Hapus Cache Browser",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Hubungkan DApp secara otomatis",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Tutup semua"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Selesai"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Riwayat"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Hapus Semua Riwayat",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Hapus semua riwayat penjelajahan?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("Riwayat dihapus"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Hari ini"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Kemarin"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Jelajahi DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Populer"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Jembatan"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Bookmark"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Alat"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Belum ada bookmark yang ditambahkan",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Penanda buku"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nama"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan Nama",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Deskripsi"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Setuju"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Pesan telah dihapus",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transaksi"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Hubungkan"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Jaringan Tersedia",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Tanda tangan pesan",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Menghubungkan"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Memasangkan, harap tunggu.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Putuskan"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Tolak"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("Diblokir"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage(
      "Perhatian",
    ),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Aman"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Terverifikasi",
    ),
    "g_dex_account_unavailable": MessageLookupByLibrary.simpleMessage(
      "Pilih dompet utama yang dapat digunakan untuk jaringan ini. Akun hanya untuk dipantau tidak dapat menandatangani pertukaran.",
    ),
    "g_dex_execution_invalid": MessageLookupByLibrary.simpleMessage(
      "Parameter transaksi tidak valid atau eksekusi gagal. Muat ulang penawaran harga pertukaran dan coba lagi.",
    ),
    "g_dex_history_record_failed": MessageLookupByLibrary.simpleMessage(
      "Pertukaran telah dikirim, tetapi riwayat tidak dapat diperbarui. Jangan kirim lagi.",
    ),
    "g_dex_smart_account_fees": MessageLookupByLibrary.simpleMessage(
      "Biaya jaringan dibayar oleh akun cerdas ini.",
    ),
    "g_dex_spending_account": MessageLookupByLibrary.simpleMessage(
      "Akun pengeluaran",
    ),
    "g_dex_use_smart_account": MessageLookupByLibrary.simpleMessage(
      "Gunakan akun cerdas",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Kirim ulang kode"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Tips Pemindaian Biometrik",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Pindai sidik jari atau wajah Anda untuk autentikasi.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Kiat"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Atur"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Pindai wajah atau sidik jari Anda untuk melanjutkan.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Kembali"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Pindai kode QR dengan aplikasi Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Atau masukkan kunci secara manual:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Masukkan kode verifikasi 6 digit",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator diperlukan untuk mengonfirmasi setiap transfer.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Kode salah, coba lagi",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator belum dikonfigurasi",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Pengikatan berhasil",
    ),
    "g_history_clear_dates": MessageLookupByLibrary.simpleMessage(
      "Hapus tanggal",
    ),
    "g_history_export_all": MessageLookupByLibrary.simpleMessage(
      "Ekspor catatan lokal yang sesuai (CSV)",
    ),
    "g_history_export_error": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat mengekspor riwayat transaksi. Silakan coba lagi.",
    ),
    "g_history_local_scope": MessageLookupByLibrary.simpleMessage(
      "Filter dan ekspor CSV mencakup semua catatan yang sesuai yang disimpan di perangkat ini. Buka aset untuk menyinkronkan aktivitas di blockchain yang lebih baru.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Berita"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verifikasi"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Undang teman"),
    "g_home_market": MessageLookupByLibrary.simpleMessage("Pasar"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Dibatalkan"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Periksa koneksi jaringan Anda dan coba lagi",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Tidak ada produk tersedia",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Pulihkan Pembelian"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Memulihkan pembelian…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Coba lagi"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Toko tidak tersedia",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Beli"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Gagal menghapus!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Batas gas"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Tidak ada lagi"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Memuat "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Buku Alamat"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Impor dompet"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Kelola"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Alamat baru"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Hapus"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Simpan"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Salin"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Buat/Impor dompet"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Tema"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Sistem"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Terang"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Gelap"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Daftar Dompet"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Tidak ada data"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Jumlah tidak valid"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Dompet Utama"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaksi berhasil"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Kata sandi salah"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("jaringan uji"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Jaringan utama"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Bahasa sistem"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Atur sebagai Dompet Utama",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Alamat dompet"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Pindai untuk menyalin alamat",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Tambah"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Pilih Dompet untuk Verifikasi",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Simbol"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Tempel"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Pilih Jaringan"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Transaksi gagal"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Ini adalah alamat dompet saya",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Lainnya"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Berhasil disimpan"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Berhasil"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Apakah Anda yakin ingin menghapus dompet?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Aktif"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Tidak ada izin untuk mengakses kamera.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Penjelajah"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Maks"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Aset"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Buku besar kosong!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Ringkasan Transaksi"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Kesalahan tautan, pindai kode QR lagi.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Ubah Kata Sandi"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Kata Sandi Lama"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("Menyinkronkan saldo..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Kunci Pribadi"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Masukkan kata sandi dompet",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage(
      "Kesalahan kunci pribadi",
    ),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Informasi Pasar"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Kata sandi tidak cocok."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Gagal menambahkan!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Terima"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Pemindahan"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Ke"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Pindai kode QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Masukkan alamat dompet"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Saldo Tersedia"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Jumlah"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Saldo tidak mencukupi untuk transaksi ini.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Kirim"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Gagal memuat!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Dompet"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Buat"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Dari"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Konfirmasi"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Batal"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Semua token"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Pengaturan"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Akun Berhasil Dibuat",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Detail Akun",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("Nama Akun"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Masukkan nama akun",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("Jenis Akun"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Aktif"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Tambahkan operasi pertama Anda",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Tambahkan Operasi",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Menghitung alamat...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Gagal menghitung alamat. Silakan coba lagi.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Menyetujui"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("kumpulan"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Eksekusi Atom",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Jalankan beberapa operasi sekaligus",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Kirim banyak transaksi dalam satu operasi",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Eksekusi batch gagal",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Tidak ada templat yang disimpan",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Operasi Batch",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Hemat Gas",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Simpan sebagai Templat",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Mengirimkan...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch berhasil dikirimkan",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Muat Templat",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nama Templat",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Masukkan nama templat",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Templat disimpan",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Templat"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transaksi Batch",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Setujui dan tukar dalam satu transaksi — tidak ada lagi konfirmasi dua langkah",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Tindakan Batch Sekali Klik",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsor transaksi atau bayar biaya dengan token ERC-20, bukan ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Bayar Gas dengan Token Apa Pun",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Pulihkan akses melalui kontak tepercaya jika Anda kehilangan kunci pribadi",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Pemulihan Sosial",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Akun pintar ERC-7579 modular dengan dukungan transaksi tanpa gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("oleh"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Rantai"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("ID Rantai"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Perubahan"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Periksa Status",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Segera Hadir",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Ini adalah alamat kontrafaktual. Ini akan diterapkan pada transaksi pertama Anda.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Buat Akun Cerdas",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Buat akun pintar pertama Anda",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Buat Kunci Sesi",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Dibuat"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Adat"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Akun akan dikerahkan secara otomatis pada transaksi pertama Anda",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Dikerahkan"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Menyebarkan...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Penerapan akan terjadi secara otomatis dengan transaksi pertama Anda.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Rasakan akun Ethereum generasi berikutnya dengan fitur yang ditingkatkan",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Detail"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "EOA Hibrid/Akun Cerdas - Tidak diperlukan penerapan",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Kesalahan"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Perkiraan Gas",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Jalankan Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Pabrik"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATIS"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Perkiraan gas gagal, menggunakan default",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Pembayaran Gas",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opsi Pembayaran Gas",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Disponsori Gas",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Tanpa gas"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transaksi tanpa gas & operasi batch",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Akun modular dengan dukungan plugin dari ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Label"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Aktivitas Terakhir",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Akun Cerdas Saya",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Belum ada akun pintar",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Tidak ada akun yang cocok dengan filter Anda",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Tidak ada operasi yang ditambahkan",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Tidak ada kunci sesi",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Tidak Dikerahkan",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Buat akun pintar (gratis, tidak perlu ETH)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Danai — terima token EVM apa pun",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Bertransaksi tanpa gas dengan Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operasi"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Pemilik"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Bayar bensin dengan token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Bayar bahan bakar dengan ETH Anda",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Bayar dengan"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Bayar dengan ETH",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "chain didukung",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Memeriksa ketersediaan...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Cakupan Chain",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Pilih bagaimana Anda ingin membayar biaya gas transaksi",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Perkiraan biaya",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal memuat opsi gas",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Coba lagi",
    ),
    "g_key_aa_paymaster_unavailable": MessageLookupByLibrary.simpleMessage(
      "Sponsor gas belum tersedia. Harap bayar biaya gas dengan saldo akun Anda.",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Tertunda"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Izin"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Alamat Pratinjau",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Siap"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Terima Alamat",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Coba lagi"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Cabut"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Apakah Anda yakin ingin mencabut kunci sesi ini? DApp resmi tidak lagi dapat melakukan transaksi.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Cabut Kunci Sesi",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Kunci sesi dicabut",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Dicabut"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Mencabut kunci sesi...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Akun multi-tanda tangan dengan fitur keamanan tingkat lanjut",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("disimpan"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Pilih Rantai",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Pilih Pembayar",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Dipilih"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Kirim token menggunakan akun pintar Anda",
    ),
    "g_key_aa_send_failed": MessageLookupByLibrary.simpleMessage(
      "Transaksi gagal",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 Hari"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 Jam"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 Hari"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 Hari"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "contoh: 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Jumlah Maks.",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Saya memahami izin kunci ini",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Berinteraksi dengan kontrak DApp yang disetujui",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal membuat kunci sesi",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Kunci sesi berhasil dibuat",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "contoh: Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Label / Nama DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Detail Kunci Sesi",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Berlaku Selama",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Risiko tinggi — hanya DApp terpercaya",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage("Kunci Sesi"),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Otorisasi DApps dengan akses sementara ke akun pintar Anda",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Akses DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Kontrol Penuh",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Hanya Kirim",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Risiko Tinggi",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Risiko Rendah",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Risiko Sedang",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Tinjau izin sebelum mengonfirmasi",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Pilih Tingkat Izin",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Transfer token dalam batas yang ditentukan",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Akun pintar dasar dengan pemilik tunggal - direkomendasikan untuk sebagian besar pengguna",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Akun Cerdas",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Dompet Cerdas",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Batas Pembelanjaan",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Disponsori (Gratis)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Akun Cerdas"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Jumlah Gas"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Transaksi"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Lihat Semua"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Alamat"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan nama",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan alamat",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Silakan pilih jenis koin",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Edit alamat"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage("Berhasil dihapus"),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Pilih Koin"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Cari koin"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Fitur Lanjutan",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Aktif"),
    "g_key_airdrop_discover": MessageLookupByLibrary.simpleMessage("Temukan"),
    "g_key_airdrop_distribute": MessageLookupByLibrary.simpleMessage("Bagikan"),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Berakhir"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Tidak ada kampanye yang diverifikasi tersedia",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("Tertunda"),
    "g_key_airdrop_sources": MessageLookupByLibrary.simpleMessage("Sumber"),
    "g_key_airdrop_sources_hint": MessageLookupByLibrary.simpleMessage(
      "Buka Sumber untuk menelusuri direktori kampanye yang dikelola pihak penyedia.",
    ),
    "g_key_airdrop_thirdparty_warning": MessageLookupByLibrary.simpleMessage(
      "Kampanye pihak ketiga bisa jadi berbahaya. Verifikasi domain proyek dan detail transaksi sebelum menandatangani.",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage("Airdrop"),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage(
      "Akan Datang",
    ),
    "g_key_badge_hot": MessageLookupByLibrary.simpleMessage("POPULER"),
    "g_key_badge_live": MessageLookupByLibrary.simpleMessage("LANGSUNG"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Tambah Penerima",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Penyiaran...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Hapus Semua",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Transfer Batch",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Lanjutkan"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Format CSV: alamat,jumlah,label",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Selesai"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Memperkirakan Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Transfer batch hanya mendukung rantai EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Ekspor CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Bantuan Transfer Batch",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage("Impor CSV"),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo bersifat opsional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Gunakan Multicall3 untuk biaya bahan bakar yang lebih rendah",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Tidak ada token yang didukung",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("Penerima"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Pilih Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Kirim token ke beberapa alamat dalam satu transaksi",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "Penandatanganan...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Gesek ke kiri untuk menghapus penerima",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transfer Massal",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Jumlah Total",
    ),
    "g_key_block_explorer_optional": MessageLookupByLibrary.simpleMessage(
      "URL Penjelajah Blok (opsional)",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Rantai tidak didukung",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Termurah"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Anda akan menerima (estimasi)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Tercepat"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Dapatkan Penawaran",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Riwayat Bridge",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Tidak ada rute tersedia",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Direkomendasikan",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Segarkan"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Rute"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Cari chain...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Pilih"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Pilih Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Selipan"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Selesai",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("Gagal"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "Sedang Berlangsung",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Tertunda",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Jembatan"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Bridge Gagal",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transaksi Tertunda",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Bridge Berhasil",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Terkunci sampai",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Verifikasikan periode kunci telah berakhir sebelum mengirimkan penukaran Anda.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC masih terkunci",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Tukarkan vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Tidak terkunci — siap untuk ditebus",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Saya memahami risikonya dan ingin melanjutkan",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Lanjutkan untuk Mempertaruhkan",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Cara Kerjanya",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC akan dikunci hingga timelock berakhir. Selesaikan proses staking pada antarmuka di bawah ini.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "BTC Anda akan dikunci selama periode staking penuh. Penarikan lebih awal tidak dimungkinkan.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Kunci ini diterapkan oleh Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) dan tidak dapat dilewati.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Risiko kontrak pintar: meskipun telah diaudit, tidak ada protokol yang sepenuhnya bebas risiko.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Taruhan minimum: 0,001 BTC. Periode penguncian minimum: 0,125 hari (~3 jam).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Peringatan Resiko",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "BTC Anda dikunci dalam alamat multisig 2-dari-2 dengan kunci waktu (CLTV), diamankan dengan kunci Anda dan kunci tabung N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Kunci BTC Anda",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Setelah konfirmasi on-chain, vBTC dicetak ke dompet Anda dengan rasio 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Mencetak vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Tahan vBTC untuk mendapatkan hadiah staking. vBTC juga dapat digunakan dalam protokol DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Dapatkan Hadiah",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Ketika periode penguncian berakhir, bakar vBTC Anda untuk menerima kembali BTC asli Anda.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Tukarkan Setelah Buka Kunci",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Taruhan Penitipan Mandiri BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Mengerti"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Pilih token dengan dukungan NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Buka tab NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Pilih NFT yang ingin Anda bakar",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Ketuk tombol \"Bakar\".",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage(
      "Langkah-langkah:",
    ),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Untuk membakar NFT, silakan buka halaman detail NFT dan ketuk tombol \"Bakar\".",
    ),
    "g_key_chain_presets": MessageLookupByLibrary.simpleMessage(
      "Jaringan populer (ketuk untuk mengisi)",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Jaringan ini belum mendukung transfer, pantau terus",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Semua aset di bawah \$1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Aset lainnya",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Ketuk untuk menampilkan semua",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage(
      "Baru-baru ini",
    ),
    "g_key_dapp_connect_account": MessageLookupByLibrary.simpleMessage("Akun"),
    "g_key_dapp_connect_desc": MessageLookupByLibrary.simpleMessage(
      "Situs ini meminta izin untuk melihat alamat dompet Anda dan menyarankan transaksi. Situs ini tidak dapat menggerakkan dana tanpa persetujuan Anda.",
    ),
    "g_key_dapp_connect_title": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Dompet",
    ),
    "g_key_device_security_warning_message": MessageLookupByLibrary.simpleMessage(
      "Perangkat ini tampaknya telah di-root atau di-jailbreak. Menggunakan dompet di perangkat yang telah dirusak meningkatkan risiko pencurian kunci dan akses tidak sah. Lanjutkan dengan hati-hati.",
    ),
    "g_key_device_security_warning_title": MessageLookupByLibrary.simpleMessage(
      "Peringatan Keamanan Perangkat",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Disetujui! Ketuk Tukar untuk melanjutkan.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Jumlah Tepat",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Tak Terbatas",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Persetujuan tak terbatas: router dapat membelanjakan token ini kapan saja. Praktik standar, namun berisiko jika kontrak disusupi.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Menyetujui…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Rute Terbaik",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Sumber Terbaik",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Jaringan"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimasi Gas",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Riwayat DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Minimal. Diterima",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage(
      "Tidak ada token",
    ),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Tidak ada token ditemukan",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Grafik harga",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Dampak Harga",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Kutipan gagal",
    ),
    "g_key_dex_quote_unavailable": MessageLookupByLibrary.simpleMessage(
      "Layanan penawaran harga pertukaran tidak tersedia sementara. Silakan coba lagi nanti.",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cari simbol / nama / alamat",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Pilih"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Selipan Maks",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Dikonfirmasi",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Gagal"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "Tertunda",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Dikutip"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Tukar"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap berhasil dikirim",
    ),
    "g_key_dex_tokens_offline": MessageLookupByLibrary.simpleMessage(
      "Layanan token tidak tersedia. Menampilkan daftar terbatas secara offline.",
    ),
    "g_key_dex_untrusted_router": MessageLookupByLibrary.simpleMessage(
      "Pertukaran diblokir: alamat router tidak dikenali. Untuk keamanan Anda, transaksi ini dibatalkan.",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Anda Membayar"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Anda Terima",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Produk Aktif",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("Transfer Batch"),
    "g_key_earn_best_apy": MessageLookupByLibrary.simpleMessage("APY Terbaik"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Bakar"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Beli N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Beli N dengan protokol N42",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Temukan kampanye pihak ketiga yang telah diverifikasi",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transfer lintas rantai",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Poin harian di blockchain",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Tukar DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Mulai Staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("buku besar"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Memuat APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Penambangan"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage(
      "Hasilkan Lebih Banyak",
    ),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Taruhan asli Solana",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Tidak ada posisi aktif",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Dapatkan hadiah dengan berpartisipasi dalam penambangan node",
    ),
    "g_key_earn_perps": MessageLookupByLibrary.simpleMessage(
      "Kontrak perpetual",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Alat Cepat",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Direkomendasikan",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Pilih Jenis Tukar",
    ),
    "g_key_earn_stablecoin_deposit": MessageLookupByLibrary.simpleMessage(
      "Setor",
    ),
    "g_key_earn_stablecoin_desc": MessageLookupByLibrary.simpleMessage(
      "Dapatkan imbal hasil harian pada USDC / USDT / DAI",
    ),
    "g_key_earn_stablecoin_empty": MessageLookupByLibrary.simpleMessage(
      "Tidak ada pasar stablecoin tersedia saat ini",
    ),
    "g_key_earn_stablecoin_title": MessageLookupByLibrary.simpleMessage(
      "Hasil Stabil",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Taruhan ETH dengan Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Tukar"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Hasilkan"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Jumlah Penghasilan",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("Lihat Semua"),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Alamat terselesaikan diperbarui",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Lanjutan"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Biaya Tahunan",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Tersedia"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Harga Dasar"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Memeriksa ketersediaan...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Berkomitmen"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Komit gagal",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Komitmen pendaftaran telah kedaluwarsa. Silakan mulai ulang proses pendaftaran.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Melakukan...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Perpanjangan",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi & Kirim",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Konfirmasikan Resolusi ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Alamat disalin",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Kedaluwarsa Saat Ini",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("hari tersisa"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Daftarkan dan kelola nama domain .eth Anda",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Nama ENS Terdeteksi",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Perpanjang Masa Pendaftaran",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Gagal"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Menyelesaikan pendaftaran",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Mulailah dengan ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Dapatkan nama .eth Anda",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Alamat tidak valid (harus 0x + 40 karakter hex)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nama ENS tidak valid",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "sekarang milikmu!",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Harap tetap membuka aplikasi saat pendaftaran",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Kelola identitas Web3 Anda",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimal 3 karakter",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("Domain Saya"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nama ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Kadaluwarsa Baru",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Alamat Pemilik Baru",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Belum ada domain",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Pemilik"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Harap tunggu",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nama Premi",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Rincian Harga",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Utama"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nama utama berhasil ditetapkan",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Memproses...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Daftarkan ENS",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Daftar"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Identitas terdesentralisasi Anda di Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Pendaftaran gagal",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Daftar Sekarang",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Mendaftar...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Info Pendaftaran",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Periode Pendaftaran",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Aktifkan pengingat kedaluwarsa",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Beri tahu 30, 7 dan 1 hari sebelum kedaluwarsa",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Memperbarui"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Perpanjang pendaftaran domain Anda",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Perpanjangan berhasil",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Alamat Terselesaikan",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Menyelesaikan ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Cari"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Temukan nama .eth yang tersedia",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cari nama .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Masukkan nama ENS untuk mencari",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Cari & Daftar",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("Cari ENS"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat mengirim ke alamat sendiri",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Layanan Nama Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Tetapkan sebagai Utama",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nama Standar",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Mulai Pendaftaran",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Langkah 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Langkah 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Langkah 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Buat Subdomain",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain dibuat",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Hapus Subdomain",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Subdomain ini akan dihapus secara permanen.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain dihapus",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Belum ada subdomain",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Gunakan huruf, angka, dan tanda hubung saja",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Label subdomain",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "misalnya blog, email, aplikasi",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Alamat pemilik",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Biarkan kosong untuk menggunakan dompet saat ini",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomain"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Sukses!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("Saran"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Catatan Teks",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Manajer ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Jumlah"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Pemindahan"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transfer kepemilikan ke alamat lain",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer berhasil",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Pemindahan tidak dapat diubah. Pastikan alamat pemilik baru sudah benar.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Coba nama lain",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "Pendaftaran ENS adalah proses dua langkah",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Tidak tersedia",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Tunggu"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Masa tunggu mencegah serangan yang berjalan di depan",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Masa tunggu mencegah proses berjalan di depan",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Menunggu..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Harap verifikasi alamat yang diselesaikan sebelum melanjutkan. Nama ENS dapat dialihkan atau diubah oleh pemiliknya.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("tahun"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("tahun"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Identitas Anda",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Kesalahan parsing data respons!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Kesalahan Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Kesalahan sintaks permintaan",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Tidak terotorisasi, silakan masuk",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Akses ditolak"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage(
      "Kesalahan permintaan",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Permintaan habis waktu",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Server bermasalah"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Layanan tidak diimplementasikan",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Kesalahan gateway"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Layanan tidak tersedia",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Gateway habis waktu",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Versi HTTP tidak didukung",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Permintaan gagal, kode kesalahan:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Sistem sibuk, silakan coba lagi nanti",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Frekuensi permintaan terlalu cepat",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("Dekoding gagal"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Transaksi sudah ada di blockchain",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Kesalahan konfigurasi sertifikat!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Kesalahan konfigurasi kode status!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "Kesalahan tidak diketahui!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Koneksi jaringan habis waktu, silakan periksa pengaturan jaringan!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Server bermasalah. Silakan coba lagi nanti!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Permintaan telah dibatalkan, silakan minta lagi!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Ekspor Keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Tips Pencadangan",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Gunakan alat pengelola kata sandi untuk menyimpan.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Disalin"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Penyalinan dibatalkan",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Dompet identitas",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "File kunci pribadi terenkripsi.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Metode impor",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "File Keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan informasi Keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Ekspor Kunci Pribadi",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Mendapatkan Keystore dan kata sandi akan memberikan pemegang kontrol penuh atas aset dompet.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Catat dengan hati-hati dan simpan di lokasi yang aman. Menyimpan beberapa salinan fisik adalah metode penyimpanan paling aman.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Jika kunci pribadi Anda hilang, tidak dapat dipulihkan. Cadangkan secara fisik dan simpan dengan aman.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Simpan secara offline",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Jangan simpan ke email, notepad, disk jaringan, atau perangkat lunak obrolan yang tidak aman.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Silakan gunakan transmisi jaringan",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Pastikan untuk mentransmisikannya melalui alat jaringan, Setelah peretas mendapatkannya, akan menyebabkan kerugian ekonomi yang tidak dapat diperbaiki",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Gunakan alat untuk menyimpan",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Saya memahami bahwa siapa pun yang mendapatkan file ini dan kata sandi memiliki kendali penuh atas dana saya — kehilangan bersifat permanen dan tidak dapat dipulihkan",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Masukkan kata sandi dompet untuk mengonfirmasi ekspor",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Masukkan kata sandi dompet untuk melihat kunci privat",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Menyaring"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Peringatan Gas"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Peringatan ketika di atas",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Waspada ketika di bawah",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Simpan"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Ambang Batas (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Biaya Dasar"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Kustom"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Cepat"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Harga gas berfluktuasi berdasarkan permintaan jaringan. Gas lebih rendah = konfirmasi lebih lambat, gas lebih tinggi = konfirmasi lebih cepat.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Biaya Maksimum"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Jaringan sibuk",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Jaringan kosong",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Jaringan normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage("Tren Harga"),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Biaya Prioritas",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Harga Gas Waktu Nyata",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Pengaturan Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lambat"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standar"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Pelacak Gas"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Akun sudah diimpor",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Tambah"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("Tambah Akun"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Alamat disalin",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Pastikan perangkat Anda tidak terkunci dan Bluetooth diaktifkan sebelum menghubungkan.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Periksa Aplikasi",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Perangkat Baru",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Celah udara dengan Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Buku Besar (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Terhubung"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Menghubungkan...",
    ),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage(
      "Putuskan sambungan",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Kembali"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Batu Kunci",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Pindai kode QR ini dengan perangkat Keystone Anda untuk menandatangani transaksi",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Arahkan kamera Anda ke kode QR yang ditampilkan di perangkat Keystone Anda",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Pindai Tanda Tangan Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Pindai kode QR dari perangkat Keystone Anda untuk mengimpor akun",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Ketuk untuk memindai respons Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage(
      "Muat lebih banyak",
    ),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Memuat akun...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Harap konfirmasi di perangkat Anda jika diminta",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Tidak ada akun yang ditemukan",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "Tidak ada aplikasi yang terbuka saat ini",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Perangkat tidak terhubung",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Tidak Terhubung",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Hapus"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Hapus Perangkat",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Perangkat Tersimpan",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Perangkat yang Didukung",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Hari ini"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal terhubung ke Trezor. Pastikan USB terhubung.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Hubungkan Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor berhasil terhubung",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Menghubungkan ke Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Hubungkan perangkat Trezor Anda melalui kabel USB dan buka kuncinya",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Lihat Akun",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Akun Dompet",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Kemarin"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Dompet mata uang saat ini sudah ada.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat membaca Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Penyimpanan kunci",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Masuk"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Keluar"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Apakah Anda yakin ingin keluar dari aplikasi?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Poin yang Tersedia",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Sudah cek-in hari ini",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage("Cek-in"),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Selesai",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Cek-in gagal",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Cek-in berhasil dikonfirmasi di N42",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Salin"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Cek-in Harian",
    ),
    "g_key_loyalty_earn_points": m28,
    "g_key_loyalty_empty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Papan peringkat kosong",
    ),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("Riwayat"),
    "g_key_loyalty_invite_description": MessageLookupByLibrary.simpleMessage(
      "Bagikan kode rujukan Anda",
    ),
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Undang teman",
    ),
    "g_key_loyalty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Papan Peringkat",
    ),
    "g_key_loyalty_no_history": MessageLookupByLibrary.simpleMessage(
      "Tidak ada riwayat poin",
    ),
    "g_key_loyalty_no_referrals": MessageLookupByLibrary.simpleMessage(
      "Belum ada rujukan. Bagikan kode Anda untuk memulai.",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Tidak ada hadiah yang tersedia",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Tidak ada tugas yang tersedia",
    ),
    "g_key_loyalty_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Tidak ada dompet aktif",
    ),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Rujukan"),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("Hadiah"),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Tugas"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Poin"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total yang Diperoleh",
    ),
    "g_key_loyalty_unavailable": MessageLookupByLibrary.simpleMessage(
      "Layanan tidak tersedia",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Digunakan"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Peramban"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Perselisihan"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Kapitalisasi Pasar"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volume Perdagangan"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Total Pasokan"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Beredar"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Tentang"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Selengkapnya"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Tautan"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Situs web"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Kelola Rantai",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Tersedia"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Membutuhkan taruhan",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan frasa pemulihan",
    ),
    "g_key_msgsign_btn": MessageLookupByLibrary.simpleMessage("Tanda Tangani"),
    "g_key_msgsign_empty": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan pesan terlebih dahulu",
    ),
    "g_key_msgsign_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal menandatangani",
    ),
    "g_key_msgsign_input_hint": MessageLookupByLibrary.simpleMessage(
      "Masukkan pesan yang ingin ditandatangani",
    ),
    "g_key_msgsign_result": MessageLookupByLibrary.simpleMessage(
      "Tanda Tangan",
    ),
    "g_key_msgsign_title": MessageLookupByLibrary.simpleMessage(
      "Tanda Tangani Pesan",
    ),
    "g_key_msgsign_unsupported": MessageLookupByLibrary.simpleMessage(
      "Penandatanganan pesan belum didukung untuk rantai ini",
    ),
    "g_key_msgsign_warning": MessageLookupByLibrary.simpleMessage(
      "Hanya tanda tangani pesan yang benar-benar Anda percayai. Pesan jahat bisa digunakan untuk mengizinkan tindakan atas nama Anda.",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Jumlah"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nama"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Kembali"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transaksi terkirim"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Alamat dompet tidak valid",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Keseimbangan"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Tindakan ini tidak dapat diubah. NFT akan dikirim ke alamat pembakaran.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Bakar NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Koleksi"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Kontrak"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("Deskripsi"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Gagal memuat NFT. Ketuk untuk mencoba lagi.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Semua"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Video"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Lantai"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galeri NFT"),
    "g_key_nft_hide_spam": MessageLookupByLibrary.simpleMessage(
      "Sembunyikan spam",
    ),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("Prasasti #"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Tidak ada NFT yang ditemukan",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Tidak ada tautan penjelajah yang tersedia",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Pemutaran video tidak didukung",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinal"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transfer ordinal belum didukung",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Kuantitas"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cari berdasarkan nama atau koleksi",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Kirim NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transfer Solana NFT akan segera hadir",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("ID Token"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Ketik"),
    "g_key_nft_uncategorized": MessageLookupByLibrary.simpleMessage("Lainnya"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Kata sandi tidak cocok",
    ),
    "g_key_perps_read_only": MessageLookupByLibrary.simpleMessage(
      "Data pasar hanya bisa dibaca. Penempatan pesanan tidak didukung dalam versi ini.",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Pilih dari galeri ponsel",
    ),
    "g_key_pubkey": MessageLookupByLibrary.simpleMessage("Kunci Publik"),
    "g_key_receive_payment_request": MessageLookupByLibrary.simpleMessage(
      "Permintaan Pembayaran",
    ),
    "g_key_receive_request_line": m29,
    "g_key_remove_network": MessageLookupByLibrary.simpleMessage(
      "Hapus Jaringan",
    ),
    "g_key_remove_network_confirm": m30,
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Setel ulang"),
    "g_key_retry": MessageLookupByLibrary.simpleMessage("Coba lagi"),
    "g_key_scan_pay_unsupported": MessageLookupByLibrary.simpleMessage(
      "Token atau rantai permintaan pembayaran tidak ada di dompet ini",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Gunakan Perhatian",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Memeriksa keamanan kontrak...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Risiko Tinggi Terdeteksi",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Kontrak Terverifikasi Aman",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Memo / Catatan",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Memo / Catatan (opsional)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("Bagikan kode QR"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Bagikan tautan"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metode berbagi",
    ),
    "g_key_sim_gas_estimate": m31,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Kemungkinan besar transaksi akan gagal",
    ),
    "g_key_sim_reverted_reason": m32,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulasi transaksi…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Simulasi transaksi berhasil",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulasi tidak tersedia untuk jaringan ini",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Obrolan"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Aktif"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Posisi Aktif",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Jumlah"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Jumlah untuk Dilepaskan",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage(
      "Rata-rata APY",
    ),
    "g_key_stake_broadcast_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transaksi telah dibuat, tetapi penyiaran dalam dompet untuk jaringan ini belum didukung.",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Komisi"),
    "g_key_stake_d_unbond": m33,
    "g_key_stake_days_remaining": m34,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Perkiraan. Hadiah Harian",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Perkiraan. Hadiah Tahunan",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Pergi ke Tukar",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Taruhan Cair",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Cair"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Token cair Anda dapat diperdagangkan di DEX secara langsung. Gunakan Swap untuk menukarkannya kembali ke aset asli.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Stake Minimum",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Tidak ada posisi aktif untuk dilepas taruhannya",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage(
      "Tidak ada kunci",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Belum ada posisi staking",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Tidak ada validator yang ditemukan",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Alamat dompet tidak tersedia",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Ikhtisar Total Taruhan",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Posisi Saya",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protokol"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Hadiah"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Validator pencarian...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Pilih validator",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Pilih posisi yang akan dilepas taruhannya",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Pilih Validator",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "Urutkan berdasarkan",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Taruhan"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Dipertaruhkan"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Mulai Mempertaruhkan",
    ),
    "g_key_stake_submitted": MessageLookupByLibrary.simpleMessage(
      "Transaksi mempertaruhkan telah dikirim",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Mempertaruhkan"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaksi berhasil disiapkan",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Membuka Kunci",
    ),
    "g_key_stake_unbonding_warning": m35,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Lepaskan taruhannya",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Memperbarui...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validator"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Anda akan menerima",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Selesai"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Harga gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Biaya gas maksimal"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Biaya maksimal per gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Tertunda"),
    "g_key_t_29": m36,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Gagal"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Lanjutkan"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Kata sandi dompet"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Kata sandi dompet salah",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan kata sandi dompet",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Tingkat Biaya Gas"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Rata-rata Tingkat Biaya Gas blok terbaru",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Transfer keluar"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Masukkan bilangan bulat lebih dari 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Gagal mendapatkan data",
    ),
    "g_key_t_45": m37,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Periksa akun alamat penerima",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Temukan"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Tidak ada akun"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transfer masuk"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Alamat tidak valid"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Verifikasi akun berhasil",
    ),
    "g_key_t_52": m38,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Alamat penerima tidak memiliki akun, dan transfer pertama minimal 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas Terpakai"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Biaya Gas"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Tambahkan",
    ),
    "g_key_token_discovery_add_selected": m39,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Token ditambahkan",
    ),
    "g_key_token_discovery_banner": m40,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Batalkan pilihan semua",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Tidak ada token baru yang ditemukan",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Abaikan",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Pilih semua",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Token yang Ditemukan",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Riwayat transaksi"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Detail Transaksi"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Silakan lihat bukti transaksi di riwayat",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage(
      "Jumlah yang dibelanjakan",
    ),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage(
      "Jumlah yang diterima",
    ),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Tanggal Mulai",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Rentang Tanggal",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Tanggal Berakhir",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage("Arah"),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Tidak ada transaksi yang cocok dengan filter Anda",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage("Temukan versi terbaru"),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Perbarui segera"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Versi baru ditemukan"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage("Sudah versi terbaru"),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Lihat Frasa Pemulihan",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Sekarang coba masukkan frasa pemulihan Anda lagi.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Impor Akun"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Buat Akun"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "Anda sudah selesai!",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Anda sekarang dapat sepenuhnya menikmati dompet Anda.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Mulai"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "Lewati untuk saat ini",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Anda dapat melewati pencadangan frasa pemulihan untuk saat ini, dan melakukannya lagi di Pengaturan kapan saja jika diperlukan.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("Buat langsung"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage("berhasil dibuat"),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Jika Anda ingin memeriksa detail dompet atau mengekspor keystore, Anda dapat pergi ke Sidebar > Kelola Dompet",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Ekspor keystore saya",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Amankan dompet Anda dengan mencadangkannya",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Keystore adalah repositori sertifikat keamanan dan kunci pribadi terkait.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Langkah 1: Buka Kelola Dompet.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Langkah 2: Pilih Alamat Dompet.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Langkah 3: Tekan Ekspor Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Buka Kelola Dompet",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Kembali ke beranda",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Tambah Dompet"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Buat dompet menggunakan frasa pemulihan.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Masukkan nama dompet",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Anda belum mencadangkan frasa pemulihan dompet!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Cadangkan Sekarang",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Atur Kata Sandi Dompet",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Cadangkan Dompet",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Silakan catat frasa pemulihan berikut",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Mulai"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Perangkat yang terhubung ke internet dapat mengekspos informasi Anda. Kami sarankan Anda menuliskan frasa pemulihan dan menyimpannya dengan aman.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Peringatan: Jangan ungkapkan frasa pemulihan Anda kepada siapa pun. N42Wallet tidak akan pernah meminta informasi ini. Harap sangat berhati-hati dan simpan secara offline dengan aman. Jika frasa pemulihan Anda terekspos, Anda mungkin kehilangan semua aset dan tidak dapat memulihkannya.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Peringatan: Frasa pemulihan adalah satu-satunya cara untuk memulihkan aset dompet Anda.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage(
      "Langkah selanjutnya",
    ),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Klik untuk melihat frasa pemulihan",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Pastikan tidak ada orang lain atau kamera di sekitar",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Frasa Pemulihan",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Informasi Dompet",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Nama dompet"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Silakan cadangkan frasa pemulihan dompet Anda terlebih dahulu!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Periksa Frasa Pemulihan",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Sekarang masukkan frasa pemulihan Anda.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Atur Frasa"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Pastikan Anda mencatat frasa pemulihan Anda dan menyimpannya dengan aman. Anda akan membutuhkannya untuk mengimpor atau memulihkan dompet cryptocurrency Anda.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("Edit dompet"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Waktu"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Hasil"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("Hash transaksi"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Tambah"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Jalur"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Blok"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Nilai"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage(
      "Tidak sekali pun",
    ),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Percepat"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Catatan"),
    "g_key_wallet_m1": m41,
    "g_key_wallet_m19": m42,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Token saat ini belum ditambahkan.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Masukkan frasa pemulihan Anda dengan kata-kata dipisahkan spasi",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Impor Dompet"),
    "g_key_wallet_m3": m43,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Saldo token saat ini tidak mencukupi.",
    ),
    "g_key_wallet_m5": m44,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage(
      "Kesalahan penandatanganan",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Kelola Dompet",
    ),
    "g_key_wallet_tx_replace_hint": MessageLookupByLibrary.simpleMessage(
      "Transaksi pengganti akan dipublikasikan dengan nonce yang sama dan biaya gas sekitar 20% lebih tinggi. Hanya berlaku selama transaksi asli masih dalam status menunggu.",
    ),
    "g_key_wallet_tx_replace_submitted": MessageLookupByLibrary.simpleMessage(
      "Transaksi pengganti telah dikirim",
    ),
    "g_key_wallet_tx_speedup": MessageLookupByLibrary.simpleMessage("Percepat"),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Masukkan alamat Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Dompet khusus jam tangan tidak dapat mengirim atau menandatangani transaksi",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Dompet Jam Tangan",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Lacak alamat EVM apa pun tanpa kunci pribadi",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Dicadangkan"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Cadangan Dasar"),
    "g_key_xml_11": m45,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Cadangan Tambahan"),
    "g_key_xml_22": m46,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Jumlah Objek yang Dimiliki",
    ),
    "g_key_xml_33": m47,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Cara menghitung total jumlah yang dicadangkan",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Total Cadangan = Cadangan Dasar + (Jumlah Objek yang Dimiliki × Cadangan Tambahan)",
    ),
    "g_live_ended": MessageLookupByLibrary.simpleMessage(
      "Siaran langsung telah berakhir",
    ),
    "g_live_enter_room_failed": m48,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("Ikuti"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "Fitur ikuti segera hadir",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID dan Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Kata sandi gestur"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Atur kata sandi gestur",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Gambar pola gestur Anda",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi pola gestur Anda",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Gambar gestur saat ini",
    ),
    "g_lock_key21": m49,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Setel ulang kata sandi gestur",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Terlalu banyak percobaan gagal, coba lagi",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Tambahkan Kata Sandi Dompet?",
    ),
    "g_lock_key25": m50,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage("Verifikasi Transfer"),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Harus menggunakan otentikasi biometrik (Face ID / sidik jari) untuk mengonfirmasi setiap transfer dompet.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Kata sandi gestur belum diatur",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Autentikasi gestur diperlukan untuk mengonfirmasi setiap transfer.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Berhasil"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Gagal"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Pengenalan biometrik tidak diaktifkan",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Tambahkan verifikasi biometrik?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage(
      "Perubahan 30D",
    ),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Perubahan 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Kedalaman Pasar"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Belum ada daftar pantauan",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Tinggi 24 jam"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Skor Likuiditas",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Rendah 24 jam"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Berita"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Tidak ada data grafik",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Tidak ada hasil",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Pangkat"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Cari"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cari koin...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Sedang tren"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Daftar pantauan",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Skor tidak aktif validator tinggi. Periksa status node Anda untuk menghindari penalti.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Buka kunci N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Aktivitas Verifikasi Cloud",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Pengaturan Verifikasi",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Musik Verifikasi Latar Belakang",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Bawaan"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Bisu"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Saat verifikasi latar belakang diaktifkan, musik akan diputar di latar belakang. Jika musik berhenti, verifikasi juga akan berhenti.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Tingkat Anda"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Pengaturan memerlukan sedikit biaya gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Anda telah berhasil bergabung dengan Node Grup di N42Wallet. Bagikan tautan untuk mengundang teman, aktifkan Node dan mulai verifikasi!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("Bagikan ke teman"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Lanjutkan"),
    "g_mining_key63": m51,
    "g_mining_key73": m52,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Saya baru saja menyiapkan node di @N42Wallet dan memulai verifikasi di perangkat seluler! Ayo bergabung dengan saya. Masa depan terdesentralisasi ada di seluler!",
    ),
    "g_mining_key76": m53,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Mineral"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("simpul"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Jaringan"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Beralih antara testnet dan mainnet untuk penambangan awan.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Penukaran tersedia setelah 768 detik.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Permintaan sebelum itu tidak akan diproses.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Rumah"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("Hadiah hari ini"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Silakan perlakukan data di bawah ini sebagai kunci penting. Kami sarankan untuk menyalin dan mencadangkannya ke lokasi tepercaya segera.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Salin Data"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Tidak Aktif"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage("Impor berhasil"),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Data terenkripsi tidak boleh kosong!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Kata sandi tidak boleh kosong!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Dekripsi gagal. Silakan periksa apakah kata sandi benar!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Format data terenkripsi tidak didukung!",
    ),
    "g_mining_key_109": m54,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage("Hadiah Kemarin"),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Data terenkripsi",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Impor file"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan data terenkripsi.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Mengimpor..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Konfirmasi"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Penukaran membutuhkan waktu, silakan tunggu sebentar!",
    ),
    "g_mining_key_116": m55,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Hadiah terakumulasi setiap hari dan hanya dikirim ke dompet N Anda ketika mencapai ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Total Hadiah"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Nilai Ditambang"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("Detil tugas"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Ringkasan"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Kegiatan"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Nilai Total yang Ditambang",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("Verifikasi Sejak"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Jumlah keuntungan",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Nilai Terverifikasi",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Pilih Paket"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Periode Buka Kunci: Dapat dibuka kapan saja",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Hadiah Maksimal Tahunan",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Distribusi Hadiah",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Batas Harian"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Kecepatan"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage("Paket Verifikasi"),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Pilih metode pembayaran",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage(
      "Metode Pembayaran",
    ),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage(
      "Bayar menggunakan N",
    ),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Saldo Dompet"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Anda tidak memiliki cukup N untuk transaksi ini",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Apakah Anda yakin ingin melewatkannya?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Anda tidak akan menerima imbalan verifikasi apa pun sampai Anda memilih salah satu paket.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Dinonaktifkan"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Hadiah"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage(
      "Lihat selengkapnya",
    ),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage("Status Verifikasi"),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage(
      "Untuk membuka kunci",
    ),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Lewati"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("7 Hari Terakhir"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("Akumulasi Hadiah"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Kunci N untuk mulai mendapatkan hadiah verifikasi.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Hadiah yang Diterima",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Lanjutan"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Pemula"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("NODE LENGKAP"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MENIT/HARI"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Node Lanjutan"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Node Pemula"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Node Pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blok/hari~70 menit",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Tanggal Buka Kunci",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blok/hari~15 menit",
    ),
    "g_mining_key_71": m56,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 detik per pemeriksaan",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Jaringan uji sedang ditingkatkan dan blok tidak dapat diverifikasi sementara.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Gagal menyelesaikan tugas selama empat hari berturut-turut akan mengakibatkan tidak ada penghasilan dan risiko penalti.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Skor Risiko"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Tebus"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Silakan simpan pasangan kunci publik dan pribadi validator terlebih dahulu.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Ekspor"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Waktu Verifikasi Hari Ini",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Saldo tidak mencukupi untuk transfer.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("Daftar Validator"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("Impor validator"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Validator sudah ada",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Risiko Rendah"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Risiko Cukup"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Hadiah 7 hari terakhir",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Risiko Tinggi"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Kontrak sedang dimuat dan tidak dapat diverifikasi saat ini. Silakan tunggu sebentar!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("Tips Keamanan"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Verifikasi Latar Belakang",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Silakan simpan kunci pribadi atau frasa pemulihan Anda dengan aman.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Kunci pribadi atau frasa pemulihan Anda adalah satu-satunya kredensial untuk mengakses aset dompet Anda.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Silakan simpan di tempat yang aman (kertas, pengelola kata sandi, dll.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Jangan mengambil tangkapan layar, mengunggahnya ke internet, atau membagikannya kepada siapa pun.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Setelah hilang atau terekspos, aset dompet Anda tidak dapat dipulihkan.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi dan simpan",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Atur kata sandi dan enkripsi",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan kata sandi enkripsi",
    ),
    "g_mining_key_98": m57,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan kembali kata sandi Anda untuk memastikan kebenaran",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Detail Node Penuh",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID Node"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Terhubung"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Terputus"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Menghubungkan",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Periode Buka Kunci:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Dapat dibuka kapan saja",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Tidak ada berita yang tersedia",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Kembali (Aman)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Lanjutkan Saja",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Situs web ini telah diidentifikasi sebagai berpotensi berbahaya. Mungkin mencoba mencuri aset kripto atau kunci pribadi Anda.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Peringatan Keamanan",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "URL Mencurigakan:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Tambahkan Perdagangan",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Biaya Rata-rata"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Harga Beli (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Dasar Biaya"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Kuantitas"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Simpan"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Keuntungan dan Kerugian yang belum direalisasi",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Perubahan 24 jam"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Semua Aset",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Alokasi Aset",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Peraih Teratas",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Penurunan Teratas",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Penggerak 24 jam",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Tidak ada aset yang ditemukan",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Lainnya"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Jumlah"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portofolio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Nilai Total"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("Tambah hasil"),
    "g_pred_amount_input": m58,
    "g_pred_balance": m59,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Beli"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Batal & kembalikan",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("Hanya tutup"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Ditutup, menunggu hasil",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi penyelesaian",
    ),
    "g_pred_confirm_resolve_msg": m60,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Mulai Prediksi",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Membuat…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Batas waktu"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "Jumlah harus lebih dari 0",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "Saldo tidak cukup",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "Bagian tidak cukup",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "Hasil tidak valid",
    ),
    "g_pred_err_invalid_state": MessageLookupByLibrary.simpleMessage(
      "Pasar telah diselesaikan, tindakan tidak diperbolehkan",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "Pasar ditutup, tidak bisa transaksi",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "Pasar tidak ditemukan",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "Pasar belum selesai, tidak bisa ditebus",
    ),
    "g_pred_err_not_resolver": MessageLookupByLibrary.simpleMessage(
      "Hanya tuan rumah yang membuat pasar ini yang dapat melakukan ini",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Minimal dua hasil valid",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Masukkan pertanyaan",
    ),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "Slippage terlampaui, coba lagi",
    ),
    "g_pred_minutes": m61,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("Tidak"),
    "g_pred_outcome_n": m62,
    "g_pred_outcome_win": m63,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Hasil"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Pilih hasil pemenang untuk menyelesaikan (dana sesuai hasil)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Memproses…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Terbitkan"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Pertanyaan prediksi, mis.: Siapa menang ronde ini?",
    ),
    "g_pred_quote_info": m64,
    "g_pred_redeem_failed": m65,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Selesai"),
    "g_pred_result_label": m66,
    "g_pred_sell_n": m67,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Tanpa batas (tutup manual)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Ya"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Diunduh"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Kode undangan",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Diundang"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage(
      "Node Penambangan",
    ),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Hadiah (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Penambangan Klasik (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Penambangan (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Antarmuka Pertambangan",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Bagikan"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Rujukan"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Ajak teman dan dapatkan Token N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Anda mendapat hingga ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N saat referral Anda memulai verifikasi!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Ajak melalui"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Tautan"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("kode"),
    "g_swap_key_14": m68,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Kesalahan mendapatkan harga koin.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Dengan melanjutkan, Anda menyetujui ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Syarat dan Ketentuan.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Selesai"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Swap Anda akan segera didistribusikan. Harap bersabar.",
    ),
    "g_swap_key_20": m69,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Biaya untuk menjalankan node: Verifikasi Grup 1-49 N Node Dasar: 50 N Node Premium: 100 N Node Pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Kedaluwarsa"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Belum Dibayar"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Mengonfirmasi pembayaran",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage(
      "Akan didistribusikan",
    ),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Ringkasan Swap"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Saldo Baru"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Anda bayar"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Tanggal"),
    "g_swap_key_31": m70,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Swap dapat dilihat di penjelajah blockchain terkait (Etherscan, BscScan, TRONSCAN dan milik kami).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Swap ke N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Tukar"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Anda dapat"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Pratinjau Swap"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Coba lagi"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("Warna Aksen"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Atur ulang ke default",
    ),
    "g_theme_mode": MessageLookupByLibrary.simpleMessage("Tampilan"),
    "g_theme_style": MessageLookupByLibrary.simpleMessage("Gaya"),
    "g_theme_style_custom": MessageLookupByLibrary.simpleMessage("Adat"),
    "g_token_m_key_1": m71,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Siapa pun dapat membuat token, termasuk membuat versi palsu dari token yang ada. Selalu teliti token sebelum mengimpornya.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Token"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Cari Token"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Nama Jaringan"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Simbol jaringan"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID Jaringan"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Desimal"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Tambah jaringan kustom",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 digit"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Tambah Token"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Kesalahan Format!",
    ),
    "g_token_m_key_22": m72,
    "g_token_m_key_23": m73,
    "g_token_m_key_24": m74,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Impor token"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Semua jaringan"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("Token Kustom"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Alamat token"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Simbol token"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Desimal token"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Impor"),
    "g_token_m_key_chainid_conflict": MessageLookupByLibrary.simpleMessage(
      "ID Jaringan ini sudah digunakan oleh jaringan lain.",
    ),
    "g_token_m_key_chainid_mismatch": m75,
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Perhatian"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Risiko Tinggi"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Aman"),
    "g_ui_aave_lending": MessageLookupByLibrary.simpleMessage(
      "Peminjaman Aave V3",
    ),
    "g_ui_account_email": MessageLookupByLibrary.simpleMessage("Email akun"),
    "g_ui_algo_asset_add_fee": MessageLookupByLibrary.simpleMessage(
      "Menambahkan aset ini memerlukan biaya jaringan. Ketuk Tambah untuk melanjutkan.",
    ),
    "g_ui_algo_asset_missing": m76,
    "g_ui_assistant_hint": MessageLookupByLibrary.simpleMessage(
      "Tanya tentang saldo, portofolio, gas",
    ),
    "g_ui_back_code": MessageLookupByLibrary.simpleMessage("Kembali ke kode"),
    "g_ui_back_email": MessageLookupByLibrary.simpleMessage("Kembali ke email"),
    "g_ui_backup_create_save": MessageLookupByLibrary.simpleMessage(
      "Buat & Simpan Cadangan",
    ),
    "g_ui_backup_empty": MessageLookupByLibrary.simpleMessage(
      "Tidak ditemukan dompet dalam file cadangan",
    ),
    "g_ui_backup_encryption_hint": MessageLookupByLibrary.simpleMessage(
      "Cadangan Anda dienkripsi dengan AES-256 + PBKDF2. Hanya kata sandi yang benar yang dapat memulihkannya.",
    ),
    "g_ui_backup_enter_password": MessageLookupByLibrary.simpleMessage(
      "Silakan masukkan kata sandi cadangan",
    ),
    "g_ui_backup_export": MessageLookupByLibrary.simpleMessage(
      "Ekspor Cadangan Cloud",
    ),
    "g_ui_backup_export_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat membuat cadangan. Silakan coba lagi.",
    ),
    "g_ui_backup_file": MessageLookupByLibrary.simpleMessage("File Cadangan"),
    "g_ui_backup_file_access": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat mengakses file yang dipilih",
    ),
    "g_ui_backup_import": MessageLookupByLibrary.simpleMessage(
      "Impor Cadangan Cloud",
    ),
    "g_ui_backup_import_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat mengembalikan cadangan. Periksa kata sandi dan file cadangan, lalu coba lagi.",
    ),
    "g_ui_backup_import_result": m77,
    "g_ui_backup_import_wallets": MessageLookupByLibrary.simpleMessage(
      "Impor Dompet",
    ),
    "g_ui_backup_invalid_file": MessageLookupByLibrary.simpleMessage(
      "Bukan file cadangan N42Wallet yang valid",
    ),
    "g_ui_backup_no_file": MessageLookupByLibrary.simpleMessage(
      "Tidak ada file yang dipilih",
    ),
    "g_ui_backup_no_selection": MessageLookupByLibrary.simpleMessage(
      "Tidak ada dompet yang valid dipilih untuk cadangan",
    ),
    "g_ui_backup_password": MessageLookupByLibrary.simpleMessage(
      "Kata Sandi Cadangan",
    ),
    "g_ui_backup_password_hint": MessageLookupByLibrary.simpleMessage(
      "Tetapkan kata sandi cadangan yang kuat (minimal 8 karakter)",
    ),
    "g_ui_backup_password_min": MessageLookupByLibrary.simpleMessage(
      "Kata sandi harus minimal 8 karakter",
    ),
    "g_ui_backup_password_repeat": MessageLookupByLibrary.simpleMessage(
      "Masukkan kembali kata sandi cadangan",
    ),
    "g_ui_backup_restore_hint": MessageLookupByLibrary.simpleMessage(
      "Pulihkan dompet Anda dari cadangan terenkripsi yang disimpan di iCloud Drive atau Google Drive.",
    ),
    "g_ui_backup_restore_none": MessageLookupByLibrary.simpleMessage(
      "Tidak ada dompet yang dapat dipulihkan dari cadangan ini",
    ),
    "g_ui_backup_restore_password_hint": MessageLookupByLibrary.simpleMessage(
      "Masukkan kata sandi yang digunakan saat membuat cadangan",
    ),
    "g_ui_backup_select_file_first": MessageLookupByLibrary.simpleMessage(
      "Silakan pilih file cadangan terlebih dahulu",
    ),
    "g_ui_backup_select_wallet": MessageLookupByLibrary.simpleMessage(
      "Silakan pilih setidaknya satu dompet untuk cadangan",
    ),
    "g_ui_backup_select_wallets": MessageLookupByLibrary.simpleMessage(
      "Pilih Dompet untuk Cadangan",
    ),
    "g_ui_backup_share_subject": MessageLookupByLibrary.simpleMessage(
      "Cadangan N42Wallet",
    ),
    "g_ui_backup_warning": MessageLookupByLibrary.simpleMessage(
      "Cadangan ini berisi kunci pribadi / mnemonic, kata sandi dompet, dan pengaturan dompet. Simpan file cadangan dan kata sandi dengan aman. Jangan pernah berbagi dengan siapa pun.",
    ),
    "g_ui_balance_value": m78,
    "g_ui_base_fee_value": m79,
    "g_ui_buy_n_description": MessageLookupByLibrary.simpleMessage(
      "Beli N melalui protokol N42",
    ),
    "g_ui_calldata_hex": MessageLookupByLibrary.simpleMessage("Calldata (hex)"),
    "g_ui_camera_permission": MessageLookupByLibrary.simpleMessage(
      "Izin kamera diperlukan untuk memindai kode.",
    ),
    "g_ui_cancel_order": MessageLookupByLibrary.simpleMessage(
      "Batalkan Pesanan",
    ),
    "g_ui_change_email": MessageLookupByLibrary.simpleMessage("Ubah Email"),
    "g_ui_checking_approval": MessageLookupByLibrary.simpleMessage(
      "Memeriksa persetujuan...",
    ),
    "g_ui_clipboard_clear": m80,
    "g_ui_clipboard_empty": MessageLookupByLibrary.simpleMessage(
      "Papan klip kosong",
    ),
    "g_ui_coins_load_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal memuat koin. Silakan coba lagi.",
    ),
    "g_ui_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Kata Sandi",
    ),
    "g_ui_confirm_update": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi pembaruan",
    ),
    "g_ui_contract_info": MessageLookupByLibrary.simpleMessage(
      "Informasi Kontrak",
    ),
    "g_ui_create_wallet": MessageLookupByLibrary.simpleMessage("Buat Dompet"),
    "g_ui_csv_header_only": MessageLookupByLibrary.simpleMessage(
      "Tidak ditemukan baris data (hanya header yang terdeteksi).",
    ),
    "g_ui_csv_missing_fields": m81,
    "g_ui_csv_no_data": MessageLookupByLibrary.simpleMessage(
      "Tidak ditemukan data setelah menghapus komentar.",
    ),
    "g_ui_custom_tag": MessageLookupByLibrary.simpleMessage("Label kustom..."),
    "g_ui_days": m82,
    "g_ui_destination_tag": MessageLookupByLibrary.simpleMessage("Tag Tujuan"),
    "g_ui_device_connected": m83,
    "g_ui_dex_description": MessageLookupByLibrary.simpleMessage(
      "Tukar token melalui Uniswap / 1inch / Jupiter",
    ),
    "g_ui_email_code_accepted": MessageLookupByLibrary.simpleMessage(
      "Kode verifikasi diterima",
    ),
    "g_ui_email_code_sent": MessageLookupByLibrary.simpleMessage(
      "Permintaan kode verifikasi telah dikirim",
    ),
    "g_ui_ens_price_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal memuat harga perpanjangan ENS. Silakan coba lagi.",
    ),
    "g_ui_ens_renew_failed": MessageLookupByLibrary.simpleMessage(
      "Perpanjangan ENS gagal. Silakan coba lagi.",
    ),
    "g_ui_entry_price": MessageLookupByLibrary.simpleMessage("Harga Masuk"),
    "g_ui_expires_in": MessageLookupByLibrary.simpleMessage(
      "Kedaluwarsa dalam:",
    ),
    "g_ui_fear_greed": MessageLookupByLibrary.simpleMessage(
      "Ketakutan & Kerinduan",
    ),
    "g_ui_file_picker_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat membuka pemilih file. Silakan coba lagi.",
    ),
    "g_ui_file_read_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat membaca file yang dipilih. Silakan coba lagi.",
    ),
    "g_ui_free_margin": MessageLookupByLibrary.simpleMessage("Gratis"),
    "g_ui_gas_prediction": MessageLookupByLibrary.simpleMessage(
      "Perkiraan Gas Blok Berikutnya",
    ),
    "g_ui_gas_value": m84,
    "g_ui_hours": m85,
    "g_ui_import_valid": m86,
    "g_ui_invalid_email": MessageLookupByLibrary.simpleMessage(
      "Masukkan alamat email yang valid",
    ),
    "g_ui_issues_label": MessageLookupByLibrary.simpleMessage("Masalah:"),
    "g_ui_keystone_paired": MessageLookupByLibrary.simpleMessage(
      "Paired Keystone berhasil",
    ),
    "g_ui_limit_orders": MessageLookupByLibrary.simpleMessage("Pesanan Batas"),
    "g_ui_limit_price": MessageLookupByLibrary.simpleMessage("Harga Batas"),
    "g_ui_limit_price_pair": m87,
    "g_ui_limit_value": m88,
    "g_ui_liquidation_price": MessageLookupByLibrary.simpleMessage(
      "Harga Likuidasi",
    ),
    "g_ui_margin_utilization": MessageLookupByLibrary.simpleMessage(
      "Pemanfaatan",
    ),
    "g_ui_markets_count": m89,
    "g_ui_memo": MessageLookupByLibrary.simpleMessage("Memo"),
    "g_ui_mempool": MessageLookupByLibrary.simpleMessage("Mempool"),
    "g_ui_message": MessageLookupByLibrary.simpleMessage("Pesan"),
    "g_ui_min_balance_value": m90,
    "g_ui_mnemonic_wallet": MessageLookupByLibrary.simpleMessage(
      "Dompet mnemonic",
    ),
    "g_ui_mpc_intro": MessageLookupByLibrary.simpleMessage(
      "Masuk dengan akun sosial Anda untuk membuat dompet MPC yang aman. Kunci pribadi Anda dibagi menjadi bagian-bagian terenkripsi — tidak perlu frasa benih yang bisa hilang.",
    ),
    "g_ui_mpc_no_phrase": MessageLookupByLibrary.simpleMessage(
      "Tidak Perlu Frasa Benih",
    ),
    "g_ui_mpc_security": MessageLookupByLibrary.simpleMessage(
      "Didukung oleh MPC-TSS. Kunci Anda dibagi menjadi 3 bagian terenkripsi di perangkat Anda, server kami, dan cadangan pemulihan.",
    ),
    "g_ui_new_email": MessageLookupByLibrary.simpleMessage("Alamat email baru"),
    "g_ui_no_cached_email": MessageLookupByLibrary.simpleMessage(
      "Tidak ada email yang disimpan di perangkat ini",
    ),
    "g_ui_no_coins": MessageLookupByLibrary.simpleMessage("Belum ada koin"),
    "g_ui_no_dapps": MessageLookupByLibrary.simpleMessage("Tidak ada DApp"),
    "g_ui_no_limit_orders": MessageLookupByLibrary.simpleMessage(
      "Tidak ada pesanan batas",
    ),
    "g_ui_no_orders": MessageLookupByLibrary.simpleMessage(
      "Tidak ada pesanan terbuka",
    ),
    "g_ui_no_positions": MessageLookupByLibrary.simpleMessage(
      "Tidak ada posisi terbuka",
    ),
    "g_ui_no_wallet": MessageLookupByLibrary.simpleMessage("Belum ada Dompet"),
    "g_ui_optional": MessageLookupByLibrary.simpleMessage("Opsional"),
    "g_ui_order_cancel_failed": MessageLookupByLibrary.simpleMessage(
      "Batal gagal",
    ),
    "g_ui_order_cancelled": MessageLookupByLibrary.simpleMessage(
      "Pesanan dibatalkan",
    ),
    "g_ui_order_create_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal membuat pesanan",
    ),
    "g_ui_order_created": MessageLookupByLibrary.simpleMessage(
      "Pesanan batas berhasil dibuat",
    ),
    "g_ui_order_executed": MessageLookupByLibrary.simpleMessage(
      "Telah dieksekusi",
    ),
    "g_ui_order_place": MessageLookupByLibrary.simpleMessage(
      "Tempatkan Pesanan Batas",
    ),
    "g_ui_order_triggered": MessageLookupByLibrary.simpleMessage("Dipicu"),
    "g_ui_orders_count": m91,
    "g_ui_orders_load_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat memuat pesanan batas",
    ),
    "g_ui_password_mismatch": MessageLookupByLibrary.simpleMessage(
      "Kata sandi tidak cocok",
    ),
    "g_ui_paste_connection": MessageLookupByLibrary.simpleMessage(
      "Tempel tautan koneksi",
    ),
    "g_ui_pending_mempool": MessageLookupByLibrary.simpleMessage(
      "Menunggu (Mempool)",
    ),
    "g_ui_popular_tokens": MessageLookupByLibrary.simpleMessage(
      "Token Populer",
    ),
    "g_ui_position_size": MessageLookupByLibrary.simpleMessage("Ukuran"),
    "g_ui_positions_count": m92,
    "g_ui_private_key_wallet": MessageLookupByLibrary.simpleMessage(
      "Dompet kunci pribadi",
    ),
    "g_ui_read_only": MessageLookupByLibrary.simpleMessage("Hanya Baca"),
    "g_ui_recipients_count": m93,
    "g_ui_room_id": MessageLookupByLibrary.simpleMessage("ID Ruangan"),
    "g_ui_save_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal menyimpan. Silakan coba lagi.",
    ),
    "g_ui_send_code": MessageLookupByLibrary.simpleMessage("Kirim kode"),
    "g_ui_sending_request": MessageLookupByLibrary.simpleMessage(
      "Mengirim permintaan...",
    ),
    "g_ui_swap_mode": MessageLookupByLibrary.simpleMessage("Pilih Mode Tukar"),
    "g_ui_tags": MessageLookupByLibrary.simpleMessage("Label"),
    "g_ui_template_copied": MessageLookupByLibrary.simpleMessage(
      "Templat disalin",
    ),
    "g_ui_token_contract_hint": MessageLookupByLibrary.simpleMessage(
      "Kontrak Token (0x...)",
    ),
    "g_ui_token_found": m94,
    "g_ui_token_lookup": MessageLookupByLibrary.simpleMessage(
      "Mencari informasi token...",
    ),
    "g_ui_token_manual": MessageLookupByLibrary.simpleMessage(
      "Token tidak ditemukan dalam daftar — isi simbol dan desimal secara manual",
    ),
    "g_ui_token_value": m95,
    "g_ui_trade_delete_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat menghapus perdagangan. Silakan coba lagi.",
    ),
    "g_ui_trade_save_failed": MessageLookupByLibrary.simpleMessage(
      "Tidak dapat menyimpan perdagangan. Silakan coba lagi.",
    ),
    "g_ui_transaction_hash_value": m96,
    "g_ui_unknown_status": MessageLookupByLibrary.simpleMessage(
      "Status tidak diketahui",
    ),
    "g_ui_update": MessageLookupByLibrary.simpleMessage("Perbarui"),
    "g_ui_update_email": MessageLookupByLibrary.simpleMessage("Perbarui email"),
    "g_ui_validation_counts": m97,
    "g_ui_validation_issues": MessageLookupByLibrary.simpleMessage(
      "Masalah Validasi",
    ),
    "g_ui_validation_more": m98,
    "g_ui_verification_code": MessageLookupByLibrary.simpleMessage(
      "Kode verifikasi",
    ),
    "g_ui_verify_code": MessageLookupByLibrary.simpleMessage("Verifikasi kode"),
    "g_ui_view_market": MessageLookupByLibrary.simpleMessage(
      "Lihat Data Pasar",
    ),
    "g_ui_volume_24h": MessageLookupByLibrary.simpleMessage("Volume 24 jam"),
    "g_ui_volume_interest": m99,
    "g_ui_wallet_ai": MessageLookupByLibrary.simpleMessage("AI Dompet"),
    "g_ui_wallet_get_started": MessageLookupByLibrary.simpleMessage(
      "Buat atau impor dompet untuk memulai",
    ),
    "g_ui_wallet_load_failed": MessageLookupByLibrary.simpleMessage(
      "Gagal memuat dompet",
    ),
    "g_ui_wallet_loading": MessageLookupByLibrary.simpleMessage(
      "Memuat dompet...",
    ),
    "g_ui_wallet_number": m100,
    "g_version_later": MessageLookupByLibrary.simpleMessage("Nanti"),
    "g_wallet_balance_warning": MessageLookupByLibrary.simpleMessage(
      "Saldo tidak dapat diperbarui",
    ),
    "g_wallet_coin_total_value": MessageLookupByLibrary.simpleMessage(
      "Nilai Total",
    ),
    "g_wallet_coin_unit_price": MessageLookupByLibrary.simpleMessage("Harga"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "Dompet HD · Mnemonik",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "Rantai Tunggal · Diimpor",
    ),
    "g_wallet_pin_token": MessageLookupByLibrary.simpleMessage("Tempel token"),
    "g_wallet_prices_cached": MessageLookupByLibrary.simpleMessage(
      "Harga yang disimpan",
    ),
    "g_wallet_prices_hours": m101,
    "g_wallet_prices_just_updated": MessageLookupByLibrary.simpleMessage(
      "Diperbarui sekarang",
    ),
    "g_wallet_prices_minutes": m102,
    "g_wallet_prices_partial": MessageLookupByLibrary.simpleMessage(
      "Harga sebagian",
    ),
    "g_wallet_prices_unavailable": MessageLookupByLibrary.simpleMessage(
      "Harga tidak tersedia",
    ),
    "g_wallet_receiver_address": MessageLookupByLibrary.simpleMessage(
      "Alamat penerima",
    ),
    "g_wallet_sender_address": MessageLookupByLibrary.simpleMessage(
      "Alamat pengirim",
    ),
    "g_wallet_unpin_token": MessageLookupByLibrary.simpleMessage(
      "Lepas sematan token",
    ),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Koneksi terputus. Silakan hubungkan kembali.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp telah terputus",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Putuskan Semua",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Putuskan koneksi dari semua DApp?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Putuskan koneksi dari DApp ini?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Tidak ada koneksi aktif",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Pindai kode QR untuk terhubung ke DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Permintaan koneksi telah habis waktu",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Sesi telah berakhir",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("DApp Terhubung"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "Biasanya wajib saat mengirim ke bursa",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(Opsional)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Hubungkan",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Pemberitahuan Penting",
    ),
    "login_email": MessageLookupByLibrary.simpleMessage("Surel"),
    "login_password": MessageLookupByLibrary.simpleMessage("Kata Sandi"),
    "next": MessageLookupByLibrary.simpleMessage("Selanjutnya"),
    "nicknameMessage": m103,
    "personalInformation": MessageLookupByLibrary.simpleMessage("Edit Profil"),
    "photograph": MessageLookupByLibrary.simpleMessage("Foto"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Silakan Masukkan Alamat",
    ),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Perangkat ini membatasi aplikasi latar belakang, sehingga Anda mungkin melewatkan pesan obrolan dan pemberitahuan transfer saat aplikasi berada di latar belakang atau tertutup.\n\nKlik \"Pergi ke Pengaturan\" untuk mengizinkan aktivitas latar belakang, lalu aktifkan Otomatis Mulai untuk aplikasi ini.",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Pengiriman Latar Belakang Mungkin Terbatas",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Jangan ingatkan lagi",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("Nanti"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Buka Pengaturan",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Notifikasi push dinonaktifkan. Anda mungkin melewatkan pesan obrolan dan peringatan transfer.\n\nAktifkan notifikasi untuk aplikasi ini di pengaturan sistem.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notifikasi Dinonaktifkan",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Masukkan Ulang Kata Sandi",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Pilih kata sandi (8~18 karakter)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Konfirmasi Kata Sandi",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Tentang Aplikasi"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Keamanan"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaksi"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Bahasa"),
    "search": MessageLookupByLibrary.simpleMessage("Cari"),
    "verification": MessageLookupByLibrary.simpleMessage("verifikasi"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Jika saya kehilangan frasa rahasia saya, dana saya akan hilang selamanya.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Jika saya mengungkapkan atau membagikan frasa pemulihan saya kepada siapa pun, dana saya dapat dicuri.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Adalah tanggung jawab saya untuk menjaga frasa pemulihan saya tetap aman.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("Frasa pemulihan salah."),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Masukkan frasa pemulihan untuk dompet yang ingin Anda impor.",
    ),
  };
}
