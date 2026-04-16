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

  static String m1(price) => "Aktueller Preis: \$${price}";

  static String m2(symbol) => "Preisalarm · ${symbol}";

  static String m3(value) => "Ich bin ${value}";

  static String m4(value) => "Chat-Mitglied (${value})";

  static String m5(value) =>
      "Sind Sie sicher, dass Sie ${value} als Freund hinzufuegen moechten";

  static String m6(email) => "Bestätigungscode an ${email} gesendet";

  static String m7(s) => "In ${s}s erneut senden";

  static String m8(value) =>
      "Sie wurden bereits verknuepft und koennen derzeit nicht erneut verknuepft werden. Verknuepfungsadresse: ${value}.";

  static String m9(value) =>
      "Verknuepfung erfolgreich. Verknuepfungsadresse: ${value}";

  static String m10(value) => "Es gibt keine N42chain im ${value}-Wallet!";

  static String m11(value) => "Abgleich erfolgreich. Adresse: ${value}.";

  static String m12(value) => "Betrag groesser als ${value}.";

  static String m13(value) =>
      "Das Wallet existiert bereits, der Wallet-Name ist \"${value}\"";

  static String m14(value) =>
      "Geben Sie einen Betrag groesser als ${value} ein.";

  static String m15(gas) =>
      "Ausführungs-Gas (${gas}) ist hoch. Der aufgerufene Vertrag könnte mehr Gas verbrauchen als erwartet.";

  static String m16(gas) =>
      "Erste Transaktion beinhaltet Konto-Bereitstellung (~${gas} Gas). Nachfolgende Transaktionen werden günstiger sein.";

  static String m17(gas) =>
      "Paymaster-Gas-Overhead (${gas}) ist hoch. Gasfreie Transaktionen können teurer sein.";

  static String m18(gas) =>
      "Geschätztes Gesamt-Gas (${gas}) ist ungewöhnlich hoch. Überprüfen Sie Ihre Transaktion auf Fehler.";

  static String m19(gas) =>
      "Verifikations-Gas (${gas}) könnte zu hoch sein. Dies kann bei komplexer Kontologik auftreten.";

  static String m20(value) => "${value} Tage übrig";

  static String m21(value) => "Doppelte Adresse in Zeile ${value}";

  static String m22(value) =>
      "Unzureichender Saldo: Der Gesamtbetrag würde den verfügbaren Betrag übersteigen ${value}";

  static String m23(value) => "Ungültige Adresse in Zeile ${value}";

  static String m24(value) => "Ungültiger Betrag in Zeile ${value}";

  static String m25(value) => "Maximal ${value} Empfänger";

  static String m26(token) => "Genehmigen Sie ${token}, um fortzufahren";

  static String m27(impact) =>
      "Hohe Preisauswirkungen (${impact})! Gehen Sie vorsichtig vor.";

  static String m28(secs) => "Das Angebot läuft in ${secs}s ab";

  static String m29(value) => "+${value} Punkte/Tag";

  static String m30(value) => "Verdienen Sie bis zu ${value} % APY";

  static String m31(value) =>
      "Herzlichen Glückwunsch! Sie besitzen jetzt ${value}";

  static String m32(value) => "Bitte warten Sie ${value} Sekunden";

  static String m33(value) =>
      "Automatische Aktualisierung alle ${value} Sekunden";

  static String m34(address) => "Konto ${address} hinzugefügt";

  static String m35(address, network) =>
      "Möchten Sie dieses Hardware-Wallet-Konto verfolgen?\n\nAdresse: ${address}\nNetzwerk: ${network}";

  static String m36(app) => "Aktuelle App: ${app}";

  static String m37(days) => "${days} vor Tagen";

  static String m38(value) => "Konto konnte nicht importiert werden: ${value}";

  static String m39(date) => "Zuletzt verbunden: ${date}";

  static String m40(value) =>
      "Bitte öffnen Sie die ${value}-App auf Ihrem Gerät";

  static String m41(app) =>
      "Stellen Sie sicher, dass die ${app}-App auf Ihrem Ledger geöffnet ist";

  static String m42(name) =>
      "Sind Sie sicher, dass Sie „${name}“ von gespeicherten Geräten entfernen möchten?";

  static String m43(value) => "Sammeln Sie ${value}-Punkte";

  static String m44(value) =>
      "Sammeln Sie ${value}-Punkte für jeden Freund, der beitritt!";

  static String m45(value) => "${value} Punkte bis zur nächsten Stufe";

  static String m46(amount, token) => "≈ ${amount}${token}";

  static String m47(amount) => "≈ ${amount} USDT";

  static String m48(value) => "Schätzung: Gas: ~${value} Einheiten";

  static String m49(reason) => "Grund: ${reason}";

  static String m50(value) =>
      "Sind Sie sicher, dass Sie den Kontakt ${value} loeschen moechten?";

  static String m51(value) => "${value}d lösen";

  static String m52(value) => "${value} Tage übrig";

  static String m53(value) => "${value} verbleibende Tage";

  static String m54(value) =>
      "Das Aufheben des Stakes dauert ${value} Tage. Ihre Token werden während dieses Zeitraums gesperrt.";

  static String m55(value) => "Sie haben nicht genuegend \"${value}\"";

  static String m56(value) =>
      "\"${value}\" Konto konnte nicht abgerufen werden";

  static String m57(value) => "Minimum ${value} XRP fuer erste Ueberweisung";

  static String m58(value) => "Vor ${value}d";

  static String m59(value) => "Vor ${value}h";

  static String m60(value) => "Vor ${value}m";

  static String m61(count) => "Hinzufügen (${count})";

  static String m62(count) =>
      "${Intl.plural(count, one: '1 neues Token erkannt', other: '${count} neue Token erkannt')} — Zum Überprüfen tippen";

  static String m63(value) => "Bestätigungscode an ${value} gesendet";

  static String m64(value) => "Keine ${value}-Blockchain hinzugefuegt.";

  static String m65(value) =>
      "${value} hat unabgeschlossene Transaktionen, bitte spaeter erneut versuchen.";

  static String m66(value) => "Keine Adresse fuer ${value} gefunden.";

  static String m67(value) => "Unzureichendes Guthaben von ${value}.";

  static String m68(value, value1) =>
      "Jedes XRP-Konto muss ${value} XRP (${value1} Drops) als Grundlage reservieren, die nicht ausgegeben werden kann.";

  static String m69(value, value1) =>
      "Fuer jedes Objekt, das das Konto besitzt, werden ${value} XRP (${value1} Drops) zur Reserve hinzugefuegt.";

  static String m70(value, value1) =>
      "Dieses Konto besitzt ${value} Objekte, was bedeutet, dass zusaetzlich ${value1} XRP reserviert sind.";

  static String m71(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m72(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m73(value) =>
      "Sie haben erfolgreich einen ${value} eingerichtet und werden mit N42Wallet die Verifizierung beginnen!";

  static String m74(value) =>
      "Tritt meiner ${value}-Gruppe auf @N42Wallet bei, um ein fruehzeitiger Miner einer Layer-1-Blockchain zu sein und Krypto auf deinem Handy zu erhalten!";

  static String m75(value, value1) =>
      "Sind Sie sicher, dass Sie ${value} N bis ${value1} sperren möchten, um einen Knoten zu betreiben?";

  static String m76(value) => "Import fehlgeschlagen: ${value}";

  static String m77(value) =>
      "Für den Erhalt von Belohnungen ist ein Mindest-Staking-Betrag von ${value} erforderlich.";

  static String m78(value, value1) =>
      "${value} N alle ${value1} geminte Bloecke";

  static String m79(value) => "Muss ${value} Zeichen sein";

  static String m80(value) => "${value} Unzureichendes Guthaben.";

  static String m81(value) => "${value} eingehend...";

  static String m82(value) =>
      "${value} in der App getauscht wird in Kuerze an Ihr Wallet verteilt und kann nicht ueber diesen Prozess verkauft werden. Es kann zum Betrieb eines Knotens verwendet werden.";

  static String m83(value) => "Max. ${value} Zeichen";

  static String m84(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt!";

  static String m85(value) =>
      "${value} Blockchain wird bereits von der App unterstuetzt, moechten Sie sie hinzufuegen?";

  static String m86(value) => "${value} Adresstestverbindung fehlgeschlagen!";

  static String m87(value) =>
      "Die Anwendung wird in ${value} Sekunden entsperrt.";

  static String m88(value) =>
      "Muster-Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m89(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuche";

  static String m90(value) =>
      "Passwort-Eingabefehler, Sie haben noch ${value} Versuch";

  static String m91(value) => "${value}-Passwort eingeben";

  static String m92(value) => "0-${value} Zeichen";

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
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "Speichern Sie diesen Schlüssel — Sie brauchen ihn, wenn Sie Ihr Telefon verlieren.",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("Teilen"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "N42Wallet Google Authenticator Backup-Schlüssel",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie den aktuellen 6-stelligen Google Authenticator Code ein, um 2FA zu deaktivieren.",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Google 2FA deaktivieren",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Google 2FA konnte nicht deaktiviert werden. Bitte überprüfen Sie den Code.",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FA wurde deaktiviert",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie einen gültigen 6-stelligen Code ein",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Geht darüber ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Fällt unter ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigen Sie mich, wenn der Preis angezeigt wird",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Aktivieren Sie diese Warnung",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie einen gültigen Preis größer als 0 ein",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Alarm einstellen"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Zielpreis (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Update-Benachrichtigung",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Token koennen nur innerhalb desselben Netzwerks gesendet werden. Das Senden aus anderen Netzwerken kann zu Verlust fuehren.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Scannen zum Empfangen",
    ),
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "Zu viele Versuche. Biometrie gesperrt – bitte PIN verwenden.",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "Biometrie nicht eingerichtet. Bitte in den Einstellungen aktivieren.",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Face ID / Touch ID verwenden",
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
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Verlauf"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Gesamten Verlauf löschen",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Gesamten Browserverlauf löschen?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("Verlauf gelöscht"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Heute"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Gestern"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("DApps entdecken"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Beliebt"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Brücke"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Lesezeichen"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Werkzeuge"),
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
    "g_chat_key_10": m3,
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
    "g_chat_key_32": m4,
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
    "g_chat_key_6": m5,
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
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "Blockiert",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Achtung"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Sicher"),
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "DApp-Sicherheit",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verifiziert",
    ),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Synchronisieren Sie auch die E-Mail-Adresse des Chat-Kontos",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← E-Mail-Adresse ändern",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Beide Konten wurden erfolgreich aktualisiert!",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "E-Mail ändern",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie den 6-stelligen Chat-Code ein",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Chat-Code gesendet an",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie die Chat-Synchronisierung",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Chat-Code konnte nicht gesendet werden",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Chat-Bestätigungscode wird gesendet...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Chat-Konto-E-Mail synchronisieren",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie den 6-stelligen Code ein",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage(
      "Code erneut gesendet",
    ),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Falscher Code, bitte versuchen Sie es erneut",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Änderung bestätigen",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie und fahren Sie mit der Chat-Synchronisierung fort",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "Aktuelle E-Mail",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Geben Sie den 6-stelligen Code ein",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie eine neue E-Mail-Adresse ein",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige E-Mail-Adresse",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "Die neue E-Mail muss sich von der aktuellen E-Mail unterscheiden",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "N42-E-Mail aktualisiert. Chat-E-Mails können unter Chat > ​​Einstellungen aktualisiert werden.",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Adresse des N42-Kontos aktualisiert",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie eine neue E-Mail-Adresse ein",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "Neue E-Mail-Adresse",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage(
      "Passwort eingeben",
    ),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Aktuelles Passwort (für Chat)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Für die Chat-Synchronisierung ist ein Passwort erforderlich",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Code erneut senden",
    ),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Bestätigungscode senden",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Überspringen – N42-E-Mail ist bereits aktualisiert",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "E-Mail erfolgreich aktualisiert",
    ),
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
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "Gesicht nicht erkannt. Bitte schauen Sie direkt in die Kamera und versuchen Sie es erneut.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Gesichtsabgleich-Methode",
    ),
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
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
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage(
      "Verknuepfung aufheben",
    ),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Gesichtsdaten-Verifizierung fehlgeschlagen!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Gesichtsdaten-Verknuepfungsaufhebung fehlgeschlagen!",
    ),
    "g_face_match_key4": m11,
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
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "Netzwerkfehler. Bitte überprüfen Sie Ihre Verbindung und versuchen Sie es erneut.",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "Gesichtserkennung konnte nicht gestartet werden. Bitte versuchen Sie es erneut.",
    ),
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
    "g_key_135": m12,
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
    "g_key_196": MessageLookupByLibrary.simpleMessage("Entdecker"),
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
    "g_key_214": m13,
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
    "g_key_46": m14,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Nicht genuegend Guthaben fuer diese Transaktion.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Senden"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Laden fehlgeschlagen!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Geldbörse"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Erstellen"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Von"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Bestaetigen"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Notiz"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Seed-Phrase"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Alle Token"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Einstellungen"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Konto erfolgreich erstellt",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Kontodetails",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage("Kontoname"),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie den Kontonamen ein",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("Kontotyp"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Fügen Sie Ihren ersten Vorgang hinzu",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Vorgang hinzufügen",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Adresse wird berechnet...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Adressberechnung fehlgeschlagen. Bitte erneut versuchen.",
    ),
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "Diese Adresse ist vorberechnet und wird bei Ihrer ersten Transaktion bereitgestellt.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Genehmigen"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Charge"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomare Ausführung",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Führen Sie mehrere Vorgänge gleichzeitig aus",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Senden Sie mehrere Transaktionen in einem einzigen Vorgang",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Die Stapelausführung ist fehlgeschlagen",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Keine gespeicherten Vorlagen",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Batch-Operationen",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Sparen Sie Gas",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Als Vorlage speichern",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Einreichen...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Stapel erfolgreich übermittelt",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Vorlage laden",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Vorlagenname",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie den Namen der Vorlage ein",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Vorlage gespeichert",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Vorlagen",
    ),
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Stapelübertragung",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch-Transaktion",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Genehmigen und tauschen Sie eine Transaktion aus – keine zweistufigen Bestätigungen mehr",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Batch-Aktionen mit einem Klick",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsern Sie Transaktionen oder zahlen Sie Gebühren mit ERC-20-Tokens anstelle von ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie Benzin mit einem beliebigen Token",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Stellen Sie den Zugriff über vertrauenswürdige Kontakte wieder her, wenn Sie Ihren privaten Schlüssel verlieren",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Sozialer Aufschwung",
    ),
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Biconomy-Konto",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Modulares ERC-7579 Smart Account mit Unterstützung für gaslose Transaktionen",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("von"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Kette"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Ketten-ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Veränderung"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Überprüfen Sie den Status",
    ),
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Alles löschen"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Demnächst erhältlich",
    ),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Weiter"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Vertrag"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Kontrafaktische Adresse",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Dies ist eine kontrafaktische Adresse. Es wird bei Ihrer ersten Transaktion bereitgestellt.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Erstellen Sie ein Smart-Konto",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Erstellen Sie Ihr erstes Smart-Konto",
    ),
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Erstellen Sie zunächst ein Smart-Konto",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel erstellen",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel ermöglichen es DApps, Transaktionen in Ihrem Namen mit eingeschränkten Berechtigungen und Zeitbeschränkungen auszuführen.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Erstellen Sie ein Smart-Konto",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Erstellt"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefiniert",
    ),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Bereitstellen"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Das Konto wird bei Ihrer ersten Transaktion automatisch bereitgestellt",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Bereitstellung fehlgeschlagen",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Die Bereitstellung ist fehlgeschlagen. Bitte versuchen Sie es erneut.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Die Bereitstellung wurde gestartet",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Im Einsatz"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Das Konto ist einsatzbereit",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Bereitstellung...",
    ),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "Die Bereitstellungstransaktion wird verarbeitet",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Die Bereitstellung erfolgt automatisch mit Ihrer ersten Transaktion.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Erleben Sie die nächste Generation von Ethereum-Konten mit erweiterten Funktionen",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Einzelheiten"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "EIP-7702-Konto",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrides EOA/Smart-Konto – keine Bereitstellung erforderlich",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Fehler"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Geschätztes Benzin",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage("Schätzung..."),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Stapel ausführen",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Läuft ab"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fabrik"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Stapeln Sie mehrere Transaktionen",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie Benzin mit einer beliebigen Wertmarke",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Erhöhte Sicherheit",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("KOSTENLOS"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage(
      "Voller Zugriff",
    ),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gasschätzung",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Gasschätzung fehlgeschlagen, Standardeinstellung verwendet",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gaszahlung"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Zahlungsoptionen für Gas",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Gaseinsparungen",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas gesponsert",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Ausführungs-Gas hoch",
    ),
    "g_key_aa_gas_warn_call_high_desc": m15,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Bereitstellungs-Gas-Overhead",
    ),
    "g_key_aa_gas_warn_deploy_desc": m16,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Paymaster-Overhead hoch",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m17,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Gas-Limit sehr hoch",
    ),
    "g_key_aa_gas_warn_total_high_desc": m18,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Mögliche Gas-Unterschätzung",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Das tatsächlich verwendete Gas könnte die Schätzung überschreiten. Erwägen Sie einen größeren Puffer.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Verifikations-Gas hoch",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m19,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gaslos"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gaslose Transaktionen und Batch-Operationen",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Kontoabstraktion",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage("Gerade eben"),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Kernel-Konto",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Modulares Konto mit Plugin-Unterstützung von ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Etikett"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Letzte Aktivität",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Meine Smart Accounts",
    ),
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Niemals"),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Noch keine Smart-Konten",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Keine Konten entsprechen Ihrem Filter",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Keine Operationen hinzugefügt",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Keine Sitzungsschlüssel",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Nicht bereitgestellt",
    ),
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Das Konto wird bei der ersten Transaktion bereitgestellt",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Erstellen Sie ein Smart-Konto (kostenlos, keine ETH erforderlich)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Finanzieren Sie es – erhalten Sie einen beliebigen EVM-Token",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Mit Paymaster können Sie gaslose Transaktionen durchführen",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operationen"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Besitzer"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie Benzin mit Token",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie Benzin mit Ihrer ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie mit",
    ),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Bezahlen Sie mit ETH",
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
      "Wählen Sie aus, wie Sie die Transaktionsgebühren für Gas bezahlen möchten",
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
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Ausstehend"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Erlaubnis"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Vorschau der Adresse",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Bereit"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Adresse erhalten",
    ),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Empfohlen"),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage(
      "Versuchen Sie es noch einmal",
    ),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Widerrufen"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie diesen Sitzungsschlüssel widerrufen möchten? Die autorisierte DApp kann keine Transaktionen mehr ausführen.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel widerrufen",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel widerrufen",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage(
      "Widerrufen",
    ),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel wird widerrufen...",
    ),
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Sicheres Konto",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-Signatur-Konto mit erweiterten Sicherheitsfunktionen",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage("Wächter"),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage(
      "Schwellenwert",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("gespeichert"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie Kette aus",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie Zahlmeister",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie den Kontotyp aus",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Ausgewählt"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Senden Sie Token mit Ihrem Smart-Konto",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage(
      "AA-Übertragung",
    ),
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
      "Details zum Sitzungsschlüssel",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Gültig für",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Hohes Risiko — nur vertrauenswürdige DApps",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Sitzungsschlüssel",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autorisieren Sie DApps mit temporärem Zugriff auf Ihr Smart-Konto",
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
      "Einfaches Konto",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Einfaches Smart-Konto mit Einzeleigentümer – für die meisten Benutzer empfohlen",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Intelligentes Konto",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Intelligente Konten",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Intelligente Geldbörse",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Ausgabenlimit",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gesponsert (kostenlos)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Intelligentes Konto",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Gesamtgas"),
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage("Gesamtwert"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transaktionen",
    ),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage(
      "Nicht verfügbar",
    ),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Alle anzeigen"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Konto erfolgreich verknüpft",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Die Verknüpfung des Kontos wurde erfolgreich aufgehoben",
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
      "Erweiterte Funktionen",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Berechtigung prüfen",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Beanspruchen"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage(
      "Beansprucht",
    ),
    "g_key_airdrop_days_left": m20,
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
      "Apple-Anmeldung abgebrochen",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Bewerben"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Empfänger hinzufügen",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Ausstrahlung...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Alles löschen",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie die Stapelübertragung",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Weiter"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV-Format: Adresse,Betrag,Bezeichnung",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Fertig"),
    "g_key_batch_duplicate_address": m21,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Gas schätzen...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Die Stapelübertragung unterstützt nur EVM-Ketten",
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
      "Hilfe zur Stapelübertragung",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "CSV importieren",
    ),
    "g_key_batch_insufficient_balance": m22,
    "g_key_batch_invalid_address": m23,
    "g_key_batch_invalid_amount": m24,
    "g_key_batch_max_recipients": m25,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Notiz ist optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Nutzen Sie Multicall3 für niedrigere Gasgebühren",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Keine unterstützten Token",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Vorschau"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("Empfänger"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie Token aus",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Senden Sie Token in einer Transaktion an mehrere Adressen",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "Unterzeichnung...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Wischen Sie nach links, um einen Empfänger zu entfernen",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Stapelüberweisung",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Gesamtbetrag",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Betrag"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Kette wird nicht unterstützt",
    ),
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
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Token auswählen",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Schlupf"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Abgeschlossen",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Fehlgeschlagen",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "In Bearbeitung",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Ausstehend",
    ),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Brücke"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage(
      "Geschätzte Zeit",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Brücke"),
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
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Gesperrt bis",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Stellen Sie sicher, dass die Sperrfrist abgelaufen ist, bevor Sie Ihre Einlösung absenden.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC ist immer noch gesperrt",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "vBTC einlösen",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Entsperrt – bereit zum Einlösen",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Ich verstehe die Risiken und möchte fortfahren",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Weiter abstecken",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Wie es funktioniert",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC wird gesperrt, bis die Zeitsperre abläuft. Schließen Sie den Absteckvorgang in der Benutzeroberfläche unten ab.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Ihr BTC wird für den gesamten Einsatzzeitraum gesperrt. Eine vorzeitige Auszahlung ist nicht möglich.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Die Sperre wird durch Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) erzwungen und kann nicht umgangen werden.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Smart-Contract-Risiko: Obwohl geprüft, ist kein Protokoll völlig risikofrei.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Mindesteinsatz: 0,001 BTC. Mindestsperrdauer: 0,125 Tage (~3 Stunden).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Risikowarnung",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Ihr BTC ist in einer 2-aus-2-Multisig-Adresse mit Zeitschloss (CLTV) gesperrt, gesichert durch Ihren Schlüssel und den N42-Kanisterschlüssel.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Sperren Sie Ihren BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Nach der Bestätigung in der Kette wird vBTC im Verhältnis 1:1 in Ihr Wallet übertragen.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Mint vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Halten Sie vBTC, um Einsatzprämien zu erhalten. vBTC ist auch in DeFi-Protokollen verwendbar.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Verdienen Sie Belohnungen",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Wenn die Sperrfrist abgelaufen ist, brennen Sie Ihr vBTC, um Ihr ursprüngliches BTC zurückzuerhalten.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Nach dem Entsperren einlösen",
    ),
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Sperren Sie BTC, um vBTC zu prägen und Belohnungen zu verdienen",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "BTC Self-Custody Staking",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Verstanden"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Wählen Sie einen Token mit NFT-Unterstützung aus",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Gehen Sie zur Registerkarte NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Wählen Sie das NFT aus, das Sie brennen möchten",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Tippen Sie auf die Schaltfläche „Brennen“.",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Schritte:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Um einen NFT zu brennen, gehen Sie bitte zur NFT-Detailseite und tippen Sie auf die Schaltfläche „Brennen“.",
    ),
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("NFT brennen"),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Diese Kette unterstützt noch keine Übertragungen, bleiben Sie dran",
    ),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage("E-Mail ändern"),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Passwort ändern",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihr aktuelles Passwort ein und legen Sie ein neues Passwort fest",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie den 6-stelligen Code ein",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Ein Bestätigungscode ist erforderlich",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Bestätigungscode gesendet",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Alle Vermögenswerte liegen unter 1 US-Dollar",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Sonstige Vermögenswerte",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Tippen Sie, um alle anzuzeigen",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Neu"),
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie das neue Passwort",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Weiter mit Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Weiter mit Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Terminerinnerungen",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Genehmigt! Tippen Sie auf „Tauschen“, um fortzufahren.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Genaue Menge",
    ),
    "g_key_dex_approve_required": m26,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Unbegrenzt",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Unbegrenzte Genehmigung: Der Router kann dieses Token jederzeit ausgeben. Standard, birgt jedoch Risiken bei Kompromittierung.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Genehmigen…"),
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
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Min. Erhalten",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Keine Token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Keine Token gefunden",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Preisdiagramm",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Preiseinfluss",
    ),
    "g_key_dex_price_impact_high": m27,
    "g_key_dex_quote_expires": m28,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Angebot fehlgeschlagen",
    ),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "Angebot aktualisiert",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Wiederholen"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Symbol / Name / Adresse suchen",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Auswählen"),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Slippage-Toleranz",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Maximaler Schlupf",
    ),
    "g_key_dex_sol_note": MessageLookupByLibrary.simpleMessage(
      "Solana-Swap: Signieren Sie die Transaktion in Ihrem Solana-Wallet.",
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
      "Solana-Namensservice",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Solana-Domain nicht gefunden",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unaufhaltsame Domänen",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Unstoppable-Domain nicht gefunden oder keine Adresse für diese Chain",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Aktive Produkte",
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
      "Fordern Sie kostenlose Token an",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-Chain-Transfer",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Täglicher Check-in-Bonus",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Tausche beliebige Token über Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX-Tausch"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Staking starten",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Hauptbuch"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "APY wird geladen...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Bergbau"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage(
      "Verdienen Sie mehr",
    ),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Nativer Solana-Einsatz",
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
      "Sammeln Sie täglich Punkte",
    ),
    "g_key_earn_pts_day": m29,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Schnelle Tools",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("Empfohlen"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Tauschtyp wählen",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH mit Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Tauschen"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Verdienen"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Gesamtertrag",
    ),
    "g_key_earn_up_to_apy": m30,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Alle anzeigen",
    ),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Berechtigungswarnungen",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Nur berechtigt",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie eine gültige E-Mail-Adresse ein",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "E-Mail ist erforderlich",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Gelöste Adresse aktualisiert",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage(
      "Fortgeschritten",
    ),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Jahresgebühr",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Verfügbar"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage("Grundpreis"),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Verfügbarkeit prüfen...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Begehen"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Commit fehlgeschlagen",
    ),
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Transaktion wird ausgeführt...",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Die Registrierungsverpflichtung ist abgelaufen. Bitte starten Sie den Registrierungsprozess erneut.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Sich verpflichten...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie die Verlängerung",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Bestätigen und senden",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Bestätigen Sie die ENS-Auflösung",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Adresse kopiert",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Aktueller Ablauf",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage("Tage übrig"),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Registrieren und verwalten Sie Ihre .eth-Domainnamen",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "ENS-Name erkannt",
    ),
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Anmeldezeitraum",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Datensätze bearbeiten",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Abgelaufen"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Läuft ab"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Läuft bald ab",
    ),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Anmeldezeitraum verlängern",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Fehlgeschlagen"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Abschluss der Registrierung",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Beginnen Sie mit ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Holen Sie sich Ihren .eth-Namen",
    ),
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage("ENS-Manager"),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Ungültige Adresse (muss 0x + 40 Hexadezimalzeichen sein)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Ungültiger ENS-Name",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "gehört jetzt dir!",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Bitte lassen Sie die App während der Registrierung geöffnet",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Verwalten Sie Ihre Web3-Identität",
    ),
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "ENS verwalten",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Mindestens 3 Zeichen",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage(
      "Meine Domains",
    ),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("ENS-Name"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Neuer Ablauf",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Neue Eigentümeradresse",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Noch keine Domains",
    ),
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "Sie besitzen noch keine ENS-Namen",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "Meine ENS-Namen",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Besitzer"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Bitte warten",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Premium-Name",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Preisaufschlüsselung",
    ),
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage(
      "pro Jahr",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primär"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Primärer Name erfolgreich festgelegt",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Verarbeitung...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Registrieren Sie ENS",
    ),
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage("Aufzeichnungen"),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("Registrieren"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Ihre dezentrale Identität auf Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Die Registrierung ist fehlgeschlagen",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Registrieren Sie sich jetzt",
    ),
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Name wird registriert...",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registrieren...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Anmeldeinformationen",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Anmeldezeitraum",
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
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Erneuern"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Erneuerungskosten",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Erweitern Sie Ihre Domainregistrierung",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Erneuerung erfolgreich",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage(
      "ENS erneuern",
    ),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "Die ENS-Auflösung ist fehlgeschlagen",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Aufgelöste Adresse",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "ENS wird gelöst...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Suchen"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Finden Sie verfügbare .eth-Namen",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Suchen Sie nach einem .eth-Namen",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Geben Sie einen ENS-Namen für die Suche ein",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Suchen und registrieren",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Suchen Sie nach ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Senden an eigene Adresse nicht möglich",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Ethereum-Namensdienst",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Als primär festlegen",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Standardname",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Beginnen Sie mit der Registrierung",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Schritt 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Schritt 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Schritt 3"),
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("Begehen"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage(
      "Registrieren",
    ),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Erfolg"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Warte"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Subdomain erstellen",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomain erstellt",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Subdomain löschen",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Diese Subdomain wird dauerhaft gelöscht.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomain gelöscht",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Noch keine Subdomains",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Verwenden Sie nur Buchstaben, Zahlen und Bindestriche",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Subdomain-Label",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "z.B. Blog, E-Mail, App",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Adresse des Eigentümers",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Lassen Sie das Feld leer, um die aktuelle Brieftasche zu verwenden",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomains"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Erfolg!"),
    "g_key_ens_success_message": m31,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("Vorschläge"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Textaufzeichnungen",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS-Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Insgesamt"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage(
      "Gesamtkosten",
    ),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Übertragen"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Übertragen Sie das Eigentum an eine andere Adresse",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Übertragung erfolgreich",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Die Übertragung ist irreversibel. Stellen Sie sicher, dass die Adresse des neuen Eigentümers korrekt ist.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Versuchen Sie es mit einem anderen Namen",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "Die ENS-Registrierung ist ein zweistufiger Prozess",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Nicht verfügbar",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Warte"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Die Wartezeit verhindert Front-Running-Angriffe",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Eine Wartezeit verhindert ein Front-Running",
    ),
    "g_key_ens_wait_timer": m32,
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Warten..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Bitte überprüfen Sie die aufgelöste Adresse, bevor Sie fortfahren. ENS-Namen können von ihrem Eigentümer übertragen oder geändert werden.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("Jahr"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("Jahre"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Ihre Identität",
    ),
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Geben Sie das neue Passwort erneut ein",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihre E-Mail-Adresse ein",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Geben Sie ein neues Passwort ein",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Geben Sie das aktuelle Passwort ein",
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
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Ich verstehe, dass jeder, der diese Datei und das Passwort erhält, die vollständige Kontrolle über mein Guthaben hat – ein Verlust ist dauerhaft und nicht wiederherstellbar",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort eingeben, um Export zu bestätigen",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort eingeben, um privaten Schlüssel anzuzeigen",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Rückmeldung"),
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
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtern"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Typ"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Passwort vergessen?",
    ),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Gasalarm"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alarm, wenn oben",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigung, wenn unten",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Schwelle (Gwei)",
    ),
    "g_key_gas_auto_refresh": m33,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Grundgebühr"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage(
      "Benutzerdefiniert",
    ),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Gesch. Zeit",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Schnell"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Die Gaspreise schwanken je nach Netznachfrage. Niedrigeres Gas = langsamere Bestätigung, höheres Gas = schnellere Bestätigung.",
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
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage("Preistrend"),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Prioritätsgebühr",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Gaspreise in Echtzeit",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Gas-Einstellungen",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Langsam"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas-Tracker"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Mittel"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Stark"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Muster zu einfach, bitte mehr Punkte verwenden",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Schwach"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google-Anmeldung abgebrochen",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "Nur hoher Wert",
    ),
    "g_key_hw_account_added": m34,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Konto bereits importiert",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Konten"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Hinzufügen"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Konto hinzufügen",
    ),
    "g_key_hw_add_account_content": m35,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adresse kopiert",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Stellen Sie sicher, dass Ihr Gerät entsperrt und Bluetooth aktiviert ist, bevor Sie eine Verbindung herstellen.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Überprüfen Sie die App",
    ),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Auf Ihrem Gerät bestätigen",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Hardware-Wallet verbinden",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Neues Gerät anschließen",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Luftspalt mit Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Ledger verbinden (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Trezor verbinden (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Verbunden"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("Verbinden..."),
    "g_key_hw_current_app_label": m36,
    "g_key_hw_days_ago": m37,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Ableitungspfad",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Trennen"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Getrennt"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Bitte Bluetooth aktivieren",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Firmware-Version",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Zurück"),
    "g_key_hw_import_failed": m38,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Keystone verbinden",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Ungültige Antwort vom Keystone-Gerät",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "QR-Code konnte nicht analysiert werden. Bitte versuchen Sie es erneut.",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie diesen QR-Code mit Ihrem Keystone-Gerät, um die Transaktion zu signieren",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Richten Sie Ihre Kamera auf den QR-Code, der auf Ihrem Keystone-Gerät angezeigt wird",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Keystone-Signatur scannen"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie den QR-Code von Ihrem Keystone-Gerät, um Konten zu importieren",
    ),
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signatur erfolgreich empfangen"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "Warten auf Keystone-Signatur...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tippen Sie hier, um die Keystone-Antwort zu scannen",
    ),
    "g_key_hw_last_connected": m39,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Hauptbuch"),
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
      "Derzeit ist keine App geöffnet",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Keine Geräte gefunden",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Gerät nicht verbunden",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Nicht verbunden",
    ),
    "g_key_hw_open_app": m40,
    "g_key_hw_open_ledger_app_hint": m41,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Auf dem Gerät abgelehnt",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Entfernen"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Gerät entfernen",
    ),
    "g_key_hw_remove_device_confirm": m42,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Gespeicherte Geräte",
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
      "Unterstützte Geräte",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Verbindungs-Timeout",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("Hardware-Wallet"),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Heute"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Verbindung zu Trezor konnte nicht hergestellt werden. Stellen Sie sicher, dass USB angeschlossen ist.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Trezor verbinden",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor wurde erfolgreich verbunden",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Mit Trezor verbinden...",
    ),
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die Passphrase auf Ihrem Trezor-Gerät ein",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die PIN auf Ihrem Trezor-Gerät ein",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Schließen Sie Ihr Trezor-Gerät per USB-Kabel an und entsperren Sie es",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Konten anzeigen",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Wallet-Konten",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Gestern"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Ein Waehrungs-Wallet fuer diesen Typ existiert bereits.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Keystore konnte nicht gelesen werden",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Schlüsselspeicher",
    ),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage(
      "Konto verknüpfen",
    ),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Verknüpfte Konten",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Anmelden"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Anmeldung erfolgreich",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Abmelden"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie die App beenden moechten?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Verfügbare Punkte",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Heute eingecheckt!",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Einchecken",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Fertig",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Der Check-in ist fehlgeschlagen. Bitte versuchen Sie es erneut",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in erfolgreich!",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Punkte beanspruchen",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Die Aufgabe ist fehlgeschlagen. Bitte versuchen Sie es erneut",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Aufgabe erledigt!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Kopieren"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Tägliches Check-in",
    ),
    "g_key_loyalty_earn_points": m43,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Verdient"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Punkteverlauf",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Einladen"),
    "g_key_loyalty_invite_bonus": m44,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Freunde einladen",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Eingeladene Freunde",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Maximales Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage(
      "Als nächstes",
    ),
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
    "g_key_loyalty_points_to_next": m45,
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
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Teilen"),
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
      "Insgesamt verdient",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Gesamtpunkte",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Gebraucht"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Browser"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegramm"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Zwietracht"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Marktkapitalisierung"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Handelsvolumen"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Gesamtangebot"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("Im Umlauf"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("Ueber"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Mehr"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Links"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Webseite"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Ketten verwalten",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Verfügbar"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Erfordert Abstecken",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Bitte Seed-Phrase eingeben",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("Neue Airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage(
      "Neues Passwort",
    ),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Das neue Passwort muss sich vom aktuellen Passwort unterscheiden",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Als nächstes"),
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
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Ungültige Wallet-Adresse",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Gleichgewicht"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Diese Aktion ist irreversibel. Der NFT wird an die Brennadresse gesendet.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "Burn wird nur auf EVM-Ketten unterstützt",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT Burn kommt bald",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("NFT brennen"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Sammlung"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Vertrag"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage(
      "Beschreibung",
    ),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "NFTs konnten nicht geladen werden. Tippen Sie, um es noch einmal zu versuchen.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Alle"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Video"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Boden"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFT-Galerie"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Inschrift #",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Keine NFTs gefunden",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Kein Explorer-Link verfügbar",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Videowiedergabe wird nicht unterstützt",
    ),
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "Im Explorer anzeigen",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage(
      "Ordnungszahlen",
    ),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Ordinalzahlenübertragungen werden noch nicht unterstützt",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Menge"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Suchen Sie nach Name oder Sammlung",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("NFT senden"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT-Transfers stehen bald an",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("Token-ID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Typ"),
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Keine verknüpften Konten",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungseinstellungen",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Unternehmensanmeldung (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO nicht konfiguriert",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Aktuelles Passwort",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("oder"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Passwort erfolgreich geändert",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Das Passwort muss mindestens 6 Zeichen lang sein",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Anders als das aktuelle Passwort",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "Mindestens 6 Zeichen",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Passwort ist erforderlich",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Passwortanforderungen",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Passwort erfolgreich zurückgesetzt",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwörter stimmen nicht überein",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Ungültiger Betrag",
    ),
    "g_key_payment_approx_token": m46,
    "g_key_payment_approx_usdt": m47,
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
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Geldbörse"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Aus Telefongalerie auswaehlen",
    ),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage(
      "Code erneut senden",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Zurücksetzen"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Passwort zurücksetzen",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihre E-Mail-Adresse ein, um einen Bestätigungscode zu erhalten",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("SAML-Anmeldung"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML nicht konfiguriert",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Seien Sie vorsichtig",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Vertragssicherheit prüfen...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Hohes Risiko erkannt",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Vertraglich geprüfter Safe",
    ),
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Bestätigungscode senden",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Memo / Notiz",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Memo / Notiz (optional)",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Legen Sie Ihr neues Passwort fest",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("QR-Code teilen"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Link teilen"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Teilen-Methode",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Die Anmeldung ist fehlgeschlagen",
    ),
    "g_key_sim_gas_estimate": m48,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Die Transaktion wird wahrscheinlich fehlschlagen",
    ),
    "g_key_sim_reverted_reason": m49,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Transaktion wird simuliert…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Transaktionssimulation bestanden",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulation für dieses Netzwerk nicht verfügbar",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage(
      "Soziales Login",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chatten"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Die Datei ist zu gross zum Hochladen",
    ),
    "g_key_squad_k15": m50,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Kontakt hinzufuegen",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Kontakt"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Nach E-Mail suchen",
    ),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Aktiv"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Aktive Positionen",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Betrag"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Betrag, der zurückgenommen werden soll",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage(
      "Durchschnittlicher effektiver Jahreszins",
    ),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Belohnungen beanspruchen",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Provision"),
    "g_key_stake_d_unbond": m51,
    "g_key_stake_days_left": m52,
    "g_key_stake_days_remaining": m53,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegierer",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Schätzung: Tägliche Belohnung",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Schätzung: Jährliche Belohnung",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Gehen Sie zu Tauschen",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Flüssiges Abstecken",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Flüssiges Abstecken",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage(
      "Flüssigkeit",
    ),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Ihr Liquid-Token kann direkt am DEX gehandelt werden. Verwenden Sie Swap, um es wieder gegen das native Asset auszutauschen.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Mindesteinlage",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Keine aktiven Positionen zum Auflösen",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("Kein Schloss"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Keine Staking-Positionen",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Noch keine Absteckpositionen",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Keine Validatoren gefunden",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Wallet-Adresse nicht verfügbar",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Übersicht über den gesamten Einsatz",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Ausstehende Belohnungen",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Meine Positionen",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protokoll"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protokolle"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restaken"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Belohnungen"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Suchvalidatoren...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie einen Validator aus",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Wählen Sie eine Position aus, die Sie aufheben möchten",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Validator auswählen",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "Sortieren nach",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Staken"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Abgesteckt"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Beginnen Sie mit dem Abstecken",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Abstecken"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Gesamt gestaked",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaktion erfolgreich vorbereitet",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("Entsperren"),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Entsperrungszeitraum",
    ),
    "g_key_stake_unbonding_warning": m54,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Entstaken"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Aktualisierung...",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Betriebszeit"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validator"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validatoren",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Sie erhalten",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("E-Mail"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Passwort"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Überprüfen"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Abgeschlossen"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas-Preis"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Maximale Gasgebuehr"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Maximale Gebuehr pro Gas",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Ausstehend"),
    "g_key_t_29": m55,
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
    "g_key_t_45": m56,
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
    "g_key_t_52": m57,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Die Empfaengeradresse hat kein Konto, und die erste Ueberweisung muss mindestens 10 XRP betragen",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Verbrauchtes Gas"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m58,
    "g_key_time_hours_ago": m59,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Gerade eben"),
    "g_key_time_minutes_ago": m60,
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Hinzufügen",
    ),
    "g_key_token_discovery_add_selected": m61,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Token hinzugefügt",
    ),
    "g_key_token_discovery_banner": m62,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Alle abwählen",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Keine neuen Token gefunden",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignorieren",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Alles auswählen",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Entdeckte Token",
    ),
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
      "Startdatum",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Datumsbereich",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage("Enddatum"),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Richtung",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Keine Transaktionen entsprechen Ihrem Filter",
    ),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT-Typen"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Follower"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Benutzertypen"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Webseite"),
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
      "Verknüpfung des Kontos aufheben",
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
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Neueste Version gefunden",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Sofort aktualisieren"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("Neue Version gefunden"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Bereits die neueste Version",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Bestätigungscode",
    ),
    "g_key_verification_code_sent": m63,
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
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Blockieren"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Wert"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Beschleunigen"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Hinweis"),
    "g_key_wallet_m1": m64,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Sind Sie sicher, dass Sie Ihr Konto kuendigen moechten?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Abmeldung bestaetigen",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Bitte Google-Verifizierungscode eingeben.",
    ),
    "g_key_wallet_m19": m65,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Der aktuelle Token wurde nicht hinzugefuegt.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Geben Sie Ihre Seed-Phrase mit durch Leerzeichen getrennten Woertern ein",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Wallet importieren",
    ),
    "g_key_wallet_m3": m66,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Das aktuelle Token-Guthaben ist unzureichend.",
    ),
    "g_key_wallet_m5": m67,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Signaturfehler"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("Kontokuendigung"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "E-Mail-Verifizierungscode eingeben.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Wallet verwalten",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Geben Sie die Ethereum-Adresse ein (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Nur zum Ansehen",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Eine reine Watch-Wallet kann keine Transaktionen senden oder signieren",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Uhrenbrieftasche",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Verfolgen Sie jede EVM-Adresse ohne privaten Schlüssel",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reserviert"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Basisreserve"),
    "g_key_xml_11": m68,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage(
      "Inkrementelle Reserve",
    ),
    "g_key_xml_22": m69,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Besitzobjekte",
    ),
    "g_key_xml_33": m70,
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
    "g_lock_key21": m71,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort zuruecksetzen",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Zu viele falsche Eingaben, bitte setzen Sie das Passwort zurueck",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Wallet-Passwort hinzufuegen?",
    ),
    "g_lock_key25": m72,
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
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("30D-Änderung"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7D-Änderung"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Markttiefe"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Noch keine Merkliste",
    ),
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Tippen Sie auf ★ auf eine beliebige Münze, um sie hinzuzufügen",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage(
      "Hoch 24 Stunden",
    ),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Liquiditätsbewertung",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage(
      "Niedrig 24 Stunden",
    ),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Nachrichten"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Keine Diagrammdaten",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Keine Ergebnisse",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Rang"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Suchen"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Münzen suchen...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Im Trend"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Beobachtungsliste",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Inaktivitätswert des Validators ist hoch. Überprüfen Sie Ihren Knotenstatus, um Strafen zu vermeiden.",
    ),
    "g_mining_key15": MessageLookupByLibrary.simpleMessage("Aufgabendetails"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("N entsperren?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Cloud-Verifizierungsaktivitaet",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Verifizierungseinstellungen",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Musik zur Hintergrundüberprüfung",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Stumm"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Wenn die Hintergrundüberprüfung aktiviert ist, wird die Musik im Hintergrund abgespielt. Wenn die Musik stoppt, wird auch die Verifizierung beendet.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Ihre Stufe"),
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
    "g_mining_key63": m73,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage("Entsperrdatum"),
    "g_mining_key73": m74,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Ich habe gerade einen Knoten auf @N42Wallet eingerichtet und die Verifizierung auf mobilen Geraeten gestartet! Komm und mach mit. Die dezentralisierte Zukunft ist mobil!",
    ),
    "g_mining_key76": m75,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Mineralisch"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Knoten"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Netzwerk"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Wechseln Sie zwischen Testnet und Mainnet für Cloud Mining.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Einloesung nach 768s verfuegbar.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Anfragen davor werden nicht bearbeitet.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Zuhause"),
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
    "g_mining_key_109": m76,
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
    "g_mining_key_116": m77,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Belohnung sammelt sich taeglich an und wird erst an Ihr N-Wallet gesendet, wenn sie ~0,5 N erreicht.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Gesamtbelohnungen",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Geminter Wert"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("Aufgabendetails"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Zusammenfassung"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Aktivitäten"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Abgebauter Gesamtwert",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("Überprüfung seit"),
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Belohnungsverteilung",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage(
      "Anzahl der Gewinne",
    ),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Verifizierter Wert",
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
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Möchten Sie wirklich überspringen?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Sie erhalten keine Verifizierungsprämien, bis Sie sich für einen der Pläne entscheiden.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Deaktiviert"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Belohnung"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Mehr anzeigen"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Verifizierungsstatus",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Zum Entsperren"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Überspringen"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Letzte 7 Tage"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Gesammelte Belohnungen",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Sperren Sie N, um Verifizierungsbelohnungen zu starten.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Erhaltene Belohnungen",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Fortgeschritten"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Einstieg"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Profi"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage(
      "VOLLSTÄNDIGER KNOTEN",
    ),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MIN./TAG"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage(
      "Erweiterter Knoten",
    ),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Einstiegs-Knoten"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro-Knoten"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 Bloecke/Tag ~ 70 Min.",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Entsperrdatum"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 Bloecke/Tag ~ 15 Min.",
    ),
    "g_mining_key_71": m78,
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
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Die heutige Verifizierungszeit",
    ),
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
    "g_mining_key_98": m79,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Bitte geben Sie Ihr Passwort erneut ein, um es zu bestaetigen",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Vollständige Knotendetails",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("Knoten-ID"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Verbunden"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Getrennt"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Verbindet...",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Ablaufdatum"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Entsperrungszeitraum:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Jederzeit entsperrbar",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Keine Neuigkeiten verfügbar",
    ),
    "g_news_source": MessageLookupByLibrary.simpleMessage("Quelle"),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Zurück (Sicher)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Trotzdem fortfahren",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Diese Website wurde als potenziell schädlich eingestuft. Sie könnte versuchen, Ihre Krypto-Assets oder privaten Schlüssel zu stehlen.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Sicherheitswarnung",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "Verdächtige URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Handel hinzufügen",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage(
      "Durchschnittliche Kosten",
    ),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Kaufpreis (USD)",
    ),
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Abbrechen"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Kostenbasis"),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "Keine Trades erfasst",
    ),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Menge"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Speichern"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Nicht realisierte Gewinne und Verluste",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24h Wechsel"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Alle Bestände",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Vermögensaufteilung",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("Top-Gewinner"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("Top Verlierer"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "24-Stunden-Umzug",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Keine Vermögenswerte gefunden",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Andere"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Gesamt"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Gesamtwert"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage(
      "Heruntergeladen",
    ),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Einladungscode",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Eingeladen"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Mining-Knoten"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Belohnung (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage(
      "Empfehlungsstatistiken",
    ),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Klassisches Mining (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Bergbau (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Mining-Interface",
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
    "g_swap_key_14": m80,
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
    "g_swap_key_20": m81,
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
    "g_swap_key_31": m82,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Swaps koennen auf den entsprechenden Blockchain-Explorern (Etherscan, BscScan, TRONSCAN und unserem eigenen) eingesehen werden.",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Zu N tauschen"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Tauschen"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Sie erhalten"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Swap-Vorschau"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Erneut versuchen"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage("Akzentfarbe"),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Auf Standard zurücksetzen",
    ),
    "g_token_m_key_1": m83,
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
    "g_token_m_key_22": m84,
    "g_token_m_key_23": m85,
    "g_token_m_key_24": m86,
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
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Achtung"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Hohes Risiko"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Sicher"),
    "g_unlock_key10": m87,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Fingerabdruck- oder Gesichtserkennung nicht aktiviert?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Muster-Passwort zeichnen",
    ),
    "g_unlock_key4": m88,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Passwort eingeben"),
    "g_unlock_key6": m89,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Authentifizierung fehlgeschlagen",
    ),
    "g_unlock_key8": m90,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Sie koennen auch "),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Später"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Verbindung verloren. Bitte erneut verbinden.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp hat die Verbindung getrennt",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage("Alle trennen"),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Von allen DApps trennen?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Von dieser DApp trennen?",
    ),
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage(
      "Neue Verbindung",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Keine aktiven Verbindungen",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Scannen Sie einen QR-Code, um sich mit einer DApp zu verbinden",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Verbindungsanfrage abgelaufen",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Sitzung ist abgelaufen",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("Verbundene DApps"),
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
    "google_verification_message21": m91,
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
    "nicknameMessage": m92,
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
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Nicht mehr erinnern",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("Später"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Zu den Einstellungen",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Push-Benachrichtigungen sind deaktiviert. Sie könnten Chat-Nachrichten und Überweisungsbenachrichtigungen verpassen.\n\nBitte aktivieren Sie Benachrichtigungen für diese App in den Systemeinstellungen.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Benachrichtigungen deaktiviert",
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
