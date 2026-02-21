// DO NOT EDIT. This is code generated via package:intl/generate_localized.dart
// This is a library that provides messages for a en locale. All the
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
  String get localeName => 'en';

  static String m0(deviceName, os) =>
      "Your account was just logged in on ${deviceName} (${os}). If this wasn\'t you, we recommend changing your password.";

  static String m1(value) => "I am ${value}";

  static String m2(value) => "Chat member(${value})";

  static String m3(value) =>
      "Are you sure you want to add ${value} as a friend";

  static String m4(value) =>
      "You have been bound and cannot be re-bound at the moment. Binding address: ${value}.";

  static String m5(value) => "Binding successful.Binding address: ${value}";

  static String m6(value) => "There is no N42chain in the ${value} wallet!";

  static String m7(value) => "Match successful.Address:${value}.";

  static String m8(value) => "Amount greater than ${value}.";

  static String m9(value) =>
      "The wallet already exists, the wallet name is \"${value}\"";

  static String m10(value) => "Enter an amount more than ${value}.";

  static String m11(value) => "${value} days left";

  static String m12(value) => "Duplicate address at row ${value}";

  static String m67(value) =>
      "Insufficient balance: total amount would exceed available ${value}";

  static String m13(value) => "Invalid address at row ${value}";

  static String m14(value) => "Invalid amount at row ${value}";

  static String m15(value) => "Maximum ${value} recipients";

  static String m16(value) => "+${value} pts/day";

  static String m17(value) => "Earn up to ${value}% APY";

  static String m18(value) => "Congratulations! You now own ${value}";

  static String m19(value) => "Please wait ${value} seconds";

  static String m20(value) => "Auto-refresh every ${value} seconds";

  static String m68(value) => "Failed to import account: ${value}";

  static String m21(value) => "Please open the ${value} app on your device";

  static String m22(value) => "Earn ${value} points";

  static String m23(value) => "Earn ${value} points for each friend who joins!";

  static String m24(value) => "${value} points to next tier";

  static String m25(amount, token) => "≈ ${amount}${token}";

  static String m26(amount) => "≈ ${amount} USDT";

  static String m27(value) =>
      "Are you sure you want to delete the contact ${value}?";

  static String m28(value) => "${value}d unbond";

  static String m29(value) => "${value} days left";

  static String m30(value) => "${value} days remaining";

  static String m69(value) =>
      "Unstaking takes ${value} days. Your tokens will be locked during this period.";

  static String m31(value) => "You do not have enough \"${value}\"";

  static String m32(value) => "Failed to get \"${value}\" account";

  static String m33(value) => "Minimum ${value} XRP for first transfer";

  static String m34(value) => "${value}d ago";

  static String m35(value) => "${value}h ago";

  static String m36(value) => "${value}m ago";

  static String m37(value) => "Verification code sent to ${value}";

  static String m38(value) => "No ${value} chain added.";

  static String m39(value) =>
      "${value} has unfinished transactions, please try again later.";

  static String m40(value) => "No address found for ${value}.";

  static String m41(value) => "Insufficient balance of ${value}.";

  static String m42(value, value1) =>
      "Every XRP account must reserve ${value} XRP (${value1} drops) as a baseline, which cannot be spent.";

  static String m43(value, value1) =>
      "For every object the account owns, ${value} XRP (${value1} drops) is added to the reserve.";

  static String m44(value, value1) =>
      "This account owns ${value} objects, which means an additional ${value1} XRP is reserved.";

  static String m45(value) =>
      "Pattern password input error,you have ${value} chances";

  static String m46(value) =>
      "Pattern password input error,you have ${value} chance";

  static String m47(value) =>
      "You have successfully set up a ${value} and will begin verification with N42Wallet!";

  static String m48(value) =>
      "Join my ${value} group on @N42Wallet to be an early miner of a Layer 1 chain, and get crypto on your phone!";

  static String m49(value) => "Lock ${value} N to run a validator.";

  static String m50(value) => "Import failed:${value}";

  static String m51(value) =>
      "A staking balance of at least ${value} is required to earn rewards.";

  static String m52(value, value1) => "${value} N every ${value1} blocks mined";

  static String m53(value) => "Must be ${value} characters";

  static String m54(value) => "${value} Insufficient Balance.";

  static String m55(value) => "${value} incoming...";

  static String m56(value) =>
      "${value} swapped in-app will be distributed shortly to your wallet and cannot be sold via this process. It can be used to run a node.";

  static String m57(value) => "Max ${value} characters";

  static String m58(value) => "${value} chain APP is already supported!";

  static String m59(value) =>
      "${value} chain APP is already supported, do you want to add it?";

  static String m60(value) => "${value} address test link failed!";

  static String m61(value) =>
      "The application will unlock in ${value} seconds.";

  static String m62(value) =>
      "Pattern password input error,you have ${value} chances";

  static String m63(value) => "Password input error,you have ${value} chances";

  static String m64(value) => "Password input error,you have ${value} chance";

  static String m65(value) => "Enter ${value} password";

  static String m66(value) => "0~${value} characters";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Create_account": MessageLookupByLibrary.simpleMessage("Sign up"),
    "Create_your_account": MessageLookupByLibrary.simpleMessage(
      "Create your account",
    ),
    "Edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verification"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Address Information",
    ),
    "code_403": MessageLookupByLibrary.simpleMessage(
      "Account temporarily locked for one day",
    ),
    "code_err_tips": MessageLookupByLibrary.simpleMessage(
      "The code is incorrect. Please try again.",
    ),
    "copy": MessageLookupByLibrary.simpleMessage("Copied successfully"),
    "copyAddress": MessageLookupByLibrary.simpleMessage("Copy Address"),
    "descO": MessageLookupByLibrary.simpleMessage("Description(Optional)"),
    "device_login_change_password": MessageLookupByLibrary.simpleMessage(
      "Change Password",
    ),
    "device_login_dismiss": MessageLookupByLibrary.simpleMessage("Got it"),
    "device_login_message": m0,
    "device_login_title": MessageLookupByLibrary.simpleMessage(
      "New Device Login",
    ),
    "editPhoto": MessageLookupByLibrary.simpleMessage("Edit photo"),
    "email_code_error": MessageLookupByLibrary.simpleMessage(
      "Failed to get authentication code",
    ),
    "email_code_finish": MessageLookupByLibrary.simpleMessage(
      "Authentication code sent successfully, please check your email",
    ),
    "email_code_input_error": MessageLookupByLibrary.simpleMessage(
      "Authentication code error",
    ),
    "email_error": MessageLookupByLibrary.simpleMessage(
      "Invalid email address",
    ),
    "email_verification": MessageLookupByLibrary.simpleMessage(
      "Email Address Authentication",
    ),
    "email_verification_message1": MessageLookupByLibrary.simpleMessage(
      "The Email Address Authenticator app protects your withdrawals and N42Wallet account.",
    ),
    "email_verification_message2": MessageLookupByLibrary.simpleMessage(
      "Add Email verification?",
    ),
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "g_app_share_key_1": MessageLookupByLibrary.simpleMessage(
      "Tokens can only be sent within the same network. Sending from other networks may result in loss.",
    ),
    "g_app_share_key_2": MessageLookupByLibrary.simpleMessage(
      "Scan to receive",
    ),
    "g_browser_key1": MessageLookupByLibrary.simpleMessage(
      "Please enter the URL",
    ),
    "g_browser_key10": MessageLookupByLibrary.simpleMessage(
      "Enter a description",
    ),
    "g_browser_key11": MessageLookupByLibrary.simpleMessage("Browser"),
    "g_browser_key12": MessageLookupByLibrary.simpleMessage(
      "Clear Browser Cache",
    ),
    "g_browser_key13": MessageLookupByLibrary.simpleMessage(
      "Connect DApp automatically",
    ),
    "g_browser_key14": MessageLookupByLibrary.simpleMessage(
      "Please confirm connecting to DApp",
    ),
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Close all"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Done"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "g_browser_key4": MessageLookupByLibrary.simpleMessage(
      "No bookmarks added yet",
    ),
    "g_browser_key5": MessageLookupByLibrary.simpleMessage("Bookmark"),
    "g_browser_key6": MessageLookupByLibrary.simpleMessage("Name"),
    "g_browser_key7": MessageLookupByLibrary.simpleMessage(
      "Please enter the Name",
    ),
    "g_browser_key8": MessageLookupByLibrary.simpleMessage("URL"),
    "g_browser_key9": MessageLookupByLibrary.simpleMessage("Description"),
    "g_chat_key_1": MessageLookupByLibrary.simpleMessage("Start group chat"),
    "g_chat_key_10": m1,
    "g_chat_key_11": MessageLookupByLibrary.simpleMessage("Invite friends"),
    "g_chat_key_12": MessageLookupByLibrary.simpleMessage("Select contact"),
    "g_chat_key_13": MessageLookupByLibrary.simpleMessage("Finish"),
    "g_chat_key_14": MessageLookupByLibrary.simpleMessage(
      "Select at least 2 contacts",
    ),
    "g_chat_key_16": MessageLookupByLibrary.simpleMessage("Friend detail"),
    "g_chat_key_17": MessageLookupByLibrary.simpleMessage("Group detail"),
    "g_chat_key_18": MessageLookupByLibrary.simpleMessage(
      "View more group members",
    ),
    "g_chat_key_19": MessageLookupByLibrary.simpleMessage("Group name"),
    "g_chat_key_2": MessageLookupByLibrary.simpleMessage("New friend"),
    "g_chat_key_20": MessageLookupByLibrary.simpleMessage(
      "Are we sure we\'re disbanding ?",
    ),
    "g_chat_key_21": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to leave this group?",
    ),
    "g_chat_key_22": MessageLookupByLibrary.simpleMessage("Ungroup"),
    "g_chat_key_23": MessageLookupByLibrary.simpleMessage("Leave group"),
    "g_chat_key_24": MessageLookupByLibrary.simpleMessage(
      "Change the group chat name",
    ),
    "g_chat_key_25": MessageLookupByLibrary.simpleMessage(
      "When the group chat name is changed, other members will be notified within the group.",
    ),
    "g_chat_key_26": MessageLookupByLibrary.simpleMessage("Finish"),
    "g_chat_key_27": MessageLookupByLibrary.simpleMessage("Friend add request"),
    "g_chat_key_28": MessageLookupByLibrary.simpleMessage(
      "Request to add you as a friend",
    ),
    "g_chat_key_29": MessageLookupByLibrary.simpleMessage(
      "Friend request approved",
    ),
    "g_chat_key_3": MessageLookupByLibrary.simpleMessage("Added"),
    "g_chat_key_30": MessageLookupByLibrary.simpleMessage(
      "You have been added as a friend",
    ),
    "g_chat_key_31": MessageLookupByLibrary.simpleMessage("agree"),
    "g_chat_key_32": m2,
    "g_chat_key_33": MessageLookupByLibrary.simpleMessage(
      "The password cannot be parsed properly, and the message cannot be sent temporarily. Please import the wallet when entering the group",
    ),
    "g_chat_key_34": MessageLookupByLibrary.simpleMessage(
      "Delete the chat history？",
    ),
    "g_chat_key_35": MessageLookupByLibrary.simpleMessage("Remove member"),
    "g_chat_key_36": MessageLookupByLibrary.simpleMessage("My QR Code"),
    "g_chat_key_4": MessageLookupByLibrary.simpleMessage("Have expired"),
    "g_chat_key_40": MessageLookupByLibrary.simpleMessage("Report"),
    "g_chat_key_41": MessageLookupByLibrary.simpleMessage("New Chat"),
    "g_chat_key_42": MessageLookupByLibrary.simpleMessage("New Group"),
    "g_chat_key_43": MessageLookupByLibrary.simpleMessage("QR Code"),
    "g_chat_key_44": MessageLookupByLibrary.simpleMessage("Report and Block"),
    "g_chat_key_45": MessageLookupByLibrary.simpleMessage(
      "This message will be forwarded to N42Wallet. This contact will not be notified.",
    ),
    "g_chat_key_46": MessageLookupByLibrary.simpleMessage("Video"),
    "g_chat_key_47": MessageLookupByLibrary.simpleMessage("Photo"),
    "g_chat_key_48": MessageLookupByLibrary.simpleMessage("Delete Message"),
    "g_chat_key_49": MessageLookupByLibrary.simpleMessage(
      "Delete on my device",
    ),
    "g_chat_key_5": MessageLookupByLibrary.simpleMessage("Wait"),
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Agree"),
    "g_chat_key_54": MessageLookupByLibrary.simpleMessage("Report Reason"),
    "g_chat_key_55": MessageLookupByLibrary.simpleMessage(
      "Enter your report reason",
    ),
    "g_chat_key_56": MessageLookupByLibrary.simpleMessage(
      "We will verify your report and respond within 24 hours.",
    ),
    "g_chat_key_57": MessageLookupByLibrary.simpleMessage(
      "You reported this - Click to see",
    ),
    "g_chat_key_58": MessageLookupByLibrary.simpleMessage("Blacklist"),
    "g_chat_key_59": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_chat_key_6": m3,
    "g_chat_key_60": MessageLookupByLibrary.simpleMessage("No contact yet"),
    "g_chat_key_61": MessageLookupByLibrary.simpleMessage("Today"),
    "g_chat_key_62": MessageLookupByLibrary.simpleMessage("Over 3 days ago"),
    "g_chat_key_63": MessageLookupByLibrary.simpleMessage("Block"),
    "g_chat_key_64": MessageLookupByLibrary.simpleMessage(
      "Hey, I’m using N42Wallet to chat and send money. Install Wallet and message me at",
    ),
    "g_chat_key_66": MessageLookupByLibrary.simpleMessage("Reply"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "The message has been deleted",
    ),
    "g_chat_key_68": MessageLookupByLibrary.simpleMessage("Someone @ me"),
    "g_chat_key_69": MessageLookupByLibrary.simpleMessage("Say hi"),
    "g_chat_key_8": MessageLookupByLibrary.simpleMessage("Add friends"),
    "g_chat_key_9": MessageLookupByLibrary.simpleMessage(
      "reason for application",
    ),
    "g_coin_key_1": MessageLookupByLibrary.simpleMessage("Transactions"),
    "g_connect_key1": MessageLookupByLibrary.simpleMessage("Connect"),
    "g_connect_key11": MessageLookupByLibrary.simpleMessage(
      "Available Networks",
    ),
    "g_connect_key12": MessageLookupByLibrary.simpleMessage("Message sign"),
    "g_connect_key13": MessageLookupByLibrary.simpleMessage("Connecting"),
    "g_connect_key14": MessageLookupByLibrary.simpleMessage(
      "Pairing, please wait.",
    ),
    "g_connect_key2": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_connect_key3": MessageLookupByLibrary.simpleMessage("Reject"),
    "g_face_1": MessageLookupByLibrary.simpleMessage("Biometric Scan Tips"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scan your fingerprint or face for authentication.",
    ),
    "g_face_2": MessageLookupByLibrary.simpleMessage(
      "Biometric scan didn\'t work",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Tips"),
    "g_face_4": MessageLookupByLibrary.simpleMessage("Biometric scan success"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("To set"),
    "g_face_6": MessageLookupByLibrary.simpleMessage(
      "You haven\'t set biometric login. Go to System Settings to set it.",
    ),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scan your face or fingerprint to continue.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Return"),
    "g_face_9": MessageLookupByLibrary.simpleMessage(
      "It is recommended that you re-enable biometrics.",
    ),
    "g_face_match_key1": MessageLookupByLibrary.simpleMessage(
      "Face matching method",
    ),
    "g_face_match_key10": m4,
    "g_face_match_key11": m5,
    "g_face_match_key12": MessageLookupByLibrary.simpleMessage("Rebind"),
    "g_face_match_key13": MessageLookupByLibrary.simpleMessage("Bind"),
    "g_face_match_key14": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_face_match_key15": MessageLookupByLibrary.simpleMessage(
      "You can bind your facial data to a wallet address directly (if you have previously bound one, the old wallet address will be overwritten), or if you have previously bound a wallet address, you can also manually verify to retrieve the bound wallet address.",
    ),
    "g_face_match_key16": MessageLookupByLibrary.simpleMessage(
      "The wallet address linked to your facial data has been detected as follows, but you have not yet imported this wallet into your wallet list.",
    ),
    "g_face_match_key17": MessageLookupByLibrary.simpleMessage(
      "You have linked your facial data with this wallet.",
    ),
    "g_face_match_key18": MessageLookupByLibrary.simpleMessage("User Notice"),
    "g_face_match_key19": MessageLookupByLibrary.simpleMessage(
      "What is Face Binding?",
    ),
    "g_face_match_key20": MessageLookupByLibrary.simpleMessage(
      "Face binding utilizes facial recognition technology to match your biometric facial features with your blockchain wallet address.",
    ),
    "g_face_match_key21": MessageLookupByLibrary.simpleMessage(
      "This process not only enhances transaction convenience but also strengthens account security, ensuring that every action is authorized by you.",
    ),
    "g_face_match_key22": MessageLookupByLibrary.simpleMessage(
      "Why is Face Binding Necessary?",
    ),
    "g_face_match_key23": MessageLookupByLibrary.simpleMessage(
      "By binding your face data, your identity is directly linked to transaction activities, simplifying the identity verification process and improving operational efficiency. This technology ensures quick and secure identity verification when performing sensitive operations such as transferring assets or interacting with contracts.",
    ),
    "g_face_match_key24": MessageLookupByLibrary.simpleMessage(
      "How is My Face Data Stored and Is It Secure?",
    ),
    "g_face_match_key25": MessageLookupByLibrary.simpleMessage(
      "Your face data is stored in an encrypted form on a public blockchain, not in any centralized database. This means the system can only decrypt and use your data for identity verification when authorized by you, ensuring your privacy and data security.",
    ),
    "g_face_match_key26": MessageLookupByLibrary.simpleMessage(
      "How Does Face Binding Affect My Account Security?",
    ),
    "g_face_match_key27": MessageLookupByLibrary.simpleMessage(
      "Face binding enhances your account security by ensuring that all sensitive actions are carried out only with your explicit authorization. We use industry-leading encryption technology to protect your biometric data, preventing unauthorized access.",
    ),
    "g_face_match_key28": MessageLookupByLibrary.simpleMessage(
      "Is My Face Data Secure?",
    ),
    "g_face_match_key29": MessageLookupByLibrary.simpleMessage(
      "Absolutely. All biometric data undergoes strict encryption, and the highest security standards are followed for data transmission and storage. The system will only decrypt this data when necessary to complete identity verification.",
    ),
    "g_face_match_key3": MessageLookupByLibrary.simpleMessage("Match failed!"),
    "g_face_match_key30": MessageLookupByLibrary.simpleMessage("Got it"),
    "g_face_match_key31": MessageLookupByLibrary.simpleMessage(
      "Select wallet address",
    ),
    "g_face_match_key32": m6,
    "g_face_match_key33": MessageLookupByLibrary.simpleMessage("Unbinding"),
    "g_face_match_key34": MessageLookupByLibrary.simpleMessage(
      "Facial data verification failed!",
    ),
    "g_face_match_key35": MessageLookupByLibrary.simpleMessage(
      "Face data unbinding failed!",
    ),
    "g_face_match_key4": m7,
    "g_face_match_key5": MessageLookupByLibrary.simpleMessage("Address error!"),
    "g_face_match_key6": MessageLookupByLibrary.simpleMessage(
      "Face Data Binding",
    ),
    "g_face_match_key7": MessageLookupByLibrary.simpleMessage("Face matching"),
    "g_face_match_key8": MessageLookupByLibrary.simpleMessage("Reselect"),
    "g_face_match_key9": MessageLookupByLibrary.simpleMessage("Match"),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profile"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("News"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verification"),
    "g_home_key5": MessageLookupByLibrary.simpleMessage("Messages"),
    "g_home_key6": MessageLookupByLibrary.simpleMessage("Learn"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invite a friend"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Failed to remove!"),
    "g_key_100": MessageLookupByLibrary.simpleMessage("Send"),
    "g_key_101": MessageLookupByLibrary.simpleMessage("Gas limit"),
    "g_key_105": MessageLookupByLibrary.simpleMessage("No more"),
    "g_key_106": MessageLookupByLibrary.simpleMessage("Loading "),
    "g_key_108": MessageLookupByLibrary.simpleMessage("Address Book"),
    "g_key_11": MessageLookupByLibrary.simpleMessage("Import wallet"),
    "g_key_110": MessageLookupByLibrary.simpleMessage("Manage"),
    "g_key_112": MessageLookupByLibrary.simpleMessage("New address"),
    "g_key_113": MessageLookupByLibrary.simpleMessage("Delete"),
    "g_key_115": MessageLookupByLibrary.simpleMessage("Save"),
    "g_key_119": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_12": MessageLookupByLibrary.simpleMessage("Create/Import wallet"),
    "g_key_126": MessageLookupByLibrary.simpleMessage("Theme"),
    "g_key_127": MessageLookupByLibrary.simpleMessage("System"),
    "g_key_128": MessageLookupByLibrary.simpleMessage("Light"),
    "g_key_129": MessageLookupByLibrary.simpleMessage("Dark"),
    "g_key_13": MessageLookupByLibrary.simpleMessage("Wallet List"),
    "g_key_132": MessageLookupByLibrary.simpleMessage("No data"),
    "g_key_134": MessageLookupByLibrary.simpleMessage("Amount not valid"),
    "g_key_135": m8,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Main Wallet"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaction successful"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Incorrect password"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Mainnet"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("System language"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("Set as Main Wallet"),
    "g_key_154": MessageLookupByLibrary.simpleMessage("Submit"),
    "g_key_155": MessageLookupByLibrary.simpleMessage("Wallet address"),
    "g_key_156": MessageLookupByLibrary.simpleMessage("Scan to copy address"),
    "g_key_159": MessageLookupByLibrary.simpleMessage("Add"),
    "g_key_16": MessageLookupByLibrary.simpleMessage("Select Verify Wallet"),
    "g_key_163": MessageLookupByLibrary.simpleMessage("Symbol"),
    "g_key_166": MessageLookupByLibrary.simpleMessage("Paste"),
    "g_key_17": MessageLookupByLibrary.simpleMessage("Choose Chain"),
    "g_key_175": MessageLookupByLibrary.simpleMessage("Transaction failed"),
    "g_key_179": MessageLookupByLibrary.simpleMessage(
      "This is my wallet address",
    ),
    "g_key_181": MessageLookupByLibrary.simpleMessage("Other"),
    "g_key_185": MessageLookupByLibrary.simpleMessage("Successfully saved"),
    "g_key_191": MessageLookupByLibrary.simpleMessage("Success"),
    "g_key_192": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to delete the wallet?",
    ),
    "g_key_193": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_195": MessageLookupByLibrary.simpleMessage(
      "No permission to access the camera.",
    ),
    "g_key_196": MessageLookupByLibrary.simpleMessage("Explorer"),
    "g_key_197": MessageLookupByLibrary.simpleMessage("Max"),
    "g_key_198": MessageLookupByLibrary.simpleMessage("Assets"),
    "g_key_2": MessageLookupByLibrary.simpleMessage("The ledger is empty!"),
    "g_key_202": MessageLookupByLibrary.simpleMessage("Transaction Overview"),
    "g_key_203": MessageLookupByLibrary.simpleMessage(
      "link error, scan QR Code again.",
    ),
    "g_key_205": MessageLookupByLibrary.simpleMessage(
      "No permission to access the photo album.",
    ),
    "g_key_206": MessageLookupByLibrary.simpleMessage("Password Edit"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Old Password"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("Syncing balances..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Private Key"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Enter wallet password"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Private key error"),
    "g_key_211": MessageLookupByLibrary.simpleMessage("Buy"),
    "g_key_212": MessageLookupByLibrary.simpleMessage("Sell"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Market Information"),
    "g_key_214": m9,
    "g_key_25": MessageLookupByLibrary.simpleMessage(
      "Password doesn\'t match.",
    ),
    "g_key_29": MessageLookupByLibrary.simpleMessage("Balance"),
    "g_key_3": MessageLookupByLibrary.simpleMessage("Failed to add!"),
    "g_key_33": MessageLookupByLibrary.simpleMessage("Receive"),
    "g_key_37": MessageLookupByLibrary.simpleMessage("Transfer"),
    "g_key_38": MessageLookupByLibrary.simpleMessage("To"),
    "g_key_4": MessageLookupByLibrary.simpleMessage("Scan QR code"),
    "g_key_41": MessageLookupByLibrary.simpleMessage("Enter a wallet address"),
    "g_key_43": MessageLookupByLibrary.simpleMessage("Available Balance"),
    "g_key_44": MessageLookupByLibrary.simpleMessage("Amount"),
    "g_key_46": m10,
    "g_key_47": MessageLookupByLibrary.simpleMessage(
      "Insufficient funds available to cover this transaction.",
    ),
    "g_key_48": MessageLookupByLibrary.simpleMessage("Send"),
    "g_key_5": MessageLookupByLibrary.simpleMessage("Failed to load!"),
    "g_key_6": MessageLookupByLibrary.simpleMessage("Wallet"),
    "g_key_7": MessageLookupByLibrary.simpleMessage("Create"),
    "g_key_75": MessageLookupByLibrary.simpleMessage("From"),
    "g_key_78": MessageLookupByLibrary.simpleMessage("Confirm"),
    "g_key_79": MessageLookupByLibrary.simpleMessage("Cancel"),
    "g_key_8": MessageLookupByLibrary.simpleMessage("Remark"),
    "g_key_85": MessageLookupByLibrary.simpleMessage("Seed phrase"),
    "g_key_9": MessageLookupByLibrary.simpleMessage("All tokens"),
    "g_key_94": MessageLookupByLibrary.simpleMessage("Settings"),
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
      "Calculating address...",
    ),
    "g_key_aa_address_error": MessageLookupByLibrary.simpleMessage(
      "Failed to calculate address. Please try again.",
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
      "Biconomy Account",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Modular ERC-7579 smart account with gasless transaction support",
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
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to pay for transaction gas fees",
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
      "Guardians",
    ),
    "g_key_aa_safe_threshold": MessageLookupByLibrary.simpleMessage(
      "Threshold",
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
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Session Key Details",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
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
    "g_key_address": MessageLookupByLibrary.simpleMessage("Address"),
    "g_key_address_1": MessageLookupByLibrary.simpleMessage(
      "Please enter a name",
    ),
    "g_key_address_2": MessageLookupByLibrary.simpleMessage(
      "Please enter address",
    ),
    "g_key_address_3": MessageLookupByLibrary.simpleMessage(
      "Please select a coin type",
    ),
    "g_key_address_4": MessageLookupByLibrary.simpleMessage("Edit address"),
    "g_key_address_5": MessageLookupByLibrary.simpleMessage(
      "Successfully deleted",
    ),
    "g_key_address_6": MessageLookupByLibrary.simpleMessage("Choose Coins"),
    "g_key_address_7": MessageLookupByLibrary.simpleMessage("Search coins"),
    "g_key_advanced_features": MessageLookupByLibrary.simpleMessage(
      "Advanced Features",
    ),
    "g_key_airdrop_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_airdrop_check_eligibility": MessageLookupByLibrary.simpleMessage(
      "Check Eligibility",
    ),
    "g_key_airdrop_claim": MessageLookupByLibrary.simpleMessage("Claim"),
    "g_key_airdrop_claimed": MessageLookupByLibrary.simpleMessage("Claimed"),
    "g_key_airdrop_days_left": m11,
    "g_key_airdrop_deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "g_key_airdrop_eligible": MessageLookupByLibrary.simpleMessage("Eligible"),
    "g_key_airdrop_estimated_value": MessageLookupByLibrary.simpleMessage(
      "Estimated Value",
    ),
    "g_key_airdrop_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_airdrop_filter": MessageLookupByLibrary.simpleMessage("Filter"),
    "g_key_airdrop_no_airdrops": MessageLookupByLibrary.simpleMessage(
      "No airdrops available",
    ),
    "g_key_airdrop_not_eligible": MessageLookupByLibrary.simpleMessage(
      "Not Eligible",
    ),
    "g_key_airdrop_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_airdrop_priority_high": MessageLookupByLibrary.simpleMessage(
      "High Priority",
    ),
    "g_key_airdrop_priority_low": MessageLookupByLibrary.simpleMessage(
      "Low Priority",
    ),
    "g_key_airdrop_priority_medium": MessageLookupByLibrary.simpleMessage(
      "Medium Priority",
    ),
    "g_key_airdrop_requirement_met": MessageLookupByLibrary.simpleMessage(
      "Requirement met",
    ),
    "g_key_airdrop_requirement_not_met": MessageLookupByLibrary.simpleMessage(
      "Not met",
    ),
    "g_key_airdrop_requirements": MessageLookupByLibrary.simpleMessage(
      "Requirements",
    ),
    "g_key_airdrop_sort_by": MessageLookupByLibrary.simpleMessage("Sort By"),
    "g_key_airdrop_title": MessageLookupByLibrary.simpleMessage(
      "Airdrop Tracker",
    ),
    "g_key_airdrop_total_claimed": MessageLookupByLibrary.simpleMessage(
      "Total Claimed",
    ),
    "g_key_airdrop_upcoming": MessageLookupByLibrary.simpleMessage("Upcoming"),
    "g_key_apple_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Apple sign-in cancelled",
    ),
    "g_key_apply": MessageLookupByLibrary.simpleMessage("Apply"),
    "g_key_batch_add_recipient": MessageLookupByLibrary.simpleMessage(
      "Add Recipient",
    ),
    "g_key_batch_broadcasting": MessageLookupByLibrary.simpleMessage(
      "Broadcasting...",
    ),
    "g_key_batch_clear_all": MessageLookupByLibrary.simpleMessage("Clear All"),
    "g_key_batch_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Batch Transfer",
    ),
    "g_key_batch_continue": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_key_batch_csv_format": MessageLookupByLibrary.simpleMessage(
      "CSV Format: address,amount,label",
    ),
    "g_key_batch_done": MessageLookupByLibrary.simpleMessage("Done"),
    "g_key_batch_duplicate_address": m12,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_execute": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Export CSV",
    ),
    "g_key_batch_gas_savings": MessageLookupByLibrary.simpleMessage(
      "Gas Savings",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Import CSV",
    ),
    "g_key_batch_insufficient_balance": m67,
    "g_key_batch_invalid_address": m13,
    "g_key_batch_invalid_amount": m14,
    "g_key_batch_max_recipients": m15,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No supported tokens",
    ),
    "g_key_batch_preview": MessageLookupByLibrary.simpleMessage("Preview"),
    "g_key_batch_recipients": MessageLookupByLibrary.simpleMessage(
      "Recipients",
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
    "g_key_batch_title": MessageLookupByLibrary.simpleMessage("Batch Transfer"),
    "g_key_batch_total_amount": MessageLookupByLibrary.simpleMessage(
      "Total Amount",
    ),
    "g_key_bridge_amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Chain not supported",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Cheapest"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "You will receive (estimated)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Fastest"),
    "g_key_bridge_fee": MessageLookupByLibrary.simpleMessage("Bridge Fee"),
    "g_key_bridge_from_chain": MessageLookupByLibrary.simpleMessage(
      "From Chain",
    ),
    "g_key_bridge_get_quote": MessageLookupByLibrary.simpleMessage("Get Quote"),
    "g_key_bridge_history": MessageLookupByLibrary.simpleMessage(
      "Bridge History",
    ),
    "g_key_bridge_no_routes": MessageLookupByLibrary.simpleMessage(
      "No routes available",
    ),
    "g_key_bridge_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommended",
    ),
    "g_key_bridge_refresh": MessageLookupByLibrary.simpleMessage("Refresh"),
    "g_key_bridge_route": MessageLookupByLibrary.simpleMessage("Route"),
    "g_key_bridge_search_chain": MessageLookupByLibrary.simpleMessage(
      "Search chain...",
    ),
    "g_key_bridge_select": MessageLookupByLibrary.simpleMessage("Select"),
    "g_key_bridge_select_token": MessageLookupByLibrary.simpleMessage(
      "Select Token",
    ),
    "g_key_bridge_slippage": MessageLookupByLibrary.simpleMessage("Slippage"),
    "g_key_bridge_status_completed": MessageLookupByLibrary.simpleMessage(
      "Completed",
    ),
    "g_key_bridge_status_failed": MessageLookupByLibrary.simpleMessage(
      "Failed",
    ),
    "g_key_bridge_status_in_progress": MessageLookupByLibrary.simpleMessage(
      "In Progress",
    ),
    "g_key_bridge_status_pending": MessageLookupByLibrary.simpleMessage(
      "Pending",
    ),
    "g_key_bridge_swap": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_time": MessageLookupByLibrary.simpleMessage("Estimated Time"),
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_key_bridge_to_chain": MessageLookupByLibrary.simpleMessage("To Chain"),
    "g_key_bridge_tx_failed": MessageLookupByLibrary.simpleMessage(
      "Bridge Failed",
    ),
    "g_key_bridge_tx_pending": MessageLookupByLibrary.simpleMessage(
      "Transaction Pending",
    ),
    "g_key_bridge_tx_success": MessageLookupByLibrary.simpleMessage(
      "Bridge Successful",
    ),
    "g_key_btc_redeem_locked_until": MessageLookupByLibrary.simpleMessage(
      "Locked until",
    ),
    "g_key_btc_redeem_reminder": MessageLookupByLibrary.simpleMessage(
      "Verify the lock period has expired before submitting your redemption.",
    ),
    "g_key_btc_redeem_still_locked": MessageLookupByLibrary.simpleMessage(
      "BTC still locked",
    ),
    "g_key_btc_redeem_title": MessageLookupByLibrary.simpleMessage(
      "Redeem vBTC",
    ),
    "g_key_btc_redeem_unlocked": MessageLookupByLibrary.simpleMessage(
      "Unlocked — ready to redeem",
    ),
    "g_key_btc_stake_acknowledge": MessageLookupByLibrary.simpleMessage(
      "I understand the risks and wish to proceed",
    ),
    "g_key_btc_stake_continue": MessageLookupByLibrary.simpleMessage(
      "Continue to Stake",
    ),
    "g_key_btc_stake_how_it_works": MessageLookupByLibrary.simpleMessage(
      "How It Works",
    ),
    "g_key_btc_stake_reminder": MessageLookupByLibrary.simpleMessage(
      "BTC will be locked until the timelock expires. Complete the staking process in the interface below.",
    ),
    "g_key_btc_stake_risk1": MessageLookupByLibrary.simpleMessage(
      "Your BTC will be locked for the full staking period. Early withdrawal is not possible.",
    ),
    "g_key_btc_stake_risk2": MessageLookupByLibrary.simpleMessage(
      "The lock is enforced by Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) and cannot be bypassed.",
    ),
    "g_key_btc_stake_risk3": MessageLookupByLibrary.simpleMessage(
      "Smart contract risk: although audited, no protocol is entirely risk-free.",
    ),
    "g_key_btc_stake_risk4": MessageLookupByLibrary.simpleMessage(
      "Minimum staking: 0.001 BTC. Minimum lock period: 0.125 days (~3 hours).",
    ),
    "g_key_btc_stake_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Risk Warning",
    ),
    "g_key_btc_stake_step1_desc": MessageLookupByLibrary.simpleMessage(
      "Your BTC is locked in a 2-of-2 multisig address with a time-lock (CLTV), secured by your key and the N42 canister key.",
    ),
    "g_key_btc_stake_step1_title": MessageLookupByLibrary.simpleMessage(
      "Lock Your BTC",
    ),
    "g_key_btc_stake_step2_desc": MessageLookupByLibrary.simpleMessage(
      "After on-chain confirmation, vBTC is minted to your wallet at a 1:1 ratio.",
    ),
    "g_key_btc_stake_step2_title": MessageLookupByLibrary.simpleMessage(
      "Mint vBTC",
    ),
    "g_key_btc_stake_step3_desc": MessageLookupByLibrary.simpleMessage(
      "Hold vBTC to earn staking rewards. vBTC is also usable in DeFi protocols.",
    ),
    "g_key_btc_stake_step3_title": MessageLookupByLibrary.simpleMessage(
      "Earn Rewards",
    ),
    "g_key_btc_stake_step4_desc": MessageLookupByLibrary.simpleMessage(
      "When the lock period expires, burn your vBTC to receive your original BTC back.",
    ),
    "g_key_btc_stake_step4_title": MessageLookupByLibrary.simpleMessage(
      "Redeem After Unlock",
    ),
    "g_key_btc_stake_subtitle": MessageLookupByLibrary.simpleMessage(
      "Lock BTC to mint vBTC and earn rewards",
    ),
    "g_key_btc_stake_title": MessageLookupByLibrary.simpleMessage(
      "BTC Self-Custody Staking",
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
    "g_key_coin_list_all_hidden": MessageLookupByLibrary.simpleMessage(
      "All assets are below \$1",
    ),
    "g_key_coin_list_separator": MessageLookupByLibrary.simpleMessage(
      "Other assets",
    ),
    "g_key_coin_list_show_all": MessageLookupByLibrary.simpleMessage(
      "Tap to show all",
    ),
    "g_key_coin_search_recent": MessageLookupByLibrary.simpleMessage("Recent"),
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
    "g_key_earn_active_products": MessageLookupByLibrary.simpleMessage(
      "Active Products",
    ),
    "g_key_earn_batch": MessageLookupByLibrary.simpleMessage("Batch"),
    "g_key_earn_burn": MessageLookupByLibrary.simpleMessage("Burn"),
    "g_key_earn_buy_n": MessageLookupByLibrary.simpleMessage("Buy N"),
    "g_key_earn_buy_n_desc": MessageLookupByLibrary.simpleMessage(
      "Buy N with AST protocol",
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
      "Swap any token via Uniswap / 1inch",
    ),
    "g_key_earn_dex_swap": MessageLookupByLibrary.simpleMessage("DEX Swap"),
    "g_key_earn_gas": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_earn_go_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_earn_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_earn_loading_apy": MessageLookupByLibrary.simpleMessage(
      "Loading APY...",
    ),
    "g_key_earn_mining": MessageLookupByLibrary.simpleMessage("Mining"),
    "g_key_earn_more": MessageLookupByLibrary.simpleMessage("Earn More"),
    "g_key_earn_native_sol": MessageLookupByLibrary.simpleMessage(
      "Native Solana staking",
    ),
    "g_key_earn_no_positions": MessageLookupByLibrary.simpleMessage(
      "No active positions",
    ),
    "g_key_earn_node_mining": MessageLookupByLibrary.simpleMessage(
      "Node Mining",
    ),
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Earn rewards by participating in node mining",
    ),
    "g_key_earn_points_daily": MessageLookupByLibrary.simpleMessage(
      "Earn points daily",
    ),
    "g_key_earn_pts_day": m16,
    "g_key_earn_quick_tools": MessageLookupByLibrary.simpleMessage(
      "Quick Tools",
    ),
    "g_key_earn_recommended": MessageLookupByLibrary.simpleMessage(
      "Recommended",
    ),
    "g_key_earn_select_swap": MessageLookupByLibrary.simpleMessage(
      "Select Swap Type",
    ),
    "g_key_earn_stake_eth_lido": MessageLookupByLibrary.simpleMessage(
      "Stake ETH with Lido",
    ),
    "g_key_earn_swap": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_key_earn_title": MessageLookupByLibrary.simpleMessage("Earn"),
    "g_key_earn_total_earnings": MessageLookupByLibrary.simpleMessage(
      "Total Earnings",
    ),
    "g_key_earn_up_to_apy": m17,
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
    "g_key_ens_success_message": m18,
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
    "g_key_ens_wait_timer": m19,
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
      "Parsing response data error!",
    ),
    "g_key_error_10": MessageLookupByLibrary.simpleMessage("Dio Error"),
    "g_key_error_11": MessageLookupByLibrary.simpleMessage(
      "Request syntax error",
    ),
    "g_key_error_12": MessageLookupByLibrary.simpleMessage(
      "Unauthorized, please log in",
    ),
    "g_key_error_13": MessageLookupByLibrary.simpleMessage("Access denied"),
    "g_key_error_1301": MessageLookupByLibrary.simpleMessage(
      "Incorrect account or password",
    ),
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Request error"),
    "g_key_error_1403": MessageLookupByLibrary.simpleMessage(
      "You are already logged in on another phone and are forced to log out.",
    ),
    "g_key_error_15": MessageLookupByLibrary.simpleMessage("Request timed out"),
    "g_key_error_16": MessageLookupByLibrary.simpleMessage("Server abnormal"),
    "g_key_error_17": MessageLookupByLibrary.simpleMessage(
      "Service not implemented",
    ),
    "g_key_error_18": MessageLookupByLibrary.simpleMessage("Gateway error"),
    "g_key_error_19": MessageLookupByLibrary.simpleMessage(
      "Service is not available",
    ),
    "g_key_error_20": MessageLookupByLibrary.simpleMessage("Gateway timeout"),
    "g_key_error_21": MessageLookupByLibrary.simpleMessage(
      "HTTP version is not supported",
    ),
    "g_key_error_22": MessageLookupByLibrary.simpleMessage(
      "The request failed, error code:",
    ),
    "g_key_error_23": MessageLookupByLibrary.simpleMessage(
      "System is busy, please try again later",
    ),
    "g_key_error_24": MessageLookupByLibrary.simpleMessage(
      "Request frequency is too fast",
    ),
    "g_key_error_25": MessageLookupByLibrary.simpleMessage("Decoding failed"),
    "g_key_error_26": MessageLookupByLibrary.simpleMessage(
      "The transaction is already on the chain",
    ),
    "g_key_error_27": MessageLookupByLibrary.simpleMessage(
      "Certificate configuration error!",
    ),
    "g_key_error_28": MessageLookupByLibrary.simpleMessage(
      "Status code configuration error!",
    ),
    "g_key_error_3": MessageLookupByLibrary.simpleMessage("Unknown error!"),
    "g_key_error_4": MessageLookupByLibrary.simpleMessage(
      "Network connection timed out, please check network settings!",
    ),
    "g_key_error_5": MessageLookupByLibrary.simpleMessage(
      "The server is abnormal. Please try again later!",
    ),
    "g_key_error_8": MessageLookupByLibrary.simpleMessage(
      "Request has been cancelled, please request again!",
    ),
    "g_key_ex_keystore": MessageLookupByLibrary.simpleMessage(
      "Export Keystore",
    ),
    "g_key_ex_keystore_1": MessageLookupByLibrary.simpleMessage("Backup Tips"),
    "g_key_ex_keystore_10": MessageLookupByLibrary.simpleMessage(
      "Use a password management tool to store.",
    ),
    "g_key_ex_keystore_11": MessageLookupByLibrary.simpleMessage("Copied"),
    "g_key_ex_keystore_12": MessageLookupByLibrary.simpleMessage(
      "Copy cancelled",
    ),
    "g_key_ex_keystore_13": MessageLookupByLibrary.simpleMessage(
      "Identity wallet",
    ),
    "g_key_ex_keystore_15": MessageLookupByLibrary.simpleMessage(
      "Encrypted private key file.",
    ),
    "g_key_ex_keystore_16": MessageLookupByLibrary.simpleMessage(
      "Import method",
    ),
    "g_key_ex_keystore_17": MessageLookupByLibrary.simpleMessage(
      "Keystore file",
    ),
    "g_key_ex_keystore_18": MessageLookupByLibrary.simpleMessage(
      "Please enter the Keystore information.",
    ),
    "g_key_ex_keystore_19": MessageLookupByLibrary.simpleMessage(
      "Export PrivateKey",
    ),
    "g_key_ex_keystore_2": MessageLookupByLibrary.simpleMessage(
      "Obtaining Keystore and password will give the holder full control over wallet assets.",
    ),
    "g_key_ex_keystore_3": MessageLookupByLibrary.simpleMessage(
      "Record carefully and store in a secure location. Keeping multiple physical copies is the safest storage method.",
    ),
    "g_key_ex_keystore_4": MessageLookupByLibrary.simpleMessage(
      "If your private key is lost, it cannot be retrieved. Back it up physically and store it securely.",
    ),
    "g_key_ex_keystore_5": MessageLookupByLibrary.simpleMessage("Save offline"),
    "g_key_ex_keystore_6": MessageLookupByLibrary.simpleMessage(
      "Do not save to any mailbox, notepad, network disk or chat software that isn\'t secure.",
    ),
    "g_key_ex_keystore_7": MessageLookupByLibrary.simpleMessage(
      "Please use network transmission",
    ),
    "g_key_ex_keystore_8": MessageLookupByLibrary.simpleMessage(
      "Please be sure to transmit it through network tools, Once hackers obtain it, it will cause irreparable economic losses",
    ),
    "g_key_ex_keystore_9": MessageLookupByLibrary.simpleMessage(
      "Use tools to save",
    ),
    "g_key_feedback": MessageLookupByLibrary.simpleMessage("Feedback"),
    "g_key_feedback_1": MessageLookupByLibrary.simpleMessage(
      "Please fill in the feedback information",
    ),
    "g_key_feedback_2": MessageLookupByLibrary.simpleMessage(
      "There are unuploaded attachments",
    ),
    "g_key_feedback_3": MessageLookupByLibrary.simpleMessage(
      "Submission Failed",
    ),
    "g_key_feedback_4": MessageLookupByLibrary.simpleMessage(
      "Submitted successfully",
    ),
    "g_key_feedback_5": MessageLookupByLibrary.simpleMessage("Attachments"),
    "g_key_feedback_6": MessageLookupByLibrary.simpleMessage(
      "Upload up to 5 attachments, each attachment cannot be larger than 100MB",
    ),
    "g_key_feedback_7": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_feedback_8": MessageLookupByLibrary.simpleMessage("Click try"),
    "g_key_feedback_9": MessageLookupByLibrary.simpleMessage("Please log in"),
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
    "g_key_gas_auto_refresh": m20,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Base Fee"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_gas_estimated_time": MessageLookupByLibrary.simpleMessage(
      "Est. Time",
    ),
    "g_key_gas_fast": MessageLookupByLibrary.simpleMessage("Fast"),
    "g_key_gas_footer": MessageLookupByLibrary.simpleMessage(
      "Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.",
    ),
    "g_key_gas_max_fee": MessageLookupByLibrary.simpleMessage("Max Fee"),
    "g_key_gas_network_busy": MessageLookupByLibrary.simpleMessage(
      "Network is busy",
    ),
    "g_key_gas_network_idle": MessageLookupByLibrary.simpleMessage(
      "Network is idle",
    ),
    "g_key_gas_network_normal": MessageLookupByLibrary.simpleMessage(
      "Network is normal",
    ),
    "g_key_gas_price_trend": MessageLookupByLibrary.simpleMessage(
      "Price Trend",
    ),
    "g_key_gas_priority_fee": MessageLookupByLibrary.simpleMessage(
      "Priority Fee",
    ),
    "g_key_gas_realtime_prices": MessageLookupByLibrary.simpleMessage(
      "Real-time Gas Prices",
    ),
    "g_key_gas_settings": MessageLookupByLibrary.simpleMessage("Gas Settings"),
    "g_key_gas_slow": MessageLookupByLibrary.simpleMessage("Slow"),
    "g_key_gas_standard": MessageLookupByLibrary.simpleMessage("Standard"),
    "g_key_gas_tracker": MessageLookupByLibrary.simpleMessage("Gas Tracker"),
    "g_key_google_sign_in_cancelled": MessageLookupByLibrary.simpleMessage(
      "Google sign-in cancelled",
    ),
    "g_key_high_value_only": MessageLookupByLibrary.simpleMessage(
      "High value only",
    ),
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Account already imported",
    ),
    "g_key_hw_accounts": MessageLookupByLibrary.simpleMessage("Accounts"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("Add Account"),
    "g_key_hw_confirm_on_device": MessageLookupByLibrary.simpleMessage(
      "Confirm on your device",
    ),
    "g_key_hw_connect": MessageLookupByLibrary.simpleMessage(
      "Connect Hardware Wallet",
    ),
    "g_key_hw_connected": MessageLookupByLibrary.simpleMessage("Connected"),
    "g_key_hw_connecting": MessageLookupByLibrary.simpleMessage(
      "Connecting...",
    ),
    "g_key_hw_derivation_path": MessageLookupByLibrary.simpleMessage(
      "Derivation Path",
    ),
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_disconnected": MessageLookupByLibrary.simpleMessage(
      "Disconnected",
    ),
    "g_key_hw_enable_bluetooth": MessageLookupByLibrary.simpleMessage(
      "Please enable Bluetooth",
    ),
    "g_key_hw_firmware": MessageLookupByLibrary.simpleMessage(
      "Firmware Version",
    ),
    "g_key_hw_import_failed": m68,
    "g_key_hw_ledger": MessageLookupByLibrary.simpleMessage("Ledger"),
    "g_key_hw_no_devices": MessageLookupByLibrary.simpleMessage(
      "No devices found",
    ),
    "g_key_hw_open_app": m21,
    "g_key_hw_rejected": MessageLookupByLibrary.simpleMessage(
      "Rejected on device",
    ),
    "g_key_hw_scanning": MessageLookupByLibrary.simpleMessage(
      "Scanning for devices...",
    ),
    "g_key_hw_select_device": MessageLookupByLibrary.simpleMessage(
      "Select Device",
    ),
    "g_key_hw_sign_message": MessageLookupByLibrary.simpleMessage(
      "Sign Message",
    ),
    "g_key_hw_sign_tx": MessageLookupByLibrary.simpleMessage(
      "Sign Transaction",
    ),
    "g_key_hw_signal_strength": MessageLookupByLibrary.simpleMessage(
      "Signal Strength",
    ),
    "g_key_hw_timeout": MessageLookupByLibrary.simpleMessage(
      "Connection timeout",
    ),
    "g_key_hw_title": MessageLookupByLibrary.simpleMessage("Hardware Wallet"),
    "g_key_hw_trezor": MessageLookupByLibrary.simpleMessage("Trezor"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "A current currency wallet already exists.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Could not read Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_link_account": MessageLookupByLibrary.simpleMessage("Link Account"),
    "g_key_linked_accounts": MessageLookupByLibrary.simpleMessage(
      "Linked Accounts",
    ),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Log In"),
    "g_key_login_success": MessageLookupByLibrary.simpleMessage(
      "Login successful",
    ),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Log Out"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the app?",
    ),
    "g_key_loyalty_available_points": MessageLookupByLibrary.simpleMessage(
      "Available Points",
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
      "Claim Points",
    ),
    "g_key_loyalty_complete_failed": MessageLookupByLibrary.simpleMessage(
      "Task failed, please try again",
    ),
    "g_key_loyalty_complete_success": MessageLookupByLibrary.simpleMessage(
      "Task completed!",
    ),
    "g_key_loyalty_copy": MessageLookupByLibrary.simpleMessage("Copy"),
    "g_key_loyalty_daily_checkin": MessageLookupByLibrary.simpleMessage(
      "Daily Check-in",
    ),
    "g_key_loyalty_earn_points": m22,
    "g_key_loyalty_earned": MessageLookupByLibrary.simpleMessage("Earned"),
    "g_key_loyalty_history": MessageLookupByLibrary.simpleMessage(
      "Points History",
    ),
    "g_key_loyalty_invite": MessageLookupByLibrary.simpleMessage("Invite"),
    "g_key_loyalty_invite_bonus": m23,
    "g_key_loyalty_invite_friends": MessageLookupByLibrary.simpleMessage(
      "Invite Friends",
    ),
    "g_key_loyalty_invited_friends": MessageLookupByLibrary.simpleMessage(
      "Invited Friends",
    ),
    "g_key_loyalty_max_level": MessageLookupByLibrary.simpleMessage(
      "Max Level",
    ),
    "g_key_loyalty_next_prefix": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_loyalty_next_tier": MessageLookupByLibrary.simpleMessage(
      "Next Tier",
    ),
    "g_key_loyalty_no_rewards": MessageLookupByLibrary.simpleMessage(
      "No rewards available",
    ),
    "g_key_loyalty_no_tasks": MessageLookupByLibrary.simpleMessage(
      "No tasks available",
    ),
    "g_key_loyalty_points": MessageLookupByLibrary.simpleMessage("Points"),
    "g_key_loyalty_points_to_next": m24,
    "g_key_loyalty_redeem": MessageLookupByLibrary.simpleMessage("Redeem"),
    "g_key_loyalty_referral": MessageLookupByLibrary.simpleMessage("Referral"),
    "g_key_loyalty_referral_bonus": MessageLookupByLibrary.simpleMessage(
      "Referral Bonus",
    ),
    "g_key_loyalty_referral_code": MessageLookupByLibrary.simpleMessage(
      "Your Referral Code",
    ),
    "g_key_loyalty_referral_link": MessageLookupByLibrary.simpleMessage(
      "Referral Link",
    ),
    "g_key_loyalty_rewards": MessageLookupByLibrary.simpleMessage("Rewards"),
    "g_key_loyalty_share": MessageLookupByLibrary.simpleMessage("Share"),
    "g_key_loyalty_spent": MessageLookupByLibrary.simpleMessage("Spent"),
    "g_key_loyalty_task_complete": MessageLookupByLibrary.simpleMessage(
      "Task Complete",
    ),
    "g_key_loyalty_tasks": MessageLookupByLibrary.simpleMessage("Tasks"),
    "g_key_loyalty_tier": MessageLookupByLibrary.simpleMessage("Tier"),
    "g_key_loyalty_tier_bronze": MessageLookupByLibrary.simpleMessage("Bronze"),
    "g_key_loyalty_tier_diamond": MessageLookupByLibrary.simpleMessage(
      "Diamond",
    ),
    "g_key_loyalty_tier_gold": MessageLookupByLibrary.simpleMessage("Gold"),
    "g_key_loyalty_tier_platinum": MessageLookupByLibrary.simpleMessage(
      "Platinum",
    ),
    "g_key_loyalty_tier_silver": MessageLookupByLibrary.simpleMessage("Silver"),
    "g_key_loyalty_title": MessageLookupByLibrary.simpleMessage("Points"),
    "g_key_loyalty_total_earned": MessageLookupByLibrary.simpleMessage(
      "Total Earned",
    ),
    "g_key_loyalty_total_points": MessageLookupByLibrary.simpleMessage(
      "Total Points",
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
    "g_key_m_2": MessageLookupByLibrary.simpleMessage("Market Cap"),
    "g_key_m_3": MessageLookupByLibrary.simpleMessage("Trading Volume"),
    "g_key_m_4": MessageLookupByLibrary.simpleMessage("Total Supply"),
    "g_key_m_5": MessageLookupByLibrary.simpleMessage("In Circulation"),
    "g_key_m_6": MessageLookupByLibrary.simpleMessage("About"),
    "g_key_m_7": MessageLookupByLibrary.simpleMessage("More"),
    "g_key_m_8": MessageLookupByLibrary.simpleMessage("Links"),
    "g_key_m_9": MessageLookupByLibrary.simpleMessage("Website"),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Please enter seed phrase",
    ),
    "g_key_new_airdrops": MessageLookupByLibrary.simpleMessage("New airdrops"),
    "g_key_new_password": MessageLookupByLibrary.simpleMessage("New Password"),
    "g_key_new_password_same_as_old": MessageLookupByLibrary.simpleMessage(
      "New password must be different from current password",
    ),
    "g_key_next": MessageLookupByLibrary.simpleMessage("Next"),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_16": MessageLookupByLibrary.simpleMessage("Camera"),
    "g_key_nft_17": MessageLookupByLibrary.simpleMessage("Select photo"),
    "g_key_nft_18": MessageLookupByLibrary.simpleMessage("Content"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Name"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Back"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Transaction submitted",
    ),
    "g_key_nft_47": MessageLookupByLibrary.simpleMessage("Select video"),
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
      "Invalid payment amount",
    ),
    "g_key_payment_approx_token": m25,
    "g_key_payment_approx_usdt": m26,
    "g_key_payment_code_title": MessageLookupByLibrary.simpleMessage(
      "Payment QR",
    ),
    "g_key_payment_confirm": MessageLookupByLibrary.simpleMessage("Confirm"),
    "g_key_payment_history": MessageLookupByLibrary.simpleMessage(
      "Payment History",
    ),
    "g_key_payment_history_btn": MessageLookupByLibrary.simpleMessage(
      "History",
    ),
    "g_key_payment_incoming": MessageLookupByLibrary.simpleMessage("Incoming"),
    "g_key_payment_load_failed": MessageLookupByLibrary.simpleMessage(
      "Load failed",
    ),
    "g_key_payment_name_not_set": MessageLookupByLibrary.simpleMessage(
      "Not Set",
    ),
    "g_key_payment_native_insufficient": MessageLookupByLibrary.simpleMessage(
      "Insufficient native balance!",
    ),
    "g_key_payment_native_not_found": MessageLookupByLibrary.simpleMessage(
      "Native chain not found!",
    ),
    "g_key_payment_outgoing": MessageLookupByLibrary.simpleMessage("Outgoing"),
    "g_key_payment_set_amount_title": MessageLookupByLibrary.simpleMessage(
      "Set Payment Amount",
    ),
    "g_key_payment_success": MessageLookupByLibrary.simpleMessage(
      "Payment successful!",
    ),
    "g_key_payment_title": MessageLookupByLibrary.simpleMessage("Payment"),
    "g_key_payment_usdt_insufficient": MessageLookupByLibrary.simpleMessage(
      "Insufficient USDT balance!",
    ),
    "g_key_payment_usdt_not_found": MessageLookupByLibrary.simpleMessage(
      "Please add USDT token!",
    ),
    "g_key_payment_wallet": MessageLookupByLibrary.simpleMessage("Wallet"),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Select from phone gallery",
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
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("Share QR code"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Share link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("Share method"),
    "g_key_sign_in_failed": MessageLookupByLibrary.simpleMessage(
      "Sign in failed",
    ),
    "g_key_social_login": MessageLookupByLibrary.simpleMessage("Social Login"),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
    "g_key_squad_k11": MessageLookupByLibrary.simpleMessage(
      "The file is too large to upload",
    ),
    "g_key_squad_k15": m27,
    "g_key_squad_k18": MessageLookupByLibrary.simpleMessage("Add Contact"),
    "g_key_squad_k24": MessageLookupByLibrary.simpleMessage("Contact"),
    "g_key_squad_k25": MessageLookupByLibrary.simpleMessage("Search by email"),
    "g_key_stake_active": MessageLookupByLibrary.simpleMessage("Active"),
    "g_key_stake_active_positions": MessageLookupByLibrary.simpleMessage(
      "Active Positions",
    ),
    "g_key_stake_amount": MessageLookupByLibrary.simpleMessage("Amount"),
    "g_key_stake_amount_unstake": MessageLookupByLibrary.simpleMessage(
      "Amount to Unstake",
    ),
    "g_key_stake_apy": MessageLookupByLibrary.simpleMessage("APY"),
    "g_key_stake_avg_apy": MessageLookupByLibrary.simpleMessage("Avg APY"),
    "g_key_stake_claim": MessageLookupByLibrary.simpleMessage("Claim Rewards"),
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commission",
    ),
    "g_key_stake_d_unbond": m28,
    "g_key_stake_days_left": m29,
    "g_key_stake_days_remaining": m30,
    "g_key_stake_delegators": MessageLookupByLibrary.simpleMessage(
      "Delegators",
    ),
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Daily Reward",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Yearly Reward",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Go to Swap",
    ),
    "g_key_stake_liquid": MessageLookupByLibrary.simpleMessage(
      "Liquid Staking",
    ),
    "g_key_stake_liquid_staking_label": MessageLookupByLibrary.simpleMessage(
      "Liquid Staking",
    ),
    "g_key_stake_liquid_tag": MessageLookupByLibrary.simpleMessage("Liquid"),
    "g_key_stake_liquid_unstake_desc": MessageLookupByLibrary.simpleMessage(
      "Your liquid token can be traded on DEX directly. Use Swap to exchange it back to the native asset.",
    ),
    "g_key_stake_min_stake": MessageLookupByLibrary.simpleMessage(
      "Minimum Stake",
    ),
    "g_key_stake_no_active_positions": MessageLookupByLibrary.simpleMessage(
      "No active positions to unstake",
    ),
    "g_key_stake_no_lock": MessageLookupByLibrary.simpleMessage("No lock"),
    "g_key_stake_no_positions": MessageLookupByLibrary.simpleMessage(
      "No staking positions",
    ),
    "g_key_stake_no_positions_yet": MessageLookupByLibrary.simpleMessage(
      "No staking positions yet",
    ),
    "g_key_stake_no_validators": MessageLookupByLibrary.simpleMessage(
      "No validators found",
    ),
    "g_key_stake_no_wallet": MessageLookupByLibrary.simpleMessage(
      "Wallet address not available",
    ),
    "g_key_stake_overview": MessageLookupByLibrary.simpleMessage(
      "Total Staking Overview",
    ),
    "g_key_stake_pending_rewards": MessageLookupByLibrary.simpleMessage(
      "Pending Rewards",
    ),
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "My Positions",
    ),
    "g_key_stake_protocol": MessageLookupByLibrary.simpleMessage("Protocol"),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
    "g_key_stake_restake": MessageLookupByLibrary.simpleMessage("Restake"),
    "g_key_stake_rewards": MessageLookupByLibrary.simpleMessage("Rewards"),
    "g_key_stake_search_validator": MessageLookupByLibrary.simpleMessage(
      "Search validators...",
    ),
    "g_key_stake_select_a_validator": MessageLookupByLibrary.simpleMessage(
      "Select a validator",
    ),
    "g_key_stake_select_position": MessageLookupByLibrary.simpleMessage(
      "Select a position to unstake",
    ),
    "g_key_stake_select_validator": MessageLookupByLibrary.simpleMessage(
      "Select Validator",
    ),
    "g_key_stake_sort_by": MessageLookupByLibrary.simpleMessage("Sort by"),
    "g_key_stake_stake": MessageLookupByLibrary.simpleMessage("Stake"),
    "g_key_stake_staked": MessageLookupByLibrary.simpleMessage("Staked"),
    "g_key_stake_start_staking": MessageLookupByLibrary.simpleMessage(
      "Start Staking",
    ),
    "g_key_stake_title": MessageLookupByLibrary.simpleMessage("Staking"),
    "g_key_stake_total_staked": MessageLookupByLibrary.simpleMessage(
      "Total Staked",
    ),
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaction prepared successfully",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("Unbonding"),
    "g_key_stake_unbonding_period": MessageLookupByLibrary.simpleMessage(
      "Unbonding Period",
    ),
    "g_key_stake_unbonding_warning": m69,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Unstake"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage("Updating..."),
    "g_key_stake_uptime": MessageLookupByLibrary.simpleMessage("Uptime"),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validator"),
    "g_key_stake_validators": MessageLookupByLibrary.simpleMessage(
      "Validators",
    ),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "You will receive",
    ),
    "g_key_step_email": MessageLookupByLibrary.simpleMessage("Email"),
    "g_key_step_password": MessageLookupByLibrary.simpleMessage("Password"),
    "g_key_step_verify": MessageLookupByLibrary.simpleMessage("Verify"),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Complete"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas price"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Max gas fee"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Max fee per gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_t_29": m31,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Failure"),
    "g_key_t_30": MessageLookupByLibrary.simpleMessage("Miner Fee"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Proceed"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Wallet password"),
    "g_key_t_33": MessageLookupByLibrary.simpleMessage(
      "Wallet password cannot be empty",
    ),
    "g_key_t_34": MessageLookupByLibrary.simpleMessage("Wrong wallet password"),
    "g_key_t_35": MessageLookupByLibrary.simpleMessage(
      "Please enter wallet password",
    ),
    "g_key_t_36": MessageLookupByLibrary.simpleMessage("Gas Fee Rate"),
    "g_key_t_37": MessageLookupByLibrary.simpleMessage(
      "The latest block Gas Fee Rate average",
    ),
    "g_key_t_4": MessageLookupByLibrary.simpleMessage("Transfer out"),
    "g_key_t_43": MessageLookupByLibrary.simpleMessage(
      "Enter a whole number greater than 0.",
    ),
    "g_key_t_44": MessageLookupByLibrary.simpleMessage("Failed to get data"),
    "g_key_t_45": m32,
    "g_key_t_46": MessageLookupByLibrary.simpleMessage(
      "Check receiving address account",
    ),
    "g_key_t_47": MessageLookupByLibrary.simpleMessage("Find"),
    "g_key_t_49": MessageLookupByLibrary.simpleMessage("No account"),
    "g_key_t_5": MessageLookupByLibrary.simpleMessage("Transfer in"),
    "g_key_t_50": MessageLookupByLibrary.simpleMessage("Invalid address"),
    "g_key_t_51": MessageLookupByLibrary.simpleMessage(
      "Account verification succeeded",
    ),
    "g_key_t_52": m33,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "The receiving address does not have an account, and the first transfer is at least 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas Used"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_time_days_ago": m34,
    "g_key_time_hours_ago": m35,
    "g_key_time_just_now": MessageLookupByLibrary.simpleMessage("Just now"),
    "g_key_time_minutes_ago": m36,
    "g_key_tran_1": MessageLookupByLibrary.simpleMessage("Transaction history"),
    "g_key_tran_4": MessageLookupByLibrary.simpleMessage("Transaction Detail"),
    "g_key_tran_6": MessageLookupByLibrary.simpleMessage(
      "Please view transaction receipts in history",
    ),
    "g_key_tran_7": MessageLookupByLibrary.simpleMessage("Spend amount"),
    "g_key_tran_8": MessageLookupByLibrary.simpleMessage("Get amount"),
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
    "g_key_u_10": MessageLookupByLibrary.simpleMessage("NFT Types"),
    "g_key_u_11": MessageLookupByLibrary.simpleMessage("Followers"),
    "g_key_u_12": MessageLookupByLibrary.simpleMessage("User Types"),
    "g_key_u_13": MessageLookupByLibrary.simpleMessage("Website"),
    "g_key_u_14": MessageLookupByLibrary.simpleMessage("Products link"),
    "g_key_u_15": MessageLookupByLibrary.simpleMessage("Media platforms"),
    "g_key_u_16": MessageLookupByLibrary.simpleMessage("Wallet address"),
    "g_key_u_2": MessageLookupByLibrary.simpleMessage("Nickname"),
    "g_key_u_23": MessageLookupByLibrary.simpleMessage("Avatar upload failed"),
    "g_key_u_3": MessageLookupByLibrary.simpleMessage("Description"),
    "g_key_u_5": MessageLookupByLibrary.simpleMessage("Artist information"),
    "g_key_u_6": MessageLookupByLibrary.simpleMessage("You are not an artist"),
    "g_key_u_7": MessageLookupByLibrary.simpleMessage(
      "Click here to apply to become an artist",
    ),
    "g_key_u_8": MessageLookupByLibrary.simpleMessage("Name"),
    "g_key_u_9": MessageLookupByLibrary.simpleMessage("Revenue"),
    "g_key_unlink_account": MessageLookupByLibrary.simpleMessage(
      "Unlink Account",
    ),
    "g_key_user_p1": MessageLookupByLibrary.simpleMessage(
      "I have read and accepted the ",
    ),
    "g_key_user_p2": MessageLookupByLibrary.simpleMessage("Terms & Conditions"),
    "g_key_user_p3": MessageLookupByLibrary.simpleMessage(
      "Privacy Policy and Personal Information Collection Statement",
    ),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Find the latest version",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Update immediately"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("New version found"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Already the latest version",
    ),
    "g_key_verification_code": MessageLookupByLibrary.simpleMessage(
      "Verification Code",
    ),
    "g_key_verification_code_sent": m37,
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "View Seed Phrase",
    ),
    "g_key_wallet_c11": MessageLookupByLibrary.simpleMessage(
      "Please Make sure you record your seed phrase and store it safely.",
    ),
    "g_key_wallet_c12": MessageLookupByLibrary.simpleMessage(
      "Now try to put your seed phrase again.",
    ),
    "g_key_wallet_c13": MessageLookupByLibrary.simpleMessage("Import Account"),
    "g_key_wallet_c14": MessageLookupByLibrary.simpleMessage("Create Account"),
    "g_key_wallet_c15": MessageLookupByLibrary.simpleMessage(
      "You’re all done!",
    ),
    "g_key_wallet_c16": MessageLookupByLibrary.simpleMessage(
      "You can now fully enjoy your wallet.",
    ),
    "g_key_wallet_c17": MessageLookupByLibrary.simpleMessage("Get Started"),
    "g_key_wallet_c18": MessageLookupByLibrary.simpleMessage("Skip for now"),
    "g_key_wallet_c19": MessageLookupByLibrary.simpleMessage(
      "You can skip backing up the seed phrase for now, and do it again in Settings at any time if you need to.",
    ),
    "g_key_wallet_c21": MessageLookupByLibrary.simpleMessage("Create directly"),
    "g_key_wallet_c22": MessageLookupByLibrary.simpleMessage(
      "created successfully",
    ),
    "g_key_wallet_c23": MessageLookupByLibrary.simpleMessage(
      "If you want to check your wallet detail or export keystore, you can go to Sidebar > Manage Wallet ",
    ),
    "g_key_wallet_c24": MessageLookupByLibrary.simpleMessage(
      "Export my keystore",
    ),
    "g_key_wallet_c25": MessageLookupByLibrary.simpleMessage(
      "Secure your wallet by backing it up",
    ),
    "g_key_wallet_c26": MessageLookupByLibrary.simpleMessage(
      "A keystore is a repository of security certificates and associated private keys.",
    ),
    "g_key_wallet_c27": MessageLookupByLibrary.simpleMessage(
      "Step 1: Go to Manage Wallet.",
    ),
    "g_key_wallet_c28": MessageLookupByLibrary.simpleMessage(
      "Step 2: Select Wallet Address.",
    ),
    "g_key_wallet_c29": MessageLookupByLibrary.simpleMessage(
      "Step 3: Press Export Keystore.",
    ),
    "g_key_wallet_c30": MessageLookupByLibrary.simpleMessage(
      "Go to Manage Wallet",
    ),
    "g_key_wallet_c31": MessageLookupByLibrary.simpleMessage(
      "Back to homepage",
    ),
    "g_key_wallet_c32": MessageLookupByLibrary.simpleMessage("Add Wallet"),
    "g_key_wallet_c33": MessageLookupByLibrary.simpleMessage(
      "Create a wallet using a seed phrase.",
    ),
    "g_key_wallet_c34": MessageLookupByLibrary.simpleMessage(
      "Enter a wallet name",
    ),
    "g_key_wallet_c35": MessageLookupByLibrary.simpleMessage(
      "You haven\'t backed up your wallet seed phrase!",
    ),
    "g_key_wallet_c36": MessageLookupByLibrary.simpleMessage("Backup Now"),
    "g_key_wallet_c37": MessageLookupByLibrary.simpleMessage(
      "Set Wallet Password",
    ),
    "g_key_wallet_c38": MessageLookupByLibrary.simpleMessage("Backup Wallet"),
    "g_key_wallet_c39": MessageLookupByLibrary.simpleMessage(
      "Please record the following seed phrase",
    ),
    "g_key_wallet_c4": MessageLookupByLibrary.simpleMessage("Start"),
    "g_key_wallet_c40": MessageLookupByLibrary.simpleMessage(
      "Internet-connected devices may expose your information. We recommend that you write down the seed phrase and store it securely.",
    ),
    "g_key_wallet_c41": MessageLookupByLibrary.simpleMessage(
      "Warning: Do not disclose your seed phrase to anyone. N42Wallet will never ask you for this information. Please be extremely cautious and store it offline securely. If your seed phrase is exposed, you may lose all your assets and be unable to recover them.",
    ),
    "g_key_wallet_c42": MessageLookupByLibrary.simpleMessage(
      "Warning: The seed phrase is the only way to recover your wallet assets.",
    ),
    "g_key_wallet_c43": MessageLookupByLibrary.simpleMessage("Next step"),
    "g_key_wallet_c44": MessageLookupByLibrary.simpleMessage(
      "Click to view seed phrase",
    ),
    "g_key_wallet_c45": MessageLookupByLibrary.simpleMessage(
      "Please make sure there are no other people or cameras around",
    ),
    "g_key_wallet_c46": MessageLookupByLibrary.simpleMessage(
      "Confirm Seed Phrase",
    ),
    "g_key_wallet_c47": MessageLookupByLibrary.simpleMessage(
      "Wallet Information",
    ),
    "g_key_wallet_c48": MessageLookupByLibrary.simpleMessage("Wallet name"),
    "g_key_wallet_c49": MessageLookupByLibrary.simpleMessage(
      "Please backup your wallet seed phrase first!",
    ),
    "g_key_wallet_c6": MessageLookupByLibrary.simpleMessage(
      "Check Seed Phrase",
    ),
    "g_key_wallet_c7": MessageLookupByLibrary.simpleMessage(
      "Now enter your seed phrase.",
    ),
    "g_key_wallet_c8": MessageLookupByLibrary.simpleMessage("Set Phrase"),
    "g_key_wallet_c9": MessageLookupByLibrary.simpleMessage(
      "Please make sure you record your seed phrase and store it safely. You\'ll need it to import or recover your cryptocurrency wallet.",
    ),
    "g_key_wallet_edit": MessageLookupByLibrary.simpleMessage("Wallet edit"),
    "g_key_wallet_k25": MessageLookupByLibrary.simpleMessage("Time"),
    "g_key_wallet_k33": MessageLookupByLibrary.simpleMessage("Result"),
    "g_key_wallet_k37": MessageLookupByLibrary.simpleMessage(
      "Transaction hash",
    ),
    "g_key_wallet_k47": MessageLookupByLibrary.simpleMessage("Add"),
    "g_key_wallet_k53": MessageLookupByLibrary.simpleMessage("Path"),
    "g_key_wallet_k54": MessageLookupByLibrary.simpleMessage("Block"),
    "g_key_wallet_k55": MessageLookupByLibrary.simpleMessage("Value"),
    "g_key_wallet_k56": MessageLookupByLibrary.simpleMessage("Nonce"),
    "g_key_wallet_k57": MessageLookupByLibrary.simpleMessage("Accelerate"),
    "g_key_wallet_k58": MessageLookupByLibrary.simpleMessage("Note"),
    "g_key_wallet_m1": m38,
    "g_key_wallet_m11": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to cancel your account?",
    ),
    "g_key_wallet_m13": MessageLookupByLibrary.simpleMessage("Confirm logout"),
    "g_key_wallet_m17": MessageLookupByLibrary.simpleMessage(
      "Please enter Google verification code.",
    ),
    "g_key_wallet_m19": m39,
    "g_key_wallet_m2": MessageLookupByLibrary.simpleMessage(
      "The current token has not been added.",
    ),
    "g_key_wallet_m21": MessageLookupByLibrary.simpleMessage(
      "Enter your seed phrase with words separated by spaces",
    ),
    "g_key_wallet_m22": MessageLookupByLibrary.simpleMessage("Import Wallet"),
    "g_key_wallet_m3": m40,
    "g_key_wallet_m4": MessageLookupByLibrary.simpleMessage(
      "The current token balance is insufficient.",
    ),
    "g_key_wallet_m5": m41,
    "g_key_wallet_m6": MessageLookupByLibrary.simpleMessage("Signing error"),
    "g_key_wallet_m8": MessageLookupByLibrary.simpleMessage(
      "Account cancellation",
    ),
    "g_key_wallet_m9": MessageLookupByLibrary.simpleMessage(
      "Enter email verification code.",
    ),
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Manage Wallet",
    ),
    "g_key_xml_0": MessageLookupByLibrary.simpleMessage("Reserved"),
    "g_key_xml_1": MessageLookupByLibrary.simpleMessage("Base Reserve"),
    "g_key_xml_11": m42,
    "g_key_xml_2": MessageLookupByLibrary.simpleMessage("Incremental Reserve"),
    "g_key_xml_22": m43,
    "g_key_xml_3": MessageLookupByLibrary.simpleMessage("Owned Objects Count"),
    "g_key_xml_33": m44,
    "g_key_xml_4": MessageLookupByLibrary.simpleMessage(
      "How to calculate total reserved amount",
    ),
    "g_key_xml_44": MessageLookupByLibrary.simpleMessage(
      "Total Reserve = Base Reserve + (Owned Objects Count × Incremental Reserve)",
    ),
    "g_lock_key1": MessageLookupByLibrary.simpleMessage("Touch ID and Face ID"),
    "g_lock_key10": MessageLookupByLibrary.simpleMessage("Current password"),
    "g_lock_key11": MessageLookupByLibrary.simpleMessage("New password"),
    "g_lock_key12": MessageLookupByLibrary.simpleMessage(
      "Confirm new password",
    ),
    "g_lock_key13": MessageLookupByLibrary.simpleMessage("6-digit number"),
    "g_lock_key15": MessageLookupByLibrary.simpleMessage(
      "Passwords and biometrics",
    ),
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Pattern password"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Set pattern passcode",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "For your account security,please set a group password",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Secondary drawing pattern password",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Draw pattern password",
    ),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Reset the pattern password",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Too many incorrect inputs, please reset the password",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Add Wallet Password?",
    ),
    "g_lock_key25": m46,
    "g_lock_key3": MessageLookupByLibrary.simpleMessage("Lock screen page"),
    "g_lock_key4": MessageLookupByLibrary.simpleMessage("Auto-lock"),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Succeeded"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Biometric recognition is not enabled",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Add biometric verification?",
    ),
    "g_lock_key9": MessageLookupByLibrary.simpleMessage("Reset password"),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Unlock N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Cloud Verification Activity",
    ),
    "g_mining_key46": MessageLookupByLibrary.simpleMessage(
      "Setup requires a small amount for gas.",
    ),
    "g_mining_key60": MessageLookupByLibrary.simpleMessage(
      "You have successfully joined a Group Node on N42Wallet. Share the link to invite friends, activate the Node and start verification!",
    ),
    "g_mining_key61": MessageLookupByLibrary.simpleMessage("Share to friends"),
    "g_mining_key62": MessageLookupByLibrary.simpleMessage("Continue"),
    "g_mining_key63": m47,
    "g_mining_key73": m48,
    "g_mining_key74": MessageLookupByLibrary.simpleMessage(
      "I just set up a node on @N42Wallet and started verification on mobile devices! Come and join me. The decentralized future is mobile!",
    ),
    "g_mining_key76": m49,
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Redemption available after 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Requests before that will not be processed.",
    ),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("Today\'s reward"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Please treat the data below as an important key. We recommend copying and backing it up to a trusted location immediately.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copy Data"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inactive"),
    "g_mining_key_103": MessageLookupByLibrary.simpleMessage("Validator List"),
    "g_mining_key_104": MessageLookupByLibrary.simpleMessage(
      "Import successful",
    ),
    "g_mining_key_105": MessageLookupByLibrary.simpleMessage(
      "Encrypted data cannot be empty!",
    ),
    "g_mining_key_106": MessageLookupByLibrary.simpleMessage(
      "Password cannot be empty!",
    ),
    "g_mining_key_107": MessageLookupByLibrary.simpleMessage(
      "Decryption failed. Please check if the password is correct!",
    ),
    "g_mining_key_108": MessageLookupByLibrary.simpleMessage(
      "Unsupported encrypted data format!",
    ),
    "g_mining_key_109": m50,
    "g_mining_key_11": MessageLookupByLibrary.simpleMessage(
      "Yesterday’s Rewards",
    ),
    "g_mining_key_110": MessageLookupByLibrary.simpleMessage("Encrypted data"),
    "g_mining_key_111": MessageLookupByLibrary.simpleMessage("Import files"),
    "g_mining_key_112": MessageLookupByLibrary.simpleMessage(
      "Please enter encrypted data.",
    ),
    "g_mining_key_113": MessageLookupByLibrary.simpleMessage("Importing..."),
    "g_mining_key_114": MessageLookupByLibrary.simpleMessage("Confirmation"),
    "g_mining_key_115": MessageLookupByLibrary.simpleMessage(
      "Redemption takes some time, please wait a moment!",
    ),
    "g_mining_key_116": m51,
    "g_mining_key_12": MessageLookupByLibrary.simpleMessage(
      "Reward accumulates daily and is only sent to your N wallet when it reaches ~0.5 N.",
    ),
    "g_mining_key_13": MessageLookupByLibrary.simpleMessage("Total Rewards"),
    "g_mining_key_14": MessageLookupByLibrary.simpleMessage("Mined Value"),
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage(
      "Calculated based on market price of N * the total N rewards.",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Profit count"),
    "g_mining_key_31": MessageLookupByLibrary.simpleMessage("Select Plans"),
    "g_mining_key_32": MessageLookupByLibrary.simpleMessage(
      "Unlock Period: Unlockable at any time",
    ),
    "g_mining_key_33": MessageLookupByLibrary.simpleMessage(
      "Max Reward Annually",
    ),
    "g_mining_key_34": MessageLookupByLibrary.simpleMessage(
      "Reward Distribution",
    ),
    "g_mining_key_35": MessageLookupByLibrary.simpleMessage("Daily Limit"),
    "g_mining_key_36": MessageLookupByLibrary.simpleMessage("Speed"),
    "g_mining_key_37": MessageLookupByLibrary.simpleMessage(
      "Verification Plans",
    ),
    "g_mining_key_38": MessageLookupByLibrary.simpleMessage(
      "Select the payment method",
    ),
    "g_mining_key_39": MessageLookupByLibrary.simpleMessage("Payment Methods"),
    "g_mining_key_40": MessageLookupByLibrary.simpleMessage("Pay using N"),
    "g_mining_key_42": MessageLookupByLibrary.simpleMessage("Wallet Balance"),
    "g_mining_key_43": MessageLookupByLibrary.simpleMessage(
      "You do not have enough N for this transaction",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Disabled"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("View more"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Verification Status",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Lock N to start verifying rewards.",
    ),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entry"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Advanced Node"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Entry Node"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro Node"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocks/day~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Select a Plan"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocks/day~15 mins",
    ),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 seconds per check",
    ),
    "g_mining_key_73": MessageLookupByLibrary.simpleMessage(
      "Cloud Verification Started",
    ),
    "g_mining_key_74": MessageLookupByLibrary.simpleMessage(
      "The test chain is being upgraded and blocks cannot be verified temporarily.",
    ),
    "g_mining_key_75": MessageLookupByLibrary.simpleMessage(
      "Failing to complete tasks for four consecutive days will result in no earnings and a risk of penalty.",
    ),
    "g_mining_key_76": MessageLookupByLibrary.simpleMessage("Risk Score"),
    "g_mining_key_77": MessageLookupByLibrary.simpleMessage("Redeem"),
    "g_mining_key_78": MessageLookupByLibrary.simpleMessage(
      "Please save the verifier\'s public and private key pair first.",
    ),
    "g_mining_key_79": MessageLookupByLibrary.simpleMessage("Export"),
    "g_mining_key_80": MessageLookupByLibrary.simpleMessage(
      "Insufficient funds for transfer.",
    ),
    "g_mining_key_81": MessageLookupByLibrary.simpleMessage("Validator List"),
    "g_mining_key_82": MessageLookupByLibrary.simpleMessage("Import validator"),
    "g_mining_key_83": MessageLookupByLibrary.simpleMessage(
      "The validator already exists",
    ),
    "g_mining_key_84": MessageLookupByLibrary.simpleMessage("Low Risk"),
    "g_mining_key_85": MessageLookupByLibrary.simpleMessage("Moderately Risk"),
    "g_mining_key_86": MessageLookupByLibrary.simpleMessage("7-Day Rewards"),
    "g_mining_key_87": MessageLookupByLibrary.simpleMessage("High Risk"),
    "g_mining_key_88": MessageLookupByLibrary.simpleMessage(
      "The contract is loading and cannot be verified at this time. Please wait a moment!",
    ),
    "g_mining_key_89": MessageLookupByLibrary.simpleMessage("Safety Tips"),
    "g_mining_key_9": MessageLookupByLibrary.simpleMessage(
      "Background Verification",
    ),
    "g_mining_key_90": MessageLookupByLibrary.simpleMessage(
      "Please keep your private key or mnemonic phrase safe.",
    ),
    "g_mining_key_91": MessageLookupByLibrary.simpleMessage(
      "Your private key or mnemonic phrase is the only credential for accessing your wallet assets.",
    ),
    "g_mining_key_92": MessageLookupByLibrary.simpleMessage(
      "Please keep it in a safe place (paper, password manager, etc.).",
    ),
    "g_mining_key_93": MessageLookupByLibrary.simpleMessage(
      "Do not take screenshots, upload them to the internet, or share them with anyone.",
    ),
    "g_mining_key_94": MessageLookupByLibrary.simpleMessage(
      "Once lost or compromised, your wallet assets cannot be recovered.",
    ),
    "g_mining_key_95": MessageLookupByLibrary.simpleMessage("Confirm and save"),
    "g_mining_key_96": MessageLookupByLibrary.simpleMessage(
      "Set a password and encrypt",
    ),
    "g_mining_key_97": MessageLookupByLibrary.simpleMessage(
      "Please enter the encryption password",
    ),
    "g_mining_key_98": m53,
    "g_mining_key_99": MessageLookupByLibrary.simpleMessage(
      "Please re-enter your password to ensure it\'s correct",
    ),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Unlock Period:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Unlockable at any time",
    ),
    "g_notification_key_1": MessageLookupByLibrary.simpleMessage(
      "Notifications",
    ),
    "g_share_v2_key_5": MessageLookupByLibrary.simpleMessage("Share"),
    "g_share_v3_key_2": MessageLookupByLibrary.simpleMessage("Referral"),
    "g_share_v3_key_3": MessageLookupByLibrary.simpleMessage(
      "Refer friends and get N Tokens!",
    ),
    "g_share_v3_key_4": MessageLookupByLibrary.simpleMessage("You get up to "),
    "g_share_v3_key_5": MessageLookupByLibrary.simpleMessage(
      " N when your referral starts verification!",
    ),
    "g_share_v3_key_6": MessageLookupByLibrary.simpleMessage("Refer via"),
    "g_share_v3_key_7": MessageLookupByLibrary.simpleMessage("Link"),
    "g_share_v3_key_8": MessageLookupByLibrary.simpleMessage("code"),
    "g_swap_key_14": m54,
    "g_swap_key_15": MessageLookupByLibrary.simpleMessage(
      "Get coin price error.",
    ),
    "g_swap_key_16": MessageLookupByLibrary.simpleMessage(
      "By proceeding, you agree with the following ",
    ),
    "g_swap_key_17": MessageLookupByLibrary.simpleMessage(
      "Terms and Conditions.",
    ),
    "g_swap_key_18": MessageLookupByLibrary.simpleMessage("Finish"),
    "g_swap_key_19": MessageLookupByLibrary.simpleMessage(
      "Your swap will be distributed shortly.Please be patient.",
    ),
    "g_swap_key_20": m55,
    "g_swap_key_21": MessageLookupByLibrary.simpleMessage(
      "Costs to run a node: Group Verification 1-49 N Basic Node: 50 N Premium Node: 100 N Pro Node: 500 N.",
    ),
    "g_swap_key_22": MessageLookupByLibrary.simpleMessage("Expire"),
    "g_swap_key_23": MessageLookupByLibrary.simpleMessage("Unpaid"),
    "g_swap_key_24": MessageLookupByLibrary.simpleMessage("Confirming payment"),
    "g_swap_key_25": MessageLookupByLibrary.simpleMessage("To be distributed"),
    "g_swap_key_28": MessageLookupByLibrary.simpleMessage("Swap Summary"),
    "g_swap_key_29": MessageLookupByLibrary.simpleMessage("New Balance"),
    "g_swap_key_3": MessageLookupByLibrary.simpleMessage("You pay"),
    "g_swap_key_30": MessageLookupByLibrary.simpleMessage("Date"),
    "g_swap_key_31": m56,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Swaps can be viewed on the relevant chain explorers (Etherscan, BscScan, TRONSCAN and our own).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Swap to N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("You get"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Preview Swap"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Try again"),
    "g_token_m_key_1": m57,
    "g_token_m_key_10": MessageLookupByLibrary.simpleMessage(
      "Anyone can create a token, including creating fake versions of existing tokens. Always research a token before importing it.",
    ),
    "g_token_m_key_11": MessageLookupByLibrary.simpleMessage("Tokens"),
    "g_token_m_key_12": MessageLookupByLibrary.simpleMessage("Search Token"),
    "g_token_m_key_13": MessageLookupByLibrary.simpleMessage("Chain Name"),
    "g_token_m_key_14": MessageLookupByLibrary.simpleMessage("Chain symbol"),
    "g_token_m_key_15": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_token_m_key_16": MessageLookupByLibrary.simpleMessage("Decimal"),
    "g_token_m_key_17": MessageLookupByLibrary.simpleMessage("RPC"),
    "g_token_m_key_18": MessageLookupByLibrary.simpleMessage("API"),
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Add custom chain",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 uint"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Add Tokens"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Format Error!"),
    "g_token_m_key_22": m58,
    "g_token_m_key_23": m59,
    "g_token_m_key_24": m60,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Import tokens"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("All networks"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("Custom Token"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Token address"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Token symbol"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Token decimal"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Import"),
    "g_unlock_key10": m61,
    "g_unlock_key2": MessageLookupByLibrary.simpleMessage(
      "Fingerprint or face recognition is not enabled?",
    ),
    "g_unlock_key3": MessageLookupByLibrary.simpleMessage(
      "Draw pattern password",
    ),
    "g_unlock_key4": m62,
    "g_unlock_key5": MessageLookupByLibrary.simpleMessage("Enter password"),
    "g_unlock_key6": m63,
    "g_unlock_key7": MessageLookupByLibrary.simpleMessage(
      "Authentication failed",
    ),
    "g_unlock_key8": m64,
    "g_unlock_key9": MessageLookupByLibrary.simpleMessage("You can also "),
    "google_verification": MessageLookupByLibrary.simpleMessage(
      "Google Authentication",
    ),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Link",
    ),
    "google_verification_message11": MessageLookupByLibrary.simpleMessage(
      "Download Google Authentication",
    ),
    "google_verification_message12": MessageLookupByLibrary.simpleMessage(
      "Instructions",
    ),
    "google_verification_message13": MessageLookupByLibrary.simpleMessage(
      "Open Google Authenticator.",
    ),
    "google_verification_message14": MessageLookupByLibrary.simpleMessage(
      "You will see a 6-digit verification code on the screen.",
    ),
    "google_verification_message15": MessageLookupByLibrary.simpleMessage(
      "Copy the 6-digit code and paste it in N42Wallet.",
    ),
    "google_verification_message16": MessageLookupByLibrary.simpleMessage(
      "Then，your Authenticator will be successfully linked.",
    ),
    "google_verification_message17": MessageLookupByLibrary.simpleMessage(
      "Backup Key",
    ),
    "google_verification_message18": MessageLookupByLibrary.simpleMessage(
      "Copy the key to Google Authentication",
    ),
    "google_verification_message19": MessageLookupByLibrary.simpleMessage(
      "Enter Google verification code",
    ),
    "google_verification_message20": MessageLookupByLibrary.simpleMessage(
      "Enter E-mail verification code",
    ),
    "google_verification_message21": m65,
    "google_verification_message3": MessageLookupByLibrary.simpleMessage(
      "Failed to get google key",
    ),
    "google_verification_message5": MessageLookupByLibrary.simpleMessage(
      "Two-Factor Authentication(2FA)",
    ),
    "google_verification_message6": MessageLookupByLibrary.simpleMessage(
      "To protect your account,it is recommended to turn on at least one 2FA.",
    ),
    "google_verification_message7": MessageLookupByLibrary.simpleMessage(
      "The Google Authenticator app protects your withdrawals and N42Wallet account.",
    ),
    "google_verification_message8": MessageLookupByLibrary.simpleMessage(
      "Download And Install",
    ),
    "google_verification_message9": MessageLookupByLibrary.simpleMessage(
      "Please download and install Google Authenticator. Then press ‘Link’ to link your N42Wallet account.",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Important Notice"),
    "login_button_text": MessageLookupByLibrary.simpleMessage("Sign in"),
    "login_email": MessageLookupByLibrary.simpleMessage("Email"),
    "login_forgot_password": MessageLookupByLibrary.simpleMessage(
      "Forgot password?",
    ),
    "login_invite_code": MessageLookupByLibrary.simpleMessage("Referral code"),
    "login_invite_code_title": MessageLookupByLibrary.simpleMessage(
      "Referral code",
    ),
    "login_message_1": MessageLookupByLibrary.simpleMessage(
      "Don’t have an account? ",
    ),
    "login_message_10": MessageLookupByLibrary.simpleMessage(
      "Created successfully",
    ),
    "login_message_11": MessageLookupByLibrary.simpleMessage(
      "Reset successfully",
    ),
    "login_message_2": MessageLookupByLibrary.simpleMessage(
      "Already have an account? ",
    ),
    "login_message_6": MessageLookupByLibrary.simpleMessage("Resend code in "),
    "login_message_7": MessageLookupByLibrary.simpleMessage(
      "Code sent successfully",
    ),
    "login_message_8": MessageLookupByLibrary.simpleMessage(
      "E-mail unregistered",
    ),
    "login_message_9": MessageLookupByLibrary.simpleMessage(
      "Failed to send code",
    ),
    "login_need_login": MessageLookupByLibrary.simpleMessage(
      "please log in first",
    ),
    "login_password": MessageLookupByLibrary.simpleMessage("Password"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nicknameMessage": m66,
    "password_diff": MessageLookupByLibrary.simpleMessage(
      "Passwords don\'t match",
    ),
    "personalInformation": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "photograph": MessageLookupByLibrary.simpleMessage("Photograph"),
    "please_enter_code": MessageLookupByLibrary.simpleMessage(
      "Enter verification code",
    ),
    "please_enter_email": MessageLookupByLibrary.simpleMessage(
      "Please enter email",
    ),
    "please_enter_password": MessageLookupByLibrary.simpleMessage(
      "Please enter password",
    ),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Please Input Address",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("Re-enter Password"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Choose a password(8~18 characters)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "rest_Enter_the_password_again": MessageLookupByLibrary.simpleMessage(
      "Enter the password again",
    ),
    "rest_Please_enter": MessageLookupByLibrary.simpleMessage("Enter code"),
    "rest_Verification_code": MessageLookupByLibrary.simpleMessage("OTP Code"),
    "rest_your_password": MessageLookupByLibrary.simpleMessage(
      "Reset your password",
    ),
    "s_key_1": MessageLookupByLibrary.simpleMessage("Manage Wallet"),
    "s_key_10": MessageLookupByLibrary.simpleMessage("About App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Security"),
    "s_key_12": MessageLookupByLibrary.simpleMessage("Use New Chat"),
    "s_key_13": MessageLookupByLibrary.simpleMessage(
      "Enable enhanced Chat experience",
    ),
    "s_key_2": MessageLookupByLibrary.simpleMessage("Wallet Addresses"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaction"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Language"),
    "s_key_5": MessageLookupByLibrary.simpleMessage("Theme"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
    "selected_user_protocol": MessageLookupByLibrary.simpleMessage(
      "Please read the agreement and confirm",
    ),
    "verification": MessageLookupByLibrary.simpleMessage("verification"),
    "w_item_1": MessageLookupByLibrary.simpleMessage(
      "If I lose my secret phrase, my funds will be lost forever.",
    ),
    "w_item_2": MessageLookupByLibrary.simpleMessage(
      "If I reveal or share my seed phrase to anybody, my funds can get stolen.",
    ),
    "w_item_3": MessageLookupByLibrary.simpleMessage(
      "It is my responsibility to keep my seed phrase secure.",
    ),
    "w_key_12": MessageLookupByLibrary.simpleMessage("Seed phrase incorrect."),
    "w_key_8": MessageLookupByLibrary.simpleMessage(
      "Enter the seed phrase for the wallet you want to import.",
    ),
  };
}
