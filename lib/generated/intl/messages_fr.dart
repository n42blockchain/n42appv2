// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a fr locale. All the
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
  String get localeName => 'fr';

  static String m0(deviceName, os) =>
      "Votre compte vient d\'être connecté sur ${deviceName} (${os}). Si ce n\'était pas vous, nous vous recommandons de changer votre mot de passe.";

  static String m1(price) => "Prix actuel : \$${price}";

  static String m2(symbol) => "Alerte de prix · ${symbol}";

  static String m3(s) => "Renvoyer dans ${s}s";

  static String m4(message) => "Achat échoué : ${message}";

  static String m5(productId) => "Achat réussi : ${productId}";

  static String m6(productId) => "Restauré : ${productId}";

  static String m7(value) => "Montant supérieur à ${value}.";

  static String m8(value) =>
      "Le portefeuille existe déjà, le nom du portefeuille est \"${value}\"";

  static String m9(value) => "Entrez un montant supérieur à ${value}.";

  static String m10(value) => "Adresse en double à la ligne ${value}";

  static String m11(value) =>
      "Solde insuffisant : le montant total dépasserait le ${value} disponible";

  static String m12(value) => "Adresse invalide à la ligne ${value}";

  static String m13(value) => "Montant invalide à la ligne ${value}";

  static String m14(value) => "Maximum ${value} destinataires";

  static String m15(token) => "Approuver ${token} pour continuer";

  static String m16(impact) =>
      "Impact prix élevé (${impact}) ! Procédez avec prudence.";

  static String m17(secs) => "Le devis expire dans ${secs}s";

  static String m18(value) => "Gagnez jusqu\'à ${value}% APY";

  static String m19(value) =>
      "Actualisation automatique toutes les secondes ${value}";

  static String m20(address) => "Compte ${address} ajouté";

  static String m21(address, network) =>
      "Voulez-vous suivre ce compte de hardware wallet?\n\nAdresse: ${address}\nRéseau: ${network}";

  static String m22(app) => "Application actuelle : ${app}";

  static String m23(days) => "${days} il y a jours";

  static String m24(value) => "Échec de l\'importation du compte: ${value}";

  static String m25(date) => "Dernière connexion : ${date}";

  static String m26(app) =>
      "Assurez-vous que l\'application ${app} est ouverte sur votre Ledger";

  static String m27(name) =>
      "Êtes-vous sûr de vouloir supprimer « ${name} » des appareils enregistrés ?";

  static String m28(value) => "Gagnez ${value} points";

  static String m29(amount, symbol, network) =>
      "Demander ${amount} ${symbol} sur ${network}";

  static String m30(value) =>
      "Supprimer le réseau personnalisé ${value} ? Les soldes sur ce réseau ne seront plus affichés. Vos actifs sur la chaîne ne sont pas affectés.";

  static String m31(value) => "Est. gaz : ~${value} unités";

  static String m32(reason) => "Raison : ${reason}";

  static String m33(value) => "${value}d dissocier";

  static String m34(value) => "${value} jours restants";

  static String m35(value) =>
      "Le délocalisation prend des jours ${value}. Vos tokens seront verrouillés pendant cette période.";

  static String m36(value) => "Vous n\'avez pas assez de \"${value}\"";

  static String m37(value) => "Échec de la récupération du compte \"${value}\"";

  static String m38(value) => "Minimum ${value} XRP pour le premier transfert";

  static String m39(count) => "Ajouter (${count})";

  static String m40(count) =>
      "${Intl.plural(count, one: '1 nouveau jeton détecté', other: '${count} nouveaux jetons détectés')} — appuyez pour examiner";

  static String m41(value) => "Aucune chaîne ${value} ajoutée.";

  static String m42(value) =>
      "${value} a des transactions non terminées, veuillez réessayer plus tard.";

  static String m43(value) => "Aucune adresse trouvée pour ${value}.";

  static String m44(value) => "Solde insuffisant de ${value}.";

  static String m45(value, value1) =>
      "Chaque compte XRP doit réserver ${value} XRP (${value1} drops) comme base, qui ne peut pas être dépensé.";

  static String m46(value, value1) =>
      "Pour chaque objet que le compte possède, ${value} XRP (${value1} drops) est ajouté à la réserve.";

  static String m47(value, value1) =>
      "Ce compte possède ${value} objets, ce qui signifie qu\'un ${value1} XRP supplémentaire est réservé.";

  static String m48(message) => "Échec de l’entrée dans le salon\n${message}";

  static String m49(value) => "Schéma incorrect, ${value} tentatives restantes";

  static String m50(value) => "Schéma incorrect, ${value} tentative restante";

  static String m51(value) =>
      "Vous avez configuré avec succès un ${value} et commencerez la vérification avec N42Wallet !";

  static String m52(value) =>
      "Rejoignez mon groupe ${value} sur @N42Wallet pour être l\'un des premiers mineurs d\'une chaîne Layer 1, et obtenez des cryptos sur votre téléphone !";

  static String m53(value, value1) =>
      "Êtes-vous sûr de vouloir verrouiller ${value} N jusqu\'à ${value1} pour faire fonctionner un nœud ?";

  static String m54(value) => "Échec de l\'importation : ${value}";

  static String m55(value) =>
      "Un solde de staking d\'au moins ${value} est requis pour recevoir des récompenses.";

  static String m56(value, value1) =>
      "${value} N tous les ${value1} blocs minés";

  static String m57(value) => "Doit contenir ${value} caractères";

  static String m58(symbol) => "Montant (${symbol})";

  static String m59(amount, symbol) => "Solde : ${amount} ${symbol}";

  static String m60(label) =>
      "Déclarer « ${label} » gagnant et régler ? Action irréversible.";

  static String m61(n) => "${n} min";

  static String m62(n) => "Résultat ${n}";

  static String m63(label, pct) => "${label} gagne (${pct}%)";

  static String m64(shares, avg, after) =>
      "Est. ${shares} parts · moy ${avg}% · après ${after}%";

  static String m65(reason) => "Échec du rachat : ${reason}";

  static String m66(label) => "Résultat : ${label}";

  static String m67(n) => "Vendre ${n}";

  static String m68(value) => "Solde insuffisant de ${value}.";

  static String m69(value) => "${value} en cours de réception...";

  static String m70(value) =>
      "Les ${value} échangés dans l\'application seront distribués sous peu dans votre portefeuille et ne peuvent pas être vendus via ce processus. Ils peuvent être utilisés pour faire fonctionner un nœud.";

  static String m71(value) => "Maximum ${value} caractères";

  static String m72(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP !";

  static String m73(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP, voulez-vous l\'ajouter ?";

  static String m74(value) =>
      "Échec du test de connexion à l\'adresse ${value} !";

  static String m75(value) =>
      "L\'RPC indique l\'ID de chaîne ${value}, qui ne correspond pas à la valeur que vous avez saisie.";

  static String m76(asset, contract, address) =>
      "L\'actif ${asset} (${contract}) n\'a pas été ajouté au compte ${address}.";

  static String m77(imported, skipped) =>
      "Portefeuilles importés : ${imported}. Ignorés : ${skipped}.";

  static String m78(value) => "Solde : ${value}";

  static String m79(value) => "Frais de base : ${value} Gwei";

  static String m80(value) =>
      "Presse-papiers effacé automatiquement dans ${value}s";

  static String m81(value) => "Ligne ${value} : champs manquants";

  static String m82(value) => "${value}j";

  static String m83(value) => "Connecté à ${value}";

  static String m84(value) => "Frais réseau : ${value}";

  static String m85(value) => "${value}h";

  static String m86(value) => "Destinataires importés valides (${value})";

  static String m87(quote, base) => "Prix limite (${quote} par ${base})";

  static String m88(value) => "Limite ${value}";

  static String m89(value) => "Marchés (${value})";

  static String m90(value) => "Solde minimum : ${value}";

  static String m91(value) => "Ordres (${value})";

  static String m92(value) => "Positions (${value})";

  static String m93(value) => "Destinataires : ${value}";

  static String m94(value) => "Jetons trouvés : ${value}";

  static String m95(value) => "Jetons : ${value}";

  static String m96(value) => "Opération : ${value}";

  static String m97(valid, issues) =>
      "Valide : ${valid}. Problèmes : ${issues}.";

  static String m98(value) => "… et ${value} problème(s) supplémentaires";

  static String m99(volume, interest) => "Vol : ${volume} · OI : ${interest}";

  static String m100(value) => "Portefeuille ${value}";

  static String m101(value) => "Mis à jour il y a ${value}h";

  static String m102(value) => "Mis à jour il y a ${value}m";

  static String m103(value) => "0~${value} caractères";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "Verification": MessageLookupByLibrary.simpleMessage("Vérification"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informations de l\'adresse",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copié avec succès"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copier l\'adresse"),
    "descO": MessageLookupByLibrary.simpleMessage("Description (facultatif)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Changer le mot de passe",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Compris"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "Nouvelle connexion",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Fichier"),
    "g_aggregate_cached_balance": MessageLookupByLibrary.simpleMessage(
      "Solde sauvegardé · échec du rafraîchissement",
    ),
    "g_aggregate_known_balance": MessageLookupByLibrary.simpleMessage(
      "Solde connu",
    ),
    "g_aggregate_mainnet_note": MessageLookupByLibrary.simpleMessage(
      "Soldes du réseau principal uniquement. Les requêtes réseau manquantes ou échouées ne sont pas comptées comme des soldes nuls.",
    ),
    "g_aggregate_network_balances": MessageLookupByLibrary.simpleMessage(
      "Soldes par réseau",
    ),
    "g_aggregate_no_mainnet": MessageLookupByLibrary.simpleMessage(
      "Aucun compte principal actif pour ce réseau",
    ),
    "g_aggregate_not_loaded": MessageLookupByLibrary.simpleMessage(
      "Solde non chargé",
    ),
    "g_aggregate_open_network": MessageLookupByLibrary.simpleMessage(
      "Ouvrir le réseau",
    ),
    "g_aggregate_unavailable": MessageLookupByLibrary.simpleMessage(
      "Cet actif n\'est plus disponible dans le portefeuille sélectionné. Retournez au portefeuille pour choisir un actif.",
    ),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Va au-dessus ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage(
      "Gouttes ci-dessous ↓",
    ),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Alertez-moi quand le prix",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage(
      "Activer cette alerte",
    ),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir un prix valide supérieur à 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Définir une alerte"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Prix indicatif (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage(
      "Alerte de mise à jour",
    ),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Les jetons ne peuvent être envoyés que sur le même réseau. L\'envoi depuis d\'autres réseaux peut entraîner une perte.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Scanner pour recevoir",
    ),
    "g_audit_aa_history_external": MessageLookupByLibrary.simpleMessage(
      "Ouvrir l\'explorateur de blocs pour visualiser l\'activité sur la chaîne de ce compte intelligent.",
    ),
    "g_audit_about_desc": MessageLookupByLibrary.simpleMessage(
      "Version, site web et assistance",
    ),
    "g_audit_activity_error": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger l\'historique des opérations.",
    ),
    "g_audit_activity_local": MessageLookupByLibrary.simpleMessage(
      "Historique des opérations locales sur vos portefeuilles. Ouvrez un actif pour synchroniser ses dernières activités.",
    ),
    "g_audit_all": MessageLookupByLibrary.simpleMessage("Tout"),
    "g_audit_approval_spender": MessageLookupByLibrary.simpleMessage(
      "Autorisation de dépense pour",
    ),
    "g_audit_approval_token": MessageLookupByLibrary.simpleMessage(
      "Contrat de jeton",
    ),
    "g_audit_batch": MessageLookupByLibrary.simpleMessage("Transfert par lots"),
    "g_audit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Envoyer à plusieurs destinataires ou importer un fichier CSV",
    ),
    "g_audit_biometrics": MessageLookupByLibrary.simpleMessage(
      "Authentification biométrique",
    ),
    "g_audit_biometrics_desc": MessageLookupByLibrary.simpleMessage(
      "Paramètres de Face ID / empreinte digitale",
    ),
    "g_audit_connections_desc": MessageLookupByLibrary.simpleMessage(
      "Gérer les sessions ; se déconnecter n\'annule pas les autorisations de jetons.",
    ),
    "g_audit_currency": MessageLookupByLibrary.simpleMessage(
      "Devise d\'affichage",
    ),
    "g_audit_currency_usd": MessageLookupByLibrary.simpleMessage(
      "Les valeurs du portefeuille sont actuellement affichées en dollars américains.",
    ),
    "g_audit_defi_error": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les positions DeFi. Appuyez pour réessayer.",
    ),
    "g_audit_defi_loading": MessageLookupByLibrary.simpleMessage(
      "Chargement des positions DeFi…",
    ),
    "g_audit_defi_positions": MessageLookupByLibrary.simpleMessage(
      "Positions DeFi",
    ),
    "g_audit_display_language": MessageLookupByLibrary.simpleMessage(
      "Langue d\'affichage de l\'application",
    ),
    "g_audit_encrypted_backup": MessageLookupByLibrary.simpleMessage(
      "Exporter une sauvegarde chiffrée du portefeuille",
    ),
    "g_audit_funding": MessageLookupByLibrary.simpleMessage(
      "Taux de financement actuel",
    ),
    "g_audit_gas": MessageLookupByLibrary.simpleMessage(
      "Suivi des frais de réseau",
    ),
    "g_audit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Frais de réseau et alertes de prix",
    ),
    "g_audit_hardware": MessageLookupByLibrary.simpleMessage(
      "Portefeuille matériel",
    ),
    "g_audit_load_more": MessageLookupByLibrary.simpleMessage("Charger plus"),
    "g_audit_mainnet": MessageLookupByLibrary.simpleMessage("Réseau principal"),
    "g_audit_manage_settings": MessageLookupByLibrary.simpleMessage(
      "Gérer votre portefeuille et vos préférences",
    ),
    "g_audit_manage_wallets": MessageLookupByLibrary.simpleMessage(
      "Créer, importer et gérer des portefeuilles",
    ),
    "g_audit_mark_price": MessageLookupByLibrary.simpleMessage(
      "Prix indicatif",
    ),
    "g_audit_max_leverage": MessageLookupByLibrary.simpleMessage(
      "Leverage maximum",
    ),
    "g_audit_network_desc": MessageLookupByLibrary.simpleMessage(
      "Gérer les réseaux et les points d\'accès RPC",
    ),
    "g_audit_open_interest": MessageLookupByLibrary.simpleMessage(
      "Intérêt ouvert",
    ),
    "g_audit_oracle_price": MessageLookupByLibrary.simpleMessage(
      "Prix de l\'oracle",
    ),
    "g_audit_protect_wallet": MessageLookupByLibrary.simpleMessage(
      "Authentification et protection du portefeuille",
    ),
    "g_audit_quote_changed": MessageLookupByLibrary.simpleMessage(
      "L\'offre de prix d\'échange a changé ou a expiré. Vérifiez l\'offre de prix d\'échange la plus récente avant de confirmer.",
    ),
    "g_audit_rate": MessageLookupByLibrary.simpleMessage("Noter N42"),
    "g_audit_rate_desc": MessageLookupByLibrary.simpleMessage(
      "Ouvrir l\'App Store",
    ),
    "g_audit_saved_addresses": MessageLookupByLibrary.simpleMessage(
      "Adresses de destinataires sauvegardées",
    ),
    "g_audit_show_less": MessageLookupByLibrary.simpleMessage("Afficher moins"),
    "g_audit_testnet": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_audit_theme_desc": MessageLookupByLibrary.simpleMessage(
      "Apparence et mode d\'affichage",
    ),
    "g_audit_volume": MessageLookupByLibrary.simpleMessage("Volume 24h (USD)"),
    "g_audit_wallet_management": MessageLookupByLibrary.simpleMessage(
      "Gestion des portefeuilles",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer l\'URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Entrez une description",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Navigateur"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Vider le cache du navigateur",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Connecter automatiquement à la DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Tout fermer"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("Historique"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Effacer tout l\'historique",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Effacer tout l\'historique de navigation ?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage(
      "Historique effacé",
    ),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Hier"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage(
      "Découvrir les DApps",
    ),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Populaire"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DéFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Pont"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Favoris"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Outils"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Aucun favori ajouté pour le moment",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Favori"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nom"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le nom",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Descriptif"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Accepter"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Le message a été supprimé",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Opérations"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Connecter"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Réseaux disponibles",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage(
      "Signature du message",
    ),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage(
      "Connexion en cours",
    ),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Appairage en cours, veuillez patienter.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Déconnecter"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Rejeter"),
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("Bloqué"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage(
      "Attention",
    ),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Coffre-fort"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage("Vérifié"),
    "g_dex_account_unavailable": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez un portefeuille mainnet utilisable pour ce réseau. Les comptes en lecture seule ne peuvent pas signer d\'échanges.",
    ),
    "g_dex_execution_invalid": MessageLookupByLibrary.simpleMessage(
      "Les paramètres de l\'opération sont invalides ou l\'exécution a échoué. Actualisez l\'offre de prix d\'échange et réessayez.",
    ),
    "g_dex_history_record_failed": MessageLookupByLibrary.simpleMessage(
      "L\'échange a été soumis, mais l\'historique n\'a pas pu être mis à jour. Ne le soumettez pas à nouveau.",
    ),
    "g_dex_smart_account_fees": MessageLookupByLibrary.simpleMessage(
      "Les frais de réseau sont payés par ce compte intelligent.",
    ),
    "g_dex_spending_account": MessageLookupByLibrary.simpleMessage(
      "Compte de dépense",
    ),
    "g_dex_use_smart_account": MessageLookupByLibrary.simpleMessage(
      "Utiliser un compte intelligent",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Renvoyer le code"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Conseils de scan biométrique",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scannez votre empreinte digitale ou votre visage pour l\'authentification.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Conseils"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Configurer"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scannez votre visage ou empreinte digitale pour continuer.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Scannez le code QR avec l\'application Google Authenticator",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Ou entrez la clé manuellement :",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Entrez le code de vérification à 6 chiffres",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator requis pour confirmer chaque transfert.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Code incorrect, veuillez réessayer",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator non configuré",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Liaison réussie",
    ),
    "g_history_clear_dates": MessageLookupByLibrary.simpleMessage(
      "Effacer les dates",
    ),
    "g_history_export_all": MessageLookupByLibrary.simpleMessage(
      "Exporter les enregistrements locaux correspondants (CSV)",
    ),
    "g_history_export_error": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'exporter l\'historique des opérations. Veuillez réessayer.",
    ),
    "g_history_local_scope": MessageLookupByLibrary.simpleMessage(
      "Les filtres et l\'export CSV incluent tous les enregistrements correspondants enregistrés sur cet appareil. Ouvrez l\'actif pour synchroniser les activités récentes sur la chaîne.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Actualités"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Vérification"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Inviter un ami"),
    "g_home_market": MessageLookupByLibrary.simpleMessage("Marchés"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Annulé"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Vérifiez votre connexion réseau et réessayez",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "Aucun produit disponible",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage(
      "Restaurer les achats",
    ),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Restauration des achats…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Boutique indisponible",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Acheter"),
    "g_key_1": MessageLookupByLibrary.simpleMessage(
      "Échec de la suppression !",
    ),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Limite de gas"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("Plus rien"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Chargement "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Carnet d\'adresses"),
    "g_key_11": MessageLookupByLibrary.simpleMessage(
      "Importer un portefeuille",
    ),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Gérer"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("Nouvelle adresse"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Copier"),
    "g_key_12": MessageLookupByLibrary.simpleMessage(
      "Créer/Importer un portefeuille",
    ),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Thème"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("Système"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Clair"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Sombre"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Liste des portefeuilles"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("Aucune donnée"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Montant non valide"),
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portefeuille principal"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaction réussie"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Mot de passe incorrect"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Réseau principal"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Langue du système"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Définir comme portefeuille principal",
    ),
    "g_key_155": MessageLookupByLibrary.simpleMessage(
      "Adresse du portefeuille",
    ),
    "g_key_156": MessageLookupByLibrary.simpleMessage(
      "Scanner pour copier l\'adresse",
    ),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "g_key_16": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le portefeuille de vérification",
    ),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Symbole"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Coller"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Choisir la chaîne"),
    "g_key_175": MessageLookupByLibrary.simpleMessage(
      "Échec de la transaction",
    ),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "Ceci est mon adresse de portefeuille",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Autre"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Enregistré avec succès"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Succès"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer le portefeuille ?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "Aucune autorisation d\'accès à la caméra.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Explorateur"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Max."),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Actifs"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("Le registre est vide !"),
    "g_key_202": MessageLookupByLibrary.simpleMessage(
      "Aperçu de la transaction",
    ),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "Erreur de lien, scannez à nouveau le code QR.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage(
      "Modification du mot de passe",
    ),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Ancien mot de passe"),
    "g_key_208": MessageLookupByLibrary.simpleMessage(
      "Synchronisation des soldes...",
    ),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Clé privée"),
    "g_key_21": MessageLookupByLibrary.simpleMessage(
      "Entrez le mot de passe du portefeuille",
    ),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Erreur de clé privée"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Informations de marché"),
    "g_key_214": m8,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Solde"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Échec de l\'ajout !"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Recevoir"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Transférer"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("À"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Scanner le code QR"),
    "g_key_41": MessageLookupByLibrary.simpleMessage(
      "Entrez une adresse de portefeuille",
    ),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Solde disponible"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Montant"),
    "g_key_46": m9,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Fonds insuffisants pour couvrir cette transaction.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Envoyer"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Échec du chargement !"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Portefeuille"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Créer"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("De"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Annuler"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("Tous les jetons"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Paramètres"),
    "g_key_aa_account_created": MessageLookupByLibrary.simpleMessage(
      "Compte créé avec succès",
    ),
    "g_key_aa_account_details": MessageLookupByLibrary.simpleMessage(
      "Détails du compte",
    ),
    "g_key_aa_account_name": MessageLookupByLibrary.simpleMessage(
      "Nom du compte",
    ),
    "g_key_aa_account_name_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom du compte",
    ),
    "g_key_aa_account_type": MessageLookupByLibrary.simpleMessage(
      "Type de compte",
    ),
    "g_key_aa_active": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_aa_add_first_operation": MessageLookupByLibrary.simpleMessage(
      "Ajoutez votre première opération",
    ),
    "g_key_aa_add_operation": MessageLookupByLibrary.simpleMessage(
      "Ajouter une opération",
    ),
    "g_key_aa_address_calculating": MessageLookupByLibrary.simpleMessage(
      "Calcul de l\'adresse...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Échec du calcul de l\'adresse. Veuillez réessayer.",
    ),
    "g_key_aa_approve": MessageLookupByLibrary.simpleMessage("Approuver"),
    "g_key_aa_batch": MessageLookupByLibrary.simpleMessage("Lot"),
    "g_key_aa_batch_atomic": MessageLookupByLibrary.simpleMessage(
      "Exécution atomique",
    ),
    "g_key_aa_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Exécuter plusieurs opérations à la fois",
    ),
    "g_key_aa_batch_description": MessageLookupByLibrary.simpleMessage(
      "Envoyez plusieurs transactions en une seule opération",
    ),
    "g_key_aa_batch_failed": MessageLookupByLibrary.simpleMessage(
      "L\'exécution par lots a échoué",
    ),
    "g_key_aa_batch_no_templates": MessageLookupByLibrary.simpleMessage(
      "Aucun modèle enregistré",
    ),
    "g_key_aa_batch_operations": MessageLookupByLibrary.simpleMessage(
      "Opérations par lots",
    ),
    "g_key_aa_batch_save_gas": MessageLookupByLibrary.simpleMessage(
      "Économiser du gaz",
    ),
    "g_key_aa_batch_save_template": MessageLookupByLibrary.simpleMessage(
      "Enregistrer comme modèle",
    ),
    "g_key_aa_batch_submitting": MessageLookupByLibrary.simpleMessage(
      "Envoi...",
    ),
    "g_key_aa_batch_success": MessageLookupByLibrary.simpleMessage(
      "Lot soumis avec succès",
    ),
    "g_key_aa_batch_template_load": MessageLookupByLibrary.simpleMessage(
      "Charger le modèle",
    ),
    "g_key_aa_batch_template_name": MessageLookupByLibrary.simpleMessage(
      "Nom du modèle",
    ),
    "g_key_aa_batch_template_name_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez le nom du modèle",
    ),
    "g_key_aa_batch_template_saved": MessageLookupByLibrary.simpleMessage(
      "Modèle enregistré",
    ),
    "g_key_aa_batch_templates": MessageLookupByLibrary.simpleMessage("Modèles"),
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Transaction par lots",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Approuvez et échangez en une seule transaction – plus de confirmations en deux étapes",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "Actions par lots en un clic",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Parrainez des transactions ou payez des frais avec des jetons ERC-20 au lieu d\'ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Payez l\'essence avec n\'importe quel jeton",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Récupérez l\'accès via des contacts de confiance si vous perdez votre clé privée",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Récupération sociale",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent ERC-7579 modulaire avec support des transactions sans frais",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("par"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chaîne"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("ID de chaîne"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Changement"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Vérifier l\'état",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Bientôt disponible",
    ),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "Il s’agit d’une adresse contrefactuelle. Il sera déployé lors de votre première transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Créer un compte intelligent",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Créez votre premier compte intelligent",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Créer une clé de session",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Créé"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Le compte sera déployé automatiquement lors de votre première transaction",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Déployé"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Déploiement...",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Le déploiement se fera automatiquement lors de votre première transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Découvrez la nouvelle génération de comptes Ethereum avec des fonctionnalités améliorées",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Détails"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybride EOA/Smart Account – Aucun déploiement nécessaire",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Erreur"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gaz estimé",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Exécuter le lot",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expire"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Usine"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATUIT"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'estimation du gaz, utilisation par défaut",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Paiement du gaz",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Options de paiement du gaz",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gaz sponsorisé",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Sans gaz"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions sans gaz et opérations par lots",
    ),
    "g_key_aa_kernel_desc": MessageLookupByLibrary.simpleMessage(
      "Compte modulaire avec prise en charge des plugins de ZeroDev",
    ),
    "g_key_aa_label": MessageLookupByLibrary.simpleMessage("Étiquette"),
    "g_key_aa_last_activity": MessageLookupByLibrary.simpleMessage(
      "Dernière activité",
    ),
    "g_key_aa_my_accounts": MessageLookupByLibrary.simpleMessage(
      "Mes comptes intelligents",
    ),
    "g_key_aa_no_accounts": MessageLookupByLibrary.simpleMessage(
      "Pas encore de comptes intelligents",
    ),
    "g_key_aa_no_accounts_filter": MessageLookupByLibrary.simpleMessage(
      "Aucun compte ne correspond à votre filtre",
    ),
    "g_key_aa_no_operations": MessageLookupByLibrary.simpleMessage(
      "Aucune opération ajoutée",
    ),
    "g_key_aa_no_session_keys": MessageLookupByLibrary.simpleMessage(
      "Aucune clé de session",
    ),
    "g_key_aa_not_deployed": MessageLookupByLibrary.simpleMessage(
      "Non déployé",
    ),
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Créez un compte intelligent (gratuit, aucun ETH requis)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Financez-le - recevez n\'importe quel jeton EVM",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Effectuez des transactions sans gaz avec Paymaster",
    ),
    "g_key_aa_operations": MessageLookupByLibrary.simpleMessage("Opérations"),
    "g_key_aa_owner": MessageLookupByLibrary.simpleMessage("Propriétaire"),
    "g_key_aa_pay_gas_with_token": MessageLookupByLibrary.simpleMessage(
      "Payer l\'essence avec un jeton",
    ),
    "g_key_aa_pay_gas_yourself": MessageLookupByLibrary.simpleMessage(
      "Payez l\'essence avec votre ETH",
    ),
    "g_key_aa_pay_with": MessageLookupByLibrary.simpleMessage("Payer avec"),
    "g_key_aa_pay_with_eth": MessageLookupByLibrary.simpleMessage(
      "Payer avec ETH",
    ),
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "chaînes supportées",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Vérification de disponibilité...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Couverture de chaîne",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choisissez comment vous souhaitez payer les frais de transaction sur le gaz",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Coût est.",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les options gaz",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "g_key_aa_paymaster_unavailable": MessageLookupByLibrary.simpleMessage(
      "Le parrainage des frais de gaz n\'est pas encore disponible. Veuillez payer les frais de gaz avec votre solde de compte.",
    ),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Autorisation"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Adresse d\'aperçu",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Prêt"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Adresse de réception",
    ),
    "g_key_aa_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "g_key_aa_revoke": MessageLookupByLibrary.simpleMessage("Révoquer"),
    "g_key_aa_revoke_confirm": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir révoquer cette clé de session ? Le DApp autorisé ne pourra plus exécuter de transactions.",
    ),
    "g_key_aa_revoke_session": MessageLookupByLibrary.simpleMessage(
      "Révoquer la clé de session",
    ),
    "g_key_aa_revoked": MessageLookupByLibrary.simpleMessage(
      "Clé de session révoquée",
    ),
    "g_key_aa_revoked_status": MessageLookupByLibrary.simpleMessage("Révoqué"),
    "g_key_aa_revoking": MessageLookupByLibrary.simpleMessage(
      "Révocation de la clé de session...",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Compte multi-signature avec fonctionnalités de sécurité avancées",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("enregistré"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez la chaîne",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez Payeur",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Sélectionné"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Envoyez des jetons en utilisant votre compte intelligent",
    ),
    "g_key_aa_send_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de la transaction",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 jour"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 heure"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 jours"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 jours"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "ex. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Montant max.",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Je comprends les permissions de cette clé",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interagir avec les contrats DApp approuvés",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de création de la clé de session",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Clé de session créée",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "ex. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Label / Nom DApp",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Détails de la clé de session",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Valable pour",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Risque élevé — uniquement DApps vérifiées",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Clés de session",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Autorisez les DApps avec un accès temporaire à votre compte intelligent",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "Accès DApp",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Contrôle total",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Envoi uniquement",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "Risque élevé",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Risque faible",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Risque moyen",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Vérifiez les permissions avant de confirmer",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Choisir le niveau de permission",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Transférer des tokens dans la limite fixée",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent de base avec un seul propriétaire - recommandé pour la plupart des utilisateurs",
    ),
    "g_key_aa_smart_accounts": MessageLookupByLibrary.simpleMessage(
      "Comptes intelligents",
    ),
    "g_key_aa_smart_wallet": MessageLookupByLibrary.simpleMessage(
      "Portefeuille intelligent",
    ),
    "g_key_aa_spending_limit": MessageLookupByLibrary.simpleMessage(
      "Limite de dépenses",
    ),
    "g_key_aa_sponsored": MessageLookupByLibrary.simpleMessage(
      "Sponsorisé (Gratuit)",
    ),
    "g_key_aa_title": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent",
    ),
    "g_key_aa_total_gas": MessageLookupByLibrary.simpleMessage("Gaz total"),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Opérations"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Tout afficher"),
    "g_key_address": MessageLookupByLibrary.simpleMessage("Adresse"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un nom",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer l\'adresse",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un type de jeton",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage(
      "Modifier l\'adresse",
    ),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Supprimé avec succès",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage(
      "Choisir les jetons",
    ),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage(
      "Rechercher des jetons",
    ),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Fonctionnalités avancées",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_airdrop_discover": MessageLookupByLibrary.simpleMessage("Découvrir"),
    "g_key_airdrop_distribute": MessageLookupByLibrary.simpleMessage(
      "Distribuer",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Aucune campagne vérifiée disponible",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("En Attente"),
    "g_key_airdrop_sources": MessageLookupByLibrary.simpleMessage("Sources"),
    "g_key_airdrop_sources_hint": MessageLookupByLibrary.simpleMessage(
      "Ouvrez Sources pour parcourir les répertoires de campagnes gérés par les fournisseurs.",
    ),
    "g_key_airdrop_thirdparty_warning": MessageLookupByLibrary.simpleMessage(
      "Les campagnes tierces peuvent être malveillantes. Vérifiez le domaine du projet et les détails de la transaction avant de signer.",
    ),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Distribution gratuite",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("À venir"),
    "g_key_badge_hot": MessageLookupByLibrary.simpleMessage("CHAUD"),
    "g_key_badge_live": MessageLookupByLibrary.simpleMessage("EN DIRECT"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Ajouter un Destinataire",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Diffusion...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Tout Effacer",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmer le transfert par lots",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continuer"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Format CSV: adresse,montant,libellé",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimation du gaz...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Le transfert par lots prend uniquement en charge les chaînes EVM",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Exporter CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Aide sur le transfert par lots",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importer CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Le mémo est facultatif",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Utilisez Multicall3 pour réduire les frais de gaz",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Aucun jeton pris en charge",
    ),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinataires",
    ),
    "g_key_batch_select_token": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez le jeton",
    ),
    "g_key_batch_send_multiple": MessageLookupByLibrary.simpleMessage(
      "Envoyez des jetons à plusieurs adresses en une seule transaction",
    ),
    "g_key_batch_signing": MessageLookupByLibrary.simpleMessage("Signature..."),
    "g_key_batch_swipe_remove": MessageLookupByLibrary.simpleMessage(
      "Balayez vers la gauche pour supprimer un destinataire",
    ),
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transfert par Lots",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Montant Total",
    ),
    "g_key_block_explorer_optional": MessageLookupByLibrary.simpleMessage(
      "URL de l\'explorateur de blocs (facultatif)",
    ),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Chaîne non prise en charge",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Moins Cher"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Vous recevrez (estimé)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Plus Rapide"),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage(
      "Obtenir un Devis",
    ),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Historique du Pont",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "Aucune route disponible",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommandé",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Actualiser"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Itinéraire"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Rechercher une chaîne...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Sélectionnez"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Glissement"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Terminé",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "En cours",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "En attente",
    ),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Pont"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Pont Échoué",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transaction en Attente",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Pont Réussi",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Verrouillé jusqu\'à",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Vérifiez que la période de verrouillage a expiré avant de soumettre votre échange.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC toujours verrouillé",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Échanger des vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Débloqué – prêt à échanger",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "Je comprends les risques et souhaite continuer",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Continuer à miser",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "Comment ça marche",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC sera verrouillé jusqu\'à l\'expiration du délai. Terminez le processus de jalonnement dans l’interface ci-dessous.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Votre BTC sera verrouillé pendant toute la période de mise. Un retrait anticipé n’est pas possible.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "Le verrouillage est appliqué par Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) et ne peut pas être contourné.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Risque lié aux contrats intelligents : bien qu’audité, aucun protocole n’est totalement sans risque.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Mise minimale : 0,001 BTC. Période de verrouillage minimale : 0,125 jours (~3 heures).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Avertissement de risque",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Votre BTC est verrouillé dans une adresse multisig 2 sur 2 avec un verrou temporel (CLTV), sécurisé par votre clé et la clé de la cartouche N42.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Verrouillez votre BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "Après confirmation en chaîne, le vBTC est émis dans votre portefeuille dans un rapport de 1:1.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Menthe vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Détenez vBTC pour gagner des récompenses de mise. vBTC est également utilisable dans les protocoles DeFi.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Gagnez des récompenses",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "Lorsque la période de verrouillage expire, gravez votre vBTC pour récupérer votre BTC d\'origine.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Échanger après le déverrouillage",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "Jalonnement d\'auto-garde BTC",
    ),
    "g_key_burn_got_it": MessageLookupByLibrary.simpleMessage(
      "Je l\'ai compris",
    ),
    "g_key_burn_nft_step1": MessageLookupByLibrary.simpleMessage(
      "1. Sélectionnez un jeton avec prise en charge NFT",
    ),
    "g_key_burn_nft_step2": MessageLookupByLibrary.simpleMessage(
      "2. Allez dans l\'onglet NFT",
    ),
    "g_key_burn_nft_step3": MessageLookupByLibrary.simpleMessage(
      "3. Sélectionnez le NFT que vous souhaitez graver",
    ),
    "g_key_burn_nft_step4": MessageLookupByLibrary.simpleMessage(
      "4. Appuyez sur le bouton « Graver »",
    ),
    "g_key_burn_nft_steps": MessageLookupByLibrary.simpleMessage("Étapes :"),
    "g_key_burn_nft_tip": MessageLookupByLibrary.simpleMessage(
      "Pour graver un NFT, veuillez vous rendre sur la page de détails du NFT et appuyer sur le bouton « Graver ».",
    ),
    "g_key_chain_presets": MessageLookupByLibrary.simpleMessage(
      "Réseaux populaires (appuyez pour remplir)",
    ),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Cette chaîne ne prend pas encore en charge les transferts, restez à l\'écoute",
    ),
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "Tous les actifs sont inférieurs à 1 \$",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Autres actifs",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour tout afficher",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Récent"),
    "g_key_dapp_connect_account": MessageLookupByLibrary.simpleMessage(
      "Compte",
    ),
    "g_key_dapp_connect_desc": MessageLookupByLibrary.simpleMessage(
      "Ce site demande à consulter votre adresse de portefeuille et à proposer des transactions. Il ne peut pas déplacer les fonds sans votre accord.",
    ),
    "g_key_dapp_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connecter le portefeuille",
    ),
    "g_key_device_security_warning_message": MessageLookupByLibrary.simpleMessage(
      "Cet appareil semble être rooté ou jailbreaké. Utiliser un portefeuille sur un appareil compromis augmente le risque de vol de clés et d\'accès non autorisé. Agissez avec précaution.",
    ),
    "g_key_device_security_warning_title": MessageLookupByLibrary.simpleMessage(
      "Avertissement de sécurité de l\'appareil",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Approuvé ! Appuyez sur Échanger pour continuer.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Montant exact",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Illimité",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Approbation illimitée : le routeur peut dépenser ce jeton à tout moment. Pratique standard, mais risquée si le contrat est compromis.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Approuver…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage(
      "Meilleure Route",
    ),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Meilleure Source",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Chaîne"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmer le Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimation du Gas",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "Historique DEX",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage("Min. Reçu"),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Aucun token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Aucun token trouvé",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Graphique de prix",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impact du Prix",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Devis échoué",
    ),
    "g_key_dex_quote_unavailable": MessageLookupByLibrary.simpleMessage(
      "Le service d\'offre de prix d\'échange est temporairement indisponible. Veuillez réessayer plus tard.",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Rechercher symbole / nom / adresse",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage(
      "Sélectionner",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Glissement maximum",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmé",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Échoué"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage(
      "En Attente",
    ),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Devisé"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Échanger"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap soumis avec succès",
    ),
    "g_key_dex_tokens_offline": MessageLookupByLibrary.simpleMessage(
      "Le service de jetons est indisponible. Affichage d\'une liste limitée hors ligne.",
    ),
    "g_key_dex_untrusted_router": MessageLookupByLibrary.simpleMessage(
      "Échange bloqué : l\'adresse du routeur n\'est pas reconnue. Pour votre sécurité, cette transaction a été annulée.",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Vous Payez"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Vous Recevez",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Produits actifs",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Transfert en lot",
    ),
    "g_key_earn_best_apy": MessageLookupByLibrary.simpleMessage(
      "Meilleur TAEG",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Brûler"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Acheter N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Achetez N avec le protocole N42",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Trouver des campagnes tierces vérifiées",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transfert inter-chaînes",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Points journaliers sur la chaîne",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Échange DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Commencer le staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Grand livre"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Chargement APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Minage"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Gagnez plus"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Jalonnement natif de Solana",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "Aucune position active",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Gagnez des récompenses en participant au minage de nœuds",
    ),
    "g_key_earn_perps": MessageLookupByLibrary.simpleMessage(
      "Contrats perpétuels",
    ),
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Outils rapides",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommandé",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le type d\'échange",
    ),
    "g_key_earn_stablecoin_deposit": MessageLookupByLibrary.simpleMessage(
      "Dépôt",
    ),
    "g_key_earn_stablecoin_desc": MessageLookupByLibrary.simpleMessage(
      "Gagnez un rendement quotidien sur le USDC / USDT / DAI",
    ),
    "g_key_earn_stablecoin_empty": MessageLookupByLibrary.simpleMessage(
      "Aucun marché de stablecoin disponible pour le moment",
    ),
    "g_key_earn_stablecoin_title": MessageLookupByLibrary.simpleMessage(
      "Récompenses sur les monnaies stables",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Miser ETH avec Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Échanger"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Gagner"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Gains totaux",
    ),
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Tout afficher",
    ),
    "g_key_ens_address_updated": MessageLookupByLibrary.simpleMessage(
      "Adresse résolue mise à jour",
    ),
    "g_key_ens_advanced": MessageLookupByLibrary.simpleMessage("Avancé"),
    "g_key_ens_annual_fee": MessageLookupByLibrary.simpleMessage(
      "Frais annuels",
    ),
    "g_key_ens_available": MessageLookupByLibrary.simpleMessage("Disponible"),
    "g_key_ens_base_price": MessageLookupByLibrary.simpleMessage(
      "Prix de base",
    ),
    "g_key_ens_checking": MessageLookupByLibrary.simpleMessage(
      "Vérification de la disponibilité...",
    ),
    "g_key_ens_commit": MessageLookupByLibrary.simpleMessage("S\'engager"),
    "g_key_ens_commit_failed": MessageLookupByLibrary.simpleMessage(
      "La validation a échoué",
    ),
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "L\'engagement d\'enregistrement a expiré. Veuillez recommencer le processus d\'enregistrement.",
    ),
    "g_key_ens_committing": MessageLookupByLibrary.simpleMessage(
      "S\'engager...",
    ),
    "g_key_ens_confirm_renew": MessageLookupByLibrary.simpleMessage(
      "Confirmer le renouvellement",
    ),
    "g_key_ens_confirm_send": MessageLookupByLibrary.simpleMessage(
      "Confirmer et envoyer",
    ),
    "g_key_ens_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirmer la résolution ENS",
    ),
    "g_key_ens_copy_address": MessageLookupByLibrary.simpleMessage(
      "Adresse copiée",
    ),
    "g_key_ens_current_expiry": MessageLookupByLibrary.simpleMessage(
      "Expiration actuelle",
    ),
    "g_key_ens_days_left": MessageLookupByLibrary.simpleMessage(
      "jours restants",
    ),
    "g_key_ens_description": MessageLookupByLibrary.simpleMessage(
      "Enregistrez et gérez vos noms de domaine .eth",
    ),
    "g_key_ens_detected": MessageLookupByLibrary.simpleMessage(
      "Nom ENS détecté",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expire"),
    "g_key_ens_extend_period": MessageLookupByLibrary.simpleMessage(
      "Prolonger la période d\'inscription",
    ),
    "g_key_ens_failed": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_key_ens_finalizing": MessageLookupByLibrary.simpleMessage(
      "Finalisation de l\'inscription",
    ),
    "g_key_ens_get_started": MessageLookupByLibrary.simpleMessage(
      "Débuter avec l\'ENS",
    ),
    "g_key_ens_get_your_name": MessageLookupByLibrary.simpleMessage(
      "Obtenez votre nom .eth",
    ),
    "g_key_ens_invalid_address": MessageLookupByLibrary.simpleMessage(
      "Adresse invalide (doit être 0x + 40 caractères hexadécimaux)",
    ),
    "g_key_ens_invalid_name": MessageLookupByLibrary.simpleMessage(
      "Nom ENS invalide",
    ),
    "g_key_ens_is_yours": MessageLookupByLibrary.simpleMessage(
      "est maintenant le vôtre !",
    ),
    "g_key_ens_keep_app_open": MessageLookupByLibrary.simpleMessage(
      "Veuillez garder l\'application ouverte lors de l\'inscription",
    ),
    "g_key_ens_manage_your_identity": MessageLookupByLibrary.simpleMessage(
      "Gérez votre identité Web3",
    ),
    "g_key_ens_min_length": MessageLookupByLibrary.simpleMessage(
      "Minimum 3 caractères",
    ),
    "g_key_ens_my_domains": MessageLookupByLibrary.simpleMessage(
      "Mes domaines",
    ),
    "g_key_ens_name": MessageLookupByLibrary.simpleMessage("Nom de l\'ENS"),
    "g_key_ens_new_expiry": MessageLookupByLibrary.simpleMessage(
      "Nouvelle expiration",
    ),
    "g_key_ens_new_owner": MessageLookupByLibrary.simpleMessage(
      "Adresse du nouveau propriétaire",
    ),
    "g_key_ens_no_domains": MessageLookupByLibrary.simpleMessage(
      "Aucun domaine pour l\'instant",
    ),
    "g_key_ens_owner": MessageLookupByLibrary.simpleMessage("Propriétaire"),
    "g_key_ens_please_wait": MessageLookupByLibrary.simpleMessage(
      "Veuillez patienter",
    ),
    "g_key_ens_premium_name": MessageLookupByLibrary.simpleMessage(
      "Nom premium",
    ),
    "g_key_ens_price_breakdown": MessageLookupByLibrary.simpleMessage(
      "Répartition des prix",
    ),
    "g_key_ens_primary": MessageLookupByLibrary.simpleMessage("Primaire"),
    "g_key_ens_primary_set": MessageLookupByLibrary.simpleMessage(
      "Nom principal défini avec succès",
    ),
    "g_key_ens_processing": MessageLookupByLibrary.simpleMessage(
      "Traitement...",
    ),
    "g_key_ens_purchase_title": MessageLookupByLibrary.simpleMessage(
      "S\'inscrire à l\'ENS",
    ),
    "g_key_ens_register": MessageLookupByLibrary.simpleMessage("S\'inscrire"),
    "g_key_ens_register_description": MessageLookupByLibrary.simpleMessage(
      "Votre identité décentralisée sur Ethereum",
    ),
    "g_key_ens_register_failed": MessageLookupByLibrary.simpleMessage(
      "L\'inscription a échoué",
    ),
    "g_key_ens_register_now": MessageLookupByLibrary.simpleMessage(
      "Inscrivez-vous maintenant",
    ),
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Inscription...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Informations d\'inscription",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Période d\'inscription",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Activer le rappel d\'expiration",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notifier 30, 7 et 1 jour avant l\'expiration",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renouveler"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Prolongez l\'enregistrement de votre domaine",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renouvellement réussi",
    ),
    "g_key_ens_resolved_address": MessageLookupByLibrary.simpleMessage(
      "Adresse résolue",
    ),
    "g_key_ens_resolving": MessageLookupByLibrary.simpleMessage(
      "Résolution de l\'ENS...",
    ),
    "g_key_ens_search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "g_key_ens_search_desc": MessageLookupByLibrary.simpleMessage(
      "Rechercher les noms .eth disponibles",
    ),
    "g_key_ens_search_hint": MessageLookupByLibrary.simpleMessage(
      "Rechercher un nom .eth",
    ),
    "g_key_ens_search_prompt": MessageLookupByLibrary.simpleMessage(
      "Entrez un nom ENS pour rechercher",
    ),
    "g_key_ens_search_register": MessageLookupByLibrary.simpleMessage(
      "Rechercher et s\'inscrire",
    ),
    "g_key_ens_search_title": MessageLookupByLibrary.simpleMessage(
      "Rechercher ENS",
    ),
    "g_key_ens_self_transfer": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'envoyer à votre propre adresse",
    ),
    "g_key_ens_service": MessageLookupByLibrary.simpleMessage(
      "Service de noms Ethereum",
    ),
    "g_key_ens_set_primary": MessageLookupByLibrary.simpleMessage(
      "Définir comme principal",
    ),
    "g_key_ens_standard_name": MessageLookupByLibrary.simpleMessage(
      "Nom de la norme",
    ),
    "g_key_ens_start_registration": MessageLookupByLibrary.simpleMessage(
      "Commencer l\'inscription",
    ),
    "g_key_ens_step_1": MessageLookupByLibrary.simpleMessage("Étape 1"),
    "g_key_ens_step_2": MessageLookupByLibrary.simpleMessage("Étape 2"),
    "g_key_ens_step_3": MessageLookupByLibrary.simpleMessage("Étape 3"),
    "g_key_ens_subdomain_create": MessageLookupByLibrary.simpleMessage(
      "Créer un sous-domaine",
    ),
    "g_key_ens_subdomain_created": MessageLookupByLibrary.simpleMessage(
      "Sous-domaine créé",
    ),
    "g_key_ens_subdomain_delete": MessageLookupByLibrary.simpleMessage(
      "Supprimer le sous-domaine",
    ),
    "g_key_ens_subdomain_delete_confirm": MessageLookupByLibrary.simpleMessage(
      "Ce sous-domaine sera définitivement supprimé.",
    ),
    "g_key_ens_subdomain_deleted": MessageLookupByLibrary.simpleMessage(
      "Sous-domaine supprimé",
    ),
    "g_key_ens_subdomain_empty": MessageLookupByLibrary.simpleMessage(
      "Pas encore de sous-domaines",
    ),
    "g_key_ens_subdomain_invalid_label": MessageLookupByLibrary.simpleMessage(
      "Utilisez uniquement des lettres, des chiffres et des traits d\'union",
    ),
    "g_key_ens_subdomain_label": MessageLookupByLibrary.simpleMessage(
      "Libellé du sous-domaine",
    ),
    "g_key_ens_subdomain_label_hint": MessageLookupByLibrary.simpleMessage(
      "par ex. blog, courrier, application",
    ),
    "g_key_ens_subdomain_owner": MessageLookupByLibrary.simpleMessage(
      "Adresse du propriétaire",
    ),
    "g_key_ens_subdomain_owner_hint": MessageLookupByLibrary.simpleMessage(
      "Laisser vide pour utiliser le portefeuille actuel",
    ),
    "g_key_ens_subdomains": MessageLookupByLibrary.simpleMessage(
      "Sous-domaines",
    ),
    "g_key_ens_success": MessageLookupByLibrary.simpleMessage("Succès !"),
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Enregistrements de texte",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Responsable ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_transfer": MessageLookupByLibrary.simpleMessage("Transfert"),
    "g_key_ens_transfer_desc": MessageLookupByLibrary.simpleMessage(
      "Transférer la propriété à une autre adresse",
    ),
    "g_key_ens_transfer_success": MessageLookupByLibrary.simpleMessage(
      "Transfert réussi",
    ),
    "g_key_ens_transfer_warning": MessageLookupByLibrary.simpleMessage(
      "Le transfert est irréversible. Assurez-vous que l\'adresse du nouveau propriétaire est correcte.",
    ),
    "g_key_ens_try_another": MessageLookupByLibrary.simpleMessage(
      "Essayez un autre nom",
    ),
    "g_key_ens_two_step_process": MessageLookupByLibrary.simpleMessage(
      "L\'inscription à l\'ENS se déroule en deux étapes",
    ),
    "g_key_ens_unavailable": MessageLookupByLibrary.simpleMessage(
      "Indisponible",
    ),
    "g_key_ens_wait": MessageLookupByLibrary.simpleMessage("Attends"),
    "g_key_ens_wait_explanation": MessageLookupByLibrary.simpleMessage(
      "Le délai d’attente empêche les attaques frontales",
    ),
    "g_key_ens_wait_time_info": MessageLookupByLibrary.simpleMessage(
      "Un délai d’attente empêche d’avancer",
    ),
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage(
      "En attendant...",
    ),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Veuillez vérifier l\'adresse résolue avant de continuer. Les noms d\'ENS peuvent être transférés ou modifiés par leur propriétaire.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("année"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("années"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Votre identité",
    ),
    "g_key_error_1": MessageLookupByLibrary.simpleMessage(
      "Erreur d\'analyse des données de réponse !",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Erreur Dio"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Erreur de syntaxe de la requête",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Non autorisé, veuillez vous connecter",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Accès refusé"),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Erreur de requête"),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage(
      "Délai de la requête expiré",
    ),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Serveur anormal"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Service non implémenté",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage(
      "Erreur de passerelle",
    ),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Service indisponible",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage(
      "Délai de passerelle expiré",
    ),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "Version HTTP non supportée",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "La requête a échoué, code d\'erreur :",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "Le système est occupé, veuillez réessayer plus tard",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Fréquence des requêtes trop élevée",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("Échec du décodage"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "La transaction est déjà sur la chaîne",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Erreur de configuration du certificat !",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Erreur de configuration du code d\'état !",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Erreur inconnue !"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Connexion réseau expirée, veuillez vérifier les paramètres réseau !",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "Le serveur est anormal. Veuillez réessayer plus tard !",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "La demande a été annulée, veuillez réessayer !",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Exporter le keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage(
      "Conseils de sauvegarde",
    ),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Utilisez un gestionnaire de mots de passe pour stocker.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Copié"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Copie annulée",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Portefeuille d\'identité",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Fichier de clé privée chiffré.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Méthode d\'importation",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Fichier keystore",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer les informations du keystore.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Exporter la clé privée",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Obtenir le keystore et le mot de passe donnera au détenteur un contrôle total sur les actifs du portefeuille.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Enregistrez soigneusement et stockez dans un endroit sécurisé. Conserver plusieurs copies physiques est la méthode de stockage la plus sûre.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "Si votre clé privée est perdue, elle ne peut pas être récupérée. Sauvegardez-la physiquement et stockez-la de manière sécurisée.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage(
      "Sauvegarder hors ligne",
    ),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Ne sauvegardez pas dans une boîte mail, un bloc-notes, un disque réseau ou un logiciel de messagerie non sécurisé.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Veuillez utiliser la transmission réseau",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Assurez-vous de la transmettre via des outils réseau, une fois que les pirates l\'obtiennent, cela causera des pertes économiques irréparables",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Utilisez des outils pour sauvegarder",
    ),
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "Je comprends que toute personne obtenant ce fichier et le mot de passe a le contrôle total de mes fonds — la perte est permanente et irrécupérable",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Saisissez le mot de passe du portefeuille pour confirmer l\'exportation",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Saisissez le mot de passe du portefeuille pour voir la clé privée",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
    "g_key_gas_alert": MessageLookupByLibrary.simpleMessage("Alerte gaz"),
    "g_key_gas_alert_above": MessageLookupByLibrary.simpleMessage(
      "Alerte lorsque ci-dessus",
    ),
    "g_key_gas_alert_below": MessageLookupByLibrary.simpleMessage(
      "Alerte en dessous",
    ),
    "g_key_gas_alert_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "g_key_gas_alert_threshold": MessageLookupByLibrary.simpleMessage(
      "Seuil (Gwei)",
    ),
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Frais de Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Rapide"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Les prix du gaz fluctuent en fonction de la demande du réseau. Gaz inférieur = confirmation plus lente, gaz plus élevé = confirmation plus rapide.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Frais Maximum"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Réseau congestionné",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Réseau libre",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Réseau normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Tendance des prix",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Frais Prioritaire",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Prix du gaz en temps réel",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lent"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Norme"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage(
      "Traqueur de gaz",
    ),
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Compte déjà importé",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Ajouter un Compte",
    ),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adresse copiée",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Assurez-vous que votre appareil est déverrouillé et que Bluetooth est activé avant de vous connecter.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Vérifier l\'application",
    ),
    "g_key_hw_connect_new_device": MessageLookupByLibrary.simpleMessage(
      "Connecter un nouvel appareil",
    ),
    "g_key_hw_connect_new_keystone": MessageLookupByLibrary.simpleMessage(
      "Entrefer avec Keystone (QR)",
    ),
    "g_key_hw_connect_new_ledger": MessageLookupByLibrary.simpleMessage(
      "Connecter le grand livre (Bluetooth)",
    ),
    "g_key_hw_connect_new_trezor": MessageLookupByLibrary.simpleMessage(
      "Connectez Trezor (USB)",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connecté"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage("Connexion..."),
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Déconnecter"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connecter Keystone",
    ),
    "g_key_hw_keystone_scan_request_hint": MessageLookupByLibrary.simpleMessage(
      "Scannez ce code QR avec votre appareil Keystone pour signer la transaction",
    ),
    "g_key_hw_keystone_scan_response_hint": MessageLookupByLibrary.simpleMessage(
      "Pointez votre appareil photo vers le code QR affiché sur votre appareil Keystone",
    ),
    "g_key_hw_keystone_scan_response_title":
        MessageLookupByLibrary.simpleMessage("Scanner la signature Keystone"),
    "g_key_hw_keystone_scan_xpub_hint": MessageLookupByLibrary.simpleMessage(
      "Scannez le code QR depuis votre appareil Keystone pour importer des comptes",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour analyser la réponse Keystone",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Charger plus"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Chargement des comptes...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Veuillez confirmer sur votre appareil si demandé",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "Aucun compte trouvé",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "Aucune application n\'est actuellement ouverte",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Appareil non connecté",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Non connecté",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'appareil",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Appareils enregistrés",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Appareils pris en charge",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
    "g_key_hw_trezor_connect_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de la connexion à Trezor. Assurez-vous que l\'USB est connecté.",
    ),
    "g_key_hw_trezor_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connecter Trezor",
    ),
    "g_key_hw_trezor_connected": MessageLookupByLibrary.simpleMessage(
      "Trezor s\'est connecté avec succès",
    ),
    "g_key_hw_trezor_connecting": MessageLookupByLibrary.simpleMessage(
      "Connexion à Trezor...",
    ),
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connectez votre appareil Trezor via un câble USB et déverrouillez-le",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "Afficher les comptes",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Comptes du Portefeuille",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Hier"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Un portefeuille de cette devise existe déjà.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire le keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage(
      "Magasin de clés",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir quitter l\'application ?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Points disponibles",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Check-in effectué aujourd\'hui",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Se connecter",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Terminé",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "Échec du check-in",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Check-in confirmé sur N42",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in quotidien",
    ),
    "g_key_loyalty_earn_points": m28,
    "g_key_loyalty_empty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Le classement est vide",
    ),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage("Historique"),
    "g_key_loyalty_invite_description": MessageLookupByLibrary.simpleMessage(
      "Partagez votre code d\'invitation",
    ),
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Inviter des amis",
    ),
    "g_key_loyalty_leaderboard": MessageLookupByLibrary.simpleMessage(
      "Classement",
    ),
    "g_key_loyalty_no_history": MessageLookupByLibrary.simpleMessage(
      "Aucun historique de points",
    ),
    "g_key_loyalty_no_referrals": MessageLookupByLibrary.simpleMessage(
      "Aucune invitation pour l\'instant. Partagez votre code pour commencer.",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Aucune récompense disponible",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Aucune tâche disponible",
    ),
    "g_key_loyalty_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Aucun portefeuille actif",
    ),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage(
      "Invitations",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage(
      "Récompenses",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Tâches"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Points"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total gagné",
    ),
    "g_key_loyalty_unavailable": MessageLookupByLibrary.simpleMessage(
      "Service indisponible",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Utilisés"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Gazouillement"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navigateur"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Télégramme"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discorde"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("YouTube"),
    "g_key_m_19": MessageLookupByLibrary.simpleMessage("Instagram"),
    "g_key_m_2": MessageLookupByLibrary.simpleMessage(
      "Capitalisation boursière",
    ),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Volume d\'échange"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Offre totale"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("En circulation"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("À propos"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("Plus"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Liens"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Site web"),
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Gérer les chaînes",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage(
      "Disponible",
    ),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Nécessite un jalonnement",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer la phrase de récupération",
    ),
    "g_key_msgsign_btn": MessageLookupByLibrary.simpleMessage("Signer"),
    "g_key_msgsign_empty": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord saisir un message",
    ),
    "g_key_msgsign_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de la signature",
    ),
    "g_key_msgsign_input_hint": MessageLookupByLibrary.simpleMessage(
      "Saisissez le message à signer",
    ),
    "g_key_msgsign_result": MessageLookupByLibrary.simpleMessage("Signature"),
    "g_key_msgsign_title": MessageLookupByLibrary.simpleMessage(
      "Signer un message",
    ),
    "g_key_msgsign_unsupported": MessageLookupByLibrary.simpleMessage(
      "La signature de message n\'est pas encore prise en charge pour cette chaîne",
    ),
    "g_key_msgsign_warning": MessageLookupByLibrary.simpleMessage(
      "Ne signez un message que si vous lui faites entièrement confiance. Un message malveillant pourrait être utilisé pour autoriser des actions en votre nom.",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nom"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transaction soumise"),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Adresse de portefeuille invalide",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Solde"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Cette action est irréversible. Le NFT sera envoyé à l’adresse de gravure.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Graver NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Collecte"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contrat"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage("Descriptif"),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement des NFT. Appuyez pour réessayer.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("Tout"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Vidéo"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Sol"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("Galerie NFT"),
    "g_key_nft_hide_spam": MessageLookupByLibrary.simpleMessage(
      "Masquer les spams",
    ),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Numéro d\'inscription",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage(
      "Aucun NFT trouvé",
    ),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "Aucun lien d\'explorateur disponible",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Lecture vidéo non prise en charge",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinaires"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Les transferts d\'ordinaux ne sont pas encore pris en charge",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Quantité"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Rechercher par nom ou par collection",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Envoyer NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Les transferts Solana NFT arrivent bientôt",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("ID de jeton"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Tapez"),
    "g_key_nft_uncategorized": MessageLookupByLibrary.simpleMessage(
      "D\'autres",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas",
    ),
    "g_key_perps_read_only": MessageLookupByLibrary.simpleMessage(
      "Données du marché en lecture seule. La soumission d\'ordres n\'est pas prise en charge dans cette version.",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Sélectionner depuis la galerie du téléphone",
    ),
    "g_key_pubkey": MessageLookupByLibrary.simpleMessage("Clé publique"),
    "g_key_receive_payment_request": MessageLookupByLibrary.simpleMessage(
      "Demande de paiement",
    ),
    "g_key_receive_request_line": m29,
    "g_key_remove_network": MessageLookupByLibrary.simpleMessage(
      "Supprimer le réseau",
    ),
    "g_key_remove_network_confirm": m30,
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "g_key_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "g_key_scan_pay_unsupported": MessageLookupByLibrary.simpleMessage(
      "Le jeton ou la chaîne de la demande de paiement n\'est pas disponible dans ce portefeuille",
    ),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Soyez prudent",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Vérification de la sécurité du contrat...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "Risque élevé détecté",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contrat Vérifié Coffre-fort",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("Mémo / Note"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Mémo / Note (facultatif)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage(
      "Partager le code QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Partager le lien",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Méthode de partage",
    ),
    "g_key_sim_gas_estimate": m31,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "La transaction échouera probablement",
    ),
    "g_key_sim_reverted_reason": m32,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulation de transaction…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Simulation de transaction réussie",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulation indisponible pour ce réseau",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Discuter"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Postes actifs",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Montant"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Montant à débloquer",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("APY moyen"),
    "g_key_stake_broadcast_unsupported": MessageLookupByLibrary.simpleMessage(
      "Transaction créée, mais la diffusion depuis le portefeuille pour cette chaîne n\'est pas encore prise en charge.",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commissions",
    ),
    "g_key_stake_d_unbond": m33,
    "g_key_stake_days_remaining": m34,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Récompense quotidienne",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Récompense annuelle",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Aller à l\'échange",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Jalonnement liquide",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquide"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Votre jeton liquide peut être échangé directement sur DEX. Utilisez Swap pour l\'échanger contre l\'actif natif.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Mise Minimum",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "Aucune position active à débloquer",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage(
      "Pas de serrure",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "Pas encore de positions de jalonnement",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "Aucun validateur trouvé",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Adresse du portefeuille non disponible",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Aperçu du jalonnement total",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Mes Positions",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocoles"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Récompenses"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Rechercher des validateurs...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez un validateur",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez une position à désengager",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un Validateur",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("Trier par"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Staker"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Jalonné"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Commencer le jalonnement",
    ),
    "g_key_stake_submitted": MessageLookupByLibrary.simpleMessage(
      "Transaction de jalonnement soumise",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Jalonnement"),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaction préparée avec succès",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Déblocage en Cours",
    ),
    "g_key_stake_unbonding_warning": m35,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Retirer"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Mise à jour...",
    ),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validateur"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Vous recevrez",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prix du gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Frais de gas maximum"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Frais maximum par gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_key_t_29": m36,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Continuer"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Mot de passe du portefeuille",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage(
      "Mauvais mot de passe du portefeuille",
    ),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le mot de passe du portefeuille",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Taux de frais de gas"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "Moyenne des frais de gas du dernier bloc",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Transfert sortant"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Entrez un nombre entier supérieur à 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage(
      "Échec de la récupération des données",
    ),
    "g_key_t_45": m37,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Vérifier le compte de l\'adresse de réception",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("Aucun compte"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transfert entrant"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Adresse invalide"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Vérification du compte réussie",
    ),
    "g_key_t_52": m38,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'adresse de réception n\'a pas de compte, et le premier transfert doit être d\'au moins 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilisé"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Ajouter",
    ),
    "g_key_token_discovery_add_selected": m39,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Jeton ajouté",
    ),
    "g_key_token_discovery_banner": m40,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Tout désélectionner",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "Aucun nouveau jeton trouvé",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignorer",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Tout sélectionner",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Jetons découverts",
    ),
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage(
      "Historique des transactions",
    ),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage(
      "Détails de la transaction",
    ),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Veuillez consulter les reçus de transaction dans l\'historique",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Montant dépensé"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Montant reçu"),
    "g_key_tx_filter_date_from": MessageLookupByLibrary.simpleMessage(
      "Date de début",
    ),
    "g_key_tx_filter_date_range": MessageLookupByLibrary.simpleMessage(
      "Plage de dates",
    ),
    "g_key_tx_filter_date_to": MessageLookupByLibrary.simpleMessage(
      "Date de fin",
    ),
    "g_key_tx_filter_direction": MessageLookupByLibrary.simpleMessage(
      "Direction",
    ),
    "g_key_tx_no_results": MessageLookupByLibrary.simpleMessage(
      "Aucune transaction ne correspond à votre filtre",
    ),
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Dernière version trouvée",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour immédiatement",
    ),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage(
      "Nouvelle version trouvée",
    ),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Déjà la dernière version",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Voir la phrase de récupération",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Essayez maintenant de ressaisir votre phrase de récupération.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage(
      "Importer un compte",
    ),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Créer un compte"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "C\'est terminé !",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez maintenant profiter pleinement de votre portefeuille.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Commencer"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage(
      "Passer pour l\'instant",
    ),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez ignorer la sauvegarde de la phrase de récupération pour l\'instant, et le faire à tout moment dans les Paramètres si nécessaire.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage(
      "Créer directement",
    ),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "créé avec succès",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "Si vous souhaitez voir les détails de votre portefeuille ou exporter le keystore, allez dans Menu latéral > Gérer le portefeuille ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Exporter mon keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Sécurisez votre portefeuille en le sauvegardant",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "Un keystore est un dépôt de certificats de sécurité et de clés privées associées.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Étape 1 : Allez dans Gérer le portefeuille.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Étape 2 : Sélectionnez l\'adresse du portefeuille.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Étape 3 : Appuyez sur Exporter le keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Aller à Gérer le portefeuille",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Retour à l\'accueil",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage(
      "Ajouter un portefeuille",
    ),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Créer un portefeuille avec une phrase de récupération.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Entrez un nom de portefeuille",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas sauvegardé la phrase de récupération de votre portefeuille !",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage(
      "Sauvegarder maintenant",
    ),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Définir le mot de passe du portefeuille",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage(
      "Sauvegarder le portefeuille",
    ),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Veuillez enregistrer la phrase de récupération suivante",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Commencer"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Les appareils connectés à Internet peuvent exposer vos informations. Nous vous recommandons d\'écrire la phrase de récupération et de la stocker en toute sécurité.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Attention : Ne divulguez jamais votre phrase de récupération à quiconque. N42Wallet ne vous demandera jamais cette information. Soyez extrêmement prudent et stockez-la hors ligne de manière sécurisée. Si votre phrase de récupération est exposée, vous risquez de perdre tous vos actifs sans possibilité de récupération.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Attention : La phrase de récupération est le seul moyen de récupérer les actifs de votre portefeuille.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Étape suivante"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Cliquez pour voir la phrase de récupération",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Veuillez vous assurer qu\'il n\'y a pas d\'autres personnes ou caméras autour",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Confirmer la phrase de récupération",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Informations du portefeuille",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage(
      "Nom du portefeuille",
    ),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord sauvegarder la phrase de récupération de votre portefeuille !",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Vérifier la phrase de récupération",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Entrez maintenant votre phrase de récupération.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage(
      "Définir la phrase",
    ),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Veuillez vous assurer d\'enregistrer votre phrase de récupération et de la stocker en toute sécurité. Vous en aurez besoin pour importer ou récupérer votre portefeuille de cryptomonnaies.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage(
      "Modifier le portefeuille",
    ),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Heure"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Résultat"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Hash de transaction",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Chemin"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Bloc"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Valeur"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage(
      "Occasionnellement",
    ),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Accélérer"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Remarque"),
    "g_key_wallet_m1": m41,
    "g_key_wallet_m19": m42,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Le jeton actuel n\'a pas été ajouté.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Entrez votre phrase de récupération avec les mots séparés par des espaces",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importer le portefeuille",
    ),
    "g_key_wallet_m3": m43,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Le solde du jeton actuel est insuffisant.",
    ),
    "g_key_wallet_m5": m44,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage(
      "Erreur de signature",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Gérer le portefeuille",
    ),
    "g_key_wallet_tx_replace_hint": MessageLookupByLibrary.simpleMessage(
      "Une transaction de remplacement sera diffusée avec le même nonce et des frais de gas supérieurs d’environ 20 %. Elle ne prend effet que si la transaction d’origine est toujours en attente.",
    ),
    "g_key_wallet_tx_replace_submitted": MessageLookupByLibrary.simpleMessage(
      "Transaction de remplacement soumise",
    ),
    "g_key_wallet_tx_speedup": MessageLookupByLibrary.simpleMessage(
      "Accélérer",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'adresse Ethereum (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Le portefeuille de montre uniquement ne peut pas envoyer ni signer de transactions",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage(
      "Montre Portefeuille",
    ),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Suivez n\'importe quelle adresse EVM sans clé privée",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Réservé"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Réserve de base"),
    "g_key_xml_11": m45,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage(
      "Réserve incrémentielle",
    ),
    "g_key_xml_22": m46,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Nombre d\'objets possédés",
    ),
    "g_key_xml_33": m47,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Comment calculer le montant total réservé",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Réserve totale = Réserve de base + (Nombre d\'objets possédés × Réserve incrémentielle)",
    ),
    "g_live_ended": MessageLookupByLibrary.simpleMessage(
      "Le flux en direct est terminé",
    ),
    "g_live_enter_room_failed": m48,
    "g_live_follow": MessageLookupByLibrary.simpleMessage("Suivre"),
    "g_live_follow_wip": MessageLookupByLibrary.simpleMessage(
      "Fonction de suivi bientôt disponible",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID et Face ID"),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage(
      "Mot de passe gestuel",
    ),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Définir le mot de passe gestuel",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Dessinez votre schéma gestuel",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Confirmez votre schéma gestuel",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Dessinez le schéma gestuel actuel",
    ),
    "g_lock_key21": m49,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le mot de passe gestuel",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Trop de tentatives échouées, veuillez réessayer",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Ajouter un mot de passe de portefeuille ?",
    ),
    "g_lock_key25": m50,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Vérification du transfert",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Exiger une authentification biométrique (reconnaissance faciale / empreinte digitale) pour confirmer chaque transfert de portefeuille.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Mot de passe gestuel non défini",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Authentification gestuelle requise pour confirmer chaque transfert.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Réussi"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "La reconnaissance biométrique n\'est pas activée",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Ajouter la vérification biométrique ?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage(
      "Changement 30D",
    ),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("Changement 7D"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage(
      "Profondeur du marché",
    ),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "Pas encore de liste de surveillance",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("Haute 24H"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Score de liquidité",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Faible 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("Actualités"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage(
      "Aucune donnée graphique",
    ),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage(
      "Aucun résultat",
    ),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Rang"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Rechercher des pièces...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Tendance"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage(
      "Liste de surveillance",
    ),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Le score d\'inactivité du validateur est élevé. Vérifiez l\'état de votre nœud pour éviter les pénalités.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Déverrouiller N ?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Activité de vérification cloud",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Paramètres de vérification",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Musique de vérification d\'arrière-plan",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Par défaut"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Muet"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "Lorsque la vérification en arrière-plan est activée, la musique sera jouée en arrière-plan. Si la musique s\'arrête, la vérification s\'arrêtera également.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Votre niveau"),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "La configuration nécessite une petite quantité pour le gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "Vous avez rejoint avec succès un nœud de groupe sur N42Wallet. Partagez le lien pour inviter des amis, activez le nœud et commencez la vérification !",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage(
      "Partager avec des amis",
    ),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Continuer"),
    "g_mining_key63": m51,
    "g_mining_key73": m52,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Je viens de configurer un nœud sur @N42Wallet et j\'ai commencé la vérification sur appareils mobiles ! Venez me rejoindre. L\'avenir décentralisé est mobile !",
    ),
    "g_mining_key76": m53,
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Minéral"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Nœud"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Réseau"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Basculez entre testnet et mainnet pour le cloud mining.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Rachat disponible après 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Les demandes avant cela ne seront pas traitées.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Accueil"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage(
      "Récompense du jour",
    ),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Veuillez traiter les données ci-dessous comme une clé importante. Nous vous recommandons de les copier et de les sauvegarder immédiatement dans un emplacement de confiance.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage(
      "Copier les données",
    ),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inactif"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Importation réussie",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Les données chiffrées ne peuvent pas être vides !",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe ne peut pas être vide !",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Échec du déchiffrement. Veuillez vérifier si le mot de passe est correct !",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Format de données chiffrées non supporté !",
    ),
    "g_mining_key_109": m54,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Récompenses d\'hier",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage(
      "Données chiffrées",
    ),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage(
      "Importer des fichiers",
    ),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer les données chiffrées.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage(
      "Importation en cours...",
    ),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Confirmation"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Le rachat prend du temps, veuillez patienter !",
    ),
    "g_mining_key_116": m55,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Les récompenses s\'accumulent quotidiennement et ne sont envoyées à votre portefeuille N que lorsqu\'elles atteignent ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Récompenses totales",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valeur minée"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Détail de la tâche",
    ),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Résumé"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Activités"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Valeur totale extraite",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Vérification depuis",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Nombre de gains"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("Valeur vérifiée"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage(
      "Sélectionner les plans",
    ),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Période de déverrouillage : Déverrouillable à tout moment",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Récompense maximale annuelle",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Distribution des récompenses",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage(
      "Limite quotidienne",
    ),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Vitesse"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Plans de vérification",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le mode de paiement",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage(
      "Modes de paiement",
    ),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Payer avec N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage(
      "Solde du portefeuille",
    ),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas assez de N pour cette transaction",
    ),
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir ignorer ?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "Vous ne recevrez aucune récompense de vérification tant que vous n\'aurez pas choisi l\'un des plans.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Récompense"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Voir plus"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Statut de vérification",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("Pour débloquer"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Sauter"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("7 derniers jours"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Récompenses accumulées",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Verrouillez des N pour commencer à gagner des récompenses de vérification.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage(
      "Récompenses reçues",
    ),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Avancé"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrée"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("NŒUD COMPLET"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MINUTES/JOUR"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nœud avancé"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nœud d\'entrée"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nœud pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocs/jour~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Date de déverrouillage",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocs/jour~15 mins",
    ),
    "g_mining_key_71": m56,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 secondes par vérification",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "La chaîne de test est en cours de mise à niveau et les blocs ne peuvent pas être vérifiés temporairement.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Ne pas accomplir les tâches pendant quatre jours consécutifs entraînera aucun gain et un risque de pénalité.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Score de risque"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Racheter"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Veuillez d\'abord sauvegarder la paire de clés publique et privée du validateur.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Exporter"),
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Heure de vérification d\'aujourd\'hui",
    ),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Fonds insuffisants pour le transfert.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage(
      "Liste des validateurs",
    ),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage(
      "Importer un validateur",
    ),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "Le validateur existe déjà",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Risque faible"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage(
      "Risque modérément",
    ),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage(
      "Récompenses des 7 derniers jours",
    ),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("Risque élevé"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "Le contrat est en cours de chargement et ne peut pas être vérifié pour le moment. Veuillez patienter !",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage(
      "Conseils de sécurité",
    ),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Vérification en arrière-plan",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Veuillez conserver votre clé privée ou phrase de récupération en sécurité.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Votre clé privée ou phrase de récupération est le seul moyen d\'accéder aux actifs de votre portefeuille.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Veuillez la conserver dans un endroit sûr (papier, gestionnaire de mots de passe, etc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Ne faites pas de captures d\'écran, ne la téléchargez pas sur Internet et ne la partagez avec personne.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "En cas de perte ou de compromission, les actifs de votre portefeuille ne pourront pas être récupérés.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage(
      "Confirmer et sauvegarder",
    ),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Définir un mot de passe et chiffrer",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le mot de passe de chiffrement",
    ),
    "g_mining_key_98": m57,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Veuillez ressaisir votre mot de passe pour vous assurer qu\'il est correct",
    ),
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Détail Nœud Complet",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("ID du Nœud"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Connecté"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage("WS Déconnecté"),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Reconnexion",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Expiration"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Période de déverrouillage:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Déverrouillable à tout moment",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage(
      "Aucune actualité disponible",
    ),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage("Retour (Sûr)"),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Continuer quand même",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "Ce site web a été identifié comme potentiellement malveillant. Il peut tenter de voler vos actifs crypto ou vos clés privées.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Avertissement de Sécurité",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "URL suspecte :",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage(
      "Ajouter un échange",
    ),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Coût moyen"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Prix d\'achat (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base de coût"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Quantité"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Enregistrer"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("P&L non réalisé"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("Changement 24h"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "Tous les actifs",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Répartition de l\'actif",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage(
      "Meilleurs gagnants",
    ),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage(
      "Plus grandes pertes",
    ),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage(
      "Déménageurs 24h",
    ),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "Aucun élément trouvé",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("D\'autres"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portefeuille"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Valeur totale"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage(
      "Ajouter un résultat",
    ),
    "g_pred_amount_input": m58,
    "g_pred_balance": m59,
    "g_pred_buy": MessageLookupByLibrary.simpleMessage("Acheter"),
    "g_pred_cancel_refund": MessageLookupByLibrary.simpleMessage(
      "Annuler et rembourser",
    ),
    "g_pred_close_only": MessageLookupByLibrary.simpleMessage(
      "Clôturer seulement",
    ),
    "g_pred_closed_waiting": MessageLookupByLibrary.simpleMessage(
      "Clôturé, en attente de résolution",
    ),
    "g_pred_confirm_resolve": MessageLookupByLibrary.simpleMessage(
      "Confirmer la résolution",
    ),
    "g_pred_confirm_resolve_msg": m60,
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Lancer la prédiction",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Création…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Échéance"),
    "g_pred_err_amount_low": MessageLookupByLibrary.simpleMessage(
      "Le montant doit être supérieur à 0",
    ),
    "g_pred_err_insufficient_balance": MessageLookupByLibrary.simpleMessage(
      "Solde insuffisant",
    ),
    "g_pred_err_insufficient_shares": MessageLookupByLibrary.simpleMessage(
      "Parts insuffisantes",
    ),
    "g_pred_err_invalid_outcome": MessageLookupByLibrary.simpleMessage(
      "Résultat invalide",
    ),
    "g_pred_err_invalid_state": MessageLookupByLibrary.simpleMessage(
      "Le marché est déjà réglé, cette action n\'est pas autorisée",
    ),
    "g_pred_err_market_closed": MessageLookupByLibrary.simpleMessage(
      "Marché fermé, trading indisponible",
    ),
    "g_pred_err_market_not_found": MessageLookupByLibrary.simpleMessage(
      "Marché introuvable",
    ),
    "g_pred_err_not_resolved": MessageLookupByLibrary.simpleMessage(
      "Marché non résolu, échange impossible",
    ),
    "g_pred_err_not_resolver": MessageLookupByLibrary.simpleMessage(
      "Seul l\'hôte qui a créé ce marché peut effectuer cette action",
    ),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "Au moins deux résultats valides",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une question",
    ),
    "g_pred_err_slippage": MessageLookupByLibrary.simpleMessage(
      "Slippage dépassé, réessayez",
    ),
    "g_pred_minutes": m61,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("Non"),
    "g_pred_outcome_n": m62,
    "g_pred_outcome_win": m63,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Résultats"),
    "g_pred_pick_winner": MessageLookupByLibrary.simpleMessage(
      "Choisissez le résultat gagnant pour régler (fonds selon le résultat)",
    ),
    "g_pred_processing": MessageLookupByLibrary.simpleMessage("Traitement…"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Publier"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Question de prédiction, p. ex. Qui gagne cette manche ?",
    ),
    "g_pred_quote_info": m64,
    "g_pred_redeem_failed": m65,
    "g_pred_resolved": MessageLookupByLibrary.simpleMessage("Résolu"),
    "g_pred_result_label": m66,
    "g_pred_sell_n": m67,
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Illimité (clôture manuelle)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Oui"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Téléchargé"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Code d\'invitation",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invités"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Nœuds miniers"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Récompense (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Minage classique (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Minage (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Interface de Minage",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Partager"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Parrainage"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Parrainez des amis et obtenez des jetons N !",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage(
      "Vous obtenez jusqu\'à ",
    ),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N lorsque votre filleul commence la vérification !",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Parrainer via"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Lien"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("coder"),
    "g_swap_key_14": m68,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Erreur de récupération du prix du jeton.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "En continuant, vous acceptez les ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Conditions générales.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Terminer"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Votre échange sera distribué sous peu. Veuillez patienter.",
    ),
    "g_swap_key_20": m69,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Coûts pour faire fonctionner un nœud : Vérification de groupe 1-49 N Nœud basique : 50 N Nœud premium : 100 N Nœud pro : 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Non payé"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage(
      "Confirmation du paiement",
    ),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("À distribuer"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage(
      "Résumé de l\'échange",
    ),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("Nouveau solde"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("Vous payez"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Date"),
    "g_swap_key_31": m70,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Les échanges peuvent être consultés sur les explorateurs de chaîne concernés (Etherscan, BscScan, TRONSCAN et le nôtre).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Échanger vers N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Échanger"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("Vous recevez"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage(
      "Aperçu de l\'échange",
    ),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Couleur d\'accentuation",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser aux valeurs par défaut",
    ),
    "g_theme_mode": MessageLookupByLibrary.simpleMessage("Apparence"),
    "g_theme_style": MessageLookupByLibrary.simpleMessage("Style"),
    "g_theme_style_custom": MessageLookupByLibrary.simpleMessage(
      "Personnalisé",
    ),
    "g_token_m_key_1": m71,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "N\'importe qui peut créer un jeton, y compris des versions contrefaites de jetons existants. Effectuez toujours des recherches sur un jeton avant de l\'importer.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Jetons"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage(
      "Rechercher un jeton",
    ),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage(
      "Nom de la chaîne",
    ),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage(
      "Symbole de la chaîne",
    ),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("ID de la chaîne"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Décimales"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Ajouter une chaîne personnalisée",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 décimales"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage(
      "Ajouter des jetons",
    ),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage(
      "Erreur de format !",
    ),
    "g_token_m_key_22": m72,
    "g_token_m_key_23": m73,
    "g_token_m_key_24": m74,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage(
      "Importer des jetons",
    ),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("Tous les réseaux"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage(
      "Jeton personnalisé",
    ),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Adresse du jeton"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Symbole du jeton"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage(
      "Décimales du jeton",
    ),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Importer"),
    "g_token_m_key_chainid_conflict": MessageLookupByLibrary.simpleMessage(
      "Cet ID de chaîne est déjà utilisé par un autre réseau.",
    ),
    "g_token_m_key_chainid_mismatch": m75,
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Attention"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Risque Élevé"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Sûr"),
    "g_ui_aave_lending": MessageLookupByLibrary.simpleMessage("Prêt Aave V3"),
    "g_ui_account_email": MessageLookupByLibrary.simpleMessage(
      "Courriel du compte",
    ),
    "g_ui_algo_asset_add_fee": MessageLookupByLibrary.simpleMessage(
      "L\'ajout de cet actif nécessite un frais réseau. Appuyez sur Ajouter pour continuer.",
    ),
    "g_ui_algo_asset_missing": m76,
    "g_ui_assistant_hint": MessageLookupByLibrary.simpleMessage(
      "Demandez le solde, le portefeuille, les frais de réseau",
    ),
    "g_ui_back_code": MessageLookupByLibrary.simpleMessage("Retour au code"),
    "g_ui_back_email": MessageLookupByLibrary.simpleMessage(
      "Retour à l\'e-mail",
    ),
    "g_ui_backup_create_save": MessageLookupByLibrary.simpleMessage(
      "Créer et enregistrer la sauvegarde",
    ),
    "g_ui_backup_empty": MessageLookupByLibrary.simpleMessage(
      "Aucun portefeuille trouvé dans le fichier de sauvegarde",
    ),
    "g_ui_backup_encryption_hint": MessageLookupByLibrary.simpleMessage(
      "Votre sauvegarde est chiffrée avec AES-256 + PBKDF2. Seul le bon mot de passe permet de la restaurer.",
    ),
    "g_ui_backup_enter_password": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le mot de passe de sauvegarde",
    ),
    "g_ui_backup_export": MessageLookupByLibrary.simpleMessage(
      "Exporter la sauvegarde cloud",
    ),
    "g_ui_backup_export_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de créer la sauvegarde. Veuillez réessayer.",
    ),
    "g_ui_backup_file": MessageLookupByLibrary.simpleMessage(
      "Fichier de sauvegarde",
    ),
    "g_ui_backup_file_access": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'accéder au fichier sélectionné",
    ),
    "g_ui_backup_import": MessageLookupByLibrary.simpleMessage(
      "Importer la sauvegarde cloud",
    ),
    "g_ui_backup_import_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de restaurer la sauvegarde. Vérifiez le mot de passe et le fichier de sauvegarde, puis réessayez.",
    ),
    "g_ui_backup_import_result": m77,
    "g_ui_backup_import_wallets": MessageLookupByLibrary.simpleMessage(
      "Importer les portefeuilles",
    ),
    "g_ui_backup_invalid_file": MessageLookupByLibrary.simpleMessage(
      "Ce n\'est pas un fichier de sauvegarde N42Wallet valide",
    ),
    "g_ui_backup_no_file": MessageLookupByLibrary.simpleMessage(
      "Aucun fichier sélectionné",
    ),
    "g_ui_backup_no_selection": MessageLookupByLibrary.simpleMessage(
      "Aucun portefeuille valide sélectionné pour la sauvegarde",
    ),
    "g_ui_backup_password": MessageLookupByLibrary.simpleMessage(
      "Mot de passe de sauvegarde",
    ),
    "g_ui_backup_password_hint": MessageLookupByLibrary.simpleMessage(
      "Définissez un mot de passe de sauvegarde fort (minimum 8 caractères)",
    ),
    "g_ui_backup_password_min": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit comporter au moins 8 caractères",
    ),
    "g_ui_backup_password_repeat": MessageLookupByLibrary.simpleMessage(
      "Saisissez à nouveau le mot de passe de sauvegarde",
    ),
    "g_ui_backup_restore_hint": MessageLookupByLibrary.simpleMessage(
      "Restaurez vos portefeuilles à partir d\'une sauvegarde chiffrée stockée sur iCloud Drive ou Google Drive.",
    ),
    "g_ui_backup_restore_none": MessageLookupByLibrary.simpleMessage(
      "Aucun portefeuille ne peut être restauré à partir de cette sauvegarde",
    ),
    "g_ui_backup_restore_password_hint": MessageLookupByLibrary.simpleMessage(
      "Saisissez le mot de passe utilisé lors de la création de la sauvegarde",
    ),
    "g_ui_backup_select_file_first": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner un fichier de sauvegarde en premier",
    ),
    "g_ui_backup_select_wallet": MessageLookupByLibrary.simpleMessage(
      "Veuillez sélectionner au moins un portefeuille à sauvegarder",
    ),
    "g_ui_backup_select_wallets": MessageLookupByLibrary.simpleMessage(
      "Sélectionner les portefeuilles à sauvegarder",
    ),
    "g_ui_backup_share_subject": MessageLookupByLibrary.simpleMessage(
      "Sauvegarde N42Wallet",
    ),
    "g_ui_backup_warning": MessageLookupByLibrary.simpleMessage(
      "Cette sauvegarde contient vos clés privées / mnémoniques, mots de passe de portefeuille et paramètres de portefeuille. Gardez le fichier de sauvegarde et le mot de passe en sécurité. Ne les partagez jamais avec personne.",
    ),
    "g_ui_balance_value": m78,
    "g_ui_base_fee_value": m79,
    "g_ui_buy_n_description": MessageLookupByLibrary.simpleMessage(
      "Acheter N via le protocole N42",
    ),
    "g_ui_calldata_hex": MessageLookupByLibrary.simpleMessage(
      "Données de transaction (hex)",
    ),
    "g_ui_camera_permission": MessageLookupByLibrary.simpleMessage(
      "L\'autorisation de la caméra est requise pour scanner un code.",
    ),
    "g_ui_cancel_order": MessageLookupByLibrary.simpleMessage(
      "Annuler la commande",
    ),
    "g_ui_change_email": MessageLookupByLibrary.simpleMessage(
      "Changer l\'e-mail",
    ),
    "g_ui_checking_approval": MessageLookupByLibrary.simpleMessage(
      "Vérification de l\'autorisation…",
    ),
    "g_ui_clipboard_clear": m80,
    "g_ui_clipboard_empty": MessageLookupByLibrary.simpleMessage(
      "Le presse-papiers est vide",
    ),
    "g_ui_coins_load_failed": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement des pièces. Veuillez réessayer.",
    ),
    "g_ui_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirmer le mot de passe",
    ),
    "g_ui_confirm_update": MessageLookupByLibrary.simpleMessage(
      "Confirmer la mise à jour",
    ),
    "g_ui_contract_info": MessageLookupByLibrary.simpleMessage(
      "Informations du contrat",
    ),
    "g_ui_create_wallet": MessageLookupByLibrary.simpleMessage(
      "Créer un portefeuille",
    ),
    "g_ui_csv_header_only": MessageLookupByLibrary.simpleMessage(
      "Aucune ligne de données trouvée (seul l\'en-tête détecté).",
    ),
    "g_ui_csv_missing_fields": m81,
    "g_ui_csv_no_data": MessageLookupByLibrary.simpleMessage(
      "Aucune donnée trouvée après suppression des commentaires.",
    ),
    "g_ui_custom_tag": MessageLookupByLibrary.simpleMessage(
      "Balise personnalisée...",
    ),
    "g_ui_days": m82,
    "g_ui_destination_tag": MessageLookupByLibrary.simpleMessage(
      "Balise de destination",
    ),
    "g_ui_device_connected": m83,
    "g_ui_dex_description": MessageLookupByLibrary.simpleMessage(
      "Échanger des jetons via Uniswap / 1inch / Jupiter",
    ),
    "g_ui_email_code_accepted": MessageLookupByLibrary.simpleMessage(
      "Code de vérification accepté",
    ),
    "g_ui_email_code_sent": MessageLookupByLibrary.simpleMessage(
      "Demande de code de vérification envoyée",
    ),
    "g_ui_ens_price_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les prix de renouvellement ENS. Veuillez réessayer.",
    ),
    "g_ui_ens_renew_failed": MessageLookupByLibrary.simpleMessage(
      "Le renouvellement ENS a échoué. Veuillez réessayer.",
    ),
    "g_ui_entry_price": MessageLookupByLibrary.simpleMessage("Prix d\'entrée"),
    "g_ui_expires_in": MessageLookupByLibrary.simpleMessage("Expire dans :"),
    "g_ui_fear_greed": MessageLookupByLibrary.simpleMessage("Peur et avidité"),
    "g_ui_file_picker_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'ouvrir le sélecteur de fichiers. Veuillez réessayer.",
    ),
    "g_ui_file_read_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire le fichier sélectionné. Veuillez réessayer.",
    ),
    "g_ui_free_margin": MessageLookupByLibrary.simpleMessage("Libre"),
    "g_ui_gas_prediction": MessageLookupByLibrary.simpleMessage(
      "Prédiction du prix du gaz pour le bloc suivant",
    ),
    "g_ui_gas_value": m84,
    "g_ui_hours": m85,
    "g_ui_import_valid": m86,
    "g_ui_invalid_email": MessageLookupByLibrary.simpleMessage(
      "Entrez une adresse e-mail valide",
    ),
    "g_ui_issues_label": MessageLookupByLibrary.simpleMessage("Problèmes :"),
    "g_ui_keystone_paired": MessageLookupByLibrary.simpleMessage(
      "Keystone appairé avec succès",
    ),
    "g_ui_limit_orders": MessageLookupByLibrary.simpleMessage("Ordres limites"),
    "g_ui_limit_price": MessageLookupByLibrary.simpleMessage("Prix limite"),
    "g_ui_limit_price_pair": m87,
    "g_ui_limit_value": m88,
    "g_ui_liquidation_price": MessageLookupByLibrary.simpleMessage(
      "Prix de liquidation",
    ),
    "g_ui_margin_utilization": MessageLookupByLibrary.simpleMessage(
      "Utilisation",
    ),
    "g_ui_markets_count": m89,
    "g_ui_memo": MessageLookupByLibrary.simpleMessage("Mémo"),
    "g_ui_mempool": MessageLookupByLibrary.simpleMessage("Mempool"),
    "g_ui_message": MessageLookupByLibrary.simpleMessage("Message"),
    "g_ui_min_balance_value": m90,
    "g_ui_mnemonic_wallet": MessageLookupByLibrary.simpleMessage(
      "Portefeuille mnémonique",
    ),
    "g_ui_mpc_intro": MessageLookupByLibrary.simpleMessage(
      "Connectez-vous avec votre compte social pour créer un portefeuille MPC sécurisé. Votre clé privée est divisée en parts chiffrées — aucune phrase de récupération à perdre.",
    ),
    "g_ui_mpc_no_phrase": MessageLookupByLibrary.simpleMessage(
      "Aucune phrase de récupération nécessaire",
    ),
    "g_ui_mpc_security": MessageLookupByLibrary.simpleMessage(
      "Fonctionne avec MPC-TSS. Votre clé est divisée en 3 parts chiffrées réparties sur votre appareil, nos serveurs et une sauvegarde de récupération.",
    ),
    "g_ui_new_email": MessageLookupByLibrary.simpleMessage(
      "Nouvelle adresse e-mail",
    ),
    "g_ui_no_cached_email": MessageLookupByLibrary.simpleMessage(
      "Aucun e-mail n\'est enregistré sur cet appareil",
    ),
    "g_ui_no_coins": MessageLookupByLibrary.simpleMessage(
      "Aucune pièce pour le moment",
    ),
    "g_ui_no_dapps": MessageLookupByLibrary.simpleMessage("Aucune DApp"),
    "g_ui_no_limit_orders": MessageLookupByLibrary.simpleMessage(
      "Aucun ordre limite",
    ),
    "g_ui_no_orders": MessageLookupByLibrary.simpleMessage(
      "Aucun ordre ouvert",
    ),
    "g_ui_no_positions": MessageLookupByLibrary.simpleMessage(
      "Aucune position ouverte",
    ),
    "g_ui_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Aucun portefeuille pour le moment",
    ),
    "g_ui_optional": MessageLookupByLibrary.simpleMessage("Facultatif"),
    "g_ui_order_cancel_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'annulation",
    ),
    "g_ui_order_cancelled": MessageLookupByLibrary.simpleMessage(
      "Commande annulée",
    ),
    "g_ui_order_create_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de la création de la commande",
    ),
    "g_ui_order_created": MessageLookupByLibrary.simpleMessage(
      "Ordre limite créé",
    ),
    "g_ui_order_executed": MessageLookupByLibrary.simpleMessage("Exécuté"),
    "g_ui_order_place": MessageLookupByLibrary.simpleMessage(
      "Placer un ordre limite",
    ),
    "g_ui_order_triggered": MessageLookupByLibrary.simpleMessage("Déclenché"),
    "g_ui_orders_count": m91,
    "g_ui_orders_load_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de charger les ordres limites",
    ),
    "g_ui_password_mismatch": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas",
    ),
    "g_ui_paste_connection": MessageLookupByLibrary.simpleMessage(
      "Collez le lien de connexion",
    ),
    "g_ui_pending_mempool": MessageLookupByLibrary.simpleMessage(
      "En attente (Mempool)",
    ),
    "g_ui_popular_tokens": MessageLookupByLibrary.simpleMessage(
      "Tokens populaires",
    ),
    "g_ui_position_size": MessageLookupByLibrary.simpleMessage("Taille"),
    "g_ui_positions_count": m92,
    "g_ui_private_key_wallet": MessageLookupByLibrary.simpleMessage(
      "Portefeuille clé privée",
    ),
    "g_ui_read_only": MessageLookupByLibrary.simpleMessage("Lecture seule"),
    "g_ui_recipients_count": m93,
    "g_ui_room_id": MessageLookupByLibrary.simpleMessage("ID de salle"),
    "g_ui_save_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'enregistrement. Veuillez réessayer.",
    ),
    "g_ui_send_code": MessageLookupByLibrary.simpleMessage("Envoyer le code"),
    "g_ui_sending_request": MessageLookupByLibrary.simpleMessage(
      "Envoi de la demande...",
    ),
    "g_ui_swap_mode": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le mode d\'échange",
    ),
    "g_ui_tags": MessageLookupByLibrary.simpleMessage("Balises"),
    "g_ui_template_copied": MessageLookupByLibrary.simpleMessage(
      "Modèle copié",
    ),
    "g_ui_token_contract_hint": MessageLookupByLibrary.simpleMessage(
      "Contrat du jeton (0x...)",
    ),
    "g_ui_token_found": m94,
    "g_ui_token_lookup": MessageLookupByLibrary.simpleMessage(
      "Recherche d\'informations sur le jeton…",
    ),
    "g_ui_token_manual": MessageLookupByLibrary.simpleMessage(
      "Jetons non trouvé dans la liste — renseignez manuellement le symbole et le nombre de décimales",
    ),
    "g_ui_token_value": m95,
    "g_ui_trade_delete_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de supprimer l\'échange. Veuillez réessayer.",
    ),
    "g_ui_trade_save_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible d\'enregistrer l\'échange. Veuillez réessayer.",
    ),
    "g_ui_transaction_hash_value": m96,
    "g_ui_unknown_status": MessageLookupByLibrary.simpleMessage(
      "Statut inconnu",
    ),
    "g_ui_update": MessageLookupByLibrary.simpleMessage("Mettre à jour"),
    "g_ui_update_email": MessageLookupByLibrary.simpleMessage(
      "Mettre à jour l\'e-mail",
    ),
    "g_ui_validation_counts": m97,
    "g_ui_validation_issues": MessageLookupByLibrary.simpleMessage(
      "Problèmes de validation",
    ),
    "g_ui_validation_more": m98,
    "g_ui_verification_code": MessageLookupByLibrary.simpleMessage(
      "Code de vérification",
    ),
    "g_ui_verify_code": MessageLookupByLibrary.simpleMessage(
      "Vérifier le code",
    ),
    "g_ui_view_market": MessageLookupByLibrary.simpleMessage(
      "Voir les données du marché",
    ),
    "g_ui_volume_24h": MessageLookupByLibrary.simpleMessage("Volume 24h"),
    "g_ui_volume_interest": m99,
    "g_ui_wallet_ai": MessageLookupByLibrary.simpleMessage(
      "IA du portefeuille",
    ),
    "g_ui_wallet_get_started": MessageLookupByLibrary.simpleMessage(
      "Créez ou importez un portefeuille pour commencer",
    ),
    "g_ui_wallet_load_failed": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement du portefeuille",
    ),
    "g_ui_wallet_loading": MessageLookupByLibrary.simpleMessage(
      "Chargement du portefeuille...",
    ),
    "g_ui_wallet_number": m100,
    "g_version_later": MessageLookupByLibrary.simpleMessage("Plus tard"),
    "g_wallet_balance_warning": MessageLookupByLibrary.simpleMessage(
      "Le solde n\'a pas pu être actualisé",
    ),
    "g_wallet_coin_total_value": MessageLookupByLibrary.simpleMessage(
      "Valeur totale",
    ),
    "g_wallet_coin_unit_price": MessageLookupByLibrary.simpleMessage("Prix"),
    "g_wallet_group_hd": MessageLookupByLibrary.simpleMessage(
      "Portefeuille HD · Mnémonique",
    ),
    "g_wallet_group_single": MessageLookupByLibrary.simpleMessage(
      "Chaîne unique · Importé",
    ),
    "g_wallet_pin_token": MessageLookupByLibrary.simpleMessage(
      "Épingler le jeton",
    ),
    "g_wallet_prices_cached": MessageLookupByLibrary.simpleMessage(
      "Prix sauvegardés",
    ),
    "g_wallet_prices_hours": m101,
    "g_wallet_prices_just_updated": MessageLookupByLibrary.simpleMessage(
      "Mis à jour maintenant",
    ),
    "g_wallet_prices_minutes": m102,
    "g_wallet_prices_partial": MessageLookupByLibrary.simpleMessage(
      "Prix partiels",
    ),
    "g_wallet_prices_unavailable": MessageLookupByLibrary.simpleMessage(
      "Prix indisponibles",
    ),
    "g_wallet_receiver_address": MessageLookupByLibrary.simpleMessage(
      "Adresse du destinataire",
    ),
    "g_wallet_sender_address": MessageLookupByLibrary.simpleMessage(
      "Adresse de l’expéditeur",
    ),
    "g_wallet_unpin_token": MessageLookupByLibrary.simpleMessage(
      "Désépingler le jeton",
    ),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Connexion perdue. Veuillez vous reconnecter.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "La DApp s\'est déconnectée",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Tout déconnecter",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Se déconnecter de toutes les DApps ?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Se déconnecter de cette DApp ?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "Aucune connexion active",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Scannez un QR code pour vous connecter à une DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "La demande de connexion a expiré",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "La session a expiré",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("DApps connectées"),
    "g_xrp_dest_tag_hint": MessageLookupByLibrary.simpleMessage(
      "Généralement requis pour un envoi vers une plateforme",
    ),
    "g_xrp_optional": MessageLookupByLibrary.simpleMessage("(Facultatif)"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Lier",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Avis important"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "next": MessageLookupByLibrary.simpleMessage("Suivant"),
    "nicknameMessage": m103,
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Modifier le profil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Photographie"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer l\'adresse",
    ),
    "push_bg_delivery_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Ce périphérique limite les applications en arrière-plan, vous pourriez donc manquer les messages de discussion et les alertes de transfert lorsque l\'application est en arrière-plan ou fermée.\n\nAppuyez sur \"Aller aux paramètres\" pour autoriser l\'activité en arrière-plan, puis activez le démarrage automatique pour cette application.",
    ),
    "push_bg_delivery_dialog_title": MessageLookupByLibrary.simpleMessage(
      "La livraison en arrière-plan peut être limitée",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Ne plus rappeler",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage(
      "Plus tard",
    ),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Aller aux paramètres",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Les notifications push sont désactivées. Vous pourriez manquer des messages de chat et des alertes de transfert.\n\nVeuillez activer les notifications pour cette application dans les paramètres système.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notifications désactivées",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage(
      "Ressaisissez le mot de passe",
    ),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Choisissez un mot de passe (8~18 caractères)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirmer le mot de passe",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage(
      "À propos de l\'application",
    ),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Sécurité"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Opération"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Langue"),
    "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "verification": MessageLookupByLibrary.simpleMessage("vérification"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "Si je perds ma phrase secrète, mes fonds seront perdus à jamais.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "Si je révèle ou partage ma phrase de récupération à quiconque, mes fonds peuvent être volés.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "Il est de ma responsabilité de garder ma phrase de récupération en sécurité.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage(
      "Phrase de récupération incorrecte.",
    ),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Entrez la phrase de récupération du portefeuille que vous souhaitez importer.",
    ),
  };
}
