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

  static String m1(value) => "Je suis ${value}";

  static String m2(value) => "Membre du chat (${value})";

  static String m3(value) =>
      "Êtes-vous sûr de vouloir ajouter ${value} comme ami";

  static String m4(value) =>
      "Vous êtes déjà lié et ne pouvez pas être relié pour le moment. Adresse de liaison : ${value}.";

  static String m5(value) => "Liaison réussie. Adresse de liaison : ${value}";

  static String m6(value) =>
      "Il n\'y a pas de chaîne N42 dans le portefeuille ${value} !";

  static String m7(value) => "Correspondance réussie. Adresse : ${value}.";

  static String m8(value) => "Montant supérieur à ${value}.";

  static String m9(value) =>
      "Le portefeuille existe déjà, le nom du portefeuille est \"${value}\"";

  static String m10(value) => "Entrez un montant supérieur à ${value}.";

  static String m11(gas) =>
      "Le gas d\'exécution (${gas}) est élevé. Le contrat appelé peut consommer plus de gas que prévu.";

  static String m12(gas) =>
      "La première transaction inclut le déploiement du compte (~${gas} gas). Les transactions suivantes seront moins chères.";

  static String m13(gas) =>
      "La surcharge de gas du paymaster (${gas}) est élevée. Les transactions sans gas peuvent coûter plus cher.";

  static String m14(gas) =>
      "Le gas total estimé (${gas}) est inhabituellement élevé. Vérifiez votre transaction pour les erreurs.";

  static String m15(gas) =>
      "Le gas de vérification (${gas}) peut être trop élevé. Cela peut arriver avec une logique de compte complexe.";

  static String m16(value) => "${value} jours restants";

  static String m17(value) => "Adresse en double à la ligne ${value}";

  static String m18(value) => "Adresse invalide à la ligne ${value}";

  static String m19(value) => "Montant invalide à la ligne ${value}";

  static String m20(value) => "Maximum ${value} destinataires";

  static String m21(value) => "+${value} pts/day";

  static String m22(value) => "Earn up to ${value}% APY";

  static String m23(value) => "Congratulations! You now own ${value}";

  static String m24(value) => "Please wait ${value} seconds";

  static String m25(value) => "Auto-refresh every ${value} seconds";

  static String m26(address) => "Compte ${address} ajouté";

  static String m27(address, network) =>
      "Voulez-vous suivre ce compte de hardware wallet?\n\nAdresse: ${address}\nRéseau: ${network}";

  static String m28(app) => "Current app: ${app}";

  static String m29(days) => "${days} days ago";

  static String m30(value) => "Échec de l\'importation du compte: ${value}";

  static String m31(date) => "Last connected: ${date}";

  static String m32(value) =>
      "Veuillez ouvrir l\'app ${value} sur votre appareil";

  static String m33(app) =>
      "Assurez-vous que l\'application ${app} est ouverte sur votre Ledger";

  static String m34(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m35(value) => "Earn ${value} points";

  static String m36(value) => "Earn ${value} points for each friend who joins!";

  static String m37(value) => "${value} points pour le niveau suivant";

  static String m38(amount, token) => "≈ ${amount}${token}";

  static String m39(amount) => "≈ ${amount} USDT";

  static String m40(value) =>
      "Êtes-vous sûr de vouloir supprimer le contact ${value} ?";

  static String m41(value) => "${value}d unbond";

  static String m42(value) => "${value} jours restants";

  static String m43(value) => "${value} days remaining";

  static String m44(value) => "Vous n\'avez pas assez de \"${value}\"";

  static String m45(value) => "Échec de la récupération du compte \"${value}\"";

  static String m46(value) => "Minimum ${value} XRP pour le premier transfert";

  static String m47(value) => "${value}d ago";

  static String m48(value) => "${value}h ago";

  static String m49(value) => "${value}m ago";

  static String m50(value) => "Verification code sent to ${value}";

  static String m51(value) => "Aucune chaîne ${value} ajoutée.";

  static String m52(value) =>
      "${value} a des transactions non terminées, veuillez réessayer plus tard.";

  static String m53(value) => "Aucune adresse trouvée pour ${value}.";

  static String m54(value) => "Solde insuffisant de ${value}.";

  static String m55(value, value1) =>
      "Chaque compte XRP doit réserver ${value} XRP (${value1} drops) comme base, qui ne peut pas être dépensé.";

  static String m56(value, value1) =>
      "Pour chaque objet que le compte possède, ${value} XRP (${value1} drops) est ajouté à la réserve.";

  static String m57(value, value1) =>
      "Ce compte possède ${value} objets, ce qui signifie qu\'un ${value1} XRP supplémentaire est réservé.";

  static String m58(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentatives";

  static String m59(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentative";

  static String m60(value) =>
      "Vous avez configuré avec succès un ${value} et commencerez la vérification avec N42Wallet !";

  static String m61(value) =>
      "Rejoignez mon groupe ${value} sur @N42Wallet pour être l\'un des premiers mineurs d\'une chaîne Layer 1, et obtenez des cryptos sur votre téléphone !";

  static String m62(value) =>
      "Verrouillez ${value} N pour faire fonctionner un validateur.";

  static String m63(value) => "Échec de l\'importation : ${value}";

  static String m64(value) =>
      "Un solde de staking d\'au moins ${value} est requis pour recevoir des récompenses.";

  static String m65(value, value1) =>
      "${value} N tous les ${value1} blocs minés";

  static String m66(value) => "Doit contenir ${value} caractères";

  static String m67(value) => "Solde insuffisant de ${value}.";

  static String m68(value) => "${value} en cours de réception...";

  static String m69(value) =>
      "Les ${value} échangés dans l\'application seront distribués sous peu dans votre portefeuille et ne peuvent pas être vendus via ce processus. Ils peuvent être utilisés pour faire fonctionner un nœud.";

  static String m70(value) => "Maximum ${value} caractères";

  static String m71(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP !";

  static String m72(value) =>
      "La chaîne ${value} est déjà supportée par l\'APP, voulez-vous l\'ajouter ?";

  static String m73(value) =>
      "Échec du test de connexion à l\'adresse ${value} !";

  static String m74(value) =>
      "L\'application se déverrouillera dans ${value} secondes.";

  static String m75(value) =>
      "Erreur de saisie du mot de passe par schéma, il vous reste ${value} tentatives";

  static String m76(value) =>
      "Erreur de saisie du mot de passe, il vous reste ${value} tentatives";

  static String m77(value) =>
      "Erreur de saisie du mot de passe, il vous reste ${value} tentative";

  static String m78(value) => "Entrez le mot de passe ${value}";

  static String m79(value) => "0~${value} caractères";

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
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Favoris"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "Aucun favori ajouté pour le moment",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Favori"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Nom"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le nom",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Description"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage(
      "Démarrer une discussion de groupe",
    ),
    "g_chat_key_10": m1,
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
    "g_chat_key_32": m2,
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
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Photo"),
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
    "g_chat_key_6": m3,
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
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transactions"),
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
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Méthode de correspondance faciale",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
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
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Déliaison"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Échec de la vérification des données faciales !",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Échec de la déliaison des données faciales !",
    ),
    "g_face_match_key4": m7,
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
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Portefeuille principal"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaction réussie"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Mot de passe incorrect"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Mainnet"),
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
    "g_key_197": MessageLookupByLibrary.simpleMessage("Max"),
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
    "g_key_214": m9,
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
    "g_key_46": m10,
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
      "Calcul de l\'adresse...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Échec du calcul de l\'adresse. Veuillez réessayer.",
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
      "Compte Biconomy",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Compte intelligent ERC-7579 modulaire avec support des transactions sans frais",
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
      "Gas d\'Exécution Élevé",
    ),
    "g_key_aa_gas_warn_call_high_desc": m11,
    "g_key_aa_gas_warn_deploy": MessageLookupByLibrary.simpleMessage(
      "Surcharge de Déploiement",
    ),
    "g_key_aa_gas_warn_deploy_desc": m12,
    "g_key_aa_gas_warn_paymaster": MessageLookupByLibrary.simpleMessage(
      "Surcharge Paymaster Élevée",
    ),
    "g_key_aa_gas_warn_paymaster_desc": m13,
    "g_key_aa_gas_warn_total_high": MessageLookupByLibrary.simpleMessage(
      "Limite de Gas Très Élevée",
    ),
    "g_key_aa_gas_warn_total_high_desc": m14,
    "g_key_aa_gas_warn_under_est": MessageLookupByLibrary.simpleMessage(
      "Possible Sous-Estimation du Gas",
    ),
    "g_key_aa_gas_warn_under_est_desc": MessageLookupByLibrary.simpleMessage(
      "Le gas réellement utilisé peut dépasser l\'estimation. Envisagez d\'ajouter une plus grande marge.",
    ),
    "g_key_aa_gas_warn_verify_high": MessageLookupByLibrary.simpleMessage(
      "Gas de Vérification Élevé",
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
      "Choose how you want to pay for transaction gas fees",
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
    "g_key_aa_safe_guardians": MessageLookupByLibrary.simpleMessage("Gardiens"),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage("Seuil"),
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
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Valable pour",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "Risque élevé — uniquement DApps vérifiées",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
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
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Vérifier l\'Éligibilité",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Réclamer"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Réclamé"),
    "g_key_airdrop_days_left": m16,
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
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Ajouter un Destinataire",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage(
      "Tout Effacer",
    ),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "Format CSV: adresse,montant,libellé",
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
      "Exécuter le Lot",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Exporter CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Économies de Gas",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Importer CSV",
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
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Aperçu"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Destinataires",
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
      "Transfert par Lots",
    ),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Montant Total",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Montant"),
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
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Route"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Rechercher une chaîne...",
    ),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Glissement"),
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
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("Aucun token"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "Aucun token trouvé",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Impact du Prix",
    ),
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Devis échoué",
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
      "Solana Name Service",
    ),
    "g_key_domain_sns_not_found": MessageLookupByLibrary.simpleMessage(
      "Domaine Solana introuvable",
    ),
    "g_key_domain_ud_name": MessageLookupByLibrary.simpleMessage(
      "Unstoppable Domains",
    ),
    "g_key_domain_ud_not_found": MessageLookupByLibrary.simpleMessage(
      "Domaine Unstoppable introuvable ou sans adresse pour cette chaîne",
    ),
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
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
      "Claim free tokens",
    ),
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-chain transfer",
    ),
    "g_key_earn_daily_bonus": MessageLookupByLibrary.simpleMessage(
      "Daily check-in bonus",
    ),
    "g_key_earn_dex_desc": MessageLookupByLibrary.simpleMessage(
      "Échangez n\'importe quel token via Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("Échange DEX"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gaz"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Commencer le staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Chargement APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Minage"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
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
      "Sélectionner le type d\'échange",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Échanger"),
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
      "L\'engagement d\'enregistrement a expiré. Veuillez recommencer le processus d\'enregistrement.",
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
      "Adresse copiée",
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
      "Impossible d\'envoyer à votre propre adresse",
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
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Frais de Base"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Personnalisé"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Temps Est.",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Rapide"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
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
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Frais Prioritaire",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage(
      "Paramètres de Gas",
    ),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Lent"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_gesture_medium": MessageLookupByLibrary.simpleMessage("Moyen"),
    "g_key_gesture_strong": MessageLookupByLibrary.simpleMessage("Fort"),
    "g_key_gesture_too_simple": MessageLookupByLibrary.simpleMessage(
      "Modèle trop simple, utilisez plus de nœuds",
    ),
    "g_key_gesture_weak": MessageLookupByLibrary.simpleMessage("Faible"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_added": m26,
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Comptes"),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Ajouter"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage(
      "Ajouter un Compte",
    ),
    "g_key_hw_add_account_content": m27,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Adresse copiée",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_cancel": MessageLookupByLibrary.simpleMessage("Annuler"),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Confirmez sur votre appareil",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Connecter le Portefeuille Matériel",
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
      "Chemin de Dérivation",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage("Déconnecté"),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Veuillez activer le Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Version du Firmware",
    ),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Retour"),
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
      "No app is currently open",
    ),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "Aucun appareil trouvé",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Appareil non connecté",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_app": m32,
    "g_key_hw_open_ledger_app_hint": m33,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rejeté sur l\'appareil",
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
      "Supported Devices",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Délai de connexion dépassé",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage(
      "Portefeuille Matériel",
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
      "Comptes du Portefeuille",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Un portefeuille de cette devise existe déjà.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Impossible de lire le keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Se connecter"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Se déconnecter"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir quitter l\'application ?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Points Disponibles",
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
      "Réclamer les Points",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Check-in Quotidien",
    ),
    "g_key_loyalty_earn_points": m35,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Gagné"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Historique des Points",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m36,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Amis Invités",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
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
    "g_key_loyalty_points_to_next": m37,
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
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
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
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Points Totaux",
    ),
    "g_key_loyalty_used": MessageLookupByLibrary.simpleMessage("Used"),
    "g_key_m_10": MessageLookupByLibrary.simpleMessage("Facebook"),
    "g_key_m_11": MessageLookupByLibrary.simpleMessage("Twitter"),
    "g_key_m_14": MessageLookupByLibrary.simpleMessage("Reddit"),
    "g_key_m_15": MessageLookupByLibrary.simpleMessage("Navigateur"),
    "g_key_m_16": MessageLookupByLibrary.simpleMessage("Telegram"),
    "g_key_m_17": MessageLookupByLibrary.simpleMessage("Discord"),
    "g_key_m_18": MessageLookupByLibrary.simpleMessage("Youtube"),
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
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer la phrase de récupération",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
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
      "Montant invalide",
    ),
    "g_key_payment_approx_token": m38,
    "g_key_payment_approx_usdt": m39,
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
      "Partager le code QR",
    ),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage(
      "Partager le lien",
    ),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage(
      "Méthode de partage",
    ),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "Le fichier est trop volumineux pour être téléchargé",
    ),
    "g_key_squad_k15": m40,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage(
      "Ajouter un contact",
    ),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contact"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage(
      "Rechercher par e-mail",
    ),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Actif"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage(
      "Réclamer les Récompenses",
    ),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commission",
    ),
    "g_key_stake_d_unbond": m41,
    "g_key_stake_days_left": m42,
    "g_key_stake_days_remaining": m43,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Délégateurs",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Staking Liquide",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Mise Minimum",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "Aucune position de staking",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Récompenses en Attente",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "Mes Positions",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocole"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restaker"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Récompenses"),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un Validateur",
    ),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Staker"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Staking"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Total Staké",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage(
      "Déblocage en Cours",
    ),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Période de Déblocage",
    ),
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Retirer"),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Disponibilité"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validateur"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validateurs",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Terminé"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Prix du gas"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Frais de gas maximum"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Frais maximum par gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("En attente"),
    "g_key_t_29": m44,
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
    "g_key_t_45": m45,
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
    "g_key_t_52": m46,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "L\'adresse de réception n\'a pas de compte, et le premier transfert doit être d\'au moins 10 XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas utilisé"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m47,
    "g_key_time_hours_ago": m48,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m49,
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
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Description"),
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
      "Unlink Account",
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
      "Verification Code",
    ),
    "g_key_verification_code_sent": m50,
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
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Accélérer"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Note"),
    "g_key_wallet_m1": m51,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Êtes-vous sûr de vouloir supprimer votre compte ?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage(
      "Confirmer la déconnexion",
    ),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Veuillez entrer le code de vérification Google.",
    ),
    "g_key_wallet_m19": m52,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "Le jeton actuel n\'a pas été ajouté.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Entrez votre phrase de récupération avec les mots séparés par des espaces",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage(
      "Importer le portefeuille",
    ),
    "g_key_wallet_m3": m53,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "Le solde du jeton actuel est insuffisant.",
    ),
    "g_key_wallet_m5": m54,
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
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Réservé"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Réserve de base"),
    "g_key_xml_11": m55,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage(
      "Réserve incrémentielle",
    ),
    "g_key_xml_22": m56,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage(
      "Nombre d\'objets possédés",
    ),
    "g_key_xml_33": m57,
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
    "g_lock_key21": m58,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Réinitialiser le mot de passe par schéma",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Trop de saisies incorrectes, veuillez réinitialiser le mot de passe",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Ajouter un mot de passe de portefeuille ?",
    ),
    "g_lock_key25": m59,
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
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Déverrouiller N ?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Activité de vérification cloud",
    ),
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
    "g_mining_key63": m60,
    "g_mining_key73": m61,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "Je viens de configurer un nœud sur @N42Wallet et j\'ai commencé la vérification sur appareils mobiles ! Venez me rejoindre. L\'avenir décentralisé est mobile !",
    ),
    "g_mining_key76": m62,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Rachat disponible après 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Les demandes avant cela ne seront pas traitées.",
    ),
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
    "g_mining_key_109": m63,
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
    "g_mining_key_116": m64,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Les récompenses s\'accumulent quotidiennement et ne sont envoyées à votre portefeuille N que lorsqu\'elles atteignent ~0,5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage(
      "Récompenses totales",
    ),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Valeur minée"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Calculé sur la base du prix du marché de N * le total des récompenses N.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Nombre de gains"),
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
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Désactivé"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("Voir plus"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Statut de vérification",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Verrouillez des N pour commencer à gagner des récompenses de vérification.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entrée"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Nœud avancé"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Nœud d\'entrée"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Nœud pro"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocs/jour~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage(
      "Sélectionner un plan",
    ),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocs/jour~15 mins",
    ),
    "g_mining_key_71": m65,
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
    "g_mining_key_98": m66,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Veuillez ressaisir votre mot de passe pour vous assurer qu\'il est correct",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Période de déverrouillage:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Déverrouillable à tout moment",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Notifications",
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
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("code"),
    "g_swap_key_14": m67,
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
    "g_swap_key_20": m68,
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
    "g_swap_key_31": m69,
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
    "g_token_m_key_1": m70,
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
    "g_token_m_key_22": m71,
    "g_token_m_key_23": m72,
    "g_token_m_key_24": m73,
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
    "g_unlock_key10": m74,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "La reconnaissance d\'empreinte ou faciale n\'est pas activée ?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Dessiner le mot de passe par schéma",
    ),
    "g_unlock_key4": m75,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage(
      "Entrer le mot de passe",
    ),
    "g_unlock_key6": m76,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Échec de l\'authentification",
    ),
    "g_unlock_key8": m77,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("Vous pouvez aussi "),
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
    "google_verification_message21": m78,
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
    "nicknameMessage": m79,
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
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaction"),
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
