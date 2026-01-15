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

  static String m0(value) => "Ich bin ${value}";

  static String m1(value) => "Chat-Mitglied (${value})";

  static String m2(value) =>
      "Sind Sie sicher, dass Sie ${value} als Freund hinzufuegen moechten";

  static String m3(value) =>
      "Sie wurden bereits verknuepft und koennen derzeit nicht erneut verknuepft werden. Verknuepfungsadresse: ${value}.";

  static String m4(value) =>
      "Verknuepfung erfolgreich. Verknuepfungsadresse: ${value}";

  static String m5(value) => "Es gibt keine N42chain im ${value}-Wallet!";

  static String m6(value) => "Abgleich erfolgreich. Adresse: ${value}.";

  static String m7(value) => "Betrag groesser als ${value}.";

  static String m8(value) =>
      "Das Wallet existiert bereits, der Wallet-Name ist \"${value}\"";

  static String m9(value) =>
      "Geben Sie einen Betrag groesser als ${value} ein.";

  static String m10(value) =>
      "Sind Sie sicher, dass Sie den Kontakt ${value} loeschen moechten?";

  static String m11(value) => "Sie haben nicht genuegend \"${value}\"";

  static String m12(value) =>
      "\"${value}\" Konto konnte nicht abgerufen werden";

  static String m13(value) => "Minimum ${value} XRP fuer erste Ueberweisung";

  static String m14(value) => "Keine ${value}-Blockchain hinzugefuegt.";

  static String m15(value) =>
      "${value} hat unabgeschlossene Transaktionen, bitte spaeter erneut versuchen.";

  static String m16(value) => "Keine Adresse fuer ${value} gefunden.";

  static String m17(value) => "Unzureichendes Guthaben von ${value}.";

  static String m18(value, value1) =>
      "Jedes XRP-Konto muss ${value} XRP (${value1} Drops) als Grundlage reservieren, die nicht ausgegeben werden kann.";

  static String m19(value, value1) =>
      "Fuer jedes Objekt, das das Konto besitzt, werden ${value} XRP (${value1} Drops) zur Reserve hinzugefuegt.";

  static String m20(value, value1) =>
      "Dieses Konto besitzt ${value} Objekte, was bedeutet, dass zusaetzlich ${value1} XRP reserviert sind.";

  static String m21(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m22(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m23(value) =>
      "Sie haben erfolgreich einen ${value} eingerichtet und werden mit N42Wallet die Verifizierung beginnen!";

  static String m24(value) =>
      "Tritt meiner ${value}-Gruppe auf @N42Wallet bei, um ein fruehzeitiger Miner einer Layer-1-Blockchain zu sein und Krypto auf deinem Handy zu erhalten!";

  static String m25(value) =>
      "Sperren Sie ${value} N, um einen Validator zu betreiben.";

  static String m26(value) => "Import fehlgeschlagen: ${value}";

  static String m27(value) =>
      "Für den Erhalt von Belohnungen ist ein Mindest-Staking-Betrag von ${value} erforderlich.";

  static String m28(value, value1) =>
      "${value} N alle ${value1} geminte Bloecke";

  static String m29(value) => "Muss ${value} Zeichen sein";

  static String m30(value) => "${value} Unzureichendes Guthaben.";

  static String m31(value) => "${value} eingehend...";

  static String m32(value) =>
      "${value} in der App getauscht wird in Kuerze an Ihr Wallet verteilt und kann nicht ueber diesen Prozess verkauft werden. Es kann zum Betrieb eines Knotens verwendet werden.";

  static String m33(value) => "Max. ${value} Zeichen";

  static String m34(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt!";

  static String m35(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt, moechten Sie sie hinzufuegen?";

  static String m36(value) => "${value} Adresstestverbindung fehlgeschlagen!";

  static String m37(value) =>
      "Die Anwendung wird in ${value} Sekunden entsperrt.";

  static String m38(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m39(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m40(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m41(value) => "${value}-Passwort eingeben";

  static String m42(value) => "0-${value} Zeichen";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
        "Create_account": MessageLookupByLibrary.simpleMessage("Registrieren"),
        "Create_your_account":
            MessageLookupByLibrary.simpleMessage("Konto erstellen"),
        "Edit": MessageLookupByLibrary.simpleMessage("Bearbeiten"),
        "Verification": MessageLookupByLibrary.simpleMessage("Verifizierung"),
        "address_Information":
            MessageLookupByLibrary.simpleMessage("Adressinformationen"),
        "code_403": MessageLookupByLibrary.simpleMessage(
            "Konto voruebergehend fuer einen Tag gesperrt"),
        "code_err_tips": MessageLookupByLibrary.simpleMessage(
            "Der Code ist falsch. Bitte erneut versuchen."),
        "copy": MessageLookupByLibrary.simpleMessage("Erfolgreich kopiert"),
        "copyAddress": MessageLookupByLibrary.simpleMessage("Adresse kopieren"),
        "descO":
            MessageLookupByLibrary.simpleMessage("Beschreibung (optional)"),
        "editPhoto": MessageLookupByLibrary.simpleMessage("Foto bearbeiten"),
        "email_code_error": MessageLookupByLibrary.simpleMessage(
            "Authentifizierungscode konnte nicht abgerufen werden"),
        "email_code_finish": MessageLookupByLibrary.simpleMessage(
            "Authentifizierungscode erfolgreich gesendet, bitte E-Mail pruefen"),
        "email_code_input_error": MessageLookupByLibrary.simpleMessage(
            "Authentifizierungscode-Fehler"),
        "email_error":
            MessageLookupByLibrary.simpleMessage("Ungueltige E-Mail-Adresse"),
        "email_verification": MessageLookupByLibrary.simpleMessage(
            "E-Mail-Adresse Authentifizierung"),
        "email_verification_message1": MessageLookupByLibrary.simpleMessage(
            "Die E-Mail-Adresse-Authentifizierungs-App schuetzt Ihre Auszahlungen und Ihr N42Wallet-Konto."),
        "email_verification_message2": MessageLookupByLibrary.simpleMessage(
            "E-Mail-Verifizierung hinzufuegen?"),
        "file": MessageLookupByLibrary.simpleMessage("Datei"),
        "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
            "Token koennen nur innerhalb desselben Netzwerks gesendet werden. Das Senden aus anderen Netzwerken kann zu Verlust fuehren."),
        "g_app_share_key_2":
            MessageLookupByLibrary.simpleMessage("Scannen zum Empfangen"),
        "g_browser_key1":
            MessageLookupByLibrary.simpleMessage("Bitte URL eingeben"),
        "g_browser_key10":
            MessageLookupByLibrary.simpleMessage("Beschreibung eingeben"),
        "g_browser_key11": MessageLookupByLibrary.simpleMessage("Browser"),
        "g_browser_key12":
            MessageLookupByLibrary.simpleMessage("Browser-Cache loeschen"),
        "g_browser_key13":
            MessageLookupByLibrary.simpleMessage("DApp automatisch verbinden"),
        "g_browser_key14": MessageLookupByLibrary.simpleMessage(
            "Bitte Verbindung mit DApp bestaetigen"),
        "g_browser_key16":
            MessageLookupByLibrary.simpleMessage("Alle schliessen"),
        "g_browser_key17": MessageLookupByLibrary.simpleMessage("Fertig"),
        "g_browser_key3": MessageLookupByLibrary.simpleMessage("Lesezeichen"),
        "g_browser_key4": MessageLookupByLibrary.simpleMessage(
            "Noch keine Lesezeichen hinzugefuegt"),
        "g_browser_key5": MessageLookupByLibrary.simpleMessage("Lesezeichen"),
        "g_browser_key6": MessageLookupByLibrary.simpleMessage("Name"),
        "g_browser_key7":
            MessageLookupByLibrary.simpleMessage("Bitte Namen eingeben"),
        "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
        "g_browser_key9": MessageLookupByLibrary.simpleMessage("Beschreibung"),
        "g_chat_key_1":
            MessageLookupByLibrary.simpleMessage("Gruppenchat starten"),
        "g_chat_key_10": m0,
        "g_chat_key_11":
            MessageLookupByLibrary.simpleMessage("Freunde einladen"),
        "g_chat_key_12":
            MessageLookupByLibrary.simpleMessage("Kontakt auswaehlen"),
        "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Fertig"),
        "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
            "Mindestens 2 Kontakte auswaehlen"),
        "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Freunddetails"),
        "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Gruppendetails"),
        "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
            "Weitere Gruppenmitglieder anzeigen"),
        "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Gruppenname"),
        "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Neuer Freund"),
        "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
            "Sind wir sicher, dass wir die Gruppe aufloesen?"),
        "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
            "Sind Sie sicher, dass Sie diese Gruppe verlassen moechten?"),
        "g_chat_key_22":
            MessageLookupByLibrary.simpleMessage("Gruppe aufloesen"),
        "g_chat_key_23":
            MessageLookupByLibrary.simpleMessage("Gruppe verlassen"),
        "g_chat_key_24":
            MessageLookupByLibrary.simpleMessage("Gruppenchat-Namen aendern"),
        "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
            "Wenn der Gruppenchat-Name geaendert wird, werden andere Mitglieder innerhalb der Gruppe benachrichtigt."),
        "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Fertig"),
        "g_chat_key_27":
            MessageLookupByLibrary.simpleMessage("Freundschaftsanfrage"),
        "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
            "Anfrage, Sie als Freund hinzuzufuegen"),
        "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
            "Freundschaftsanfrage genehmigt"),
        "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Hinzugefuegt"),
        "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
            "Sie wurden als Freund hinzugefuegt"),
        "g_chat_key_31": MessageLookupByLibrary.simpleMessage("Zustimmen"),
        "g_chat_key_32": m1,
        "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
            "Das Passwort kann nicht korrekt analysiert werden, und die Nachricht kann voruebergehend nicht gesendet werden. Bitte importieren Sie das Wallet beim Beitritt zur Gruppe"),
        "g_chat_key_34":
            MessageLookupByLibrary.simpleMessage("Chatverlauf loeschen?"),
        "g_chat_key_35":
            MessageLookupByLibrary.simpleMessage("Mitglied entfernen"),
        "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Mein QR-Code"),
        "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
        "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Melden"),
        "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Neuer Chat"),
        "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Neue Gruppe"),
        "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR-Code"),
        "g_chat_key_44":
            MessageLookupByLibrary.simpleMessage("Melden und blockieren"),
        "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
            "Diese Nachricht wird an N42Wallet weitergeleitet. Dieser Kontakt wird nicht benachrichtigt."),
        "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
        "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Foto"),
        "g_chat_key_48":
            MessageLookupByLibrary.simpleMessage("Nachricht loeschen"),
        "g_chat_key_49":
            MessageLookupByLibrary.simpleMessage("Auf meinem Geraet loeschen"),
        "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Warten"),
        "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Zustimmen"),
        "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Meldegrund"),
        "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
            "Geben Sie Ihren Meldegrund ein"),
        "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
            "Wir werden Ihre Meldung ueberpruefen und innerhalb von 24 Stunden antworten."),
        "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
            "Sie haben dies gemeldet - Klicken zum Anzeigen"),
        "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Sperrliste"),
        "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Entfernen"),
        "g_chat_key_6": m2,
        "g_chat_key_60":
            MessageLookupByLibrary.simpleMessage("Noch kein Kontakt"),
        "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Heute"),
        "g_chat_key_62":
            MessageLookupByLibrary.simpleMessage("Vor mehr als 3 Tagen"),
        "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Blockieren"),
        "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
            "Hey, ich benutze N42Wallet zum Chatten und Geld senden. Installiere Wallet und schreib mir unter"),
        "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Antworten"),
        "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
            "Die Nachricht wurde geloescht"),
        "g_chat_key_68":
            MessageLookupByLibrary.simpleMessage("Jemand hat mich @ erwaehnt"),
        "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Hallo sagen"),
        "g_chat_key_8":
            MessageLookupByLibrary.simpleMessage("Freunde hinzufuegen"),
        "g_chat_key_9": MessageLookupByLibrary.simpleMessage("Antragsgrund"),
        "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transaktionen"),
        "g_connect_key1": MessageLookupByLibrary.simpleMessage("Verbinden"),
        "g_connect_key11":
            MessageLookupByLibrary.simpleMessage("Verfuegbare Netzwerke"),
        "g_connect_key12":
            MessageLookupByLibrary.simpleMessage("Nachricht signieren"),
        "g_connect_key13": MessageLookupByLibrary.simpleMessage("Verbinde"),
        "g_connect_key14":
            MessageLookupByLibrary.simpleMessage("Kopplung, bitte warten."),
        "g_connect_key2": MessageLookupByLibrary.simpleMessage("Trennen"),
        "g_connect_key3": MessageLookupByLibrary.simpleMessage("Ablehnen"),
        "g_face_1":
            MessageLookupByLibrary.simpleMessage("Biometrische Scan-Tipps"),
        "g_face_10": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie Ihren Fingerabdruck oder Ihr Gesicht zur Authentifizierung."),
        "g_face_2": MessageLookupByLibrary.simpleMessage(
            "Biometrischer Scan fehlgeschlagen"),
        "g_face_3": MessageLookupByLibrary.simpleMessage("Tipps"),
        "g_face_4": MessageLookupByLibrary.simpleMessage(
            "Biometrischer Scan erfolgreich"),
        "g_face_5": MessageLookupByLibrary.simpleMessage("Einrichten"),
        "g_face_6": MessageLookupByLibrary.simpleMessage(
            "Sie haben keine biometrische Anmeldung eingerichtet. Gehen Sie zu den Systemeinstellungen."),
        "g_face_7": MessageLookupByLibrary.simpleMessage(
            "Scannen Sie Ihr Gesicht oder Ihren Fingerabdruck, um fortzufahren."),
        "g_face_8": MessageLookupByLibrary.simpleMessage("Zurueck"),
        "g_face_9": MessageLookupByLibrary.simpleMessage(
            "Es wird empfohlen, die Biometrie erneut zu aktivieren."),
        "g_face_match_key1":
            MessageLookupByLibrary.simpleMessage("Gesichtsabgleich-Methode"),
        "g_face_match_key10": m3,
        "g_face_match_key11": m4,
        "g_face_match_key12":
            MessageLookupByLibrary.simpleMessage("Erneut verknuepfen"),
        "g_face_match_key13":
            MessageLookupByLibrary.simpleMessage("Verknuepfen"),
        "g_face_match_key14":
            MessageLookupByLibrary.simpleMessage("Verifizieren"),
        "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
            "Sie koennen Ihre Gesichtsdaten direkt mit einer Wallet-Adresse verknuepfen (wenn Sie zuvor eine verknuepft haben, wird die alte Wallet-Adresse ueberschrieben), oder wenn Sie zuvor eine Wallet-Adresse verknuepft haben, koennen Sie auch manuell verifizieren, um die verknuepfte Wallet-Adresse abzurufen."),
        "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
            "Die mit Ihren Gesichtsdaten verknuepfte Wallet-Adresse wurde wie folgt erkannt, aber Sie haben dieses Wallet noch nicht in Ihre Wallet-Liste importiert."),
        "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
            "Sie haben Ihre Gesichtsdaten mit diesem Wallet verknuepft."),
        "g_face_match_key18":
            MessageLookupByLibrary.simpleMessage("Benutzerhinweis"),
        "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
            "Was ist Gesichtsverknuepfung?"),
        "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
            "Die Gesichtsverknuepfung nutzt Gesichtserkennungstechnologie, um Ihre biometrischen Gesichtsmerkmale mit Ihrer Blockchain-Wallet-Adresse abzugleichen."),
        "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
            "Dieser Prozess erhoet nicht nur den Transaktionskomfort, sondern staerkt auch die Kontosicherheit und stellt sicher, dass jede Aktion von Ihnen autorisiert ist."),
        "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
            "Warum ist Gesichtsverknuepfung notwendig?"),
        "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
            "Durch die Verknuepfung Ihrer Gesichtsdaten wird Ihre Identitaet direkt mit Transaktionsaktivitaeten verknuepft, was den Identitaetsverifizierungsprozess vereinfacht und die Betriebseffizienz verbessert. Diese Technologie gewaehrleistet eine schnelle und sichere Identitaetsverifizierung bei sensiblen Vorgaengen wie Vermoegenstransfers oder Vertragsinteraktionen."),
        "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
            "Wie werden meine Gesichtsdaten gespeichert und sind sie sicher?"),
        "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
            "Ihre Gesichtsdaten werden in verschluesselter Form auf einer oeffentlichen Blockchain gespeichert, nicht in einer zentralisierten Datenbank. Das bedeutet, dass das System Ihre Daten nur zur Identitaetsverifizierung entschluesseln und verwenden kann, wenn Sie es autorisieren, was Ihre Privatsphaere und Datensicherheit gewaehrleistet."),
        "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
            "Wie wirkt sich die Gesichtsverknuepfung auf meine Kontosicherheit aus?"),
        "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
            "Die Gesichtsverknuepfung erhoeht Ihre Kontosicherheit, indem sichergestellt wird, dass alle sensiblen Aktionen nur mit Ihrer ausdruecklichen Genehmigung durchgefuehrt werden. Wir verwenden branchenfuehrende Verschluesselungstechnologie, um Ihre biometrischen Daten zu schuetzen und unbefugten Zugriff zu verhindern."),
        "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
            "Sind meine Gesichtsdaten sicher?"),
        "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
            "Absolut. Alle biometrischen Daten werden streng verschluesselt und die hoechsten Sicherheitsstandards werden fuer Datenuebertragung und -speicherung eingehalten. Das System entschluesselt diese Daten nur bei Bedarf, um die Identitaetsverifizierung abzuschliessen."),
        "g_face_match_key3":
            MessageLookupByLibrary.simpleMessage("Abgleich fehlgeschlagen!"),
        "g_face_match_key30":
            MessageLookupByLibrary.simpleMessage("Verstanden"),
        "g_face_match_key31":
            MessageLookupByLibrary.simpleMessage("Wallet-Adresse auswaehlen"),
        "g_face_match_key32": m5,
        "g_face_match_key33":
            MessageLookupByLibrary.simpleMessage("Verknuepfung aufheben"),
        "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
            "Gesichtsdaten-Verifizierung fehlgeschlagen!"),
        "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
            "Gesichtsdaten-Verknuepfungsaufhebung fehlgeschlagen!"),
        "g_face_match_key4": m6,
        "g_face_match_key5":
            MessageLookupByLibrary.simpleMessage("Adressfehler!"),
        "g_face_match_key6":
            MessageLookupByLibrary.simpleMessage("Gesichtsdaten-Verknuepfung"),
        "g_face_match_key7":
            MessageLookupByLibrary.simpleMessage("Gesichtsabgleich"),
        "g_face_match_key8":
            MessageLookupByLibrary.simpleMessage("Erneut auswaehlen"),
        "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Abgleichen"),
        "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
        "g_home_key2": MessageLookupByLibrary.simpleMessage("Nachrichten"),
        "g_home_key3": MessageLookupByLibrary.simpleMessage("Verifizierung"),
        "g_home_key5": MessageLookupByLibrary.simpleMessage("Mitteilungen"),
        "g_home_key6": MessageLookupByLibrary.simpleMessage("Lernen"),
        "g_home_key9": MessageLookupByLibrary.simpleMessage("Freund einladen"),
        "g_key_1":
            MessageLookupByLibrary.simpleMessage("Entfernen fehlgeschlagen!"),
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
            "Wallet erstellen/importieren"),
        "g_key_126": MessageLookupByLibrary.simpleMessage("Design"),
        "g_key_127": MessageLookupByLibrary.simpleMessage("System"),
        "g_key_128": MessageLookupByLibrary.simpleMessage("Hell"),
        "g_key_129": MessageLookupByLibrary.simpleMessage("Dunkel"),
        "g_key_13": MessageLookupByLibrary.simpleMessage("Wallet-Liste"),
        "g_key_132": MessageLookupByLibrary.simpleMessage("Keine Daten"),
        "g_key_134": MessageLookupByLibrary.simpleMessage("Betrag ungueltig"),
        "g_key_135": m7,
        "g_key_14": MessageLookupByLibrary.simpleMessage("Haupt-Wallet"),
        "g_key_140":
            MessageLookupByLibrary.simpleMessage("Transaktion erfolgreich"),
        "g_key_146": MessageLookupByLibrary.simpleMessage("Falsches Passwort"),
        "g_key_147": MessageLookupByLibrary.simpleMessage("Testnetz"),
        "g_key_148": MessageLookupByLibrary.simpleMessage("Hauptnetz"),
        "g_key_149": MessageLookupByLibrary.simpleMessage("Systemsprache"),
        "g_key_15":
            MessageLookupByLibrary.simpleMessage("Als Haupt-Wallet festlegen"),
        "g_key_154": MessageLookupByLibrary.simpleMessage("Absenden"),
        "g_key_155": MessageLookupByLibrary.simpleMessage("Wallet-Adresse"),
        "g_key_156": MessageLookupByLibrary.simpleMessage(
            "Scannen, um Adresse zu kopieren"),
        "g_key_159": MessageLookupByLibrary.simpleMessage("Hinzufuegen"),
        "g_key_16": MessageLookupByLibrary.simpleMessage(
            "Verifizierungs-Wallet auswaehlen"),
        "g_key_163": MessageLookupByLibrary.simpleMessage("Symbol"),
        "g_key_166": MessageLookupByLibrary.simpleMessage("Einfuegen"),
        "g_key_17":
            MessageLookupByLibrary.simpleMessage("Blockchain auswaehlen"),
        "g_key_175":
            MessageLookupByLibrary.simpleMessage("Transaktion fehlgeschlagen"),
        "g_key_179": MessageLookupByLibrary.simpleMessage(
            "Dies ist meine Wallet-Adresse"),
        "g_key_181": MessageLookupByLibrary.simpleMessage("Sonstiges"),
        "g_key_185":
            MessageLookupByLibrary.simpleMessage("Erfolgreich gespeichert"),
        "g_key_191": MessageLookupByLibrary.simpleMessage("Erfolgreich"),
        "g_key_192": MessageLookupByLibrary.simpleMessage(
            "Sind Sie sicher, dass Sie das Wallet loeschen moechten?"),
        "g_key_193": MessageLookupByLibrary.simpleMessage("Aktiv"),
        "g_key_195": MessageLookupByLibrary.simpleMessage(
            "Keine Berechtigung fuer Kamerazugriff."),
        "g_key_196": MessageLookupByLibrary.simpleMessage("Explorer"),
        "g_key_197": MessageLookupByLibrary.simpleMessage("Max"),
        "g_key_198": MessageLookupByLibrary.simpleMessage("Vermoegen"),
        "g_key_2": MessageLookupByLibrary.simpleMessage("Das Ledger ist leer!"),
        "g_key_202":
            MessageLookupByLibrary.simpleMessage("Transaktionsuebersicht"),
        "g_key_203": MessageLookupByLibrary.simpleMessage(
            "Verbindungsfehler, QR-Code erneut scannen."),
        "g_key_205": MessageLookupByLibrary.simpleMessage(
            "Keine Berechtigung fuer Zugriff auf Fotoalbum."),
        "g_key_206":
            MessageLookupByLibrary.simpleMessage("Passwort bearbeiten"),
        "g_key_207": MessageLookupByLibrary.simpleMessage("Altes Passwort"),
        "g_key_208": MessageLookupByLibrary.simpleMessage(
            "Guthaben werden synchronisiert..."),
        "g_key_209":
            MessageLookupByLibrary.simpleMessage("Privater Schluessel"),
        "g_key_21":
            MessageLookupByLibrary.simpleMessage("Wallet-Passwort eingeben"),
        "g_key_210": MessageLookupByLibrary.simpleMessage(
            "Fehler beim privaten Schluessel"),
        "g_key_211": MessageLookupByLibrary.simpleMessage("Kaufen"),
        "g_key_212": MessageLookupByLibrary.simpleMessage("Verkaufen"),
        "g_key_213": MessageLookupByLibrary.simpleMessage("Marktinformationen"),
        "g_key_214": m8,
        "g_key_25": MessageLookupByLibrary.simpleMessage(
            "Passwort stimmt nicht ueberein."),
        "g_key_29": MessageLookupByLibrary.simpleMessage("Guthaben"),
        "g_key_3":
            MessageLookupByLibrary.simpleMessage("Hinzufuegen fehlgeschlagen!"),
        "g_key_33": MessageLookupByLibrary.simpleMessage("Empfangen"),
        "g_key_37": MessageLookupByLibrary.simpleMessage("Uebertragen"),
        "g_key_38": MessageLookupByLibrary.simpleMessage("An"),
        "g_key_4": MessageLookupByLibrary.simpleMessage("QR-Code scannen"),
        "g_key_41":
            MessageLookupByLibrary.simpleMessage("Wallet-Adresse eingeben"),
        "g_key_43":
            MessageLookupByLibrary.simpleMessage("Verfuegbares Guthaben"),
        "g_key_44": MessageLookupByLibrary.simpleMessage("Betrag"),
        "g_key_46": m9,
        "g_key_47": MessageLookupByLibrary.simpleMessage(
            "Nicht genuegend Guthaben fuer diese Transaktion."),
        "g_key_48": MessageLookupByLibrary.simpleMessage("Senden"),
        "g_key_5":
            MessageLookupByLibrary.simpleMessage("Laden fehlgeschlagen!"),
        "g_key_6": MessageLookupByLibrary.simpleMessage("Wallet"),
        "g_key_7": MessageLookupByLibrary.simpleMessage("Erstellen"),
        "g_key_75": MessageLookupByLibrary.simpleMessage("Von"),
        "g_key_78": MessageLookupByLibrary.simpleMessage("Bestaetigen"),
        "g_key_79": MessageLookupByLibrary.simpleMessage("Abbrechen"),
        "g_key_8": MessageLookupByLibrary.simpleMessage("Notiz"),
        "g_key_85": MessageLookupByLibrary.simpleMessage("Seed-Phrase"),
        "g_key_9": MessageLookupByLibrary.simpleMessage("Alle Token"),
        "g_key_94": MessageLookupByLibrary.simpleMessage("Einstellungen"),
        "g_key_address": MessageLookupByLibrary.simpleMessage("Adresse"),
        "g_key_address_1":
            MessageLookupByLibrary.simpleMessage("Bitte Namen eingeben"),
        "g_key_address_2":
            MessageLookupByLibrary.simpleMessage("Bitte Adresse eingeben"),
        "g_key_address_3": MessageLookupByLibrary.simpleMessage(
            "Bitte waehlen Sie einen Coin-Typ"),
        "g_key_address_4":
            MessageLookupByLibrary.simpleMessage("Adresse bearbeiten"),
        "g_key_address_5":
            MessageLookupByLibrary.simpleMessage("Erfolgreich geloescht"),
        "g_key_address_6":
            MessageLookupByLibrary.simpleMessage("Coins auswaehlen"),
        "g_key_address_7": MessageLookupByLibrary.simpleMessage("Coins suchen"),
        "g_key_error_1": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Parsen der Antwortdaten!"),
        "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio-Fehler"),
        "g_key_error_11":
            MessageLookupByLibrary.simpleMessage("Syntaxfehler bei Anfrage"),
        "g_key_error_12": MessageLookupByLibrary.simpleMessage(
            "Nicht autorisiert, bitte anmelden"),
        "g_key_error_13":
            MessageLookupByLibrary.simpleMessage("Zugriff verweigert"),
        "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
            "Falsches Konto oder Passwort"),
        "g_key_error_14": MessageLookupByLibrary.simpleMessage("Anfragefehler"),
        "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
            "Sie sind bereits auf einem anderen Geraet angemeldet und wurden abgemeldet."),
        "g_key_error_15":
            MessageLookupByLibrary.simpleMessage("Anfrage abgelaufen"),
        "g_key_error_16": MessageLookupByLibrary.simpleMessage("Serverfehler"),
        "g_key_error_17":
            MessageLookupByLibrary.simpleMessage("Dienst nicht implementiert"),
        "g_key_error_18":
            MessageLookupByLibrary.simpleMessage("Gateway-Fehler"),
        "g_key_error_19":
            MessageLookupByLibrary.simpleMessage("Dienst nicht verfuegbar"),
        "g_key_error_20":
            MessageLookupByLibrary.simpleMessage("Gateway-Timeout"),
        "g_key_error_21": MessageLookupByLibrary.simpleMessage(
            "HTTP-Version wird nicht unterstuetzt"),
        "g_key_error_22": MessageLookupByLibrary.simpleMessage(
            "Anfrage fehlgeschlagen, Fehlercode:"),
        "g_key_error_23": MessageLookupByLibrary.simpleMessage(
            "System ist ausgelastet, bitte spaeter erneut versuchen"),
        "g_key_error_24":
            MessageLookupByLibrary.simpleMessage("Anfragefrequenz ist zu hoch"),
        "g_key_error_25":
            MessageLookupByLibrary.simpleMessage("Dekodierung fehlgeschlagen"),
        "g_key_error_26": MessageLookupByLibrary.simpleMessage(
            "Die Transaktion befindet sich bereits auf der Blockchain"),
        "g_key_error_27": MessageLookupByLibrary.simpleMessage(
            "Zertifikatskonfigurationsfehler!"),
        "g_key_error_28": MessageLookupByLibrary.simpleMessage(
            "Statuscode-Konfigurationsfehler!"),
        "g_key_error_3":
            MessageLookupByLibrary.simpleMessage("Unbekannter Fehler!"),
        "g_key_error_4": MessageLookupByLibrary.simpleMessage(
            "Netzwerkverbindung abgelaufen, bitte Netzwerkeinstellungen ueberpruefen!"),
        "g_key_error_5": MessageLookupByLibrary.simpleMessage(
            "Server ist nicht erreichbar. Bitte spaeter erneut versuchen!"),
        "g_key_error_8": MessageLookupByLibrary.simpleMessage(
            "Anfrage wurde abgebrochen, bitte erneut anfordern!"),
        "g_key_ex_keystore":
            MessageLookupByLibrary.simpleMessage("Keystore exportieren"),
        "g_key_ex_keystore_1":
            MessageLookupByLibrary.simpleMessage("Backup-Tipps"),
        "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
            "Verwenden Sie ein Passwort-Management-Tool zum Speichern."),
        "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Kopiert"),
        "g_key_ex_keystore_12":
            MessageLookupByLibrary.simpleMessage("Kopieren abgebrochen"),
        "g_key_ex_keystore_13":
            MessageLookupByLibrary.simpleMessage("Identitaets-Wallet"),
        "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
            "Verschluesselte private Schluesseldatei."),
        "g_key_ex_keystore_16":
            MessageLookupByLibrary.simpleMessage("Importmethode"),
        "g_key_ex_keystore_17":
            MessageLookupByLibrary.simpleMessage("Keystore-Datei"),
        "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie die Keystore-Informationen ein."),
        "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
            "Privaten Schluessel exportieren"),
        "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
            "Wer den Keystore und das Passwort hat, hat volle Kontrolle ueber die Wallet-Vermoegen."),
        "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
            "Sorgfaeltig notieren und an einem sicheren Ort aufbewahren. Mehrere physische Kopien sind die sicherste Aufbewahrungsmethode."),
        "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
            "Wenn Ihr privater Schluessel verloren geht, kann er nicht wiederhergestellt werden. Erstellen Sie ein physisches Backup und bewahren Sie es sicher auf."),
        "g_key_ex_keystore_5":
            MessageLookupByLibrary.simpleMessage("Offline speichern"),
        "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
            "Speichern Sie nicht in E-Mail, Notizblock, Cloud-Speicher oder unsicherer Chat-Software."),
        "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
            "Bitte Netzwerkuebertragung verwenden"),
        "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
            "Bitte uebertragen Sie es unbedingt ueber Netzwerktools. Sobald Hacker es erhalten, fuehrt dies zu unwiederbringlichen finanziellen Verlusten"),
        "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
            "Verwenden Sie Tools zum Speichern"),
        "g_key_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
        "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
            "Bitte Feedback-Informationen ausfuellen"),
        "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
            "Es gibt nicht hochgeladene Anhaenge"),
        "g_key_feedback_3":
            MessageLookupByLibrary.simpleMessage("Einreichung fehlgeschlagen"),
        "g_key_feedback_4":
            MessageLookupByLibrary.simpleMessage("Erfolgreich eingereicht"),
        "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Anhaenge"),
        "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
            "Bis zu 5 Anhaenge hochladen, jeder Anhang darf nicht groesser als 100 MB sein"),
        "g_key_feedback_7":
            MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
        "g_key_feedback_8":
            MessageLookupByLibrary.simpleMessage("Zum Wiederholen klicken"),
        "g_key_feedback_9":
            MessageLookupByLibrary.simpleMessage("Bitte anmelden"),
        "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
            "Ein Waehrungs-Wallet fuer diesen Typ existiert bereits."),
        "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
            "Keystore konnte nicht gelesen werden"),
        "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
        "g_key_login": MessageLookupByLibrary.simpleMessage("Anmelden"),
        "g_key_logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
        "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
            "Sind Sie sicher, dass Sie die App beenden moechten?"),
        "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
        "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
        "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
        "g_key_m_15": MessageLookupByLibrary.simpleMessage("Browser"),
        "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
        "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
        "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
        "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
        "g_key_m_2":
            MessageLookupByLibrary.simpleMessage("Marktkapitalisierung"),
        "g_key_m_3": MessageLookupByLibrary.simpleMessage("Handelsvolumen"),
        "g_key_m_4": MessageLookupByLibrary.simpleMessage("Gesamtangebot"),
        "g_key_m_5": MessageLookupByLibrary.simpleMessage("Im Umlauf"),
        "g_key_m_6": MessageLookupByLibrary.simpleMessage("Ueber"),
        "g_key_m_7": MessageLookupByLibrary.simpleMessage("Mehr"),
        "g_key_m_8": MessageLookupByLibrary.simpleMessage("Links"),
        "g_key_m_9": MessageLookupByLibrary.simpleMessage("Website"),
        "g_key_mnemonic":
            MessageLookupByLibrary.simpleMessage("Bitte Seed-Phrase eingeben"),
        "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Gesamt"),
        "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Kamera"),
        "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Foto auswaehlen"),
        "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Inhalt"),
        "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Name"),
        "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Zurueck"),
        "g_key_nft_41":
            MessageLookupByLibrary.simpleMessage("Transaktion eingereicht"),
        "g_key_nft_47":
            MessageLookupByLibrary.simpleMessage("Video auswaehlen"),
        "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
            "Aus Telefongalerie auswaehlen"),
        "g_key_share_code":
            MessageLookupByLibrary.simpleMessage("QR-Code teilen"),
        "g_key_share_link": MessageLookupByLibrary.simpleMessage("Link teilen"),
        "g_key_share_method":
            MessageLookupByLibrary.simpleMessage("Teilen-Methode"),
        "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
        "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
            "Die Datei ist zu gross zum Hochladen"),
        "g_key_squad_k15": m10,
        "g_key_squad_k18":
            MessageLookupByLibrary.simpleMessage("Kontakt hinzufuegen"),
        "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Kontakt"),
        "g_key_squad_k25":
            MessageLookupByLibrary.simpleMessage("Nach E-Mail suchen"),
        "g_key_t_1": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
        "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas-Preis"),
        "g_key_t_16":
            MessageLookupByLibrary.simpleMessage("Maximale Gasgebuehr"),
        "g_key_t_17":
            MessageLookupByLibrary.simpleMessage("Maximale Gebuehr pro Gas"),
        "g_key_t_2": MessageLookupByLibrary.simpleMessage("Ausstehend"),
        "g_key_t_29": m11,
        "g_key_t_3": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
        "g_key_t_30": MessageLookupByLibrary.simpleMessage("Miner-Gebuehr"),
        "g_key_t_31": MessageLookupByLibrary.simpleMessage("Fortfahren"),
        "g_key_t_32": MessageLookupByLibrary.simpleMessage("Wallet-Passwort"),
        "g_key_t_33": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort darf nicht leer sein"),
        "g_key_t_34":
            MessageLookupByLibrary.simpleMessage("Falsches Wallet-Passwort"),
        "g_key_t_35": MessageLookupByLibrary.simpleMessage(
            "Bitte Wallet-Passwort eingeben"),
        "g_key_t_36": MessageLookupByLibrary.simpleMessage("Gasgebuehr-Rate"),
        "g_key_t_37": MessageLookupByLibrary.simpleMessage(
            "Durchschnittliche Gasgebuehr-Rate des letzten Blocks"),
        "g_key_t_4": MessageLookupByLibrary.simpleMessage("Ausgehend"),
        "g_key_t_43": MessageLookupByLibrary.simpleMessage(
            "Geben Sie eine ganze Zahl groesser als 0 ein."),
        "g_key_t_44": MessageLookupByLibrary.simpleMessage(
            "Daten konnten nicht abgerufen werden"),
        "g_key_t_45": m12,
        "g_key_t_46": MessageLookupByLibrary.simpleMessage(
            "Empfaengeradresse ueberpruefen"),
        "g_key_t_47": MessageLookupByLibrary.simpleMessage("Suchen"),
        "g_key_t_49": MessageLookupByLibrary.simpleMessage("Kein Konto"),
        "g_key_t_5": MessageLookupByLibrary.simpleMessage("Eingehend"),
        "g_key_t_50":
            MessageLookupByLibrary.simpleMessage("Ungueltige Adresse"),
        "g_key_t_51": MessageLookupByLibrary.simpleMessage(
            "Kontoverifizierung erfolgreich"),
        "g_key_t_52": m13,
        "g_key_t_54": MessageLookupByLibrary.simpleMessage(
            "Die Empfaengeradresse hat kein Konto, und die erste Ueberweisung muss mindestens 10 XRP betragen"),
        "g_key_t_6": MessageLookupByLibrary.simpleMessage("Verbrauchtes Gas"),
        "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
        "g_key_tran_1":
            MessageLookupByLibrary.simpleMessage("Transaktionshistorie"),
        "g_key_tran_4":
            MessageLookupByLibrary.simpleMessage("Transaktionsdetails"),
        "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
            "Bitte Transaktionsbelege im Verlauf ansehen"),
        "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Ausgabebetrag"),
        "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Empfangsbetrag"),
        "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT-Typen"),
        "g_key_u_11": MessageLookupByLibrary.simpleMessage("Follower"),
        "g_key_u_12": MessageLookupByLibrary.simpleMessage("Benutzertypen"),
        "g_key_u_13": MessageLookupByLibrary.simpleMessage("Website"),
        "g_key_u_14": MessageLookupByLibrary.simpleMessage("Produktlink"),
        "g_key_u_15": MessageLookupByLibrary.simpleMessage("Medienplattformen"),
        "g_key_u_16": MessageLookupByLibrary.simpleMessage("Wallet-Adresse"),
        "g_key_u_2": MessageLookupByLibrary.simpleMessage("Spitzname"),
        "g_key_u_23": MessageLookupByLibrary.simpleMessage(
            "Avatar-Upload fehlgeschlagen"),
        "g_key_u_3": MessageLookupByLibrary.simpleMessage("Beschreibung"),
        "g_key_u_5":
            MessageLookupByLibrary.simpleMessage("Kuenstlerinformationen"),
        "g_key_u_6":
            MessageLookupByLibrary.simpleMessage("Sie sind kein Kuenstler"),
        "g_key_u_7": MessageLookupByLibrary.simpleMessage(
            "Hier klicken, um sich als Kuenstler zu bewerben"),
        "g_key_u_8": MessageLookupByLibrary.simpleMessage("Name"),
        "g_key_u_9": MessageLookupByLibrary.simpleMessage("Einnahmen"),
        "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
            "Ich habe gelesen und akzeptiere die "),
        "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
            "Allgemeine Geschaeftsbedingungen"),
        "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
            "Datenschutzrichtlinie und Erklaerung zur Erhebung personenbezogener Daten"),
        "g_key_v_k1":
            MessageLookupByLibrary.simpleMessage("Neueste Version gefunden"),
        "g_key_v_k2":
            MessageLookupByLibrary.simpleMessage("Sofort aktualisieren"),
        "g_key_v_k3":
            MessageLookupByLibrary.simpleMessage("Neue Version gefunden"),
        "g_key_v_k4":
            MessageLookupByLibrary.simpleMessage("Bereits die neueste Version"),
        "g_key_wallet_c10":
            MessageLookupByLibrary.simpleMessage("Seed-Phrase anzeigen"),
        "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
            "Bitte notieren Sie Ihre Seed-Phrase und bewahren Sie sie sicher auf."),
        "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
            "Versuchen Sie jetzt, Ihre Seed-Phrase erneut einzugeben."),
        "g_key_wallet_c13":
            MessageLookupByLibrary.simpleMessage("Konto importieren"),
        "g_key_wallet_c14":
            MessageLookupByLibrary.simpleMessage("Konto erstellen"),
        "g_key_wallet_c15":
            MessageLookupByLibrary.simpleMessage("Sie sind fertig!"),
        "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
            "Sie koennen jetzt Ihr Wallet vollstaendig nutzen."),
        "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Loslegen"),
        "g_key_wallet_c18":
            MessageLookupByLibrary.simpleMessage("Vorerst ueberspringen"),
        "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
            "Sie koennen das Backup der Seed-Phrase vorerst ueberspringen und es bei Bedarf jederzeit in den Einstellungen erneut durchfuehren."),
        "g_key_wallet_c21":
            MessageLookupByLibrary.simpleMessage("Direkt erstellen"),
        "g_key_wallet_c22":
            MessageLookupByLibrary.simpleMessage("Erfolgreich erstellt"),
        "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
            "Wenn Sie Ihre Wallet-Details einsehen oder den Keystore exportieren moechten, gehen Sie zu Seitenleiste > Wallet verwalten "),
        "g_key_wallet_c24":
            MessageLookupByLibrary.simpleMessage("Meinen Keystore exportieren"),
        "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
            "Sichern Sie Ihr Wallet durch ein Backup"),
        "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
            "Ein Keystore ist ein Repository fuer Sicherheitszertifikate und zugehoerige private Schluessel."),
        "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
            "Schritt 1: Gehen Sie zu Wallet verwalten."),
        "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
            "Schritt 2: Waehlen Sie die Wallet-Adresse aus."),
        "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
            "Schritt 3: Druecken Sie Keystore exportieren."),
        "g_key_wallet_c30":
            MessageLookupByLibrary.simpleMessage("Zu Wallet verwalten gehen"),
        "g_key_wallet_c31":
            MessageLookupByLibrary.simpleMessage("Zurueck zur Startseite"),
        "g_key_wallet_c32":
            MessageLookupByLibrary.simpleMessage("Wallet hinzufuegen"),
        "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
            "Ein Wallet mit einer Seed-Phrase erstellen."),
        "g_key_wallet_c34":
            MessageLookupByLibrary.simpleMessage("Wallet-Namen eingeben"),
        "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
            "Sie haben Ihre Wallet-Seed-Phrase nicht gesichert!"),
        "g_key_wallet_c36":
            MessageLookupByLibrary.simpleMessage("Jetzt sichern"),
        "g_key_wallet_c37":
            MessageLookupByLibrary.simpleMessage("Wallet-Passwort festlegen"),
        "g_key_wallet_c38":
            MessageLookupByLibrary.simpleMessage("Wallet sichern"),
        "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
            "Bitte notieren Sie die folgende Seed-Phrase"),
        "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Starten"),
        "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
            "Mit dem Internet verbundene Geraete koennen Ihre Informationen preisgeben. Wir empfehlen, die Seed-Phrase aufzuschreiben und sicher aufzubewahren."),
        "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
            "Warnung: Geben Sie Ihre Seed-Phrase niemals an andere weiter. N42Wallet wird Sie niemals nach diesen Informationen fragen. Seien Sie aeusserst vorsichtig und bewahren Sie sie offline sicher auf. Wenn Ihre Seed-Phrase offengelegt wird, koennten Sie alle Ihre Vermoegen verlieren und sie nicht wiederherstellen koennen."),
        "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
            "Warnung: Die Seed-Phrase ist die einzige Moeglichkeit, Ihre Wallet-Vermoegen wiederherzustellen."),
        "g_key_wallet_c43":
            MessageLookupByLibrary.simpleMessage("Naechster Schritt"),
        "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
            "Klicken, um Seed-Phrase anzuzeigen"),
        "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
            "Bitte stellen Sie sicher, dass sich keine anderen Personen oder Kameras in der Naehe befinden"),
        "g_key_wallet_c46":
            MessageLookupByLibrary.simpleMessage("Seed-Phrase bestaetigen"),
        "g_key_wallet_c47":
            MessageLookupByLibrary.simpleMessage("Wallet-Informationen"),
        "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Wallet-Name"),
        "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
            "Bitte sichern Sie zuerst Ihre Wallet-Seed-Phrase!"),
        "g_key_wallet_c6":
            MessageLookupByLibrary.simpleMessage("Seed-Phrase ueberpruefen"),
        "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
            "Geben Sie jetzt Ihre Seed-Phrase ein."),
        "g_key_wallet_c8":
            MessageLookupByLibrary.simpleMessage("Phrase festlegen"),
        "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
            "Bitte notieren Sie Ihre Seed-Phrase und bewahren Sie sie sicher auf. Sie benoetigen sie, um Ihr Kryptowaehrungs-Wallet zu importieren oder wiederherzustellen."),
        "g_key_wallet_edit":
            MessageLookupByLibrary.simpleMessage("Wallet bearbeiten"),
        "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Zeit"),
        "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Ergebnis"),
        "g_key_wallet_k37":
            MessageLookupByLibrary.simpleMessage("Transaktions-Hash"),
        "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Hinzufuegen"),
        "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Pfad"),
        "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Block"),
        "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Wert"),
        "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
        "g_key_wallet_k57":
            MessageLookupByLibrary.simpleMessage("Beschleunigen"),
        "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Hinweis"),
        "g_key_wallet_m1": m14,
        "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
            "Sind Sie sicher, dass Sie Ihr Konto kuendigen moechten?"),
        "g_key_wallet_m13":
            MessageLookupByLibrary.simpleMessage("Abmeldung bestaetigen"),
        "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
            "Bitte Google-Verifizierungscode eingeben."),
        "g_key_wallet_m19": m15,
        "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
            "Der aktuelle Token wurde nicht hinzugefuegt."),
        "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
            "Geben Sie Ihre Seed-Phrase mit durch Leerzeichen getrennten Woertern ein"),
        "g_key_wallet_m22":
            MessageLookupByLibrary.simpleMessage("Wallet importieren"),
        "g_key_wallet_m3": m16,
        "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
            "Das aktuelle Token-Guthaben ist unzureichend."),
        "g_key_wallet_m5": m17,
        "g_key_wallet_m6":
            MessageLookupByLibrary.simpleMessage("Signaturfehler"),
        "g_key_wallet_m8":
            MessageLookupByLibrary.simpleMessage("Kontokuendigung"),
        "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
            "E-Mail-Verifizierungscode eingeben."),
        "g_key_wallet_manage":
            MessageLookupByLibrary.simpleMessage("Wallet verwalten"),
        "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reserviert"),
        "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Basisreserve"),
        "g_key_xml_11": m18,
        "g_key_xml_2":
            MessageLookupByLibrary.simpleMessage("Inkrementelle Reserve"),
        "g_key_xml_22": m19,
        "g_key_xml_3":
            MessageLookupByLibrary.simpleMessage("Anzahl der Besitzobjekte"),
        "g_key_xml_33": m20,
        "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
            "Wie man den Gesamtreservebetrag berechnet"),
        "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
            "Gesamtreserve = Basisreserve + (Anzahl der Besitzobjekte x Inkrementelle Reserve)"),
        "g_lock_key1":
            MessageLookupByLibrary.simpleMessage("Touch ID und Face ID"),
        "g_lock_key10":
            MessageLookupByLibrary.simpleMessage("Aktuelles Passwort"),
        "g_lock_key11": MessageLookupByLibrary.simpleMessage("Neues Passwort"),
        "g_lock_key12":
            MessageLookupByLibrary.simpleMessage("Neues Passwort bestaetigen"),
        "g_lock_key13": MessageLookupByLibrary.simpleMessage("6-stellige Zahl"),
        "g_lock_key15":
            MessageLookupByLibrary.simpleMessage("Passwoerter und Biometrie"),
        "g_lock_key16": MessageLookupByLibrary.simpleMessage("Muster-Passwort"),
        "g_lock_key17":
            MessageLookupByLibrary.simpleMessage("Muster-Passwort festlegen"),
        "g_lock_key18": MessageLookupByLibrary.simpleMessage(
            "Fuer Ihre Kontosicherheit legen Sie bitte ein Gruppenpasswort fest"),
        "g_lock_key19": MessageLookupByLibrary.simpleMessage(
            "Muster-Passwort erneut zeichnen"),
        "g_lock_key20":
            MessageLookupByLibrary.simpleMessage("Muster-Passwort zeichnen"),
        "g_lock_key21": m21,
        "g_lock_key22": MessageLookupByLibrary.simpleMessage(
            "Muster-Passwort zuruecksetzen"),
        "g_lock_key23": MessageLookupByLibrary.simpleMessage(
            "Zu viele falsche Eingaben, bitte setzen Sie das Passwort zurueck"),
        "g_lock_key24": MessageLookupByLibrary.simpleMessage(
            "Wallet-Passwort hinzufuegen?"),
        "g_lock_key25": m22,
        "g_lock_key3":
            MessageLookupByLibrary.simpleMessage("Sperrbildschirmseite"),
        "g_lock_key4":
            MessageLookupByLibrary.simpleMessage("Automatische Sperre"),
        "g_lock_key5": MessageLookupByLibrary.simpleMessage("Erfolgreich"),
        "g_lock_key6": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
        "g_lock_key7": MessageLookupByLibrary.simpleMessage(
            "Biometrische Erkennung ist nicht aktiviert"),
        "g_lock_key8": MessageLookupByLibrary.simpleMessage(
            "Biometrische Verifizierung hinzufuegen?"),
        "g_lock_key9":
            MessageLookupByLibrary.simpleMessage("Passwort zuruecksetzen"),
        "g_mining_key20": MessageLookupByLibrary.simpleMessage("N entsperren?"),
        "g_mining_key31": MessageLookupByLibrary.simpleMessage(
            "Cloud-Verifizierungsaktivitaet"),
        "g_mining_key46": MessageLookupByLibrary.simpleMessage(
            "Einrichtung erfordert eine kleine Menge fuer Gas."),
        "g_mining_key60": MessageLookupByLibrary.simpleMessage(
            "Sie sind erfolgreich einem Gruppenknoten auf N42Wallet beigetreten. Teilen Sie den Link, um Freunde einzuladen, den Knoten zu aktivieren und die Verifizierung zu starten!"),
        "g_mining_key61":
            MessageLookupByLibrary.simpleMessage("Mit Freunden teilen"),
        "g_mining_key62": MessageLookupByLibrary.simpleMessage("Fortfahren"),
        "g_mining_key63": m23,
        "g_mining_key73": m24,
        "g_mining_key74": MessageLookupByLibrary.simpleMessage(
            "Ich habe gerade einen Knoten auf @N42Wallet eingerichtet und die Verifizierung auf mobilen Geraeten gestartet! Komm und mach mit. Die dezentralisierte Zukunft ist mobil!"),
        "g_mining_key76": m25,
        "g_mining_key86": MessageLookupByLibrary.simpleMessage(
            "Einloesung nach 768s verfuegbar."),
        "g_mining_key87": MessageLookupByLibrary.simpleMessage(
            "Anfragen davor werden nicht bearbeitet."),
        "g_mining_key_10":
            MessageLookupByLibrary.simpleMessage("Heutige Belohnung"),
        "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
            "Bitte behandeln Sie die folgenden Daten als wichtigen Schluessel. Wir empfehlen, sie sofort zu kopieren und an einem vertrauenswuerdigen Ort zu sichern."),
        "g_mining_key_101":
            MessageLookupByLibrary.simpleMessage("Daten kopieren"),
        "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inaktiv"),
        "g_mining_key_103":
            MessageLookupByLibrary.simpleMessage("Validator-Liste"),
        "g_mining_key_104":
            MessageLookupByLibrary.simpleMessage("Import erfolgreich"),
        "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
            "Verschluesselte Daten duerfen nicht leer sein!"),
        "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
            "Passwort darf nicht leer sein!"),
        "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
            "Entschluesselung fehlgeschlagen. Bitte ueberpruefen Sie, ob das Passwort korrekt ist!"),
        "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
            "Nicht unterstuetztes verschluesseltes Datenformat!"),
        "g_mining_key_109": m26,
        "g_mining_key_11":
            MessageLookupByLibrary.simpleMessage("Gestrige Belohnungen"),
        "g_mining_key_110":
            MessageLookupByLibrary.simpleMessage("Verschluesselte Daten"),
        "g_mining_key_111":
            MessageLookupByLibrary.simpleMessage("Dateien importieren"),
        "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
            "Bitte verschluesselte Daten eingeben."),
        "g_mining_key_113":
            MessageLookupByLibrary.simpleMessage("Importiere..."),
        "g_mining_key_114":
            MessageLookupByLibrary.simpleMessage("Bestaetigung"),
        "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
            "Die Einloesung dauert einige Zeit, bitte warten Sie einen Moment!"),
        "g_mining_key_116": m27,
        "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
            "Belohnung sammelt sich taeglich an und wird erst an Ihr N-Wallet gesendet, wenn sie ~0,5 N erreicht."),
        "g_mining_key_13":
            MessageLookupByLibrary.simpleMessage("Gesamtbelohnungen"),
        "g_mining_key_14":
            MessageLookupByLibrary.simpleMessage("Geminter Wert"),
        "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
            "Berechnet basierend auf dem Marktpreis von N * die gesamten N-Belohnungen."),
        "g_mining_key_23":
            MessageLookupByLibrary.simpleMessage("Anzahl der Gewinne"),
        "g_mining_key_31":
            MessageLookupByLibrary.simpleMessage("Plaene auswaehlen"),
        "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
            "Entsperrungszeitraum: Jederzeit entsperrbar"),
        "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
            "Maximale jaehrliche Belohnung"),
        "g_mining_key_34":
            MessageLookupByLibrary.simpleMessage("Belohnungsverteilung"),
        "g_mining_key_35":
            MessageLookupByLibrary.simpleMessage("Taegliches Limit"),
        "g_mining_key_36":
            MessageLookupByLibrary.simpleMessage("Geschwindigkeit"),
        "g_mining_key_37":
            MessageLookupByLibrary.simpleMessage("Verifizierungsplaene"),
        "g_mining_key_38":
            MessageLookupByLibrary.simpleMessage("Zahlungsmethode auswaehlen"),
        "g_mining_key_39":
            MessageLookupByLibrary.simpleMessage("Zahlungsmethoden"),
        "g_mining_key_40":
            MessageLookupByLibrary.simpleMessage("Mit N bezahlen"),
        "g_mining_key_42":
            MessageLookupByLibrary.simpleMessage("Wallet-Guthaben"),
        "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
            "Sie haben nicht genuegend N fuer diese Transaktion"),
        "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Deaktiviert"),
        "g_mining_key_49":
            MessageLookupByLibrary.simpleMessage("Mehr anzeigen"),
        "g_mining_key_5":
            MessageLookupByLibrary.simpleMessage("Verifizierungsstatus"),
        "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
            "Sperren Sie N, um Verifizierungsbelohnungen zu starten."),
        "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Einstieg"),
        "g_mining_key_66":
            MessageLookupByLibrary.simpleMessage("Erweiterter Knoten"),
        "g_mining_key_67":
            MessageLookupByLibrary.simpleMessage("Einstiegs-Knoten"),
        "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro-Knoten"),
        "g_mining_key_69":
            MessageLookupByLibrary.simpleMessage("500 Bloecke/Tag ~ 70 Min."),
        "g_mining_key_7":
            MessageLookupByLibrary.simpleMessage("Plan auswaehlen"),
        "g_mining_key_70":
            MessageLookupByLibrary.simpleMessage("100 Bloecke/Tag ~ 15 Min."),
        "g_mining_key_71": m28,
        "g_mining_key_72":
            MessageLookupByLibrary.simpleMessage("128 Sekunden pro Pruefung"),
        "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
            "Cloud-Verifizierung gestartet"),
        "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
            "Die Testkette wird aktualisiert und Bloecke koennen voruebergehend nicht verifiziert werden."),
        "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
            "Werden Aufgaben an vier aufeinanderfolgenden Tagen nicht erledigt, gibt es keine Einnahmen und es besteht ein Strafrisiko."),
        "g_mining_key_76":
            MessageLookupByLibrary.simpleMessage("Risikobewertung"),
        "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Einloesen"),
        "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
            "Bitte speichern Sie zuerst das oeffentliche und private Schluesselpaar des Validators."),
        "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Exportieren"),
        "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
            "Unzureichende Mittel fuer die Uebertragung."),
        "g_mining_key_81":
            MessageLookupByLibrary.simpleMessage("Validator-Liste"),
        "g_mining_key_82":
            MessageLookupByLibrary.simpleMessage("Validator importieren"),
        "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
            "Der Validator existiert bereits"),
        "g_mining_key_84":
            MessageLookupByLibrary.simpleMessage("Niedriges Risiko"),
        "g_mining_key_85":
            MessageLookupByLibrary.simpleMessage("Maessig Risiko"),
        "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
            "Belohnungen der letzten 7 Tage"),
        "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Hohes Risiko"),
        "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
            "Der Vertrag wird geladen und kann derzeit nicht verifiziert werden. Bitte warten Sie einen Moment!"),
        "g_mining_key_89":
            MessageLookupByLibrary.simpleMessage("Sicherheitstipps"),
        "g_mining_key_9":
            MessageLookupByLibrary.simpleMessage("Hintergrundverifizierung"),
        "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
            "Bitte bewahren Sie Ihren privaten Schluessel oder Ihre Seed-Phrase sicher auf."),
        "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
            "Ihr privater Schluessel oder Ihre Seed-Phrase ist das einzige Zugangsrecht zu Ihren Wallet-Vermoegen."),
        "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
            "Bitte bewahren Sie sie an einem sicheren Ort auf (Papier, Passwort-Manager, etc.)."),
        "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
            "Machen Sie keine Screenshots, laden Sie sie nicht ins Internet hoch und teilen Sie sie mit niemandem."),
        "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
            "Einmal verloren oder kompromittiert, koennen Ihre Wallet-Vermoegen nicht wiederhergestellt werden."),
        "g_mining_key_95":
            MessageLookupByLibrary.simpleMessage("Bestaetigen und speichern"),
        "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
            "Passwort setzen und verschluesseln"),
        "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
            "Bitte Verschluesselungspasswort eingeben"),
        "g_mining_key_98": m29,
        "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
            "Bitte geben Sie Ihr Passwort erneut ein, um es zu bestaetigen"),
        "g_mining_unlock_period":
            MessageLookupByLibrary.simpleMessage("Entsperrungszeitraum:"),
        "g_mining_unlockable_anytime":
            MessageLookupByLibrary.simpleMessage("Jederzeit entsperrbar"),
        "g_notification_key_1":
            MessageLookupByLibrary.simpleMessage("Benachrichtigungen"),
        "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Teilen"),
        "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Empfehlung"),
        "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
            "Freunde werben und N-Token erhalten!"),
        "g_share_v3_key_4":
            MessageLookupByLibrary.simpleMessage("Sie erhalten bis zu "),
        "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
            " N, wenn Ihre Empfehlung die Verifizierung startet!"),
        "g_share_v3_key_6":
            MessageLookupByLibrary.simpleMessage("Werben ueber"),
        "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
        "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("Code"),
        "g_swap_key_14": m30,
        "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
            "Fehler beim Abrufen des Coin-Preises."),
        "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
            "Mit dem Fortfahren stimmen Sie den folgenden "),
        "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
            "Allgemeinen Geschaeftsbedingungen zu."),
        "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Abschliessen"),
        "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
            "Ihr Swap wird in Kuerze verteilt. Bitte haben Sie Geduld."),
        "g_swap_key_20": m31,
        "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
            "Kosten fuer den Betrieb eines Knotens: Gruppenverifizierung 1-49 N Basis-Knoten: 50 N Premium-Knoten: 100 N Pro-Knoten: 500 N."),
        "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
        "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Unbezahlt"),
        "g_swap_key_24":
            MessageLookupByLibrary.simpleMessage("Zahlung wird bestaetigt"),
        "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Zur Verteilung"),
        "g_swap_key_28":
            MessageLookupByLibrary.simpleMessage("Swap-Zusammenfassung"),
        "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Neues Guthaben"),
        "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Sie zahlen"),
        "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Datum"),
        "g_swap_key_31": m32,
        "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
            "Swaps koennen auf den entsprechenden Blockchain-Explorern (Etherscan, BscScan, TRONSCAN und unserem eigenen) eingesehen werden."),
        "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Zu N tauschen"),
        "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Swap"),
        "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Sie erhalten"),
        "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Swap-Vorschau"),
        "g_swap_key_6":
            MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
        "g_token_m_key_1": m33,
        "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
            "Jeder kann Token erstellen, einschliesslich gefaelschter Versionen bestehender Token. Recherchieren Sie immer einen Token, bevor Sie ihn importieren."),
        "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Token"),
        "g_token_m_key_12":
            MessageLookupByLibrary.simpleMessage("Token suchen"),
        "g_token_m_key_13":
            MessageLookupByLibrary.simpleMessage("Blockchain-Name"),
        "g_token_m_key_14":
            MessageLookupByLibrary.simpleMessage("Blockchain-Symbol"),
        "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("Chain-ID"),
        "g_token_m_key_16":
            MessageLookupByLibrary.simpleMessage("Dezimalstellen"),
        "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
        "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
        "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
            "Benutzerdefinierte Blockchain hinzufuegen"),
        "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0-18 uint"),
        "g_token_m_key_20":
            MessageLookupByLibrary.simpleMessage("Token hinzufuegen"),
        "g_token_m_key_21":
            MessageLookupByLibrary.simpleMessage("Formatfehler!"),
        "g_token_m_key_22": m34,
        "g_token_m_key_23": m35,
        "g_token_m_key_24": m36,
        "g_token_m_key_3":
            MessageLookupByLibrary.simpleMessage("Token importieren"),
        "g_token_m_key_4":
            MessageLookupByLibrary.simpleMessage("Alle Netzwerke"),
        "g_token_m_key_5":
            MessageLookupByLibrary.simpleMessage("Benutzerdefinierter Token"),
        "g_token_m_key_6":
            MessageLookupByLibrary.simpleMessage("Token-Adresse"),
        "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Token-Symbol"),
        "g_token_m_key_8":
            MessageLookupByLibrary.simpleMessage("Token-Dezimalstellen"),
        "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importieren"),
        "g_unlock_key10": m37,
        "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
            "Fingerabdruck- oder Gesichtserkennung nicht aktiviert?"),
        "g_unlock_key3":
            MessageLookupByLibrary.simpleMessage("Muster-Passwort zeichnen"),
        "g_unlock_key4": m38,
        "g_unlock_key5":
            MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
        "g_unlock_key6": m39,
        "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
            "Authentifizierung fehlgeschlagen"),
        "g_unlock_key8": m40,
        "g_unlock_key9":
            MessageLookupByLibrary.simpleMessage("Sie koennen auch "),
        "google_verification":
            MessageLookupByLibrary.simpleMessage("Google-Authentifizierung"),
        "google_verification_message10":
            MessageLookupByLibrary.simpleMessage("Verknuepfen"),
        "google_verification_message11": MessageLookupByLibrary.simpleMessage(
            "Google Authenticator herunterladen"),
        "google_verification_message12":
            MessageLookupByLibrary.simpleMessage("Anleitung"),
        "google_verification_message13": MessageLookupByLibrary.simpleMessage(
            "Oeffnen Sie Google Authenticator."),
        "google_verification_message14": MessageLookupByLibrary.simpleMessage(
            "Sie sehen einen 6-stelligen Verifizierungscode auf dem Bildschirm."),
        "google_verification_message15": MessageLookupByLibrary.simpleMessage(
            "Kopieren Sie den 6-stelligen Code und fuegen Sie ihn in N42Wallet ein."),
        "google_verification_message16": MessageLookupByLibrary.simpleMessage(
            "Dann wird Ihr Authenticator erfolgreich verknuepft."),
        "google_verification_message17":
            MessageLookupByLibrary.simpleMessage("Backup-Schluessel"),
        "google_verification_message18": MessageLookupByLibrary.simpleMessage(
            "Kopieren Sie den Schluessel zu Google Authenticator"),
        "google_verification_message19": MessageLookupByLibrary.simpleMessage(
            "Google-Verifizierungscode eingeben"),
        "google_verification_message20": MessageLookupByLibrary.simpleMessage(
            "E-Mail-Verifizierungscode eingeben"),
        "google_verification_message21": m41,
        "google_verification_message3": MessageLookupByLibrary.simpleMessage(
            "Google-Schluessel konnte nicht abgerufen werden"),
        "google_verification_message5": MessageLookupByLibrary.simpleMessage(
            "Zwei-Faktor-Authentifizierung (2FA)"),
        "google_verification_message6": MessageLookupByLibrary.simpleMessage(
            "Um Ihr Konto zu schuetzen, wird empfohlen, mindestens eine 2FA zu aktivieren."),
        "google_verification_message7": MessageLookupByLibrary.simpleMessage(
            "Die Google Authenticator-App schuetzt Ihre Auszahlungen und Ihr N42Wallet-Konto."),
        "google_verification_message8": MessageLookupByLibrary.simpleMessage(
            "Herunterladen und installieren"),
        "google_verification_message9": MessageLookupByLibrary.simpleMessage(
            "Bitte laden Sie Google Authenticator herunter und installieren Sie es. Druecken Sie dann \'Verknuepfen\', um Ihr N42Wallet-Konto zu verknuepfen."),
        "importantNotice":
            MessageLookupByLibrary.simpleMessage("Wichtiger Hinweis"),
        "login_button_text": MessageLookupByLibrary.simpleMessage("Anmelden"),
        "login_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
        "login_forgot_password":
            MessageLookupByLibrary.simpleMessage("Passwort vergessen?"),
        "login_invite_code":
            MessageLookupByLibrary.simpleMessage("Empfehlungscode"),
        "login_invite_code_title":
            MessageLookupByLibrary.simpleMessage("Empfehlungscode"),
        "login_message_1":
            MessageLookupByLibrary.simpleMessage("Noch kein Konto? "),
        "login_message_10":
            MessageLookupByLibrary.simpleMessage("Erfolgreich erstellt"),
        "login_message_11":
            MessageLookupByLibrary.simpleMessage("Erfolgreich zurueckgesetzt"),
        "login_message_2":
            MessageLookupByLibrary.simpleMessage("Bereits ein Konto? "),
        "login_message_6":
            MessageLookupByLibrary.simpleMessage("Code erneut senden in "),
        "login_message_7":
            MessageLookupByLibrary.simpleMessage("Code erfolgreich gesendet"),
        "login_message_8":
            MessageLookupByLibrary.simpleMessage("E-Mail nicht registriert"),
        "login_message_9":
            MessageLookupByLibrary.simpleMessage("Code senden fehlgeschlagen"),
        "login_need_login":
            MessageLookupByLibrary.simpleMessage("Bitte zuerst anmelden"),
        "login_password": MessageLookupByLibrary.simpleMessage("Passwort"),
        "next": MessageLookupByLibrary.simpleMessage("Weiter"),
        "nicknameMessage": m42,
        "password_diff": MessageLookupByLibrary.simpleMessage(
            "Passwoerter stimmen nicht ueberein"),
        "personalInformation":
            MessageLookupByLibrary.simpleMessage("Profil bearbeiten"),
        "photograph": MessageLookupByLibrary.simpleMessage("Fotografieren"),
        "please_enter_code":
            MessageLookupByLibrary.simpleMessage("Verifizierungscode eingeben"),
        "please_enter_email":
            MessageLookupByLibrary.simpleMessage("Bitte E-Mail eingeben"),
        "please_enter_password":
            MessageLookupByLibrary.simpleMessage("Bitte Passwort eingeben"),
        "please_input_address":
            MessageLookupByLibrary.simpleMessage("Bitte Adresse eingeben"),
        "repeatPassword":
            MessageLookupByLibrary.simpleMessage("Passwort wiederholen"),
        "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
            "Waehlen Sie ein Passwort (8-18 Zeichen)"),
        "rest_Confirm_password":
            MessageLookupByLibrary.simpleMessage("Passwort bestaetigen"),
        "rest_Enter_the_password_again":
            MessageLookupByLibrary.simpleMessage("Passwort erneut eingeben"),
        "rest_Please_enter":
            MessageLookupByLibrary.simpleMessage("Code eingeben"),
        "rest_Verification_code":
            MessageLookupByLibrary.simpleMessage("OTP-Code"),
        "rest_your_password": MessageLookupByLibrary.simpleMessage(
            "Setzen Sie Ihr Passwort zurueck"),
        "s_key_1": MessageLookupByLibrary.simpleMessage("Wallet verwalten"),
        "s_key_10": MessageLookupByLibrary.simpleMessage("Ueber die App"),
        "s_key_11": MessageLookupByLibrary.simpleMessage("Sicherheit"),
        "s_key_12":
            MessageLookupByLibrary.simpleMessage("Neuen Chat verwenden"),
        "s_key_13": MessageLookupByLibrary.simpleMessage(
            "Erweitertes Chat-Erlebnis aktivieren"),
        "s_key_2": MessageLookupByLibrary.simpleMessage("Wallet-Adressen"),
        "s_key_3": MessageLookupByLibrary.simpleMessage("Transaktion"),
        "s_key_4": MessageLookupByLibrary.simpleMessage("Sprache"),
        "s_key_5": MessageLookupByLibrary.simpleMessage("Design"),
        "search": MessageLookupByLibrary.simpleMessage("Suchen"),
        "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
            "Bitte lesen Sie die Vereinbarung und bestaetigen Sie"),
        "verification": MessageLookupByLibrary.simpleMessage("Verifizierung"),
        "w_item_1": MessageLookupByLibrary.simpleMessage(
            "Wenn ich meine Seed-Phrase verliere, sind meine Mittel fuer immer verloren."),
        "w_item_2": MessageLookupByLibrary.simpleMessage(
            "Wenn ich meine Seed-Phrase jemandem offenbare oder teile, koennen meine Mittel gestohlen werden."),
        "w_item_3": MessageLookupByLibrary.simpleMessage(
            "Es liegt in meiner Verantwortung, meine Seed-Phrase sicher aufzubewahren."),
        "w_key_12": MessageLookupByLibrary.simpleMessage("Seed-Phrase falsch."),
        "w_key_8": MessageLookupByLibrary.simpleMessage(
            "Geben Sie die Seed-Phrase fuer das Wallet ein, das Sie importieren moechten.")
      };
}
