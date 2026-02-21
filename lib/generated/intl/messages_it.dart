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

  static String m1(value) => "Sono ${value}";

  static String m2(value) => "Membri chat (${value})";

  static String m3(value) =>
      "Sei sicuro di voler aggiungere ${value} come amico";

  static String m4(value) =>
      "Sei già associato e non puoi essere riassociato al momento. Indirizzo associato: ${value}.";

  static String m5(value) =>
      "Associazione riuscita. Indirizzo associato: ${value}";

  static String m6(value) => "Non c\'è N42chain nel portafoglio ${value}!";

  static String m7(value) => "Corrispondenza riuscita. Indirizzo:${value}.";

  static String m8(value) => "Importo superiore a ${value}.";

  static String m9(value) =>
      "Il portafoglio esiste già, il nome del portafoglio è \"${value}\"";

  static String m10(value) => "Inserisci un importo superiore a ${value}.";

  static String m11(gas) =>
      "Il gas di esecuzione (${gas}) è alto. Il contratto chiamato potrebbe consumare più gas del previsto.";

  static String m12(gas) =>
      "La prima transazione include il deployment dell\'account (~${gas} gas). Le transazioni successive saranno più economiche.";

  static String m13(gas) =>
      "L\'overhead gas del paymaster (${gas}) è alto. Le transazioni senza gas potrebbero costare di più.";

  static String m14(gas) =>
      "Il gas totale stimato (${gas}) è insolitamente alto. Controlla la tua transazione per errori.";

  static String m15(gas) =>
      "Il gas di verifica (${gas}) potrebbe essere troppo alto. Ciò può accadere con logica account complessa.";

  static String m16(value) => "${value} giorni rimanenti";

  static String m17(value) => "Indirizzo duplicato alla riga ${value}";

  static String m18(value) => "Indirizzo non valido alla riga ${value}";

  static String m19(value) => "Importo non valido alla riga ${value}";

  static String m20(value) => "Massimo ${value} destinatari";

  static String m21(value) => "+${value} pts/day";

  static String m22(value) => "Earn up to ${value}% APY";

  static String m23(value) => "Congratulations! You now own ${value}";

  static String m24(value) => "Please wait ${value} seconds";

  static String m25(value) => "Auto-refresh every ${value} seconds";

  static String m26(address) => "Conto ${address} aggiunto";

  static String m27(address, network) =>
      "Si vuole tracciare questo conto hardware wallet?\n\nIndirizzo: ${address}\nRete: ${network}";

  static String m28(app) => "Current app: ${app}";

  static String m29(days) => "${days} days ago";

  static String m30(value) => "Importazione account fallita: ${value}";

  static String m31(date) => "Last connected: ${date}";

  static String m32(value) =>
      "Per favore apri l\'app ${value} sul tuo dispositivo";

  static String m33(app) =>
      "Assicurarsi che l\'app ${app} sia aperta sul Ledger";

  static String m34(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m35(value) => "Earn ${value} points";

  static String m36(value) => "Earn ${value} points for each friend who joins!";

  static String m37(value) => "${value} punti per il prossimo livello";

  static String m38(amount, token) => "≈ ${amount}${token}";

  static String m39(amount) => "≈ ${amount} USDT";

  static String m40(value) =>
      "Sei sicuro di voler eliminare il contatto ${value}?";

  static String m41(value) => "${value}d unbond";

  static String m42(value) => "${value} giorni rimanenti";

  static String m43(value) => "${value} days remaining";

  static String m44(value) => "Non hai abbastanza \"${value}\"";

  static String m45(value) => "Impossibile recuperare l\'account \"${value}\"";

  static String m46(value) => "Minimo ${value} XRP per il primo trasferimento";

  static String m47(value) => "${value}d ago";

  static String m48(value) => "${value}h ago";

  static String m49(value) => "${value}m ago";

  static String m50(value) => "Verification code sent to ${value}";

  static String m51(value) => "Nessuna catena ${value} aggiunta.";

  static String m52(value) =>
      "${value} ha transazioni non completate, riprova più tardi.";

  static String m53(value) => "Nessun indirizzo trovato per ${value}.";

  static String m54(value) => "Saldo insufficiente di ${value}.";

  static String m55(value, value1) =>
      "Ogni account XRP deve riservare ${value} XRP (${value1} drops) come baseline, che non può essere speso.";

  static String m56(value, value1) =>
      "Per ogni oggetto posseduto dall\'account, ${value} XRP (${value1} drops) viene aggiunto alla riserva.";

  static String m57(value, value1) =>
      "Questo account possiede ${value} oggetti, il che significa che ${value1} XRP aggiuntivi sono riservati.";

  static String m58(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativi";

  static String m59(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativo";

  static String m60(value) =>
      "Hai configurato con successo un ${value} e inizierai la verifica con N42Wallet!";

  static String m61(value) =>
      "Unisciti al mio gruppo ${value} su @N42Wallet per essere uno dei primi miner di una blockchain Layer 1, e ottieni criptovalute sul tuo telefono!";

  static String m62(value) => "Blocca ${value} N per eseguire un validatore.";

  static String m63(value) => "Importazione fallita:${value}";

  static String m64(value) =>
      "È necessario un saldo di staking di almeno ${value} per ricevere ricompense.";

  static String m65(value, value1) =>
      "${value} N ogni ${value1} blocchi estratti";

  static String m66(value) => "Deve essere di ${value} caratteri";

  static String m67(value) => "Saldo insufficiente di ${value}.";

  static String m68(value) => "${value} in arrivo...";

  static String m69(value) =>
      "${value} scambiati nell\'app saranno distribuiti a breve nel tuo portafoglio e non possono essere venduti tramite questo processo. Possono essere utilizzati per gestire un nodo.";

  static String m70(value) => "Massimo ${value} caratteri";

  static String m71(value) => "La catena ${value} è già supportata dall\'APP!";

  static String m72(value) =>
      "La catena ${value} è già supportata dall\'APP, vuoi aggiungerla?";

  static String m73(value) =>
      "Test del collegamento dell\'indirizzo ${value} fallito!";

  static String m74(value) =>
      "L\'applicazione si sbloccherà tra ${value} secondi.";

  static String m75(value) =>
      "Errore inserimento password a sequenza, hai ${value} tentativi";

  static String m76(value) =>
      "Errore inserimento password, hai ${value} tentativi";

  static String m77(value) =>
      "Errore inserimento password, hai ${value} tentativo";

  static String m78(value) => "Inserisci la password ${value}";

  static String m79(value) => "0~${value} caratteri";

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
    "file": MessageLookupByLibrary.simpleMessage("File"),
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
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Browser"),
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
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Segnalibri"),
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
    "g_chat_key_10": m1,
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
    "g_chat_key_32": m2,
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
    "g_chat_key_6": m3,
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
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Metodo di riconoscimento facciale",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
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
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Dissociazione"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Verifica dei dati facciali fallita!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Dissociazione dei dati facciali fallita!",
    ),
    "g_face_match_key4": m7,
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
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portafoglio principale"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transazione completata"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Password errata"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Mainnet"),
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
    "g_key_197": MessageLookupByLibrary.simpleMessage("Max"),
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
    "g_key_214": m9,
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
    "g_key_46": m10,
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
      "Account Created Successfully",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Account Details",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Account Name",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter account name",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Account Type",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Add your first operation",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Add Operation",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calcolo indirizzo...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Calcolo indirizzo fallito. Riprova.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "This address is pre-computed and will be deployed when you make your first transaction.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approve"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomic Execution",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Execute multiple operations at once",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Send multiple transactions in a single operation",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Batch execution failed",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "No saved templates",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Batch Operations",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage("Save Gas"),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Save as Template",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Submitting...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Batch submitted successfully",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Load Template",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Template Name",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Enter template name",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Template saved",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Templates",
    ),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch Transaction",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Account Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Account smart ERC-7579 modulare con supporto per transazioni senza gas",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("by"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Change"),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Counterfactual Address",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "This is a counterfactual address. It will be deployed on your first transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Create your first smart account",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Create a smart account to get started",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Create Session Key",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Created"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Deploy"),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Deploy Failed",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment failed. Please try again.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Deployment started",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Deployed"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account is ready to use",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Deploying..."),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Deployment transaction is being processed",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Deployment will occur automatically with your first transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experience the next generation of Ethereum accounts with enhanced features",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Details"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "EIP-7702 Account",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrid EOA/Smart Account - No deployment needed",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Estimated Gas",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage(
      "Estimating...",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Factory"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Batch multiple transactions",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Pay gas in any token",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Enhanced security",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("FREE"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage("Full Access"),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas Estimate",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gas Payment"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas Payment Options",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage("Gas Savings"),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas Sponsored",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Gas di Esecuzione Alto",
    ),
    "g_key_aa_gas_warn_call_high_desc": m11,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Overhead Gas di Deployment",
    ),
    "g_key_aa_gas_warn_deploy_desc": m12,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Overhead Paymaster Alto",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m13,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite Gas Molto Alto",
    ),
    "g_key_aa_gas_warn_total_high_desc": m14,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possibile Sottostima del Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Il gas effettivamente utilizzato potrebbe superare la stima. Considera di aggiungere un buffer maggiore.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas di Verifica Alto",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m15,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gasless"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gasless transactions & batch operations",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Account Abstraction",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Kernel Account",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Modular account with plugin support from ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Label"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Last Activity",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "My Smart Accounts",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Never"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "No smart accounts yet",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "No accounts match your filter",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "No operations added",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "No session keys",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Not Deployed",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed on first transaction",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operations"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Pay gas with token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Pay gas with your ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Pay with"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Pay with ETH",
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
      "Choose how you want to pay for transaction gas fees",
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
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Preview Address",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recommended"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Revoke"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Revoke Session Key",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Session key revoked",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Revoked"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Revoking session key...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Safe Account",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-signature account with advanced security features",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage(
      "Guardiani",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Soglia"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("saved"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Select Chain",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Select Paymaster",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Select Account Type",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Send tokens using your smart account",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("AA Transfer"),
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
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Valido per",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Rischio alto — solo DApp verificate",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
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
      "Simple Account",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Basic smart account with single owner - recommended for most users",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Smart Account",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Smart Accounts",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Smart Wallet",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Spending Limit",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsored (Free)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage("Smart Account"),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Total Gas"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage("Unavailable"),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Account linked successfully",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Account unlinked successfully",
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
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Verifica Idoneità",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Richiedi"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Richiesto"),
    "g_key_airdrop_days_left": m16,
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
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Aggiungi Destinatario",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Cancella Tutto",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Formato CSV: indirizzo,importo,etichetta",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m17,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage("Esegui Batch"),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Esporta CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Risparmio Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importa CSV",
    ),
    "g_key_batch_invalid_address": m18,
    "g_key_batch_invalid_amount": m19,
    "g_key_batch_max_recipients": m20,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No supported tokens",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Anteprima"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinatari",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Select Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Send tokens to multiple addresses in one transaction",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Signing..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Swipe left to remove a recipient",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Trasferimento Multiplo",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Importo Totale",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Importo"),
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
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Seleziona Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Tempo Stimato"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Bridge"),
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
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Got it"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Select a token with NFT support",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Go to NFT tab",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Select the NFT you want to burn",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Tap \"Burn\" button",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Steps:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "To burn an NFT, please go to the NFT details page and tap the \"Burn\" button.",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Burn NFT"),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("Change Email"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your current password and set a new password",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Please enter 6-digit code",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Verification code is required",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Verification code sent",
    ),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirm New Password",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continue with Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continue with Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Deadline reminders",
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
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Nessun token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Nessun token trovato",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impatto Prezzo",
    ),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Preventivo fallito",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Cerca simbolo / nome / indirizzo",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Seleziona"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Tolleranza Slippage",
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
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
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
      "Claim free tokens",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-chain transfer",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Daily check-in bonus",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Scambia qualsiasi token tramite Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Scambio DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Inizia lo staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Caricamento APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Mining"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
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
      "Earn points daily",
    ),
    "g_key_earn_pts_day": m21,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Quick Tools",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommended",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Seleziona tipo di scambio",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Scambia"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Earn"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Total Earnings",
    ),
    "g_key_earn_up_to_apy": m22,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("View All"),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Eligibility alerts",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Eligible only",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid email address",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "Email is required",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage("Annual Fee"),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Base Price"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Checking availability...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Commit failed",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Committing transaction...",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Committing...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirm Renewal",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirm & Send",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm ENS Resolution",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Current Expiry",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("days left"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Register and manage your .eth domain names",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "ENS Name Detected",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Edit Records",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expiring Soon",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Extend Registration Period",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizing registration",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Get started with ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Get your .eth name",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Invalid ENS name",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage("is now yours!"),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Please keep the app open during registration",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Manage your Web3 identity",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Manage ENS",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 characters",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("My Domains"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS Name"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage("New Expiry"),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "New Owner Address",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "No domains yet",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "You don\'t own any ENS names yet",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "My ENS Names",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Owner"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Please wait",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Premium Name",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Price Breakdown",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "per year",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primary"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Primary name set successfully",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Processing...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Register ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Records"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Your decentralized identity on Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Registration failed",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Register Now",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Registering name...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registering...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Registration Info",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renew"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Renewal Cost",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Extend your domain registration",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renewal successful",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage("Renew ENS"),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "ENS resolution failed",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Resolved Address",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Resolving ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Find available .eth names",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search for a .eth name",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Enter an ENS name to search",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Search & Register",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Search ENS",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Ethereum Name Service",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Set as Primary",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Standard Name",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Start Registration",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Step 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Step 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Step 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Commit"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage("Register"),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Success"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Success!"),
    "g_key_ens_success_message": m23,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Text Records",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Total Cost"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transfer ownership to another address",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer successful",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Transfer is irreversible. Make sure the new owner address is correct.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Try another name",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "ENS registration is a two-step process",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Unavailable",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Waiting period prevents front-running attacks",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "A waiting period prevents front-running",
    ),
    "g_key_ens_wait_timer": m24,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Waiting..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("year"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("years"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Your Identity",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Re-enter new password",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Enter your email address",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Enter new password",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Enter current password",
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
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot Password?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gas Alert"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alert when above",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alert when below",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Save"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Threshold (Gwei)",
    ),
    "g_key_gas_auto_refresh": m25,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Tariffa Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personalizzato"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Tempo Stimato",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Veloce"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
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
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Tariffa Prioritaria",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Impostazioni Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lento"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m26,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Account"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Aggiungi"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Aggiungi Account",
    ),
    "g_key_hw_add_account_content": m27,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Indirizzo copiato",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Annulla"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Conferma sul tuo dispositivo",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Connetti Portafoglio Hardware",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connect New Device",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Air-gap with Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connect Ledger (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "g_key_hw_current_app_label": m28,
    "g_key_hw_days_ago": m29,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Percorso di Derivazione",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
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
    "g_key_hw_import_failed": m30,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Invalid response from Keystone device",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Failed to parse QR code. Please try again.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scan this QR code with your Keystone device to sign the transaction",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Point your camera at the QR code displayed on your Keystone device",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scan Keystone Signature"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code from your Keystone device to import accounts",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signature received successfully"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Waiting for Keystone signature...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tap to scan Keystone response",
    ),
    "g_key_hw_last_connected": m31,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
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
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Nessun dispositivo trovato",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Dispositivo non connesso",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m32,
    "g_key_hw_open_ledger_app_hint": m33,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rifiutato sul dispositivo",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remove Device",
    ),
    "g_key_hw_remove_device_confirm": m34,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Saved Devices",
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
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Timeout connessione",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Portafoglio Hardware",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Today"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to connect to Trezor. Make sure USB is connected.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor connected successfully",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting to Trezor...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Enter passphrase on your Trezor device",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Enter PIN on your Trezor device",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connect your Trezor device via USB cable and unlock it",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "View Accounts",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Conti del Portafoglio",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Esiste già un portafoglio per questa valuta.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Impossibile leggere il keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Accedi"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Esci"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler uscire dall\'app?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Punti Disponibili",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Checked in today!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Check In",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Check-in failed, please try again",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in successful!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Richiedi Punti",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Giornaliero",
    ),
    "g_key_loyalty_earn_points": m35,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Guadagnato"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Cronologia Punti",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m36,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amici Invitati",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
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
    "g_key_loyalty_points_to_next": m37,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Riscatta"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Referral"),
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
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
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
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Punti Totali",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Used"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Browser"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
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
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Inserisci la frase di recupero",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Totale"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Fotocamera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Seleziona foto"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Contenuto"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nome"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Indietro"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transazione inviata"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Seleziona video"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "No linked accounts",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Notification Settings",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Enterprise Login (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO not configured",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Current Password",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("or"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Password changed successfully",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Password must be at least 6 characters",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Different from current password",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "At least 6 characters",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Password is required",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Password Requirements",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Password reset successfully",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Importo non valido",
    ),
    "g_key_payment_approx_token": m38,
    "g_key_payment_approx_usdt": m39,
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
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage("Resend Code"),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Reset Password",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Enter your email address to receive a verification code",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML Login"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML not configured",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Send Verification Code",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Set your new password",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Condividi codice QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Condividi link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metodo di condivisione",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Il file è troppo grande per essere caricato",
    ),
    "g_key_squad_k15": m40,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Aggiungi contatto",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contatto"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("Cerca per email"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Attivo"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Richiedi Ricompense",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commissione",
    ),
    "g_key_stake_d_unbond": m41,
    "g_key_stake_days_left": m42,
    "g_key_stake_days_remaining": m43,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegatori",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Liquido",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Stake Minimo",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Nessuna posizione di staking",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ricompense in Sospeso",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Le Mie Posizioni",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocollo"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restake"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Ricompense"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Seleziona Validatore",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Stake"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Staking"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Totale in Stake",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Sbloccaggio",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Periodo di Sblocco",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Unstake"),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Uptime"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validatore"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validatori",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Completato"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prezzo del gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage(
      "Commissione gas massima",
    ),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Commissione massima per gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("In attesa"),
    "g_key_t_29": m44,
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
    "g_key_t_45": m45,
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
    "g_key_t_52": m46,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'indirizzo di ricezione non ha un account, il primo trasferimento è di almeno 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilizzato"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m47,
    "g_key_time_hours_ago": m48,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m49,
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
      "Start Date",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Date Range",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("End Date"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direction",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "No transactions match your filter",
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
      "Unlink Account",
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
      "Verification Code",
    ),
    "g_key_verification_code_sent": m50,
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
    "g_key_wallet_m1": m51,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Sei sicuro di voler cancellare il tuo account?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Conferma disconnessione",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Inserisci il codice di verifica Google.",
    ),
    "g_key_wallet_m19": m52,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Il token corrente non è stato aggiunto.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Inserisci la tua frase di recupero con le parole separate da spazi",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importa portafoglio",
    ),
    "g_key_wallet_m3": m53,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Il saldo del token corrente è insufficiente.",
    ),
    "g_key_wallet_m5": m54,
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
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Riservato"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Riserva base"),
    "g_key_xml_11": m55,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Riserva incrementale"),
    "g_key_xml_22": m56,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Conteggio oggetti posseduti",
    ),
    "g_key_xml_33": m57,
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
    "g_lock_key21": m58,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Reimposta la password a sequenza",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Troppi inserimenti errati, reimposta la password",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Aggiungere password del portafoglio?",
    ),
    "g_lock_key25": m59,
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
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Sbloccare N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Attività di verifica cloud",
    ),
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
    "g_mining_key63": m60,
    "g_mining_key73": m61,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Ho appena configurato un nodo su @N42Wallet e ho iniziato la verifica su dispositivi mobili! Vieni a unirti a me. Il futuro decentralizzato è mobile!",
    ),
    "g_mining_key76": m62,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Riscatto disponibile dopo 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Le richieste precedenti non verranno elaborate.",
    ),
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
    "g_mining_key_109": m63,
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
    "g_mining_key_116": m64,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "La ricompensa si accumula giornalmente e viene inviata al tuo portafoglio N solo quando raggiunge ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Ricompense totali",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valore estratto"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Calcolato in base al prezzo di mercato di N * le ricompense totali in N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Numero di profitti",
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
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Disabilitato"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Vedi altro"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Stato della verifica",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Blocca N per iniziare a verificare e ottenere ricompense.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Base"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nodo avanzato"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nodo base"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nodo pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocchi/giorno~70 min",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Seleziona un piano",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocchi/giorno~15 min",
    ),
    "g_mining_key_71": m65,
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
    "g_mining_key_98": m66,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Reinserisci la password per assicurarti che sia corretta",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Periodo di sblocco:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Sbloccabile in qualsiasi momento",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage("Notifiche"),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Condividi"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Referral"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Invita amici e ottieni token N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Ottieni fino a "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N quando il tuo referral inizia la verifica!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Invita tramite"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("codice"),
    "g_swap_key_14": m67,
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
    "g_swap_key_20": m68,
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
    "g_swap_key_31": m69,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Gli scambi possono essere visualizzati sugli esploratori della blockchain pertinenti (Etherscan, BscScan, TRONSCAN e il nostro).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Scambia in N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Scambia"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Ricevi"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Anteprima scambio"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Riprova"),
    "g_token_m_key_1": m70,
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
    "g_token_m_key_22": m71,
    "g_token_m_key_23": m72,
    "g_token_m_key_24": m73,
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
    "g_unlock_key10": m74,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Impronta digitale o riconoscimento facciale non abilitato?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Disegna password a sequenza",
    ),
    "g_unlock_key4": m75,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Inserisci password"),
    "g_unlock_key6": m76,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Autenticazione fallita",
    ),
    "g_unlock_key8": m77,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Puoi anche "),
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
    "google_verification_message21": m78,
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
    "login_email": MessageLookupByLibrary.simpleMessage("Email"),
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
    "login_password": MessageLookupByLibrary.simpleMessage("Password"),
    "next": MessageLookupByLibrary.simpleMessage("Avanti"),
    "nicknameMessage": m79,
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
