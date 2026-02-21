// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a de locale. All the
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
  String get localeName => 'de';

  static String m0(deviceName, os) =>
      "Ihr Konto wurde gerade auf ${deviceName} (${os}) angemeldet. Wenn Sie das nicht waren, empfehlen wir Ihnen, Ihr Passwort zu ändern.";

  static String m1(value) => "Ich bin ${value}";

  static String m2(value) => "Chat-Mitglied (${value})";

  static String m3(value) =>
      "Sind Sie sicher, dass Sie ${value} als Freund hinzufuegen moechten";

  static String m4(value) =>
      "Sie wurden bereits verknuepft und koennen derzeit nicht erneut verknuepft werden. Verknuepfungsadresse: ${value}.";

  static String m5(value) =>
      "Verknuepfung erfolgreich. Verknuepfungsadresse: ${value}";

  static String m6(value) => "Es gibt keine N42chain im ${value}-Wallet!";

  static String m7(value) => "Abgleich erfolgreich. Adresse: ${value}.";

  static String m8(value) => "Betrag groesser als ${value}.";

  static String m9(value) =>
      "Das Wallet existiert bereits, der Wallet-Name ist \"${value}\"";

  static String m10(value) =>
      "Geben Sie einen Betrag groesser als ${value} ein.";

  static String m11(gas) =>
      "Ausführungs-Gas (${gas}) ist hoch. Der aufgerufene Vertrag könnte mehr Gas verbrauchen als erwartet.";

  static String m12(gas) =>
      "Erste Transaktion beinhaltet Konto-Bereitstellung (~${gas} Gas). Nachfolgende Transaktionen werden günstiger sein.";

  static String m13(gas) =>
      "Paymaster-Gas-Overhead (${gas}) ist hoch. Gasfreie Transaktionen können teurer sein.";

  static String m14(gas) =>
      "Geschätztes Gesamt-Gas (${gas}) ist ungewöhnlich hoch. Überprüfen Sie Ihre Transaktion auf Fehler.";

  static String m15(gas) =>
      "Verifikations-Gas (${gas}) könnte zu hoch sein. Dies kann bei komplexer Kontologik auftreten.";

  static String m16(value) => "${value} Tage übrig";

  static String m17(value) => "Doppelte Adresse in Zeile ${value}";

  static String m18(value) => "Ungültige Adresse in Zeile ${value}";

  static String m19(value) => "Ungültiger Betrag in Zeile ${value}";

  static String m20(value) => "Maximal ${value} Empfänger";

  static String m21(value) => "+${value} pts/day";

  static String m22(value) => "Earn up to ${value}% APY";

  static String m23(value) => "Congratulations! You now own ${value}";

  static String m24(value) => "Please wait ${value} seconds";

  static String m25(value) => "Auto-refresh every ${value} seconds";

  static String m26(address) => "Konto ${address} hinzugefügt";

  static String m27(address, network) =>
      "Möchten Sie dieses Hardware-Wallet-Konto verfolgen?\n\nAdresse: ${address}\nNetzwerk: ${network}";

  static String m28(app) => "Current app: ${app}";

  static String m29(days) => "${days} days ago";

  static String m30(value) => "Konto konnte nicht importiert werden: ${value}";

  static String m31(date) => "Last connected: ${date}";

  static String m32(value) =>
      "Bitte öffnen Sie die ${value}-App auf Ihrem Gerät";

  static String m33(app) =>
      "Stellen Sie sicher, dass die ${app}-App auf Ihrem Ledger geöffnet ist";

  static String m34(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m35(value) => "Earn ${value} points";

  static String m36(value) => "Earn ${value} points for each friend who joins!";

  static String m37(value) => "${value} Punkte bis zur nächsten Stufe";

  static String m38(amount, token) => "≈ ${amount}${token}";

  static String m39(amount) => "≈ ${amount} USDT";

  static String m40(value) =>
      "Sind Sie sicher, dass Sie den Kontakt ${value} loeschen moechten?";

  static String m41(value) => "${value}d unbond";

  static String m42(value) => "${value} Tage übrig";

  static String m43(value) => "${value} days remaining";

  static String m44(value) => "Sie haben nicht genuegend \"${value}\"";

  static String m45(value) =>
      "\"${value}\" Konto konnte nicht abgerufen werden";

  static String m46(value) => "Minimum ${value} XRP fuer erste Ueberweisung";

  static String m47(value) => "${value}d ago";

  static String m48(value) => "${value}h ago";

  static String m49(value) => "${value}m ago";

  static String m50(value) => "Verification code sent to ${value}";

  static String m51(value) => "Keine ${value}-Blockchain hinzugefuegt.";

  static String m52(value) =>
      "${value} hat unabgeschlossene Transaktionen, bitte spaeter erneut versuchen.";

  static String m53(value) => "Keine Adresse fuer ${value} gefunden.";

  static String m54(value) => "Unzureichendes Guthaben von ${value}.";

  static String m55(value, value1) =>
      "Jedes XRP-Konto muss ${value} XRP (${value1} Drops) als Grundlage reservieren, die nicht ausgegeben werden kann.";

  static String m56(value, value1) =>
      "Fuer jedes Objekt, das das Konto besitzt, werden ${value} XRP (${value1} Drops) zur Reserve hinzugefuegt.";

  static String m57(value, value1) =>
      "Dieses Konto besitzt ${value} Objekte, was bedeutet, dass zusaetzlich ${value1} XRP reserviert sind.";

  static String m58(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m59(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m60(value) =>
      "Sie haben erfolgreich einen ${value} eingerichtet und werden mit N42Wallet die Verifizierung beginnen!";

  static String m61(value) =>
      "Tritt meiner ${value}-Gruppe auf @N42Wallet bei, um ein fruehzeitiger Miner einer Layer-1-Blockchain zu sein und Krypto auf deinem Handy zu erhalten!";

  static String m62(value) =>
      "Sperren Sie ${value} N, um einen Validator zu betreiben.";

  static String m63(value) => "Import fehlgeschlagen: ${value}";

  static String m64(value) =>
      "Für den Erhalt von Belohnungen ist ein Mindest-Staking-Betrag von ${value} erforderlich.";

  static String m65(value, value1) =>
      "${value} N alle ${value1} geminte Bloecke";

  static String m66(value) => "Muss ${value} Zeichen sein";

  static String m67(value) => "${value} Unzureichendes Guthaben.";

  static String m68(value) => "${value} eingehend...";

  static String m69(value) =>
      "${value} in der App getauscht wird in Kuerze an Ihr Wallet verteilt und kann nicht ueber diesen Prozess verkauft werden. Es kann zum Betrieb eines Knotens verwendet werden.";

  static String m70(value) => "Max. ${value} Zeichen";

  static String m71(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt!";

  static String m72(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt, moechten Sie sie hinzufuegen?";

  static String m73(value) => "${value} Adresstestverbindung fehlgeschlagen!";

  static String m74(value) =>
      "Die Anwendung wird in ${value} Sekunden entsperrt.";

  static String m75(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m76(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m77(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m78(value) => "${value}-Passwort eingeben";

  static String m79(value) => "0-${value} Zeichen";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Registrieren"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Konto erstellen",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verifizierung"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Adressinformationen",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Konto voruebergehend fuer einen Tag gesperrt",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Der Code ist falsch. Bitte erneut versuchen.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Erfolgreich kopiert"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Adresse kopieren"),
    "descO": MessageLookupByLibrary.simpleMessage("Beschreibung (optional)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Passwort ändern",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Neue Geräteanmeldung",
    ),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Foto bearbeiten"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Authentifizierungscode konnte nicht abgerufen werden",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Authentifizierungscode erfolgreich gesendet, bitte E-Mail pruefen",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Authentifizierungscode-Fehler",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Ungueltige E-Mail-Adresse",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse Authentifizierung",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "Die E-Mail-Adresse-Authentifizierungs-App schuetzt Ihre Auszahlungen und Ihr N42Wallet-Konto.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Verifizierung hinzufuegen?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Datei"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Token koennen nur innerhalb desselben Netzwerks gesendet werden. Das Senden aus anderen Netzwerken kann zu Verlust fuehren.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Scannen zum Empfangen",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Bitte URL eingeben",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Beschreibung eingeben",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Browser"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Browser-Cache loeschen",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "DApp automatisch verbinden",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Bitte Verbindung mit DApp bestaetigen",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Alle schliessen"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Fertig"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Lesezeichen"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Noch keine Lesezeichen hinzugefuegt",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Lesezeichen"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Name"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Bitte Namen eingeben",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Beschreibung"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("Gruppenchat starten"),
    "g_chat_key_10": m1,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Freunde einladen"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Kontakt auswaehlen"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Fertig"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Mindestens 2 Kontakte auswaehlen",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Freunddetails"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Gruppendetails"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Weitere Gruppenmitglieder anzeigen",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Gruppenname"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Neuer Freund"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Sind wir sicher, dass wir die Gruppe aufloesen?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie diese Gruppe verlassen moechten?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Gruppe aufloesen"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Gruppe verlassen"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Gruppenchat-Namen aendern",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Wenn der Gruppenchat-Name geaendert wird, werden andere Mitglieder innerhalb der Gruppe benachrichtigt.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Fertig"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Freundschaftsanfrage",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Anfrage, Sie als Freund hinzuzufuegen",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Freundschaftsanfrage genehmigt",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Hinzugefuegt"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Sie wurden als Freund hinzugefuegt",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("Zustimmen"),
    "g_chat_key_32": m2,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Das Passwort kann nicht korrekt analysiert werden, und die Nachricht kann voruebergehend nicht gesendet werden. Bitte importieren Sie das Wallet beim Beitritt zur Gruppe",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Chatverlauf loeschen?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Mitglied entfernen"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Mein QR-Code"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Melden"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Neuer Chat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Neue Gruppe"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR-Code"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Melden und blockieren",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Diese Nachricht wird an N42Wallet weitergeleitet. Dieser Kontakt wird nicht benachrichtigt.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Foto"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Nachricht loeschen"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Auf meinem Geraet loeschen",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Warten"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Zustimmen"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Meldegrund"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihren Meldegrund ein",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Wir werden Ihre Meldung ueberpruefen und innerhalb von 24 Stunden antworten.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Sie haben dies gemeldet - Klicken zum Anzeigen",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Sperrliste"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "g_chat_key_6": m3,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("Noch kein Kontakt"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Heute"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage(
      "Vor mehr als 3 Tagen",
    ),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Blockieren"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Hey, ich benutze N42Wallet zum Chatten und Geld senden. Installiere Wallet und schreib mir unter",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Antworten"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Die Nachricht wurde geloescht",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Jemand hat mich @ erwaehnt",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Hallo sagen"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Freunde hinzufuegen"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("Antragsgrund"),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transaktionen"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Verbinden"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Verfuegbare Netzwerke",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Nachricht signieren",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Verbinde"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Kopplung, bitte warten.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Trennen"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Ablehnen"),
    "g_face_1": MessageLookupByLibrary.simpleMessage("Biometrische Scan-Tipps"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie Ihren Fingerabdruck oder Ihr Gesicht zur Authentifizierung.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Biometrischer Scan fehlgeschlagen",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Tipps"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Biometrischer Scan erfolgreich",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Einrichten"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Sie haben keine biometrische Anmeldung eingerichtet. Gehen Sie zu den Systemeinstellungen.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie Ihr Gesicht oder Ihren Fingerabdruck, um fortzufahren.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Zurueck"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Es wird empfohlen, die Biometrie erneut zu aktivieren.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Gesichtsabgleich-Methode",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage(
      "Erneut verknuepfen",
    ),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Verknuepfen"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Verifizieren"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Sie koennen Ihre Gesichtsdaten direkt mit einer Wallet-Adresse verknuepfen (wenn Sie zuvor eine verknuepft haben, wird die alte Wallet-Adresse ueberschrieben), oder wenn Sie zuvor eine Wallet-Adresse verknuepft haben, koennen Sie auch manuell verifizieren, um die verknuepfte Wallet-Adresse abzurufen.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "Die mit Ihren Gesichtsdaten verknuepfte Wallet-Adresse wurde wie folgt erkannt, aber Sie haben dieses Wallet noch nicht in Ihre Wallet-Liste importiert.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Sie haben Ihre Gesichtsdaten mit diesem Wallet verknuepft.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Benutzerhinweis",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Was ist Gesichtsverknuepfung?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Die Gesichtsverknuepfung nutzt Gesichtserkennungstechnologie, um Ihre biometrischen Gesichtsmerkmale mit Ihrer Blockchain-Wallet-Adresse abzugleichen.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Dieser Prozess erhoet nicht nur den Transaktionskomfort, sondern staerkt auch die Kontosicherheit und stellt sicher, dass jede Aktion von Ihnen autorisiert ist.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Warum ist Gesichtsverknuepfung notwendig?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Durch die Verknuepfung Ihrer Gesichtsdaten wird Ihre Identitaet direkt mit Transaktionsaktivitaeten verknuepft, was den Identitaetsverifizierungsprozess vereinfacht und die Betriebseffizienz verbessert. Diese Technologie gewaehrleistet eine schnelle und sichere Identitaetsverifizierung bei sensiblen Vorgaengen wie Vermoegenstransfers oder Vertragsinteraktionen.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Wie werden meine Gesichtsdaten gespeichert und sind sie sicher?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Ihre Gesichtsdaten werden in verschluesselter Form auf einer oeffentlichen Blockchain gespeichert, nicht in einer zentralisierten Datenbank. Das bedeutet, dass das System Ihre Daten nur zur Identitaetsverifizierung entschluesseln und verwenden kann, wenn Sie es autorisieren, was Ihre Privatsphaere und Datensicherheit gewaehrleistet.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Wie wirkt sich die Gesichtsverknuepfung auf meine Kontosicherheit aus?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Die Gesichtsverknuepfung erhoeht Ihre Kontosicherheit, indem sichergestellt wird, dass alle sensiblen Aktionen nur mit Ihrer ausdruecklichen Genehmigung durchgefuehrt werden. Wir verwenden branchenfuehrende Verschluesselungstechnologie, um Ihre biometrischen Daten zu schuetzen und unbefugten Zugriff zu verhindern.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Sind meine Gesichtsdaten sicher?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolut. Alle biometrischen Daten werden streng verschluesselt und die hoechsten Sicherheitsstandards werden fuer Datenuebertragung und -speicherung eingehalten. Das System entschluesselt diese Daten nur bei Bedarf, um die Identitaetsverifizierung abzuschliessen.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Abgleich fehlgeschlagen!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Wallet-Adresse auswaehlen",
    ),
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage(
      "Verknuepfung aufheben",
    ),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Gesichtsdaten-Verifizierung fehlgeschlagen!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Gesichtsdaten-Verknuepfungsaufhebung fehlgeschlagen!",
    ),
    "g_face_match_key4": m7,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Adressfehler!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Gesichtsdaten-Verknuepfung",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Gesichtsabgleich",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage(
      "Erneut auswaehlen",
    ),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Abgleichen"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Nachrichten"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verifizierung"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Mitteilungen"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Lernen"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Freund einladen"),
    "g_key_1": MessageLookupByLibrary.simpleMessage(
      "Entfernen fehlgeschlagen!",
    ),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Senden"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Gas-Limit"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Keine weiteren"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Laden "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Adressbuch"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Wallet importieren"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Verwalten"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Neue Adresse"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Loeschen"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Speichern"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Kopieren"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Wallet erstellen/importieren",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Design"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("System"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Hell"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Dunkel"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Wallet-Liste"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Keine Daten"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Betrag ungueltig"),
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Haupt-Wallet"),
    "g_key_140": MessageLookupByLibrary.simpleMessage(
      "Transaktion erfolgreich",
    ),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Falsches Passwort"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnetz"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Hauptnetz"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Systemsprache"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Als Haupt-Wallet festlegen",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Absenden"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Wallet-Adresse"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Scannen, um Adresse zu kopieren",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Hinzufuegen"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Verifizierungs-Wallet auswaehlen",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Symbol"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Einfuegen"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Blockchain auswaehlen"),
    "g_key_175": MessageLookupByLibrary.simpleMessage(
      "Transaktion fehlgeschlagen",
    ),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Dies ist meine Wallet-Adresse",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Sonstiges"),
    "g_key_185": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich gespeichert",
    ),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Erfolgreich"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie das Wallet loeschen moechten?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Keine Berechtigung fuer Kamerazugriff.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Explorer"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Max"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Vermoegen"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Das Ledger ist leer!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Transaktionsuebersicht"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Verbindungsfehler, QR-Code erneut scannen.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Keine Berechtigung fuer Zugriff auf Fotoalbum.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Passwort bearbeiten"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Altes Passwort"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Guthaben werden synchronisiert...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Privater Schluessel"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort eingeben",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage(
      "Fehler beim privaten Schluessel",
    ),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Kaufen"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Verkaufen"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Marktinformationen"),
    "g_key_214": m9,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "Passwort stimmt nicht ueberein.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Guthaben"),
    "g_key_3": MessageLookupByLibrary.simpleMessage(
      "Hinzufuegen fehlgeschlagen!",
    ),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Empfangen"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Uebertragen"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("An"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Wallet-Adresse eingeben"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Verfuegbares Guthaben"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Betrag"),
    "g_key_46": m10,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Nicht genuegend Guthaben fuer diese Transaktion.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Senden"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Laden fehlgeschlagen!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Wallet"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Erstellen"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Von"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Bestaetigen"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Notiz"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Seed-Phrase"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Alle Token"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Einstellungen"),
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
      "Adresse wird berechnet...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Adressberechnung fehlgeschlagen. Bitte erneut versuchen.",
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
      "Biconomy-Konto",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Modulares ERC-7579 Smart Account mit Unterstützung für gaslose Transaktionen",
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
      "Ausführungs-Gas hoch",
    ),
    "g_key_aa_gas_warn_call_high_desc": m11,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Bereitstellungs-Gas-Overhead",
    ),
    "g_key_aa_gas_warn_deploy_desc": m12,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Paymaster-Overhead hoch",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m13,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Gas-Limit sehr hoch",
    ),
    "g_key_aa_gas_warn_total_high_desc": m14,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Mögliche Gas-Unterschätzung",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Das tatsächlich verwendete Gas könnte die Schätzung überschreiten. Erwägen Sie einen größeren Puffer.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Verifikations-Gas hoch",
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
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage(
      "Guthaben",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "Chains unterstützt",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Verfügbarkeit prüfen...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Chain-Abdeckung",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to pay for transaction gas fees",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Gesch. Kosten",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Gas-Optionen nicht geladen",
    ),
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "Nicht auf dieser Chain verfügbar",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "Angebot abgelaufen",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Wiederholen",
    ),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage("Sponsoring nicht verfügbar"),
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
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage("Wächter"),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage(
      "Schwellenwert",
    ),
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
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 Tag"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 Stunde"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 Tage"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 Tage"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage("Erlaubt"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "z.B. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Max. Betrag",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage(
      "Blockiert",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Ich verstehe die Berechtigungen dieses Schlüssels",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Mit genehmigten DApp-Verträgen interagieren",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel konnte nicht erstellt werden",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel erstellt",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "z.B. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Label / DApp-Name",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Gültig für",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Hohes Risiko — nur vertrauenswürdige DApps",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "DApp-Zugriff",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Volle Kontrolle",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Nur Senden",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Hohes Risiko",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Niedriges Risiko",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Mittleres Risiko",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Berechtigungen vor Bestätigung prüfen",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Berechtigungsebene wählen",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Token im gesetzten Limit übertragen",
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
    "g_key_address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Bitte Namen eingeben",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Bitte Adresse eingeben",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Bitte waehlen Sie einen Coin-Typ",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage(
      "Adresse bearbeiten",
    ),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich geloescht",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Coins auswaehlen"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Coins suchen"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Berechtigung prüfen",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Beanspruchen"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage(
      "Beansprucht",
    ),
    "g_key_airdrop_days_left": m16,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("Frist"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage(
      "Berechtigt",
    ),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Geschätzter Wert",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Filtern"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Keine Airdrops verfügbar",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Nicht berechtigt",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("Ausstehend"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "Hohe Priorität",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Niedrige Priorität",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Mittlere Priorität",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Anforderung erfüllt",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Nicht erfüllt",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Anforderungen",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage(
      "Sortieren nach",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Airdrop-Tracker",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Gesamt beansprucht",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage(
      "Bevorstehend",
    ),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Empfänger hinzufügen",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Alles löschen",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV-Format: Adresse,Betrag,Bezeichnung",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m17,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage(
      "Stapel ausführen",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "CSV exportieren",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Gas-Ersparnis",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "CSV importieren",
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
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Vorschau"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("Empfänger"),
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
      "Stapelüberweisung",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Gesamtbetrag",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Betrag"),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage(
      "Am günstigsten",
    ),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Sie erhalten (geschätzt)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage(
      "Am schnellsten",
    ),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("Bridge-Gebühr"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage(
      "Von Chain",
    ),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Angebot einholen",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Bridge-Verlauf",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Keine Routen verfügbar",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Empfohlen",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage(
      "Aktualisieren",
    ),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Route"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Chain suchen...",
    ),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Token auswählen",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage(
      "Geschätzte Zeit",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage("Zu Chain"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Bridge fehlgeschlagen",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transaktion ausstehend",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Bridge erfolgreich",
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
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("Beste Route"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Beste Quelle",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Blockchain"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Swap bestätigen",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas-Schätzung",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "DEX-Verlauf",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Keine Token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Keine Token gefunden",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Preiseinfluss",
    ),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Angebot fehlgeschlagen",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Wiederholen"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Symbol / Name / Adresse suchen",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Slippage-Toleranz",
    ),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX Swap in der App noch nicht unterstützt",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Bestätigt",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage(
      "Fehlgeschlagen",
    ),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "Ausstehend",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage(
      "Angeboten",
    ),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Tauschen"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap erfolgreich eingereicht",
    ),
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Transaktion fehlgeschlagen",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Sie zahlen"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Sie erhalten",
    ),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "Unterstützt ENS (.eth), Unstoppable Domains (.crypto/.wallet/…) und Solana SNS (.sol)",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Solana Name Service",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Solana-Domain nicht gefunden",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unstoppable Domains",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Unstoppable-Domain nicht gefunden oder keine Adresse für diese Chain",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Sammelüberweisung",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Verbrennen"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("N kaufen"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "N mit dem AST-Protokoll kaufen",
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
      "Tausche beliebige Token über Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX-Tausch"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Staking starten",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "APY wird geladen...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Mining"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Keine aktiven Positionen",
    ),
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Knoten-Mining",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Verdiene Belohnungen durch Teilnahme am Knoten-Mining",
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
      "Tauschtyp wählen",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Tauschen"),
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
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Resolved address updated",
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
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Die Registrierungsverpflichtung ist abgelaufen. Bitte starten Sie den Registrierungsprozess erneut.",
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
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Adresse kopiert",
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
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Invalid address (must be 0x + 40 hex chars)",
    ),
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
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "Erinnerung ist deaktiviert",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Ablauferinnerung aktivieren",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "Erinnerung ist aktiviert",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "30, 7 und 1 Tag vor Ablauf benachrichtigen",
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
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Senden an eigene Adresse nicht möglich",
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
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Create Subdomain",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain created",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Delete Subdomain",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "This subdomain will be permanently deleted.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain deleted",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "No subdomains yet",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Use letters, numbers and hyphens only",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Subdomain label",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. blog, mail, app",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Owner address",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Leave empty to use current wallet",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
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
      "Fehler beim Parsen der Antwortdaten!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio-Fehler"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Syntaxfehler bei Anfrage",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Nicht autorisiert, bitte anmelden",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage(
      "Zugriff verweigert",
    ),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Falsches Konto oder Passwort",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Anfragefehler"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Sie sind bereits auf einem anderen Geraet angemeldet und wurden abgemeldet.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Anfrage abgelaufen",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Serverfehler"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Dienst nicht implementiert",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Gateway-Fehler"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Dienst nicht verfuegbar",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("Gateway-Timeout"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "HTTP-Version wird nicht unterstuetzt",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Anfrage fehlgeschlagen, Fehlercode:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "System ist ausgelastet, bitte spaeter erneut versuchen",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Anfragefrequenz ist zu hoch",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Dekodierung fehlgeschlagen",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Die Transaktion befindet sich bereits auf der Blockchain",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Zertifikatskonfigurationsfehler!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Statuscode-Konfigurationsfehler!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage(
      "Unbekannter Fehler!",
    ),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Netzwerkverbindung abgelaufen, bitte Netzwerkeinstellungen ueberpruefen!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Server ist nicht erreichbar. Bitte spaeter erneut versuchen!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Anfrage wurde abgebrochen, bitte erneut anfordern!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Keystore exportieren",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("Backup-Tipps"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Verwenden Sie ein Passwort-Management-Tool zum Speichern.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Kopiert"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Kopieren abgebrochen",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Identitaets-Wallet",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Verschluesselte private Schluesseldatei.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Importmethode",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Keystore-Datei",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie die Keystore-Informationen ein.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Privaten Schluessel exportieren",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Wer den Keystore und das Passwort hat, hat volle Kontrolle ueber die Wallet-Vermoegen.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Sorgfaeltig notieren und an einem sicheren Ort aufbewahren. Mehrere physische Kopien sind die sicherste Aufbewahrungsmethode.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Wenn Ihr privater Schluessel verloren geht, kann er nicht wiederhergestellt werden. Erstellen Sie ein physisches Backup und bewahren Sie es sicher auf.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Offline speichern",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Speichern Sie nicht in E-Mail, Notizblock, Cloud-Speicher oder unsicherer Chat-Software.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Bitte Netzwerkuebertragung verwenden",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Bitte uebertragen Sie es unbedingt ueber Netzwerktools. Sobald Hacker es erhalten, fuehrt dies zu unwiederbringlichen finanziellen Verlusten",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Verwenden Sie Tools zum Speichern",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Bitte Feedback-Informationen ausfuellen",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Es gibt nicht hochgeladene Anhaenge",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Einreichung fehlgeschlagen",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich eingereicht",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Anhaenge"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Bis zu 5 Anhaenge hochladen, jeder Anhang darf nicht groesser als 100 MB sein",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Zum Wiederholen klicken",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage("Bitte anmelden"),
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
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Grundgebühr"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefiniert",
    ),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Gesch. Zeit",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Schnell"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage(
      "Maximale Gebühr",
    ),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Netzwerk ausgelastet",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Netzwerk frei",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Netzwerk normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Prioritätsgebühr",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Gas-Einstellungen",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Langsam"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Mittel"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Stark"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Muster zu einfach, bitte mehr Punkte verwenden",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Schwach"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m26,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Konten"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Konto hinzufügen",
    ),
    "g_key_hw_add_account_content": m27,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adresse kopiert",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Auf Ihrem Gerät bestätigen",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Hardware-Wallet verbinden",
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
      "Ableitungspfad",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Getrennt"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Bitte Bluetooth aktivieren",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Firmware-Version",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Zurück"),
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
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Mehr laden"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Konten werden geladen...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Bitte auf Ihrem Gerät bestätigen, falls aufgefordert",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Keine Konten gefunden",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Keine Geräte gefunden",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Gerät nicht verbunden",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m32,
    "g_key_hw_open_ledger_app_hint": m33,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Auf dem Gerät abgelehnt",
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
      "Suche nach Geräten...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Gerät auswählen",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Nachricht signieren",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Transaktion signieren",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Signalstärke",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Verbindungs-Timeout",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("Hardware-Wallet"),
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
      "Wallet-Konten",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Ein Waehrungs-Wallet fuer diesen Typ existiert bereits.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Keystore konnte nicht gelesen werden",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie die App beenden moechten?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Verfügbare Punkte",
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
      "Punkte beanspruchen",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Tägliches Check-in",
    ),
    "g_key_loyalty_earn_points": m35,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Verdient"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Punkteverlauf",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m36,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Eingeladene Freunde",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "Nächste Stufe",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Keine Belohnungen verfügbar",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Keine Aufgaben verfügbar",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Punkte"),
    "g_key_loyalty_points_to_next": m37,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Einlösen"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage(
      "Empfehlung",
    ),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Empfehlungsbonus",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Ihr Empfehlungscode",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Empfehlungslink",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage(
      "Belohnungen",
    ),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Ausgegeben"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Aufgabe erledigt",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Aufgaben"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Stufe"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Bronze"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Diamant",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Gold"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Platin",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage("Silber"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Punkte"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Gesamtpunkte",
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
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Marktkapitalisierung"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Handelsvolumen"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Gesamtangebot"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Im Umlauf"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Ueber"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Mehr"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Links"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Website"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Bitte Seed-Phrase eingeben",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Kamera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Foto auswaehlen"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Inhalt"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Name"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Zurueck"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Transaktion eingereicht",
    ),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Video auswaehlen"),
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
      "Ungültiger Betrag",
    ),
    "g_key_payment_approx_token": m38,
    "g_key_payment_approx_usdt": m39,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "Zahlungs-QR",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("Bestätigen"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "Zahlungsverlauf",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "Verlauf",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("Eingang"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Laden fehlgeschlagen",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Nicht festgelegt",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Unzureichendes Guthaben!",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Hauptkette nicht gefunden!",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("Ausgang"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Zahlungsbetrag festlegen",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Zahlung erfolgreich!",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Zahlung"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Unzureichendes USDT-Guthaben!",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Bitte USDT-Token hinzufügen!",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Aus Telefongalerie auswaehlen",
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
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QR-Code teilen"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Link teilen"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Teilen-Methode",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Die Datei ist zu gross zum Hochladen",
    ),
    "g_key_squad_k15": m40,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Kontakt hinzufuegen",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Kontakt"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Nach E-Mail suchen",
    ),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Belohnungen beanspruchen",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Provision"),
    "g_key_stake_d_unbond": m41,
    "g_key_stake_days_left": m42,
    "g_key_stake_days_remaining": m43,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegierer",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Liquid Staking",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Mindesteinlage",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Keine Staking-Positionen",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ausstehende Belohnungen",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Meine Positionen",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protokoll"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restaken"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Belohnungen"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Validator auswählen",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Staken"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Staking"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Gesamt gestaked",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("Entsperren"),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Entsperrungszeitraum",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Entstaken"),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Betriebszeit"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validator"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validatoren",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas-Preis"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Maximale Gasgebuehr"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Maximale Gebuehr pro Gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Ausstehend"),
    "g_key_t_29": m44,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Miner-Gebuehr"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Fortfahren"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Wallet-Passwort"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort darf nicht leer sein",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Falsches Wallet-Passwort",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Bitte Wallet-Passwort eingeben",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Gasgebuehr-Rate"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Durchschnittliche Gasgebuehr-Rate des letzten Blocks",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Ausgehend"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine ganze Zahl groesser als 0 ein.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Daten konnten nicht abgerufen werden",
    ),
    "g_key_t_45": m45,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Empfaengeradresse ueberpruefen",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Suchen"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Kein Konto"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Eingehend"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Ungueltige Adresse"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Kontoverifizierung erfolgreich",
    ),
    "g_key_t_52": m46,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Die Empfaengeradresse hat kein Konto, und die erste Ueberweisung muss mindestens 10 XRP betragen",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Verbrauchtes Gas"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m47,
    "g_key_time_hours_ago": m48,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m49,
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage(
      "Transaktionshistorie",
    ),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Transaktionsdetails"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Bitte Transaktionsbelege im Verlauf ansehen",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Ausgabebetrag"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Empfangsbetrag"),
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
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT-Typen"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Follower"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Benutzertypen"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Website"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Produktlink"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Medienplattformen"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Wallet-Adresse"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Spitzname"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Avatar-Upload fehlgeschlagen",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Beschreibung"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Kuenstlerinformationen"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage(
      "Sie sind kein Kuenstler",
    ),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Hier klicken, um sich als Kuenstler zu bewerben",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Name"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Einnahmen"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Unlink Account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Ich habe gelesen und akzeptiere die ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Allgemeine Geschaeftsbedingungen",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Datenschutzrichtlinie und Erklaerung zur Erhebung personenbezogener Daten",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Neueste Version gefunden",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Sofort aktualisieren"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Neue Version gefunden"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Bereits die neueste Version",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "g_key_verification_code_sent": m50,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Seed-Phrase anzeigen",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Bitte notieren Sie Ihre Seed-Phrase und bewahren Sie sie sicher auf.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Versuchen Sie jetzt, Ihre Seed-Phrase erneut einzugeben.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage(
      "Konto importieren",
    ),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Konto erstellen"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "Sie sind fertig!",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Sie koennen jetzt Ihr Wallet vollstaendig nutzen.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Loslegen"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "Vorerst ueberspringen",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Sie koennen das Backup der Seed-Phrase vorerst ueberspringen und es bei Bedarf jederzeit in den Einstellungen erneut durchfuehren.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Direkt erstellen",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich erstellt",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Wenn Sie Ihre Wallet-Details einsehen oder den Keystore exportieren moechten, gehen Sie zu Seitenleiste > Wallet verwalten ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Meinen Keystore exportieren",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Sichern Sie Ihr Wallet durch ein Backup",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Ein Keystore ist ein Repository fuer Sicherheitszertifikate und zugehoerige private Schluessel.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Schritt 1: Gehen Sie zu Wallet verwalten.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Schritt 2: Waehlen Sie die Wallet-Adresse aus.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Schritt 3: Druecken Sie Keystore exportieren.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Zu Wallet verwalten gehen",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Zurueck zur Startseite",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Wallet hinzufuegen",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Ein Wallet mit einer Seed-Phrase erstellen.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Wallet-Namen eingeben",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Sie haben Ihre Wallet-Seed-Phrase nicht gesichert!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("Jetzt sichern"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort festlegen",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("Wallet sichern"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Bitte notieren Sie die folgende Seed-Phrase",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Starten"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Mit dem Internet verbundene Geraete koennen Ihre Informationen preisgeben. Wir empfehlen, die Seed-Phrase aufzuschreiben und sicher aufzubewahren.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Warnung: Geben Sie Ihre Seed-Phrase niemals an andere weiter. N42Wallet wird Sie niemals nach diesen Informationen fragen. Seien Sie aeusserst vorsichtig und bewahren Sie sie offline sicher auf. Wenn Ihre Seed-Phrase offengelegt wird, koennten Sie alle Ihre Vermoegen verlieren und sie nicht wiederherstellen koennen.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Warnung: Die Seed-Phrase ist die einzige Moeglichkeit, Ihre Wallet-Vermoegen wiederherzustellen.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage(
      "Naechster Schritt",
    ),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Klicken, um Seed-Phrase anzuzeigen",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Bitte stellen Sie sicher, dass sich keine anderen Personen oder Kameras in der Naehe befinden",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Seed-Phrase bestaetigen",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Wallet-Informationen",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Wallet-Name"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Bitte sichern Sie zuerst Ihre Wallet-Seed-Phrase!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Seed-Phrase ueberpruefen",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Geben Sie jetzt Ihre Seed-Phrase ein.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Phrase festlegen"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Bitte notieren Sie Ihre Seed-Phrase und bewahren Sie sie sicher auf. Sie benoetigen sie, um Ihr Kryptowaehrungs-Wallet zu importieren oder wiederherzustellen.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Wallet bearbeiten",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Zeit"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Ergebnis"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Transaktions-Hash",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Hinzufuegen"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Pfad"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Block"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Wert"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Beschleunigen"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Hinweis"),
    "g_key_wallet_m1": m51,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie Ihr Konto kuendigen moechten?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Abmeldung bestaetigen",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Bitte Google-Verifizierungscode eingeben.",
    ),
    "g_key_wallet_m19": m52,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Der aktuelle Token wurde nicht hinzugefuegt.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihre Seed-Phrase mit durch Leerzeichen getrennten Woertern ein",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Wallet importieren",
    ),
    "g_key_wallet_m3": m53,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Das aktuelle Token-Guthaben ist unzureichend.",
    ),
    "g_key_wallet_m5": m54,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Signaturfehler"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("Kontokuendigung"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Verifizierungscode eingeben.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Wallet verwalten",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reserviert"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Basisreserve"),
    "g_key_xml_11": m55,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage(
      "Inkrementelle Reserve",
    ),
    "g_key_xml_22": m56,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Besitzobjekte",
    ),
    "g_key_xml_33": m57,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Wie man den Gesamtreservebetrag berechnet",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Gesamtreserve = Basisreserve + (Anzahl der Besitzobjekte x Inkrementelle Reserve)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID und Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Aktuelles Passwort"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Neues Passwort"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Neues Passwort bestaetigen",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6-stellige Zahl"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Passwoerter und Biometrie",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Muster-Passwort"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort festlegen",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Fuer Ihre Kontosicherheit legen Sie bitte ein Gruppenpasswort fest",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort erneut zeichnen",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort zeichnen",
    ),
    "g_lock_key21": m58,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort zuruecksetzen",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Zu viele falsche Eingaben, bitte setzen Sie das Passwort zurueck",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort hinzufuegen?",
    ),
    "g_lock_key25": m59,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("Sperrbildschirmseite"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Automatische Sperre"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Erfolgreich"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Biometrische Erkennung ist nicht aktiviert",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Biometrische Verifizierung hinzufuegen?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage(
      "Passwort zuruecksetzen",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("N entsperren?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Cloud-Verifizierungsaktivitaet",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Einrichtung erfordert eine kleine Menge fuer Gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Sie sind erfolgreich einem Gruppenknoten auf N42Wallet beigetreten. Teilen Sie den Link, um Freunde einzuladen, den Knoten zu aktivieren und die Verifizierung zu starten!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Mit Freunden teilen",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Fortfahren"),
    "g_mining_key63": m60,
    "g_mining_key73": m61,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Ich habe gerade einen Knoten auf @N42Wallet eingerichtet und die Verifizierung auf mobilen Geraeten gestartet! Komm und mach mit. Die dezentralisierte Zukunft ist mobil!",
    ),
    "g_mining_key76": m62,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Einloesung nach 768s verfuegbar.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Anfragen davor werden nicht bearbeitet.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Heutige Belohnung",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Bitte behandeln Sie die folgenden Daten als wichtigen Schluessel. Wir empfehlen, sie sofort zu kopieren und an einem vertrauenswuerdigen Ort zu sichern.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Daten kopieren"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inaktiv"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage("Validator-Liste"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Import erfolgreich",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Verschluesselte Daten duerfen nicht leer sein!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Passwort darf nicht leer sein!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Entschluesselung fehlgeschlagen. Bitte ueberpruefen Sie, ob das Passwort korrekt ist!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Nicht unterstuetztes verschluesseltes Datenformat!",
    ),
    "g_mining_key_109": m63,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Gestrige Belohnungen",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Verschluesselte Daten",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "Dateien importieren",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Bitte verschluesselte Daten eingeben.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Importiere..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Bestaetigung"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Die Einloesung dauert einige Zeit, bitte warten Sie einen Moment!",
    ),
    "g_mining_key_116": m64,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Belohnung sammelt sich taeglich an und wird erst an Ihr N-Wallet gesendet, wenn sie ~0,5 N erreicht.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Gesamtbelohnungen",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Geminter Wert"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Berechnet basierend auf dem Marktpreis von N * die gesamten N-Belohnungen.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Gewinne",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage(
      "Plaene auswaehlen",
    ),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Entsperrungszeitraum: Jederzeit entsperrbar",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Maximale jaehrliche Belohnung",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Belohnungsverteilung",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Taegliches Limit"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Geschwindigkeit"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Verifizierungsplaene",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Zahlungsmethode auswaehlen",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Zahlungsmethoden"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Mit N bezahlen"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Wallet-Guthaben"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Sie haben nicht genuegend N fuer diese Transaktion",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Deaktiviert"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Mehr anzeigen"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Verifizierungsstatus",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Sperren Sie N, um Verifizierungsbelohnungen zu starten.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Einstieg"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage(
      "Erweiterter Knoten",
    ),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Einstiegs-Knoten"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro-Knoten"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 Bloecke/Tag ~ 70 Min.",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Plan auswaehlen"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 Bloecke/Tag ~ 15 Min.",
    ),
    "g_mining_key_71": m65,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 Sekunden pro Pruefung",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Cloud-Verifizierung gestartet",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Die Testkette wird aktualisiert und Bloecke koennen voruebergehend nicht verifiziert werden.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Werden Aufgaben an vier aufeinanderfolgenden Tagen nicht erledigt, gibt es keine Einnahmen und es besteht ein Strafrisiko.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Risikobewertung"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Einloesen"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Bitte speichern Sie zuerst das oeffentliche und private Schluesselpaar des Validators.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Exportieren"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Unzureichende Mittel fuer die Uebertragung.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("Validator-Liste"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Validator importieren",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Der Validator existiert bereits",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Niedriges Risiko"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Maessig Risiko"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Belohnungen der letzten 7 Tage",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Hohes Risiko"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Der Vertrag wird geladen und kann derzeit nicht verifiziert werden. Bitte warten Sie einen Moment!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("Sicherheitstipps"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Hintergrundverifizierung",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Bitte bewahren Sie Ihren privaten Schluessel oder Ihre Seed-Phrase sicher auf.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Ihr privater Schluessel oder Ihre Seed-Phrase ist das einzige Zugangsrecht zu Ihren Wallet-Vermoegen.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Bitte bewahren Sie sie an einem sicheren Ort auf (Papier, Passwort-Manager, etc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Machen Sie keine Screenshots, laden Sie sie nicht ins Internet hoch und teilen Sie sie mit niemandem.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Einmal verloren oder kompromittiert, koennen Ihre Wallet-Vermoegen nicht wiederhergestellt werden.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Bestaetigen und speichern",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Passwort setzen und verschluesseln",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Bitte Verschluesselungspasswort eingeben",
    ),
    "g_mining_key_98": m66,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Ihr Passwort erneut ein, um es zu bestaetigen",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Entsperrungszeitraum:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Jederzeit entsperrbar",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Teilen"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Empfehlung"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Freunde werben und N-Token erhalten!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Sie erhalten bis zu ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N, wenn Ihre Empfehlung die Verifizierung startet!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Werben ueber"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("Code"),
    "g_swap_key_14": m67,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Fehler beim Abrufen des Coin-Preises.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Mit dem Fortfahren stimmen Sie den folgenden ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Allgemeinen Geschaeftsbedingungen zu.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Abschliessen"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Ihr Swap wird in Kuerze verteilt. Bitte haben Sie Geduld.",
    ),
    "g_swap_key_20": m68,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Kosten fuer den Betrieb eines Knotens: Gruppenverifizierung 1-49 N Basis-Knoten: 50 N Premium-Knoten: 100 N Pro-Knoten: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Unbezahlt"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Zahlung wird bestaetigt",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Zur Verteilung"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage(
      "Swap-Zusammenfassung",
    ),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Neues Guthaben"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Sie zahlen"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Datum"),
    "g_swap_key_31": m69,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Swaps koennen auf den entsprechenden Blockchain-Explorern (Etherscan, BscScan, TRONSCAN und unserem eigenen) eingesehen werden.",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Zu N tauschen"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Sie erhalten"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Swap-Vorschau"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "g_token_m_key_1": m70,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Jeder kann Token erstellen, einschliesslich gefaelschter Versionen bestehender Token. Recherchieren Sie immer einen Token, bevor Sie ihn importieren.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Token"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Token suchen"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Blockchain-Name"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage(
      "Blockchain-Symbol",
    ),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("Chain-ID"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Dezimalstellen"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefinierte Blockchain hinzufuegen",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0-18 uint"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage(
      "Token hinzufuegen",
    ),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Formatfehler!"),
    "g_token_m_key_22": m71,
    "g_token_m_key_23": m72,
    "g_token_m_key_24": m73,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage(
      "Token importieren",
    ),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Alle Netzwerke"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefinierter Token",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Token-Adresse"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Token-Symbol"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Token-Dezimalstellen",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importieren"),
    "g_unlock_key10": m74,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Fingerabdruck- oder Gesichtserkennung nicht aktiviert?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort zeichnen",
    ),
    "g_unlock_key4": m75,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
    "g_unlock_key6": m76,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Authentifizierung fehlgeschlagen",
    ),
    "g_unlock_key8": m77,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Sie koennen auch "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Google-Authentifizierung",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Verknuepfen",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator herunterladen",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Anleitung",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Oeffnen Sie Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Sie sehen einen 6-stelligen Verifizierungscode auf dem Bildschirm.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Kopieren Sie den 6-stelligen Code und fuegen Sie ihn in N42Wallet ein.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Dann wird Ihr Authenticator erfolgreich verknuepft.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Backup-Schluessel",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Kopieren Sie den Schluessel zu Google Authenticator",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Google-Verifizierungscode eingeben",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Verifizierungscode eingeben",
    ),
    "google_verification_message21": m78,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Google-Schluessel konnte nicht abgerufen werden",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Zwei-Faktor-Authentifizierung (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Um Ihr Konto zu schuetzen, wird empfohlen, mindestens eine 2FA zu aktivieren.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Die Google Authenticator-App schuetzt Ihre Auszahlungen und Ihr N42Wallet-Konto.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Herunterladen und installieren",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Bitte laden Sie Google Authenticator herunter und installieren Sie es. Druecken Sie dann \'Verknuepfen\', um Ihr N42Wallet-Konto zu verknuepfen.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage(
      "Wichtiger Hinweis",
    ),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Passwort vergessen?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Empfehlungscode",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Empfehlungscode",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Noch kein Konto? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich erstellt",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Erfolgreich zurueckgesetzt",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Bereits ein Konto? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Code erneut senden in ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Code erfolgreich gesendet",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-Mail nicht registriert",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Code senden fehlgeschlagen",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "Bitte zuerst anmelden",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "next": MessageLookupByLibrary.simpleMessage("Weiter"),
    "nicknameMessage": m79,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Passwoerter stimmen nicht ueberein",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Profil bearbeiten",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Fotografieren"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Verifizierungscode eingeben",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Bitte E-Mail eingeben",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Bitte Passwort eingeben",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Bitte Adresse eingeben",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Passwort wiederholen",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Waehlen Sie ein Passwort (8-18 Zeichen)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Passwort bestaetigen",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Passwort erneut eingeben",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Code eingeben"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("OTP-Code"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Setzen Sie Ihr Passwort zurueck",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Wallet verwalten"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("Ueber die App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Sicherheit"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Neuen Chat verwenden"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Erweitertes Chat-Erlebnis aktivieren",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Wallet-Adressen"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaktion"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Sprache"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Design"),
    "search": MessageLookupByLibrary.simpleMessage("Suchen"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Bitte lesen Sie die Vereinbarung und bestaetigen Sie",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("Verifizierung"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Wenn ich meine Seed-Phrase verliere, sind meine Mittel fuer immer verloren.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Wenn ich meine Seed-Phrase jemandem offenbare oder teile, koennen meine Mittel gestohlen werden.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Es liegt in meiner Verantwortung, meine Seed-Phrase sicher aufzubewahren.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("Seed-Phrase falsch."),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die Seed-Phrase fuer das Wallet ein, das Sie importieren moechten.",
    ),
  };
}
