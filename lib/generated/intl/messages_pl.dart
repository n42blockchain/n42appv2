// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a pl locale. All the
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
  String get localeName => 'pl';

  static String m0(deviceName, os) =>
      "Twoje konto zostało właśnie zalogowane na ${deviceName} (${os}). Jeśli to nie Ty, zalecamy zmianę hasła.";

  static String m1(price) => "Obecna cena: \$${price}";

  static String m2(symbol) => "Alert cenowy · ${symbol}";

  static String m3(s) => "Wyślij ponownie w ${s}";

  static String m4(message) => "Zakup nie powiódł się: ${message}";

  static String m5(productId) => "Zakup zakończony sukcesem: ${productId}";

  static String m6(productId) => "Przywrócono: ${productId}";

  static String m7(value) => "Kwota większa niż ${value}.";

  static String m8(value) =>
      "Portfel już istnieje, nazwa portfela to \"${value}\"";

  static String m9(value) => "Wprowadź kwotę większą niż ${value}.";

  static String m10(value) => "Zduplikowany adres w wierszu ${value}";

  static String m11(value) =>
      "Niewystarczające saldo: całkowita kwota przekroczyłaby dostępne ${value}";

  static String m12(value) => "Nieprawidłowy adres w wierszu ${value}";

  static String m13(value) => "Nieprawidłowa kwota w wierszu ${value}";

  static String m14(value) => "Maksymalnie ${value} odbiorców";

  static String m15(token) => "Zatwierdź ${token}, aby kontynuować";

  static String m16(impact) =>
      "Wysoki wpływ na cenę (${impact})! Postępuj ostrożnie.";

  static String m17(secs) => "Oferta wygasa za ${secs}";

  static String m18(value) => "Zarabiaj do ${value}% RRSO";

  static String m19(value) => "Automatyczne odświeżanie co ${value} sekund";

  static String m20(address) => "Konto ${address} dodane";

  static String m21(address, network) =>
      "Czy chcesz śledzić to konto portfela sprzętowego?\n\nAdres: ${address}\nSieć: ${network}";

  static String m22(app) => "Bieżąca aplikacja: ${app}";

  static String m23(days) => "${days} kilka dni temu";

  static String m24(value) => "Nie udało się zaimportować konta: ${value}";

  static String m25(date) => "Ostatnio połączone: ${date}";

  static String m26(app) =>
      "Upewnij się, że aplikacja ${app} jest otwarta na Ledgerze";

  static String m27(name) =>
      "Czy na pewno chcesz usunąć „${name}” z zapisanych urządzeń?";

  static String m28(value) => "Szac. gaz: jednostki ~${value}";

  static String m29(reason) => "Powód: ${reason}";

  static String m30(value) => "${value}d rozłączone";

  static String m31(value) => "Pozostało ${value} dni";

  static String m32(value) =>
      "Odstawienie zajmuje ${value} dni. Twoje tokeny zostaną zablokowane w tym okresie.";

  static String m33(value) => "Nie masz wystarczającej ilości \"${value}\"";

  static String m34(value) => "Nie udało się pobrać konta \"${value}\"";

  static String m35(value) => "Minimum ${value} XRP dla pierwszego transferu";

  static String m36(count) => "Dodaj (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: 'Wykryto 1 nowy token', other: 'Wykryto nowe tokeny ${count}')} — dotknij, aby sprawdzić";

  static String m38(value) => "Nie dodano sieci ${value}.";

  static String m39(value) =>
      "${value} ma niezakończone transakcje, spróbuj ponownie później.";

  static String m40(value) => "Nie znaleziono adresu dla ${value}.";

  static String m41(value) => "Niewystarczające saldo ${value}.";

  static String m42(value, value1) =>
      "Każde konto XRP musi zarezerwować ${value} XRP (${value1} drops) jako poziom bazowy, którego nie można wydać.";

  static String m43(value, value1) =>
      "Za każdy obiekt posiadany przez konto dodaje się ${value} XRP (${value1} drops) do rezerwy.";

  static String m44(value, value1) =>
      "To konto posiada ${value} obiektów, co oznacza dodatkową rezerwę ${value1} XRP.";

  static String m45(message) => "Nie udało się wejść do pokoju\n${message}";

  static String m46(value) => "Nieprawidłowy wzór, pozostało ${value} prób";

  static String m47(value) => "Nieprawidłowy wzór, pozostała ${value} próba";

  static String m48(value) =>
      "Pomyślnie skonfigurowałeś ${value} i rozpoczniesz weryfikację z N42Wallet!";

  static String m49(value) =>
      "Dołącz do mojej grupy ${value} na @N42Wallet, aby być wczesnym górnikiem sieci Layer 1 i zdobywać kryptowaluty na telefonie!";

  static String m50(value, value1) =>
      "Czy na pewno chcesz zablokować ${value} N do ${value1}, aby uruchomić węzeł?";

  static String m51(value) => "Import nie powiódł się:${value}";

  static String m52(value) =>
      "Aby otrzymać nagrody, wymagane jest saldo stakingowe wynoszące co najmniej ${value}.";

  static String m53(value, value1) =>
      "${value} N co ${value1} wydobytych bloków";

  static String m54(value) => "Musi mieć ${value} znaków";

  static String m55(symbol) => "Kwota (${symbol})";

  static String m56(amount, symbol) => "Saldo: ${amount} ${symbol}";

  static String m57(label) =>
      "Ogłosić „${label}” zwycięzcą i rozliczyć? Nieodwracalne.";

  static String m58(n) => "${n} min";

  static String m59(n) => "Wynik ${n}";

  static String m60(label, pct) => "${label} wygrywa (${pct}%)";

  static String m61(shares, avg, after) =>
      "Szac. ${shares} udz. · śr ${avg}% · po ${after}%";

  static String m62(label) => "Wynik: ${label}";

  static String m63(n) => "Sprzedaj ${n}";

  static String m64(value) => "Niewystarczające saldo ${value}.";

  static String m65(value) => "${value} w drodze...";

  static String m66(value) =>
      "${value} wymienione w aplikacji zostanie wkrótce przekazane do Twojego portfela i nie może być sprzedane w tym procesie. Może być używane do uruchomienia węzła.";

  static String m67(value) => "Maks. ${value} znaków";

  static String m68(value) =>
      "Sieć ${value} jest już obsługiwana przez aplikację!";

  static String m69(value) =>
      "Sieć ${value} jest już obsługiwana przez aplikację, czy chcesz ją dodać?";

  static String m70(value) =>
      "Test połączenia z adresem ${value} nie powiódł się!";

  static String m71(value) => "0~${value} znaków";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Edytuj"),
    "Verification": MessageLookupByLibrary.simpleMessage("Weryfikacja"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informacje o adresie",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Skopiowano pomyślnie"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Kopiuj adres"),
    "descO": MessageLookupByLibrary.simpleMessage("Opis (opcjonalnie)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Zmień hasło",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Rozumiem"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Logowanie z nowego urządzenia",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Plik"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage(
      "Przechodzi powyżej ↑",
    ),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Spada poniżej ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Powiadom mnie, gdy cena",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("Włącz ten alert"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Proszę wprowadzić prawidłową cenę większą niż 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Usuń"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Ustaw alert"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Cena docelowa (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("Aktualizuj alert"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Tokeny można wysyłać tylko w tej samej sieci. Wysłanie z innych sieci może spowodować utratę środków.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj, aby otrzymać",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Wprowadź adres URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage("Wprowadź opis"),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Przeglądarka"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Wyczyść pamięć podręczną przeglądarki",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Automatycznie połącz z DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage(
      "Zamknij wszystkie",
    ),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Gotowe"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Historia"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Wyczyść całą historię",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Wyczyścić całą historię przeglądania?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage(
      "Historia wyczyszczona",
    ),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Dzisiaj"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Wczoraj"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Odkryj DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Popularne"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Most"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Zakładki"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Narzędzia"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Nie dodano jeszcze zakładek",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Zakładka"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nazwa"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("Wprowadź nazwę"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("Adres URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Opis"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Zgadzam się"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Wiadomość została usunięta",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transakcje"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Połącz"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage("Dostępne sieci"),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Podpis wiadomości",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Łączenie"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Parowanie, proszę czekać.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Rozłącz"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Odrzuć"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage(
      "Zablokowany",
    ),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Uwaga"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Bezpieczny"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Zweryfikowano",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage(
      "Wyślij kod ponownie",
    ),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Wskazówki dotyczące skanowania biometrycznego",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj odcisk palca lub twarz do uwierzytelnienia.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Wskazówki"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Aby ustawić"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj twarz lub odcisk palca, aby kontynuować.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Powrót"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod QR aplikacją Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Lub wprowadź klucz ręcznie:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Wprowadź 6-cyfrowy kod weryfikacyjny",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator wymagany do potwierdzenia każdego przelewu.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy kod, spróbuj ponownie",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator nie jest skonfigurowany",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Powiązanie zakończone sukcesem",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Aktualności"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Weryfikacja"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Zaproś znajomego"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Anulowano"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Sprawdź połączenie sieciowe i spróbuj ponownie",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Brak dostępnych produktów",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Przywróć zakupy"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Przywracanie zakupów…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Spróbuj ponownie"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Sklep niedostępny",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Kup"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Nie udało się usunąć!"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Limit gazu"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Brak więcej"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Ładowanie "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Książka adresowa"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Importuj portfel"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Zarządzaj"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Nowy adres"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Usuń"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Zapisz"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Kopiuj"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Utwórz/Importuj portfel"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Motyw"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Systemowy"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Jasny"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Ciemny"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Lista portfeli"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Brak danych"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Nieprawidłowa kwota"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portfel główny"),
    "g_key_140": MessageLookupByLibrary.simpleMessage(
      "Transakcja zakończona sukcesem",
    ),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Nieprawidłowe hasło"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Sieć testowa"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Sieć główna"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Język systemowy"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Ustaw jako portfel główny",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Adres portfela"),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj, aby skopiować adres",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Dodaj"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Wybierz portfel do weryfikacji",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Symbol"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Wklej"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Wybierz sieć"),
    "g_key_175": MessageLookupByLibrary.simpleMessage(
      "Transakcja nie powiodła się",
    ),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "To jest mój adres portfela",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Inne"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Zapisano pomyślnie"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Sukces"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz usunąć portfel?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Aktywny"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Brak uprawnień do dostępu do kamery.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Eksplorator"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Maks."),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Aktywa"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Rejestr jest pusty!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Przegląd transakcji"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Błąd połączenia, zeskanuj ponownie kod QR.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Edycja hasła"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Stare hasło"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Synchronizowanie sald...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Klucz prywatny"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Wprowadź hasło portfela"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Błąd klucza prywatnego"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Informacje rynkowe"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage("Hasła nie są zgodne."),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Saldo"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Nie udało się dodać!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Odbierz"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Wyślij"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("Do"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Zeskanuj kod QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Wprowadź adres portfela"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Dostępne saldo"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Kwota"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Niewystarczające środki na pokrycie tej transakcji.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Wyślij"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Nie udało się załadować!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Portfel"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Utwórz"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("Od"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Potwierdź"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Anuluj"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Wszystkie tokeny"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Ustawienia"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Konto utworzono pomyślnie",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Szczegóły konta",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Nazwa konta",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Wpisz nazwę konta",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage("Typ konta"),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Aktywny"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Dodaj swoją pierwszą operację",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Dodaj operację",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Obliczanie adresu...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Nie udało się obliczyć adresu. Spróbuj ponownie.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Zatwierdź"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Partia"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Atomowa egzekucja",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Wykonuj wiele operacji na raz",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Wyślij wiele transakcji w jednej operacji",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "Wykonanie wsadowe nie powiodło się",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Brak zapisanych szablonów",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Operacje wsadowe",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Oszczędzaj gaz",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Zapisz jako szablon",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Przesyłanie...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Partia przesłana pomyślnie",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Załaduj szablon",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nazwa szablonu",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Wprowadź nazwę szablonu",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Szablon został zapisany",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage(
      "Szablony",
    ),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transakcja zbiorcza",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Zatwierdź i zamień w jednej transakcji — koniec z dwuetapowymi potwierdzeniami",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Akcje zbiorcze jednym kliknięciem",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsoruj transakcje lub płać opłaty za pomocą tokenów ERC-20 zamiast ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Zapłać za gaz dowolnym żetonem",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Odzyskaj dostęp poprzez zaufane kontakty, jeśli zgubisz klucz prywatny",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Odnowa społeczna",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Modułowe konto smart ERC-7579 z obsługą bezgasowych transakcji",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("przez"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Łańcuch"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage(
      "Identyfikator łańcucha",
    ),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Zmień"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Sprawdź stan",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Już wkrótce"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "To jest adres alternatywny. Zostanie wdrożony podczas Twojej pierwszej transakcji.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Utwórz inteligentne konto",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Utwórz swoje pierwsze inteligentne konto",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Utwórz klucz sesji",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Utworzono"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Niestandardowe"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Konto zostanie wdrożone automatycznie przy pierwszej transakcji",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Wdrożony"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Wdrażam..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Wdrożenie nastąpi automatycznie przy pierwszej transakcji.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Poznaj następną generację kont Ethereum z ulepszonymi funkcjami",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Szczegóły"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrydowe konto EOA/inteligentne — nie wymaga wdrażania",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Błąd"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Szacowany gaz",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Wykonaj partię",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Wygasło"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Wygasa"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Fabryka"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("BEZPŁATNE"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Oszacowanie gazu nie powiodło się, przy użyciu ustawień domyślnych",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Płatność za gaz",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Opcje płatności za gaz",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorowany gaz",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Bezgazowy"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transakcje bezgazowe i operacje wsadowe",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Konto modułowe z obsługą wtyczek od ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Etykieta"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Ostatnia aktywność",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Moje inteligentne konta",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Nie ma jeszcze kont inteligentnych",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Żadne konta nie pasują do wybranego filtra",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Nie dodano żadnych operacji",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Brak kluczy sesyjnych",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Nie wdrożono",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Utwórz inteligentne konto (bezpłatne, nie wymaga ETH)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Zafunduj to — otrzymaj dowolny token EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Transakcje bez gazu z Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Operacje"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Właściciel"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Płać za benzynę żetonem",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Płać za benzynę swoim ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage(
      "Zapłać za pomocą",
    ),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage("Zapłać ETH"),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "sieci obsługiwane",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Sprawdzanie dostępności...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Zasięg chain",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Wybierz sposób płatności za opłaty za gaz transakcyjny",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Szac. koszt",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Nie można załadować opcji gazu",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Ponów próbę",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Oczekujące"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Pozwolenie"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Podgląd adresu",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Gotowy"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Odbierz adres",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Spróbuj ponownie"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Odwołaj"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz unieważnić ten klucz sesji? Autoryzowany DApp nie będzie już mógł wykonywać transakcji.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Unieważnij klucz sesji",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Klucz sesji unieważniony",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage(
      "Unieważnione",
    ),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Odwoływanie klucza sesji...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Konto z wieloma podpisami i zaawansowanymi funkcjami bezpieczeństwa",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("zapisane"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Wybierz opcję Łańcuch",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Wybierz opcję Płatnik",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Wybrane"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Wysyłaj tokeny za pomocą swojego inteligentnego konta",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 dzień"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 godzinę"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 dni"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 dni"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "np. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Maks. kwota",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Rozumiem uprawnienia tego klucza",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interakcja z zatwierdzonymi kontraktami DApp",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Nie udało się utworzyć klucza sesji",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Klucz sesji utworzony",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "np. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Etykieta / Nazwa DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Szczegóły klucza sesji",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Ważne przez",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Wysokie ryzyko — tylko zaufane DApp",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Klucze sesji",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autoryzuj DApps z tymczasowym dostępem do Twojego inteligentnego konta",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Dostęp DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Pełna kontrola",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Tylko wysyłanie",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Wysokie ryzyko",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Niskie ryzyko",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Średnie ryzyko",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Sprawdź uprawnienia przed potwierdzeniem",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Wybierz poziom uprawnień",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Prześlij tokeny w ramach limitu",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Podstawowe konto inteligentne z jednym właścicielem - zalecane dla większości użytkowników",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Inteligentne konta",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Inteligentny portfel",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Limit wydatków",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorowane (bezpłatne)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Inteligentne konto",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Całkowity gaz"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Transakcje"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage(
      "Zobacz wszystko",
    ),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Adres"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage("Wprowadź nazwę"),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage("Wprowadź adres"),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Wybierz typ monety",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Edytuj adres"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Usunięto pomyślnie",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Wybierz monety"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Szukaj monet"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Zaawansowane funkcje",
    ),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Dodaj odbiorcę",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Nadawanie...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Wyczyść wszystko",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Potwierdź transfer zbiorczy",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Kontynuuj"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Format CSV: adres,kwota,etykieta",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Gotowe"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Szacowanie gazu...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Transfer wsadowy obsługuje tylko łańcuchy EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Eksportuj CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Pomoc dotycząca transferu zbiorczego",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importuj CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Notatka jest opcjonalna",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Skorzystaj z Multicall3, aby uzyskać niższe opłaty za gaz",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Brak obsługiwanych tokenów",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage("Odbiorcy"),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Wybierz Token",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Wysyłaj tokeny na wiele adresów w jednej transakcji",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage(
      "Podpisywanie...",
    ),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Przesuń w lewo, aby usunąć odbiorcę",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transfer zbiorczy",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Łączna kwota",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Łańcuch nie jest obsługiwany",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Najtańszy"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Otrzymasz (szacunkowo)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Najszybszy"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Pobierz wycenę",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Historia mostów",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Brak dostępnych tras",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Zalecane",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Odśwież"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Trasa"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Szukaj sieci...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Wybierz"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Wybierz token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Poślizg"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Ukończono",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Nie udało się",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "W toku",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Oczekujące",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Most"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Most nieudany",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transakcja w toku",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Most zakończony sukcesem",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Zablokowane do",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Przed przesłaniem realizacji sprawdź, czy upłynął okres blokady.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC nadal zablokowane",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Zrealizuj vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Odblokowany — gotowy do wykorzystania",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Rozumiem ryzyko i chcę kontynuować",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Kontynuuj Stawka",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Jak to działa",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC będzie zablokowany do czasu wygaśnięcia blokady czasowej. Zakończ proces tyczenia w interfejsie poniżej.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Twoje BTC zostaną zablokowane na cały okres obstawiania. Wcześniejsza rezygnacja nie jest możliwa.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Blokada jest wymuszana przez Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) i nie można jej ominąć.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Ryzyko inteligentnych kontraktów: pomimo audytu żaden protokół nie jest całkowicie wolny od ryzyka.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Minimalna stawka: 0,001 BTC. Minimalny okres blokady: 0,125 dnia (~3 godziny).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Ostrzeżenie o ryzyku",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Twoje BTC są zamknięte na adresie multisig 2 z 2 z blokadą czasową (CLTV), zabezpieczone Twoim kluczem i kluczem kanistrowym N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Zablokuj swoje BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Po potwierdzeniu w łańcuchu vBTC zostanie wybity w Twoim portfelu w stosunku 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Mennica vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Trzymaj vBTC, aby zdobywać nagrody za stakowanie. vBTC można również używać w protokołach DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Zdobywaj nagrody",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Po wygaśnięciu okresu blokady spal swoje vBTC, aby otrzymać z powrotem oryginalne BTC.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Wykorzystaj po odblokowaniu",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Samodzielne stakowanie BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage("Rozumiem"),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Wybierz token z obsługą NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Przejdź do zakładki NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Wybierz NFT, który chcesz nagrać",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Naciśnij przycisk „Nagraj”.",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Kroki:"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Aby nagrać NFT, przejdź do strony szczegółów NFT i naciśnij przycisk „Nagraj”.",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Ta sieć nie obsługuje jeszcze transferów, bądź na bieżąco",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Wszystkie aktywa są poniżej 1 dolara",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Inne aktywa",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Kliknij, aby pokazać wszystko",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage(
      "Najnowsze",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Zatwierdzone! Kliknij Zamień, aby kontynuować.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Dokładna kwota",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Nieograniczone",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Nieograniczone zatwierdzenie: router może w dowolnym momencie wydać ten token. Standardowa praktyka, ale ryzykowna w przypadku naruszenia kontraktu.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage(
      "Zatwierdzanie…",
    ),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Najlepsza Trasa",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Najlepsze Źródło",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Łańcuch"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Potwierdź Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Szacunek Gazu",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Historia DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Min. Otrzymano",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Brak tokenów"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono tokenów",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Wykres ceny",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Wpływ na Cenę",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Wycena nieudana",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Szukaj symbolu / nazwy / adresu",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Wybierz"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Maksymalny poślizg",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Potwierdzone",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Nieudane"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "Oczekujące",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage(
      "Wycenione",
    ),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Zamień"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap pomyślnie przesłany",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Płacisz"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Otrzymujesz",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Produkty aktywne",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Transfer zbiorczy",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Spalić"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Kup N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Kup N za pomocą protokołu AST",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transfer międzyłańcuchowy",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Wymiana DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Księga"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Ładowanie APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Wydobycie"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Zarabiaj więcej"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Rodzime stakowanie Solany",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Brak aktywnych pozycji",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Zdobywaj nagrody uczestnicząc w wydobyciu węzłów",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Szybkie narzędzia",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage("Zalecane"),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Wybierz typ wymiany",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Postaw ETH z Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Wymień"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Zarabiaj"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Całkowite zarobki",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Zobacz wszystko",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Rozwiązany adres został zaktualizowany",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Zaawansowane"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Opłata roczna",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Dostępne"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage(
      "Cena podstawowa",
    ),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Sprawdzam dostępność...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("Popełnij"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "Zatwierdzenie nie powiodło się",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Zobowiązanie rejestracyjne wygasło. Proszę ponownie rozpocząć proces rejestracji.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "Popełnianie...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Potwierdź odnowienie",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Potwierdź i wyślij",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Potwierdź rozdzielczość ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Adres skopiowany",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Aktualny termin ważności",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "pozostało dni",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Zarejestruj i zarządzaj swoimi nazwami domen .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Wykryto nazwę ENS",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Wygasło"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Wygasa"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Przedłużenie okresu rejestracji",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Nie udało się"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalizowanie rejestracji",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Zacznij od ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Zdobądź swoją nazwę .eth",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy adres (musi mieć wartość 0x + 40 znaków szesnastkowych)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowa nazwa ENS",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "jest teraz Twój!",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Podczas rejestracji należy pozostawić aplikację otwartą",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Zarządzaj swoją tożsamością Web3",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 znaki",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage("Moje domeny"),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nazwa EN"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Nowe wygaśnięcie",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Adres nowego właściciela",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Nie ma jeszcze domen",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Właściciel"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Proszę czekać",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nazwa premium",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Podział cen",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Podstawowy"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nazwa podstawowa została pomyślnie ustawiona",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Przetwarzanie...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "Zarejestruj się",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage(
      "Zarejestruj się",
    ),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Twoja zdecentralizowana tożsamość w Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "Rejestracja nie powiodła się",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Zarejestruj się teraz",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Rejestracja...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Informacje rejestracyjne",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Okres rejestracji",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Włącz przypomnienie o wygaśnięciu",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Powiadom 30, 7 i 1 dzień przed wygaśnięciem",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Odnów"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Przedłuż rejestrację domeny",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Odnowienie zakończone sukcesem",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Ustalony adres",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Rozwiązanie problemu ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Szukaj"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Znajdź dostępne nazwy .eth",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Wyszukaj nazwę .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Wprowadź nazwę ENS, aby wyszukać",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Wyszukaj i zarejestruj się",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Wyszukaj ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Nie można wysłać na własny adres",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Usługa nazw Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Ustaw jako podstawowy",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nazwa standardowa",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij rejestrację",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Krok 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Krok 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Krok 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Utwórz subdomenę",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Subdomena utworzona",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Usuń subdomenę",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Ta subdomena zostanie trwale usunięta.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Subdomena usunięta",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Nie ma jeszcze subdomen",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Używaj wyłącznie liter, cyfr i łączników",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Etykieta subdomeny",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "np. blog, poczta, aplikacja",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Adres właściciela",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Pozostaw puste, aby użyć bieżącego portfela",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage("Subdomeny"),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Sukces!"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage("Sugestie"),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Zapisy tekstowe",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Menedżer ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Razem"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Przeniesienie"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Przenieś własność na inny adres",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfer udany",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Transfer jest nieodwracalny. Upewnij się, że adres nowego właściciela jest poprawny.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Spróbuj innej nazwy",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "Rejestracja w ENS jest procesem dwuetapowym",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Niedostępne",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Poczekaj"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Okres oczekiwania zapobiega atakom z przodu",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Okres oczekiwania zapobiega przedwczesnemu bieganiu",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Czekam..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Przed kontynuowaniem sprawdź rozwiązany adres. Nazwy ENS mogą być przenoszone lub zmieniane przez ich właścicieli.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("rok"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("lata"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Twoja tożsamość",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Błąd przetwarzania danych odpowiedzi!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Błąd Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Błąd składni żądania",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Brak autoryzacji, zaloguj się",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Odmowa dostępu"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Błąd żądania"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Przekroczono limit czasu żądania",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Błąd serwera"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Usługa nie została zaimplementowana",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Błąd bramy"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Usługa niedostępna",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Przekroczono limit czasu bramy",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Wersja HTTP nie jest obsługiwana",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "Żądanie nie powiodło się, kod błędu:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "System jest zajęty, spróbuj ponownie później",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Zbyt częste żądania",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage(
      "Dekodowanie nie powiodło się",
    ),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "Transakcja jest już w łańcuchu bloków",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Błąd konfiguracji certyfikatu!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Błąd konfiguracji kodu statusu!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Nieznany błąd!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Przekroczono limit czasu połączenia sieciowego, sprawdź ustawienia sieci!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Serwer jest niedostępny. Spróbuj ponownie później!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Żądanie zostało anulowane, spróbuj ponownie!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Eksportuj keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Wskazówki dotyczące kopii zapasowej",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Użyj menedżera haseł do przechowywania.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Skopiowano"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Kopiowanie anulowane",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Portfel tożsamości",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Zaszyfrowany plik klucza prywatnego.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Metoda importu",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Plik keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Wprowadź informacje keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Eksportuj klucz prywatny",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Uzyskanie keystore i hasła daje posiadaczowi pełną kontrolę nad aktywami portfela.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Zapisz starannie i przechowuj w bezpiecznym miejscu. Przechowywanie wielu fizycznych kopii jest najbezpieczniejszą metodą.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Jeśli klucz prywatny zostanie utracony, nie można go odzyskać. Utwórz fizyczną kopię i przechowuj ją bezpiecznie.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Zapisz offline",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Nie zapisuj w żadnej skrzynce pocztowej, notatniku, dysku sieciowym ani komunikatorze, który nie jest bezpieczny.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Proszę użyć transmisji sieciowej",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Upewnij się, że przesyłasz go za pomocą narzędzi sieciowych. Gdy hakerzy go zdobędą, spowoduje to nieodwracalne straty ekonomiczne",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Użyj narzędzi do zapisania",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Rozumiem, że każdy, kto uzyska ten plik i hasło, ma pełną kontrolę nad moimi środkami — strata jest trwała i nieodwracalna",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło portfela, aby potwierdzić eksport",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło portfela, aby wyświetlić klucz prywatny",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtruj"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Alarm gazowy"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Ostrzegaj, gdy jest powyżej",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Ostrzegaj, gdy poniżej",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Zapisz"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Próg (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Opłata bazowa"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Niestandardowe"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Szybko"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Ceny gazu zmieniają się w zależności od zapotrzebowania sieci. Niższy gaz = wolniejsze potwierdzenie, wyższy gaz = szybsze potwierdzenie.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage(
      "Maksymalna opłata",
    ),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Sieć przeciążona",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Sieć wolna",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Sieć normalna",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Trend cenowy",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Opłata priorytetowa",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Ceny gazu w czasie rzeczywistym",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Ustawienia Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Wolno"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standardowo"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Śledzenie gazu"),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Konto już zaimportowane",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Dodaj"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("Dodaj konto"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adres skopiowany",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Przed połączeniem upewnij się, że urządzenie jest odblokowane i włączona jest funkcja Bluetooth.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Sprawdź aplikację",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Podłącz nowe urządzenie",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Szczelina powietrzna z Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Połącz księgę rachunkową (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Podłącz Trezora (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Połączono"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("Łączenie..."),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Rozłącz"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Powrót"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Podłącz Keystone\'a",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj ten kod QR za pomocą urządzenia Keystone, aby podpisać transakcję",
    ),
    "g_key_hw_keystone_scan_response_hint":
        MessageLookupByLibrary.simpleMessage(
          "Skieruj aparat na kod QR wyświetlony na urządzeniu Keystone",
        ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Zeskanuj podpis Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod QR z urządzenia Keystone, aby zaimportować konta",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Stuknij, aby przeskanować reakcję Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage(
      "Załaduj więcej",
    ),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Ładowanie kont...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Potwierdź na urządzeniu jeśli wymagane",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono kont",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "Żadna aplikacja nie jest obecnie otwarta",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Urządzenie niepodłączone",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Brak połączenia",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Usuń"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Usuń urządzenie",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Zapisane urządzenia",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Obsługiwane urządzenia",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Dzisiaj"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Nie udało się połączyć z Trezorem. Upewnij się, że USB jest podłączone.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Połącz Trezora",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor połączył się pomyślnie",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Łączę się z Trezorem...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Podłącz urządzenie Trezor kablem USB i odblokuj je",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Zobacz konta",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Konta Portfela",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Wczoraj"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Portfel bieżącej waluty już istnieje.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Nie można odczytać keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Magazyn kluczy"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Zaloguj się"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Wyloguj się"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz wyjść z aplikacji?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebooku"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitterze"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Przeglądarka"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Niezgoda"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagrama"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Kapitalizacja rynkowa"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Wolumen obrotu"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Całkowita podaż"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("W obiegu"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("O"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Więcej"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Linki"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Strona internetowa"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Zarządzaj łańcuchami",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Dostępne"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Wymaga stakowania",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Wprowadź frazę odzyskiwania",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Suma"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nazwa"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Wstecz"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Transakcja przesłana",
    ),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy adres portfela",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Równowaga"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "To działanie jest nieodwracalne. NFT zostanie wysłany na adres nagrania.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Spalić NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Kolekcja"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Umowa"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("Opis"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Nie udało się załadować plików NFT. Kliknij, aby spróbować ponownie.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Wszystko"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Wideo"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Podłoga"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galeria NFT"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage("Napis #"),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono NFT",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Brak dostępnego łącza eksploratora",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Odtwarzanie wideo nie jest obsługiwane",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage(
      "Liczby porządkowe",
    ),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transfery liczb porządkowych nie są jeszcze obsługiwane",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Ilość"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Szukaj według nazwy lub kolekcji",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Wyślij NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transfery Solany NFT już wkrótce",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage(
      "Identyfikator tokena",
    ),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Wpisz"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Hasła nie pasują",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Wybierz z galerii telefonu",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Zresetuj"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Zachowaj ostrożność",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Sprawdzanie bezpieczeństwa umowy...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Wykryto wysokie ryzyko",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Umowa zweryfikowana jako bezpieczna",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage(
      "Notatka / Notatka",
    ),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Notatka / Notatka (opcjonalnie)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Udostępnij kod QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Udostępnij link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metoda udostępniania",
    ),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Transakcja prawdopodobnie się nie powiedzie",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Symuluję transakcję…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Symulacja transakcji zaliczona",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Symulacja niedostępna dla tej sieci",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Czat"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Aktywne"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Aktywne pozycje",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Kwota"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Kwota do wycofania",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("RRSO"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Średnia RRSO"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage("Prowizja"),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Szac. Codzienna nagroda",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Szac. Nagroda roczna",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Przejdź do Zamień",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Płynna stawka",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Płyn"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Twój płynny token może być przedmiotem obrotu bezpośrednio na DEX. Użyj Zamień, aby wymienić go z powrotem na zasób natywny.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Minimalny stake",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Brak aktywnych pozycji do odstawienia",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("Brak zamka"),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Nie ma jeszcze żadnych pozycji do obstawiania",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono walidatorów",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Adres portfela jest niedostępny",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Omówienie całkowitego obstawiania",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Moje pozycje",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protokoły"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Nagrody"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Wyszukaj walidatory...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Wybierz walidator",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Wybierz pozycję, którą chcesz odstawić",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Wybierz walidatora",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage(
      "Sortuj według",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Stakuj"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Postawione"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij stakowanie",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Stawianie"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transakcja przygotowana pomyślnie",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Odblokowywanie",
    ),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage(
      "Wycofaj stake",
    ),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Aktualizowanie...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Walidator"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Otrzymasz",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Zakończone"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Cena gazu"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Maks. opłata za gaz"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Maks. opłata za jednostkę gazu",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Oczekujące"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Niepowodzenie"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Kontynuuj"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Hasło portfela"),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe hasło portfela",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło portfela",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Stawka opłaty za gaz"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Średnia stawka opłaty za gaz ostatniego bloku",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Transfer wychodzący"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Wprowadź liczbę całkowitą większą niż 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Nie udało się pobrać danych",
    ),
    "g_key_t_45": m34,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Sprawdź konto adresu odbiorcy",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Znajdź"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Brak konta"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transfer przychodzący"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Nieprawidłowy adres"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Weryfikacja konta powiodła się",
    ),
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Adres odbiorcy nie ma konta, pierwszy transfer musi wynosić co najmniej 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Zużyty gaz"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("Dodaj"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Dodano token",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Odznacz wszystko",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono nowych tokenów",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignoruj",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Zaznacz wszystko",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Odkryte tokeny",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Historia transakcji"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Szczegóły transakcji",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Sprawdź potwierdzenia transakcji w historii",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Wydana kwota"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Otrzymana kwota"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Data rozpoczęcia",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Zakres dat",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Data zakończenia",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Kierunek",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Żadne transakcje nie pasują do wybranego filtra",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Znaleziono najnowszą wersję",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Aktualizuj teraz"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Znaleziono nową wersję",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Już masz najnowszą wersję",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Wyświetl frazę odzyskiwania",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Teraz spróbuj ponownie wprowadzić frazę odzyskiwania.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Importuj konto"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Utwórz konto"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage("Gotowe!"),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Możesz teraz w pełni korzystać ze swojego portfela.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Rozpocznij"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Pomiń na razie"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Możesz teraz pominąć tworzenie kopii zapasowej frazy odzyskiwania i zrobić to później w ustawieniach, jeśli będzie potrzeba.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Utwórz bezpośrednio",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "utworzono pomyślnie",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Jeśli chcesz sprawdzić szczegóły portfela lub wyeksportować keystore, przejdź do Pasek boczny > Zarządzaj portfelem",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Eksportuj mój keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Zabezpiecz swój portfel, tworząc kopię zapasową",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Keystore to repozytorium certyfikatów bezpieczeństwa i powiązanych kluczy prywatnych.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Krok 1: Przejdź do Zarządzaj portfelem.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Krok 2: Wybierz adres portfela.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Krok 3: Naciśnij Eksportuj keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Przejdź do Zarządzaj portfelem",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Powrót do strony głównej",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Dodaj portfel"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Utwórz portfel za pomocą frazy odzyskiwania.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Wprowadź nazwę portfela",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Nie utworzyłeś kopii zapasowej frazy odzyskiwania portfela!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Utwórz kopię teraz",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Ustaw hasło portfela",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Kopia zapasowa portfela",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Zapisz następującą frazę odzyskiwania",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Rozpocznij"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Urządzenia połączone z internetem mogą ujawnić Twoje informacje. Zalecamy zapisanie frazy odzyskiwania i bezpieczne jej przechowywanie.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Ostrzeżenie: Nie ujawniaj nikomu swojej frazy odzyskiwania. N42Wallet nigdy nie poprosi Cię o te informacje. Zachowaj szczególną ostrożność i przechowuj ją bezpiecznie offline. Jeśli Twoja fraza odzyskiwania zostanie ujawniona, możesz stracić wszystkie swoje aktywa i nie będziesz w stanie ich odzyskać.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Ostrzeżenie: Fraza odzyskiwania to jedyny sposób na odzyskanie aktywów portfela.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Następny krok"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Kliknij, aby wyświetlić frazę odzyskiwania",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Upewnij się, że w pobliżu nie ma innych osób ani kamer",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Potwierdź frazę odzyskiwania",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Informacje o portfelu",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Nazwa portfela"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Najpierw utwórz kopię zapasową frazy odzyskiwania portfela!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Sprawdź frazę odzyskiwania",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Teraz wprowadź swoją frazę odzyskiwania.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Ustaw frazę"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Upewnij się, że zapisałeś frazę odzyskiwania i przechowujesz ją bezpiecznie. Będziesz jej potrzebować do importu lub odzyskania portfela kryptowalutowego.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Edycja portfela",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Czas"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Wynik"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage("Hash transakcji"),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Dodaj"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Ścieżka"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Blok"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Wartość"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Chwilowo"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Przyspiesz"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Notatka"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Bieżący token nie został dodany.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Wprowadź frazę odzyskiwania ze słowami oddzielonymi spacjami",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importuj portfel",
    ),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Saldo bieżącego tokena jest niewystarczające.",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Błąd podpisu"),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Zarządzaj portfelem",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Wpisz adres Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Portfel przeznaczony tylko do zegarków nie może wysyłać ani podpisywać transakcji",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Obejrzyj Portfel",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Śledź dowolny adres EVM bez klucza prywatnego",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Zarezerwowane"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Rezerwa bazowa"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Rezerwa przyrostowa"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Liczba posiadanych obiektów",
    ),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Jak obliczyć całkowitą zarezerwowaną kwotę",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Całkowita rezerwa = Rezerwa bazowa + (Liczba posiadanych obiektów × Rezerwa przyrostowa)",
    ),
    "g_live_enter_room_failed": m45,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("Obserwuj"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "Funkcja obserwowania wkrótce",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID i Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Hasło gestowe"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("Ustaw hasło gestowe"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Narysuj swój wzór gestowy",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Potwierdź swój wzór gestowy",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Narysuj aktualny gest",
    ),
    "g_lock_key21": m46,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Zresetuj hasło gestowe",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Zbyt wiele nieudanych prób, spróbuj ponownie",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Dodać hasło portfela?",
    ),
    "g_lock_key25": m47,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Hasło gestowe nie jest ustawione",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Uwierzytelnienie gestowe wymagane do potwierdzenia każdego przelewu.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Sukces"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Niepowodzenie"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Rozpoznawanie biometryczne nie jest włączone",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Dodać weryfikację biometryczną?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("Zmiana 30D"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Zmiana 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Głębokość rynku"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Nie ma jeszcze listy obserwowanych",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Wysoka 24H"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Wynik Płynności",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Niski 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Wiadomości"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Brak danych wykresu",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("Brak wyników"),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Ranga"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Szukaj"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Szukaj monet...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Trendy"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Lista obserwowanych",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Wynik nieaktywności walidatora jest wysoki. Sprawdź status węzła, aby uniknąć kar.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Odblokować N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Aktywność weryfikacji w chmurze",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Ustawienia weryfikacji",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Muzyka weryfikacyjna w tle",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Domyślne"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Wycisz"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Gdy włączona jest weryfikacja w tle, w tle będzie odtwarzana muzyka. Jeśli muzyka ucichnie, weryfikacja również zostanie zatrzymana.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Twój poziom"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Konfiguracja wymaga niewielkiej ilości na opłatę za gaz.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Pomyślnie dołączyłeś do węzła grupowego w N42Wallet. Udostępnij link, aby zaprosić znajomych, aktywować węzeł i rozpocząć weryfikację!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Udostępnij znajomym",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Kontynuuj"),
    "g_mining_key63": m48,
    "g_mining_key73": m49,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Właśnie skonfigurowałem węzeł na @N42Wallet i rozpocząłem weryfikację na urządzeniach mobilnych! Dołącz do mnie. Zdecentralizowana przyszłość jest mobilna!",
    ),
    "g_mining_key76": m50,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Mineralny"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Węzeł"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Sieć"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Przełączaj się między siecią testową a siecią główną w celu eksploracji w chmurze.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Odbiór dostępny po 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Żądania przed tym czasem nie będą przetwarzane.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Dom"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Dzisiejsza nagroda",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Traktuj poniższe dane jak ważny klucz. Zalecamy natychmiastowe skopiowanie i utworzenie kopii zapasowej w zaufanej lokalizacji.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Kopiuj dane"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Nieaktywny"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Import zakończony sukcesem",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Zaszyfrowane dane nie mogą być puste!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Hasło nie może być puste!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Deszyfrowanie nie powiodło się. Sprawdź, czy hasło jest poprawne!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Nieobsługiwany format zaszyfrowanych danych!",
    ),
    "g_mining_key_109": m51,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Nagrody z wczoraj",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Zaszyfrowane dane",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Importuj pliki"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Wprowadź zaszyfrowane dane.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Importowanie..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Potwierdzenie"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Odbiór zajmuje trochę czasu, proszę chwilę poczekać!",
    ),
    "g_mining_key_116": m52,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Nagroda kumuluje się codziennie i jest wysyłana do Twojego portfela N tylko gdy osiągnie ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Łączne nagrody"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Wartość wydobyta"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Szczegóły zadania",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Podsumowanie"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Działania"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Całkowita wydobyta wartość",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage("Weryfikacja od"),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Liczba zysków"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage(
      "Zweryfikowana wartość",
    ),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Wybierz plany"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Okres odblokowania: Można odblokować w dowolnym momencie",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Maks. roczna nagroda",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Dystrybucja nagród",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Dzienny limit"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Prędkość"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Plany weryfikacji",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Wybierz metodę płatności",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Metody płatności"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage(
      "Zapłać za pomocą N",
    ),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Saldo portfela"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Nie masz wystarczającej ilości N na tę transakcję",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz pominąć?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Nie otrzymasz żadnych nagród weryfikacyjnych, dopóki nie wybierzesz 1 z planów.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Wyłączony"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Nagroda"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Zobacz więcej"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Status weryfikacji",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Aby odblokować"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Pomiń"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Ostatnie 7 dni"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Skumulowane nagrody",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Zablokuj N, aby rozpocząć weryfikację nagród.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Otrzymane nagrody",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Zaawansowane"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Podstawowy"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Zawodowiec"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("PEŁNY WĘZEŁ"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MIN/DZIEŃ"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage(
      "Węzeł zaawansowany",
    ),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Węzeł podstawowy"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Węzeł pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 bloków/dzień~70 min",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Odblokuj datę"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 bloków/dzień~15 min",
    ),
    "g_mining_key_71": m53,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 sekund na sprawdzenie",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "Sieć testowa jest aktualizowana i bloki nie mogą być tymczasowo weryfikowane.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Nieukończenie zadań przez cztery kolejne dni spowoduje brak zarobków i ryzyko kary.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Ocena ryzyka"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Odbierz"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Proszę najpierw zapisać parę kluczy publiczny/prywatny walidatora.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Eksportuj"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Dzisiejszy czas weryfikacji",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Niewystarczające środki na transfer.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Lista walidatorów",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Importuj walidatora",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Walidator już istnieje",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Niskie ryzyko"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Umiarkowanie ryzyko",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Nagrody z ostatnich 7 dni",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Wysokie ryzyko"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Kontrakt jest ładowany i nie można teraz przeprowadzić weryfikacji. Proszę chwilę poczekać!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Wskazówki bezpieczeństwa",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage("Weryfikacja w tle"),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Proszę bezpiecznie przechowywać klucz prywatny lub frazę odzyskiwania.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Klucz prywatny lub fraza odzyskiwania to jedyne dane uwierzytelniające dostęp do aktywów portfela.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Przechowuj je w bezpiecznym miejscu (papier, menedżer haseł itp.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Nie rób zrzutów ekranu, nie przesyłaj do internetu ani nie udostępniaj nikomu.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Po utracie lub ujawnieniu aktywów portfela nie można odzyskać.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Potwierdź i zapisz",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Ustaw hasło i zaszyfruj",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło szyfrowania",
    ),
    "g_mining_key_98": m54,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło ponownie, aby upewnić się, że jest poprawne",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Szczegóły Pełnego Węzła",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID Węzła"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Połączony"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Rozłączony"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Ponowne połączenie",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Wygaśnięcie"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Okres odblokowania:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Można odblokować w dowolnym momencie",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Brak dostępnych wiadomości",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Wróć (Bezpieczne)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Kontynuuj mimo to",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Ta strona internetowa została zidentyfikowana jako potencjalnie szkodliwa. Może próbować ukraść Twoje krypto aktywa lub klucze prywatne.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Ostrzeżenie Bezpieczeństwa",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "Podejrzany URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("Dodaj handel"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Średni koszt"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Cena zakupu (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage(
      "Podstawa kosztów",
    ),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Ilość"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Zapisz"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage(
      "Niezrealizowane zyski i straty",
    ),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24h Zmiana"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Wszystkie aktywa",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Alokacja aktywów",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Najlepsi zdobywcy",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Największe straty",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Przeprowadzki 24h",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Nie znaleziono żadnych zasobów",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Inni"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Łącznie"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portfel"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage(
      "Całkowita wartość",
    ),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("Dodaj wynik"),
    "g_pred_amount_input": m55,
    "g_pred_balance": m56,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Kup"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Anuluj i zwróć",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage("Tylko zamknij"),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Zamknięte, oczekiwanie na rozstrzygnięcie",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Potwierdź rozstrzygnięcie",
    ),
    "g_pred_confirm_resolve_msg": m57,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij prognozę",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Tworzenie…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Termin"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Co najmniej dwa poprawne wyniki",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Wprowadź pytanie",
    ),
    "g_pred_minutes": m58,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("Nie"),
    "g_pred_outcome_n": m59,
    "g_pred_outcome_win": m60,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Wyniki"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Wybierz zwycięski wynik do rozliczenia (środki wg wyniku)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Przetwarzanie…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Opublikuj"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Pytanie prognozy, np.: Kto wygra tę rundę?",
    ),
    "g_pred_quote_info": m61,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Rozstrzygnięte"),
    "g_pred_result_label": m62,
    "g_pred_sell_n": m63,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Bez limitu (ręczne zamknięcie)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Tak"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Pobrane"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Kod zaproszenia",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Zaproszeni"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Węzły górnicze"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Nagroda (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Klasyczne górnictwo (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Górnictwo (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Interfejs Górniczy",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Udostępnij"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Polecenie"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Poleć znajomych i zdobądź tokeny N!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("Otrzymujesz do "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N, gdy Twój polecony rozpocznie weryfikację!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Poleć przez"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Połączyć"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("kod"),
    "g_swap_key_14": m64,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Błąd pobierania ceny monety.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "Kontynuując, zgadzasz się z następującymi ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage("Regulaminem."),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Zakończ"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Twoja wymiana zostanie wkrótce zrealizowana. Prosimy o cierpliwość.",
    ),
    "g_swap_key_20": m65,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Koszty uruchomienia węzła: Weryfikacja grupowa 1-49 N Węzeł podstawowy: 50 N Węzeł premium: 100 N Węzeł pro: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Wygasa"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Nieopłacone"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Potwierdzanie płatności",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("Do dystrybucji"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage(
      "Podsumowanie wymiany",
    ),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Nowe saldo"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Płacisz"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Data"),
    "g_swap_key_31": m66,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Wymiany można przeglądać w odpowiednich eksploratorach sieci (Etherscan, BscScan, TRONSCAN i naszym własnym).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Wymień na N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Wymień"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Otrzymujesz"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Podgląd wymiany"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Spróbuj ponownie"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Kolor akcentujący",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Przywróć ustawienia domyślne",
    ),
    "g_token_m_key_1": m67,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Każdy może utworzyć token, w tym fałszywe wersje istniejących tokenów. Zawsze sprawdź token przed jego importem.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Tokeny"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Szukaj tokena"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Nazwa sieci"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Symbol sieci"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID sieci"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage(
      "Miejsca dziesiętne",
    ),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Dodaj niestandardową sieć",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 jednostek"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Dodaj tokeny"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Błąd formatu!"),
    "g_token_m_key_22": m68,
    "g_token_m_key_23": m69,
    "g_token_m_key_24": m70,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Importuj tokeny"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Wszystkie sieci"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Niestandardowy token",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Adres tokena"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Symbol tokena"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Miejsca dziesiętne tokena",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importuj"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Uwaga"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Wysokie Ryzyko"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Bezpieczne"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Później"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "Portfel HD · Mnemonik",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "Pojedynczy łańcuch · Zaimportowano",
    ),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Połączenie utracone. Proszę połączyć ponownie.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp rozłączył się",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Odłącz wszystkie",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Odłączyć od wszystkich DApps?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Odłączyć od tej DApp?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Brak aktywnych połączeń",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj kod QR, aby połączyć się z DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Żądanie połączenia wygasło",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Sesja wygasła",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("Połączone DApps"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "Zwykle wymagane przy wysyłce na giełdę",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(Opcjonalne)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Połącz",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Ważna informacja"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_password": MessageLookupByLibrary.simpleMessage("Hasło"),
    "next": MessageLookupByLibrary.simpleMessage("Dalej"),
    "nicknameMessage": m71,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Edytuj profil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Zdjęcie"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Wprowadź adres",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Nie przypominaj",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Później",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Przejdź do ustawień",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Powiadomienia push są wyłączone. Możesz przegapić wiadomości czatu i alerty o przelewach.\n\nWłącz powiadomienia dla tej aplikacji w ustawieniach systemowych.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Powiadomienia wyłączone",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło ponownie",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Wybierz hasło (8-18 znaków)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Potwierdź hasło",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("O aplikacji"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Bezpieczeństwo"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transakcja"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Język"),
    "search": MessageLookupByLibrary.simpleMessage("Szukaj"),
    "verification": MessageLookupByLibrary.simpleMessage("weryfikacja"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Jeśli stracę frazę odzyskiwania, moje środki zostaną utracone na zawsze.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Jeśli ujawnię lub udostępnię komukolwiek frazę odzyskiwania, moje środki mogą zostać skradzione.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Moim obowiązkiem jest bezpieczne przechowywanie frazy odzyskiwania.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowa fraza odzyskiwania.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Wprowadź frazę odzyskiwania portfela, który chcesz zaimportować.",
    ),
  };
}
