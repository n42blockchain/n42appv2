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

  static String m3(value) => "Sono ${value}";

  static String m4(value) => "Membri chat (${value})";

  static String m5(value) =>
      "Sei sicuro di voler aggiungere ${value} come amico";

  static String m6(email) => "Codice di verifica inviato a ${email}";

  static String m7(s) => "Invia nuovamente in ${s}s";

  static String m8(value) =>
      "Sei già associato e non puoi essere riassociato al momento. Indirizzo associato: ${value}.";

  static String m9(value) =>
      "Associazione riuscita. Indirizzo associato: ${value}";

  static String m10(value) => "Non c\'è N42chain nel portafoglio ${value}!";

  static String m11(value) => "Corrispondenza riuscita. Indirizzo:${value}.";

  static String m12(value) => "Importo superiore a ${value}.";

  static String m13(value) =>
      "Il portafoglio esiste già, il nome del portafoglio è \"${value}\"";

  static String m14(value) => "Inserisci un importo superiore a ${value}.";

  static String m15(gas) =>
      "Il gas di esecuzione (${gas}) è alto. Il contratto chiamato potrebbe consumare più gas del previsto.";

  static String m16(gas) =>
      "La prima transazione include il deployment dell\'account (~${gas} gas). Le transazioni successive saranno più economiche.";

  static String m17(gas) =>
      "L\'overhead gas del paymaster (${gas}) è alto. Le transazioni senza gas potrebbero costare di più.";

  static String m18(gas) =>
      "Il gas totale stimato (${gas}) è insolitamente alto. Controlla la tua transazione per errori.";

  static String m19(gas) =>
      "Il gas di verifica (${gas}) potrebbe essere troppo alto. Ciò può accadere con logica account complessa.";

  static String m20(value) => "${value} giorni rimanenti";

  static String m21(value) => "Indirizzo duplicato alla riga ${value}";

  static String m22(value) =>
      "Saldo insufficiente: l\'importo totale supererebbe ${value} disponibile";

  static String m23(value) => "Indirizzo non valido alla riga ${value}";

  static String m24(value) => "Importo non valido alla riga ${value}";

  static String m25(value) => "Massimo ${value} destinatari";

  static String m26(token) => "Approva ${token} per continuare";

  static String m27(impact) =>
      "Elevato impatto sui prezzi (${impact})! Procedi con cautela.";

  static String m28(secs) => "Il preventivo scade tra ${secs}s";

  static String m29(value) => "+${value} punti/giorno";

  static String m30(value) => "Guadagna fino al ${value}% APY";

  static String m31(value) => "Congratulazioni! Ora possiedi ${value}";

  static String m32(value) => "Attendi ${value} secondi";

  static String m33(value) => "Aggiornamento automatico ogni ${value} secondi";

  static String m34(address) => "Conto ${address} aggiunto";

  static String m35(address, network) =>
      "Si vuole tracciare questo conto hardware wallet?\n\nIndirizzo: ${address}\nRete: ${network}";

  static String m36(app) => "Applicazione corrente: ${app}";

  static String m37(days) => "${days} giorni fa";

  static String m38(value) => "Importazione account fallita: ${value}";

  static String m39(date) => "Ultimo connesso: ${date}";

  static String m40(value) =>
      "Per favore apri l\'app ${value} sul tuo dispositivo";

  static String m41(app) =>
      "Assicurarsi che l\'app ${app} sia aperta sul Ledger";

  static String m42(name) =>
      "Sei sicuro di voler rimuovere \"${name}\" dai dispositivi salvati?";

  static String m43(value) => "Guadagna punti ${value}";

  static String m44(value) =>
      "Guadagna ${value} punti per ogni amico che si iscrive!";

  static String m45(value) => "${value} punti per il prossimo livello";

  static String m46(amount, token) => "≈ ${amount}${token}";

  static String m47(amount) => "≈ ${amount} USDT";

  static String m48(value) => "Stima gas: unità ~${value}";

  static String m49(reason) => "Motivo: ${reason}";

  static String m50(value) =>
      "Sei sicuro di voler eliminare il contatto ${value}?";

  static String m51(value) => "${value}d sciogliere";

  static String m52(value) => "${value} giorni rimanenti";

  static String m53(value) => "${value} giorni rimanenti";

  static String m54(value) =>
      "L\'unstaking richiede ${value} giorni. I tuoi token saranno bloccati durante questo periodo.";

  static String m55(value) => "Non hai abbastanza \"${value}\"";

  static String m56(value) => "Impossibile recuperare l\'account \"${value}\"";

  static String m57(value) => "Minimo ${value} XRP per il primo trasferimento";

  static String m58(value) => "${value}d fa";

  static String m59(value) => "${value}h fa";

  static String m60(value) => "${value}m fa";

  static String m61(count) => "Aggiungi (${count})";

  static String m62(count) =>
      "${Intl.plural(count, one: '1 nuovo token rilevato', other: '${count} rilevati nuovi token')} — tocca per rivedere";

  static String m63(value) => "Codice di verifica inviato a ${value}";

  static String m64(value) => "Nessuna catena ${value} aggiunta.";

  static String m65(value) =>
      "${value} ha transazioni non completate, riprova più tardi.";

  static String m66(value) => "Nessun indirizzo trovato per ${value}.";

  static String m67(value) => "Saldo insufficiente di ${value}.";

  static String m68(value, value1) =>
      "Ogni account XRP deve riservare ${value} XRP (${value1} drops) come baseline, che non può essere speso.";

  static String m69(value, value1) =>
      "Per ogni oggetto posseduto dall\'account, ${value} XRP (${value1} drops) viene aggiunto alla riserva.";

  static String m70(value, value1) =>
      "Questo account possiede ${value} oggetti, il che significa che ${value1} XRP aggiuntivi sono riservati.";

  static String m71(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativi";

  static String m72(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativo";

  static String m73(value) =>
      "Hai configurato con successo un ${value} e inizierai la verifica con N42Wallet!";

  static String m74(value) =>
      "Unisciti al mio gruppo ${value} su @N42Wallet per essere uno dei primi miner di una blockchain Layer 1, e ottieni criptovalute sul tuo telefono!";

  static String m75(value, value1) =>
      "Sei sicuro di voler bloccare ${value} N fino a ${value1} per eseguire un nodo?";

  static String m76(value) => "Importazione fallita:${value}";

  static String m77(value) =>
      "È necessario un saldo di staking di almeno ${value} per ricevere ricompense.";

  static String m78(value, value1) =>
      "${value} N ogni ${value1} blocchi estratti";

  static String m79(value) => "Deve essere di ${value} caratteri";

  static String m80(value) => "Saldo insufficiente di ${value}.";

  static String m81(value) => "${value} in arrivo...";

  static String m82(value) =>
      "${value} scambiati nell\'app saranno distribuiti a breve nel tuo portafoglio e non possono essere venduti tramite questo processo. Possono essere utilizzati per gestire un nodo.";

  static String m83(value) => "Massimo ${value} caratteri";

  static String m84(value) => "La catena ${value} è già supportata dall\'APP!";

  static String m85(value) =>
      "La catena ${value} è già supportata dall\'APP, vuoi aggiungerla?";

  static String m86(value) =>
      "Test del collegamento dell\'indirizzo ${value} fallito!";

  static String m87(value) =>
      "L\'applicazione si sbloccherà tra ${value} secondi.";

  static String m88(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativi";

  static String m89(value) =>
      "Errore inserimento password, hai ${value} tentativi";

  static String m90(value) =>
      "Errore inserimento password, hai ${value} tentativo";

  static String m91(value) => "Inserisci la password ${value}";

  static String m92(value) => "0~${value} caratteri";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Registrati"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Crea il tuo account",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Modifica"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verifica"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informazioni indirizzo",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Account temporaneamente bloccato per un giorno",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Il codice non è corretto. Riprova.",
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
    "editPhoto": MessageLookupByLibrary.simpleMessage("Modifica foto"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Impossibile ottenere il codice di autenticazione",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Codice di autenticazione inviato con successo, controlla la tua email",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Errore codice di autenticazione",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Indirizzo email non valido",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticazione indirizzo email",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "L\'app di autenticazione dell\'indirizzo email protegge i tuoi prelievi e l\'account N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Aggiungere la verifica email?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Archivio"),
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "Salva questa chiave — ne avrai bisogno se perdi il telefono.",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("Condividi"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "Chiave di backup Google Authenticator di N42Wallet",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice Google Authenticator a 6 cifre per disabilitare il 2FA.",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Disabilita Google 2FA",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Impossibile disabilitare Google 2FA. Verifica il codice e riprova.",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FA è stato disabilitato",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Inserisci un codice valido di 6 cifre",
    ),
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
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "Troppi tentativi. Biometria bloccata — usa il codice.",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "Biometria non configurata. Abilitala nelle Impostazioni.",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Usa Face ID / Touch ID",
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
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Conferma la connessione alla DApp",
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
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Avvia chat di gruppo",
    ),
    "g_chat_key_10": m3,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Invita amici"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Seleziona contatto"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Fine"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Seleziona almeno 2 contatti",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Dettagli amico"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Dettagli gruppo"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Vedi altri membri del gruppo",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Nome del gruppo"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Nuovo amico"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler sciogliere il gruppo?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler lasciare questo gruppo?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Sciogli gruppo"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Lascia gruppo"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Cambia il nome della chat di gruppo",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Quando il nome della chat di gruppo viene modificato, gli altri membri saranno notificati all\'interno del gruppo.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Fine"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Richiesta di amicizia",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Richiesta di aggiungerti come amico",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Richiesta di amicizia approvata",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Aggiunto"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Sei stato aggiunto come amico",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("Accetta"),
    "g_chat_key_32": m4,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "La password non può essere analizzata correttamente e il messaggio non può essere inviato temporaneamente. Importa il portafoglio quando entri nel gruppo",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Eliminare la cronologia chat?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Rimuovi membro"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Il mio codice QR"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Segnala"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Nuova chat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Nuovo gruppo"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Codice QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("Segnala e blocca"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Questo messaggio sarà inoltrato a N42Wallet. Questo contatto non sarà notificato.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Foto"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Elimina messaggio"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Elimina sul mio dispositivo",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Attendi"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Accetta"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage(
      "Motivo della segnalazione",
    ),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Inserisci il motivo della segnalazione",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Verificheremo la tua segnalazione e risponderemo entro 24 ore.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Hai segnalato questo - Clicca per vedere",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Lista nera"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "g_chat_key_6": m5,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage(
      "Nessun contatto ancora",
    ),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Oggi"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Più di 3 giorni fa"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Blocca"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Ehi, sto usando N42Wallet per chattare e inviare denaro. Installa Wallet e scrivimi a",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Rispondi"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Il messaggio è stato eliminato",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Qualcuno ti ha menzionato",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Saluta"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Aggiungi amici"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage(
      "Motivo della richiesta",
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
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "Sicurezza delle DApp",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verificato",
    ),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Sincronizza anche l\'e-mail dell\'account di chat",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← Cambia indirizzo email",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Entrambi gli account sono stati aggiornati correttamente!",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "Cambia e-mail",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice chat di 6 cifre",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Codice chat inviato a",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Conferma la sincronizzazione della chat",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Impossibile inviare il codice chat",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Invio del codice di verifica chat...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Sincronizza l\'e-mail dell\'account chat",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice a 6 cifre",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage(
      "Codice inviato nuovamente",
    ),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Codice errato, riprova",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Conferma modifica",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Conferma e continua con la sincronizzazione della chat",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "E-mail attuale",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice a 6 cifre",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Inserisci un nuovo indirizzo email",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Indirizzo e-mail non valido",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "La nuova email deve essere diversa dall\'email corrente",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "E-mail N42 aggiornata. L\'e-mail di chat può essere aggiornata in Chat > ​​Impostazioni.",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "Email del conto N42 aggiornata",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci il nuovo indirizzo email",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "Nuovo indirizzo e-mail",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password",
    ),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Password attuale (per Chat)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Password richiesta per la sincronizzazione della chat",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Invia nuovamente il codice",
    ),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Invia codice di verifica",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Salta"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Salta: l\'e-mail di N42 è già aggiornata",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "Email aggiornata con successo",
    ),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Suggerimenti per la scansione biometrica",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scansiona l\'impronta digitale o il viso per l\'autenticazione.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "La scansione biometrica non ha funzionato",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Suggerimenti"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Scansione biometrica riuscita",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Configura"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Non hai configurato l\'accesso biometrico. Vai alle Impostazioni di sistema per configurarlo.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scansiona il viso o l\'impronta digitale per continuare.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Si consiglia di riattivare la biometria.",
    ),
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "Volto non rilevato. Guarda direttamente la telecamera e riprova.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Metodo di riconoscimento facciale",
    ),
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Riassocia"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Associa"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Verifica"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Puoi associare i tuoi dati facciali direttamente a un indirizzo del portafoglio (se ne hai associato uno in precedenza, il vecchio indirizzo verrà sovrascritto), oppure se hai già associato un indirizzo, puoi anche verificare manualmente per recuperare l\'indirizzo associato.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "È stato rilevato che l\'indirizzo del portafoglio collegato ai tuoi dati facciali è il seguente, ma non hai ancora importato questo portafoglio nel tuo elenco portafogli.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Hai collegato i tuoi dati facciali a questo portafoglio.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Avviso per l\'utente",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Cos\'è l\'associazione facciale?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "L\'associazione facciale utilizza la tecnologia di riconoscimento facciale per abbinare le caratteristiche biometriche del tuo viso con l\'indirizzo del tuo portafoglio blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Questo processo non solo migliora la comodità delle transazioni, ma rafforza anche la sicurezza dell\'account, garantendo che ogni azione sia autorizzata da te.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Perché è necessaria l\'associazione facciale?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Associando i tuoi dati facciali, la tua identità è direttamente collegata alle attività di transazione, semplificando il processo di verifica dell\'identità e migliorando l\'efficienza operativa. Questa tecnologia garantisce una verifica dell\'identità rapida e sicura quando si eseguono operazioni sensibili come il trasferimento di asset o l\'interazione con contratti.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Come vengono memorizzati i miei dati facciali e sono sicuri?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "I tuoi dati facciali sono memorizzati in forma crittografata su una blockchain pubblica, non in alcun database centralizzato. Ciò significa che il sistema può decrittare e utilizzare i tuoi dati per la verifica dell\'identità solo quando autorizzato da te, garantendo la tua privacy e la sicurezza dei dati.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Come influisce l\'associazione facciale sulla sicurezza del mio account?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "L\'associazione facciale migliora la sicurezza del tuo account assicurando che tutte le azioni sensibili vengano eseguite solo con la tua esplicita autorizzazione. Utilizziamo la tecnologia di crittografia leader del settore per proteggere i tuoi dati biometrici, prevenendo accessi non autorizzati.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "I miei dati facciali sono sicuri?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Assolutamente. Tutti i dati biometrici sono sottoposti a crittografia rigorosa e vengono seguiti i più alti standard di sicurezza per la trasmissione e l\'archiviazione dei dati. Il sistema decritterà questi dati solo quando necessario per completare la verifica dell\'identità.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Corrispondenza fallita!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Capito"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Seleziona indirizzo del portafoglio",
    ),
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Dissociazione"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Verifica dei dati facciali fallita!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Dissociazione dei dati facciali fallita!",
    ),
    "g_face_match_key4": m11,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage(
      "Errore indirizzo!",
    ),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Associazione dati facciali",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Riconoscimento facciale",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Riseleziona"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Abbina"),
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "Errore di rete. Controlla la connessione e riprova.",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "Impossibile avviare il riconoscimento facciale. Riprova.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profilo"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Notizie"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verifica"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Messaggi"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Impara"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invita un amico"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Rimozione fallita!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Invia"),
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
    "g_key_135": m12,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portafoglio principale"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transazione completata"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Password errata"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Rete di prova"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Rete principale"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Lingua di sistema"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Imposta come portafoglio principale",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Invia"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Nessun permesso per accedere all\'album fotografico.",
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
    "g_key_211": MessageLookupByLibrary.simpleMessage("Acquista"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Vendi"),
    "g_key_213": MessageLookupByLibrary.simpleMessage(
      "Informazioni di mercato",
    ),
    "g_key_214": m13,
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
    "g_key_46": m14,
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("Nota"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Frase di recupero"),
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
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "Questo indirizzo è precalcolato e verrà distribuito quando effettuerai la prima transazione.",
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
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Trasferimento in batch",
    ),
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
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Account Biconomy",
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
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage(
      "Cancella tutto",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Prossimamente",
    ),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continua"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contratto"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Indirizzo controfattuale",
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
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Crea un account intelligente per iniziare",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Crea chiave di sessione",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Le chiavi di sessione consentono alle DApp di eseguire transazioni per tuo conto con autorizzazioni limitate e vincoli di tempo.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Crea un account intelligente",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Creato"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Personalizzato"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Distribuire"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "L\'account verrà distribuito automaticamente alla tua prima transazione",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Distribuzione non riuscita",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Distribuzione non riuscita. Per favore riprova.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "La distribuzione è iniziata",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Distribuito"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "L\'account è pronto per l\'uso",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Distribuzione...",
    ),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "La transazione di distribuzione è in fase di elaborazione",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "La distribuzione avverrà automaticamente con la prima transazione.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Sperimenta la prossima generazione di conti Ethereum con funzionalità migliorate",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Dettagli"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "Conto EIP-7702",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Account EOA/Smart ibrido: non è necessaria alcuna implementazione",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Errore"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gas stimato",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage("Stima..."),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Esegui batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Scade"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fabbrica"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Raggruppa più transazioni",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Paga il gas con qualsiasi gettone",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Maggiore sicurezza",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATUITO"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage(
      "Accesso completo",
    ),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Stima del gas",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Stima del gas non riuscita, utilizzando l\'impostazione predefinita",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Pagamento del gas",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opzioni di pagamento del gas",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Risparmio di gas",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorizzato dal gas",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Gas di Esecuzione Alto",
    ),
    "g_key_aa_gas_warn_call_high_desc": m15,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Overhead Gas di Deployment",
    ),
    "g_key_aa_gas_warn_deploy_desc": m16,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Overhead Paymaster Alto",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m17,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite Gas Molto Alto",
    ),
    "g_key_aa_gas_warn_total_high_desc": m18,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possibile Sottostima del Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Il gas effettivamente utilizzato potrebbe superare la stima. Considera di aggiungere un buffer maggiore.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas di Verifica Alto",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m19,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Senza gas"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transazioni senza gas e operazioni batch",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Astrazione del conto",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Proprio adesso"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Conto del kernel",
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
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Mai"),
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
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Il conto verrà distribuito alla prima transazione",
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
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage("Saldo"),
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
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "Non disponibile su questa chain",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "Preventivo scaduto",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage(
          "Sponsorizzazione non disponibile",
        ),
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
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Consigliato"),
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
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Conto sicuro",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Conto multifirma con funzionalità di sicurezza avanzate",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Guardiani",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Soglia"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("salvato"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Seleziona Catena",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Seleziona Responsabile dei pagamenti",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Seleziona Tipo di account",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selezionato"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Invia token utilizzando il tuo account intelligente",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage(
      "Trasferimento AA",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 giorno"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 ora"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 giorni"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 giorni"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage(
      "Consentito",
    ),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "es. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Importo massimo",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage(
      "Bloccato",
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
    "g_key_aa_simple_account": MessageLookupByLibrary.simpleMessage(
      "Conto semplice",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Account intelligente di base con unico proprietario: consigliato per la maggior parte degli utenti",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Conto intelligente",
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
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage(
      "Valore totale",
    ),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transazioni",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage(
      "Non disponibile",
    ),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage(
      "Visualizza tutto",
    ),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Account collegato correttamente",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Account scollegato correttamente",
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
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Verifica Idoneità",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Richiedi"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Richiesto"),
    "g_key_airdrop_days_left": m20,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("Scadenza"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("Idoneo"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Valore Stimato",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Filtra"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Nessun airdrop disponibile",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Non Idoneo",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("In Sospeso"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "Alta Priorità",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Bassa Priorità",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Media Priorità",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Requisito soddisfatto",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Non soddisfatto",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Requisiti",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage("Ordina Per"),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Tracker Airdrop",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Totale Richiesto",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("In Arrivo"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Accesso Apple annullato",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Applicare"),
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
    "g_key_batch_duplicate_address": m21,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Stima del gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Il trasferimento batch supporta solo le catene EVM",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage("Esegui Batch"),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Esporta CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Risparmio Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Aiuto per il trasferimento batch",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importa CSV",
    ),
    "g_key_batch_insufficient_balance": m22,
    "g_key_batch_invalid_address": m23,
    "g_key_batch_invalid_amount": m24,
    "g_key_batch_max_recipients": m25,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Il promemoria è facoltativo",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Utilizza Multicall3 per tariffe del gas più basse",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Nessun token supportato",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Anteprima"),
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
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Importo"),
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
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage(
      "Commissione Bridge",
    ),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage(
      "Chain di Origine",
    ),
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
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Tempo Stimato"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Ponte"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage(
      "Chain di Destinazione",
    ),
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
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Blocca BTC per coniare vBTC e guadagnare premi",
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
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage(
      "Masterizza NFT",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Questa catena non supporta ancora i trasferimenti, resta sintonizzato",
    ),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("Cambia e-mail"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Cambia password",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Inserisci la tua password attuale e imposta una nuova password",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice a 6 cifre",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "È richiesto il codice di verifica",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Codice di verifica inviato",
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
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Conferma nuova password",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continua con Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continua con Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Promemoria di scadenza",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Approvato! Tocca Scambia per continuare.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Importo esatto",
    ),
    "g_key_dex_approve_required": m26,
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
    "g_key_dex_price_impact_high": m27,
    "g_key_dex_quote_expires": m28,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Preventivo fallito",
    ),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "Preventivo aggiornato",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca simbolo / nome / indirizzo",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Seleziona"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Tolleranza Slippage",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Slittamento massimo",
    ),
    "g_key_dex_sol_note": MessageLookupByLibrary.simpleMessage(
      "Solana swap: firma la transazione nel tuo portafoglio Solana.",
    ),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX swap non ancora supportato nell\'app",
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
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Transazione fallita",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Paghi"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage("Ricevi"),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "Supporta ENS (.eth), Unstoppable Domains (.crypto/.wallet/…) e Solana SNS (.sol)",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Servizio di nomi Solana",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Dominio Solana non trovato",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Domini inarrestabili",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Dominio Unstoppable non trovato o nessun indirizzo per questa chain",
    ),
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
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Richiedi gettoni gratuiti",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Trasferimento a catena incrociata",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Bonus check-in giornaliero",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Scambia qualsiasi token tramite Uniswap / 1inch",
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
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Mining di nodi",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Guadagna premi partecipando al mining di nodi",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "Guadagna punti ogni giorno",
    ),
    "g_key_earn_pts_day": m29,
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
    "g_key_earn_up_to_apy": m30,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Visualizza tutto",
    ),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Avvisi di idoneità",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage("Solo idoneo"),
    "g_key_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Inserisci un indirizzo email valido",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "L\'e-mail è obbligatoria",
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
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Esecuzione della transazione in corso...",
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
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Periodo di registrazione",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Modifica record",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Scaduto"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Scade"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "In scadenza a breve",
    ),
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
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage(
      "Direttore dell\'ENS",
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
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Gestire l\'ENS",
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
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "Non possiedi ancora alcun nome ENS",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "I miei nomi ENS",
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
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "all\'anno",
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
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Record"),
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
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registrazione del nome...",
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
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "Promemoria disattivato",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Abilita promemoria scadenza",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "Promemoria attivato",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notifica 30, 7 e 1 giorno prima della scadenza",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Rinnovare"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Costo di rinnovo",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Estendi la registrazione del tuo dominio",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Rinnovo riuscito",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage(
      "Rinnovare l\'ENS",
    ),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "La risoluzione ENS non è riuscita",
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
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Impegnarsi"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage(
      "Registrati",
    ),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Successo"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Aspetta"),
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
    "g_key_ens_success_message": m31,
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
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage(
      "Costo totale",
    ),
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
    "g_key_ens_wait_timer": m32,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("In attesa..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Verificare l\'indirizzo risolto prima di procedere. I nomi ENS possono essere trasferiti o modificati dal relativo proprietario.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("anno"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("anni"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "La tua identità",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Reinserisci la nuova password",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Inserisci il tuo indirizzo email",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Inserisci la nuova password",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password attuale",
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
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Account o password errati",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage(
      "Errore nella richiesta",
    ),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Sei già connesso su un altro telefono e sei stato disconnesso forzatamente.",
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Compila le informazioni di feedback",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Ci sono allegati non caricati",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage("Invio fallito"),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Inviato con successo",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Allegati"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Carica fino a 5 allegati, ogni allegato non può superare i 100MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Clicca per riprovare",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Effettua l\'accesso",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtra"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Digitare"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Password dimenticata?",
    ),
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
    "g_key_gas_auto_refresh": m33,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Tariffa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizzato"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Tempo Stimato",
    ),
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
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Medio"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Forte"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Schema troppo semplice, aggiungere più nodi",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Debole"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Accesso a Google annullato",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "Solo valore elevato",
    ),
    "g_key_hw_account_added": m34,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Conto già importato",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Account"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Aggiungi Account",
    ),
    "g_key_hw_add_account_content": m35,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Indirizzo copiato",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Assicurati che il tuo dispositivo sia sbloccato e che il Bluetooth sia abilitato prima di connetterti.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Controlla l\'app",
    ),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Conferma sul tuo dispositivo",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Connetti Portafoglio Hardware",
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
    "g_key_hw_current_app_label": m36,
    "g_key_hw_days_ago": m37,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Percorso di Derivazione",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnetti"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage(
      "Disconnesso",
    ),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Per favore attiva il Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Versione Firmware",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_key_hw_import_failed": m38,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connetti Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Risposta non valida dal dispositivo Keystone",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Impossibile analizzare il codice QR. Per favore riprova.",
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
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Firma ricevuta con successo"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "In attesa della firma di Keystone...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tocca per scansionare la risposta Keystone",
    ),
    "g_key_hw_last_connected": m39,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Registro"),
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
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Nessun dispositivo trovato",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo non connesso",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Non connesso",
    ),
    "g_key_hw_open_app": m40,
    "g_key_hw_open_ledger_app_hint": m41,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rifiutato sul dispositivo",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Rimuovi"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Rimuovi dispositivo",
    ),
    "g_key_hw_remove_device_confirm": m42,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivi salvati",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage(
      "Ricerca dispositivi...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Seleziona Dispositivo",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Firma Messaggio",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Firma Transazione",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Potenza Segnale",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Dispositivi supportati",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Timeout connessione",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Portafoglio Hardware",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Oggi"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
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
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Inserisci la passphrase sul tuo dispositivo Trezor",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Inserisci il PIN sul tuo dispositivo Trezor",
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
    "g_key_link_account": MessageLookupByLibrary.simpleMessage(
      "Collega account",
    ),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Account collegati",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Accedi"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Accesso riuscito",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Esci"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler uscire dall\'app?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Punti Disponibili",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Ho fatto il check-in oggi!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Effettua il check-in",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("Fatto"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Check-in non riuscito, riprova",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in riuscito!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Richiedi Punti",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Attività non riuscita, riprova",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Compito completato!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copia"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Giornaliero",
    ),
    "g_key_loyalty_earn_points": m43,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Guadagnato"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Cronologia Punti",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invita"),
    "g_key_loyalty_invite_bonus": m44,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invita amici",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amici Invitati",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Livello massimo",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Avanti"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "Livello Successivo",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Nessun premio disponibile",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Nessuna attività disponibile",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Punti"),
    "g_key_loyalty_points_to_next": m45,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Riscatta"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Rinvio"),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Bonus Referral",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Il Tuo Codice Referral",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Link Referral",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("Premi"),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Condividi"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Speso"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Attività Completata",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Attività"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Livello"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Bronzo"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Diamante",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Oro"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Platino",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage(
      "Argento",
    ),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Punti"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Totale guadagnato",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Punti Totali",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Usato"),
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
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage(
      "Nuovi lanci aerei",
    ),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage(
      "Nuova parola d\'ordine",
    ),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "La nuova password deve essere diversa dalla password corrente",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Avanti"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Totale"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Fotocamera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Seleziona foto"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Contenuto"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transazione inviata"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Seleziona video"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del portafoglio non valido",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Equilibrio"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Questa azione è irreversibile. L\'NFT verrà inviato all\'indirizzo di masterizzazione.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "La masterizzazione è supportata solo su catene EVM",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "La masterizzazione di Solana NFT sarà presto disponibile",
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
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "Visualizza su Explorer",
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
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Nessun account collegato",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni di notifica",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Accesso aziendale (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "SSO aziendale non configurato",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Password attuale",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("o"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "La password è stata modificata con successo",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "La password deve contenere almeno 6 caratteri",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Diversa dalla password attuale",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "Almeno 6 caratteri",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "È richiesta la password",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Requisiti della password",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Reimpostazione della password riuscita",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Le password non corrispondono",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Importo non valido",
    ),
    "g_key_payment_approx_token": m46,
    "g_key_payment_approx_usdt": m47,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "QR pagamento",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("Conferma"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "Cronologia pagamenti",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "Cronologia",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage(
      "In entrata",
    ),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Caricamento fallito",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Non impostato",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Saldo nativo insufficiente!",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Catena nativa non trovata!",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("In uscita"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Imposta importo",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Pagamento riuscito!",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Pagamento"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Saldo USDT insufficiente!",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Aggiungere il token USDT!",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Portafoglio"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Seleziona dalla galleria del telefono",
    ),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage(
      "Invia nuovamente il codice",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Ripristina"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Reimposta password",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Inserisci il tuo indirizzo email per ricevere un codice di verifica",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("Accesso SAML"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML non configurato",
    ),
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
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Invia codice di verifica",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Promemoria/Nota",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Promemoria/Nota (facoltativo)",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Imposta la tua nuova password",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Condividi codice QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Condividi link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metodo di condivisione",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Accesso non riuscito",
    ),
    "g_key_sim_gas_estimate": m48,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "La transazione probabilmente fallirà",
    ),
    "g_key_sim_reverted_reason": m49,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulazione della transazione...",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "La simulazione della transazione è stata superata",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulazione non disponibile per questa rete",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage(
      "Accesso sociale",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chatta"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Il file è troppo grande per essere caricato",
    ),
    "g_key_squad_k15": m50,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Aggiungi contatto",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contatto"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("Cerca per email"),
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
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Richiedi Ricompense",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commissione",
    ),
    "g_key_stake_d_unbond": m51,
    "g_key_stake_days_left": m52,
    "g_key_stake_days_remaining": m53,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegatori",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Stima Premio giornaliero",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Stima Premio annuale",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Vai a Scambia",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Liquido",
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
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Nessuna posizione di staking",
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
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ricompense in Sospeso",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Le Mie Posizioni",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocollo"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocolli"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Ripresa"),
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
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Totale in Stake",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transazione preparata con successo",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Sbloccaggio",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Periodo di Sblocco",
    ),
    "g_key_stake_unbonding_warning": m54,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Non partecipare",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Aggiornamento...",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage(
      "Tempo di attività",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validatore"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validatori",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Riceverai",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage(
      "Parola d\'ordine",
    ),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verifica"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Completato"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prezzo del gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage(
      "Commissione gas massima",
    ),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Commissione massima per gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("In attesa"),
    "g_key_t_29": m55,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Commissione miner"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Procedi"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Password del portafoglio",
    ),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "La password del portafoglio non può essere vuota",
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
    "g_key_t_45": m56,
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
    "g_key_t_52": m57,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'indirizzo di ricezione non ha un account, il primo trasferimento è di almeno 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilizzato"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m58,
    "g_key_time_hours_ago": m59,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage(
      "Proprio adesso",
    ),
    "g_key_time_minutes_ago": m60,
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Aggiungi",
    ),
    "g_key_token_discovery_add_selected": m61,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Gettone aggiunto",
    ),
    "g_key_token_discovery_banner": m62,
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
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Tipi di NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Follower"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Tipi di utente"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Sito web"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Link dei prodotti"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage(
      "Piattaforme multimediali",
    ),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage(
      "Indirizzo del portafoglio",
    ),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Soprannome"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Caricamento avatar fallito",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Descrizione"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage(
      "Informazioni sull\'artista",
    ),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("Non sei un artista"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Clicca qui per candidarti come artista",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Ricavi"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Scollega account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Ho letto e accetto ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Termini e condizioni",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Informativa sulla privacy e dichiarazione sulla raccolta delle informazioni personali",
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
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Codice di verifica",
    ),
    "g_key_verification_code_sent": m63,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Visualizza frase di recupero",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Assicurati di annotare la tua frase di recupero e conservarla in modo sicuro.",
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
    "g_key_wallet_m1": m64,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler cancellare il tuo account?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Conferma disconnessione",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica Google.",
    ),
    "g_key_wallet_m19": m65,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Il token corrente non è stato aggiunto.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Inserisci la tua frase di recupero con le parole separate da spazi",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importa portafoglio",
    ),
    "g_key_wallet_m3": m66,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Il saldo del token corrente è insufficiente.",
    ),
    "g_key_wallet_m5": m67,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Errore di firma"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Cancellazione account",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica email.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Gestisci portafoglio",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'indirizzo Ethereum (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Solo orologio",
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
    "g_key_xml_11": m68,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Riserva incrementale"),
    "g_key_xml_22": m69,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Conteggio oggetti posseduti",
    ),
    "g_key_xml_33": m70,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Come calcolare l\'importo totale riservato",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Riserva totale = Riserva base + (Conteggio oggetti posseduti × Riserva incrementale)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID e Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Password attuale"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Nuova password"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Conferma nuova password",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("Numero a 6 cifre"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Password e biometria",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Password a sequenza"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Imposta codice a sequenza",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Per la sicurezza del tuo account, imposta una password di gruppo",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Disegna nuovamente la password a sequenza",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Disegna password a sequenza",
    ),
    "g_lock_key21": m71,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Reimposta la password a sequenza",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Troppi inserimenti errati, reimposta la password",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Aggiungere password del portafoglio?",
    ),
    "g_lock_key25": m72,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage(
      "Pagina schermata di blocco",
    ),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Blocco automatico"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Riuscito"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Fallito"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Il riconoscimento biometrico non è abilitato",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Aggiungere la verifica biometrica?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Reimposta password"),
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
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Tocca ★ su qualsiasi moneta da aggiungere",
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
    "g_mining_key15": MessageLookupByLibrary.simpleMessage(
      "Dettagli del compito",
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
    "g_mining_key63": m73,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage("Data di sblocco"),
    "g_mining_key73": m74,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Ho appena configurato un nodo su @N42Wallet e ho iniziato la verifica su dispositivi mobili! Vieni a unirti a me. Il futuro decentralizzato è mobile!",
    ),
    "g_mining_key76": m75,
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
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Elenco validatori",
    ),
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
    "g_mining_key_109": m76,
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
    "g_mining_key_116": m77,
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
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Distribuzione della ricompensa",
    ),
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
    "g_mining_key_71": m78,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 secondi per verifica",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Verifica cloud avviata",
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
    "g_mining_key_98": m79,
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
    "g_news_source": MessageLookupByLibrary.simpleMessage("Fonte"),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Notifiche"),
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
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base di costo"),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "Nessuna compravendita registrata",
    ),
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
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Scaricato"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Codice invito",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invitati"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Nodi di mining"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Ricompensa (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage(
      "Statistiche referral",
    ),
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
    "g_swap_key_14": m80,
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
    "g_swap_key_20": m81,
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
    "g_swap_key_31": m82,
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
    "g_token_m_key_1": m83,
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
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Aggiungi catena personalizzata",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 unità"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Aggiungi token"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Errore di formato!",
    ),
    "g_token_m_key_22": m84,
    "g_token_m_key_23": m85,
    "g_token_m_key_24": m86,
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
    "g_unlock_key10": m87,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Impronta digitale o riconoscimento facciale non abilitato?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Disegna password a sequenza",
    ),
    "g_unlock_key4": m88,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Inserisci password"),
    "g_unlock_key6": m89,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Autenticazione fallita",
    ),
    "g_unlock_key8": m90,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Puoi anche "),
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
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage(
      "Nuova connessione",
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
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Autenticazione Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Collega",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Scarica Google Authenticator",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Istruzioni",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Apri Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Vedrai un codice di verifica a 6 cifre sullo schermo.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Copia il codice a 6 cifre e incollalo in N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Quindi, il tuo Authenticator sarà collegato con successo.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Chiave di backup",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Copia la chiave in Google Authenticator",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica email",
    ),
    "google_verification_message21": m91,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Impossibile ottenere la chiave Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Autenticazione a due fattori (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Per proteggere il tuo account, si consiglia di attivare almeno un 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "L\'app Google Authenticator protegge i tuoi prelievi e l\'account N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Scarica e installa",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Scarica e installa Google Authenticator. Poi premi \'Collega\' per collegare il tuo account N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Avviso importante",
    ),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Accedi"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Password dimenticata?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Codice referral",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Codice referral",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Non hai un account? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Creato con successo",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Reimpostato con successo",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Hai già un account? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Rinvia codice tra ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Codice inviato con successo",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "Email non registrata",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Invio del codice fallito",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "Effettua prima l\'accesso",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Parola d\'ordine"),
    "next": MessageLookupByLibrary.simpleMessage("Avanti"),
    "nicknameMessage": m92,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Le password non corrispondono",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Modifica profilo",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografia"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'email",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Inserisci la password",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Inserisci l\'indirizzo",
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
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Inserisci nuovamente la password",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage(
      "Inserisci codice",
    ),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage(
      "Codice OTP",
    ),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Reimposta la tua password",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Gestisci portafoglio"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Informazioni sull\'app"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Sicurezza"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Usa nuova Chat"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Abilita esperienza Chat migliorata",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage(
      "Indirizzi del portafoglio",
    ),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transazione"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Lingua"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Tema"),
    "search": MessageLookupByLibrary.simpleMessage("Cerca"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Leggi l\'accordo e conferma",
    ),
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
