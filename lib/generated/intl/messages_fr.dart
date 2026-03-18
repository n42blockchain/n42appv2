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

  static String m3(value) => "Je suis ${value}";

  static String m4(value) => "Membre du chat (${value})";

  static String m5(value) =>
      "Êtes-vous sûr de vouloir ajouter ${value} comme ami";

  static String m6(email) => "Code de vérification envoyé à ${email}";

  static String m7(s) => "Renvoyer dans ${s}s";

  static String m8(value) =>
      "Vous êtes déjà lié et ne pouvez pas être relié pour le moment. Adresse de liaison : ${value}.";

  static String m9(value) => "Liaison réussie. Adresse de liaison : ${value}";

  static String m10(value) =>
      "Il n\'y a pas de chaîne N42 dans le portefeuille ${value} !";

  static String m11(value) => "Correspondance réussie. Adresse : ${value}.";

  static String m12(value) => "Montant supérieur à ${value}.";

  static String m13(value) =>
      "Le portefeuille existe déjà, le nom du portefeuille est \"${value}\"";

  static String m14(value) => "Entrez un montant supérieur à ${value}.";

  static String m15(gas) =>
      "Le gas d\'exécution (${gas}) est élevé. Le contrat appelé peut consommer plus de gas que prévu.";

  static String m16(gas) =>
      "La première transaction inclut le déploiement du compte (~${gas} gas). Les transactions suivantes seront moins chères.";

  static String m17(gas) =>
      "La surcharge de gas du paymaster (${gas}) est élevée. Les transactions sans gas peuvent coûter plus cher.";

  static String m18(gas) =>
      "Le gas total estimé (${gas}) est inhabituellement élevé. Vérifiez votre transaction pour les erreurs.";

  static String m19(gas) =>
      "Le gas de vérification (${gas}) peut être trop élevé. Cela peut arriver avec une logique de compte complexe.";

  static String m20(value) => "${value} jours restants";

  static String m21(value) => "Adresse en double à la ligne ${value}";

  static String m22(value) =>
      "Solde insuffisant : le montant total dépasserait le ${value} disponible";

  static String m23(value) => "Adresse invalide à la ligne ${value}";

  static String m24(value) => "Montant invalide à la ligne ${value}";

  static String m25(value) => "Maximum ${value} destinataires";

  static String m26(token) => "Approuver ${token} pour continuer";

  static String m27(impact) =>
      "Impact prix élevé (${impact}) ! Procédez avec prudence.";

  static String m28(secs) => "Le devis expire dans ${secs}s";

  static String m29(value) => "+${value} pts/jour";

  static String m30(value) => "Gagnez jusqu\'à ${value}% APY";

  static String m31(value) =>
      "Félicitations ! Vous possédez maintenant ${value}";

  static String m32(value) => "Veuillez patienter ${value} secondes";

  static String m33(value) =>
      "Actualisation automatique toutes les secondes ${value}";

  static String m34(address) => "Compte ${address} ajouté";

  static String m35(address, network) =>
      "Voulez-vous suivre ce compte de hardware wallet?\n\nAdresse: ${address}\nRéseau: ${network}";

  static String m36(app) => "Application actuelle : ${app}";

  static String m37(days) => "${days} il y a jours";

  static String m38(value) => "Échec de l\'importation du compte: ${value}";

  static String m39(date) => "Dernière connexion : ${date}";

  static String m40(value) =>
      "Veuillez ouvrir l\'app ${value} sur votre appareil";

  static String m41(app) =>
      "Assurez-vous que l\'application ${app} est ouverte sur votre Ledger";

  static String m42(name) =>
      "Êtes-vous sûr de vouloir supprimer « ${name} » des appareils enregistrés ?";

  static String m43(value) => "Gagnez des points ${value}";

  static String m44(value) =>
      "Gagnez des points ${value} pour chaque ami qui nous rejoint !";

  static String m45(value) => "${value} points pour le niveau suivant";

  static String m46(amount, token) => "≈ ${amount}${token}";

  static String m47(amount) => "≈ ${amount} USDT";

  static String m48(value) => "Est. gaz : ~${value} unités";

  static String m49(reason) => "Raison : ${reason}";

  static String m50(value) =>
      "Êtes-vous sûr de vouloir supprimer le contact ${value} ?";

  static String m51(value) => "${value}d dissocier";

  static String m52(value) => "${value} jours restants";

  static String m53(value) => "${value} jours restants";

  static String m54(value) =>
      "Le délocalisation prend des jours ${value}. Vos tokens seront verrouillés pendant cette période.";

  static String m55(value) => "Vous n\'avez pas assez de \"${value}\"";

  static String m56(value) => "Échec de la récupération du compte \"${value}\"";

  static String m57(value) => "Minimum ${value} XRP pour le premier transfert";

  static String m58(value) => "${value}j il y a";

  static String m59(value) => "Il y a ${value}h";

  static String m60(value) => "Il y a ${value}m";

  static String m61(count) => "Ajouter (${count})";

  static String m62(count) =>
      "${Intl.plural(count, one: '1 nouveau jeton détecté', other: '${count} nouveaux jetons détectés')} — appuyez pour examiner";

  static String m63(value) => "Code de vérification envoyé à ${value}";

  static String m64(value) => "Aucune chaîne ${value} ajoutée.";

  static String m65(value) =>
      "${value} a des transactions non terminées, veuillez réessayer plus tard.";

  static String m66(value) => "Aucune adresse trouvée pour ${value}.";

  static String m67(value) => "Solde insuffisant de ${value}.";

  static String m68(value, value1) =>
      "Chaque compte XRP doit réserver ${value} XRP (${value1} drops) comme base, qui ne peut pas être dépensé.";

  static String m69(value, value1) =>
      "Pour chaque objet que le compte possède, ${value} XRP (${value1} drops) est ajouté à la réserve.";

  static String m70(value, value1) =>
      "Ce compte possède ${value} objets, ce qui signifie qu\'un ${value1} XRP supplémentaire est réservé.";

  static String m71(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentatives";

  static String m72(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentative";

  static String m73(value) =>
      "Vous avez configuré avec succès un ${value} et commencerez la vérification avec N42Wallet !";

  static String m74(value) =>
      "Rejoignez mon groupe ${value} sur @N42Wallet pour être l\'un des premiers mineurs d\'une chaîne Layer 1, et obtenez des cryptos sur votre téléphone !";

  static String m75(value, value1) =>
      "Êtes-vous sûr de vouloir verrouiller ${value} N jusqu\'à ${value1} pour faire fonctionner un nœud ?";

  static String m76(value) => "Échec de l\'importation : ${value}";

  static String m77(value) =>
      "Un solde de staking d\'au moins ${value} est requis pour recevoir des récompenses.";

  static String m78(value, value1) =>
      "${value} N tous les ${value1} blocs minés";

  static String m79(value) => "Doit contenir ${value} caractères";

  static String m80(value) => "Solde insuffisant de ${value}.";

  static String m81(value) => "${value} en cours de réception...";

  static String m82(value) =>
      "Les ${value} échangés dans l\'application seront distribués sous peu dans votre portefeuille et ne peuvent pas être vendus via ce processus. Ils peuvent être utilisés pour faire fonctionner un nœud.";

  static String m83(value) => "Maximum ${value} caractères";

  static String m84(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP !";

  static String m85(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP, voulez-vous l\'ajouter ?";

  static String m86(value) =>
      "Échec du test de connexion à l\'adresse ${value} !";

  static String m87(value) =>
      "L\'application se déverrouillera dans ${value} secondes.";

  static String m88(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentatives";

  static String m89(value) =>
      "Erreur de saisie du mot de passe, il vous reste ${value} tentatives";

  static String m90(value) =>
      "Erreur de saisie du mot de passe, il vous reste ${value} tentative";

  static String m91(value) => "Entrez le mot de passe ${value}";

  static String m92(value) => "0~${value} caractères";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("S\'inscrire"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Créer votre compte",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Modifier"),
    "Verification": MessageLookupByLibrary.simpleMessage("Vérification"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Informations de l\'adresse",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Compte temporairement verrouillé pendant un jour",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "Le code est incorrect. Veuillez réessayer.",
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
    "editPhoto": MessageLookupByLibrary.simpleMessage("Modifier la photo"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'obtention du code d\'authentification",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Code d\'authentification envoyé avec succès, veuillez vérifier votre e-mail",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Erreur du code d\'authentification",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Adresse e-mail invalide",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Authentification de l\'adresse e-mail",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "L\'application d\'authentification par adresse e-mail protège vos retraits et votre compte N42Wallet.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Ajouter la vérification par e-mail ?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("Fichier"),
    "g_2fa_backup_hint": MessageLookupByLibrary.simpleMessage(
      "Sauvegardez cette clé — vous en aurez besoin si vous perdez votre téléphone.",
    ),
    "g_2fa_backup_share": MessageLookupByLibrary.simpleMessage("Partager"),
    "g_2fa_backup_share_text": MessageLookupByLibrary.simpleMessage(
      "Clé de sauvegarde Google Authenticator de N42Wallet",
    ),
    "g_2fa_disable_confirm_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez votre code Google Authenticator à 6 chiffres pour confirmer la désactivation du 2FA.",
    ),
    "g_2fa_disable_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Désactiver Google 2FA",
    ),
    "g_2fa_disable_error": MessageLookupByLibrary.simpleMessage(
      "Échec de la désactivation de Google 2FA. Vérifiez le code et réessayez.",
    ),
    "g_2fa_disable_success": MessageLookupByLibrary.simpleMessage(
      "Google 2FA a été désactivé",
    ),
    "g_2fa_invalid_format": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer un code valide à 6 chiffres",
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
    "g_biometric_locked_out": MessageLookupByLibrary.simpleMessage(
      "Trop de tentatives. Biométrie verrouillée — utilisez votre code.",
    ),
    "g_biometric_not_enrolled": MessageLookupByLibrary.simpleMessage(
      "Biométrie non configurée. Activez-la dans Réglages.",
    ),
    "g_biometric_retry": MessageLookupByLibrary.simpleMessage(
      "Utiliser Face ID / Touch ID",
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
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Veuillez confirmer la connexion à la DApp",
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
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Démarrer une discussion de groupe",
    ),
    "g_chat_key_10": m3,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Inviter des amis"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un contact",
    ),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez au moins 2 contacts",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Détails de l\'ami"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Détails du groupe"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "Voir plus de membres du groupe",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Nom du groupe"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("Nouvel ami"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir dissoudre le groupe ?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir quitter ce groupe ?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage(
      "Dissoudre le groupe",
    ),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Quitter le groupe"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Changer le nom du groupe",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "Lorsque le nom du groupe est modifié, les autres membres seront notifiés au sein du groupe.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage(
      "Demande d\'ajout d\'ami",
    ),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Demande de vous ajouter comme ami",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Demande d\'ami approuvée",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Ajouté"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "Vous avez été ajouté comme ami",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("Accepter"),
    "g_chat_key_32": m4,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe ne peut pas être analysé correctement et le message ne peut pas être envoyé temporairement. Veuillez importer le portefeuille lors de l\'entrée dans le groupe",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'historique du chat ?",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage(
      "Supprimer le membre",
    ),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("Mon code QR"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Signaler"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage(
      "Nouvelle discussion",
    ),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("Nouveau groupe"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("Code QR"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage(
      "Signaler et bloquer",
    ),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "Ce message sera transféré à N42Wallet. Ce contact ne sera pas notifié.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Vidéo"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Photos"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage(
      "Supprimer le message",
    ),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Supprimer sur mon appareil",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Accepter"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage(
      "Raison du signalement",
    ),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Entrez la raison de votre signalement",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "Nous vérifierons votre signalement et répondrons dans les 24 heures.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "Vous avez signalé ceci - Cliquez pour voir",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Liste noire"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "g_chat_key_6": m5,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage(
      "Aucun contact pour le moment",
    ),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage(
      "Il y a plus de 3 jours",
    ),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Bloquer"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Salut, j\'utilise N42Wallet pour discuter et envoyer de l\'argent. Installe le portefeuille et envoie-moi un message à",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Répondre"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "Le message a été supprimé",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage(
      "Quelqu\'un m\'a mentionné",
    ),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Dire bonjour"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Ajouter des amis"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage(
      "Raison de la demande",
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
    "g_dapp_security_title": MessageLookupByLibrary.simpleMessage(
      "Sécurité des applications DApp",
    ),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage("Vérifié"),
    "g_email_also_sync": MessageLookupByLibrary.simpleMessage(
      "Synchronisez également l\'e-mail du compte Chat",
    ),
    "g_email_back_to_email": MessageLookupByLibrary.simpleMessage(
      "← Changer l\'adresse e-mail",
    ),
    "g_email_both_success": MessageLookupByLibrary.simpleMessage(
      "Les deux comptes ont été mis à jour avec succès !",
    ),
    "g_email_change_title": MessageLookupByLibrary.simpleMessage(
      "Changer l\'e-mail",
    ),
    "g_email_chat_code_hint": MessageLookupByLibrary.simpleMessage(
      "Saisissez le code de discussion à 6 chiffres",
    ),
    "g_email_chat_code_sent_to": MessageLookupByLibrary.simpleMessage(
      "Code de discussion envoyé à",
    ),
    "g_email_chat_confirm": MessageLookupByLibrary.simpleMessage(
      "Confirmer la synchronisation du chat",
    ),
    "g_email_chat_send_fail": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'envoi du code de chat",
    ),
    "g_email_chat_sending": MessageLookupByLibrary.simpleMessage(
      "Envoi du code de vérification du chat...",
    ),
    "g_email_chat_sync_title": MessageLookupByLibrary.simpleMessage(
      "Synchroniser l\'e-mail du compte de chat",
    ),
    "g_email_code_invalid": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le code à 6 chiffres",
    ),
    "g_email_code_resent": MessageLookupByLibrary.simpleMessage("Code renvoyé"),
    "g_email_code_sent_to": m6,
    "g_email_code_wrong": MessageLookupByLibrary.simpleMessage(
      "Code incorrect, veuillez réessayer",
    ),
    "g_email_confirm_change": MessageLookupByLibrary.simpleMessage(
      "Confirmer le changement",
    ),
    "g_email_confirm_continue": MessageLookupByLibrary.simpleMessage(
      "Confirmer et continuer la synchronisation du chat",
    ),
    "g_email_current_label": MessageLookupByLibrary.simpleMessage(
      "Courriel actuel",
    ),
    "g_email_enter_code": MessageLookupByLibrary.simpleMessage(
      "Entrez le code à 6 chiffres",
    ),
    "g_email_error_empty": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer une nouvelle adresse e-mail",
    ),
    "g_email_error_invalid": MessageLookupByLibrary.simpleMessage(
      "Adresse e-mail invalide",
    ),
    "g_email_error_same": MessageLookupByLibrary.simpleMessage(
      "Le nouvel e-mail doit être différent de l\'e-mail actuel",
    ),
    "g_email_n42_only": MessageLookupByLibrary.simpleMessage(
      "E-mail N42 mis à jour. L\'e-mail de chat peut être mis à jour dans Chat > ​​Paramètres.",
    ),
    "g_email_n42_updated": MessageLookupByLibrary.simpleMessage(
      "E-mail du compte N42 mis à jour",
    ),
    "g_email_new_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez une nouvelle adresse e-mail",
    ),
    "g_email_new_label": MessageLookupByLibrary.simpleMessage(
      "Nouvelle adresse e-mail",
    ),
    "g_email_pwd_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez le mot de passe",
    ),
    "g_email_pwd_label": MessageLookupByLibrary.simpleMessage(
      "Mot de passe actuel (pour Chat)",
    ),
    "g_email_pwd_required": MessageLookupByLibrary.simpleMessage(
      "Mot de passe requis pour la synchronisation du chat",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Renvoyer le code"),
    "g_email_resend_countdown": m7,
    "g_email_send_code": MessageLookupByLibrary.simpleMessage(
      "Envoyer le code de vérification",
    ),
    "g_email_skip": MessageLookupByLibrary.simpleMessage("Sauter"),
    "g_email_skip_full": MessageLookupByLibrary.simpleMessage(
      "Ignorer – L\'e-mail N42 est déjà mis à jour",
    ),
    "g_email_success": MessageLookupByLibrary.simpleMessage(
      "E-mail mis à jour avec succès",
    ),
    "g_face_1": MessageLookupByLibrary.simpleMessage(
      "Conseils de scan biométrique",
    ),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scannez votre empreinte digitale ou votre visage pour l\'authentification.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Le scan biométrique n\'a pas fonctionné",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Conseils"),
    "g_face_4": MessageLookupByLibrary.simpleMessage("Scan biométrique réussi"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("Configurer"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas configuré la connexion biométrique. Allez dans les paramètres système pour la configurer.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scannez votre visage ou empreinte digitale pour continuer.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "Il est recommandé de réactiver la biométrie.",
    ),
    "g_face_liveness_failed": MessageLookupByLibrary.simpleMessage(
      "Visage non détecté. Veuillez regarder directement la caméra et réessayer.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Méthode de correspondance faciale",
    ),
    "g_face_match_key10": m8,
    "g_face_match_key11": m9,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Relier"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Lier"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "Vous pouvez lier vos données faciales directement à une adresse de portefeuille (si vous en avez déjà lié une, l\'ancienne adresse sera écrasée), ou si vous avez déjà lié une adresse, vous pouvez également vérifier manuellement pour récupérer l\'adresse liée.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "L\'adresse du portefeuille liée à vos données faciales a été détectée comme suit, mais vous n\'avez pas encore importé ce portefeuille dans votre liste.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "Vous avez lié vos données faciales à ce portefeuille.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage(
      "Avis utilisateur",
    ),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "Qu\'est-ce que la liaison faciale ?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "La liaison faciale utilise la technologie de reconnaissance faciale pour faire correspondre vos caractéristiques biométriques faciales à votre adresse de portefeuille blockchain.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "Ce processus améliore non seulement la commodité des transactions, mais renforce également la sécurité du compte, garantissant que chaque action est autorisée par vous.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Pourquoi la liaison faciale est-elle nécessaire ?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "En liant vos données faciales, votre identité est directement liée aux activités de transaction, simplifiant le processus de vérification d\'identité et améliorant l\'efficacité opérationnelle. Cette technologie garantit une vérification d\'identité rapide et sécurisée lors d\'opérations sensibles telles que le transfert d\'actifs ou l\'interaction avec des contrats.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "Comment mes données faciales sont-elles stockées et sont-elles sécurisées ?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Vos données faciales sont stockées sous forme chiffrée sur une blockchain publique, et non dans une base de données centralisée. Cela signifie que le système ne peut déchiffrer et utiliser vos données pour la vérification d\'identité que lorsque vous l\'autorisez, garantissant ainsi la confidentialité et la sécurité de vos données.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "Comment la liaison faciale affecte-t-elle la sécurité de mon compte ?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "La liaison faciale renforce la sécurité de votre compte en s\'assurant que toutes les actions sensibles ne sont effectuées qu\'avec votre autorisation explicite. Nous utilisons une technologie de chiffrement de pointe pour protéger vos données biométriques, empêchant tout accès non autorisé.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Mes données faciales sont-elles sécurisées ?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolument. Toutes les données biométriques sont strictement chiffrées, et les normes de sécurité les plus élevées sont respectées pour la transmission et le stockage des données. Le système ne déchiffrera ces données que lorsque nécessaire pour effectuer la vérification d\'identité.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage(
      "Correspondance échouée !",
    ),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Compris"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Sélectionner l\'adresse du portefeuille",
    ),
    "g_face_match_key32": m10,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Déliaison"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Échec de la vérification des données faciales !",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Échec de la déliaison des données faciales !",
    ),
    "g_face_match_key4": m11,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage(
      "Erreur d\'adresse !",
    ),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Liaison des données faciales",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage(
      "Correspondance faciale",
    ),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Resélectionner"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Correspondre"),
    "g_face_network_error": MessageLookupByLibrary.simpleMessage(
      "Erreur réseau. Veuillez vérifier votre connexion et réessayer.",
    ),
    "g_face_sdk_init_failed": MessageLookupByLibrary.simpleMessage(
      "Impossible de démarrer la reconnaissance faciale. Veuillez réessayer.",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profil"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("Actualités"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Vérification"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Messages"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Apprendre"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Inviter un ami"),
    "g_key_1": MessageLookupByLibrary.simpleMessage(
      "Échec de la suppression !",
    ),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Envoyer"),
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
    "g_key_135": m12,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portefeuille principal"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaction réussie"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Mot de passe incorrect"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Réseau principal"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("Langue du système"),
    "g_key_15": MessageLookupByLibrary.simpleMessage(
      "Définir comme portefeuille principal",
    ),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Soumettre"),
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
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "Aucune autorisation d\'accès à l\'album photo.",
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
    "g_key_211": MessageLookupByLibrary.simpleMessage("Acheter"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Vendre"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Informations de marché"),
    "g_key_214": m13,
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
    "g_key_46": m14,
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
    "g_key_8": MessageLookupByLibrary.simpleMessage("Remarque"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Phrase de récupération"),
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
    "g_key_aa_address_preview": MessageLookupByLibrary.simpleMessage(
      "Cette adresse est pré-calculée et sera déployée lors de votre première transaction.",
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
    "g_key_aa_batch_title": MessageLookupByLibrary.simpleMessage(
      "Transfert par lots",
    ),
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
    "g_key_aa_biconomy_account": MessageLookupByLibrary.simpleMessage(
      "Compte Biconomy",
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
    "g_key_aa_clear_all": MessageLookupByLibrary.simpleMessage("Tout effacer"),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage(
      "Bientôt disponible",
    ),
    "g_key_aa_continue": MessageLookupByLibrary.simpleMessage("Continuer"),
    "g_key_aa_contract": MessageLookupByLibrary.simpleMessage("Contrat"),
    "g_key_aa_counterfactual_address": MessageLookupByLibrary.simpleMessage(
      "Adresse contrefactuelle",
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
    "g_key_aa_create_first_account": MessageLookupByLibrary.simpleMessage(
      "Créez un compte intelligent pour commencer",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Créer une clé de session",
    ),
    "g_key_aa_create_session_desc": MessageLookupByLibrary.simpleMessage(
      "Les clés de session permettent aux DApp d\'exécuter des transactions en votre nom avec des autorisations et des contraintes de temps limitées.",
    ),
    "g_key_aa_create_smart_account": MessageLookupByLibrary.simpleMessage(
      "Créer un compte intelligent",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Créé"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "g_key_aa_deploy": MessageLookupByLibrary.simpleMessage("Déployer"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Le compte sera déployé automatiquement lors de votre première transaction",
    ),
    "g_key_aa_deploy_failed": MessageLookupByLibrary.simpleMessage(
      "Échec du déploiement",
    ),
    "g_key_aa_deploy_failed_desc": MessageLookupByLibrary.simpleMessage(
      "Le déploiement a échoué. Veuillez réessayer.",
    ),
    "g_key_aa_deploy_started": MessageLookupByLibrary.simpleMessage(
      "Le déploiement a commencé",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Déployé"),
    "g_key_aa_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Le compte est prêt à être utilisé",
    ),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage(
      "Déploiement...",
    ),
    "g_key_aa_deploying_desc": MessageLookupByLibrary.simpleMessage(
      "La transaction de déploiement est en cours de traitement",
    ),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Le déploiement se fera automatiquement lors de votre première transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Découvrez la nouvelle génération de comptes Ethereum avec des fonctionnalités améliorées",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Détails"),
    "g_key_aa_eip7702_account": MessageLookupByLibrary.simpleMessage(
      "Compte EIP-7702",
    ),
    "g_key_aa_eip7702_badge": MessageLookupByLibrary.simpleMessage("EIP-7702"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybride EOA/Smart Account – Aucun déploiement nécessaire",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Erreur"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Gaz estimé",
    ),
    "g_key_aa_estimating": MessageLookupByLibrary.simpleMessage(
      "Estimation...",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Exécuter le lot",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expire"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Usine"),
    "g_key_aa_feature_batch": MessageLookupByLibrary.simpleMessage(
      "Regrouper plusieurs transactions",
    ),
    "g_key_aa_feature_gas": MessageLookupByLibrary.simpleMessage(
      "Payez l\'essence avec n\'importe quel jeton",
    ),
    "g_key_aa_feature_security": MessageLookupByLibrary.simpleMessage(
      "Sécurité renforcée",
    ),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("GRATUIT"),
    "g_key_aa_full_access": MessageLookupByLibrary.simpleMessage(
      "Accès complet",
    ),
    "g_key_aa_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Estimation du gaz",
    ),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'estimation du gaz, utilisation par défaut",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage(
      "Paiement du gaz",
    ),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Options de paiement du gaz",
    ),
    "g_key_aa_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Économies de gaz",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gaz sponsorisé",
    ),
    "g_key_aa_gas_warn_call_high": MessageLookupByLibrary.simpleMessage(
      "Gas d\'Exécution Élevé",
    ),
    "g_key_aa_gas_warn_call_high_desc": m15,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Surcharge de Déploiement",
    ),
    "g_key_aa_gas_warn_deploy_desc": m16,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Surcharge Paymaster Élevée",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m17,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite de Gas Très Élevée",
    ),
    "g_key_aa_gas_warn_total_high_desc": m18,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possible Sous-Estimation du Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Le gas réellement utilisé peut dépasser l\'estimation. Envisagez d\'ajouter une plus grande marge.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Vérification Élevé",
    ),
    "g_key_aa_gas_warn_verify_high_desc": m19,
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Sans gaz"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions sans gaz et opérations par lots",
    ),
    "g_key_aa_home_title": MessageLookupByLibrary.simpleMessage(
      "Abstraction du compte",
    ),
    "g_key_aa_just_now": MessageLookupByLibrary.simpleMessage(
      "Juste maintenant",
    ),
    "g_key_aa_kernel_account": MessageLookupByLibrary.simpleMessage(
      "Compte du noyau",
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
    "g_key_aa_never": MessageLookupByLibrary.simpleMessage("Jamais"),
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
    "g_key_aa_not_deployed_desc": MessageLookupByLibrary.simpleMessage(
      "Le compte sera déployé lors de la première transaction",
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
    "g_key_aa_paymaster_balance": MessageLookupByLibrary.simpleMessage("Solde"),
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
    "g_key_aa_paymaster_not_supported": MessageLookupByLibrary.simpleMessage(
      "Non disponible sur cette chaîne",
    ),
    "g_key_aa_paymaster_quote_expired": MessageLookupByLibrary.simpleMessage(
      "Devis expiré",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage(
      "Réessayer",
    ),
    "g_key_aa_paymaster_sponsored_unavailable":
        MessageLookupByLibrary.simpleMessage("Parrainage non disponible"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Autorisation"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Adresse d\'aperçu",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Prêt"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Adresse de réception",
    ),
    "g_key_aa_recommended": MessageLookupByLibrary.simpleMessage("Recommandé"),
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
    "g_key_aa_safe_account": MessageLookupByLibrary.simpleMessage(
      "Compte sécurisé",
    ),
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Compte multi-signature avec fonctionnalités de sécurité avancées",
    ),
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage("Gardiens"),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Seuil"),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("enregistré"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez la chaîne",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez Payeur",
    ),
    "g_key_aa_select_type": MessageLookupByLibrary.simpleMessage(
      "Sélectionnez le type de compte",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Sélectionné"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Envoyez des jetons en utilisant votre compte intelligent",
    ),
    "g_key_aa_send_title": MessageLookupByLibrary.simpleMessage("Transfert AA"),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 jour"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 heure"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 jours"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 jours"),
    "g_key_aa_session_allowed": MessageLookupByLibrary.simpleMessage(
      "Autorisé",
    ),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "ex. 100,00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Montant max.",
    ),
    "g_key_aa_session_blocked": MessageLookupByLibrary.simpleMessage("Bloqué"),
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
    "g_key_aa_simple_account": MessageLookupByLibrary.simpleMessage(
      "Compte simple",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent de base avec un seul propriétaire - recommandé pour la plupart des utilisateurs",
    ),
    "g_key_aa_smart_account": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent",
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
    "g_key_aa_total_value": MessageLookupByLibrary.simpleMessage(
      "Valeur totale",
    ),
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage("Opérations"),
    "g_key_aa_unavailable": MessageLookupByLibrary.simpleMessage(
      "Indisponible",
    ),
    "g_key_aa_version_v07": MessageLookupByLibrary.simpleMessage("v0.7"),
    "g_key_aa_version_v08": MessageLookupByLibrary.simpleMessage("v0.8"),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("Tout afficher"),
    "g_key_account_linked": MessageLookupByLibrary.simpleMessage(
      "Compte lié avec succès",
    ),
    "g_key_account_unlinked": MessageLookupByLibrary.simpleMessage(
      "Compte dissocié avec succès",
    ),
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
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Vérifier l\'Éligibilité",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Réclamer"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Réclamé"),
    "g_key_airdrop_days_left": m20,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage(
      "Date Limite",
    ),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("Éligible"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Valeur Estimée",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "Aucun airdrop disponible",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Non Éligible",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("En Attente"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "Haute Priorité",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Basse Priorité",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Priorité Moyenne",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Condition remplie",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Non remplie",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Conditions",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage("Trier Par"),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Suivi des Airdrops",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Total Réclamé",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("À Venir"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Connexion Apple annulée",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Postuler"),
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
    "g_key_batch_duplicate_address": m21,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimation du gaz...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Le transfert par lots prend uniquement en charge les chaînes EVM",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage(
      "Exécuter le Lot",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Exporter CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Économies de Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Aide sur le transfert par lots",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importer CSV",
    ),
    "g_key_batch_insufficient_balance": m22,
    "g_key_batch_invalid_address": m23,
    "g_key_batch_invalid_amount": m24,
    "g_key_batch_max_recipients": m25,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Le mémo est facultatif",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Utilisez Multicall3 pour réduire les frais de gaz",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "Aucun jeton pris en charge",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Aperçu"),
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
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Montant"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Chaîne non prise en charge",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Moins Cher"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "Vous recevrez (estimé)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Plus Rapide"),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("Frais de Pont"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage(
      "Chaîne Source",
    ),
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
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Pont"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Temps Estimé"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Pont"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage(
      "Chaîne Destination",
    ),
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
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Verrouillez BTC pour créer du vBTC et gagner des récompenses",
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
    "g_key_burn_nft_title": MessageLookupByLibrary.simpleMessage("Graver NFT"),
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "Cette chaîne ne prend pas encore en charge les transferts, restez à l\'écoute",
    ),
    "g_key_change_email": MessageLookupByLibrary.simpleMessage(
      "Changer l\'e-mail",
    ),
    "g_key_change_password": MessageLookupByLibrary.simpleMessage(
      "Changer le mot de passe",
    ),
    "g_key_change_password_desc": MessageLookupByLibrary.simpleMessage(
      "Entrez votre mot de passe actuel et définissez un nouveau mot de passe",
    ),
    "g_key_code_length": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir le code à 6 chiffres",
    ),
    "g_key_code_required": MessageLookupByLibrary.simpleMessage(
      "Un code de vérification est requis",
    ),
    "g_key_code_sent": MessageLookupByLibrary.simpleMessage(
      "Code de vérification envoyé",
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
    "g_key_confirm_new_password": MessageLookupByLibrary.simpleMessage(
      "Confirmer le nouveau mot de passe",
    ),
    "g_key_continue_with_apple": MessageLookupByLibrary.simpleMessage(
      "Continuer avec Apple",
    ),
    "g_key_continue_with_google": MessageLookupByLibrary.simpleMessage(
      "Continuer avec Google",
    ),
    "g_key_deadline_reminders": MessageLookupByLibrary.simpleMessage(
      "Rappels de délais",
    ),
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Approuvé ! Appuyez sur Échanger pour continuer.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Montant exact",
    ),
    "g_key_dex_approve_required": m26,
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
    "g_key_dex_price_impact_high": m27,
    "g_key_dex_quote_expires": m28,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Devis échoué",
    ),
    "g_key_dex_quote_refreshed": MessageLookupByLibrary.simpleMessage(
      "Devis actualisé",
    ),
    "g_key_dex_retry": MessageLookupByLibrary.simpleMessage("Réessayer"),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Rechercher symbole / nom / adresse",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage(
      "Sélectionner",
    ),
    "g_key_dex_slippage": MessageLookupByLibrary.simpleMessage(
      "Tolérance de Glissement",
    ),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Glissement maximum",
    ),
    "g_key_dex_sol_note": MessageLookupByLibrary.simpleMessage(
      "Solana swap : signez la transaction dans votre portefeuille Solana.",
    ),
    "g_key_dex_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana DEX swap pas encore pris en charge dans l\'app",
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
    "g_key_dex_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Transaction échouée",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("Vous Payez"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "Vous Recevez",
    ),
    "g_key_domain_resolve_hint": MessageLookupByLibrary.simpleMessage(
      "Prend en charge ENS (.eth), Unstoppable Domains (.crypto/.wallet/…) et Solana SNS (.sol)",
    ),
    "g_key_domain_sns_name": MessageLookupByLibrary.simpleMessage(
      "Service de noms Solana",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Domaine Solana introuvable",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Domaines imparables",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Domaine Unstoppable introuvable ou sans adresse pour cette chaîne",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Produits actifs",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage(
      "Transfert en lot",
    ),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Brûler"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Acheter N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Achetez N avec le protocole AST",
    ),
    "g_key_earn_claim_free": MessageLookupByLibrary.simpleMessage(
      "Réclamez des jetons gratuits",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Transfert inter-chaînes",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Bonus d\'enregistrement quotidien",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Échangez n\'importe quel token via Uniswap / 1inch",
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
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Minage de nœuds",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Gagnez des récompenses en participant au minage de nœuds",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "Gagnez des points quotidiennement",
    ),
    "g_key_earn_pts_day": m29,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Outils rapides",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommandé",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Sélectionner le type d\'échange",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Miser ETH avec Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Échanger"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Gagner"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Gains totaux",
    ),
    "g_key_earn_up_to_apy": m30,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage(
      "Tout afficher",
    ),
    "g_key_eligibility_alerts": MessageLookupByLibrary.simpleMessage(
      "Alertes d\'éligibilité",
    ),
    "g_key_eligible_only": MessageLookupByLibrary.simpleMessage(
      "Éligible uniquement",
    ),
    "g_key_email": MessageLookupByLibrary.simpleMessage("Courriel"),
    "g_key_email_invalid": MessageLookupByLibrary.simpleMessage(
      "Veuillez saisir une adresse e-mail valide",
    ),
    "g_key_email_required": MessageLookupByLibrary.simpleMessage(
      "L\'e-mail est requis",
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
    "g_key_ens_commit_tx": MessageLookupByLibrary.simpleMessage(
      "Validation de la transaction...",
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
    "g_key_ens_duration": MessageLookupByLibrary.simpleMessage(
      "Période d\'inscription",
    ),
    "g_key_ens_edit_records": MessageLookupByLibrary.simpleMessage(
      "Modifier les enregistrements",
    ),
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expiré"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expire"),
    "g_key_ens_expiring_soon": MessageLookupByLibrary.simpleMessage(
      "Expire bientôt",
    ),
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
    "g_key_ens_home_title": MessageLookupByLibrary.simpleMessage(
      "Responsable ENS",
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
    "g_key_ens_management_title": MessageLookupByLibrary.simpleMessage(
      "Gérer l\'ENS",
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
    "g_key_ens_no_names": MessageLookupByLibrary.simpleMessage(
      "Vous ne possédez pas encore de noms ENS",
    ),
    "g_key_ens_owned_names": MessageLookupByLibrary.simpleMessage(
      "Mes noms ENS",
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
    "g_key_ens_price_per_year": MessageLookupByLibrary.simpleMessage("par an"),
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
    "g_key_ens_records": MessageLookupByLibrary.simpleMessage(
      "Enregistrements",
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
    "g_key_ens_register_tx": MessageLookupByLibrary.simpleMessage(
      "Enregistrement du nom...",
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
    "g_key_ens_reminder_disabled": MessageLookupByLibrary.simpleMessage(
      "Le rappel est désactivé",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Activer le rappel d\'expiration",
    ),
    "g_key_ens_reminder_enabled": MessageLookupByLibrary.simpleMessage(
      "Le rappel est activé",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notifier 30, 7 et 1 jour avant l\'expiration",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renouveler"),
    "g_key_ens_renew_cost": MessageLookupByLibrary.simpleMessage(
      "Coût de renouvellement",
    ),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Prolongez l\'enregistrement de votre domaine",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renouvellement réussi",
    ),
    "g_key_ens_renew_title": MessageLookupByLibrary.simpleMessage(
      "Renouveler l\'ENS",
    ),
    "g_key_ens_resolution_failed": MessageLookupByLibrary.simpleMessage(
      "La résolution ENS a échoué",
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
    "g_key_ens_step_commit": MessageLookupByLibrary.simpleMessage("S\'engager"),
    "g_key_ens_step_register": MessageLookupByLibrary.simpleMessage(
      "S\'inscrire",
    ),
    "g_key_ens_step_success": MessageLookupByLibrary.simpleMessage("Succès"),
    "g_key_ens_step_wait": MessageLookupByLibrary.simpleMessage("Attends"),
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
    "g_key_ens_success_message": m31,
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Enregistrements de texte",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("Responsable ENS"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_ens_total_cost": MessageLookupByLibrary.simpleMessage("Coût total"),
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
    "g_key_ens_wait_timer": m32,
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
    "g_key_enter_confirm_password": MessageLookupByLibrary.simpleMessage(
      "Ressaisissez le nouveau mot de passe",
    ),
    "g_key_enter_email": MessageLookupByLibrary.simpleMessage(
      "Entrez votre adresse e-mail",
    ),
    "g_key_enter_new_password": MessageLookupByLibrary.simpleMessage(
      "Entrez le nouveau mot de passe",
    ),
    "g_key_enter_old_password": MessageLookupByLibrary.simpleMessage(
      "Entrez le mot de passe actuel",
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
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Compte ou mot de passe incorrect",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Erreur de requête"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "Vous êtes déjà connecté sur un autre téléphone et avez été déconnecté de force.",
    ),
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
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Commentaires"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Veuillez remplir les informations de commentaires",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "Il y a des pièces jointes non téléchargées",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Échec de la soumission",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Soumis avec succès",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Pièces jointes"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Téléchargez jusqu\'à 5 pièces jointes, chaque pièce jointe ne peut pas dépasser 100 Mo",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage(
      "Cliquez pour réessayer",
    ),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage(
      "Veuillez vous connecter",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filtrer"),
    "g_key_filter_type": MessageLookupByLibrary.simpleMessage("Tapez"),
    "g_key_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié ?",
    ),
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
    "g_key_gas_auto_refresh": m33,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Frais de Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Temps Est.",
    ),
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
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Moyen"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Fort"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Modèle trop simple, utilisez plus de nœuds",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Faible"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Connexion Google annulée",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "Valeur élevée uniquement",
    ),
    "g_key_hw_account_added": m34,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Compte déjà importé",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Comptes"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Ajouter un Compte",
    ),
    "g_key_hw_add_account_content": m35,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adresse copiée",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Assurez-vous que votre appareil est déverrouillé et que Bluetooth est activé avant de vous connecter.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage(
      "Vérifier l\'application",
    ),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Confirmez sur votre appareil",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Connecter le Portefeuille Matériel",
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
    "g_key_hw_current_app_label": m36,
    "g_key_hw_days_ago": m37,
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Chemin de Dérivation",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Déconnecter"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Déconnecté"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Veuillez activer le Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Version du Firmware",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_key_hw_import_failed": m38,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connecter Keystone",
    ),
    "g_key_hw_keystone_invalid_response": MessageLookupByLibrary.simpleMessage(
      "Réponse invalide du périphérique Keystone",
    ),
    "g_key_hw_keystone_scan_error": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'analyse du code QR. Veuillez réessayer.",
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
    "g_key_hw_keystone_signature_received":
        MessageLookupByLibrary.simpleMessage("Signature reçue avec succès"),
    "g_key_hw_keystone_signing": MessageLookupByLibrary.simpleMessage(
      "En attente de la signature de Keystone...",
    ),
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Appuyez pour analyser la réponse Keystone",
    ),
    "g_key_hw_last_connected": m39,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Grand livre"),
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
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Aucun appareil trouvé",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Appareil non connecté",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Non connecté",
    ),
    "g_key_hw_open_app": m40,
    "g_key_hw_open_ledger_app_hint": m41,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rejeté sur l\'appareil",
    ),
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Supprimer"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Supprimer l\'appareil",
    ),
    "g_key_hw_remove_device_confirm": m42,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Appareils enregistrés",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage(
      "Recherche d\'appareils...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Sélectionner l\'Appareil",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Signer le Message",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Signer la Transaction",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Force du Signal",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Appareils pris en charge",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Délai de connexion dépassé",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Portefeuille Matériel",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Aujourd\'hui"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
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
    "g_key_hw_trezor_passphrase_required": MessageLookupByLibrary.simpleMessage(
      "Entrez la phrase secrète sur votre appareil Trezor",
    ),
    "g_key_hw_trezor_pin_required": MessageLookupByLibrary.simpleMessage(
      "Entrez le code PIN sur votre appareil Trezor",
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
    "g_key_link_account": MessageLookupByLibrary.simpleMessage(
      "Lier le compte",
    ),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Comptes liés",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Connexion réussie",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir quitter l\'application ?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Points Disponibles",
    ),
    "g_key_loyalty_checked_today": MessageLookupByLibrary.simpleMessage(
      "Je suis arrivé aujourd\'hui !",
    ),
    "g_key_loyalty_checkin_btn": MessageLookupByLibrary.simpleMessage(
      "Enregistrement",
    ),
    "g_key_loyalty_checkin_done": MessageLookupByLibrary.simpleMessage(
      "Terminé",
    ),
    "g_key_loyalty_checkin_failed": MessageLookupByLibrary.simpleMessage(
      "L\'enregistrement a échoué, veuillez réessayer",
    ),
    "g_key_loyalty_checkin_success": MessageLookupByLibrary.simpleMessage(
      "Enregistrement réussi !",
    ),
    "g_key_loyalty_claim_points": MessageLookupByLibrary.simpleMessage(
      "Réclamer les Points",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "La tâche a échoué, veuillez réessayer",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Tâche terminée !",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copier"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Quotidien",
    ),
    "g_key_loyalty_earn_points": m43,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Gagné"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Historique des Points",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Inviter"),
    "g_key_loyalty_invite_bonus": m44,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Inviter des amis",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amis Invités",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Niveau maximum",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage(
      "Suivant",
    ),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "Niveau Suivant",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "Aucune récompense disponible",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "Aucune tâche disponible",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Points"),
    "g_key_loyalty_points_to_next": m45,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Échanger"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage(
      "Parrainage",
    ),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Bonus de Parrainage",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Votre Code de Parrainage",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Lien de Parrainage",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage(
      "Récompenses",
    ),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Partager"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Dépensé"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Tâche Terminée",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Tâches"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Niveau"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Bronze"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Diamant",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Or"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Platine",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage("Argent"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Points"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total gagné",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Points Totaux",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Utilisé"),
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
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage(
      "Nouveaux parachutages",
    ),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage(
      "Nouveau mot de passe",
    ),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "Le nouveau mot de passe doit être différent du mot de passe actuel",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Suivant"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Caméra"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage(
      "Sélectionner une photo",
    ),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Contenu"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Nom"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Retour"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage("Transaction soumise"),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage(
      "Sélectionner une vidéo",
    ),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Adresse de portefeuille invalide",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Solde"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "Cette action est irréversible. Le NFT sera envoyé à l’adresse de gravure.",
    ),
    "g_key_nft_burn_evm_only": MessageLookupByLibrary.simpleMessage(
      "Burn n\'est pris en charge que sur les chaînes EVM",
    ),
    "g_key_nft_burn_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "La gravure de Solana NFT arrive bientôt",
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
    "g_key_nft_open_browser": MessageLookupByLibrary.simpleMessage(
      "Afficher sur l\'Explorateur",
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
    "g_key_no_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Aucun compte lié",
    ),
    "g_key_notification_settings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de notification",
    ),
    "g_key_oidc_login": MessageLookupByLibrary.simpleMessage(
      "Connexion entreprise (SSO)",
    ),
    "g_key_oidc_not_configured": MessageLookupByLibrary.simpleMessage(
      "Enterprise SSO non configuré",
    ),
    "g_key_old_password": MessageLookupByLibrary.simpleMessage(
      "Mot de passe actuel",
    ),
    "g_key_or": MessageLookupByLibrary.simpleMessage("ou"),
    "g_key_password_changed_success": MessageLookupByLibrary.simpleMessage(
      "Mot de passe modifié avec succès",
    ),
    "g_key_password_min_length": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe doit contenir au moins 6 caractères",
    ),
    "g_key_password_req_different": MessageLookupByLibrary.simpleMessage(
      "Différent du mot de passe actuel",
    ),
    "g_key_password_req_length": MessageLookupByLibrary.simpleMessage(
      "Au moins 6 caractères",
    ),
    "g_key_password_required": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe est requis",
    ),
    "g_key_password_requirements": MessageLookupByLibrary.simpleMessage(
      "Exigences de mot de passe",
    ),
    "g_key_password_reset_success": MessageLookupByLibrary.simpleMessage(
      "Mot de passe réinitialisé avec succès",
    ),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas",
    ),
    "g_key_payment_amount_invalid": MessageLookupByLibrary.simpleMessage(
      "Montant invalide",
    ),
    "g_key_payment_approx_token": m46,
    "g_key_payment_approx_usdt": m47,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "QR de paiement",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("Confirmer"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "Historique des paiements",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "Historique",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("Entrant"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Échec du chargement",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Non défini",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Solde natif insuffisant !",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Chaîne native introuvable !",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("Sortant"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Définir le montant",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Paiement réussi !",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Paiement"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Solde USDT insuffisant !",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Veuillez ajouter le token USDT !",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage(
      "Portefeuille",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Sélectionner depuis la galerie du téléphone",
    ),
    "g_key_resend_code": MessageLookupByLibrary.simpleMessage(
      "Renvoyer le code",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Réinitialiser"),
    "g_key_reset_password": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le mot de passe",
    ),
    "g_key_reset_password_email_desc": MessageLookupByLibrary.simpleMessage(
      "Entrez votre adresse e-mail pour recevoir un code de vérification",
    ),
    "g_key_saml_login": MessageLookupByLibrary.simpleMessage("Connexion SAML"),
    "g_key_saml_not_configured": MessageLookupByLibrary.simpleMessage(
      "SAML non configuré",
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
    "g_key_send_code": MessageLookupByLibrary.simpleMessage(
      "Envoyer le code de vérification",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("Mémo / Note"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Mémo / Note (facultatif)",
    ),
    "g_key_set_new_password_desc": MessageLookupByLibrary.simpleMessage(
      "Définissez votre nouveau mot de passe",
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
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Échec de la connexion",
    ),
    "g_key_sim_gas_estimate": m48,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "La transaction échouera probablement",
    ),
    "g_key_sim_reverted_reason": m49,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulation de transaction…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Simulation de transaction réussie",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulation indisponible pour ce réseau",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage(
      "Connexion sociale",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Discuter"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Le fichier est trop volumineux pour être téléchargé",
    ),
    "g_key_squad_k15": m50,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Ajouter un contact",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contacter"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Rechercher par e-mail",
    ),
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
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Réclamer les Récompenses",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commissions",
    ),
    "g_key_stake_d_unbond": m51,
    "g_key_stake_days_left": m52,
    "g_key_stake_days_remaining": m53,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Délégateurs",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Récompense quotidienne",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Récompense annuelle",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Aller à l\'échange",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Liquide",
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
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Aucune position de staking",
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
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Récompenses en Attente",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Mes Positions",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocole"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocoles"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restaker"),
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
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Jalonnement"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Total Staké",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaction préparée avec succès",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Déblocage en Cours",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Période de Déblocage",
    ),
    "g_key_stake_unbonding_warning": m54,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Retirer"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage(
      "Mise à jour...",
    ),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Disponibilité"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validateur"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validateurs",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "Vous recevrez",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Courriel"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Vérifier"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prix du gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Frais de gas maximum"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Frais maximum par gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_key_t_29": m55,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Frais de minage"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Continuer"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage(
      "Mot de passe du portefeuille",
    ),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Le mot de passe du portefeuille ne peut pas être vide",
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
    "g_key_t_45": m56,
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
    "g_key_t_52": m57,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'adresse de réception n\'a pas de compte, et le premier transfert doit être d\'au moins 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilisé"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_time_days_ago": m58,
    "g_key_time_hours_ago": m59,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage(
      "Juste maintenant",
    ),
    "g_key_time_minutes_ago": m60,
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage(
      "Ajouter",
    ),
    "g_key_token_discovery_add_selected": m61,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Jeton ajouté",
    ),
    "g_key_token_discovery_banner": m62,
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
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("Types de NFT"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Abonnés"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("Types d\'utilisateurs"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Site web"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Lien des produits"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Plateformes médias"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage(
      "Adresse du portefeuille",
    ),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Pseudo"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage(
      "Échec du téléchargement de l\'avatar",
    ),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Descriptif"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage(
      "Informations de l\'artiste",
    ),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage(
      "Vous n\'êtes pas un artiste",
    ),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Cliquez ici pour postuler en tant qu\'artiste",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Nom"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Revenus"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Dissocier le compte",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "J\'ai lu et accepté les ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage(
      "Conditions générales",
    ),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Politique de confidentialité et Déclaration de collecte des informations personnelles",
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
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Code de vérification",
    ),
    "g_key_verification_code_sent": m63,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "Voir la phrase de récupération",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Veuillez vous assurer d\'enregistrer votre phrase de récupération et de la stocker en toute sécurité.",
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
    "g_key_wallet_m1": m64,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre compte ?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Confirmer la déconnexion",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le code de vérification Google.",
    ),
    "g_key_wallet_m19": m65,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Le jeton actuel n\'a pas été ajouté.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Entrez votre phrase de récupération avec les mots séparés par des espaces",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importer le portefeuille",
    ),
    "g_key_wallet_m3": m66,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Le solde du jeton actuel est insuffisant.",
    ),
    "g_key_wallet_m5": m67,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage(
      "Erreur de signature",
    ),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Suppression du compte",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Entrez le code de vérification par e-mail.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Gérer le portefeuille",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Entrez l\'adresse Ethereum (0x...)",
    ),
    "g_key_watch_only_banner": MessageLookupByLibrary.simpleMessage(
      "Montre uniquement",
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
    "g_key_xml_11": m68,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage(
      "Réserve incrémentielle",
    ),
    "g_key_xml_22": m69,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Nombre d\'objets possédés",
    ),
    "g_key_xml_33": m70,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "Comment calculer le montant total réservé",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Réserve totale = Réserve de base + (Nombre d\'objets possédés × Réserve incrémentielle)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID et Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Mot de passe actuel"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage(
      "Nouveau mot de passe",
    ),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Confirmer le nouveau mot de passe",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("Numéro à 6 chiffres"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Mots de passe et biométrie",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage(
      "Mot de passe par schéma",
    ),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Définir le code par schéma",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Pour la sécurité de votre compte, veuillez définir un mot de passe de groupe",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Dessin secondaire du mot de passe par schéma",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Dessiner le mot de passe par schéma",
    ),
    "g_lock_key21": m71,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le mot de passe par schéma",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Trop de saisies incorrectes, veuillez réinitialiser le mot de passe",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Ajouter un mot de passe de portefeuille ?",
    ),
    "g_lock_key25": m72,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage(
      "Page de verrouillage d\'écran",
    ),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage(
      "Verrouillage automatique",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Réussi"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Échec"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "La reconnaissance biométrique n\'est pas activée",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Ajouter la vérification biométrique ?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le mot de passe",
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
    "g_market_empty_watchlist_hint": MessageLookupByLibrary.simpleMessage(
      "Appuyez sur ★ sur n\'importe quelle pièce à ajouter",
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
    "g_mining_key15": MessageLookupByLibrary.simpleMessage(
      "Détail de la tâche",
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
    "g_mining_key63": m73,
    "g_mining_key7": MessageLookupByLibrary.simpleMessage(
      "Date de déverrouillage",
    ),
    "g_mining_key73": m74,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Je viens de configurer un nœud sur @N42Wallet et j\'ai commencé la vérification sur appareils mobiles ! Venez me rejoindre. L\'avenir décentralisé est mobile !",
    ),
    "g_mining_key76": m75,
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
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage(
      "Liste des validateurs",
    ),
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
    "g_mining_key_109": m76,
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
    "g_mining_key_116": m77,
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
    "g_mining_key_22": MessageLookupByLibrary.simpleMessage(
      "Distribution des récompenses",
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
    "g_mining_key_71": m78,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 secondes par vérification",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Vérification cloud démarrée",
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
    "g_mining_key_98": m79,
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
    "g_news_source": MessageLookupByLibrary.simpleMessage("Origine"),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Notifications",
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
    "g_pnl_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Base de coût"),
    "g_pnl_no_trades": MessageLookupByLibrary.simpleMessage(
      "Aucune transaction enregistrée",
    ),
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
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Téléchargé"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Code d\'invitation",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invités"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Nœuds miniers"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Récompense (N)"),
    "g_referral_stats_title": MessageLookupByLibrary.simpleMessage(
      "Statistiques de parrainage",
    ),
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
    "g_swap_key_14": m80,
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
    "g_swap_key_20": m81,
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
    "g_swap_key_31": m82,
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
    "g_token_m_key_1": m83,
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
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
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
    "g_token_m_key_22": m84,
    "g_token_m_key_23": m85,
    "g_token_m_key_24": m86,
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
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Attention"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("Risque Élevé"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Sûr"),
    "g_unlock_key10": m87,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "La reconnaissance d\'empreinte ou faciale n\'est pas activée ?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Dessiner le mot de passe par schéma",
    ),
    "g_unlock_key4": m88,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage(
      "Entrer le mot de passe",
    ),
    "g_unlock_key6": m89,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'authentification",
    ),
    "g_unlock_key8": m90,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Vous pouvez aussi "),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Plus tard"),
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
    "g_wc_new_connection": MessageLookupByLibrary.simpleMessage(
      "Nouvelle connexion",
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
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Authentification Google",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Lier",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Télécharger Google Authentication",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Instructions",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Ouvrez Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "Vous verrez un code de vérification à 6 chiffres à l\'écran.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Copiez le code à 6 chiffres et collez-le dans N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Ensuite, votre Authenticator sera lié avec succès.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Clé de sauvegarde",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Copiez la clé dans Google Authentication",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Entrez le code de vérification Google",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Entrez le code de vérification par e-mail",
    ),
    "google_verification_message21": m91,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'obtention de la clé Google",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Authentification à deux facteurs (2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "Pour protéger votre compte, il est recommandé d\'activer au moins une 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "L\'application Google Authenticator protège vos retraits et votre compte N42Wallet.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Télécharger et installer",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Veuillez télécharger et installer Google Authenticator. Ensuite, appuyez sur \'Lier\' pour lier votre compte N42Wallet.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Avis important"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "login_email": MessageLookupByLibrary.simpleMessage("E-mail"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Mot de passe oublié ?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage(
      "Code de parrainage",
    ),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Code de parrainage",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Vous n\'avez pas de compte ? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Créé avec succès",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Réinitialisé avec succès",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Vous avez déjà un compte ? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage(
      "Renvoyer le code dans ",
    ),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Code envoyé avec succès",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-mail non enregistré",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'envoi du code",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "veuillez d\'abord vous connecter",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Mot de passe"),
    "next": MessageLookupByLibrary.simpleMessage("Suivant"),
    "nicknameMessage": m92,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Les mots de passe ne correspondent pas",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage(
      "Modifier le profil",
    ),
    "photograph": MessageLookupByLibrary.simpleMessage("Photographie"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Entrez le code de vérification",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer l\'e-mail",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le mot de passe",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer l\'adresse",
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
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Entrez à nouveau le mot de passe",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Entrez le code"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("Code OTP"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser votre mot de passe",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Gérer le portefeuille"),
    "s_key_10": MessageLookupByLibrary.simpleMessage(
      "À propos de l\'application",
    ),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Sécurité"),
    "s_key_12": MessageLookupByLibrary.simpleMessage(
      "Utiliser le nouveau Chat",
    ),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Activer l\'expérience Chat améliorée",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Adresses du portefeuille"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Opération"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Langue"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Thème"),
    "search": MessageLookupByLibrary.simpleMessage("Rechercher"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Veuillez lire l\'accord et confirmer",
    ),
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
