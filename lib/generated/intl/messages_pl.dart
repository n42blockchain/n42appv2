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

  static String m0(value) => "Jestem ${value}";

  static String m1(value) => "Członek czatu (${value})";

  static String m2(value) =>
      "Czy na pewno chcesz dodać ${value} jako znajomego";

  static String m3(value) =>
      "Zostałeś już powiązany i nie możesz się teraz ponownie powiązać. Adres powiązania: ${value}.";

  static String m4(value) => "Powiązanie udane. Adres powiązania: ${value}";

  static String m5(value) => "Brak sieci N42chain w portfelu ${value}!";

  static String m6(value) => "Dopasowanie udane. Adres:${value}.";

  static String m7(value) => "Kwota większa niż ${value}.";

  static String m8(value) =>
      "Portfel już istnieje, nazwa portfela to \"${value}\"";

  static String m9(value) => "Wprowadź kwotę większą niż ${value}.";

  static String m10(value) => "Czy na pewno chcesz usunąć kontakt ${value}?";

  static String m11(value) => "Nie masz wystarczającej ilości \"${value}\"";

  static String m12(value) => "Nie udało się pobrać konta \"${value}\"";

  static String m13(value) => "Minimum ${value} XRP dla pierwszego transferu";

  static String m14(value) => "Nie dodano sieci ${value}.";

  static String m15(value) =>
      "${value} ma niezakończone transakcje, spróbuj ponownie później.";

  static String m16(value) => "Nie znaleziono adresu dla ${value}.";

  static String m17(value) => "Niewystarczające saldo ${value}.";

  static String m18(value, value1) =>
      "Każde konto XRP musi zarezerwować ${value} XRP (${value1} drops) jako poziom bazowy, którego nie można wydać.";

  static String m19(value, value1) =>
      "Za każdy obiekt posiadany przez konto dodaje się ${value} XRP (${value1} drops) do rezerwy.";

  static String m20(value, value1) =>
      "To konto posiada ${value} obiektów, co oznacza dodatkową rezerwę ${value1} XRP.";

  static String m21(value) =>
      "Błąd wprowadzenia hasła wzorowego, masz ${value} prób";

  static String m22(value) =>
      "Błąd wprowadzenia hasła wzorowego, masz ${value} próbę";

  static String m23(value) =>
      "Pomyślnie skonfigurowałeś ${value} i rozpoczniesz weryfikację z N42Wallet!";

  static String m24(value) =>
      "Dołącz do mojej grupy ${value} na @N42Wallet, aby być wczesnym górnikiem sieci Layer 1 i zdobywać kryptowaluty na telefonie!";

  static String m25(value) => "Zablokuj ${value} N, aby uruchomić walidatora.";

  static String m26(value) => "Import nie powiódł się:${value}";

  static String m27(value, value1) =>
      "${value} N co ${value1} wydobytych bloków";

  static String m28(value) => "Musi mieć ${value} znaków";

  static String m29(value) => "Niewystarczające saldo ${value}.";

  static String m30(value) => "${value} w drodze...";

  static String m31(value) =>
      "${value} wymienione w aplikacji zostanie wkrótce przekazane do Twojego portfela i nie może być sprzedane w tym procesie. Może być używane do uruchomienia węzła.";

  static String m32(value) => "Maks. ${value} znaków";

  static String m33(value) =>
      "Sieć ${value} jest już obsługiwana przez aplikację!";

  static String m34(value) =>
      "Sieć ${value} jest już obsługiwana przez aplikację, czy chcesz ją dodać?";

  static String m35(value) =>
      "Test połączenia z adresem ${value} nie powiódł się!";

  static String m36(value) =>
      "Aplikacja zostanie odblokowana za ${value} sekund.";

  static String m37(value) =>
      "Błąd wprowadzenia hasła wzorowego, masz ${value} prób";

  static String m38(value) => "Błąd wprowadzenia hasła, masz ${value} prób";

  static String m39(value) => "Błąd wprowadzenia hasła, masz ${value} próbę";

  static String m40(value) => "Wprowadź hasło ${value}";

  static String m41(value) => "0~${value} znaków";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Zarejestruj się"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Utwórz swoje konto",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Edytuj"),
    "Verification": MessageLookupByLibrary.simpleMessage("Weryfikacja"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informacje o adresie",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Konto tymczasowo zablokowane na jeden dzień",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Kod jest nieprawidłowy. Spróbuj ponownie.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Skopiowano pomyślnie"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Kopiuj adres"),
    "descO": MessageLookupByLibrary.simpleMessage("Opis (opcjonalnie)"),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Edytuj zdjęcie"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Nie udało się uzyskać kodu weryfikacyjnego",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Kod weryfikacyjny wysłany pomyślnie, sprawdź swoją skrzynkę e-mail",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Błąd kodu weryfikacyjnego",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowy adres e-mail",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Weryfikacja adresu e-mail",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "Aplikacja weryfikatora adresu e-mail chroni Twoje wypłaty i konto N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Dodać weryfikację e-mail?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Plik"),
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
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Potwierdź połączenie z DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage(
      "Zamknij wszystkie",
    ),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Gotowe"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Zakładki"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Nie dodano jeszcze zakładek",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Zakładka"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nazwa"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage("Wprowadź nazwę"),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Opis"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Rozpocznij czat grupowy",
    ),
    "g_chat_key_10": m0,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Zaproś znajomych"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Wybierz kontakt"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Zakończ"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Wybierz co najmniej 2 kontakty",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage(
      "Szczegóły znajomego",
    ),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Szczegóły grupy"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Zobacz więcej członków grupy",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Nazwa grupy"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Nowy znajomy"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcemy rozwiązać grupę?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz opuścić tę grupę?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Rozwiąż grupę"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Opuść grupę"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Zmień nazwę czatu grupowego",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Gdy nazwa czatu grupowego zostanie zmieniona, inni członkowie zostaną powiadomieni w grupie.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Zakończ"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Prośba o dodanie znajomego",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Prośba o dodanie Cię jako znajomego",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Prośba o znajomość zaakceptowana",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Dodano"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Zostałeś dodany jako znajomy",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("zgadzam się"),
    "g_chat_key_32": m1,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Hasła nie można poprawnie przeanalizować i wiadomość nie może być tymczasowo wysłana. Proszę zaimportować portfel podczas wchodzenia do grupy",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Usunąć historię czatu?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Usuń członka"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Mój kod QR"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Wygasło"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Zgłoś"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("Nowy czat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Nowa grupa"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Kod QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("Zgłoś i zablokuj"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Ta wiadomość zostanie przekazana do N42Wallet. Ten kontakt nie zostanie powiadomiony.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Wideo"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Zdjęcie"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Usuń wiadomość"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Usuń na moim urządzeniu",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Czekaj"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Zgadzam się"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Powód zgłoszenia"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Wprowadź powód zgłoszenia",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Zweryfikujemy Twoje zgłoszenie i odpowiemy w ciągu 24 godzin.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Zgłosiłeś to - Kliknij, aby zobaczyć",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Czarna lista"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Usuń"),
    "g_chat_key_6": m2,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("Brak kontaktów"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Dzisiaj"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Ponad 3 dni temu"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Zablokuj"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Hej, używam N42Wallet do czatowania i wysyłania pieniędzy. Zainstaluj portfel i napisz do mnie na",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Odpowiedz"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Wiadomość została usunięta",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("Ktoś mnie oznaczył"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Przywitaj się"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Dodaj znajomych"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage("Powód zgłoszenia"),
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
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Wskazówki dotyczące skanowania biometrycznego",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj odcisk palca lub twarz do uwierzytelnienia.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Skanowanie biometryczne nie powiodło się",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Wskazówki"),
    "g_face_4": MessageLookupByLibrary.simpleMessage(
      "Skanowanie biometryczne zakończone sukcesem",
    ),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Aby ustawić"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Nie ustawiłeś logowania biometrycznego. Przejdź do ustawień systemowych, aby to ustawić.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Zeskanuj twarz lub odcisk palca, aby kontynuować.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Powrót"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Zaleca się ponowne włączenie biometrii.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Metoda dopasowania twarzy",
    ),
    "g_face_match_key10": m3,
    "g_face_match_key11": m4,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage(
      "Powiąż ponownie",
    ),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Powiąż"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Zweryfikuj"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Możesz bezpośrednio powiązać dane twarzy z adresem portfela (jeśli wcześniej powiązałeś, stary adres portfela zostanie nadpisany), lub jeśli wcześniej powiązałeś adres portfela, możesz również ręcznie zweryfikować, aby pobrać powiązany adres portfela.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "Wykryto adres portfela powiązany z Twoimi danymi twarzy, ale nie zaimportowałeś jeszcze tego portfela do listy portfeli.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Powiązałeś dane twarzy z tym portfelem.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Informacja dla użytkownika",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Co to jest powiązanie twarzy?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Powiązanie twarzy wykorzystuje technologię rozpoznawania twarzy do dopasowania biometrycznych cech twarzy do adresu portfela blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Ten proces nie tylko zwiększa wygodę transakcji, ale także wzmacnia bezpieczeństwo konta, zapewniając, że każda czynność jest autoryzowana przez Ciebie.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Dlaczego powiązanie twarzy jest konieczne?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "Poprzez powiązanie danych twarzy Twoja tożsamość jest bezpośrednio połączona z działaniami transakcyjnymi, upraszczając proces weryfikacji tożsamości i poprawiając efektywność operacyjną. Ta technologia zapewnia szybką i bezpieczną weryfikację tożsamości podczas wykonywania wrażliwych operacji, takich jak transfer aktywów lub interakcja z kontraktami.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Jak przechowywane są moje dane twarzy i czy są bezpieczne?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Twoje dane twarzy są przechowywane w zaszyfrowanej formie w publicznym łańcuchu bloków, a nie w żadnej scentralizowanej bazie danych. Oznacza to, że system może odszyfrować i użyć Twoich danych do weryfikacji tożsamości tylko po Twojej autoryzacji, zapewniając prywatność i bezpieczeństwo danych.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Jak powiązanie twarzy wpływa na bezpieczeństwo mojego konta?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Powiązanie twarzy zwiększa bezpieczeństwo konta, zapewniając, że wszystkie wrażliwe działania są wykonywane tylko za Twoją wyraźną autoryzacją. Używamy wiodącej w branży technologii szyfrowania do ochrony danych biometrycznych, zapobiegając nieautoryzowanemu dostępowi.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Czy moje dane twarzy są bezpieczne?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolutnie. Wszystkie dane biometryczne przechodzą ścisłe szyfrowanie, a podczas transmisji i przechowywania danych przestrzegane są najwyższe standardy bezpieczeństwa. System odszyfruje te dane tylko wtedy, gdy jest to konieczne do zakończenia weryfikacji tożsamości.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Dopasowanie nie powiodło się!",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Rozumiem"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Wybierz adres portfela",
    ),
    "g_face_match_key32": m5,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage(
      "Rozwiązywanie powiązania",
    ),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Weryfikacja danych twarzy nie powiodła się!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Rozwiązanie powiązania danych twarzy nie powiodło się!",
    ),
    "g_face_match_key4": m6,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Błąd adresu!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Powiązanie danych twarzy",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Dopasowanie twarzy",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage(
      "Wybierz ponownie",
    ),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Dopasuj"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Aktualności"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Weryfikacja"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Wiadomości"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Nauka"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Zaproś znajomego"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Nie udało się usunąć!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Wyślij"),
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
    "g_key_154": MessageLookupByLibrary.simpleMessage("Zatwierdź"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Brak uprawnień do dostępu do galerii zdjęć.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Edycja hasła"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Stare hasło"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Synchronizowanie sald...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Klucz prywatny"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Wprowadź hasło portfela"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Błąd klucza prywatnego"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Kup"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Sprzedaj"),
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("Uwagi"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Fraza odzyskiwania"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Wszystkie tokeny"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Ustawienia"),
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
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Nieprawidłowe konto lub hasło",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Błąd żądania"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Jesteś już zalogowany na innym telefonie i zostałeś wylogowany.",
    ),
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Opinia"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Wypełnij informacje zwrotne",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Są nieprzesłane załączniki",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Przesyłanie nie powiodło się",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Przesłano pomyślnie",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Załączniki"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Prześlij do 5 załączników, każdy załącznik nie może być większy niż 100MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Niepowodzenie"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Kliknij, aby spróbować",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Proszę się zalogować",
    ),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Portfel bieżącej waluty już istnieje.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Nie można odczytać keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Zaloguj się"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Wyloguj się"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz wyjść z aplikacji?",
    ),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Przeglądarka"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Kapitalizacja rynkowa"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Wolumen obrotu"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Całkowita podaż"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("W obiegu"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("O"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Więcej"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Linki"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Strona internetowa"),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Wprowadź frazę odzyskiwania",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Suma"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Kamera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Wybierz zdjęcie"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Treść"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nazwa"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Wstecz"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Transakcja przesłana",
    ),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Wybierz wideo"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Wybierz z galerii telefonu",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Udostępnij kod QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Udostępnij link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Metoda udostępniania",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Czat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Plik jest zbyt duży, aby go przesłać",
    ),
    "g_key_squad_k15": m10,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Dodaj kontakt"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Kontakt"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Szukaj po adresie e-mail",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Zakończone"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Cena gazu"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Maks. opłata za gaz"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage(
      "Maks. opłata za jednostkę gazu",
    ),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Oczekujące"),
    "g_key_t_29": m11,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Niepowodzenie"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Opłata górnicza"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Kontynuuj"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Hasło portfela"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Hasło portfela nie może być puste",
    ),
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
    "g_key_t_45": m12,
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
    "g_key_t_52": m13,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "Adres odbiorcy nie ma konta, pierwszy transfer musi wynosić co najmniej 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Zużyty gaz"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Historia transakcji"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Szczegóły transakcji",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Sprawdź potwierdzenia transakcji w historii",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Wydana kwota"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Otrzymana kwota"),
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Typy NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Obserwujący"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Typy użytkowników"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Strona internetowa"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Link do produktów"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Platformy medialne"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Adres portfela"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Pseudonim"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Przesyłanie awatara nie powiodło się",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Opis"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Informacje o artyście"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("Nie jesteś artystą"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Kliknij tutaj, aby złożyć wniosek o zostanie artystą",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Nazwa"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Przychód"),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "Przeczytałem i akceptuję ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("Regulamin"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Politykę prywatności i oświadczenie o zbieraniu danych osobowych",
    ),
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
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Upewnij się, że zapisałeś frazę odzyskiwania i przechowujesz ją bezpiecznie.",
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
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Przyspiesz"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Notatka"),
    "g_key_wallet_m1": m14,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Czy na pewno chcesz anulować swoje konto?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Potwierdź wylogowanie",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod weryfikacyjny Google.",
    ),
    "g_key_wallet_m19": m15,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Bieżący token nie został dodany.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Wprowadź frazę odzyskiwania ze słowami oddzielonymi spacjami",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importuj portfel",
    ),
    "g_key_wallet_m3": m16,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Saldo bieżącego tokena jest niewystarczające.",
    ),
    "g_key_wallet_m5": m17,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Błąd podpisu"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage("Anulowanie konta"),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod weryfikacyjny e-mail.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Zarządzaj portfelem",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Zarezerwowane"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Rezerwa bazowa"),
    "g_key_xml_11": m18,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Rezerwa przyrostowa"),
    "g_key_xml_22": m19,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Liczba posiadanych obiektów",
    ),
    "g_key_xml_33": m20,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Jak obliczyć całkowitą zarezerwowaną kwotę",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Całkowita rezerwa = Rezerwa bazowa + (Liczba posiadanych obiektów × Rezerwa przyrostowa)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID i Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Aktualne hasło"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("Nowe hasło"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Potwierdź nowe hasło",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6-cyfrowa liczba"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage("Hasła i biometria"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Hasło wzorowe"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage("Ustaw kod wzorowy"),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Dla bezpieczeństwa konta ustaw hasło grupowe",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Narysuj ponownie hasło wzorowe",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Narysuj hasło wzorowe",
    ),
    "g_lock_key21": m21,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Zresetuj hasło wzorowe",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Zbyt wiele nieprawidłowych prób, zresetuj hasło",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Dodać hasło portfela?",
    ),
    "g_lock_key25": m22,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage(
      "Strona blokady ekranu",
    ),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Automatyczna blokada"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Sukces"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Niepowodzenie"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Rozpoznawanie biometryczne nie jest włączone",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Dodać weryfikację biometryczną?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Zresetuj hasło"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Odblokować N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Aktywność weryfikacji w chmurze",
    ),
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
    "g_mining_key63": m23,
    "g_mining_key73": m24,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Właśnie skonfigurowałem węzeł na @N42Wallet i rozpocząłem weryfikację na urządzeniach mobilnych! Dołącz do mnie. Zdecentralizowana przyszłość jest mobilna!",
    ),
    "g_mining_key76": m25,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Odbiór dostępny po 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Żądania przed tym czasem nie będą przetwarzane.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Dzisiejsza nagroda",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Traktuj poniższe dane jak ważny klucz. Zalecamy natychmiastowe skopiowanie i utworzenie kopii zapasowej w zaufanej lokalizacji.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Kopiuj dane"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Nieaktywny"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Lista walidatorów",
    ),
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
    "g_mining_key_109": m26,
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
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Nagroda kumuluje się codziennie i jest wysyłana do Twojego portfela N tylko gdy osiągnie ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Łączne nagrody"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Wartość wydobyta"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Obliczone na podstawie ceny rynkowej N * łączne nagrody N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Liczba walidacji"),
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
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Wyłączony"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Zobacz więcej"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Status weryfikacji",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Zablokuj N, aby rozpocząć weryfikację nagród.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Podstawowy"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage(
      "Węzeł zaawansowany",
    ),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Węzeł podstawowy"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Węzeł pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 bloków/dzień~70 min",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Wybierz plan"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 bloków/dzień~15 min",
    ),
    "g_mining_key_71": m27,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 sekund na sprawdzenie",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Weryfikacja w chmurze rozpoczęta",
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
      "Umiarkowanie niskie ryzyko",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Umiarkowanie wysokie ryzyko",
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
    "g_mining_key_98": m28,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło ponownie, aby upewnić się, że jest poprawne",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Powiadomienia",
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
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("kod"),
    "g_swap_key_14": m29,
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
    "g_swap_key_20": m30,
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
    "g_swap_key_31": m31,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Wymiany można przeglądać w odpowiednich eksploratorach sieci (Etherscan, BscScan, TRONSCAN i naszym własnym).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Wymień na N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Wymień"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Otrzymujesz"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Podgląd wymiany"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Spróbuj ponownie"),
    "g_token_m_key_1": m32,
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
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Dodaj niestandardową sieć",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 jednostek"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Dodaj tokeny"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Błąd formatu!"),
    "g_token_m_key_22": m33,
    "g_token_m_key_23": m34,
    "g_token_m_key_24": m35,
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
    "g_unlock_key10": m36,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Rozpoznawanie odcisku palca lub twarzy nie jest włączone?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Narysuj hasło wzorowe",
    ),
    "g_unlock_key4": m37,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Wprowadź hasło"),
    "g_unlock_key6": m38,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Uwierzytelnianie nie powiodło się",
    ),
    "g_unlock_key8": m39,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Możesz również "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Weryfikacja Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Połącz",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Pobierz Google Authenticator",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Instrukcje",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Otwórz Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Na ekranie zobaczysz 6-cyfrowy kod weryfikacyjny.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Skopiuj 6-cyfrowy kod i wklej go w N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Następnie Twój Authenticator zostanie pomyślnie połączony.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Klucz zapasowy",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Skopiuj klucz do Google Authentication",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod weryfikacyjny Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod weryfikacyjny e-mail",
    ),
    "google_verification_message21": m40,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Nie udało się uzyskać klucza Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Uwierzytelnianie dwuskładnikowe (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Aby chronić swoje konto, zaleca się włączenie co najmniej jednego 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "Aplikacja Google Authenticator chroni Twoje wypłaty i konto N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Pobierz i zainstaluj",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Proszę pobrać i zainstalować Google Authenticator. Następnie naciśnij \"Połącz\", aby połączyć swoje konto N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Ważna informacja"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Zaloguj się"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Zapomniałeś hasła?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("Kod polecający"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Kod polecający",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage("Nie masz konta? "),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Utworzono pomyślnie",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Zresetowano pomyślnie",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage("Masz już konto? "),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Wyślij kod ponownie za ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Kod wysłany pomyślnie",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-mail niezarejestrowany",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Nie udało się wysłać kodu",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "proszę najpierw się zalogować",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Hasło"),
    "next": MessageLookupByLibrary.simpleMessage("Dalej"),
    "nicknameMessage": m41,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Hasła nie są zgodne",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Edytuj profil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Zdjęcie"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Wprowadź kod weryfikacyjny",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Wprowadź adres e-mail",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Wprowadź adres",
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
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Wprowadź hasło ponownie",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Wprowadź kod"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("Kod OTP"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Zresetuj swoje hasło",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Zarządzaj portfelem"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("O aplikacji"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Bezpieczeństwo"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Użyj nowego czatu"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Włącz ulepszone doświadczenie czatu",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Adresy portfela"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transakcja"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Język"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Motyw"),
    "search": MessageLookupByLibrary.simpleMessage("Szukaj"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Proszę przeczytać i potwierdzić regulamin",
    ),
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
