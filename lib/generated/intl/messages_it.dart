// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a it locale. All the
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
  String get localeName => 'it';

  static String m0(deviceName, os) =>
      "Il tuo account è stato appena connesso su ${deviceName} (${os}). Se non sei stato tu, ti consigliamo di cambiare la password.";

  static String m1(price) => "Prezzo attuale: \$${price}";

  static String m2(symbol) => "Avviso prezzo · ${symbol}";

  static String m3(s) => "Invia nuovamente in ${s}s";

  static String m4(message) => "Acquisto non riuscito: ${message}";

  static String m5(productId) => "Acquisto riuscito: ${productId}";

  static String m6(productId) => "Ripristinato: ${productId}";

  static String m7(value) => "Importo superiore a ${value}.";

  static String m8(value) =>
      "Il portafoglio esiste già, il nome del portafoglio è \"${value}\"";

  static String m9(value) => "Inserisci un importo superiore a ${value}.";

  static String m10(value) => "Indirizzo duplicato alla riga ${value}";

  static String m11(value) =>
      "Saldo insufficiente: l\'importo totale supererebbe ${value} disponibile";

  static String m12(value) => "Indirizzo non valido alla riga ${value}";

  static String m13(value) => "Importo non valido alla riga ${value}";

  static String m14(value) => "Massimo ${value} destinatari";

  static String m15(token) => "Approva ${token} per continuare";

  static String m16(impact) =>
      "Elevato impatto sui prezzi (${impact})! Procedi con cautela.";

  static String m17(secs) => "Il preventivo scade tra ${secs}s";

  static String m18(value) => "Guadagna fino al ${value}% APY";

  static String m19(value) => "Aggiornamento automatico ogni ${value} secondi";

  static String m20(address) => "Conto ${address} aggiunto";

  static String m21(address, network) =>
      "Si vuole tracciare questo conto hardware wallet?\n\nIndirizzo: ${address}\nRete: ${network}";

  static String m22(app) => "Applicazione corrente: ${app}";

  static String m23(days) => "${days} giorni fa";

  static String m24(value) => "Importazione account fallita: ${value}";

  static String m25(date) => "Ultimo connesso: ${date}";

  static String m26(app) =>
      "Assicurarsi che l\'app ${app} sia aperta sul Ledger";

  static String m27(name) =>
      "Sei sicuro di voler rimuovere \"${name}\" dai dispositivi salvati?";

  static String m28(value) => "Stima gas: unità ~${value}";

  static String m29(reason) => "Motivo: ${reason}";

  static String m30(value) => "${value}d sciogliere";

  static String m31(value) => "${value} giorni rimanenti";

  static String m32(value) =>
      "L\'unstaking richiede ${value} giorni. I tuoi token saranno bloccati durante questo periodo.";

  static String m33(value) => "Non hai abbastanza \"${value}\"";

  static String m34(value) => "Impossibile recuperare l\'account \"${value}\"";

  static String m35(value) => "Minimo ${value} XRP per il primo trasferimento";

  static String m36(count) => "Aggiungi (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 nuovo token rilevato', other: '${count} rilevati nuovi token')} — tocca per rivedere";

  static String m38(value) => "Nessuna catena ${value} aggiunta.";

  static String m39(value) =>
      "${value} ha transazioni non completate, riprova più tardi.";

  static String m40(value) => "Nessun indirizzo trovato per ${value}.";

  static String m41(value) => "Saldo insufficiente di ${value}.";

  static String m42(value, value1) =>
      "Ogni account XRP deve riservare ${value} XRP (${value1} drops) come baseline, che non può essere speso.";

  static String m43(value, value1) =>
      "Per ogni oggetto posseduto dall\'account, ${value} XRP (${value1} drops) viene aggiunto alla riserva.";

  static String m44(value, value1) =>
      "Questo account possiede ${value} oggetti, il che significa che ${value1} XRP aggiuntivi sono riservati.";

  static String m45(value) => "Schema errato, ${value} tentativi rimanenti";

  static String m46(value) => "Schema errato, ${value} tentativo rimanente";

  static String m47(value) =>
      "Hai configurato con successo un ${value} e inizierai la verifica con N42Wallet!";

  static String m48(value) =>
      "Unisciti al mio gruppo ${value} su @N42Wallet per essere uno dei primi miner di una blockchain Layer 1, e ottieni criptovalute sul tuo telefono!";

  static String m49(value, value1) =>
      "Sei sicuro di voler bloccare ${value} N fino a ${value1} per eseguire un nodo?";

  static String m50(value) => "Importazione fallita:${value}";

  static String m51(value) =>
      "È necessario un saldo di staking di almeno ${value} per ricevere ricompense.";

  static String m52(value, value1) =>
      "${value} N ogni ${value1} blocchi estratti";

  static String m53(value) => "Deve essere di ${value} caratteri";

  static String m54(symbol) => "Importo (${symbol})";

  static String m55(amount, symbol) => "Saldo: ${amount} ${symbol}";

  static String m56(label) =>
      "Dichiarare “${label}” vincitore e liquidare? Irreversibile.";

  static String m57(n) => "${n} min";

  static String m58(n) => "Esito ${n}";

  static String m59(label, pct) => "${label} vince (${pct}%)";

  static String m60(shares, avg, after) =>
      "Stima ${shares} quote · media ${avg}% · dopo ${after}%";

  static String m61(label) => "Esito: ${label}";

  static String m62(n) => "Vendi ${n}";

  static String m63(value) => "Saldo insufficiente di ${value}.";

  static String m64(value) => "${value} in arrivo...";

  static String m65(value) =>
      "${value} scambiati nell\'app saranno distribuiti a breve nel tuo portafoglio e non possono essere venduti tramite questo processo. Possono essere utilizzati per gestire un nodo.";

  static String m66(value) => "Massimo ${value} caratteri";

  static String m67(value) => "La catena ${value} è già supportata dall\'APP!";

  static String m68(value) =>
      "La catena ${value} è già supportata dall\'APP, vuoi aggiungerla?";

  static String m69(value) =>
      "Test del collegamento dell\'indirizzo ${value} fallito!";

  static String m70(value) => "0~${value} caratteri";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Modifica"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verifica"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informazioni indirizzo",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copiato con successo"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copia indirizzo"),
    "descO": MessageLookupByLibrary.simpleMessage("Descrizione (Opzionale)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Cambia password",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Capito"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Nuovo accesso dispositivo",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Archivio"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Va sopra ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Scende sotto ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Avvisami quando il prezzo",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Abilita questo avviso",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Inserisci un prezzo valido maggiore di 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Imposta avviso"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Prezzo indicativo (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("Aggiorna avviso"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "I token possono essere inviati solo all\'interno della stessa rete. L\'invio da altre reti può causare la perdita dei fondi.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Scansiona per ricevere",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage("Inserisci l\'URL"),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Inserisci una descrizione",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Navigatore"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Svuota cache del browser",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Connetti automaticamente alla DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Chiudi tutto"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Fatto"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Cronologia"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Cancella tutta la cronologia",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Cancellare tutta la cronologia di navigazione?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage(
      "Cronologia cancellata",
    ),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Oggi"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Ieri"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Scopri DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Popolari"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DES"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Segnalibri"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Strumenti"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Nessun segnalibro aggiunto",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Segnalibro"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("Inserisci il nome"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Descrizione"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Accetta"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Il messaggio è stato eliminato",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transazioni"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Connetti"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("Reti disponibili"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("Firma messaggio"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage(
      "Connessione in corso",
    ),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Accoppiamento in corso, attendere.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Disconnetti"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Rifiuta"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("Bloccato"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage(
      "Attenzione",
    ),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Sicuro"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verificato",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Invia nuovamente il codice",
    ),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Suggerimenti per la scansione biometrica",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scansiona l\'impronta digitale o il viso per l\'autenticazione.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Suggerimenti"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Configura"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scansiona il viso o l\'impronta digitale per continuare.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Scansiona il codice QR con l\'app Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Oppure inserisci la chiave manualmente:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica a 6 cifre",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator richiesto per confermare ogni trasferimento.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Codice errato, riprova",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator non configurato",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Collegamento riuscito",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profilo"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Notizie"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verifica"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invita un amico"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Annullato"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Controlla la connessione di rete e riprova",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Nessun prodotto disponibile",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage(
      "Ripristina acquisti",
    ),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Ripristino acquisti in corso…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Store non disponibile",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Acquista"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Rimozione fallita!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Limite gas"),
    "g_key_105": MessageLookupByLibrary.simpleMessage(
      "Non ci sono altri elementi",
    ),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Caricamento "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Rubrica"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Importa portafoglio"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Gestisci"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Nuovo indirizzo"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Elimina"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Salva"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Copia"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Crea/Importa portafoglio",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Tema"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Sistema"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Chiaro"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Scuro"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Elenco portafogli"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Nessun dato"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Importo non valido"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portafoglio principale"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transazione completata"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Password errata"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Rete di prova"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Rete principale"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Lingua di sistema"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Imposta come portafoglio principale",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del portafoglio",
    ),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Scansiona per copiare l\'indirizzo",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Seleziona portafoglio di verifica",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Simbolo"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Incolla"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Scegli blockchain"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Transazione fallita"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Questo è il mio indirizzo del portafoglio",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Altro"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Salvato con successo"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Successo"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler eliminare il portafoglio?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Nessun permesso per accedere alla fotocamera.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Esploratore"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Massimo"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Asset"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Il registro è vuoto!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Riepilogo transazione"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Errore di collegamento, scansiona nuovamente il codice QR.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Modifica password"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Vecchia password"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Sincronizzazione saldi in corso...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Chiave privata"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password del portafoglio",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Errore chiave privata"),
    "g_key_213": MessageLookupByLibrary.simpleMessage(
      "Informazioni di mercato",
    ),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "Le password non corrispondono.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Aggiunta fallita!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Ricevi"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Trasferisci"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("A"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Scansiona codice QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage(
      "Inserisci un indirizzo del portafoglio",
    ),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Saldo disponibile"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Importo"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Fondi insufficienti per coprire questa transazione.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Invia"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Caricamento fallito!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Portafoglio"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Crea"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Da"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Conferma"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Annulla"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Tutti i token"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Impostazioni"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Account creato con successo",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Dettagli dell\'account",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Nome dell\'account",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il nome dell\'account",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Tipo di conto",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Aggiungi la tua prima operazione",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Aggiungi operazione",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calcolo indirizzo...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Calcolo indirizzo fallito. Riprova.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approvare"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Lotto"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Esecuzione atomica",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Esegui più operazioni contemporaneamente",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Invia più transazioni in un\'unica operazione",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "L\'esecuzione batch non è riuscita",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Nessun modello salvato",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Operazioni batch",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Risparmia gas",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Salva come modello",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Invio...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch inviato con successo",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Carica modello",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nome del modello",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il nome del modello",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Modello salvato",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Modelli"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transazione batch",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Approva e scambia in un\'unica transazione: niente più conferme in due passaggi",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Azioni batch con un clic",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsorizza transazioni o paga commissioni con token ERC-20 anziché ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Paga il gas con qualsiasi gettone",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Recupera l\'accesso tramite contatti fidati se perdi la chiave privata",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Recupero sociale",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Account smart ERC-7579 modulare con supporto per transazioni senza gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("di"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Catena"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage(
      "Identificativo della catena",
    ),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Cambiare"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Controlla lo stato",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Prossimamente",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Questo è un indirizzo controfattuale. Verrà distribuito alla tua prima transazione.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Crea un account intelligente",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Crea il tuo primo account intelligente",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Crea chiave di sessione",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Creato"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Personalizzato"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "L\'account verrà distribuito automaticamente alla tua prima transazione",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Distribuito"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Distribuzione...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "La distribuzione avverrà automaticamente con la prima transazione.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Sperimenta la prossima generazione di conti Ethereum con funzionalità migliorate",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Dettagli"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Account EOA/Smart ibrido: non è necessaria alcuna implementazione",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Errore"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gas stimato",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Esegui batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Scade"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fabbrica"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATUITO"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Stima del gas non riuscita, utilizzando l\'impostazione predefinita",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Pagamento del gas",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opzioni di pagamento del gas",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorizzato dal gas",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Senza gas"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transazioni senza gas e operazioni batch",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Account modulare con supporto plug-in di ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Etichetta"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Ultima attività",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "I miei conti intelligenti",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Nessun account intelligente ancora",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Nessun account corrisponde al filtro",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Nessuna operazione aggiunta",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Nessuna chiave di sessione",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Non distribuito",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Crea un account intelligente (gratuito, non è necessario ETH)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Finanzialo: ricevi qualsiasi token EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Effettua transazioni senza gas con Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operazioni"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Proprietario"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Paga il gas con il gettone",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Paga il gas con il tuo ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Paga con"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Paga con ETH",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "chain supportate",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Verifica disponibilità...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Copertura Chain",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Scegli come vuoi pagare le commissioni sulle transazioni sul gas",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Costo est.",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare opzioni gas",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("In sospeso"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage(
      "Autorizzazione",
    ),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Indirizzo di anteprima",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Pronto"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Ricevi indirizzo",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revoca"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler revocare questa chiave di sessione? La DApp autorizzata non sarà più in grado di eseguire transazioni.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revoca chiave di sessione",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Chiave di sessione revocata",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revocato"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revoca della chiave di sessione...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Conto multifirma con funzionalità di sicurezza avanzate",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("salvato"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Seleziona Catena",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Seleziona Responsabile dei pagamenti",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selezionato"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Invia token utilizzando il tuo account intelligente",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 giorno"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 ora"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 giorni"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 giorni"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "es. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Importo massimo",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Comprendo i permessi di questa chiave",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interagire con i contratti DApp approvati",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Creazione della chiave di sessione fallita",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Chiave di sessione creata",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "es. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Etichetta / Nome DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Dettagli chiave della sessione",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Valido per",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Rischio alto — solo DApp verificate",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Chiavi di sessione",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autorizza le DApp con accesso temporaneo al tuo account smart",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Accesso DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Controllo completo",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Solo invio",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Rischio alto",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Rischio basso",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Rischio medio",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Rivedi i permessi prima di confermare",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Scegli il livello di autorizzazione",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Trasferire token entro il limite impostato",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Account intelligente di base con unico proprietario: consigliato per la maggior parte degli utenti",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Conti intelligenti",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Portafoglio intelligente",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Limite di spesa",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorizzato (gratuito)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Conto intelligente",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Gas totale"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transazioni",
    ),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage(
      "Visualizza tutto",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Indirizzo"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'indirizzo",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Seleziona un tipo di moneta",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage(
      "Modifica indirizzo",
    ),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Eliminato con successo",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Scegli monete"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Cerca monete"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Funzionalità avanzate",
    ),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Aggiungi Destinatario",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Trasmissione...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Cancella Tutto",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Conferma il trasferimento batch",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continua"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Formato CSV: indirizzo,importo,etichetta",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Fatto"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Stima del gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Il trasferimento batch supporta solo le catene EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Esporta CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Aiuto per il trasferimento batch",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importa CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Il promemoria è facoltativo",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Utilizza Multicall3 per tariffe del gas più basse",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Nessun token supportato",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinatari",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleziona Gettone",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Invia token a più indirizzi in un\'unica transazione",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Firma..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Scorri verso sinistra per rimuovere un destinatario",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Trasferimento Multiplo",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Importo Totale",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Catena non supportata",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage(
      "Più Economico",
    ),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Riceverai (stimato)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Più Veloce"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Ottieni Preventivo",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Cronologia Bridge",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Nessun percorso disponibile",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Consigliato",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Aggiorna"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Percorso"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Cerca chain...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Seleziona"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleziona Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage(
      "Scivolamento",
    ),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Completato",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Fallito",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "In corso",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "In sospeso",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Bridge Fallito",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transazione in Sospeso",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Bridge Riuscito",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Bloccato fino al",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Verifica che il periodo di blocco sia scaduto prima di inviare il riscatto.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC ancora bloccato",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Riscatta vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Sbloccato: pronto per il riscatto",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Comprendo i rischi e desidero procedere",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Continua a puntare",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Come funziona",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC sarà bloccato fino alla scadenza del blocco temporale. Completa il processo di staking nell\'interfaccia sottostante.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Il tuo BTC sarà bloccato per l\'intero periodo di staking. Non è possibile il ritiro anticipato.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Il blocco è applicato da Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) e non può essere aggirato.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Rischio del contratto intelligente: sebbene controllato, nessun protocollo è completamente esente da rischi.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Puntata minima: 0,001 BTC. Periodo minimo di blocco: 0,125 giorni (~3 ore).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Avviso di rischio",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Il tuo BTC è bloccato in un indirizzo multisig 2 su 2 con un blocco temporale (CLTV), protetto dalla tua chiave e dalla chiave del contenitore N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Blocca i tuoi BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Dopo la conferma sulla catena, vBTC viene coniato nel tuo portafoglio con un rapporto 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "vBTC nuovo",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Mantieni vBTC per guadagnare premi di staking. vBTC è utilizzabile anche nei protocolli DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Guadagna premi",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Quando il periodo di blocco scade, brucia i tuoi vBTC per ricevere indietro i tuoi BTC originali.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Riscatta dopo lo sblocco",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Staking di autocustodia di BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Capito"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Seleziona un token con supporto NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Vai alla scheda NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Seleziona l\'NFT che desideri masterizzare",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Tocca il pulsante \"Masterizza\".",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Passaggi:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Per masterizzare un NFT, vai alla pagina dei dettagli NFT e tocca il pulsante \"Masterizza\".",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Questa catena non supporta ancora i trasferimenti, resta sintonizzato",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Tutti gli asset sono inferiori a \$ 1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Altri beni",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Tocca per mostrare tutto",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Recente"),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Approvato! Tocca Scambia per continuare.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Importo esatto",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Illimitato",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Approvazione illimitata: il router può spendere questo token in qualsiasi momento. Pratica standard, ma rischiosa se il contratto viene compromesso.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage(
      "Approvazione...",
    ),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Percorso Migliore",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Fonte Migliore",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Rete"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Conferma Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage("Stima Gas"),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Cronologia DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "minimo Ricevuto",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Nessun token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Nessun token trovato",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Grafico del prezzo",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impatto Prezzo",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Preventivo fallito",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca simbolo / nome / indirizzo",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Seleziona"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Slittamento massimo",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Confermato",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "In Attesa",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Quotato"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Scambia"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap inviato con successo",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Paghi"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("Ricevi"),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Prodotti attivi",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Trasferimento multiplo",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Brucia"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Compra N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Compra N con il protocollo AST",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Trasferimento a catena incrociata",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Scambio DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Inizia lo staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Registro"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Caricamento APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage(
      "Estrazione mineraria",
    ),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Guadagna di più"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Staking nativo di Solana",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Nessuna posizione attiva",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Guadagna premi partecipando al mining di nodi",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Strumenti rapidi",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Consigliato",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Seleziona tipo di scambio",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Partecipa a ETH con Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Scambia"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Guadagna"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Guadagni totali",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Visualizza tutto",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Indirizzo risolto aggiornato",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Avanzato"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Tassa annuale",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Disponibile"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Prezzo base"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Verifica disponibilità...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Impegnarsi"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Impegno fallito",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "L\'impegno di registrazione è scaduto. Avviare nuovamente il processo di registrazione.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Impegnarsi...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Conferma rinnovo",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Conferma e invia",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Conferma la risoluzione ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Indirizzo copiato",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Scadenza attuale",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "giorni rimasti",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Registra e gestisci i tuoi nomi di dominio .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Nome ENS rilevato",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Scade"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Estendere il periodo di registrazione",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizzazione della registrazione",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Inizia con ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Ottieni il tuo nome .eth",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Indirizzo non valido (deve essere 0x + 40 caratteri esadecimali)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nome ENS non valido",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("ora è tuo!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Tieni l\'app aperta durante la registrazione",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Gestisci la tua identità Web3",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimo 3 caratteri",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage(
      "I miei domini",
    ),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nome dell\'ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Nuova scadenza",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del nuovo proprietario",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Nessun dominio ancora",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Proprietario"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Per favore aspetta",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nome Premium",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Ripartizione dei prezzi",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primario"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nome principale impostato correttamente",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Elaborazione...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Registrati ENS",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Registrati"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "La tua identità decentralizzata su Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "La registrazione non è riuscita",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Registrati ora",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registrazione...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Informazioni sulla registrazione",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Periodo di registrazione",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Abilita promemoria scadenza",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notifica 30, 7 e 1 giorno prima della scadenza",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Rinnovare"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Estendi la registrazione del tuo dominio",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Rinnovo riuscito",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Indirizzo risolto",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Risoluzione dell\'ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Cerca"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Trova i nomi .eth disponibili",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca un nome .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome ENS da cercare",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Cerca e registrati",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage("Cerca ENS"),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Impossibile inviare al proprio indirizzo",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Servizio di nomi Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Imposta come principale",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nome standard",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Inizia la registrazione",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Passaggio 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Passaggio 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Passaggio 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Crea sottodominio",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Sottodominio creato",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Elimina sottodominio",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Questo sottodominio verrà eliminato definitivamente.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Sottodominio eliminato",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Nessun sottodominio ancora",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Utilizza solo lettere, numeri e trattini",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Etichetta del sottodominio",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "ad es. blog, posta, app",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del proprietario",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Lascia vuoto per utilizzare il portafoglio corrente",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Sottodomini"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Successo!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggerimenti",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Record di testo",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage(
      "Direttore dell\'ENS",
    ),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Totale"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Trasferimento"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Trasferisci la proprietà ad un altro indirizzo",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Trasferimento riuscito",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Il trasferimento è irreversibile. Assicurati che l\'indirizzo del nuovo proprietario sia corretto.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Prova un altro nome",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "La registrazione all\'ENS è un processo in due fasi",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Non disponibile",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Aspetta"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Il periodo di attesa impedisce attacchi front-running",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Un periodo di attesa impedisce il front-running",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("In attesa..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Verificare l\'indirizzo risolto prima di procedere. I nomi ENS possono essere trasferiti o modificati dal relativo proprietario.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("anno"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("anni"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "La tua identità",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Errore nell\'analisi dei dati di risposta!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Errore Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Errore di sintassi della richiesta",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Non autorizzato, effettua l\'accesso",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Accesso negato"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage(
      "Errore nella richiesta",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage("Richiesta scaduta"),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage(
      "Anomalia del server",
    ),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Servizio non implementato",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Errore gateway"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Servizio non disponibile",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Timeout del gateway",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Versione HTTP non supportata",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Richiesta fallita, codice errore:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Il sistema è occupato, riprova più tardi",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Frequenza delle richieste troppo elevata",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Decodifica fallita",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "La transazione è già sulla blockchain",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Errore di configurazione del certificato!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Errore di configurazione del codice di stato!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "Errore sconosciuto!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Connessione di rete scaduta, controlla le impostazioni di rete!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Il server presenta anomalie. Riprova più tardi!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Richiesta annullata, riprova!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Esporta keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Suggerimenti per il backup",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Usa uno strumento di gestione delle password per conservarla.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Copiato"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Copia annullata",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Portafoglio identità",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "File di chiave privata crittografata.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Metodo di importazione",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "File keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Inserisci le informazioni del keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Esporta chiave privata",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Ottenere il keystore e la password darà al possessore il pieno controllo sugli asset del portafoglio.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Annota con cura e conserva in un luogo sicuro. Mantenere più copie fisiche è il metodo di conservazione più sicuro.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Se la tua chiave privata viene persa, non può essere recuperata. Fai un backup fisico e conservala in modo sicuro.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Salva offline",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Non salvare in nessuna casella di posta, blocco note, cloud o software di chat non sicuro.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Utilizza la trasmissione di rete",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Assicurati di trasmetterla tramite strumenti di rete. Una volta che gli hacker la ottengono, causerà perdite economiche irreparabili",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Usa strumenti per salvare",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Capisco che chiunque ottenga questo file e la password ha il pieno controllo dei miei fondi — la perdita è permanente e non recuperabile",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password del wallet per confermare l\'esportazione",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password del wallet per visualizzare la chiave privata",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtra"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Avviso gas"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Avvisa quando sopra",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Avvisa quando è sotto",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Salva"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Soglia (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Tariffa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizzato"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Veloce"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "I prezzi del gas variano in base alla domanda della rete. Gas più basso = conferma più lenta, gas più alto = conferma più veloce.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage(
      "Tariffa Massima",
    ),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Rete congestionata",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Rete libera",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Rete normale",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Andamento dei prezzi",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Tariffa Prioritaria",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Prezzi del gas in tempo reale",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lento"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Norma"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage(
      "Localizzatore di gas",
    ),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Conto già importato",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Aggiungi Account",
    ),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Indirizzo copiato",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Assicurati che il tuo dispositivo sia sbloccato e che il Bluetooth sia abilitato prima di connetterti.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Controlla l\'app",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connetti il nuovo dispositivo",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Air-gap con Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connetti registro (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connetti Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connesso"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connessione...",
    ),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnetti"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connetti Keystone",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scansiona questo codice QR con il tuo dispositivo Keystone per firmare la transazione",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Punta la fotocamera verso il codice QR visualizzato sul tuo dispositivo Keystone",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scansiona la firma trapezoidale"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scansiona il codice QR dal tuo dispositivo Keystone per importare gli account",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tocca per scansionare la risposta Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Carica altro"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Caricamento conti...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Confermare sul dispositivo se richiesto",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Nessun conto trovato",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "Nessuna app è attualmente aperta",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo non connesso",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Non connesso",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Rimuovi dispositivo",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivi salvati",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivi supportati",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Oggi"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Impossibile connettersi a Trezor. Assicurati che l\'USB sia collegato.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connetti Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor si è connesso correttamente",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connessione a Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Collega il tuo dispositivo Trezor tramite cavo USB e sbloccalo",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Visualizza account",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Conti del Portafoglio",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Ieri"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Esiste già un portafoglio per questa valuta.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Impossibile leggere il keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Archivio chiavi",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Accedi"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Esci"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler uscire dall\'app?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navigatore"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegramma"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discordia"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage(
      "Capitalizzazione di mercato",
    ),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volume di scambio"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Offerta totale"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("In circolazione"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Informazioni"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Altro"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Link"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Sito web"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Gestisci catene",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage(
      "Disponibile",
    ),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Richiede picchettamento",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Inserisci la frase di recupero",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Totale"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transazione inviata"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del portafoglio non valido",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Equilibrio"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Questa azione è irreversibile. L\'NFT verrà inviato all\'indirizzo di masterizzazione.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage(
      "Masterizza NFT",
    ),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Raccolta"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contratto"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage(
      "Descrizione",
    ),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Impossibile caricare gli NFT. Tocca per riprovare.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Tutto"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Video"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Pavimento"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galleria NFT"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Iscrizione n.",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Nessun NFT trovato",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Nessun collegamento a Explorer disponibile",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Riproduzione video non supportata",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinali"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "I trasferimenti ordinali non sono ancora supportati",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Quantità"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca per nome o collezione",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Invia NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "I trasferimenti NFT Solana arriveranno presto",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage(
      "Identificativo del gettone",
    ),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Digitare"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Le password non corrispondono",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Seleziona dalla galleria del telefono",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Ripristina"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Usare cautela",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Verifica della sicurezza del contratto...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Rilevato rischio elevato",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contratto verificato sicuro",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Promemoria/Nota",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Promemoria/Nota (facoltativo)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Condividi codice QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Condividi link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metodo di condivisione",
    ),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "La transazione probabilmente fallirà",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulazione della transazione...",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "La simulazione della transazione è stata superata",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulazione non disponibile per questa rete",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chatta"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Posizioni attive",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Importo"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Importo da non partecipare",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("APY medio"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commissione",
    ),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Stima Premio giornaliero",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Stima Premio annuale",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Vai a Scambia",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Picchettamento liquido",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquido"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Il tuo token liquido può essere scambiato direttamente su DEX. Utilizza Scambia per scambiarlo nuovamente con la risorsa nativa.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Stake Minimo",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Nessuna posizione attiva da sbloccare",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage(
      "Nessuna serratura",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Nessuna posizione di staking ancora",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Nessun validatore trovato",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del portafoglio non disponibile",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Panoramica dello staking totale",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Le Mie Posizioni",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocolli"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Ricompense"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Cerca validatori...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Seleziona un validatore",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Seleziona una posizione da annullare",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Seleziona Validatore",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("Ordina per"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Palo"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Picchettato"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Inizia a puntare",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Puntata"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transazione preparata con successo",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Sbloccaggio",
    ),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Non partecipare",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validatore"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Riceverai",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Completato"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prezzo del gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage(
      "Commissione gas massima",
    ),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Commissione massima per gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("In attesa"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Procedi"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Password del portafoglio",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Password del portafoglio errata",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password del portafoglio",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage(
      "Tariffa commissione gas",
    ),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Media della tariffa gas dell\'ultimo blocco",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage(
      "Trasferimento in uscita",
    ),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Inserisci un numero intero maggiore di 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Impossibile recuperare i dati",
    ),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Verifica l\'account dell\'indirizzo di ricezione",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Trova"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Nessun account"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage(
      "Trasferimento in entrata",
    ),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Indirizzo non valido"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Verifica account riuscita",
    ),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'indirizzo di ricezione non ha un account, il primo trasferimento è di almeno 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilizzato"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Aggiungi",
    ),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Gettone aggiunto",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Deseleziona tutto",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Nessun nuovo token trovato",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignora",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Seleziona tutto",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Gettoni scoperti",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage(
      "Cronologia transazioni",
    ),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Dettaglio transazione",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Visualizza le ricevute delle transazioni nella cronologia",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Importo speso"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Importo ricevuto"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Data di inizio",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Intervallo di date",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Data di fine",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direzione",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Nessuna transazione corrisponde al filtro",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Trovata l\'ultima versione",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Aggiorna subito"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Nuova versione trovata",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Già all\'ultima versione",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Visualizza frase di recupero",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Ora prova a reinserire la tua frase di recupero.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Importa account"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Crea account"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Hai finito!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Ora puoi goderti appieno il tuo portafoglio.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Inizia"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Salta per ora"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Puoi saltare il backup della frase di recupero per ora e farlo in qualsiasi momento dalle Impostazioni se necessario.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Crea direttamente",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "Creato con successo",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Se vuoi controllare i dettagli del portafoglio o esportare il keystore, vai su Menu laterale > Gestisci portafoglio",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Esporta il mio keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Proteggi il tuo portafoglio con un backup",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Un keystore è un archivio di certificati di sicurezza e chiavi private associate.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Passaggio 1: Vai a Gestisci portafoglio.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Passaggio 2: Seleziona indirizzo del portafoglio.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Passaggio 3: Premi Esporta keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Vai a Gestisci portafoglio",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Torna alla homepage",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Aggiungi portafoglio",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Crea un portafoglio usando una frase di recupero.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nome per il portafoglio",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Non hai ancora fatto il backup della frase di recupero del portafoglio!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("Backup adesso"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Imposta password del portafoglio",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Backup portafoglio",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Annota la seguente frase di recupero",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Inizia"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "I dispositivi connessi a Internet possono esporre le tue informazioni. Ti consigliamo di annotare la frase di recupero e conservarla in modo sicuro.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Attenzione: non rivelare la tua frase di recupero a nessuno. N42Wallet non ti chiederà mai questa informazione. Sii estremamente prudente e conservala offline in modo sicuro. Se la tua frase di recupero viene esposta, potresti perdere tutti i tuoi asset e non poterli recuperare.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Attenzione: la frase di recupero è l\'unico modo per recuperare gli asset del tuo portafoglio.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage(
      "Passaggio successivo",
    ),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Clicca per visualizzare la frase di recupero",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Assicurati che non ci siano altre persone o telecamere nelle vicinanze",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Conferma frase di recupero",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Informazioni del portafoglio",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage(
      "Nome del portafoglio",
    ),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Fai prima il backup della frase di recupero del portafoglio!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Verifica frase di recupero",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Ora inserisci la tua frase di recupero.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Imposta frase"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Assicurati di annotare la tua frase di recupero e conservarla in modo sicuro. Ne avrai bisogno per importare o recuperare il tuo portafoglio di criptovalute.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Modifica portafoglio",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Ora"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Risultato"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Hash della transazione",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Percorso"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Blocco"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Valore"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Accelera"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Nota"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Il token corrente non è stato aggiunto.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Inserisci la tua frase di recupero con le parole separate da spazi",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importa portafoglio",
    ),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Il saldo del token corrente è insufficiente.",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Errore di firma"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Gestisci portafoglio",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'indirizzo Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Il portafoglio solo orologio non può inviare o firmare transazioni",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Guarda Portafoglio",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Tieni traccia di qualsiasi indirizzo EVM senza chiave privata",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Riservato"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Riserva base"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Riserva incrementale"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Conteggio oggetti posseduti",
    ),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Come calcolare l\'importo totale riservato",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Riserva totale = Riserva base + (Conteggio oggetti posseduti × Riserva incrementale)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID e Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Password gestuale"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Imposta password gestuale",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Disegna il tuo schema gestuale",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Conferma il tuo schema gestuale",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Disegna il gesto attuale",
    ),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Reimposta password gestuale",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Troppi tentativi falliti, riprova",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Aggiungere password del portafoglio?",
    ),
    "g_lock_key25": m46,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Password gestuale non impostata",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Autenticazione gestuale richiesta per confermare ogni trasferimento.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Riuscito"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Il riconoscimento biometrico non è abilitato",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Aggiungere la verifica biometrica?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage(
      "Cambiamento 30D",
    ),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage(
      "Cambiamento 7D",
    ),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("AT"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage(
      "Profondità del mercato",
    ),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Nessuna lista di controllo ancora",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Alta 24 ore"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Punteggio di liquidità",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Basso 24 ore"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Novità"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Nessun dato grafico",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Nessun risultato",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Rango"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Cerca"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca monete...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Tendenza"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Lista di controllo",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Il punteggio di inattività del validatore è alto. Controlla lo stato del nodo per evitare sanzioni.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Sbloccare N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Attività di verifica cloud",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Impostazioni di verifica",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Musica di verifica di sottofondo",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Predefinito"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Muto"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Quando la verifica in background è abilitata, la musica verrà riprodotta in sottofondo. Se la musica si interrompe, si interromperà anche la verifica.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Il tuo livello"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "La configurazione richiede una piccola quantità per il gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Hai aderito con successo a un nodo di gruppo su N42Wallet. Condividi il link per invitare amici, attiva il nodo e inizia la verifica!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Condividi con gli amici",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Continua"),
    "g_mining_key63": m47,
    "g_mining_key73": m48,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Ho appena configurato un nodo su @N42Wallet e ho iniziato la verifica su dispositivi mobili! Vieni a unirti a me. Il futuro decentralizzato è mobile!",
    ),
    "g_mining_key76": m49,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Minerale"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Nodo"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Rete"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Passa da testnet a mainnet per il cloud mining.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Riscatto disponibile dopo 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Le richieste precedenti non verranno elaborate.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Casa"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Ricompensa di oggi",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Tratta i dati qui sotto come una chiave importante. Ti consigliamo di copiarli e salvarli immediatamente in una posizione affidabile.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copia dati"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inattivo"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Importazione riuscita",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "I dati crittografati non possono essere vuoti!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "La password non può essere vuota!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Decrittazione fallita. Verifica che la password sia corretta!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Formato dati crittografati non supportato!",
    ),
    "g_mining_key_109": m50,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Ricompense di ieri",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Dati crittografati",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Importa file"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Inserisci i dati crittografati.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage(
      "Importazione in corso...",
    ),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Conferma"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Il riscatto richiede un po\' di tempo, attendi un momento!",
    ),
    "g_mining_key_116": m51,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "La ricompensa si accumula giornalmente e viene inviata al tuo portafoglio N solo quando raggiunge ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Ricompense totali",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valore estratto"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Dettagli del compito",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Sommario"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Attività"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Valore totale estratto",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("Verifica da"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Numero di profitti",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Valore verificato",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Seleziona piani"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Periodo di sblocco: sbloccabile in qualsiasi momento",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Ricompensa massima annuale",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Distribuzione ricompense",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage(
      "Limite giornaliero",
    ),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Velocità"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Piani di verifica",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Seleziona il metodo di pagamento",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage(
      "Metodi di pagamento",
    ),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Paga con N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage(
      "Saldo del portafoglio",
    ),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Non hai abbastanza N per questa transazione",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler saltare?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Non riceverai alcun premio di verifica finché non sceglierai 1 dei piani.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Disabilitato"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Ricompensa"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Vedi altro"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Stato della verifica",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Per sbloccare"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Salta"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Ultimi 7 giorni"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage("Premi accumulati"),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Blocca N per iniziare a verificare e ottenere ricompense.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("Premi ricevuti"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Avanzato"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Base"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("NODO COMPLETO"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MIN/GIORNO"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nodo avanzato"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nodo base"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nodo pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocchi/giorno~70 min",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Data di sblocco"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocchi/giorno~15 min",
    ),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 secondi per verifica",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "La catena di test è in fase di aggiornamento e i blocchi non possono essere verificati temporaneamente.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Il mancato completamento delle attività per quattro giorni consecutivi comporterà l\'assenza di guadagni e il rischio di penalità.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage(
      "Punteggio di rischio",
    ),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Riscatta"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Salva prima la coppia di chiavi pubblica e privata del validatore.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Esporta"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Orario di verifica di oggi",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Fondi insufficienti per il trasferimento.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Elenco validatori",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Importa validatore",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Il validatore esiste già",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Rischio basso"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Rischio moderatamente",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Ricompense degli ultimi 7 giorni",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Rischio alto"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Il contratto è in caricamento e non può essere verificato in questo momento. Attendi un momento!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Suggerimenti di sicurezza",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Verifica in background",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Conserva la tua chiave privata o frase di recupero in modo sicuro.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "La tua chiave privata o frase di recupero è l\'unica credenziale per accedere agli asset del tuo portafoglio.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Conservala in un luogo sicuro (carta, gestore di password, ecc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Non fare screenshot, non caricarla su Internet e non condividerla con nessuno.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Una volta persa o compromessa, gli asset del tuo portafoglio non possono essere recuperati.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("Conferma e salva"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Imposta una password e cripta",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password di crittografia",
    ),
    "g_mining_key_98": m53,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Reinserisci la password per assicurarti che sia corretta",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Dettaglio Nodo Completo",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID Nodo"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Connesso"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage(
      "WS Disconnesso",
    ),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Riconnessione",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Scadenza"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Periodo di sblocco:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Sbloccabile in qualsiasi momento",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Nessuna notizia disponibile",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Torna Indietro (Sicuro)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Procedi Comunque",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Questo sito web è stato identificato come potenzialmente dannoso. Potrebbe tentare di rubare i tuoi asset crypto o le chiavi private.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Avviso di Sicurezza",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "URL Sospetto:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Aggiungi commercio",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Costo medio"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Prezzo di acquisto (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base di costo"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Quantità"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Salva"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Profitti e perdite non realizzati",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Cambio 24 ore"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Tutti gli asset",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Allocazione delle risorse",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "I migliori vincitori",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("Peggiori"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("Traslochi 24h"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Nessuna risorsa trovata",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Altri"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Totale"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portafoglio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Valore totale"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage(
      "Aggiungi esito",
    ),
    "g_pred_amount_input": m54,
    "g_pred_balance": m55,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Compra"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Annulla e rimborsa",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("Solo chiudi"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Chiuso, in attesa di esito",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Conferma esito",
    ),
    "g_pred_confirm_resolve_msg": m56,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Avvia previsione",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Creazione…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Scadenza"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Almeno due esiti validi",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Inserisci una domanda",
    ),
    "g_pred_minutes": m57,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("No"),
    "g_pred_outcome_n": m58,
    "g_pred_outcome_win": m59,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Esiti"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Scegli l’esito vincente per liquidare (fondi in base al risultato)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Elaborazione…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Pubblica"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Domanda di previsione, es.: Chi vince questo round?",
    ),
    "g_pred_quote_info": m60,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Risolto"),
    "g_pred_result_label": m61,
    "g_pred_sell_n": m62,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Illimitato (chiusura manuale)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Sì"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Scaricato"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Codice invito",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invitati"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Nodi di mining"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Ricompensa (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Mining Classico (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Estrazione mineraria (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Interfaccia di Mining",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Condividi"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Rinvio"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Invita amici e ottieni token N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Ottieni fino a "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N quando il tuo referral inizia la verifica!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Invita tramite"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Collegamento"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("codice"),
    "g_swap_key_14": m63,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Errore nel recupero del prezzo della moneta.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Procedendo, accetti i seguenti ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Termini e condizioni.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Fine"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Il tuo scambio sarà distribuito a breve. Attendi con pazienza.",
    ),
    "g_swap_key_20": m64,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Costi per gestire un nodo: Verifica di gruppo 1-49 N Nodo base: 50 N Nodo premium: 100 N Nodo pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Non pagato"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Conferma pagamento in corso",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Da distribuire"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Riepilogo scambio"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Nuovo saldo"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Paghi"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Data"),
    "g_swap_key_31": m65,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Gli scambi possono essere visualizzati sugli esploratori della blockchain pertinenti (Etherscan, BscScan, TRONSCAN e il nostro).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Scambia in N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Scambia"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Ricevi"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Anteprima scambio"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Colore accento",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Ripristina le impostazioni predefinite",
    ),
    "g_token_m_key_1": m66,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Chiunque può creare un token, incluse versioni false di token esistenti. Fai sempre ricerche su un token prima di importarlo.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Token"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Cerca token"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage(
      "Nome della catena",
    ),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage(
      "Simbolo della catena",
    ),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID della catena"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Decimali"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Aggiungi catena personalizzata",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 unità"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Aggiungi token"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Errore di formato!",
    ),
    "g_token_m_key_22": m67,
    "g_token_m_key_23": m68,
    "g_token_m_key_24": m69,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Importa token"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Tutte le reti"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Token personalizzato",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del token",
    ),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage(
      "Simbolo del token",
    ),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Decimali del token",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importa"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Attenzione"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Alto Rischio"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Sicuro"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Più tardi"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Connessione persa. Si prega di riconnettersi.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "La DApp si è disconnessa",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Disconnetti tutto",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Disconnettersi da tutte le DApp?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Disconnettersi da questa DApp?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Nessuna connessione attiva",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Scansiona un codice QR per connetterti a una DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "La richiesta di connessione è scaduta",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "La sessione è scaduta",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("DApp connesse"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Collega",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Avviso importante",
    ),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_password": MessageLookupByLibrary.simpleMessage("Parola d\'ordine"),
    "next": MessageLookupByLibrary.simpleMessage("Avanti"),
    "nicknameMessage": m70,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Modifica profilo",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografia"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'indirizzo",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Non ricordare più",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Più tardi",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Vai alle impostazioni",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Le notifiche push sono disabilitate. Potresti perdere messaggi in chat e avvisi di trasferimento.\n\nAbilita le notifiche per questa app nelle impostazioni di sistema.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notifiche disabilitate",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Reinserisci la password",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Scegli una password (8~18 caratteri)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Conferma password",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Informazioni sull\'app"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Sicurezza"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transazione"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Lingua"),
    "search": MessageLookupByLibrary.simpleMessage("Cerca"),
    "verification": MessageLookupByLibrary.simpleMessage("verifica"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Se perdo la mia frase segreta, i miei fondi saranno persi per sempre.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Se rivelo o condivido la mia frase di recupero con qualcuno, i miei fondi possono essere rubati.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "È mia responsabilità mantenere la mia frase di recupero al sicuro.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Frase di recupero errata.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Inserisci la frase di recupero del portafoglio che vuoi importare.",
    ),
  };
}
