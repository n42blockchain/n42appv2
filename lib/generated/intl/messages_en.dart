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

  static String m1(price) => "Current price: \$${price}";

  static String m2(symbol) => "Price Alert · ${symbol}";

  static String m3(s) => "Resend in ${s}s";

  static String m4(message) => "Purchase failed: ${message}";

  static String m5(productId) => "Purchase successful: ${productId}";

  static String m6(productId) => "Restored: ${productId}";

  static String m7(value) => "Amount greater than ${value}.";

  static String m8(value) =>
      "The wallet already exists, the wallet name is \"${value}\"";

  static String m9(value) => "Enter an amount more than ${value}.";

  static String m10(value) => "Duplicate address at row ${value}";

  static String m11(value) =>
      "Insufficient balance: total amount would exceed available ${value}";

  static String m12(value) => "Invalid address at row ${value}";

  static String m13(value) => "Invalid amount at row ${value}";

  static String m14(value) => "Maximum ${value} recipients";

  static String m15(token) => "Approve ${token} to continue";

  static String m16(impact) =>
      "High price impact (${impact})! Proceed with caution.";

  static String m17(secs) => "Quote expires in ${secs}s";

  static String m18(value) => "Earn up to ${value}% APY";

  static String m19(value) => "Auto-refresh every ${value} seconds";

  static String m20(address) => "Account ${address} added";

  static String m21(address, network) =>
      "Do you want to track this hardware wallet account?\n\nAddress: ${address}\nNetwork: ${network}";

  static String m22(app) => "Current app: ${app}";

  static String m23(days) => "${days} days ago";

  static String m24(value) => "Failed to import account: ${value}";

  static String m25(date) => "Last connected: ${date}";

  static String m26(app) => "Make sure the ${app} app is open on your Ledger";

  static String m27(name) =>
      "Are you sure you want to remove \"${name}\" from saved devices?";

  static String m28(value) => "Est. gas: ~${value} units";

  static String m29(reason) => "Reason: ${reason}";

  static String m30(value) => "${value}d unbond";

  static String m31(value) => "${value} days remaining";

  static String m32(value) =>
      "Unstaking takes ${value} days. Your tokens will be locked during this period.";

  static String m33(value) => "You do not have enough \"${value}\"";

  static String m34(value) => "Failed to get \"${value}\" account";

  static String m35(value) => "Minimum ${value} XRP for first transfer";

  static String m36(count) => "Add (${count})";

  static String m37(count) =>
      "${Intl.plural(count, one: '1 new token detected', other: '${count} new tokens detected')} — tap to review";

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

  static String m45(value) => "Incorrect pattern, ${value} attempts remaining";

  static String m46(value) => "Incorrect pattern, ${value} attempt remaining";

  static String m47(value) =>
      "You have successfully set up a ${value} and will begin verification with N42Wallet!";

  static String m48(value) =>
      "Join my ${value} group on @N42Wallet to be an early miner of a Layer 1 chain, and get crypto on your phone!";

  static String m49(value, value1) =>
      "Are you sure you want to lock ${value} N until ${value1} to run a node?";

  static String m50(value) => "Import failed:${value}";

  static String m51(value) =>
      "A staking balance of at least ${value} is required to earn rewards.";

  static String m52(value, value1) => "${value} N every ${value1} blocks mined";

  static String m53(value) => "Must be ${value} characters";

  static String m54(n) => "${n} min";

  static String m55(n) => "Outcome ${n}";

  static String m56(value) => "${value} Insufficient Balance.";

  static String m57(value) => "${value} incoming...";

  static String m58(value) =>
      "${value} swapped in-app will be distributed shortly to your wallet and cannot be sold via this process. It can be used to run a node.";

  static String m59(value) => "Max ${value} characters";

  static String m60(value) => "${value} chain APP is already supported!";

  static String m61(value) =>
      "${value} chain APP is already supported, do you want to add it?";

  static String m62(value) => "${value} address test link failed!";

  static String m63(value) => "0~${value} characters";

  final messages = _notInlinedMessages(_notInlinedMessages);
  static Map<String, Function> _notInlinedMessages(_) => <String, Function>{
    "Edit": MessageLookupByLibrary.simpleMessage("Edit"),
    "Verification": MessageLookupByLibrary.simpleMessage("Verification"),
    "address_Information": MessageLookupByLibrary.simpleMessage(
      "Address Information",
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
    "file": MessageLookupByLibrary.simpleMessage("File"),
    "g_alert_above": MessageLookupByLibrary.simpleMessage("Goes Above ↑"),
    "g_alert_below": MessageLookupByLibrary.simpleMessage("Drops Below ↓"),
    "g_alert_current_price": m1,
    "g_alert_direction": MessageLookupByLibrary.simpleMessage(
      "Alert me when price",
    ),
    "g_alert_enable": MessageLookupByLibrary.simpleMessage("Enable this alert"),
    "g_alert_invalid_price": MessageLookupByLibrary.simpleMessage(
      "Please enter a valid price greater than 0",
    ),
    "g_alert_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_alert_set": MessageLookupByLibrary.simpleMessage("Set Alert"),
    "g_alert_target_price": MessageLookupByLibrary.simpleMessage(
      "Target price (USD)",
    ),
    "g_alert_title": m2,
    "g_alert_update": MessageLookupByLibrary.simpleMessage("Update Alert"),
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
    "g_browser_key16": MessageLookupByLibrary.simpleMessage("Close all"),
    "g_browser_key17": MessageLookupByLibrary.simpleMessage("Done"),
    "g_browser_key18": MessageLookupByLibrary.simpleMessage("History"),
    "g_browser_key19": MessageLookupByLibrary.simpleMessage(
      "Clear All History",
    ),
    "g_browser_key20": MessageLookupByLibrary.simpleMessage(
      "Clear all browsing history?",
    ),
    "g_browser_key21": MessageLookupByLibrary.simpleMessage("History cleared"),
    "g_browser_key22": MessageLookupByLibrary.simpleMessage("Today"),
    "g_browser_key23": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_browser_key24": MessageLookupByLibrary.simpleMessage("Discover DApps"),
    "g_browser_key25": MessageLookupByLibrary.simpleMessage("Popular"),
    "g_browser_key26": MessageLookupByLibrary.simpleMessage("DEX"),
    "g_browser_key27": MessageLookupByLibrary.simpleMessage("DeFi"),
    "g_browser_key28": MessageLookupByLibrary.simpleMessage("NFT"),
    "g_browser_key29": MessageLookupByLibrary.simpleMessage("Bridge"),
    "g_browser_key3": MessageLookupByLibrary.simpleMessage("Bookmarks"),
    "g_browser_key30": MessageLookupByLibrary.simpleMessage("Tools"),
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
    "g_chat_key_50": MessageLookupByLibrary.simpleMessage("Agree"),
    "g_chat_key_67": MessageLookupByLibrary.simpleMessage(
      "The message has been deleted",
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
    "g_dapp_security_blocked": MessageLookupByLibrary.simpleMessage("Blocked"),
    "g_dapp_security_caution": MessageLookupByLibrary.simpleMessage("Caution"),
    "g_dapp_security_safe": MessageLookupByLibrary.simpleMessage("Safe"),
    "g_dapp_security_verified": MessageLookupByLibrary.simpleMessage(
      "Verified",
    ),
    "g_email_resend": MessageLookupByLibrary.simpleMessage("Resend code"),
    "g_email_resend_countdown": m3,
    "g_face_1": MessageLookupByLibrary.simpleMessage("Biometric Scan Tips"),
    "g_face_10": MessageLookupByLibrary.simpleMessage(
      "Scan your fingerprint or face for authentication.",
    ),
    "g_face_3": MessageLookupByLibrary.simpleMessage("Tips"),
    "g_face_5": MessageLookupByLibrary.simpleMessage("To set"),
    "g_face_7": MessageLookupByLibrary.simpleMessage(
      "Scan your face or fingerprint to continue.",
    ),
    "g_face_8": MessageLookupByLibrary.simpleMessage("Return"),
    "g_google_auth_key1": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator",
    ),
    "g_google_auth_key2": MessageLookupByLibrary.simpleMessage(
      "Scan the QR code with Google Authenticator app",
    ),
    "g_google_auth_key3": MessageLookupByLibrary.simpleMessage(
      "Or enter the key manually:",
    ),
    "g_google_auth_key4": MessageLookupByLibrary.simpleMessage(
      "Enter 6-digit verification code",
    ),
    "g_google_auth_key5": MessageLookupByLibrary.simpleMessage(
      "Require Google Authenticator to confirm each wallet transfer.",
    ),
    "g_google_auth_key6": MessageLookupByLibrary.simpleMessage(
      "Incorrect code, please try again",
    ),
    "g_google_auth_key7": MessageLookupByLibrary.simpleMessage(
      "Google Authenticator not configured",
    ),
    "g_google_auth_key8": MessageLookupByLibrary.simpleMessage(
      "Binding successful",
    ),
    "g_home_key1": MessageLookupByLibrary.simpleMessage("Profile"),
    "g_home_key2": MessageLookupByLibrary.simpleMessage("News"),
    "g_home_key3": MessageLookupByLibrary.simpleMessage("Verification"),
    "g_home_key9": MessageLookupByLibrary.simpleMessage("Invite a friend"),
    "g_iap_cancelled": MessageLookupByLibrary.simpleMessage("Cancelled"),
    "g_iap_check_network": MessageLookupByLibrary.simpleMessage(
      "Check your network connection and try again",
    ),
    "g_iap_failed": m4,
    "g_iap_no_products": MessageLookupByLibrary.simpleMessage(
      "No products available",
    ),
    "g_iap_purchased": m5,
    "g_iap_restore": MessageLookupByLibrary.simpleMessage("Restore Purchases"),
    "g_iap_restored": m6,
    "g_iap_restoring": MessageLookupByLibrary.simpleMessage(
      "Restoring purchases…",
    ),
    "g_iap_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_iap_store_unavailable": MessageLookupByLibrary.simpleMessage(
      "Store Unavailable",
    ),
    "g_iap_title": MessageLookupByLibrary.simpleMessage("Buy"),
    "g_key_1": MessageLookupByLibrary.simpleMessage("Failed to remove!"),
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
    "g_key_135": m7,
    "g_key_14": MessageLookupByLibrary.simpleMessage("Main Wallet"),
    "g_key_140": MessageLookupByLibrary.simpleMessage("Transaction successful"),
    "g_key_146": MessageLookupByLibrary.simpleMessage("Incorrect password"),
    "g_key_147": MessageLookupByLibrary.simpleMessage("Testnet"),
    "g_key_148": MessageLookupByLibrary.simpleMessage("Mainnet"),
    "g_key_149": MessageLookupByLibrary.simpleMessage("System language"),
    "g_key_15": MessageLookupByLibrary.simpleMessage("Set as Main Wallet"),
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
    "g_key_206": MessageLookupByLibrary.simpleMessage("Password Edit"),
    "g_key_207": MessageLookupByLibrary.simpleMessage("Old Password"),
    "g_key_208": MessageLookupByLibrary.simpleMessage("Syncing balances..."),
    "g_key_209": MessageLookupByLibrary.simpleMessage("Private Key"),
    "g_key_21": MessageLookupByLibrary.simpleMessage("Enter wallet password"),
    "g_key_210": MessageLookupByLibrary.simpleMessage("Private key error"),
    "g_key_213": MessageLookupByLibrary.simpleMessage("Market Information"),
    "g_key_214": m8,
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
    "g_key_46": m9,
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
    "g_key_aa_batch_transaction": MessageLookupByLibrary.simpleMessage(
      "Batch Transaction",
    ),
    "g_key_aa_benefit_batch_desc": MessageLookupByLibrary.simpleMessage(
      "Approve and swap in one transaction — no more two-step confirmations",
    ),
    "g_key_aa_benefit_batch_title": MessageLookupByLibrary.simpleMessage(
      "One-Click Batch Actions",
    ),
    "g_key_aa_benefit_gas_desc": MessageLookupByLibrary.simpleMessage(
      "Sponsor transactions or pay fees with ERC-20 tokens instead of ETH",
    ),
    "g_key_aa_benefit_gas_title": MessageLookupByLibrary.simpleMessage(
      "Pay Gas with Any Token",
    ),
    "g_key_aa_benefit_recovery_desc": MessageLookupByLibrary.simpleMessage(
      "Recover access via trusted contacts if you lose your private key",
    ),
    "g_key_aa_benefit_recovery_title": MessageLookupByLibrary.simpleMessage(
      "Social Recovery",
    ),
    "g_key_aa_biconomy_desc": MessageLookupByLibrary.simpleMessage(
      "Modular ERC-7579 smart account with gasless transaction support",
    ),
    "g_key_aa_by": MessageLookupByLibrary.simpleMessage("by"),
    "g_key_aa_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_aa_chain_id": MessageLookupByLibrary.simpleMessage("Chain ID"),
    "g_key_aa_change": MessageLookupByLibrary.simpleMessage("Change"),
    "g_key_aa_check_status": MessageLookupByLibrary.simpleMessage(
      "Check Status",
    ),
    "g_key_aa_coming_soon": MessageLookupByLibrary.simpleMessage("Coming Soon"),
    "g_key_aa_counterfactual_note": MessageLookupByLibrary.simpleMessage(
      "This is a counterfactual address. It will be deployed on your first transaction.",
    ),
    "g_key_aa_create_account": MessageLookupByLibrary.simpleMessage(
      "Create Smart Account",
    ),
    "g_key_aa_create_first": MessageLookupByLibrary.simpleMessage(
      "Create your first smart account",
    ),
    "g_key_aa_create_session": MessageLookupByLibrary.simpleMessage(
      "Create Session Key",
    ),
    "g_key_aa_created": MessageLookupByLibrary.simpleMessage("Created"),
    "g_key_aa_custom": MessageLookupByLibrary.simpleMessage("Custom"),
    "g_key_aa_deploy_auto_note": MessageLookupByLibrary.simpleMessage(
      "Account will be deployed automatically on your first transaction",
    ),
    "g_key_aa_deployed": MessageLookupByLibrary.simpleMessage("Deployed"),
    "g_key_aa_deploying": MessageLookupByLibrary.simpleMessage("Deploying..."),
    "g_key_aa_deployment_note": MessageLookupByLibrary.simpleMessage(
      "Deployment will occur automatically with your first transaction.",
    ),
    "g_key_aa_description": MessageLookupByLibrary.simpleMessage(
      "Experience the next generation of Ethereum accounts with enhanced features",
    ),
    "g_key_aa_details": MessageLookupByLibrary.simpleMessage("Details"),
    "g_key_aa_eip7702_desc": MessageLookupByLibrary.simpleMessage(
      "Hybrid EOA/Smart Account - No deployment needed",
    ),
    "g_key_aa_error": MessageLookupByLibrary.simpleMessage("Error"),
    "g_key_aa_estimated_gas": MessageLookupByLibrary.simpleMessage(
      "Estimated Gas",
    ),
    "g_key_aa_execute_batch": MessageLookupByLibrary.simpleMessage(
      "Execute Batch",
    ),
    "g_key_aa_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_aa_expires": MessageLookupByLibrary.simpleMessage("Expires"),
    "g_key_aa_factory": MessageLookupByLibrary.simpleMessage("Factory"),
    "g_key_aa_free": MessageLookupByLibrary.simpleMessage("FREE"),
    "g_key_aa_gas_estimate_failed": MessageLookupByLibrary.simpleMessage(
      "Gas estimate failed, using default",
    ),
    "g_key_aa_gas_payment": MessageLookupByLibrary.simpleMessage("Gas Payment"),
    "g_key_aa_gas_payment_options": MessageLookupByLibrary.simpleMessage(
      "Gas Payment Options",
    ),
    "g_key_aa_gas_sponsored": MessageLookupByLibrary.simpleMessage(
      "Gas Sponsored",
    ),
    "g_key_aa_gasless": MessageLookupByLibrary.simpleMessage("Gasless"),
    "g_key_aa_gasless_transactions": MessageLookupByLibrary.simpleMessage(
      "Gasless transactions & batch operations",
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
    "g_key_aa_onboard_step1": MessageLookupByLibrary.simpleMessage(
      "Create smart account (free, no ETH needed)",
    ),
    "g_key_aa_onboard_step2": MessageLookupByLibrary.simpleMessage(
      "Fund it — receive any EVM token",
    ),
    "g_key_aa_onboard_step3": MessageLookupByLibrary.simpleMessage(
      "Transact gaslessly with Paymaster",
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
    "g_key_aa_paymaster_chains_supported": MessageLookupByLibrary.simpleMessage(
      "chains supported",
    ),
    "g_key_aa_paymaster_checking": MessageLookupByLibrary.simpleMessage(
      "Checking availability...",
    ),
    "g_key_aa_paymaster_coverage": MessageLookupByLibrary.simpleMessage(
      "Chain Coverage",
    ),
    "g_key_aa_paymaster_description": MessageLookupByLibrary.simpleMessage(
      "Choose how you want to pay for transaction gas fees",
    ),
    "g_key_aa_paymaster_est_cost": MessageLookupByLibrary.simpleMessage(
      "Est. cost",
    ),
    "g_key_aa_paymaster_load_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to load gas options",
    ),
    "g_key_aa_paymaster_retry": MessageLookupByLibrary.simpleMessage("Retry"),
    "g_key_aa_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_aa_permission": MessageLookupByLibrary.simpleMessage("Permission"),
    "g_key_aa_preview_address": MessageLookupByLibrary.simpleMessage(
      "Preview Address",
    ),
    "g_key_aa_ready": MessageLookupByLibrary.simpleMessage("Ready"),
    "g_key_aa_receive_address": MessageLookupByLibrary.simpleMessage(
      "Receive Address",
    ),
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
    "g_key_aa_safe_desc": MessageLookupByLibrary.simpleMessage(
      "Multi-signature account with advanced security features",
    ),
    "g_key_aa_saved": MessageLookupByLibrary.simpleMessage("saved"),
    "g_key_aa_select_chain": MessageLookupByLibrary.simpleMessage(
      "Select Chain",
    ),
    "g_key_aa_select_paymaster": MessageLookupByLibrary.simpleMessage(
      "Select Paymaster",
    ),
    "g_key_aa_selected": MessageLookupByLibrary.simpleMessage("Selected"),
    "g_key_aa_send_desc": MessageLookupByLibrary.simpleMessage(
      "Send tokens using your smart account",
    ),
    "g_key_aa_session_1d": MessageLookupByLibrary.simpleMessage("1 Day"),
    "g_key_aa_session_1h": MessageLookupByLibrary.simpleMessage("1 Hour"),
    "g_key_aa_session_30d": MessageLookupByLibrary.simpleMessage("30 Days"),
    "g_key_aa_session_7d": MessageLookupByLibrary.simpleMessage("7 Days"),
    "g_key_aa_session_amount_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. 100.00",
    ),
    "g_key_aa_session_amount_limit": MessageLookupByLibrary.simpleMessage(
      "Max Amount",
    ),
    "g_key_aa_session_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "I understand this key\'s permissions",
    ),
    "g_key_aa_session_contract_can": MessageLookupByLibrary.simpleMessage(
      "Interact with approved DApp contracts",
    ),
    "g_key_aa_session_create_failed": MessageLookupByLibrary.simpleMessage(
      "Failed to create session key",
    ),
    "g_key_aa_session_create_success": MessageLookupByLibrary.simpleMessage(
      "Session key created",
    ),
    "g_key_aa_session_dapp_hint": MessageLookupByLibrary.simpleMessage(
      "e.g. Uniswap, Aave...",
    ),
    "g_key_aa_session_dapp_label": MessageLookupByLibrary.simpleMessage(
      "Label / DApp Name",
    ),
    "g_key_aa_session_details": MessageLookupByLibrary.simpleMessage(
      "Session Key Details",
    ),
    "g_key_aa_session_expiry": MessageLookupByLibrary.simpleMessage(
      "Valid For",
    ),
    "g_key_aa_session_full_warning": MessageLookupByLibrary.simpleMessage(
      "High risk — only trust verified DApps",
    ),
    "g_key_aa_session_keys": MessageLookupByLibrary.simpleMessage(
      "Session Keys",
    ),
    "g_key_aa_session_keys_desc": MessageLookupByLibrary.simpleMessage(
      "Authorize DApps with temporary access to your smart account",
    ),
    "g_key_aa_session_preset_contract": MessageLookupByLibrary.simpleMessage(
      "DApp Access",
    ),
    "g_key_aa_session_preset_full": MessageLookupByLibrary.simpleMessage(
      "Full Control",
    ),
    "g_key_aa_session_preset_transfer": MessageLookupByLibrary.simpleMessage(
      "Send Only",
    ),
    "g_key_aa_session_risk_high": MessageLookupByLibrary.simpleMessage(
      "High Risk",
    ),
    "g_key_aa_session_risk_low": MessageLookupByLibrary.simpleMessage(
      "Low Risk",
    ),
    "g_key_aa_session_risk_medium": MessageLookupByLibrary.simpleMessage(
      "Medium Risk",
    ),
    "g_key_aa_session_risk_warning": MessageLookupByLibrary.simpleMessage(
      "Review permissions before confirming",
    ),
    "g_key_aa_session_select_preset": MessageLookupByLibrary.simpleMessage(
      "Choose Permission Level",
    ),
    "g_key_aa_session_transfer_can": MessageLookupByLibrary.simpleMessage(
      "Transfer tokens within set limit",
    ),
    "g_key_aa_simple_desc": MessageLookupByLibrary.simpleMessage(
      "Basic smart account with single owner - recommended for most users",
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
    "g_key_aa_transactions": MessageLookupByLibrary.simpleMessage(
      "Transactions",
    ),
    "g_key_aa_view_all": MessageLookupByLibrary.simpleMessage("View All"),
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
    "g_key_batch_duplicate_address": m10,
    "g_key_batch_estimating_gas": MessageLookupByLibrary.simpleMessage(
      "Estimating Gas...",
    ),
    "g_key_batch_evm_only": MessageLookupByLibrary.simpleMessage(
      "Batch transfer supports EVM chains only",
    ),
    "g_key_batch_export_csv": MessageLookupByLibrary.simpleMessage(
      "Export CSV",
    ),
    "g_key_batch_help_title": MessageLookupByLibrary.simpleMessage(
      "Batch Transfer Help",
    ),
    "g_key_batch_import_csv": MessageLookupByLibrary.simpleMessage(
      "Import CSV",
    ),
    "g_key_batch_insufficient_balance": m11,
    "g_key_batch_invalid_address": m12,
    "g_key_batch_invalid_amount": m13,
    "g_key_batch_max_recipients": m14,
    "g_key_batch_memo_optional": MessageLookupByLibrary.simpleMessage(
      "Memo is optional",
    ),
    "g_key_batch_multicall_tip": MessageLookupByLibrary.simpleMessage(
      "Use Multicall3 for lower gas fees",
    ),
    "g_key_batch_no_supported": MessageLookupByLibrary.simpleMessage(
      "No supported tokens",
    ),
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
    "g_key_bridge_chain_not_supported": MessageLookupByLibrary.simpleMessage(
      "Chain not supported",
    ),
    "g_key_bridge_cheapest": MessageLookupByLibrary.simpleMessage("Cheapest"),
    "g_key_bridge_estimated_receive": MessageLookupByLibrary.simpleMessage(
      "You will receive (estimated)",
    ),
    "g_key_bridge_fastest": MessageLookupByLibrary.simpleMessage("Fastest"),
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
    "g_key_bridge_title": MessageLookupByLibrary.simpleMessage("Bridge"),
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
    "g_key_chain_transfer_not_supported": MessageLookupByLibrary.simpleMessage(
      "This chain does not support transfers yet, stay tuned",
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
    "g_key_dex_approval_success": MessageLookupByLibrary.simpleMessage(
      "Approved! Tap Swap to continue.",
    ),
    "g_key_dex_approve_exact": MessageLookupByLibrary.simpleMessage(
      "Exact Amount",
    ),
    "g_key_dex_approve_required": m15,
    "g_key_dex_approve_unlimited": MessageLookupByLibrary.simpleMessage(
      "Unlimited",
    ),
    "g_key_dex_approve_unlimited_info": MessageLookupByLibrary.simpleMessage(
      "Unlimited approval: the router can spend this token any time. Standard practice, but carries risk if the contract is compromised.",
    ),
    "g_key_dex_approving": MessageLookupByLibrary.simpleMessage("Approving…"),
    "g_key_dex_best_route": MessageLookupByLibrary.simpleMessage("Best Route"),
    "g_key_dex_best_source": MessageLookupByLibrary.simpleMessage(
      "Best Source",
    ),
    "g_key_dex_chain": MessageLookupByLibrary.simpleMessage("Chain"),
    "g_key_dex_confirm_title": MessageLookupByLibrary.simpleMessage(
      "Confirm Swap",
    ),
    "g_key_dex_gas_estimate": MessageLookupByLibrary.simpleMessage(
      "Gas Estimate",
    ),
    "g_key_dex_history_title": MessageLookupByLibrary.simpleMessage(
      "DEX History",
    ),
    "g_key_dex_min_received": MessageLookupByLibrary.simpleMessage(
      "Min. Received",
    ),
    "g_key_dex_no_tokens": MessageLookupByLibrary.simpleMessage("No tokens"),
    "g_key_dex_no_tokens_found": MessageLookupByLibrary.simpleMessage(
      "No tokens found",
    ),
    "g_key_dex_price_chart": MessageLookupByLibrary.simpleMessage(
      "Price Chart",
    ),
    "g_key_dex_price_impact": MessageLookupByLibrary.simpleMessage(
      "Price Impact",
    ),
    "g_key_dex_price_impact_high": m16,
    "g_key_dex_quote_expires": m17,
    "g_key_dex_quote_failed": MessageLookupByLibrary.simpleMessage(
      "Quote failed",
    ),
    "g_key_dex_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search symbol / name / address",
    ),
    "g_key_dex_select_token": MessageLookupByLibrary.simpleMessage("Select"),
    "g_key_dex_slippage_label": MessageLookupByLibrary.simpleMessage(
      "Max Slippage",
    ),
    "g_key_dex_status_confirmed": MessageLookupByLibrary.simpleMessage(
      "Confirmed",
    ),
    "g_key_dex_status_failed": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_key_dex_status_pending": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_dex_status_quoted": MessageLookupByLibrary.simpleMessage("Quoted"),
    "g_key_dex_swap_btn": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_key_dex_swap_success": MessageLookupByLibrary.simpleMessage(
      "Swap submitted successfully",
    ),
    "g_key_dex_you_pay": MessageLookupByLibrary.simpleMessage("You Pay"),
    "g_key_dex_you_receive": MessageLookupByLibrary.simpleMessage(
      "You Receive",
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
    "g_key_earn_cross_chain": MessageLookupByLibrary.simpleMessage(
      "Cross-chain transfer",
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
    "g_key_earn_node_mining_desc": MessageLookupByLibrary.simpleMessage(
      "Earn rewards by participating in node mining",
    ),
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
    "g_key_earn_up_to_apy": m18,
    "g_key_earn_view_all": MessageLookupByLibrary.simpleMessage("View All"),
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
    "g_key_ens_commitment_expired_msg": MessageLookupByLibrary.simpleMessage(
      "Registration commitment expired. Please start the registration process again.",
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
      "Address copied",
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
    "g_key_ens_expired": MessageLookupByLibrary.simpleMessage("Expired"),
    "g_key_ens_expires": MessageLookupByLibrary.simpleMessage("Expires"),
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
    "g_key_ens_registering": MessageLookupByLibrary.simpleMessage(
      "Registering...",
    ),
    "g_key_ens_registration_info": MessageLookupByLibrary.simpleMessage(
      "Registration Info",
    ),
    "g_key_ens_registration_period": MessageLookupByLibrary.simpleMessage(
      "Registration Period",
    ),
    "g_key_ens_reminder_enable": MessageLookupByLibrary.simpleMessage(
      "Enable expiry reminder",
    ),
    "g_key_ens_reminder_hint": MessageLookupByLibrary.simpleMessage(
      "Notify 30, 7 and 1 day before expiry",
    ),
    "g_key_ens_renew": MessageLookupByLibrary.simpleMessage("Renew"),
    "g_key_ens_renew_desc": MessageLookupByLibrary.simpleMessage(
      "Extend your domain registration",
    ),
    "g_key_ens_renew_success": MessageLookupByLibrary.simpleMessage(
      "Renewal successful",
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
      "Cannot send to your own address",
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
    "g_key_ens_suggestions": MessageLookupByLibrary.simpleMessage(
      "Suggestions",
    ),
    "g_key_ens_text_records": MessageLookupByLibrary.simpleMessage(
      "Text Records",
    ),
    "g_key_ens_title": MessageLookupByLibrary.simpleMessage("ENS Manager"),
    "g_key_ens_total": MessageLookupByLibrary.simpleMessage("Total"),
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
    "g_key_ens_waiting": MessageLookupByLibrary.simpleMessage("Waiting..."),
    "g_key_ens_warning": MessageLookupByLibrary.simpleMessage(
      "Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.",
    ),
    "g_key_ens_year": MessageLookupByLibrary.simpleMessage("year"),
    "g_key_ens_years": MessageLookupByLibrary.simpleMessage("years"),
    "g_key_ens_your_identity": MessageLookupByLibrary.simpleMessage(
      "Your Identity",
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
    "g_key_error_14": MessageLookupByLibrary.simpleMessage("Request error"),
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
    "g_key_ex_keystore_confirm_risk": MessageLookupByLibrary.simpleMessage(
      "I understand that anyone who obtains this file and password has full control over my funds — loss is permanent and unrecoverable",
    ),
    "g_key_ex_keystore_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Enter wallet password to confirm export",
    ),
    "g_key_ex_pk_pwd_title": MessageLookupByLibrary.simpleMessage(
      "Enter wallet password to view private key",
    ),
    "g_key_filter": MessageLookupByLibrary.simpleMessage("Filter"),
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
    "g_key_gas_auto_refresh": m19,
    "g_key_gas_base_fee": MessageLookupByLibrary.simpleMessage("Base Fee"),
    "g_key_gas_custom": MessageLookupByLibrary.simpleMessage("Custom"),
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
    "g_key_hw_account_added": m20,
    "g_key_hw_account_already_imported": MessageLookupByLibrary.simpleMessage(
      "Account already imported",
    ),
    "g_key_hw_add": MessageLookupByLibrary.simpleMessage("Add"),
    "g_key_hw_add_account": MessageLookupByLibrary.simpleMessage("Add Account"),
    "g_key_hw_add_account_content": m21,
    "g_key_hw_address_copied": MessageLookupByLibrary.simpleMessage(
      "Address copied",
    ),
    "g_key_hw_ble_hint": MessageLookupByLibrary.simpleMessage(
      "Make sure your device is unlocked and Bluetooth is enabled before connecting.",
    ),
    "g_key_hw_check_app": MessageLookupByLibrary.simpleMessage("Check App"),
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
    "g_key_hw_current_app_label": m22,
    "g_key_hw_days_ago": m23,
    "g_key_hw_disconnect": MessageLookupByLibrary.simpleMessage("Disconnect"),
    "g_key_hw_go_back": MessageLookupByLibrary.simpleMessage("Go Back"),
    "g_key_hw_import_failed": m24,
    "g_key_hw_keystone_connect_title": MessageLookupByLibrary.simpleMessage(
      "Connect Keystone",
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
    "g_key_hw_keystone_tap_to_scan": MessageLookupByLibrary.simpleMessage(
      "Tap to scan Keystone response",
    ),
    "g_key_hw_last_connected": m25,
    "g_key_hw_load_more": MessageLookupByLibrary.simpleMessage("Load More"),
    "g_key_hw_loading_accounts": MessageLookupByLibrary.simpleMessage(
      "Loading accounts...",
    ),
    "g_key_hw_loading_hint": MessageLookupByLibrary.simpleMessage(
      "Please confirm on your device if prompted",
    ),
    "g_key_hw_no_accounts_found": MessageLookupByLibrary.simpleMessage(
      "No accounts found",
    ),
    "g_key_hw_no_app_open": MessageLookupByLibrary.simpleMessage(
      "No app is currently open",
    ),
    "g_key_hw_not_connected": MessageLookupByLibrary.simpleMessage(
      "Device not connected",
    ),
    "g_key_hw_not_connected_label": MessageLookupByLibrary.simpleMessage(
      "Not Connected",
    ),
    "g_key_hw_open_ledger_app_hint": m26,
    "g_key_hw_remove": MessageLookupByLibrary.simpleMessage("Remove"),
    "g_key_hw_remove_device": MessageLookupByLibrary.simpleMessage(
      "Remove Device",
    ),
    "g_key_hw_remove_device_confirm": m27,
    "g_key_hw_saved_devices": MessageLookupByLibrary.simpleMessage(
      "Saved Devices",
    ),
    "g_key_hw_supported_devices": MessageLookupByLibrary.simpleMessage(
      "Supported Devices",
    ),
    "g_key_hw_today": MessageLookupByLibrary.simpleMessage("Today"),
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
    "g_key_hw_trezor_usb_hint": MessageLookupByLibrary.simpleMessage(
      "Connect your Trezor device via USB cable and unlock it",
    ),
    "g_key_hw_view_accounts": MessageLookupByLibrary.simpleMessage(
      "View Accounts",
    ),
    "g_key_hw_wallet_accounts": MessageLookupByLibrary.simpleMessage(
      "Wallet Accounts",
    ),
    "g_key_hw_yesterday": MessageLookupByLibrary.simpleMessage("Yesterday"),
    "g_key_keystore_19": MessageLookupByLibrary.simpleMessage(
      "A current currency wallet already exists.",
    ),
    "g_key_keystore_21": MessageLookupByLibrary.simpleMessage(
      "Could not read Keystore",
    ),
    "g_key_keystore_22": MessageLookupByLibrary.simpleMessage("Keystore"),
    "g_key_login": MessageLookupByLibrary.simpleMessage("Log In"),
    "g_key_logout": MessageLookupByLibrary.simpleMessage("Log Out"),
    "g_key_logout_sure": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to exit the app?",
    ),
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
    "g_key_manage_chains": MessageLookupByLibrary.simpleMessage(
      "Manage Chains",
    ),
    "g_key_mining_available": MessageLookupByLibrary.simpleMessage("Available"),
    "g_key_mining_requires_staking": MessageLookupByLibrary.simpleMessage(
      "Requires staking",
    ),
    "g_key_mnemonic": MessageLookupByLibrary.simpleMessage(
      "Please enter seed phrase",
    ),
    "g_key_nft_141": MessageLookupByLibrary.simpleMessage("Total"),
    "g_key_nft_2": MessageLookupByLibrary.simpleMessage("Name"),
    "g_key_nft_220": MessageLookupByLibrary.simpleMessage("Back"),
    "g_key_nft_41": MessageLookupByLibrary.simpleMessage(
      "Transaction submitted",
    ),
    "g_key_nft_address_invalid": MessageLookupByLibrary.simpleMessage(
      "Invalid wallet address",
    ),
    "g_key_nft_balance": MessageLookupByLibrary.simpleMessage("Balance"),
    "g_key_nft_burn_confirm": MessageLookupByLibrary.simpleMessage(
      "This action is irreversible. The NFT will be sent to the burn address.",
    ),
    "g_key_nft_burn_title": MessageLookupByLibrary.simpleMessage("Burn NFT"),
    "g_key_nft_collection": MessageLookupByLibrary.simpleMessage("Collection"),
    "g_key_nft_contract": MessageLookupByLibrary.simpleMessage("Contract"),
    "g_key_nft_description": MessageLookupByLibrary.simpleMessage(
      "Description",
    ),
    "g_key_nft_error_retry": MessageLookupByLibrary.simpleMessage(
      "Failed to load NFTs. Tap to retry.",
    ),
    "g_key_nft_filter_all": MessageLookupByLibrary.simpleMessage("All"),
    "g_key_nft_filter_video": MessageLookupByLibrary.simpleMessage("Video"),
    "g_key_nft_floor_price": MessageLookupByLibrary.simpleMessage("Floor"),
    "g_key_nft_gallery": MessageLookupByLibrary.simpleMessage("NFT Gallery"),
    "g_key_nft_inscription": MessageLookupByLibrary.simpleMessage(
      "Inscription #",
    ),
    "g_key_nft_no_items": MessageLookupByLibrary.simpleMessage("No NFTs found"),
    "g_key_nft_no_url": MessageLookupByLibrary.simpleMessage(
      "No explorer link available",
    ),
    "g_key_nft_no_video_support": MessageLookupByLibrary.simpleMessage(
      "Video playback not supported",
    ),
    "g_key_nft_ordinals": MessageLookupByLibrary.simpleMessage("Ordinals"),
    "g_key_nft_ordinals_unsupported": MessageLookupByLibrary.simpleMessage(
      "Ordinals transfers are not yet supported",
    ),
    "g_key_nft_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "g_key_nft_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search by name or collection",
    ),
    "g_key_nft_send": MessageLookupByLibrary.simpleMessage("Send NFT"),
    "g_key_nft_send_sol_unsupported": MessageLookupByLibrary.simpleMessage(
      "Solana NFT transfers are coming soon",
    ),
    "g_key_nft_token_id": MessageLookupByLibrary.simpleMessage("Token ID"),
    "g_key_nft_type": MessageLookupByLibrary.simpleMessage("Type"),
    "g_key_passwords_not_match": MessageLookupByLibrary.simpleMessage(
      "Passwords do not match",
    ),
    "g_key_personal_1": MessageLookupByLibrary.simpleMessage(
      "Select from phone gallery",
    ),
    "g_key_reset": MessageLookupByLibrary.simpleMessage("Reset"),
    "g_key_security_goplus_caution": MessageLookupByLibrary.simpleMessage(
      "Use Caution",
    ),
    "g_key_security_goplus_checking": MessageLookupByLibrary.simpleMessage(
      "Checking contract security...",
    ),
    "g_key_security_goplus_danger": MessageLookupByLibrary.simpleMessage(
      "High Risk Detected",
    ),
    "g_key_security_goplus_powered_by": MessageLookupByLibrary.simpleMessage(
      "GoPlus",
    ),
    "g_key_security_goplus_safe": MessageLookupByLibrary.simpleMessage(
      "Contract Verified Safe",
    ),
    "g_key_send_memo_hint": MessageLookupByLibrary.simpleMessage("Memo / Note"),
    "g_key_send_memo_label": MessageLookupByLibrary.simpleMessage(
      "Memo / Note (optional)",
    ),
    "g_key_share_code": MessageLookupByLibrary.simpleMessage("Share QR code"),
    "g_key_share_link": MessageLookupByLibrary.simpleMessage("Share link"),
    "g_key_share_method": MessageLookupByLibrary.simpleMessage("Share method"),
    "g_key_sim_gas_estimate": m28,
    "g_key_sim_reverted": MessageLookupByLibrary.simpleMessage(
      "Transaction will likely fail",
    ),
    "g_key_sim_reverted_reason": m29,
    "g_key_sim_simulating": MessageLookupByLibrary.simpleMessage(
      "Simulating transaction…",
    ),
    "g_key_sim_success": MessageLookupByLibrary.simpleMessage(
      "Transaction simulation passed",
    ),
    "g_key_sim_unavailable": MessageLookupByLibrary.simpleMessage(
      "Simulation unavailable for this network",
    ),
    "g_key_squad": MessageLookupByLibrary.simpleMessage("Chat"),
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
    "g_key_stake_commission": MessageLookupByLibrary.simpleMessage(
      "Commission",
    ),
    "g_key_stake_d_unbond": m30,
    "g_key_stake_days_remaining": m31,
    "g_key_stake_estimated_daily": MessageLookupByLibrary.simpleMessage(
      "Est. Daily Reward",
    ),
    "g_key_stake_estimated_yearly": MessageLookupByLibrary.simpleMessage(
      "Est. Yearly Reward",
    ),
    "g_key_stake_go_to_swap": MessageLookupByLibrary.simpleMessage(
      "Go to Swap",
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
    "g_key_stake_positions": MessageLookupByLibrary.simpleMessage(
      "My Positions",
    ),
    "g_key_stake_protocols": MessageLookupByLibrary.simpleMessage("Protocols"),
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
    "g_key_stake_tx_prepared": MessageLookupByLibrary.simpleMessage(
      "Transaction prepared successfully",
    ),
    "g_key_stake_unbonding": MessageLookupByLibrary.simpleMessage("Unbonding"),
    "g_key_stake_unbonding_warning": m32,
    "g_key_stake_unstake": MessageLookupByLibrary.simpleMessage("Unstake"),
    "g_key_stake_updating": MessageLookupByLibrary.simpleMessage("Updating..."),
    "g_key_stake_validator": MessageLookupByLibrary.simpleMessage("Validator"),
    "g_key_stake_you_receive": MessageLookupByLibrary.simpleMessage(
      "You will receive",
    ),
    "g_key_t_1": MessageLookupByLibrary.simpleMessage("Complete"),
    "g_key_t_15": MessageLookupByLibrary.simpleMessage("Gas price"),
    "g_key_t_16": MessageLookupByLibrary.simpleMessage("Max gas fee"),
    "g_key_t_17": MessageLookupByLibrary.simpleMessage("Max fee per gas"),
    "g_key_t_2": MessageLookupByLibrary.simpleMessage("Pending"),
    "g_key_t_29": m33,
    "g_key_t_3": MessageLookupByLibrary.simpleMessage("Failure"),
    "g_key_t_31": MessageLookupByLibrary.simpleMessage("Proceed"),
    "g_key_t_32": MessageLookupByLibrary.simpleMessage("Wallet password"),
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
    "g_key_t_45": m34,
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
    "g_key_t_52": m35,
    "g_key_t_54": MessageLookupByLibrary.simpleMessage(
      "The receiving address does not have an account, and the first transfer is at least 10XRP",
    ),
    "g_key_t_6": MessageLookupByLibrary.simpleMessage("Gas Used"),
    "g_key_t_7": MessageLookupByLibrary.simpleMessage("Gas"),
    "g_key_token_discovery_add": MessageLookupByLibrary.simpleMessage("Add"),
    "g_key_token_discovery_add_selected": m36,
    "g_key_token_discovery_added": MessageLookupByLibrary.simpleMessage(
      "Token added",
    ),
    "g_key_token_discovery_banner": m37,
    "g_key_token_discovery_deselect_all": MessageLookupByLibrary.simpleMessage(
      "Deselect all",
    ),
    "g_key_token_discovery_empty": MessageLookupByLibrary.simpleMessage(
      "No new tokens found",
    ),
    "g_key_token_discovery_ignore": MessageLookupByLibrary.simpleMessage(
      "Ignore",
    ),
    "g_key_token_discovery_select_all": MessageLookupByLibrary.simpleMessage(
      "Select all",
    ),
    "g_key_token_discovery_title": MessageLookupByLibrary.simpleMessage(
      "Discovered Tokens",
    ),
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
    "g_key_uuid": MessageLookupByLibrary.simpleMessage("UUID"),
    "g_key_v_k1": MessageLookupByLibrary.simpleMessage(
      "Find the latest version",
    ),
    "g_key_v_k2": MessageLookupByLibrary.simpleMessage("Update immediately"),
    "g_key_v_k3": MessageLookupByLibrary.simpleMessage("New version found"),
    "g_key_v_k4": MessageLookupByLibrary.simpleMessage(
      "Already the latest version",
    ),
    "g_key_wallet_c10": MessageLookupByLibrary.simpleMessage(
      "View Seed Phrase",
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
    "g_key_wallet_manage": MessageLookupByLibrary.simpleMessage(
      "Manage Wallet",
    ),
    "g_key_watch_address_hint": MessageLookupByLibrary.simpleMessage(
      "Enter Ethereum address (0x...)",
    ),
    "g_key_watch_only_cant_send": MessageLookupByLibrary.simpleMessage(
      "Watch-only wallet cannot send or sign transactions",
    ),
    "g_key_watch_wallet": MessageLookupByLibrary.simpleMessage("Watch Wallet"),
    "g_key_watch_wallet_desc": MessageLookupByLibrary.simpleMessage(
      "Track any EVM address without private key",
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
    "g_lock_key16": MessageLookupByLibrary.simpleMessage("Gesture Password"),
    "g_lock_key17": MessageLookupByLibrary.simpleMessage(
      "Set Gesture Password",
    ),
    "g_lock_key18": MessageLookupByLibrary.simpleMessage(
      "Draw your gesture pattern",
    ),
    "g_lock_key19": MessageLookupByLibrary.simpleMessage(
      "Confirm your gesture pattern",
    ),
    "g_lock_key20": MessageLookupByLibrary.simpleMessage(
      "Draw current gesture",
    ),
    "g_lock_key21": m45,
    "g_lock_key22": MessageLookupByLibrary.simpleMessage(
      "Reset Gesture Password",
    ),
    "g_lock_key23": MessageLookupByLibrary.simpleMessage(
      "Too many failed attempts, please retry",
    ),
    "g_lock_key24": MessageLookupByLibrary.simpleMessage(
      "Add Wallet Password?",
    ),
    "g_lock_key25": m46,
    "g_lock_key26": MessageLookupByLibrary.simpleMessage(
      "Transfer Verification",
    ),
    "g_lock_key27": MessageLookupByLibrary.simpleMessage(
      "Require biometric authentication (Face ID / fingerprint) to confirm each wallet transfer.",
    ),
    "g_lock_key28": MessageLookupByLibrary.simpleMessage(
      "Gesture password not set",
    ),
    "g_lock_key29": MessageLookupByLibrary.simpleMessage(
      "Require gesture authentication to confirm each wallet transfer.",
    ),
    "g_lock_key5": MessageLookupByLibrary.simpleMessage("Succeeded"),
    "g_lock_key6": MessageLookupByLibrary.simpleMessage("Failed"),
    "g_lock_key7": MessageLookupByLibrary.simpleMessage(
      "Biometric recognition is not enabled",
    ),
    "g_lock_key8": MessageLookupByLibrary.simpleMessage(
      "Add biometric verification?",
    ),
    "g_market_30d_change": MessageLookupByLibrary.simpleMessage("30D Change"),
    "g_market_7d_change": MessageLookupByLibrary.simpleMessage("7D Change"),
    "g_market_ath": MessageLookupByLibrary.simpleMessage("ATH"),
    "g_market_atl": MessageLookupByLibrary.simpleMessage("ATL"),
    "g_market_depth": MessageLookupByLibrary.simpleMessage("Market Depth"),
    "g_market_empty_watchlist": MessageLookupByLibrary.simpleMessage(
      "No watchlist yet",
    ),
    "g_market_fdv": MessageLookupByLibrary.simpleMessage("FDV"),
    "g_market_high_24h": MessageLookupByLibrary.simpleMessage("High 24H"),
    "g_market_liquidity_score": MessageLookupByLibrary.simpleMessage(
      "Liquidity Score",
    ),
    "g_market_low_24h": MessageLookupByLibrary.simpleMessage("Low 24H"),
    "g_market_news": MessageLookupByLibrary.simpleMessage("News"),
    "g_market_no_chart": MessageLookupByLibrary.simpleMessage("No chart data"),
    "g_market_no_results": MessageLookupByLibrary.simpleMessage("No results"),
    "g_market_rank": MessageLookupByLibrary.simpleMessage("Rank"),
    "g_market_search": MessageLookupByLibrary.simpleMessage("Search"),
    "g_market_search_hint": MessageLookupByLibrary.simpleMessage(
      "Search coins...",
    ),
    "g_market_trending": MessageLookupByLibrary.simpleMessage("Trending"),
    "g_market_watchlist": MessageLookupByLibrary.simpleMessage("Watchlist"),
    "g_mining_inactivity_warning": MessageLookupByLibrary.simpleMessage(
      "Validator inactivity score is high. Check your node status to avoid penalties.",
    ),
    "g_mining_key20": MessageLookupByLibrary.simpleMessage("Unlock N?"),
    "g_mining_key31": MessageLookupByLibrary.simpleMessage(
      "Cloud Verification Activity",
    ),
    "g_mining_key33": MessageLookupByLibrary.simpleMessage(
      "Verification Settings",
    ),
    "g_mining_key34": MessageLookupByLibrary.simpleMessage(
      "Background Verification Music",
    ),
    "g_mining_key35": MessageLookupByLibrary.simpleMessage("Default"),
    "g_mining_key36": MessageLookupByLibrary.simpleMessage("Mute"),
    "g_mining_key37": MessageLookupByLibrary.simpleMessage(
      "When background verification is enabled, the music will play in the background. If the music stops, verification will also stop.",
    ),
    "g_mining_key38": MessageLookupByLibrary.simpleMessage("Your Tier"),
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
    "g_mining_key82": MessageLookupByLibrary.simpleMessage("Mineral"),
    "g_mining_key83": MessageLookupByLibrary.simpleMessage("Node"),
    "g_mining_key84": MessageLookupByLibrary.simpleMessage("Network"),
    "g_mining_key85": MessageLookupByLibrary.simpleMessage(
      "Switch between testnet and mainnet for cloud mining.",
    ),
    "g_mining_key86": MessageLookupByLibrary.simpleMessage(
      "Redemption available after 768s.",
    ),
    "g_mining_key87": MessageLookupByLibrary.simpleMessage(
      "Requests before that will not be processed.",
    ),
    "g_mining_key_1": MessageLookupByLibrary.simpleMessage("Home"),
    "g_mining_key_10": MessageLookupByLibrary.simpleMessage("Today\'s reward"),
    "g_mining_key_100": MessageLookupByLibrary.simpleMessage(
      "Please treat the data below as an important key. We recommend copying and backing it up to a trusted location immediately.",
    ),
    "g_mining_key_101": MessageLookupByLibrary.simpleMessage("Copy Data"),
    "g_mining_key_102": MessageLookupByLibrary.simpleMessage("Inactive"),
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
    "g_mining_key_15": MessageLookupByLibrary.simpleMessage("Task detail"),
    "g_mining_key_19": MessageLookupByLibrary.simpleMessage("Summary"),
    "g_mining_key_2": MessageLookupByLibrary.simpleMessage("Activities"),
    "g_mining_key_20": MessageLookupByLibrary.simpleMessage(
      "Total Value Mined",
    ),
    "g_mining_key_21": MessageLookupByLibrary.simpleMessage(
      "Verification Since",
    ),
    "g_mining_key_23": MessageLookupByLibrary.simpleMessage("Profit count"),
    "g_mining_key_24": MessageLookupByLibrary.simpleMessage("Verified Value"),
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
    "g_mining_key_45": MessageLookupByLibrary.simpleMessage(
      "Are you sure you want to skip?",
    ),
    "g_mining_key_46": MessageLookupByLibrary.simpleMessage(
      "You will not receive any verification rewards until you choose 1 of the plans.",
    ),
    "g_mining_key_47": MessageLookupByLibrary.simpleMessage("Disabled"),
    "g_mining_key_48": MessageLookupByLibrary.simpleMessage("Reward"),
    "g_mining_key_49": MessageLookupByLibrary.simpleMessage("View more"),
    "g_mining_key_5": MessageLookupByLibrary.simpleMessage(
      "Verification Status",
    ),
    "g_mining_key_50": MessageLookupByLibrary.simpleMessage("To unlock"),
    "g_mining_key_52": MessageLookupByLibrary.simpleMessage("Skip"),
    "g_mining_key_58": MessageLookupByLibrary.simpleMessage("Past 7 Days"),
    "g_mining_key_59": MessageLookupByLibrary.simpleMessage(
      "Accumulated Rewards",
    ),
    "g_mining_key_6": MessageLookupByLibrary.simpleMessage(
      "Lock N to start verifying rewards.",
    ),
    "g_mining_key_60": MessageLookupByLibrary.simpleMessage("Rewards Received"),
    "g_mining_key_61": MessageLookupByLibrary.simpleMessage("Advanced"),
    "g_mining_key_62": MessageLookupByLibrary.simpleMessage("Entry"),
    "g_mining_key_63": MessageLookupByLibrary.simpleMessage("Pro"),
    "g_mining_key_64": MessageLookupByLibrary.simpleMessage("FULL NODE"),
    "g_mining_key_65": MessageLookupByLibrary.simpleMessage("MINS/DAY"),
    "g_mining_key_66": MessageLookupByLibrary.simpleMessage("Advanced Node"),
    "g_mining_key_67": MessageLookupByLibrary.simpleMessage("Entry Node"),
    "g_mining_key_68": MessageLookupByLibrary.simpleMessage("Pro Node"),
    "g_mining_key_69": MessageLookupByLibrary.simpleMessage(
      "500 blocks/day~70 mins",
    ),
    "g_mining_key_7": MessageLookupByLibrary.simpleMessage("Unlock Date"),
    "g_mining_key_70": MessageLookupByLibrary.simpleMessage(
      "100 blocks/day~15 mins",
    ),
    "g_mining_key_71": m52,
    "g_mining_key_72": MessageLookupByLibrary.simpleMessage(
      "128 seconds per check",
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
    "g_mining_key_8": MessageLookupByLibrary.simpleMessage(
      "Today\'s Verification Time",
    ),
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
    "g_mining_node_key1": MessageLookupByLibrary.simpleMessage(
      "Full Node Detail",
    ),
    "g_mining_node_key2": MessageLookupByLibrary.simpleMessage("Node ID"),
    "g_mining_node_key3": MessageLookupByLibrary.simpleMessage("WS Connected"),
    "g_mining_node_key4": MessageLookupByLibrary.simpleMessage(
      "WS Disconnected",
    ),
    "g_mining_node_key5": MessageLookupByLibrary.simpleMessage(
      "WS Reconnecting",
    ),
    "g_mining_node_key6": MessageLookupByLibrary.simpleMessage("Expiry"),
    "g_mining_unlock_period": MessageLookupByLibrary.simpleMessage(
      "Unlock Period:",
    ),
    "g_mining_unlockable_anytime": MessageLookupByLibrary.simpleMessage(
      "Unlockable at any time",
    ),
    "g_news_empty": MessageLookupByLibrary.simpleMessage("No news available"),
    "g_phishing_go_back": MessageLookupByLibrary.simpleMessage(
      "Go Back (Safe)",
    ),
    "g_phishing_proceed_anyway": MessageLookupByLibrary.simpleMessage(
      "Proceed Anyway",
    ),
    "g_phishing_warning_body": MessageLookupByLibrary.simpleMessage(
      "This website has been identified as potentially malicious. It may be attempting to steal your crypto assets or private keys.",
    ),
    "g_phishing_warning_title": MessageLookupByLibrary.simpleMessage(
      "Security Warning",
    ),
    "g_phishing_warning_url_label": MessageLookupByLibrary.simpleMessage(
      "Suspicious URL:",
    ),
    "g_pnl_add_trade": MessageLookupByLibrary.simpleMessage("Add Trade"),
    "g_pnl_avg_cost": MessageLookupByLibrary.simpleMessage("Avg Cost"),
    "g_pnl_buy_price_usd": MessageLookupByLibrary.simpleMessage(
      "Buy Price (USD)",
    ),
    "g_pnl_cost_basis": MessageLookupByLibrary.simpleMessage("Cost Basis"),
    "g_pnl_quantity": MessageLookupByLibrary.simpleMessage("Quantity"),
    "g_pnl_save": MessageLookupByLibrary.simpleMessage("Save"),
    "g_pnl_unrealized": MessageLookupByLibrary.simpleMessage("Unrealized P&L"),
    "g_portfolio_24h": MessageLookupByLibrary.simpleMessage("24h Change"),
    "g_portfolio_all_holdings": MessageLookupByLibrary.simpleMessage(
      "All Holdings",
    ),
    "g_portfolio_allocation": MessageLookupByLibrary.simpleMessage(
      "Asset Allocation",
    ),
    "g_portfolio_gainers": MessageLookupByLibrary.simpleMessage("Top Gainers"),
    "g_portfolio_losers": MessageLookupByLibrary.simpleMessage("Top Losers"),
    "g_portfolio_movers": MessageLookupByLibrary.simpleMessage("24h Movers"),
    "g_portfolio_no_assets": MessageLookupByLibrary.simpleMessage(
      "No assets found",
    ),
    "g_portfolio_others": MessageLookupByLibrary.simpleMessage("Others"),
    "g_portfolio_pie_total": MessageLookupByLibrary.simpleMessage("Total"),
    "g_portfolio_title": MessageLookupByLibrary.simpleMessage("Portfolio"),
    "g_portfolio_total": MessageLookupByLibrary.simpleMessage("Total Value"),
    "g_pred_add_outcome": MessageLookupByLibrary.simpleMessage("Add outcome"),
    "g_pred_create_title": MessageLookupByLibrary.simpleMessage(
      "Start Prediction",
    ),
    "g_pred_creating": MessageLookupByLibrary.simpleMessage("Creating…"),
    "g_pred_deadline": MessageLookupByLibrary.simpleMessage("Deadline"),
    "g_pred_err_outcomes": MessageLookupByLibrary.simpleMessage(
      "At least two valid outcomes",
    ),
    "g_pred_err_question": MessageLookupByLibrary.simpleMessage(
      "Please enter a question",
    ),
    "g_pred_minutes": m54,
    "g_pred_no": MessageLookupByLibrary.simpleMessage("No"),
    "g_pred_outcome_n": m55,
    "g_pred_outcomes": MessageLookupByLibrary.simpleMessage("Outcomes"),
    "g_pred_publish": MessageLookupByLibrary.simpleMessage("Publish"),
    "g_pred_q_hint": MessageLookupByLibrary.simpleMessage(
      "Prediction question, e.g. Who wins this round?",
    ),
    "g_pred_unlimited": MessageLookupByLibrary.simpleMessage(
      "Unlimited (manual close)",
    ),
    "g_pred_yes": MessageLookupByLibrary.simpleMessage("Yes"),
    "g_referral_downloaded": MessageLookupByLibrary.simpleMessage("Downloaded"),
    "g_referral_invite_code": MessageLookupByLibrary.simpleMessage(
      "Invite Code",
    ),
    "g_referral_invited": MessageLookupByLibrary.simpleMessage("Invited"),
    "g_referral_mining": MessageLookupByLibrary.simpleMessage("Mining Nodes"),
    "g_referral_reward": MessageLookupByLibrary.simpleMessage("Reward (N)"),
    "g_setting_mining_v1_label": MessageLookupByLibrary.simpleMessage(
      "Classic Mining (V1)",
    ),
    "g_setting_mining_v2_label": MessageLookupByLibrary.simpleMessage(
      "Mining (V2)",
    ),
    "g_setting_mining_version": MessageLookupByLibrary.simpleMessage(
      "Mining Interface",
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
    "g_swap_key_14": m56,
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
    "g_swap_key_20": m57,
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
    "g_swap_key_31": m58,
    "g_swap_key_32": MessageLookupByLibrary.simpleMessage(
      "Swaps can be viewed on the relevant chain explorers (Etherscan, BscScan, TRONSCAN and our own).",
    ),
    "g_swap_key_33": MessageLookupByLibrary.simpleMessage("Swap to N"),
    "g_swap_key_35": MessageLookupByLibrary.simpleMessage("Swap"),
    "g_swap_key_4": MessageLookupByLibrary.simpleMessage("You get"),
    "g_swap_key_5": MessageLookupByLibrary.simpleMessage("Preview Swap"),
    "g_swap_key_6": MessageLookupByLibrary.simpleMessage("Try again"),
    "g_theme_accent_color": MessageLookupByLibrary.simpleMessage(
      "Accent Color",
    ),
    "g_theme_accent_reset": MessageLookupByLibrary.simpleMessage(
      "Reset to default",
    ),
    "g_token_m_key_1": m59,
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
    "g_token_m_key_19": MessageLookupByLibrary.simpleMessage(
      "Add custom chain",
    ),
    "g_token_m_key_2": MessageLookupByLibrary.simpleMessage("0~18 uint"),
    "g_token_m_key_20": MessageLookupByLibrary.simpleMessage("Add Tokens"),
    "g_token_m_key_21": MessageLookupByLibrary.simpleMessage("Format Error!"),
    "g_token_m_key_22": m60,
    "g_token_m_key_23": m61,
    "g_token_m_key_24": m62,
    "g_token_m_key_3": MessageLookupByLibrary.simpleMessage("Import tokens"),
    "g_token_m_key_4": MessageLookupByLibrary.simpleMessage("All networks"),
    "g_token_m_key_5": MessageLookupByLibrary.simpleMessage("Custom Token"),
    "g_token_m_key_6": MessageLookupByLibrary.simpleMessage("Token address"),
    "g_token_m_key_7": MessageLookupByLibrary.simpleMessage("Token symbol"),
    "g_token_m_key_8": MessageLookupByLibrary.simpleMessage("Token decimal"),
    "g_token_m_key_9": MessageLookupByLibrary.simpleMessage("Import"),
    "g_tx_risk_caution": MessageLookupByLibrary.simpleMessage("Caution"),
    "g_tx_risk_danger": MessageLookupByLibrary.simpleMessage("High Risk"),
    "g_tx_risk_safe": MessageLookupByLibrary.simpleMessage("Safe"),
    "g_version_later": MessageLookupByLibrary.simpleMessage("Later"),
    "g_wc_connection_lost": MessageLookupByLibrary.simpleMessage(
      "Connection lost. Please reconnect.",
    ),
    "g_wc_dapp_disconnected": MessageLookupByLibrary.simpleMessage(
      "DApp has disconnected",
    ),
    "g_wc_disconnect_all": MessageLookupByLibrary.simpleMessage(
      "Disconnect All",
    ),
    "g_wc_disconnect_all_confirm": MessageLookupByLibrary.simpleMessage(
      "Disconnect from all DApps?",
    ),
    "g_wc_disconnect_confirm": MessageLookupByLibrary.simpleMessage(
      "Disconnect from this DApp?",
    ),
    "g_wc_no_sessions": MessageLookupByLibrary.simpleMessage(
      "No active connections",
    ),
    "g_wc_no_sessions_desc": MessageLookupByLibrary.simpleMessage(
      "Scan a QR code to connect to a DApp",
    ),
    "g_wc_proposal_timeout": MessageLookupByLibrary.simpleMessage(
      "Connection request timed out",
    ),
    "g_wc_session_expired": MessageLookupByLibrary.simpleMessage(
      "Session has expired",
    ),
    "g_wc_sessions": MessageLookupByLibrary.simpleMessage("Connected DApps"),
    "google_verification_message10": MessageLookupByLibrary.simpleMessage(
      "Link",
    ),
    "importantNotice": MessageLookupByLibrary.simpleMessage("Important Notice"),
    "login_email": MessageLookupByLibrary.simpleMessage("Email"),
    "login_password": MessageLookupByLibrary.simpleMessage("Password"),
    "next": MessageLookupByLibrary.simpleMessage("Next"),
    "nicknameMessage": m63,
    "personalInformation": MessageLookupByLibrary.simpleMessage("Edit Profile"),
    "photograph": MessageLookupByLibrary.simpleMessage("Photograph"),
    "please_input_address": MessageLookupByLibrary.simpleMessage(
      "Please Input Address",
    ),
    "push_permission_btn_dismiss": MessageLookupByLibrary.simpleMessage(
      "Don\'t remind me",
    ),
    "push_permission_btn_later": MessageLookupByLibrary.simpleMessage("Later"),
    "push_permission_btn_settings": MessageLookupByLibrary.simpleMessage(
      "Go to Settings",
    ),
    "push_permission_dialog_content": MessageLookupByLibrary.simpleMessage(
      "Push notifications are disabled. You may miss chat messages and transfer alerts.\n\nPlease enable notifications for this app in system settings.",
    ),
    "push_permission_dialog_title": MessageLookupByLibrary.simpleMessage(
      "Notifications Disabled",
    ),
    "repeatPassword": MessageLookupByLibrary.simpleMessage("Re-enter Password"),
    "rest_Choose_password": MessageLookupByLibrary.simpleMessage(
      "Choose a password(8~18 characters)",
    ),
    "rest_Confirm_password": MessageLookupByLibrary.simpleMessage(
      "Confirm Password",
    ),
    "s_key_10": MessageLookupByLibrary.simpleMessage("About App"),
    "s_key_11": MessageLookupByLibrary.simpleMessage("Security"),
    "s_key_3": MessageLookupByLibrary.simpleMessage("Transaction"),
    "s_key_4": MessageLookupByLibrary.simpleMessage("Language"),
    "search": MessageLookupByLibrary.simpleMessage("Search"),
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
