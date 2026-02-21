// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Failed to remove!`
  String get g_key_1 {
    return Intl.message(
      'Failed to remove!',
      name: 'g_key_1',
      desc: '',
      args: [],
    );
  }

  /// `The ledger is empty!`
  String get g_key_2 {
    return Intl.message(
      'The ledger is empty!',
      name: 'g_key_2',
      desc: '',
      args: [],
    );
  }

  /// `Failed to add!`
  String get g_key_3 {
    return Intl.message('Failed to add!', name: 'g_key_3', desc: '', args: []);
  }

  /// `Scan QR code`
  String get g_key_4 {
    return Intl.message('Scan QR code', name: 'g_key_4', desc: '', args: []);
  }

  /// `Failed to load!`
  String get g_key_5 {
    return Intl.message('Failed to load!', name: 'g_key_5', desc: '', args: []);
  }

  /// `Wallet`
  String get g_key_6 {
    return Intl.message('Wallet', name: 'g_key_6', desc: '', args: []);
  }

  /// `Create`
  String get g_key_7 {
    return Intl.message('Create', name: 'g_key_7', desc: '', args: []);
  }

  /// `Remark`
  String get g_key_8 {
    return Intl.message('Remark', name: 'g_key_8', desc: '', args: []);
  }

  /// `All tokens`
  String get g_key_9 {
    return Intl.message('All tokens', name: 'g_key_9', desc: '', args: []);
  }

  /// `Import wallet`
  String get g_key_11 {
    return Intl.message('Import wallet', name: 'g_key_11', desc: '', args: []);
  }

  /// `Create/Import wallet`
  String get g_key_12 {
    return Intl.message(
      'Create/Import wallet',
      name: 'g_key_12',
      desc: '',
      args: [],
    );
  }

  /// `Wallet List`
  String get g_key_13 {
    return Intl.message('Wallet List', name: 'g_key_13', desc: '', args: []);
  }

  /// `Main Wallet`
  String get g_key_14 {
    return Intl.message('Main Wallet', name: 'g_key_14', desc: '', args: []);
  }

  /// `Set as Main Wallet`
  String get g_key_15 {
    return Intl.message(
      'Set as Main Wallet',
      name: 'g_key_15',
      desc: '',
      args: [],
    );
  }

  /// `Select Verify Wallet`
  String get g_key_16 {
    return Intl.message(
      'Select Verify Wallet',
      name: 'g_key_16',
      desc: '',
      args: [],
    );
  }

  /// `Choose Chain`
  String get g_key_17 {
    return Intl.message('Choose Chain', name: 'g_key_17', desc: '', args: []);
  }

  /// `Enter wallet password`
  String get g_key_21 {
    return Intl.message(
      'Enter wallet password',
      name: 'g_key_21',
      desc: '',
      args: [],
    );
  }

  /// `Password doesn't match.`
  String get g_key_25 {
    return Intl.message(
      'Password doesn\'t match.',
      name: 'g_key_25',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get g_key_29 {
    return Intl.message('Balance', name: 'g_key_29', desc: '', args: []);
  }

  /// `Receive`
  String get g_key_33 {
    return Intl.message('Receive', name: 'g_key_33', desc: '', args: []);
  }

  /// `Transfer`
  String get g_key_37 {
    return Intl.message('Transfer', name: 'g_key_37', desc: '', args: []);
  }

  /// `To`
  String get g_key_38 {
    return Intl.message('To', name: 'g_key_38', desc: '', args: []);
  }

  /// `Enter a wallet address`
  String get g_key_41 {
    return Intl.message(
      'Enter a wallet address',
      name: 'g_key_41',
      desc: '',
      args: [],
    );
  }

  /// `Available Balance`
  String get g_key_43 {
    return Intl.message(
      'Available Balance',
      name: 'g_key_43',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get g_key_44 {
    return Intl.message('Amount', name: 'g_key_44', desc: '', args: []);
  }

  /// `Enter an amount more than {value}.`
  String g_key_46(Object value) {
    return Intl.message(
      'Enter an amount more than $value.',
      name: 'g_key_46',
      desc: '',
      args: [value],
    );
  }

  /// `Insufficient funds available to cover this transaction.`
  String get g_key_47 {
    return Intl.message(
      'Insufficient funds available to cover this transaction.',
      name: 'g_key_47',
      desc: '',
      args: [],
    );
  }

  /// `Send`
  String get g_key_48 {
    return Intl.message('Send', name: 'g_key_48', desc: '', args: []);
  }

  /// `From`
  String get g_key_75 {
    return Intl.message('From', name: 'g_key_75', desc: '', args: []);
  }

  /// `Confirm`
  String get g_key_78 {
    return Intl.message('Confirm', name: 'g_key_78', desc: '', args: []);
  }

  /// `Cancel`
  String get g_key_79 {
    return Intl.message('Cancel', name: 'g_key_79', desc: '', args: []);
  }

  /// `Seed phrase`
  String get g_key_85 {
    return Intl.message('Seed phrase', name: 'g_key_85', desc: '', args: []);
  }

  /// `Settings`
  String get g_key_94 {
    return Intl.message('Settings', name: 'g_key_94', desc: '', args: []);
  }

  /// `Send`
  String get g_key_100 {
    return Intl.message('Send', name: 'g_key_100', desc: '', args: []);
  }

  /// `Gas limit`
  String get g_key_101 {
    return Intl.message('Gas limit', name: 'g_key_101', desc: '', args: []);
  }

  /// `No more`
  String get g_key_105 {
    return Intl.message('No more', name: 'g_key_105', desc: '', args: []);
  }

  /// `Loading `
  String get g_key_106 {
    return Intl.message('Loading ', name: 'g_key_106', desc: '', args: []);
  }

  /// `Address Book`
  String get g_key_108 {
    return Intl.message('Address Book', name: 'g_key_108', desc: '', args: []);
  }

  /// `Manage`
  String get g_key_110 {
    return Intl.message('Manage', name: 'g_key_110', desc: '', args: []);
  }

  /// `New address`
  String get g_key_112 {
    return Intl.message('New address', name: 'g_key_112', desc: '', args: []);
  }

  /// `Delete`
  String get g_key_113 {
    return Intl.message('Delete', name: 'g_key_113', desc: '', args: []);
  }

  /// `Save`
  String get g_key_115 {
    return Intl.message('Save', name: 'g_key_115', desc: '', args: []);
  }

  /// `Copy`
  String get g_key_119 {
    return Intl.message('Copy', name: 'g_key_119', desc: '', args: []);
  }

  /// `Theme`
  String get g_key_126 {
    return Intl.message('Theme', name: 'g_key_126', desc: '', args: []);
  }

  /// `System`
  String get g_key_127 {
    return Intl.message('System', name: 'g_key_127', desc: '', args: []);
  }

  /// `Light`
  String get g_key_128 {
    return Intl.message('Light', name: 'g_key_128', desc: '', args: []);
  }

  /// `Dark`
  String get g_key_129 {
    return Intl.message('Dark', name: 'g_key_129', desc: '', args: []);
  }

  /// `No data`
  String get g_key_132 {
    return Intl.message('No data', name: 'g_key_132', desc: '', args: []);
  }

  /// `Amount not valid`
  String get g_key_134 {
    return Intl.message(
      'Amount not valid',
      name: 'g_key_134',
      desc: '',
      args: [],
    );
  }

  /// `Amount greater than {value}.`
  String g_key_135(Object value) {
    return Intl.message(
      'Amount greater than $value.',
      name: 'g_key_135',
      desc: '',
      args: [value],
    );
  }

  /// `Transaction successful`
  String get g_key_140 {
    return Intl.message(
      'Transaction successful',
      name: 'g_key_140',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect password`
  String get g_key_146 {
    return Intl.message(
      'Incorrect password',
      name: 'g_key_146',
      desc: '',
      args: [],
    );
  }

  /// `Testnet`
  String get g_key_147 {
    return Intl.message('Testnet', name: 'g_key_147', desc: '', args: []);
  }

  /// `Mainnet`
  String get g_key_148 {
    return Intl.message('Mainnet', name: 'g_key_148', desc: '', args: []);
  }

  /// `System language`
  String get g_key_149 {
    return Intl.message(
      'System language',
      name: 'g_key_149',
      desc: '',
      args: [],
    );
  }

  /// `Submit`
  String get g_key_154 {
    return Intl.message('Submit', name: 'g_key_154', desc: '', args: []);
  }

  /// `Wallet address`
  String get g_key_155 {
    return Intl.message(
      'Wallet address',
      name: 'g_key_155',
      desc: '',
      args: [],
    );
  }

  /// `Scan to copy address`
  String get g_key_156 {
    return Intl.message(
      'Scan to copy address',
      name: 'g_key_156',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get g_key_159 {
    return Intl.message('Add', name: 'g_key_159', desc: '', args: []);
  }

  /// `Symbol`
  String get g_key_163 {
    return Intl.message('Symbol', name: 'g_key_163', desc: '', args: []);
  }

  /// `Paste`
  String get g_key_166 {
    return Intl.message('Paste', name: 'g_key_166', desc: '', args: []);
  }

  /// `Transaction failed`
  String get g_key_175 {
    return Intl.message(
      'Transaction failed',
      name: 'g_key_175',
      desc: '',
      args: [],
    );
  }

  /// `This is my wallet address`
  String get g_key_179 {
    return Intl.message(
      'This is my wallet address',
      name: 'g_key_179',
      desc: '',
      args: [],
    );
  }

  /// `Other`
  String get g_key_181 {
    return Intl.message('Other', name: 'g_key_181', desc: '', args: []);
  }

  /// `Successfully saved`
  String get g_key_185 {
    return Intl.message(
      'Successfully saved',
      name: 'g_key_185',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get g_key_191 {
    return Intl.message('Success', name: 'g_key_191', desc: '', args: []);
  }

  /// `Are you sure you want to delete the wallet?`
  String get g_key_192 {
    return Intl.message(
      'Are you sure you want to delete the wallet?',
      name: 'g_key_192',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get g_key_193 {
    return Intl.message('Active', name: 'g_key_193', desc: '', args: []);
  }

  /// `No permission to access the camera.`
  String get g_key_195 {
    return Intl.message(
      'No permission to access the camera.',
      name: 'g_key_195',
      desc: '',
      args: [],
    );
  }

  /// `Explorer`
  String get g_key_196 {
    return Intl.message('Explorer', name: 'g_key_196', desc: '', args: []);
  }

  /// `Max`
  String get g_key_197 {
    return Intl.message('Max', name: 'g_key_197', desc: '', args: []);
  }

  /// `Assets`
  String get g_key_198 {
    return Intl.message('Assets', name: 'g_key_198', desc: '', args: []);
  }

  /// `Transaction Overview`
  String get g_key_202 {
    return Intl.message(
      'Transaction Overview',
      name: 'g_key_202',
      desc: '',
      args: [],
    );
  }

  /// `link error, scan QR Code again.`
  String get g_key_203 {
    return Intl.message(
      'link error, scan QR Code again.',
      name: 'g_key_203',
      desc: '',
      args: [],
    );
  }

  /// `No permission to access the photo album.`
  String get g_key_205 {
    return Intl.message(
      'No permission to access the photo album.',
      name: 'g_key_205',
      desc: '',
      args: [],
    );
  }

  /// `Password Edit`
  String get g_key_206 {
    return Intl.message('Password Edit', name: 'g_key_206', desc: '', args: []);
  }

  /// `Old Password`
  String get g_key_207 {
    return Intl.message('Old Password', name: 'g_key_207', desc: '', args: []);
  }

  /// `Syncing balances...`
  String get g_key_208 {
    return Intl.message(
      'Syncing balances...',
      name: 'g_key_208',
      desc: '',
      args: [],
    );
  }

  /// `Private Key`
  String get g_key_209 {
    return Intl.message('Private Key', name: 'g_key_209', desc: '', args: []);
  }

  /// `Private key error`
  String get g_key_210 {
    return Intl.message(
      'Private key error',
      name: 'g_key_210',
      desc: '',
      args: [],
    );
  }

  /// `Buy`
  String get g_key_211 {
    return Intl.message('Buy', name: 'g_key_211', desc: '', args: []);
  }

  /// `Sell`
  String get g_key_212 {
    return Intl.message('Sell', name: 'g_key_212', desc: '', args: []);
  }

  /// `Market Information`
  String get g_key_213 {
    return Intl.message(
      'Market Information',
      name: 'g_key_213',
      desc: '',
      args: [],
    );
  }

  /// `The wallet already exists, the wallet name is "{value}"`
  String g_key_214(Object value) {
    return Intl.message(
      'The wallet already exists, the wallet name is "$value"',
      name: 'g_key_214',
      desc: '',
      args: [value],
    );
  }

  /// `Nickname`
  String get g_key_u_2 {
    return Intl.message('Nickname', name: 'g_key_u_2', desc: '', args: []);
  }

  /// `Description`
  String get g_key_u_3 {
    return Intl.message('Description', name: 'g_key_u_3', desc: '', args: []);
  }

  /// `Artist information`
  String get g_key_u_5 {
    return Intl.message(
      'Artist information',
      name: 'g_key_u_5',
      desc: '',
      args: [],
    );
  }

  /// `You are not an artist`
  String get g_key_u_6 {
    return Intl.message(
      'You are not an artist',
      name: 'g_key_u_6',
      desc: '',
      args: [],
    );
  }

  /// `Click here to apply to become an artist`
  String get g_key_u_7 {
    return Intl.message(
      'Click here to apply to become an artist',
      name: 'g_key_u_7',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get g_key_u_8 {
    return Intl.message('Name', name: 'g_key_u_8', desc: '', args: []);
  }

  /// `Revenue`
  String get g_key_u_9 {
    return Intl.message('Revenue', name: 'g_key_u_9', desc: '', args: []);
  }

  /// `NFT Types`
  String get g_key_u_10 {
    return Intl.message('NFT Types', name: 'g_key_u_10', desc: '', args: []);
  }

  /// `Followers`
  String get g_key_u_11 {
    return Intl.message('Followers', name: 'g_key_u_11', desc: '', args: []);
  }

  /// `User Types`
  String get g_key_u_12 {
    return Intl.message('User Types', name: 'g_key_u_12', desc: '', args: []);
  }

  /// `Website`
  String get g_key_u_13 {
    return Intl.message('Website', name: 'g_key_u_13', desc: '', args: []);
  }

  /// `Products link`
  String get g_key_u_14 {
    return Intl.message(
      'Products link',
      name: 'g_key_u_14',
      desc: '',
      args: [],
    );
  }

  /// `Media platforms`
  String get g_key_u_15 {
    return Intl.message(
      'Media platforms',
      name: 'g_key_u_15',
      desc: '',
      args: [],
    );
  }

  /// `Wallet address`
  String get g_key_u_16 {
    return Intl.message(
      'Wallet address',
      name: 'g_key_u_16',
      desc: '',
      args: [],
    );
  }

  /// `Avatar upload failed`
  String get g_key_u_23 {
    return Intl.message(
      'Avatar upload failed',
      name: 'g_key_u_23',
      desc: '',
      args: [],
    );
  }

  /// `Parsing response data error!`
  String get g_key_error_1 {
    return Intl.message(
      'Parsing response data error!',
      name: 'g_key_error_1',
      desc: '',
      args: [],
    );
  }

  /// `Unknown error!`
  String get g_key_error_3 {
    return Intl.message(
      'Unknown error!',
      name: 'g_key_error_3',
      desc: '',
      args: [],
    );
  }

  /// `Network connection timed out, please check network settings!`
  String get g_key_error_4 {
    return Intl.message(
      'Network connection timed out, please check network settings!',
      name: 'g_key_error_4',
      desc: '',
      args: [],
    );
  }

  /// `The server is abnormal. Please try again later!`
  String get g_key_error_5 {
    return Intl.message(
      'The server is abnormal. Please try again later!',
      name: 'g_key_error_5',
      desc: '',
      args: [],
    );
  }

  /// `Request has been cancelled, please request again!`
  String get g_key_error_8 {
    return Intl.message(
      'Request has been cancelled, please request again!',
      name: 'g_key_error_8',
      desc: '',
      args: [],
    );
  }

  /// `Dio Error`
  String get g_key_error_10 {
    return Intl.message(
      'Dio Error',
      name: 'g_key_error_10',
      desc: '',
      args: [],
    );
  }

  /// `Request syntax error`
  String get g_key_error_11 {
    return Intl.message(
      'Request syntax error',
      name: 'g_key_error_11',
      desc: '',
      args: [],
    );
  }

  /// `Unauthorized, please log in`
  String get g_key_error_12 {
    return Intl.message(
      'Unauthorized, please log in',
      name: 'g_key_error_12',
      desc: '',
      args: [],
    );
  }

  /// `Access denied`
  String get g_key_error_13 {
    return Intl.message(
      'Access denied',
      name: 'g_key_error_13',
      desc: '',
      args: [],
    );
  }

  /// `Request error`
  String get g_key_error_14 {
    return Intl.message(
      'Request error',
      name: 'g_key_error_14',
      desc: '',
      args: [],
    );
  }

  /// `Request timed out`
  String get g_key_error_15 {
    return Intl.message(
      'Request timed out',
      name: 'g_key_error_15',
      desc: '',
      args: [],
    );
  }

  /// `Server abnormal`
  String get g_key_error_16 {
    return Intl.message(
      'Server abnormal',
      name: 'g_key_error_16',
      desc: '',
      args: [],
    );
  }

  /// `Service not implemented`
  String get g_key_error_17 {
    return Intl.message(
      'Service not implemented',
      name: 'g_key_error_17',
      desc: '',
      args: [],
    );
  }

  /// `Gateway error`
  String get g_key_error_18 {
    return Intl.message(
      'Gateway error',
      name: 'g_key_error_18',
      desc: '',
      args: [],
    );
  }

  /// `Service is not available`
  String get g_key_error_19 {
    return Intl.message(
      'Service is not available',
      name: 'g_key_error_19',
      desc: '',
      args: [],
    );
  }

  /// `Gateway timeout`
  String get g_key_error_20 {
    return Intl.message(
      'Gateway timeout',
      name: 'g_key_error_20',
      desc: '',
      args: [],
    );
  }

  /// `HTTP version is not supported`
  String get g_key_error_21 {
    return Intl.message(
      'HTTP version is not supported',
      name: 'g_key_error_21',
      desc: '',
      args: [],
    );
  }

  /// `The request failed, error code:`
  String get g_key_error_22 {
    return Intl.message(
      'The request failed, error code:',
      name: 'g_key_error_22',
      desc: '',
      args: [],
    );
  }

  /// `System is busy, please try again later`
  String get g_key_error_23 {
    return Intl.message(
      'System is busy, please try again later',
      name: 'g_key_error_23',
      desc: '',
      args: [],
    );
  }

  /// `Request frequency is too fast`
  String get g_key_error_24 {
    return Intl.message(
      'Request frequency is too fast',
      name: 'g_key_error_24',
      desc: '',
      args: [],
    );
  }

  /// `Decoding failed`
  String get g_key_error_25 {
    return Intl.message(
      'Decoding failed',
      name: 'g_key_error_25',
      desc: '',
      args: [],
    );
  }

  /// `The transaction is already on the chain`
  String get g_key_error_26 {
    return Intl.message(
      'The transaction is already on the chain',
      name: 'g_key_error_26',
      desc: '',
      args: [],
    );
  }

  /// `Certificate configuration error!`
  String get g_key_error_27 {
    return Intl.message(
      'Certificate configuration error!',
      name: 'g_key_error_27',
      desc: '',
      args: [],
    );
  }

  /// `Status code configuration error!`
  String get g_key_error_28 {
    return Intl.message(
      'Status code configuration error!',
      name: 'g_key_error_28',
      desc: '',
      args: [],
    );
  }

  /// `Incorrect account or password`
  String get g_key_error_1301 {
    return Intl.message(
      'Incorrect account or password',
      name: 'g_key_error_1301',
      desc: '',
      args: [],
    );
  }

  /// `You are already logged in on another phone and are forced to log out.`
  String get g_key_error_1403 {
    return Intl.message(
      'You are already logged in on another phone and are forced to log out.',
      name: 'g_key_error_1403',
      desc: '',
      args: [],
    );
  }

  /// `Manage Wallet`
  String get s_key_1 {
    return Intl.message('Manage Wallet', name: 's_key_1', desc: '', args: []);
  }

  /// `Wallet Addresses`
  String get s_key_2 {
    return Intl.message(
      'Wallet Addresses',
      name: 's_key_2',
      desc: '',
      args: [],
    );
  }

  /// `Transaction`
  String get s_key_3 {
    return Intl.message('Transaction', name: 's_key_3', desc: '', args: []);
  }

  /// `Language`
  String get s_key_4 {
    return Intl.message('Language', name: 's_key_4', desc: '', args: []);
  }

  /// `Theme`
  String get s_key_5 {
    return Intl.message('Theme', name: 's_key_5', desc: '', args: []);
  }

  /// `About App`
  String get s_key_10 {
    return Intl.message('About App', name: 's_key_10', desc: '', args: []);
  }

  /// `Security`
  String get s_key_11 {
    return Intl.message('Security', name: 's_key_11', desc: '', args: []);
  }

  /// `Use New Chat`
  String get s_key_12 {
    return Intl.message('Use New Chat', name: 's_key_12', desc: '', args: []);
  }

  /// `Enable enhanced Chat experience`
  String get s_key_13 {
    return Intl.message(
      'Enable enhanced Chat experience',
      name: 's_key_13',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the URL`
  String get g_browser_key1 {
    return Intl.message(
      'Please enter the URL',
      name: 'g_browser_key1',
      desc: '',
      args: [],
    );
  }

  /// `Bookmarks`
  String get g_browser_key3 {
    return Intl.message(
      'Bookmarks',
      name: 'g_browser_key3',
      desc: '',
      args: [],
    );
  }

  /// `No bookmarks added yet`
  String get g_browser_key4 {
    return Intl.message(
      'No bookmarks added yet',
      name: 'g_browser_key4',
      desc: '',
      args: [],
    );
  }

  /// `Bookmark`
  String get g_browser_key5 {
    return Intl.message('Bookmark', name: 'g_browser_key5', desc: '', args: []);
  }

  /// `Name`
  String get g_browser_key6 {
    return Intl.message('Name', name: 'g_browser_key6', desc: '', args: []);
  }

  /// `Please enter the Name`
  String get g_browser_key7 {
    return Intl.message(
      'Please enter the Name',
      name: 'g_browser_key7',
      desc: '',
      args: [],
    );
  }

  /// `URL`
  String get g_browser_key8 {
    return Intl.message('URL', name: 'g_browser_key8', desc: '', args: []);
  }

  /// `Description`
  String get g_browser_key9 {
    return Intl.message(
      'Description',
      name: 'g_browser_key9',
      desc: '',
      args: [],
    );
  }

  /// `Enter a description`
  String get g_browser_key10 {
    return Intl.message(
      'Enter a description',
      name: 'g_browser_key10',
      desc: '',
      args: [],
    );
  }

  /// `Browser`
  String get g_browser_key11 {
    return Intl.message('Browser', name: 'g_browser_key11', desc: '', args: []);
  }

  /// `Clear Browser Cache`
  String get g_browser_key12 {
    return Intl.message(
      'Clear Browser Cache',
      name: 'g_browser_key12',
      desc: '',
      args: [],
    );
  }

  /// `Connect DApp automatically`
  String get g_browser_key13 {
    return Intl.message(
      'Connect DApp automatically',
      name: 'g_browser_key13',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm connecting to DApp`
  String get g_browser_key14 {
    return Intl.message(
      'Please confirm connecting to DApp',
      name: 'g_browser_key14',
      desc: '',
      args: [],
    );
  }

  /// `Close all`
  String get g_browser_key16 {
    return Intl.message(
      'Close all',
      name: 'g_browser_key16',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get g_browser_key17 {
    return Intl.message('Done', name: 'g_browser_key17', desc: '', args: []);
  }

  /// `Connect`
  String get g_connect_key1 {
    return Intl.message('Connect', name: 'g_connect_key1', desc: '', args: []);
  }

  /// `Disconnect`
  String get g_connect_key2 {
    return Intl.message(
      'Disconnect',
      name: 'g_connect_key2',
      desc: '',
      args: [],
    );
  }

  /// `Reject`
  String get g_connect_key3 {
    return Intl.message('Reject', name: 'g_connect_key3', desc: '', args: []);
  }

  /// `Available Networks`
  String get g_connect_key11 {
    return Intl.message(
      'Available Networks',
      name: 'g_connect_key11',
      desc: '',
      args: [],
    );
  }

  /// `Message sign`
  String get g_connect_key12 {
    return Intl.message(
      'Message sign',
      name: 'g_connect_key12',
      desc: '',
      args: [],
    );
  }

  /// `Connecting`
  String get g_connect_key13 {
    return Intl.message(
      'Connecting',
      name: 'g_connect_key13',
      desc: '',
      args: [],
    );
  }

  /// `Pairing, please wait.`
  String get g_connect_key14 {
    return Intl.message(
      'Pairing, please wait.',
      name: 'g_connect_key14',
      desc: '',
      args: [],
    );
  }

  /// `Biometric Scan Tips`
  String get g_face_1 {
    return Intl.message(
      'Biometric Scan Tips',
      name: 'g_face_1',
      desc: '',
      args: [],
    );
  }

  /// `Biometric scan didn't work`
  String get g_face_2 {
    return Intl.message(
      'Biometric scan didn\'t work',
      name: 'g_face_2',
      desc: '',
      args: [],
    );
  }

  /// `Tips`
  String get g_face_3 {
    return Intl.message('Tips', name: 'g_face_3', desc: '', args: []);
  }

  /// `Biometric scan success`
  String get g_face_4 {
    return Intl.message(
      'Biometric scan success',
      name: 'g_face_4',
      desc: '',
      args: [],
    );
  }

  /// `To set`
  String get g_face_5 {
    return Intl.message('To set', name: 'g_face_5', desc: '', args: []);
  }

  /// `You haven't set biometric login. Go to System Settings to set it.`
  String get g_face_6 {
    return Intl.message(
      'You haven\'t set biometric login. Go to System Settings to set it.',
      name: 'g_face_6',
      desc: '',
      args: [],
    );
  }

  /// `Scan your face or fingerprint to continue.`
  String get g_face_7 {
    return Intl.message(
      'Scan your face or fingerprint to continue.',
      name: 'g_face_7',
      desc: '',
      args: [],
    );
  }

  /// `Return`
  String get g_face_8 {
    return Intl.message('Return', name: 'g_face_8', desc: '', args: []);
  }

  /// `It is recommended that you re-enable biometrics.`
  String get g_face_9 {
    return Intl.message(
      'It is recommended that you re-enable biometrics.',
      name: 'g_face_9',
      desc: '',
      args: [],
    );
  }

  /// `Scan your fingerprint or face for authentication.`
  String get g_face_10 {
    return Intl.message(
      'Scan your fingerprint or face for authentication.',
      name: 'g_face_10',
      desc: '',
      args: [],
    );
  }

  /// `You pay`
  String get g_swap_key_3 {
    return Intl.message('You pay', name: 'g_swap_key_3', desc: '', args: []);
  }

  /// `You get`
  String get g_swap_key_4 {
    return Intl.message('You get', name: 'g_swap_key_4', desc: '', args: []);
  }

  /// `Preview Swap`
  String get g_swap_key_5 {
    return Intl.message(
      'Preview Swap',
      name: 'g_swap_key_5',
      desc: '',
      args: [],
    );
  }

  /// `Try again`
  String get g_swap_key_6 {
    return Intl.message('Try again', name: 'g_swap_key_6', desc: '', args: []);
  }

  /// `{value} Insufficient Balance.`
  String g_swap_key_14(Object value) {
    return Intl.message(
      '$value Insufficient Balance.',
      name: 'g_swap_key_14',
      desc: '',
      args: [value],
    );
  }

  /// `Get coin price error.`
  String get g_swap_key_15 {
    return Intl.message(
      'Get coin price error.',
      name: 'g_swap_key_15',
      desc: '',
      args: [],
    );
  }

  /// `By proceeding, you agree with the following `
  String get g_swap_key_16 {
    return Intl.message(
      'By proceeding, you agree with the following ',
      name: 'g_swap_key_16',
      desc: '',
      args: [],
    );
  }

  /// `Terms and Conditions.`
  String get g_swap_key_17 {
    return Intl.message(
      'Terms and Conditions.',
      name: 'g_swap_key_17',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get g_swap_key_18 {
    return Intl.message('Finish', name: 'g_swap_key_18', desc: '', args: []);
  }

  /// `Your swap will be distributed shortly.Please be patient.`
  String get g_swap_key_19 {
    return Intl.message(
      'Your swap will be distributed shortly.Please be patient.',
      name: 'g_swap_key_19',
      desc: '',
      args: [],
    );
  }

  /// `{value} incoming...`
  String g_swap_key_20(Object value) {
    return Intl.message(
      '$value incoming...',
      name: 'g_swap_key_20',
      desc: '',
      args: [value],
    );
  }

  /// `Costs to run a node: Group Verification 1-49 N Basic Node: 50 N Premium Node: 100 N Pro Node: 500 N.`
  String get g_swap_key_21 {
    return Intl.message(
      'Costs to run a node: Group Verification 1-49 N Basic Node: 50 N Premium Node: 100 N Pro Node: 500 N.',
      name: 'g_swap_key_21',
      desc: '',
      args: [],
    );
  }

  /// `Expire`
  String get g_swap_key_22 {
    return Intl.message('Expire', name: 'g_swap_key_22', desc: '', args: []);
  }

  /// `Unpaid`
  String get g_swap_key_23 {
    return Intl.message('Unpaid', name: 'g_swap_key_23', desc: '', args: []);
  }

  /// `Confirming payment`
  String get g_swap_key_24 {
    return Intl.message(
      'Confirming payment',
      name: 'g_swap_key_24',
      desc: '',
      args: [],
    );
  }

  /// `To be distributed`
  String get g_swap_key_25 {
    return Intl.message(
      'To be distributed',
      name: 'g_swap_key_25',
      desc: '',
      args: [],
    );
  }

  /// `Swap Summary`
  String get g_swap_key_28 {
    return Intl.message(
      'Swap Summary',
      name: 'g_swap_key_28',
      desc: '',
      args: [],
    );
  }

  /// `New Balance`
  String get g_swap_key_29 {
    return Intl.message(
      'New Balance',
      name: 'g_swap_key_29',
      desc: '',
      args: [],
    );
  }

  /// `Date`
  String get g_swap_key_30 {
    return Intl.message('Date', name: 'g_swap_key_30', desc: '', args: []);
  }

  /// `{value} swapped in-app will be distributed shortly to your wallet and cannot be sold via this process. It can be used to run a node.`
  String g_swap_key_31(Object value) {
    return Intl.message(
      '$value swapped in-app will be distributed shortly to your wallet and cannot be sold via this process. It can be used to run a node.',
      name: 'g_swap_key_31',
      desc: '',
      args: [value],
    );
  }

  /// `Swaps can be viewed on the relevant chain explorers (Etherscan, BscScan, TRONSCAN and our own).`
  String get g_swap_key_32 {
    return Intl.message(
      'Swaps can be viewed on the relevant chain explorers (Etherscan, BscScan, TRONSCAN and our own).',
      name: 'g_swap_key_32',
      desc: '',
      args: [],
    );
  }

  /// `Swap to N`
  String get g_swap_key_33 {
    return Intl.message('Swap to N', name: 'g_swap_key_33', desc: '', args: []);
  }

  /// `Swap`
  String get g_swap_key_35 {
    return Intl.message('Swap', name: 'g_swap_key_35', desc: '', args: []);
  }

  /// `Transaction history`
  String get g_key_tran_1 {
    return Intl.message(
      'Transaction history',
      name: 'g_key_tran_1',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Detail`
  String get g_key_tran_4 {
    return Intl.message(
      'Transaction Detail',
      name: 'g_key_tran_4',
      desc: '',
      args: [],
    );
  }

  /// `Please view transaction receipts in history`
  String get g_key_tran_6 {
    return Intl.message(
      'Please view transaction receipts in history',
      name: 'g_key_tran_6',
      desc: '',
      args: [],
    );
  }

  /// `Spend amount`
  String get g_key_tran_7 {
    return Intl.message(
      'Spend amount',
      name: 'g_key_tran_7',
      desc: '',
      args: [],
    );
  }

  /// `Get amount`
  String get g_key_tran_8 {
    return Intl.message('Get amount', name: 'g_key_tran_8', desc: '', args: []);
  }

  /// `Max {value} characters`
  String g_token_m_key_1(Object value) {
    return Intl.message(
      'Max $value characters',
      name: 'g_token_m_key_1',
      desc: '',
      args: [value],
    );
  }

  /// `0~18 uint`
  String get g_token_m_key_2 {
    return Intl.message(
      '0~18 uint',
      name: 'g_token_m_key_2',
      desc: '',
      args: [],
    );
  }

  /// `Import tokens`
  String get g_token_m_key_3 {
    return Intl.message(
      'Import tokens',
      name: 'g_token_m_key_3',
      desc: '',
      args: [],
    );
  }

  /// `All networks`
  String get g_token_m_key_4 {
    return Intl.message(
      'All networks',
      name: 'g_token_m_key_4',
      desc: '',
      args: [],
    );
  }

  /// `Custom Token`
  String get g_token_m_key_5 {
    return Intl.message(
      'Custom Token',
      name: 'g_token_m_key_5',
      desc: '',
      args: [],
    );
  }

  /// `Token address`
  String get g_token_m_key_6 {
    return Intl.message(
      'Token address',
      name: 'g_token_m_key_6',
      desc: '',
      args: [],
    );
  }

  /// `Token symbol`
  String get g_token_m_key_7 {
    return Intl.message(
      'Token symbol',
      name: 'g_token_m_key_7',
      desc: '',
      args: [],
    );
  }

  /// `Token decimal`
  String get g_token_m_key_8 {
    return Intl.message(
      'Token decimal',
      name: 'g_token_m_key_8',
      desc: '',
      args: [],
    );
  }

  /// `Import`
  String get g_token_m_key_9 {
    return Intl.message('Import', name: 'g_token_m_key_9', desc: '', args: []);
  }

  /// `Anyone can create a token, including creating fake versions of existing tokens. Always research a token before importing it.`
  String get g_token_m_key_10 {
    return Intl.message(
      'Anyone can create a token, including creating fake versions of existing tokens. Always research a token before importing it.',
      name: 'g_token_m_key_10',
      desc: '',
      args: [],
    );
  }

  /// `Tokens`
  String get g_token_m_key_11 {
    return Intl.message('Tokens', name: 'g_token_m_key_11', desc: '', args: []);
  }

  /// `Search Token`
  String get g_token_m_key_12 {
    return Intl.message(
      'Search Token',
      name: 'g_token_m_key_12',
      desc: '',
      args: [],
    );
  }

  /// `Chain Name`
  String get g_token_m_key_13 {
    return Intl.message(
      'Chain Name',
      name: 'g_token_m_key_13',
      desc: '',
      args: [],
    );
  }

  /// `Chain symbol`
  String get g_token_m_key_14 {
    return Intl.message(
      'Chain symbol',
      name: 'g_token_m_key_14',
      desc: '',
      args: [],
    );
  }

  /// `Chain ID`
  String get g_token_m_key_15 {
    return Intl.message(
      'Chain ID',
      name: 'g_token_m_key_15',
      desc: '',
      args: [],
    );
  }

  /// `Decimal`
  String get g_token_m_key_16 {
    return Intl.message(
      'Decimal',
      name: 'g_token_m_key_16',
      desc: '',
      args: [],
    );
  }

  /// `RPC`
  String get g_token_m_key_17 {
    return Intl.message('RPC', name: 'g_token_m_key_17', desc: '', args: []);
  }

  /// `API`
  String get g_token_m_key_18 {
    return Intl.message('API', name: 'g_token_m_key_18', desc: '', args: []);
  }

  /// `Add custom chain`
  String get g_token_m_key_19 {
    return Intl.message(
      'Add custom chain',
      name: 'g_token_m_key_19',
      desc: '',
      args: [],
    );
  }

  /// `Add Tokens`
  String get g_token_m_key_20 {
    return Intl.message(
      'Add Tokens',
      name: 'g_token_m_key_20',
      desc: '',
      args: [],
    );
  }

  /// `Format Error!`
  String get g_token_m_key_21 {
    return Intl.message(
      'Format Error!',
      name: 'g_token_m_key_21',
      desc: '',
      args: [],
    );
  }

  /// `{value} chain APP is already supported!`
  String g_token_m_key_22(Object value) {
    return Intl.message(
      '$value chain APP is already supported!',
      name: 'g_token_m_key_22',
      desc: '',
      args: [value],
    );
  }

  /// `{value} chain APP is already supported, do you want to add it?`
  String g_token_m_key_23(Object value) {
    return Intl.message(
      '$value chain APP is already supported, do you want to add it?',
      name: 'g_token_m_key_23',
      desc: '',
      args: [value],
    );
  }

  /// `{value} address test link failed!`
  String g_token_m_key_24(Object value) {
    return Intl.message(
      '$value address test link failed!',
      name: 'g_token_m_key_24',
      desc: '',
      args: [value],
    );
  }

  /// `Tokens can only be sent within the same network. Sending from other networks may result in loss.`
  String get g_app_share_key_1 {
    return Intl.message(
      'Tokens can only be sent within the same network. Sending from other networks may result in loss.',
      name: 'g_app_share_key_1',
      desc: '',
      args: [],
    );
  }

  /// `Scan to receive`
  String get g_app_share_key_2 {
    return Intl.message(
      'Scan to receive',
      name: 'g_app_share_key_2',
      desc: '',
      args: [],
    );
  }

  /// `Market Cap`
  String get g_key_m_2 {
    return Intl.message('Market Cap', name: 'g_key_m_2', desc: '', args: []);
  }

  /// `Trading Volume`
  String get g_key_m_3 {
    return Intl.message(
      'Trading Volume',
      name: 'g_key_m_3',
      desc: '',
      args: [],
    );
  }

  /// `Total Supply`
  String get g_key_m_4 {
    return Intl.message('Total Supply', name: 'g_key_m_4', desc: '', args: []);
  }

  /// `In Circulation`
  String get g_key_m_5 {
    return Intl.message(
      'In Circulation',
      name: 'g_key_m_5',
      desc: '',
      args: [],
    );
  }

  /// `About`
  String get g_key_m_6 {
    return Intl.message('About', name: 'g_key_m_6', desc: '', args: []);
  }

  /// `More`
  String get g_key_m_7 {
    return Intl.message('More', name: 'g_key_m_7', desc: '', args: []);
  }

  /// `Links`
  String get g_key_m_8 {
    return Intl.message('Links', name: 'g_key_m_8', desc: '', args: []);
  }

  /// `Website`
  String get g_key_m_9 {
    return Intl.message('Website', name: 'g_key_m_9', desc: '', args: []);
  }

  /// `Facebook`
  String get g_key_m_10 {
    return Intl.message('Facebook', name: 'g_key_m_10', desc: '', args: []);
  }

  /// `Twitter`
  String get g_key_m_11 {
    return Intl.message('Twitter', name: 'g_key_m_11', desc: '', args: []);
  }

  /// `Reddit`
  String get g_key_m_14 {
    return Intl.message('Reddit', name: 'g_key_m_14', desc: '', args: []);
  }

  /// `Browser`
  String get g_key_m_15 {
    return Intl.message('Browser', name: 'g_key_m_15', desc: '', args: []);
  }

  /// `Telegram`
  String get g_key_m_16 {
    return Intl.message('Telegram', name: 'g_key_m_16', desc: '', args: []);
  }

  /// `Discord`
  String get g_key_m_17 {
    return Intl.message('Discord', name: 'g_key_m_17', desc: '', args: []);
  }

  /// `Youtube`
  String get g_key_m_18 {
    return Intl.message('Youtube', name: 'g_key_m_18', desc: '', args: []);
  }

  /// `Instagram`
  String get g_key_m_19 {
    return Intl.message('Instagram', name: 'g_key_m_19', desc: '', args: []);
  }

  /// `Complete`
  String get g_key_t_1 {
    return Intl.message('Complete', name: 'g_key_t_1', desc: '', args: []);
  }

  /// `Pending`
  String get g_key_t_2 {
    return Intl.message('Pending', name: 'g_key_t_2', desc: '', args: []);
  }

  /// `Failure`
  String get g_key_t_3 {
    return Intl.message('Failure', name: 'g_key_t_3', desc: '', args: []);
  }

  /// `Transfer out`
  String get g_key_t_4 {
    return Intl.message('Transfer out', name: 'g_key_t_4', desc: '', args: []);
  }

  /// `Transfer in`
  String get g_key_t_5 {
    return Intl.message('Transfer in', name: 'g_key_t_5', desc: '', args: []);
  }

  /// `Gas Used`
  String get g_key_t_6 {
    return Intl.message('Gas Used', name: 'g_key_t_6', desc: '', args: []);
  }

  /// `Gas`
  String get g_key_t_7 {
    return Intl.message('Gas', name: 'g_key_t_7', desc: '', args: []);
  }

  /// `Gas price`
  String get g_key_t_15 {
    return Intl.message('Gas price', name: 'g_key_t_15', desc: '', args: []);
  }

  /// `Max gas fee`
  String get g_key_t_16 {
    return Intl.message('Max gas fee', name: 'g_key_t_16', desc: '', args: []);
  }

  /// `Max fee per gas`
  String get g_key_t_17 {
    return Intl.message(
      'Max fee per gas',
      name: 'g_key_t_17',
      desc: '',
      args: [],
    );
  }

  /// `You do not have enough "{value}"`
  String g_key_t_29(Object value) {
    return Intl.message(
      'You do not have enough "$value"',
      name: 'g_key_t_29',
      desc: '',
      args: [value],
    );
  }

  /// `Miner Fee`
  String get g_key_t_30 {
    return Intl.message('Miner Fee', name: 'g_key_t_30', desc: '', args: []);
  }

  /// `Proceed`
  String get g_key_t_31 {
    return Intl.message('Proceed', name: 'g_key_t_31', desc: '', args: []);
  }

  /// `Wallet password`
  String get g_key_t_32 {
    return Intl.message(
      'Wallet password',
      name: 'g_key_t_32',
      desc: '',
      args: [],
    );
  }

  /// `Wallet password cannot be empty`
  String get g_key_t_33 {
    return Intl.message(
      'Wallet password cannot be empty',
      name: 'g_key_t_33',
      desc: '',
      args: [],
    );
  }

  /// `Wrong wallet password`
  String get g_key_t_34 {
    return Intl.message(
      'Wrong wallet password',
      name: 'g_key_t_34',
      desc: '',
      args: [],
    );
  }

  /// `Please enter wallet password`
  String get g_key_t_35 {
    return Intl.message(
      'Please enter wallet password',
      name: 'g_key_t_35',
      desc: '',
      args: [],
    );
  }

  /// `Gas Fee Rate`
  String get g_key_t_36 {
    return Intl.message('Gas Fee Rate', name: 'g_key_t_36', desc: '', args: []);
  }

  /// `The latest block Gas Fee Rate average`
  String get g_key_t_37 {
    return Intl.message(
      'The latest block Gas Fee Rate average',
      name: 'g_key_t_37',
      desc: '',
      args: [],
    );
  }

  /// `Enter a whole number greater than 0.`
  String get g_key_t_43 {
    return Intl.message(
      'Enter a whole number greater than 0.',
      name: 'g_key_t_43',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get data`
  String get g_key_t_44 {
    return Intl.message(
      'Failed to get data',
      name: 'g_key_t_44',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get "{value}" account`
  String g_key_t_45(Object value) {
    return Intl.message(
      'Failed to get "$value" account',
      name: 'g_key_t_45',
      desc: '',
      args: [value],
    );
  }

  /// `Check receiving address account`
  String get g_key_t_46 {
    return Intl.message(
      'Check receiving address account',
      name: 'g_key_t_46',
      desc: '',
      args: [],
    );
  }

  /// `Find`
  String get g_key_t_47 {
    return Intl.message('Find', name: 'g_key_t_47', desc: '', args: []);
  }

  /// `No account`
  String get g_key_t_49 {
    return Intl.message('No account', name: 'g_key_t_49', desc: '', args: []);
  }

  /// `Invalid address`
  String get g_key_t_50 {
    return Intl.message(
      'Invalid address',
      name: 'g_key_t_50',
      desc: '',
      args: [],
    );
  }

  /// `Account verification succeeded`
  String get g_key_t_51 {
    return Intl.message(
      'Account verification succeeded',
      name: 'g_key_t_51',
      desc: '',
      args: [],
    );
  }

  /// `Minimum {value} XRP for first transfer`
  String g_key_t_52(Object value) {
    return Intl.message(
      'Minimum $value XRP for first transfer',
      name: 'g_key_t_52',
      desc: '',
      args: [value],
    );
  }

  /// `The receiving address does not have an account, and the first transfer is at least 10XRP`
  String get g_key_t_54 {
    return Intl.message(
      'The receiving address does not have an account, and the first transfer is at least 10XRP',
      name: 'g_key_t_54',
      desc: '',
      args: [],
    );
  }

  /// `Profile`
  String get g_home_key1 {
    return Intl.message('Profile', name: 'g_home_key1', desc: '', args: []);
  }

  /// `News`
  String get g_home_key2 {
    return Intl.message('News', name: 'g_home_key2', desc: '', args: []);
  }

  /// `Verification`
  String get g_home_key3 {
    return Intl.message(
      'Verification',
      name: 'g_home_key3',
      desc: '',
      args: [],
    );
  }

  /// `Messages`
  String get g_home_key5 {
    return Intl.message('Messages', name: 'g_home_key5', desc: '', args: []);
  }

  /// `Learn`
  String get g_home_key6 {
    return Intl.message('Learn', name: 'g_home_key6', desc: '', args: []);
  }

  /// `Invite a friend`
  String get g_home_key9 {
    return Intl.message(
      'Invite a friend',
      name: 'g_home_key9',
      desc: '',
      args: [],
    );
  }

  /// `Referral code`
  String get login_invite_code {
    return Intl.message(
      'Referral code',
      name: 'login_invite_code',
      desc: '',
      args: [],
    );
  }

  /// `Referral code`
  String get login_invite_code_title {
    return Intl.message(
      'Referral code',
      name: 'login_invite_code_title',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get login_email {
    return Intl.message('Email', name: 'login_email', desc: '', args: []);
  }

  /// `Sign in`
  String get login_button_text {
    return Intl.message(
      'Sign in',
      name: 'login_button_text',
      desc: '',
      args: [],
    );
  }

  /// `Forgot password?`
  String get login_forgot_password {
    return Intl.message(
      'Forgot password?',
      name: 'login_forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Don’t have an account? `
  String get login_message_1 {
    return Intl.message(
      'Don’t have an account? ',
      name: 'login_message_1',
      desc: '',
      args: [],
    );
  }

  /// `Already have an account? `
  String get login_message_2 {
    return Intl.message(
      'Already have an account? ',
      name: 'login_message_2',
      desc: '',
      args: [],
    );
  }

  /// `Resend code in `
  String get login_message_6 {
    return Intl.message(
      'Resend code in ',
      name: 'login_message_6',
      desc: '',
      args: [],
    );
  }

  /// `please log in first`
  String get login_need_login {
    return Intl.message(
      'please log in first',
      name: 'login_need_login',
      desc: '',
      args: [],
    );
  }

  /// `Code sent successfully`
  String get login_message_7 {
    return Intl.message(
      'Code sent successfully',
      name: 'login_message_7',
      desc: '',
      args: [],
    );
  }

  /// `E-mail unregistered`
  String get login_message_8 {
    return Intl.message(
      'E-mail unregistered',
      name: 'login_message_8',
      desc: '',
      args: [],
    );
  }

  /// `Failed to send code`
  String get login_message_9 {
    return Intl.message(
      'Failed to send code',
      name: 'login_message_9',
      desc: '',
      args: [],
    );
  }

  /// `Created successfully`
  String get login_message_10 {
    return Intl.message(
      'Created successfully',
      name: 'login_message_10',
      desc: '',
      args: [],
    );
  }

  /// `Reset successfully`
  String get login_message_11 {
    return Intl.message(
      'Reset successfully',
      name: 'login_message_11',
      desc: '',
      args: [],
    );
  }

  /// `I have read and accepted the `
  String get g_key_user_p1 {
    return Intl.message(
      'I have read and accepted the ',
      name: 'g_key_user_p1',
      desc: '',
      args: [],
    );
  }

  /// `Terms & Conditions`
  String get g_key_user_p2 {
    return Intl.message(
      'Terms & Conditions',
      name: 'g_key_user_p2',
      desc: '',
      args: [],
    );
  }

  /// `Privacy Policy and Personal Information Collection Statement`
  String get g_key_user_p3 {
    return Intl.message(
      'Privacy Policy and Personal Information Collection Statement',
      name: 'g_key_user_p3',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get g_coin_key_1 {
    return Intl.message(
      'Transactions',
      name: 'g_coin_key_1',
      desc: '',
      args: [],
    );
  }

  /// `Notifications`
  String get g_notification_key_1 {
    return Intl.message(
      'Notifications',
      name: 'g_notification_key_1',
      desc: '',
      args: [],
    );
  }

  /// `Verification Status`
  String get g_mining_key_5 {
    return Intl.message(
      'Verification Status',
      name: 'g_mining_key_5',
      desc: '',
      args: [],
    );
  }

  /// `Lock N to start verifying rewards.`
  String get g_mining_key_6 {
    return Intl.message(
      'Lock N to start verifying rewards.',
      name: 'g_mining_key_6',
      desc: '',
      args: [],
    );
  }

  /// `Select a Plan`
  String get g_mining_key_7 {
    return Intl.message(
      'Select a Plan',
      name: 'g_mining_key_7',
      desc: '',
      args: [],
    );
  }

  /// `Background Verification`
  String get g_mining_key_9 {
    return Intl.message(
      'Background Verification',
      name: 'g_mining_key_9',
      desc: '',
      args: [],
    );
  }

  /// `Today's reward`
  String get g_mining_key_10 {
    return Intl.message(
      'Today\'s reward',
      name: 'g_mining_key_10',
      desc: '',
      args: [],
    );
  }

  /// `Yesterday’s Rewards`
  String get g_mining_key_11 {
    return Intl.message(
      'Yesterday’s Rewards',
      name: 'g_mining_key_11',
      desc: '',
      args: [],
    );
  }

  /// `Reward accumulates daily and is only sent to your N wallet when it reaches ~0.5 N.`
  String get g_mining_key_12 {
    return Intl.message(
      'Reward accumulates daily and is only sent to your N wallet when it reaches ~0.5 N.',
      name: 'g_mining_key_12',
      desc: '',
      args: [],
    );
  }

  /// `Total Rewards`
  String get g_mining_key_13 {
    return Intl.message(
      'Total Rewards',
      name: 'g_mining_key_13',
      desc: '',
      args: [],
    );
  }

  /// `Mined Value`
  String get g_mining_key_14 {
    return Intl.message(
      'Mined Value',
      name: 'g_mining_key_14',
      desc: '',
      args: [],
    );
  }

  /// `Calculated based on market price of N * the total N rewards.`
  String get g_mining_key_15 {
    return Intl.message(
      'Calculated based on market price of N * the total N rewards.',
      name: 'g_mining_key_15',
      desc: '',
      args: [],
    );
  }

  /// `Profit count`
  String get g_mining_key_23 {
    return Intl.message(
      'Profit count',
      name: 'g_mining_key_23',
      desc: '',
      args: [],
    );
  }

  /// `Select Plans`
  String get g_mining_key_31 {
    return Intl.message(
      'Select Plans',
      name: 'g_mining_key_31',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Period: Unlockable at any time`
  String get g_mining_key_32 {
    return Intl.message(
      'Unlock Period: Unlockable at any time',
      name: 'g_mining_key_32',
      desc: '',
      args: [],
    );
  }

  /// `Unlock Period:`
  String get g_mining_unlock_period {
    return Intl.message(
      'Unlock Period:',
      name: 'g_mining_unlock_period',
      desc: '',
      args: [],
    );
  }

  /// `Unlockable at any time`
  String get g_mining_unlockable_anytime {
    return Intl.message(
      'Unlockable at any time',
      name: 'g_mining_unlockable_anytime',
      desc: '',
      args: [],
    );
  }

  /// `Max Reward Annually`
  String get g_mining_key_33 {
    return Intl.message(
      'Max Reward Annually',
      name: 'g_mining_key_33',
      desc: '',
      args: [],
    );
  }

  /// `Reward Distribution`
  String get g_mining_key_34 {
    return Intl.message(
      'Reward Distribution',
      name: 'g_mining_key_34',
      desc: '',
      args: [],
    );
  }

  /// `Daily Limit`
  String get g_mining_key_35 {
    return Intl.message(
      'Daily Limit',
      name: 'g_mining_key_35',
      desc: '',
      args: [],
    );
  }

  /// `Speed`
  String get g_mining_key_36 {
    return Intl.message('Speed', name: 'g_mining_key_36', desc: '', args: []);
  }

  /// `Verification Plans`
  String get g_mining_key_37 {
    return Intl.message(
      'Verification Plans',
      name: 'g_mining_key_37',
      desc: '',
      args: [],
    );
  }

  /// `Select the payment method`
  String get g_mining_key_38 {
    return Intl.message(
      'Select the payment method',
      name: 'g_mining_key_38',
      desc: '',
      args: [],
    );
  }

  /// `Payment Methods`
  String get g_mining_key_39 {
    return Intl.message(
      'Payment Methods',
      name: 'g_mining_key_39',
      desc: '',
      args: [],
    );
  }

  /// `Pay using N`
  String get g_mining_key_40 {
    return Intl.message(
      'Pay using N',
      name: 'g_mining_key_40',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Balance`
  String get g_mining_key_42 {
    return Intl.message(
      'Wallet Balance',
      name: 'g_mining_key_42',
      desc: '',
      args: [],
    );
  }

  /// `You do not have enough N for this transaction`
  String get g_mining_key_43 {
    return Intl.message(
      'You do not have enough N for this transaction',
      name: 'g_mining_key_43',
      desc: '',
      args: [],
    );
  }

  /// `Disabled`
  String get g_mining_key_47 {
    return Intl.message(
      'Disabled',
      name: 'g_mining_key_47',
      desc: '',
      args: [],
    );
  }

  /// `View more`
  String get g_mining_key_49 {
    return Intl.message(
      'View more',
      name: 'g_mining_key_49',
      desc: '',
      args: [],
    );
  }

  /// `Entry`
  String get g_mining_key_62 {
    return Intl.message('Entry', name: 'g_mining_key_62', desc: '', args: []);
  }

  /// `Advanced Node`
  String get g_mining_key_66 {
    return Intl.message(
      'Advanced Node',
      name: 'g_mining_key_66',
      desc: '',
      args: [],
    );
  }

  /// `Entry Node`
  String get g_mining_key_67 {
    return Intl.message(
      'Entry Node',
      name: 'g_mining_key_67',
      desc: '',
      args: [],
    );
  }

  /// `Pro Node`
  String get g_mining_key_68 {
    return Intl.message(
      'Pro Node',
      name: 'g_mining_key_68',
      desc: '',
      args: [],
    );
  }

  /// `500 blocks/day~70 mins`
  String get g_mining_key_69 {
    return Intl.message(
      '500 blocks/day~70 mins',
      name: 'g_mining_key_69',
      desc: '',
      args: [],
    );
  }

  /// `100 blocks/day~15 mins`
  String get g_mining_key_70 {
    return Intl.message(
      '100 blocks/day~15 mins',
      name: 'g_mining_key_70',
      desc: '',
      args: [],
    );
  }

  /// `{value} N every {value1} blocks mined`
  String g_mining_key_71(Object value, Object value1) {
    return Intl.message(
      '$value N every $value1 blocks mined',
      name: 'g_mining_key_71',
      desc: '',
      args: [value, value1],
    );
  }

  /// `128 seconds per check`
  String get g_mining_key_72 {
    return Intl.message(
      '128 seconds per check',
      name: 'g_mining_key_72',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Verification Started`
  String get g_mining_key_73 {
    return Intl.message(
      'Cloud Verification Started',
      name: 'g_mining_key_73',
      desc: '',
      args: [],
    );
  }

  /// `The test chain is being upgraded and blocks cannot be verified temporarily.`
  String get g_mining_key_74 {
    return Intl.message(
      'The test chain is being upgraded and blocks cannot be verified temporarily.',
      name: 'g_mining_key_74',
      desc: '',
      args: [],
    );
  }

  /// `Failing to complete tasks for four consecutive days will result in no earnings and a risk of penalty.`
  String get g_mining_key_75 {
    return Intl.message(
      'Failing to complete tasks for four consecutive days will result in no earnings and a risk of penalty.',
      name: 'g_mining_key_75',
      desc: '',
      args: [],
    );
  }

  /// `Risk Score`
  String get g_mining_key_76 {
    return Intl.message(
      'Risk Score',
      name: 'g_mining_key_76',
      desc: '',
      args: [],
    );
  }

  /// `Redeem`
  String get g_mining_key_77 {
    return Intl.message('Redeem', name: 'g_mining_key_77', desc: '', args: []);
  }

  /// `Please save the verifier's public and private key pair first.`
  String get g_mining_key_78 {
    return Intl.message(
      'Please save the verifier\'s public and private key pair first.',
      name: 'g_mining_key_78',
      desc: '',
      args: [],
    );
  }

  /// `Export`
  String get g_mining_key_79 {
    return Intl.message('Export', name: 'g_mining_key_79', desc: '', args: []);
  }

  /// `Insufficient funds for transfer.`
  String get g_mining_key_80 {
    return Intl.message(
      'Insufficient funds for transfer.',
      name: 'g_mining_key_80',
      desc: '',
      args: [],
    );
  }

  /// `Validator List`
  String get g_mining_key_81 {
    return Intl.message(
      'Validator List',
      name: 'g_mining_key_81',
      desc: '',
      args: [],
    );
  }

  /// `Import validator`
  String get g_mining_key_82 {
    return Intl.message(
      'Import validator',
      name: 'g_mining_key_82',
      desc: '',
      args: [],
    );
  }

  /// `The validator already exists`
  String get g_mining_key_83 {
    return Intl.message(
      'The validator already exists',
      name: 'g_mining_key_83',
      desc: '',
      args: [],
    );
  }

  /// `Low Risk`
  String get g_mining_key_84 {
    return Intl.message(
      'Low Risk',
      name: 'g_mining_key_84',
      desc: '',
      args: [],
    );
  }

  /// `Moderately Risk`
  String get g_mining_key_85 {
    return Intl.message(
      'Moderately Risk',
      name: 'g_mining_key_85',
      desc: '',
      args: [],
    );
  }

  /// `7-Day Rewards`
  String get g_mining_key_86 {
    return Intl.message(
      '7-Day Rewards',
      name: 'g_mining_key_86',
      desc: '',
      args: [],
    );
  }

  /// `High Risk`
  String get g_mining_key_87 {
    return Intl.message(
      'High Risk',
      name: 'g_mining_key_87',
      desc: '',
      args: [],
    );
  }

  /// `The contract is loading and cannot be verified at this time. Please wait a moment!`
  String get g_mining_key_88 {
    return Intl.message(
      'The contract is loading and cannot be verified at this time. Please wait a moment!',
      name: 'g_mining_key_88',
      desc: '',
      args: [],
    );
  }

  /// `Safety Tips`
  String get g_mining_key_89 {
    return Intl.message(
      'Safety Tips',
      name: 'g_mining_key_89',
      desc: '',
      args: [],
    );
  }

  /// `Please keep your private key or mnemonic phrase safe.`
  String get g_mining_key_90 {
    return Intl.message(
      'Please keep your private key or mnemonic phrase safe.',
      name: 'g_mining_key_90',
      desc: '',
      args: [],
    );
  }

  /// `Your private key or mnemonic phrase is the only credential for accessing your wallet assets.`
  String get g_mining_key_91 {
    return Intl.message(
      'Your private key or mnemonic phrase is the only credential for accessing your wallet assets.',
      name: 'g_mining_key_91',
      desc: '',
      args: [],
    );
  }

  /// `Please keep it in a safe place (paper, password manager, etc.).`
  String get g_mining_key_92 {
    return Intl.message(
      'Please keep it in a safe place (paper, password manager, etc.).',
      name: 'g_mining_key_92',
      desc: '',
      args: [],
    );
  }

  /// `Do not take screenshots, upload them to the internet, or share them with anyone.`
  String get g_mining_key_93 {
    return Intl.message(
      'Do not take screenshots, upload them to the internet, or share them with anyone.',
      name: 'g_mining_key_93',
      desc: '',
      args: [],
    );
  }

  /// `Once lost or compromised, your wallet assets cannot be recovered.`
  String get g_mining_key_94 {
    return Intl.message(
      'Once lost or compromised, your wallet assets cannot be recovered.',
      name: 'g_mining_key_94',
      desc: '',
      args: [],
    );
  }

  /// `Confirm and save`
  String get g_mining_key_95 {
    return Intl.message(
      'Confirm and save',
      name: 'g_mining_key_95',
      desc: '',
      args: [],
    );
  }

  /// `Set a password and encrypt`
  String get g_mining_key_96 {
    return Intl.message(
      'Set a password and encrypt',
      name: 'g_mining_key_96',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the encryption password`
  String get g_mining_key_97 {
    return Intl.message(
      'Please enter the encryption password',
      name: 'g_mining_key_97',
      desc: '',
      args: [],
    );
  }

  /// `Must be {value} characters`
  String g_mining_key_98(Object value) {
    return Intl.message(
      'Must be $value characters',
      name: 'g_mining_key_98',
      desc: '',
      args: [value],
    );
  }

  /// `Please re-enter your password to ensure it's correct`
  String get g_mining_key_99 {
    return Intl.message(
      'Please re-enter your password to ensure it\'s correct',
      name: 'g_mining_key_99',
      desc: '',
      args: [],
    );
  }

  /// `Please treat the data below as an important key. We recommend copying and backing it up to a trusted location immediately.`
  String get g_mining_key_100 {
    return Intl.message(
      'Please treat the data below as an important key. We recommend copying and backing it up to a trusted location immediately.',
      name: 'g_mining_key_100',
      desc: '',
      args: [],
    );
  }

  /// `Copy Data`
  String get g_mining_key_101 {
    return Intl.message(
      'Copy Data',
      name: 'g_mining_key_101',
      desc: '',
      args: [],
    );
  }

  /// `Inactive`
  String get g_mining_key_102 {
    return Intl.message(
      'Inactive',
      name: 'g_mining_key_102',
      desc: '',
      args: [],
    );
  }

  /// `Validator List`
  String get g_mining_key_103 {
    return Intl.message(
      'Validator List',
      name: 'g_mining_key_103',
      desc: '',
      args: [],
    );
  }

  /// `Import successful`
  String get g_mining_key_104 {
    return Intl.message(
      'Import successful',
      name: 'g_mining_key_104',
      desc: '',
      args: [],
    );
  }

  /// `Encrypted data cannot be empty!`
  String get g_mining_key_105 {
    return Intl.message(
      'Encrypted data cannot be empty!',
      name: 'g_mining_key_105',
      desc: '',
      args: [],
    );
  }

  /// `Password cannot be empty!`
  String get g_mining_key_106 {
    return Intl.message(
      'Password cannot be empty!',
      name: 'g_mining_key_106',
      desc: '',
      args: [],
    );
  }

  /// `Decryption failed. Please check if the password is correct!`
  String get g_mining_key_107 {
    return Intl.message(
      'Decryption failed. Please check if the password is correct!',
      name: 'g_mining_key_107',
      desc: '',
      args: [],
    );
  }

  /// `Unsupported encrypted data format!`
  String get g_mining_key_108 {
    return Intl.message(
      'Unsupported encrypted data format!',
      name: 'g_mining_key_108',
      desc: '',
      args: [],
    );
  }

  /// `Import failed:{value}`
  String g_mining_key_109(Object value) {
    return Intl.message(
      'Import failed:$value',
      name: 'g_mining_key_109',
      desc: '',
      args: [value],
    );
  }

  /// `Encrypted data`
  String get g_mining_key_110 {
    return Intl.message(
      'Encrypted data',
      name: 'g_mining_key_110',
      desc: '',
      args: [],
    );
  }

  /// `Import files`
  String get g_mining_key_111 {
    return Intl.message(
      'Import files',
      name: 'g_mining_key_111',
      desc: '',
      args: [],
    );
  }

  /// `Please enter encrypted data.`
  String get g_mining_key_112 {
    return Intl.message(
      'Please enter encrypted data.',
      name: 'g_mining_key_112',
      desc: '',
      args: [],
    );
  }

  /// `Importing...`
  String get g_mining_key_113 {
    return Intl.message(
      'Importing...',
      name: 'g_mining_key_113',
      desc: '',
      args: [],
    );
  }

  /// `Confirmation`
  String get g_mining_key_114 {
    return Intl.message(
      'Confirmation',
      name: 'g_mining_key_114',
      desc: '',
      args: [],
    );
  }

  /// `Redemption takes some time, please wait a moment!`
  String get g_mining_key_115 {
    return Intl.message(
      'Redemption takes some time, please wait a moment!',
      name: 'g_mining_key_115',
      desc: '',
      args: [],
    );
  }

  /// `A staking balance of at least {value} is required to earn rewards.`
  String g_mining_key_116(Object value) {
    return Intl.message(
      'A staking balance of at least $value is required to earn rewards.',
      name: 'g_mining_key_116',
      desc: '',
      args: [value],
    );
  }

  /// `Unlock N?`
  String get g_mining_key20 {
    return Intl.message(
      'Unlock N?',
      name: 'g_mining_key20',
      desc: '',
      args: [],
    );
  }

  /// `Cloud Verification Activity`
  String get g_mining_key31 {
    return Intl.message(
      'Cloud Verification Activity',
      name: 'g_mining_key31',
      desc: '',
      args: [],
    );
  }

  /// `Setup requires a small amount for gas.`
  String get g_mining_key46 {
    return Intl.message(
      'Setup requires a small amount for gas.',
      name: 'g_mining_key46',
      desc: '',
      args: [],
    );
  }

  /// `You have successfully joined a Group Node on N42Wallet. Share the link to invite friends, activate the Node and start verification!`
  String get g_mining_key60 {
    return Intl.message(
      'You have successfully joined a Group Node on N42Wallet. Share the link to invite friends, activate the Node and start verification!',
      name: 'g_mining_key60',
      desc: '',
      args: [],
    );
  }

  /// `Share to friends`
  String get g_mining_key61 {
    return Intl.message(
      'Share to friends',
      name: 'g_mining_key61',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get g_mining_key62 {
    return Intl.message('Continue', name: 'g_mining_key62', desc: '', args: []);
  }

  /// `You have successfully set up a {value} and will begin verification with N42Wallet!`
  String g_mining_key63(Object value) {
    return Intl.message(
      'You have successfully set up a $value and will begin verification with N42Wallet!',
      name: 'g_mining_key63',
      desc: '',
      args: [value],
    );
  }

  /// `Join my {value} group on @N42Wallet to be an early miner of a Layer 1 chain, and get crypto on your phone!`
  String g_mining_key73(Object value) {
    return Intl.message(
      'Join my $value group on @N42Wallet to be an early miner of a Layer 1 chain, and get crypto on your phone!',
      name: 'g_mining_key73',
      desc: '',
      args: [value],
    );
  }

  /// `I just set up a node on @N42Wallet and started verification on mobile devices! Come and join me. The decentralized future is mobile!`
  String get g_mining_key74 {
    return Intl.message(
      'I just set up a node on @N42Wallet and started verification on mobile devices! Come and join me. The decentralized future is mobile!',
      name: 'g_mining_key74',
      desc: '',
      args: [],
    );
  }

  /// `Lock {value} N to run a validator.`
  String g_mining_key76(Object value) {
    return Intl.message(
      'Lock $value N to run a validator.',
      name: 'g_mining_key76',
      desc: '',
      args: [value],
    );
  }

  /// `Redemption available after 768s.`
  String get g_mining_key86 {
    return Intl.message(
      'Redemption available after 768s.',
      name: 'g_mining_key86',
      desc: '',
      args: [],
    );
  }

  /// `Requests before that will not be processed.`
  String get g_mining_key87 {
    return Intl.message(
      'Requests before that will not be processed.',
      name: 'g_mining_key87',
      desc: '',
      args: [],
    );
  }

  /// `Time`
  String get g_key_wallet_k25 {
    return Intl.message('Time', name: 'g_key_wallet_k25', desc: '', args: []);
  }

  /// `Result`
  String get g_key_wallet_k33 {
    return Intl.message('Result', name: 'g_key_wallet_k33', desc: '', args: []);
  }

  /// `Transaction hash`
  String get g_key_wallet_k37 {
    return Intl.message(
      'Transaction hash',
      name: 'g_key_wallet_k37',
      desc: '',
      args: [],
    );
  }

  /// `Add`
  String get g_key_wallet_k47 {
    return Intl.message('Add', name: 'g_key_wallet_k47', desc: '', args: []);
  }

  /// `Path`
  String get g_key_wallet_k53 {
    return Intl.message('Path', name: 'g_key_wallet_k53', desc: '', args: []);
  }

  /// `Block`
  String get g_key_wallet_k54 {
    return Intl.message('Block', name: 'g_key_wallet_k54', desc: '', args: []);
  }

  /// `Value`
  String get g_key_wallet_k55 {
    return Intl.message('Value', name: 'g_key_wallet_k55', desc: '', args: []);
  }

  /// `Nonce`
  String get g_key_wallet_k56 {
    return Intl.message('Nonce', name: 'g_key_wallet_k56', desc: '', args: []);
  }

  /// `Accelerate`
  String get g_key_wallet_k57 {
    return Intl.message(
      'Accelerate',
      name: 'g_key_wallet_k57',
      desc: '',
      args: [],
    );
  }

  /// `Note`
  String get g_key_wallet_k58 {
    return Intl.message('Note', name: 'g_key_wallet_k58', desc: '', args: []);
  }

  /// `No {value} chain added.`
  String g_key_wallet_m1(Object value) {
    return Intl.message(
      'No $value chain added.',
      name: 'g_key_wallet_m1',
      desc: '',
      args: [value],
    );
  }

  /// `The current token has not been added.`
  String get g_key_wallet_m2 {
    return Intl.message(
      'The current token has not been added.',
      name: 'g_key_wallet_m2',
      desc: '',
      args: [],
    );
  }

  /// `No address found for {value}.`
  String g_key_wallet_m3(Object value) {
    return Intl.message(
      'No address found for $value.',
      name: 'g_key_wallet_m3',
      desc: '',
      args: [value],
    );
  }

  /// `The current token balance is insufficient.`
  String get g_key_wallet_m4 {
    return Intl.message(
      'The current token balance is insufficient.',
      name: 'g_key_wallet_m4',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance of {value}.`
  String g_key_wallet_m5(Object value) {
    return Intl.message(
      'Insufficient balance of $value.',
      name: 'g_key_wallet_m5',
      desc: '',
      args: [value],
    );
  }

  /// `Signing error`
  String get g_key_wallet_m6 {
    return Intl.message(
      'Signing error',
      name: 'g_key_wallet_m6',
      desc: '',
      args: [],
    );
  }

  /// `Account cancellation`
  String get g_key_wallet_m8 {
    return Intl.message(
      'Account cancellation',
      name: 'g_key_wallet_m8',
      desc: '',
      args: [],
    );
  }

  /// `Enter email verification code.`
  String get g_key_wallet_m9 {
    return Intl.message(
      'Enter email verification code.',
      name: 'g_key_wallet_m9',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to cancel your account?`
  String get g_key_wallet_m11 {
    return Intl.message(
      'Are you sure you want to cancel your account?',
      name: 'g_key_wallet_m11',
      desc: '',
      args: [],
    );
  }

  /// `Confirm logout`
  String get g_key_wallet_m13 {
    return Intl.message(
      'Confirm logout',
      name: 'g_key_wallet_m13',
      desc: '',
      args: [],
    );
  }

  /// `Please enter Google verification code.`
  String get g_key_wallet_m17 {
    return Intl.message(
      'Please enter Google verification code.',
      name: 'g_key_wallet_m17',
      desc: '',
      args: [],
    );
  }

  /// `{value} has unfinished transactions, please try again later.`
  String g_key_wallet_m19(Object value) {
    return Intl.message(
      '$value has unfinished transactions, please try again later.',
      name: 'g_key_wallet_m19',
      desc: '',
      args: [value],
    );
  }

  /// `Enter your seed phrase with words separated by spaces`
  String get g_key_wallet_m21 {
    return Intl.message(
      'Enter your seed phrase with words separated by spaces',
      name: 'g_key_wallet_m21',
      desc: '',
      args: [],
    );
  }

  /// `Import Wallet`
  String get g_key_wallet_m22 {
    return Intl.message(
      'Import Wallet',
      name: 'g_key_wallet_m22',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get g_key_wallet_c4 {
    return Intl.message('Start', name: 'g_key_wallet_c4', desc: '', args: []);
  }

  /// `Check Seed Phrase`
  String get g_key_wallet_c6 {
    return Intl.message(
      'Check Seed Phrase',
      name: 'g_key_wallet_c6',
      desc: '',
      args: [],
    );
  }

  /// `Now enter your seed phrase.`
  String get g_key_wallet_c7 {
    return Intl.message(
      'Now enter your seed phrase.',
      name: 'g_key_wallet_c7',
      desc: '',
      args: [],
    );
  }

  /// `Set Phrase`
  String get g_key_wallet_c8 {
    return Intl.message(
      'Set Phrase',
      name: 'g_key_wallet_c8',
      desc: '',
      args: [],
    );
  }

  /// `Please make sure you record your seed phrase and store it safely. You'll need it to import or recover your cryptocurrency wallet.`
  String get g_key_wallet_c9 {
    return Intl.message(
      'Please make sure you record your seed phrase and store it safely. You\'ll need it to import or recover your cryptocurrency wallet.',
      name: 'g_key_wallet_c9',
      desc: '',
      args: [],
    );
  }

  /// `View Seed Phrase`
  String get g_key_wallet_c10 {
    return Intl.message(
      'View Seed Phrase',
      name: 'g_key_wallet_c10',
      desc: '',
      args: [],
    );
  }

  /// `Please Make sure you record your seed phrase and store it safely.`
  String get g_key_wallet_c11 {
    return Intl.message(
      'Please Make sure you record your seed phrase and store it safely.',
      name: 'g_key_wallet_c11',
      desc: '',
      args: [],
    );
  }

  /// `Now try to put your seed phrase again.`
  String get g_key_wallet_c12 {
    return Intl.message(
      'Now try to put your seed phrase again.',
      name: 'g_key_wallet_c12',
      desc: '',
      args: [],
    );
  }

  /// `Import Account`
  String get g_key_wallet_c13 {
    return Intl.message(
      'Import Account',
      name: 'g_key_wallet_c13',
      desc: '',
      args: [],
    );
  }

  /// `Create Account`
  String get g_key_wallet_c14 {
    return Intl.message(
      'Create Account',
      name: 'g_key_wallet_c14',
      desc: '',
      args: [],
    );
  }

  /// `You’re all done!`
  String get g_key_wallet_c15 {
    return Intl.message(
      'You’re all done!',
      name: 'g_key_wallet_c15',
      desc: '',
      args: [],
    );
  }

  /// `You can now fully enjoy your wallet.`
  String get g_key_wallet_c16 {
    return Intl.message(
      'You can now fully enjoy your wallet.',
      name: 'g_key_wallet_c16',
      desc: '',
      args: [],
    );
  }

  /// `Get Started`
  String get g_key_wallet_c17 {
    return Intl.message(
      'Get Started',
      name: 'g_key_wallet_c17',
      desc: '',
      args: [],
    );
  }

  /// `Skip for now`
  String get g_key_wallet_c18 {
    return Intl.message(
      'Skip for now',
      name: 'g_key_wallet_c18',
      desc: '',
      args: [],
    );
  }

  /// `You can skip backing up the seed phrase for now, and do it again in Settings at any time if you need to.`
  String get g_key_wallet_c19 {
    return Intl.message(
      'You can skip backing up the seed phrase for now, and do it again in Settings at any time if you need to.',
      name: 'g_key_wallet_c19',
      desc: '',
      args: [],
    );
  }

  /// `Create directly`
  String get g_key_wallet_c21 {
    return Intl.message(
      'Create directly',
      name: 'g_key_wallet_c21',
      desc: '',
      args: [],
    );
  }

  /// `created successfully`
  String get g_key_wallet_c22 {
    return Intl.message(
      'created successfully',
      name: 'g_key_wallet_c22',
      desc: '',
      args: [],
    );
  }

  /// `If you want to check your wallet detail or export keystore, you can go to Sidebar > Manage Wallet `
  String get g_key_wallet_c23 {
    return Intl.message(
      'If you want to check your wallet detail or export keystore, you can go to Sidebar > Manage Wallet ',
      name: 'g_key_wallet_c23',
      desc: '',
      args: [],
    );
  }

  /// `Export my keystore`
  String get g_key_wallet_c24 {
    return Intl.message(
      'Export my keystore',
      name: 'g_key_wallet_c24',
      desc: '',
      args: [],
    );
  }

  /// `Secure your wallet by backing it up`
  String get g_key_wallet_c25 {
    return Intl.message(
      'Secure your wallet by backing it up',
      name: 'g_key_wallet_c25',
      desc: '',
      args: [],
    );
  }

  /// `A keystore is a repository of security certificates and associated private keys.`
  String get g_key_wallet_c26 {
    return Intl.message(
      'A keystore is a repository of security certificates and associated private keys.',
      name: 'g_key_wallet_c26',
      desc: '',
      args: [],
    );
  }

  /// `Step 1: Go to Manage Wallet.`
  String get g_key_wallet_c27 {
    return Intl.message(
      'Step 1: Go to Manage Wallet.',
      name: 'g_key_wallet_c27',
      desc: '',
      args: [],
    );
  }

  /// `Step 2: Select Wallet Address.`
  String get g_key_wallet_c28 {
    return Intl.message(
      'Step 2: Select Wallet Address.',
      name: 'g_key_wallet_c28',
      desc: '',
      args: [],
    );
  }

  /// `Step 3: Press Export Keystore.`
  String get g_key_wallet_c29 {
    return Intl.message(
      'Step 3: Press Export Keystore.',
      name: 'g_key_wallet_c29',
      desc: '',
      args: [],
    );
  }

  /// `Go to Manage Wallet`
  String get g_key_wallet_c30 {
    return Intl.message(
      'Go to Manage Wallet',
      name: 'g_key_wallet_c30',
      desc: '',
      args: [],
    );
  }

  /// `Back to homepage`
  String get g_key_wallet_c31 {
    return Intl.message(
      'Back to homepage',
      name: 'g_key_wallet_c31',
      desc: '',
      args: [],
    );
  }

  /// `Add Wallet`
  String get g_key_wallet_c32 {
    return Intl.message(
      'Add Wallet',
      name: 'g_key_wallet_c32',
      desc: '',
      args: [],
    );
  }

  /// `Create a wallet using a seed phrase.`
  String get g_key_wallet_c33 {
    return Intl.message(
      'Create a wallet using a seed phrase.',
      name: 'g_key_wallet_c33',
      desc: '',
      args: [],
    );
  }

  /// `Enter a wallet name`
  String get g_key_wallet_c34 {
    return Intl.message(
      'Enter a wallet name',
      name: 'g_key_wallet_c34',
      desc: '',
      args: [],
    );
  }

  /// `You haven't backed up your wallet seed phrase!`
  String get g_key_wallet_c35 {
    return Intl.message(
      'You haven\'t backed up your wallet seed phrase!',
      name: 'g_key_wallet_c35',
      desc: '',
      args: [],
    );
  }

  /// `Backup Now`
  String get g_key_wallet_c36 {
    return Intl.message(
      'Backup Now',
      name: 'g_key_wallet_c36',
      desc: '',
      args: [],
    );
  }

  /// `Set Wallet Password`
  String get g_key_wallet_c37 {
    return Intl.message(
      'Set Wallet Password',
      name: 'g_key_wallet_c37',
      desc: '',
      args: [],
    );
  }

  /// `Backup Wallet`
  String get g_key_wallet_c38 {
    return Intl.message(
      'Backup Wallet',
      name: 'g_key_wallet_c38',
      desc: '',
      args: [],
    );
  }

  /// `Please record the following seed phrase`
  String get g_key_wallet_c39 {
    return Intl.message(
      'Please record the following seed phrase',
      name: 'g_key_wallet_c39',
      desc: '',
      args: [],
    );
  }

  /// `Internet-connected devices may expose your information. We recommend that you write down the seed phrase and store it securely.`
  String get g_key_wallet_c40 {
    return Intl.message(
      'Internet-connected devices may expose your information. We recommend that you write down the seed phrase and store it securely.',
      name: 'g_key_wallet_c40',
      desc: '',
      args: [],
    );
  }

  /// `Warning: Do not disclose your seed phrase to anyone. N42Wallet will never ask you for this information. Please be extremely cautious and store it offline securely. If your seed phrase is exposed, you may lose all your assets and be unable to recover them.`
  String get g_key_wallet_c41 {
    return Intl.message(
      'Warning: Do not disclose your seed phrase to anyone. N42Wallet will never ask you for this information. Please be extremely cautious and store it offline securely. If your seed phrase is exposed, you may lose all your assets and be unable to recover them.',
      name: 'g_key_wallet_c41',
      desc: '',
      args: [],
    );
  }

  /// `Warning: The seed phrase is the only way to recover your wallet assets.`
  String get g_key_wallet_c42 {
    return Intl.message(
      'Warning: The seed phrase is the only way to recover your wallet assets.',
      name: 'g_key_wallet_c42',
      desc: '',
      args: [],
    );
  }

  /// `Next step`
  String get g_key_wallet_c43 {
    return Intl.message(
      'Next step',
      name: 'g_key_wallet_c43',
      desc: '',
      args: [],
    );
  }

  /// `Click to view seed phrase`
  String get g_key_wallet_c44 {
    return Intl.message(
      'Click to view seed phrase',
      name: 'g_key_wallet_c44',
      desc: '',
      args: [],
    );
  }

  /// `Please make sure there are no other people or cameras around`
  String get g_key_wallet_c45 {
    return Intl.message(
      'Please make sure there are no other people or cameras around',
      name: 'g_key_wallet_c45',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Seed Phrase`
  String get g_key_wallet_c46 {
    return Intl.message(
      'Confirm Seed Phrase',
      name: 'g_key_wallet_c46',
      desc: '',
      args: [],
    );
  }

  /// `Wallet Information`
  String get g_key_wallet_c47 {
    return Intl.message(
      'Wallet Information',
      name: 'g_key_wallet_c47',
      desc: '',
      args: [],
    );
  }

  /// `Wallet name`
  String get g_key_wallet_c48 {
    return Intl.message(
      'Wallet name',
      name: 'g_key_wallet_c48',
      desc: '',
      args: [],
    );
  }

  /// `Please backup your wallet seed phrase first!`
  String get g_key_wallet_c49 {
    return Intl.message(
      'Please backup your wallet seed phrase first!',
      name: 'g_key_wallet_c49',
      desc: '',
      args: [],
    );
  }

  /// `Manage Wallet`
  String get g_key_wallet_manage {
    return Intl.message(
      'Manage Wallet',
      name: 'g_key_wallet_manage',
      desc: '',
      args: [],
    );
  }

  /// `Export Keystore`
  String get g_key_ex_keystore {
    return Intl.message(
      'Export Keystore',
      name: 'g_key_ex_keystore',
      desc: '',
      args: [],
    );
  }

  /// `Backup Tips`
  String get g_key_ex_keystore_1 {
    return Intl.message(
      'Backup Tips',
      name: 'g_key_ex_keystore_1',
      desc: '',
      args: [],
    );
  }

  /// `Obtaining Keystore and password will give the holder full control over wallet assets.`
  String get g_key_ex_keystore_2 {
    return Intl.message(
      'Obtaining Keystore and password will give the holder full control over wallet assets.',
      name: 'g_key_ex_keystore_2',
      desc: '',
      args: [],
    );
  }

  /// `Record carefully and store in a secure location. Keeping multiple physical copies is the safest storage method.`
  String get g_key_ex_keystore_3 {
    return Intl.message(
      'Record carefully and store in a secure location. Keeping multiple physical copies is the safest storage method.',
      name: 'g_key_ex_keystore_3',
      desc: '',
      args: [],
    );
  }

  /// `If your private key is lost, it cannot be retrieved. Back it up physically and store it securely.`
  String get g_key_ex_keystore_4 {
    return Intl.message(
      'If your private key is lost, it cannot be retrieved. Back it up physically and store it securely.',
      name: 'g_key_ex_keystore_4',
      desc: '',
      args: [],
    );
  }

  /// `Save offline`
  String get g_key_ex_keystore_5 {
    return Intl.message(
      'Save offline',
      name: 'g_key_ex_keystore_5',
      desc: '',
      args: [],
    );
  }

  /// `Do not save to any mailbox, notepad, network disk or chat software that isn't secure.`
  String get g_key_ex_keystore_6 {
    return Intl.message(
      'Do not save to any mailbox, notepad, network disk or chat software that isn\'t secure.',
      name: 'g_key_ex_keystore_6',
      desc: '',
      args: [],
    );
  }

  /// `Please use network transmission`
  String get g_key_ex_keystore_7 {
    return Intl.message(
      'Please use network transmission',
      name: 'g_key_ex_keystore_7',
      desc: '',
      args: [],
    );
  }

  /// `Please be sure to transmit it through network tools, Once hackers obtain it, it will cause irreparable economic losses`
  String get g_key_ex_keystore_8 {
    return Intl.message(
      'Please be sure to transmit it through network tools, Once hackers obtain it, it will cause irreparable economic losses',
      name: 'g_key_ex_keystore_8',
      desc: '',
      args: [],
    );
  }

  /// `Use tools to save`
  String get g_key_ex_keystore_9 {
    return Intl.message(
      'Use tools to save',
      name: 'g_key_ex_keystore_9',
      desc: '',
      args: [],
    );
  }

  /// `Use a password management tool to store.`
  String get g_key_ex_keystore_10 {
    return Intl.message(
      'Use a password management tool to store.',
      name: 'g_key_ex_keystore_10',
      desc: '',
      args: [],
    );
  }

  /// `Copied`
  String get g_key_ex_keystore_11 {
    return Intl.message(
      'Copied',
      name: 'g_key_ex_keystore_11',
      desc: '',
      args: [],
    );
  }

  /// `Copy cancelled`
  String get g_key_ex_keystore_12 {
    return Intl.message(
      'Copy cancelled',
      name: 'g_key_ex_keystore_12',
      desc: '',
      args: [],
    );
  }

  /// `Identity wallet`
  String get g_key_ex_keystore_13 {
    return Intl.message(
      'Identity wallet',
      name: 'g_key_ex_keystore_13',
      desc: '',
      args: [],
    );
  }

  /// `Encrypted private key file.`
  String get g_key_ex_keystore_15 {
    return Intl.message(
      'Encrypted private key file.',
      name: 'g_key_ex_keystore_15',
      desc: '',
      args: [],
    );
  }

  /// `Import method`
  String get g_key_ex_keystore_16 {
    return Intl.message(
      'Import method',
      name: 'g_key_ex_keystore_16',
      desc: '',
      args: [],
    );
  }

  /// `Keystore file`
  String get g_key_ex_keystore_17 {
    return Intl.message(
      'Keystore file',
      name: 'g_key_ex_keystore_17',
      desc: '',
      args: [],
    );
  }

  /// `Please enter the Keystore information.`
  String get g_key_ex_keystore_18 {
    return Intl.message(
      'Please enter the Keystore information.',
      name: 'g_key_ex_keystore_18',
      desc: '',
      args: [],
    );
  }

  /// `Export PrivateKey`
  String get g_key_ex_keystore_19 {
    return Intl.message(
      'Export PrivateKey',
      name: 'g_key_ex_keystore_19',
      desc: '',
      args: [],
    );
  }

  /// `A current currency wallet already exists.`
  String get g_key_keystore_19 {
    return Intl.message(
      'A current currency wallet already exists.',
      name: 'g_key_keystore_19',
      desc: '',
      args: [],
    );
  }

  /// `Could not read Keystore`
  String get g_key_keystore_21 {
    return Intl.message(
      'Could not read Keystore',
      name: 'g_key_keystore_21',
      desc: '',
      args: [],
    );
  }

  /// `Keystore`
  String get g_key_keystore_22 {
    return Intl.message(
      'Keystore',
      name: 'g_key_keystore_22',
      desc: '',
      args: [],
    );
  }

  /// `Name`
  String get g_key_nft_2 {
    return Intl.message('Name', name: 'g_key_nft_2', desc: '', args: []);
  }

  /// `Camera`
  String get g_key_nft_16 {
    return Intl.message('Camera', name: 'g_key_nft_16', desc: '', args: []);
  }

  /// `Select photo`
  String get g_key_nft_17 {
    return Intl.message(
      'Select photo',
      name: 'g_key_nft_17',
      desc: '',
      args: [],
    );
  }

  /// `Content`
  String get g_key_nft_18 {
    return Intl.message('Content', name: 'g_key_nft_18', desc: '', args: []);
  }

  /// `Transaction submitted`
  String get g_key_nft_41 {
    return Intl.message(
      'Transaction submitted',
      name: 'g_key_nft_41',
      desc: '',
      args: [],
    );
  }

  /// `Select video`
  String get g_key_nft_47 {
    return Intl.message(
      'Select video',
      name: 'g_key_nft_47',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get g_key_nft_141 {
    return Intl.message('Total', name: 'g_key_nft_141', desc: '', args: []);
  }

  /// `Back`
  String get g_key_nft_220 {
    return Intl.message('Back', name: 'g_key_nft_220', desc: '', args: []);
  }

  /// `Enter the seed phrase for the wallet you want to import.`
  String get w_key_8 {
    return Intl.message(
      'Enter the seed phrase for the wallet you want to import.',
      name: 'w_key_8',
      desc: '',
      args: [],
    );
  }

  /// `Seed phrase incorrect.`
  String get w_key_12 {
    return Intl.message(
      'Seed phrase incorrect.',
      name: 'w_key_12',
      desc: '',
      args: [],
    );
  }

  /// `If I lose my secret phrase, my funds will be lost forever.`
  String get w_item_1 {
    return Intl.message(
      'If I lose my secret phrase, my funds will be lost forever.',
      name: 'w_item_1',
      desc: '',
      args: [],
    );
  }

  /// `If I reveal or share my seed phrase to anybody, my funds can get stolen.`
  String get w_item_2 {
    return Intl.message(
      'If I reveal or share my seed phrase to anybody, my funds can get stolen.',
      name: 'w_item_2',
      desc: '',
      args: [],
    );
  }

  /// `It is my responsibility to keep my seed phrase secure.`
  String get w_item_3 {
    return Intl.message(
      'It is my responsibility to keep my seed phrase secure.',
      name: 'w_item_3',
      desc: '',
      args: [],
    );
  }

  /// `Face matching method`
  String get g_face_match_key1 {
    return Intl.message(
      'Face matching method',
      name: 'g_face_match_key1',
      desc: '',
      args: [],
    );
  }

  /// `Match failed!`
  String get g_face_match_key3 {
    return Intl.message(
      'Match failed!',
      name: 'g_face_match_key3',
      desc: '',
      args: [],
    );
  }

  /// `Match successful.Address:{value}.`
  String g_face_match_key4(Object value) {
    return Intl.message(
      'Match successful.Address:$value.',
      name: 'g_face_match_key4',
      desc: '',
      args: [value],
    );
  }

  /// `Address error!`
  String get g_face_match_key5 {
    return Intl.message(
      'Address error!',
      name: 'g_face_match_key5',
      desc: '',
      args: [],
    );
  }

  /// `Face Data Binding`
  String get g_face_match_key6 {
    return Intl.message(
      'Face Data Binding',
      name: 'g_face_match_key6',
      desc: '',
      args: [],
    );
  }

  /// `Face matching`
  String get g_face_match_key7 {
    return Intl.message(
      'Face matching',
      name: 'g_face_match_key7',
      desc: '',
      args: [],
    );
  }

  /// `Reselect`
  String get g_face_match_key8 {
    return Intl.message(
      'Reselect',
      name: 'g_face_match_key8',
      desc: '',
      args: [],
    );
  }

  /// `Match`
  String get g_face_match_key9 {
    return Intl.message('Match', name: 'g_face_match_key9', desc: '', args: []);
  }

  /// `You have been bound and cannot be re-bound at the moment. Binding address: {value}.`
  String g_face_match_key10(Object value) {
    return Intl.message(
      'You have been bound and cannot be re-bound at the moment. Binding address: $value.',
      name: 'g_face_match_key10',
      desc: '',
      args: [value],
    );
  }

  /// `Binding successful.Binding address: {value}`
  String g_face_match_key11(Object value) {
    return Intl.message(
      'Binding successful.Binding address: $value',
      name: 'g_face_match_key11',
      desc: '',
      args: [value],
    );
  }

  /// `Rebind`
  String get g_face_match_key12 {
    return Intl.message(
      'Rebind',
      name: 'g_face_match_key12',
      desc: '',
      args: [],
    );
  }

  /// `Bind`
  String get g_face_match_key13 {
    return Intl.message('Bind', name: 'g_face_match_key13', desc: '', args: []);
  }

  /// `Verify`
  String get g_face_match_key14 {
    return Intl.message(
      'Verify',
      name: 'g_face_match_key14',
      desc: '',
      args: [],
    );
  }

  /// `You can bind your facial data to a wallet address directly (if you have previously bound one, the old wallet address will be overwritten), or if you have previously bound a wallet address, you can also manually verify to retrieve the bound wallet address.`
  String get g_face_match_key15 {
    return Intl.message(
      'You can bind your facial data to a wallet address directly (if you have previously bound one, the old wallet address will be overwritten), or if you have previously bound a wallet address, you can also manually verify to retrieve the bound wallet address.',
      name: 'g_face_match_key15',
      desc: '',
      args: [],
    );
  }

  /// `The wallet address linked to your facial data has been detected as follows, but you have not yet imported this wallet into your wallet list.`
  String get g_face_match_key16 {
    return Intl.message(
      'The wallet address linked to your facial data has been detected as follows, but you have not yet imported this wallet into your wallet list.',
      name: 'g_face_match_key16',
      desc: '',
      args: [],
    );
  }

  /// `You have linked your facial data with this wallet.`
  String get g_face_match_key17 {
    return Intl.message(
      'You have linked your facial data with this wallet.',
      name: 'g_face_match_key17',
      desc: '',
      args: [],
    );
  }

  /// `User Notice`
  String get g_face_match_key18 {
    return Intl.message(
      'User Notice',
      name: 'g_face_match_key18',
      desc: '',
      args: [],
    );
  }

  /// `What is Face Binding?`
  String get g_face_match_key19 {
    return Intl.message(
      'What is Face Binding?',
      name: 'g_face_match_key19',
      desc: '',
      args: [],
    );
  }

  /// `Face binding utilizes facial recognition technology to match your biometric facial features with your blockchain wallet address.`
  String get g_face_match_key20 {
    return Intl.message(
      'Face binding utilizes facial recognition technology to match your biometric facial features with your blockchain wallet address.',
      name: 'g_face_match_key20',
      desc: '',
      args: [],
    );
  }

  /// `This process not only enhances transaction convenience but also strengthens account security, ensuring that every action is authorized by you.`
  String get g_face_match_key21 {
    return Intl.message(
      'This process not only enhances transaction convenience but also strengthens account security, ensuring that every action is authorized by you.',
      name: 'g_face_match_key21',
      desc: '',
      args: [],
    );
  }

  /// `Why is Face Binding Necessary?`
  String get g_face_match_key22 {
    return Intl.message(
      'Why is Face Binding Necessary?',
      name: 'g_face_match_key22',
      desc: '',
      args: [],
    );
  }

  /// `By binding your face data, your identity is directly linked to transaction activities, simplifying the identity verification process and improving operational efficiency. This technology ensures quick and secure identity verification when performing sensitive operations such as transferring assets or interacting with contracts.`
  String get g_face_match_key23 {
    return Intl.message(
      'By binding your face data, your identity is directly linked to transaction activities, simplifying the identity verification process and improving operational efficiency. This technology ensures quick and secure identity verification when performing sensitive operations such as transferring assets or interacting with contracts.',
      name: 'g_face_match_key23',
      desc: '',
      args: [],
    );
  }

  /// `How is My Face Data Stored and Is It Secure?`
  String get g_face_match_key24 {
    return Intl.message(
      'How is My Face Data Stored and Is It Secure?',
      name: 'g_face_match_key24',
      desc: '',
      args: [],
    );
  }

  /// `Your face data is stored in an encrypted form on a public blockchain, not in any centralized database. This means the system can only decrypt and use your data for identity verification when authorized by you, ensuring your privacy and data security.`
  String get g_face_match_key25 {
    return Intl.message(
      'Your face data is stored in an encrypted form on a public blockchain, not in any centralized database. This means the system can only decrypt and use your data for identity verification when authorized by you, ensuring your privacy and data security.',
      name: 'g_face_match_key25',
      desc: '',
      args: [],
    );
  }

  /// `How Does Face Binding Affect My Account Security?`
  String get g_face_match_key26 {
    return Intl.message(
      'How Does Face Binding Affect My Account Security?',
      name: 'g_face_match_key26',
      desc: '',
      args: [],
    );
  }

  /// `Face binding enhances your account security by ensuring that all sensitive actions are carried out only with your explicit authorization. We use industry-leading encryption technology to protect your biometric data, preventing unauthorized access.`
  String get g_face_match_key27 {
    return Intl.message(
      'Face binding enhances your account security by ensuring that all sensitive actions are carried out only with your explicit authorization. We use industry-leading encryption technology to protect your biometric data, preventing unauthorized access.',
      name: 'g_face_match_key27',
      desc: '',
      args: [],
    );
  }

  /// `Is My Face Data Secure?`
  String get g_face_match_key28 {
    return Intl.message(
      'Is My Face Data Secure?',
      name: 'g_face_match_key28',
      desc: '',
      args: [],
    );
  }

  /// `Absolutely. All biometric data undergoes strict encryption, and the highest security standards are followed for data transmission and storage. The system will only decrypt this data when necessary to complete identity verification.`
  String get g_face_match_key29 {
    return Intl.message(
      'Absolutely. All biometric data undergoes strict encryption, and the highest security standards are followed for data transmission and storage. The system will only decrypt this data when necessary to complete identity verification.',
      name: 'g_face_match_key29',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get g_face_match_key30 {
    return Intl.message(
      'Got it',
      name: 'g_face_match_key30',
      desc: '',
      args: [],
    );
  }

  /// `Select wallet address`
  String get g_face_match_key31 {
    return Intl.message(
      'Select wallet address',
      name: 'g_face_match_key31',
      desc: '',
      args: [],
    );
  }

  /// `There is no N42chain in the {value} wallet!`
  String g_face_match_key32(Object value) {
    return Intl.message(
      'There is no N42chain in the $value wallet!',
      name: 'g_face_match_key32',
      desc: '',
      args: [value],
    );
  }

  /// `Unbinding`
  String get g_face_match_key33 {
    return Intl.message(
      'Unbinding',
      name: 'g_face_match_key33',
      desc: '',
      args: [],
    );
  }

  /// `Facial data verification failed!`
  String get g_face_match_key34 {
    return Intl.message(
      'Facial data verification failed!',
      name: 'g_face_match_key34',
      desc: '',
      args: [],
    );
  }

  /// `Face data unbinding failed!`
  String get g_face_match_key35 {
    return Intl.message(
      'Face data unbinding failed!',
      name: 'g_face_match_key35',
      desc: '',
      args: [],
    );
  }

  /// `Touch ID and Face ID`
  String get g_lock_key1 {
    return Intl.message(
      'Touch ID and Face ID',
      name: 'g_lock_key1',
      desc: '',
      args: [],
    );
  }

  /// `Lock screen page`
  String get g_lock_key3 {
    return Intl.message(
      'Lock screen page',
      name: 'g_lock_key3',
      desc: '',
      args: [],
    );
  }

  /// `Auto-lock`
  String get g_lock_key4 {
    return Intl.message('Auto-lock', name: 'g_lock_key4', desc: '', args: []);
  }

  /// `Succeeded`
  String get g_lock_key5 {
    return Intl.message('Succeeded', name: 'g_lock_key5', desc: '', args: []);
  }

  /// `Failed`
  String get g_lock_key6 {
    return Intl.message('Failed', name: 'g_lock_key6', desc: '', args: []);
  }

  /// `Biometric recognition is not enabled`
  String get g_lock_key7 {
    return Intl.message(
      'Biometric recognition is not enabled',
      name: 'g_lock_key7',
      desc: '',
      args: [],
    );
  }

  /// `Add biometric verification?`
  String get g_lock_key8 {
    return Intl.message(
      'Add biometric verification?',
      name: 'g_lock_key8',
      desc: '',
      args: [],
    );
  }

  /// `Reset password`
  String get g_lock_key9 {
    return Intl.message(
      'Reset password',
      name: 'g_lock_key9',
      desc: '',
      args: [],
    );
  }

  /// `Current password`
  String get g_lock_key10 {
    return Intl.message(
      'Current password',
      name: 'g_lock_key10',
      desc: '',
      args: [],
    );
  }

  /// `New password`
  String get g_lock_key11 {
    return Intl.message(
      'New password',
      name: 'g_lock_key11',
      desc: '',
      args: [],
    );
  }

  /// `Confirm new password`
  String get g_lock_key12 {
    return Intl.message(
      'Confirm new password',
      name: 'g_lock_key12',
      desc: '',
      args: [],
    );
  }

  /// `6-digit number`
  String get g_lock_key13 {
    return Intl.message(
      '6-digit number',
      name: 'g_lock_key13',
      desc: '',
      args: [],
    );
  }

  /// `Passwords and biometrics`
  String get g_lock_key15 {
    return Intl.message(
      'Passwords and biometrics',
      name: 'g_lock_key15',
      desc: '',
      args: [],
    );
  }

  /// `Pattern password`
  String get g_lock_key16 {
    return Intl.message(
      'Pattern password',
      name: 'g_lock_key16',
      desc: '',
      args: [],
    );
  }

  /// `Set pattern passcode`
  String get g_lock_key17 {
    return Intl.message(
      'Set pattern passcode',
      name: 'g_lock_key17',
      desc: '',
      args: [],
    );
  }

  /// `For your account security,please set a group password`
  String get g_lock_key18 {
    return Intl.message(
      'For your account security,please set a group password',
      name: 'g_lock_key18',
      desc: '',
      args: [],
    );
  }

  /// `Secondary drawing pattern password`
  String get g_lock_key19 {
    return Intl.message(
      'Secondary drawing pattern password',
      name: 'g_lock_key19',
      desc: '',
      args: [],
    );
  }

  /// `Draw pattern password`
  String get g_lock_key20 {
    return Intl.message(
      'Draw pattern password',
      name: 'g_lock_key20',
      desc: '',
      args: [],
    );
  }

  /// `Pattern password input error,you have {value} chances`
  String g_lock_key21(Object value) {
    return Intl.message(
      'Pattern password input error,you have $value chances',
      name: 'g_lock_key21',
      desc: '',
      args: [value],
    );
  }

  /// `Reset the pattern password`
  String get g_lock_key22 {
    return Intl.message(
      'Reset the pattern password',
      name: 'g_lock_key22',
      desc: '',
      args: [],
    );
  }

  /// `Too many incorrect inputs, please reset the password`
  String get g_lock_key23 {
    return Intl.message(
      'Too many incorrect inputs, please reset the password',
      name: 'g_lock_key23',
      desc: '',
      args: [],
    );
  }

  /// `Add Wallet Password?`
  String get g_lock_key24 {
    return Intl.message(
      'Add Wallet Password?',
      name: 'g_lock_key24',
      desc: '',
      args: [],
    );
  }

  /// `Pattern password input error,you have {value} chance`
  String g_lock_key25(Object value) {
    return Intl.message(
      'Pattern password input error,you have $value chance',
      name: 'g_lock_key25',
      desc: '',
      args: [value],
    );
  }

  /// `Fingerprint or face recognition is not enabled?`
  String get g_unlock_key2 {
    return Intl.message(
      'Fingerprint or face recognition is not enabled?',
      name: 'g_unlock_key2',
      desc: '',
      args: [],
    );
  }

  /// `Draw pattern password`
  String get g_unlock_key3 {
    return Intl.message(
      'Draw pattern password',
      name: 'g_unlock_key3',
      desc: '',
      args: [],
    );
  }

  /// `Pattern password input error,you have {value} chances`
  String g_unlock_key4(Object value) {
    return Intl.message(
      'Pattern password input error,you have $value chances',
      name: 'g_unlock_key4',
      desc: '',
      args: [value],
    );
  }

  /// `Enter password`
  String get g_unlock_key5 {
    return Intl.message(
      'Enter password',
      name: 'g_unlock_key5',
      desc: '',
      args: [],
    );
  }

  /// `Password input error,you have {value} chances`
  String g_unlock_key6(Object value) {
    return Intl.message(
      'Password input error,you have $value chances',
      name: 'g_unlock_key6',
      desc: '',
      args: [value],
    );
  }

  /// `Authentication failed`
  String get g_unlock_key7 {
    return Intl.message(
      'Authentication failed',
      name: 'g_unlock_key7',
      desc: '',
      args: [],
    );
  }

  /// `Password input error,you have {value} chance`
  String g_unlock_key8(Object value) {
    return Intl.message(
      'Password input error,you have $value chance',
      name: 'g_unlock_key8',
      desc: '',
      args: [value],
    );
  }

  /// `You can also `
  String get g_unlock_key9 {
    return Intl.message(
      'You can also ',
      name: 'g_unlock_key9',
      desc: '',
      args: [],
    );
  }

  /// `The application will unlock in {value} seconds.`
  String g_unlock_key10(Object value) {
    return Intl.message(
      'The application will unlock in $value seconds.',
      name: 'g_unlock_key10',
      desc: '',
      args: [value],
    );
  }

  /// `Reset your password`
  String get rest_your_password {
    return Intl.message(
      'Reset your password',
      name: 'rest_your_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter code`
  String get rest_Please_enter {
    return Intl.message(
      'Enter code',
      name: 'rest_Please_enter',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get authentication code`
  String get email_code_error {
    return Intl.message(
      'Failed to get authentication code',
      name: 'email_code_error',
      desc: '',
      args: [],
    );
  }

  /// `Authentication code sent successfully, please check your email`
  String get email_code_finish {
    return Intl.message(
      'Authentication code sent successfully, please check your email',
      name: 'email_code_finish',
      desc: '',
      args: [],
    );
  }

  /// `Email Address Authentication`
  String get email_verification {
    return Intl.message(
      'Email Address Authentication',
      name: 'email_verification',
      desc: '',
      args: [],
    );
  }

  /// `The Email Address Authenticator app protects your withdrawals and N42Wallet account.`
  String get email_verification_message1 {
    return Intl.message(
      'The Email Address Authenticator app protects your withdrawals and N42Wallet account.',
      name: 'email_verification_message1',
      desc: '',
      args: [],
    );
  }

  /// `Add Email verification?`
  String get email_verification_message2 {
    return Intl.message(
      'Add Email verification?',
      name: 'email_verification_message2',
      desc: '',
      args: [],
    );
  }

  /// `Authentication code error`
  String get email_code_input_error {
    return Intl.message(
      'Authentication code error',
      name: 'email_code_input_error',
      desc: '',
      args: [],
    );
  }

  /// `Create your account`
  String get Create_your_account {
    return Intl.message(
      'Create your account',
      name: 'Create_your_account',
      desc: '',
      args: [],
    );
  }

  /// `Google Authentication`
  String get google_verification {
    return Intl.message(
      'Google Authentication',
      name: 'google_verification',
      desc: '',
      args: [],
    );
  }

  /// `Failed to get google key`
  String get google_verification_message3 {
    return Intl.message(
      'Failed to get google key',
      name: 'google_verification_message3',
      desc: '',
      args: [],
    );
  }

  /// `Two-Factor Authentication(2FA)`
  String get google_verification_message5 {
    return Intl.message(
      'Two-Factor Authentication(2FA)',
      name: 'google_verification_message5',
      desc: '',
      args: [],
    );
  }

  /// `To protect your account,it is recommended to turn on at least one 2FA.`
  String get google_verification_message6 {
    return Intl.message(
      'To protect your account,it is recommended to turn on at least one 2FA.',
      name: 'google_verification_message6',
      desc: '',
      args: [],
    );
  }

  /// `The Google Authenticator app protects your withdrawals and N42Wallet account.`
  String get google_verification_message7 {
    return Intl.message(
      'The Google Authenticator app protects your withdrawals and N42Wallet account.',
      name: 'google_verification_message7',
      desc: '',
      args: [],
    );
  }

  /// `Download And Install`
  String get google_verification_message8 {
    return Intl.message(
      'Download And Install',
      name: 'google_verification_message8',
      desc: '',
      args: [],
    );
  }

  /// `Please download and install Google Authenticator. Then press ‘Link’ to link your N42Wallet account.`
  String get google_verification_message9 {
    return Intl.message(
      'Please download and install Google Authenticator. Then press ‘Link’ to link your N42Wallet account.',
      name: 'google_verification_message9',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get google_verification_message10 {
    return Intl.message(
      'Link',
      name: 'google_verification_message10',
      desc: '',
      args: [],
    );
  }

  /// `Download Google Authentication`
  String get google_verification_message11 {
    return Intl.message(
      'Download Google Authentication',
      name: 'google_verification_message11',
      desc: '',
      args: [],
    );
  }

  /// `Instructions`
  String get google_verification_message12 {
    return Intl.message(
      'Instructions',
      name: 'google_verification_message12',
      desc: '',
      args: [],
    );
  }

  /// `Open Google Authenticator.`
  String get google_verification_message13 {
    return Intl.message(
      'Open Google Authenticator.',
      name: 'google_verification_message13',
      desc: '',
      args: [],
    );
  }

  /// `You will see a 6-digit verification code on the screen.`
  String get google_verification_message14 {
    return Intl.message(
      'You will see a 6-digit verification code on the screen.',
      name: 'google_verification_message14',
      desc: '',
      args: [],
    );
  }

  /// `Copy the 6-digit code and paste it in N42Wallet.`
  String get google_verification_message15 {
    return Intl.message(
      'Copy the 6-digit code and paste it in N42Wallet.',
      name: 'google_verification_message15',
      desc: '',
      args: [],
    );
  }

  /// `Then，your Authenticator will be successfully linked.`
  String get google_verification_message16 {
    return Intl.message(
      'Then，your Authenticator will be successfully linked.',
      name: 'google_verification_message16',
      desc: '',
      args: [],
    );
  }

  /// `Backup Key`
  String get google_verification_message17 {
    return Intl.message(
      'Backup Key',
      name: 'google_verification_message17',
      desc: '',
      args: [],
    );
  }

  /// `Copy the key to Google Authentication`
  String get google_verification_message18 {
    return Intl.message(
      'Copy the key to Google Authentication',
      name: 'google_verification_message18',
      desc: '',
      args: [],
    );
  }

  /// `Enter Google verification code`
  String get google_verification_message19 {
    return Intl.message(
      'Enter Google verification code',
      name: 'google_verification_message19',
      desc: '',
      args: [],
    );
  }

  /// `Enter E-mail verification code`
  String get google_verification_message20 {
    return Intl.message(
      'Enter E-mail verification code',
      name: 'google_verification_message20',
      desc: '',
      args: [],
    );
  }

  /// `Enter {value} password`
  String google_verification_message21(Object value) {
    return Intl.message(
      'Enter $value password',
      name: 'google_verification_message21',
      desc: '',
      args: [value],
    );
  }

  /// `Sign up`
  String get Create_account {
    return Intl.message('Sign up', name: 'Create_account', desc: '', args: []);
  }

  /// `Log In`
  String get g_key_login {
    return Intl.message('Log In', name: 'g_key_login', desc: '', args: []);
  }

  /// `Log Out`
  String get g_key_logout {
    return Intl.message('Log Out', name: 'g_key_logout', desc: '', args: []);
  }

  /// `Are you sure you want to exit the app?`
  String get g_key_logout_sure {
    return Intl.message(
      'Are you sure you want to exit the app?',
      name: 'g_key_logout_sure',
      desc: '',
      args: [],
    );
  }

  /// `Please enter email`
  String get please_enter_email {
    return Intl.message(
      'Please enter email',
      name: 'please_enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Please enter password`
  String get please_enter_password {
    return Intl.message(
      'Please enter password',
      name: 'please_enter_password',
      desc: '',
      args: [],
    );
  }

  /// `Invalid email address`
  String get email_error {
    return Intl.message(
      'Invalid email address',
      name: 'email_error',
      desc: '',
      args: [],
    );
  }

  /// `Passwords don't match`
  String get password_diff {
    return Intl.message(
      'Passwords don\'t match',
      name: 'password_diff',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get next {
    return Intl.message('Next', name: 'next', desc: '', args: []);
  }

  /// `Choose a password(8~18 characters)`
  String get rest_Choose_password {
    return Intl.message(
      'Choose a password(8~18 characters)',
      name: 'rest_Choose_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter the password again`
  String get rest_Enter_the_password_again {
    return Intl.message(
      'Enter the password again',
      name: 'rest_Enter_the_password_again',
      desc: '',
      args: [],
    );
  }

  /// `OTP Code`
  String get rest_Verification_code {
    return Intl.message(
      'OTP Code',
      name: 'rest_Verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Please read the agreement and confirm`
  String get selected_user_protocol {
    return Intl.message(
      'Please read the agreement and confirm',
      name: 'selected_user_protocol',
      desc: '',
      args: [],
    );
  }

  /// `Verification`
  String get Verification {
    return Intl.message(
      'Verification',
      name: 'Verification',
      desc: '',
      args: [],
    );
  }

  /// `verification`
  String get verification {
    return Intl.message(
      'verification',
      name: 'verification',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message('Search', name: 'search', desc: '', args: []);
  }

  /// `Copied successfully`
  String get copy {
    return Intl.message(
      'Copied successfully',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Photograph`
  String get photograph {
    return Intl.message('Photograph', name: 'photograph', desc: '', args: []);
  }

  /// `0~{value} characters`
  String nicknameMessage(Object value) {
    return Intl.message(
      '0~$value characters',
      name: 'nicknameMessage',
      desc: '',
      args: [value],
    );
  }

  /// `Edit`
  String get Edit {
    return Intl.message('Edit', name: 'Edit', desc: '', args: []);
  }

  /// `Copy Address`
  String get copyAddress {
    return Intl.message(
      'Copy Address',
      name: 'copyAddress',
      desc: '',
      args: [],
    );
  }

  /// `Enter verification code`
  String get please_enter_code {
    return Intl.message(
      'Enter verification code',
      name: 'please_enter_code',
      desc: '',
      args: [],
    );
  }

  /// `Address Information`
  String get address_Information {
    return Intl.message(
      'Address Information',
      name: 'address_Information',
      desc: '',
      args: [],
    );
  }

  /// `Please Input Address`
  String get please_input_address {
    return Intl.message(
      'Please Input Address',
      name: 'please_input_address',
      desc: '',
      args: [],
    );
  }

  /// `Description(Optional)`
  String get descO {
    return Intl.message(
      'Description(Optional)',
      name: 'descO',
      desc: '',
      args: [],
    );
  }

  /// `Account temporarily locked for one day`
  String get code_403 {
    return Intl.message(
      'Account temporarily locked for one day',
      name: 'code_403',
      desc: '',
      args: [],
    );
  }

  /// `The code is incorrect. Please try again.`
  String get code_err_tips {
    return Intl.message(
      'The code is incorrect. Please try again.',
      name: 'code_err_tips',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter Password`
  String get repeatPassword {
    return Intl.message(
      'Re-enter Password',
      name: 'repeatPassword',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Password`
  String get rest_Confirm_password {
    return Intl.message(
      'Confirm Password',
      name: 'rest_Confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Edit Profile`
  String get personalInformation {
    return Intl.message(
      'Edit Profile',
      name: 'personalInformation',
      desc: '',
      args: [],
    );
  }

  /// `Edit photo`
  String get editPhoto {
    return Intl.message('Edit photo', name: 'editPhoto', desc: '', args: []);
  }

  /// `Select from phone gallery`
  String get g_key_personal_1 {
    return Intl.message(
      'Select from phone gallery',
      name: 'g_key_personal_1',
      desc: '',
      args: [],
    );
  }

  /// `Wallet edit`
  String get g_key_wallet_edit {
    return Intl.message(
      'Wallet edit',
      name: 'g_key_wallet_edit',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get login_password {
    return Intl.message('Password', name: 'login_password', desc: '', args: []);
  }

  /// `Important Notice`
  String get importantNotice {
    return Intl.message(
      'Important Notice',
      name: 'importantNotice',
      desc: '',
      args: [],
    );
  }

  /// `File`
  String get file {
    return Intl.message('File', name: 'file', desc: '', args: []);
  }

  /// `Address`
  String get g_key_address {
    return Intl.message('Address', name: 'g_key_address', desc: '', args: []);
  }

  /// `Please enter a name`
  String get g_key_address_1 {
    return Intl.message(
      'Please enter a name',
      name: 'g_key_address_1',
      desc: '',
      args: [],
    );
  }

  /// `Please enter address`
  String get g_key_address_2 {
    return Intl.message(
      'Please enter address',
      name: 'g_key_address_2',
      desc: '',
      args: [],
    );
  }

  /// `Please select a coin type`
  String get g_key_address_3 {
    return Intl.message(
      'Please select a coin type',
      name: 'g_key_address_3',
      desc: '',
      args: [],
    );
  }

  /// `Edit address`
  String get g_key_address_4 {
    return Intl.message(
      'Edit address',
      name: 'g_key_address_4',
      desc: '',
      args: [],
    );
  }

  /// `Successfully deleted`
  String get g_key_address_5 {
    return Intl.message(
      'Successfully deleted',
      name: 'g_key_address_5',
      desc: '',
      args: [],
    );
  }

  /// `Choose Coins`
  String get g_key_address_6 {
    return Intl.message(
      'Choose Coins',
      name: 'g_key_address_6',
      desc: '',
      args: [],
    );
  }

  /// `Search coins`
  String get g_key_address_7 {
    return Intl.message(
      'Search coins',
      name: 'g_key_address_7',
      desc: '',
      args: [],
    );
  }

  /// `Please enter seed phrase`
  String get g_key_mnemonic {
    return Intl.message(
      'Please enter seed phrase',
      name: 'g_key_mnemonic',
      desc: '',
      args: [],
    );
  }

  /// `Find the latest version`
  String get g_key_v_k1 {
    return Intl.message(
      'Find the latest version',
      name: 'g_key_v_k1',
      desc: '',
      args: [],
    );
  }

  /// `Update immediately`
  String get g_key_v_k2 {
    return Intl.message(
      'Update immediately',
      name: 'g_key_v_k2',
      desc: '',
      args: [],
    );
  }

  /// `New version found`
  String get g_key_v_k3 {
    return Intl.message(
      'New version found',
      name: 'g_key_v_k3',
      desc: '',
      args: [],
    );
  }

  /// `Already the latest version`
  String get g_key_v_k4 {
    return Intl.message(
      'Already the latest version',
      name: 'g_key_v_k4',
      desc: '',
      args: [],
    );
  }

  /// `Share QR code`
  String get g_key_share_code {
    return Intl.message(
      'Share QR code',
      name: 'g_key_share_code',
      desc: '',
      args: [],
    );
  }

  /// `Share link`
  String get g_key_share_link {
    return Intl.message(
      'Share link',
      name: 'g_key_share_link',
      desc: '',
      args: [],
    );
  }

  /// `Share method`
  String get g_key_share_method {
    return Intl.message(
      'Share method',
      name: 'g_key_share_method',
      desc: '',
      args: [],
    );
  }

  /// `Share`
  String get g_share_v2_key_5 {
    return Intl.message('Share', name: 'g_share_v2_key_5', desc: '', args: []);
  }

  /// `Referral`
  String get g_share_v3_key_2 {
    return Intl.message(
      'Referral',
      name: 'g_share_v3_key_2',
      desc: '',
      args: [],
    );
  }

  /// `Refer friends and get N Tokens!`
  String get g_share_v3_key_3 {
    return Intl.message(
      'Refer friends and get N Tokens!',
      name: 'g_share_v3_key_3',
      desc: '',
      args: [],
    );
  }

  /// `You get up to `
  String get g_share_v3_key_4 {
    return Intl.message(
      'You get up to ',
      name: 'g_share_v3_key_4',
      desc: '',
      args: [],
    );
  }

  /// ` N when your referral starts verification!`
  String get g_share_v3_key_5 {
    return Intl.message(
      ' N when your referral starts verification!',
      name: 'g_share_v3_key_5',
      desc: '',
      args: [],
    );
  }

  /// `Refer via`
  String get g_share_v3_key_6 {
    return Intl.message(
      'Refer via',
      name: 'g_share_v3_key_6',
      desc: '',
      args: [],
    );
  }

  /// `Link`
  String get g_share_v3_key_7 {
    return Intl.message('Link', name: 'g_share_v3_key_7', desc: '', args: []);
  }

  /// `code`
  String get g_share_v3_key_8 {
    return Intl.message('code', name: 'g_share_v3_key_8', desc: '', args: []);
  }

  /// `Feedback`
  String get g_key_feedback {
    return Intl.message('Feedback', name: 'g_key_feedback', desc: '', args: []);
  }

  /// `Please fill in the feedback information`
  String get g_key_feedback_1 {
    return Intl.message(
      'Please fill in the feedback information',
      name: 'g_key_feedback_1',
      desc: '',
      args: [],
    );
  }

  /// `There are unuploaded attachments`
  String get g_key_feedback_2 {
    return Intl.message(
      'There are unuploaded attachments',
      name: 'g_key_feedback_2',
      desc: '',
      args: [],
    );
  }

  /// `Submission Failed`
  String get g_key_feedback_3 {
    return Intl.message(
      'Submission Failed',
      name: 'g_key_feedback_3',
      desc: '',
      args: [],
    );
  }

  /// `Submitted successfully`
  String get g_key_feedback_4 {
    return Intl.message(
      'Submitted successfully',
      name: 'g_key_feedback_4',
      desc: '',
      args: [],
    );
  }

  /// `Attachments`
  String get g_key_feedback_5 {
    return Intl.message(
      'Attachments',
      name: 'g_key_feedback_5',
      desc: '',
      args: [],
    );
  }

  /// `Upload up to 5 attachments, each attachment cannot be larger than 100MB`
  String get g_key_feedback_6 {
    return Intl.message(
      'Upload up to 5 attachments, each attachment cannot be larger than 100MB',
      name: 'g_key_feedback_6',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get g_key_feedback_7 {
    return Intl.message('Failed', name: 'g_key_feedback_7', desc: '', args: []);
  }

  /// `Click try`
  String get g_key_feedback_8 {
    return Intl.message(
      'Click try',
      name: 'g_key_feedback_8',
      desc: '',
      args: [],
    );
  }

  /// `Please log in`
  String get g_key_feedback_9 {
    return Intl.message(
      'Please log in',
      name: 'g_key_feedback_9',
      desc: '',
      args: [],
    );
  }

  /// `Start group chat`
  String get g_chat_key_1 {
    return Intl.message(
      'Start group chat',
      name: 'g_chat_key_1',
      desc: '',
      args: [],
    );
  }

  /// `New friend`
  String get g_chat_key_2 {
    return Intl.message('New friend', name: 'g_chat_key_2', desc: '', args: []);
  }

  /// `Added`
  String get g_chat_key_3 {
    return Intl.message('Added', name: 'g_chat_key_3', desc: '', args: []);
  }

  /// `Have expired`
  String get g_chat_key_4 {
    return Intl.message(
      'Have expired',
      name: 'g_chat_key_4',
      desc: '',
      args: [],
    );
  }

  /// `Wait`
  String get g_chat_key_5 {
    return Intl.message('Wait', name: 'g_chat_key_5', desc: '', args: []);
  }

  /// `Are you sure you want to add {value} as a friend`
  String g_chat_key_6(Object value) {
    return Intl.message(
      'Are you sure you want to add $value as a friend',
      name: 'g_chat_key_6',
      desc: '',
      args: [value],
    );
  }

  /// `Add friends`
  String get g_chat_key_8 {
    return Intl.message(
      'Add friends',
      name: 'g_chat_key_8',
      desc: '',
      args: [],
    );
  }

  /// `reason for application`
  String get g_chat_key_9 {
    return Intl.message(
      'reason for application',
      name: 'g_chat_key_9',
      desc: '',
      args: [],
    );
  }

  /// `I am {value}`
  String g_chat_key_10(Object value) {
    return Intl.message(
      'I am $value',
      name: 'g_chat_key_10',
      desc: '',
      args: [value],
    );
  }

  /// `Invite friends`
  String get g_chat_key_11 {
    return Intl.message(
      'Invite friends',
      name: 'g_chat_key_11',
      desc: '',
      args: [],
    );
  }

  /// `Select contact`
  String get g_chat_key_12 {
    return Intl.message(
      'Select contact',
      name: 'g_chat_key_12',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get g_chat_key_13 {
    return Intl.message('Finish', name: 'g_chat_key_13', desc: '', args: []);
  }

  /// `Select at least 2 contacts`
  String get g_chat_key_14 {
    return Intl.message(
      'Select at least 2 contacts',
      name: 'g_chat_key_14',
      desc: '',
      args: [],
    );
  }

  /// `Friend detail`
  String get g_chat_key_16 {
    return Intl.message(
      'Friend detail',
      name: 'g_chat_key_16',
      desc: '',
      args: [],
    );
  }

  /// `Group detail`
  String get g_chat_key_17 {
    return Intl.message(
      'Group detail',
      name: 'g_chat_key_17',
      desc: '',
      args: [],
    );
  }

  /// `View more group members`
  String get g_chat_key_18 {
    return Intl.message(
      'View more group members',
      name: 'g_chat_key_18',
      desc: '',
      args: [],
    );
  }

  /// `Group name`
  String get g_chat_key_19 {
    return Intl.message(
      'Group name',
      name: 'g_chat_key_19',
      desc: '',
      args: [],
    );
  }

  /// `Are we sure we're disbanding ?`
  String get g_chat_key_20 {
    return Intl.message(
      'Are we sure we\'re disbanding ?',
      name: 'g_chat_key_20',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to leave this group?`
  String get g_chat_key_21 {
    return Intl.message(
      'Are you sure you want to leave this group?',
      name: 'g_chat_key_21',
      desc: '',
      args: [],
    );
  }

  /// `Ungroup`
  String get g_chat_key_22 {
    return Intl.message('Ungroup', name: 'g_chat_key_22', desc: '', args: []);
  }

  /// `Leave group`
  String get g_chat_key_23 {
    return Intl.message(
      'Leave group',
      name: 'g_chat_key_23',
      desc: '',
      args: [],
    );
  }

  /// `Change the group chat name`
  String get g_chat_key_24 {
    return Intl.message(
      'Change the group chat name',
      name: 'g_chat_key_24',
      desc: '',
      args: [],
    );
  }

  /// `When the group chat name is changed, other members will be notified within the group.`
  String get g_chat_key_25 {
    return Intl.message(
      'When the group chat name is changed, other members will be notified within the group.',
      name: 'g_chat_key_25',
      desc: '',
      args: [],
    );
  }

  /// `Finish`
  String get g_chat_key_26 {
    return Intl.message('Finish', name: 'g_chat_key_26', desc: '', args: []);
  }

  /// `Friend add request`
  String get g_chat_key_27 {
    return Intl.message(
      'Friend add request',
      name: 'g_chat_key_27',
      desc: '',
      args: [],
    );
  }

  /// `Request to add you as a friend`
  String get g_chat_key_28 {
    return Intl.message(
      'Request to add you as a friend',
      name: 'g_chat_key_28',
      desc: '',
      args: [],
    );
  }

  /// `Friend request approved`
  String get g_chat_key_29 {
    return Intl.message(
      'Friend request approved',
      name: 'g_chat_key_29',
      desc: '',
      args: [],
    );
  }

  /// `You have been added as a friend`
  String get g_chat_key_30 {
    return Intl.message(
      'You have been added as a friend',
      name: 'g_chat_key_30',
      desc: '',
      args: [],
    );
  }

  /// `agree`
  String get g_chat_key_31 {
    return Intl.message('agree', name: 'g_chat_key_31', desc: '', args: []);
  }

  /// `Chat member({value})`
  String g_chat_key_32(Object value) {
    return Intl.message(
      'Chat member($value)',
      name: 'g_chat_key_32',
      desc: '',
      args: [value],
    );
  }

  /// `The password cannot be parsed properly, and the message cannot be sent temporarily. Please import the wallet when entering the group`
  String get g_chat_key_33 {
    return Intl.message(
      'The password cannot be parsed properly, and the message cannot be sent temporarily. Please import the wallet when entering the group',
      name: 'g_chat_key_33',
      desc: '',
      args: [],
    );
  }

  /// `Delete the chat history？`
  String get g_chat_key_34 {
    return Intl.message(
      'Delete the chat history？',
      name: 'g_chat_key_34',
      desc: '',
      args: [],
    );
  }

  /// `Remove member`
  String get g_chat_key_35 {
    return Intl.message(
      'Remove member',
      name: 'g_chat_key_35',
      desc: '',
      args: [],
    );
  }

  /// `My QR Code`
  String get g_chat_key_36 {
    return Intl.message(
      'My QR Code',
      name: 'g_chat_key_36',
      desc: '',
      args: [],
    );
  }

  /// `Report`
  String get g_chat_key_40 {
    return Intl.message('Report', name: 'g_chat_key_40', desc: '', args: []);
  }

  /// `New Chat`
  String get g_chat_key_41 {
    return Intl.message('New Chat', name: 'g_chat_key_41', desc: '', args: []);
  }

  /// `New Group`
  String get g_chat_key_42 {
    return Intl.message('New Group', name: 'g_chat_key_42', desc: '', args: []);
  }

  /// `QR Code`
  String get g_chat_key_43 {
    return Intl.message('QR Code', name: 'g_chat_key_43', desc: '', args: []);
  }

  /// `Report and Block`
  String get g_chat_key_44 {
    return Intl.message(
      'Report and Block',
      name: 'g_chat_key_44',
      desc: '',
      args: [],
    );
  }

  /// `This message will be forwarded to N42Wallet. This contact will not be notified.`
  String get g_chat_key_45 {
    return Intl.message(
      'This message will be forwarded to N42Wallet. This contact will not be notified.',
      name: 'g_chat_key_45',
      desc: '',
      args: [],
    );
  }

  /// `Video`
  String get g_chat_key_46 {
    return Intl.message('Video', name: 'g_chat_key_46', desc: '', args: []);
  }

  /// `Photo`
  String get g_chat_key_47 {
    return Intl.message('Photo', name: 'g_chat_key_47', desc: '', args: []);
  }

  /// `Delete Message`
  String get g_chat_key_48 {
    return Intl.message(
      'Delete Message',
      name: 'g_chat_key_48',
      desc: '',
      args: [],
    );
  }

  /// `Delete on my device`
  String get g_chat_key_49 {
    return Intl.message(
      'Delete on my device',
      name: 'g_chat_key_49',
      desc: '',
      args: [],
    );
  }

  /// `Agree`
  String get g_chat_key_50 {
    return Intl.message('Agree', name: 'g_chat_key_50', desc: '', args: []);
  }

  /// `Report Reason`
  String get g_chat_key_54 {
    return Intl.message(
      'Report Reason',
      name: 'g_chat_key_54',
      desc: '',
      args: [],
    );
  }

  /// `Enter your report reason`
  String get g_chat_key_55 {
    return Intl.message(
      'Enter your report reason',
      name: 'g_chat_key_55',
      desc: '',
      args: [],
    );
  }

  /// `We will verify your report and respond within 24 hours.`
  String get g_chat_key_56 {
    return Intl.message(
      'We will verify your report and respond within 24 hours.',
      name: 'g_chat_key_56',
      desc: '',
      args: [],
    );
  }

  /// `You reported this - Click to see`
  String get g_chat_key_57 {
    return Intl.message(
      'You reported this - Click to see',
      name: 'g_chat_key_57',
      desc: '',
      args: [],
    );
  }

  /// `Blacklist`
  String get g_chat_key_58 {
    return Intl.message('Blacklist', name: 'g_chat_key_58', desc: '', args: []);
  }

  /// `Remove`
  String get g_chat_key_59 {
    return Intl.message('Remove', name: 'g_chat_key_59', desc: '', args: []);
  }

  /// `No contact yet`
  String get g_chat_key_60 {
    return Intl.message(
      'No contact yet',
      name: 'g_chat_key_60',
      desc: '',
      args: [],
    );
  }

  /// `Today`
  String get g_chat_key_61 {
    return Intl.message('Today', name: 'g_chat_key_61', desc: '', args: []);
  }

  /// `Over 3 days ago`
  String get g_chat_key_62 {
    return Intl.message(
      'Over 3 days ago',
      name: 'g_chat_key_62',
      desc: '',
      args: [],
    );
  }

  /// `Block`
  String get g_chat_key_63 {
    return Intl.message('Block', name: 'g_chat_key_63', desc: '', args: []);
  }

  /// `Hey, I’m using N42Wallet to chat and send money. Install Wallet and message me at`
  String get g_chat_key_64 {
    return Intl.message(
      'Hey, I’m using N42Wallet to chat and send money. Install Wallet and message me at',
      name: 'g_chat_key_64',
      desc: '',
      args: [],
    );
  }

  /// `Reply`
  String get g_chat_key_66 {
    return Intl.message('Reply', name: 'g_chat_key_66', desc: '', args: []);
  }

  /// `The message has been deleted`
  String get g_chat_key_67 {
    return Intl.message(
      'The message has been deleted',
      name: 'g_chat_key_67',
      desc: '',
      args: [],
    );
  }

  /// `Someone @ me`
  String get g_chat_key_68 {
    return Intl.message(
      'Someone @ me',
      name: 'g_chat_key_68',
      desc: '',
      args: [],
    );
  }

  /// `Say hi`
  String get g_chat_key_69 {
    return Intl.message('Say hi', name: 'g_chat_key_69', desc: '', args: []);
  }

  /// `Chat`
  String get g_key_squad {
    return Intl.message('Chat', name: 'g_key_squad', desc: '', args: []);
  }

  /// `The file is too large to upload`
  String get g_key_squad_k11 {
    return Intl.message(
      'The file is too large to upload',
      name: 'g_key_squad_k11',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to delete the contact {value}?`
  String g_key_squad_k15(Object value) {
    return Intl.message(
      'Are you sure you want to delete the contact $value?',
      name: 'g_key_squad_k15',
      desc: '',
      args: [value],
    );
  }

  /// `Add Contact`
  String get g_key_squad_k18 {
    return Intl.message(
      'Add Contact',
      name: 'g_key_squad_k18',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get g_key_squad_k24 {
    return Intl.message('Contact', name: 'g_key_squad_k24', desc: '', args: []);
  }

  /// `Search by email`
  String get g_key_squad_k25 {
    return Intl.message(
      'Search by email',
      name: 'g_key_squad_k25',
      desc: '',
      args: [],
    );
  }

  /// `Reserved`
  String get g_key_xml_0 {
    return Intl.message('Reserved', name: 'g_key_xml_0', desc: '', args: []);
  }

  /// `Base Reserve`
  String get g_key_xml_1 {
    return Intl.message(
      'Base Reserve',
      name: 'g_key_xml_1',
      desc: '',
      args: [],
    );
  }

  /// `Every XRP account must reserve {value} XRP ({value1} drops) as a baseline, which cannot be spent.`
  String g_key_xml_11(Object value, Object value1) {
    return Intl.message(
      'Every XRP account must reserve $value XRP ($value1 drops) as a baseline, which cannot be spent.',
      name: 'g_key_xml_11',
      desc: '',
      args: [value, value1],
    );
  }

  /// `Incremental Reserve`
  String get g_key_xml_2 {
    return Intl.message(
      'Incremental Reserve',
      name: 'g_key_xml_2',
      desc: '',
      args: [],
    );
  }

  /// `For every object the account owns, {value} XRP ({value1} drops) is added to the reserve.`
  String g_key_xml_22(Object value, Object value1) {
    return Intl.message(
      'For every object the account owns, $value XRP ($value1 drops) is added to the reserve.',
      name: 'g_key_xml_22',
      desc: '',
      args: [value, value1],
    );
  }

  /// `Owned Objects Count`
  String get g_key_xml_3 {
    return Intl.message(
      'Owned Objects Count',
      name: 'g_key_xml_3',
      desc: '',
      args: [],
    );
  }

  /// `This account owns {value} objects, which means an additional {value1} XRP is reserved.`
  String g_key_xml_33(Object value, Object value1) {
    return Intl.message(
      'This account owns $value objects, which means an additional $value1 XRP is reserved.',
      name: 'g_key_xml_33',
      desc: '',
      args: [value, value1],
    );
  }

  /// `How to calculate total reserved amount`
  String get g_key_xml_4 {
    return Intl.message(
      'How to calculate total reserved amount',
      name: 'g_key_xml_4',
      desc: '',
      args: [],
    );
  }

  /// `Total Reserve = Base Reserve + (Owned Objects Count × Incremental Reserve)`
  String get g_key_xml_44 {
    return Intl.message(
      'Total Reserve = Base Reserve + (Owned Objects Count × Incremental Reserve)',
      name: 'g_key_xml_44',
      desc: '',
      args: [],
    );
  }

  /// `Slow`
  String get g_key_gas_slow {
    return Intl.message('Slow', name: 'g_key_gas_slow', desc: '', args: []);
  }

  /// `Standard`
  String get g_key_gas_standard {
    return Intl.message(
      'Standard',
      name: 'g_key_gas_standard',
      desc: '',
      args: [],
    );
  }

  /// `Fast`
  String get g_key_gas_fast {
    return Intl.message('Fast', name: 'g_key_gas_fast', desc: '', args: []);
  }

  /// `Gas Settings`
  String get g_key_gas_settings {
    return Intl.message(
      'Gas Settings',
      name: 'g_key_gas_settings',
      desc: '',
      args: [],
    );
  }

  /// `Est. Time`
  String get g_key_gas_estimated_time {
    return Intl.message(
      'Est. Time',
      name: 'g_key_gas_estimated_time',
      desc: '',
      args: [],
    );
  }

  /// `Base Fee`
  String get g_key_gas_base_fee {
    return Intl.message(
      'Base Fee',
      name: 'g_key_gas_base_fee',
      desc: '',
      args: [],
    );
  }

  /// `Priority Fee`
  String get g_key_gas_priority_fee {
    return Intl.message(
      'Priority Fee',
      name: 'g_key_gas_priority_fee',
      desc: '',
      args: [],
    );
  }

  /// `Max Fee`
  String get g_key_gas_max_fee {
    return Intl.message(
      'Max Fee',
      name: 'g_key_gas_max_fee',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get g_key_gas_custom {
    return Intl.message('Custom', name: 'g_key_gas_custom', desc: '', args: []);
  }

  /// `Network is busy`
  String get g_key_gas_network_busy {
    return Intl.message(
      'Network is busy',
      name: 'g_key_gas_network_busy',
      desc: '',
      args: [],
    );
  }

  /// `Network is normal`
  String get g_key_gas_network_normal {
    return Intl.message(
      'Network is normal',
      name: 'g_key_gas_network_normal',
      desc: '',
      args: [],
    );
  }

  /// `Network is idle`
  String get g_key_gas_network_idle {
    return Intl.message(
      'Network is idle',
      name: 'g_key_gas_network_idle',
      desc: '',
      args: [],
    );
  }

  /// `Bridge`
  String get g_key_bridge_title {
    return Intl.message(
      'Bridge',
      name: 'g_key_bridge_title',
      desc: '',
      args: [],
    );
  }

  /// `Bridge`
  String get g_key_bridge_swap {
    return Intl.message(
      'Bridge',
      name: 'g_key_bridge_swap',
      desc: '',
      args: [],
    );
  }

  /// `Get Quote`
  String get g_key_bridge_get_quote {
    return Intl.message(
      'Get Quote',
      name: 'g_key_bridge_get_quote',
      desc: '',
      args: [],
    );
  }

  /// `Route`
  String get g_key_bridge_route {
    return Intl.message(
      'Route',
      name: 'g_key_bridge_route',
      desc: '',
      args: [],
    );
  }

  /// `Bridge History`
  String get g_key_bridge_history {
    return Intl.message(
      'Bridge History',
      name: 'g_key_bridge_history',
      desc: '',
      args: [],
    );
  }

  /// `Refresh`
  String get g_key_bridge_refresh {
    return Intl.message(
      'Refresh',
      name: 'g_key_bridge_refresh',
      desc: '',
      args: [],
    );
  }

  /// `Search chain...`
  String get g_key_bridge_search_chain {
    return Intl.message(
      'Search chain...',
      name: 'g_key_bridge_search_chain',
      desc: '',
      args: [],
    );
  }

  /// `From Chain`
  String get g_key_bridge_from_chain {
    return Intl.message(
      'From Chain',
      name: 'g_key_bridge_from_chain',
      desc: '',
      args: [],
    );
  }

  /// `To Chain`
  String get g_key_bridge_to_chain {
    return Intl.message(
      'To Chain',
      name: 'g_key_bridge_to_chain',
      desc: '',
      args: [],
    );
  }

  /// `Select Token`
  String get g_key_bridge_select_token {
    return Intl.message(
      'Select Token',
      name: 'g_key_bridge_select_token',
      desc: '',
      args: [],
    );
  }

  /// `Amount`
  String get g_key_bridge_amount {
    return Intl.message(
      'Amount',
      name: 'g_key_bridge_amount',
      desc: '',
      args: [],
    );
  }

  /// `You will receive (estimated)`
  String get g_key_bridge_estimated_receive {
    return Intl.message(
      'You will receive (estimated)',
      name: 'g_key_bridge_estimated_receive',
      desc: '',
      args: [],
    );
  }

  /// `Bridge Fee`
  String get g_key_bridge_fee {
    return Intl.message(
      'Bridge Fee',
      name: 'g_key_bridge_fee',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Time`
  String get g_key_bridge_time {
    return Intl.message(
      'Estimated Time',
      name: 'g_key_bridge_time',
      desc: '',
      args: [],
    );
  }

  /// `No routes available`
  String get g_key_bridge_no_routes {
    return Intl.message(
      'No routes available',
      name: 'g_key_bridge_no_routes',
      desc: '',
      args: [],
    );
  }

  /// `Transaction Pending`
  String get g_key_bridge_tx_pending {
    return Intl.message(
      'Transaction Pending',
      name: 'g_key_bridge_tx_pending',
      desc: '',
      args: [],
    );
  }

  /// `Bridge Successful`
  String get g_key_bridge_tx_success {
    return Intl.message(
      'Bridge Successful',
      name: 'g_key_bridge_tx_success',
      desc: '',
      args: [],
    );
  }

  /// `Bridge Failed`
  String get g_key_bridge_tx_failed {
    return Intl.message(
      'Bridge Failed',
      name: 'g_key_bridge_tx_failed',
      desc: '',
      args: [],
    );
  }

  /// `Slippage`
  String get g_key_bridge_slippage {
    return Intl.message(
      'Slippage',
      name: 'g_key_bridge_slippage',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get g_key_bridge_recommended {
    return Intl.message(
      'Recommended',
      name: 'g_key_bridge_recommended',
      desc: '',
      args: [],
    );
  }

  /// `Fastest`
  String get g_key_bridge_fastest {
    return Intl.message(
      'Fastest',
      name: 'g_key_bridge_fastest',
      desc: '',
      args: [],
    );
  }

  /// `Cheapest`
  String get g_key_bridge_cheapest {
    return Intl.message(
      'Cheapest',
      name: 'g_key_bridge_cheapest',
      desc: '',
      args: [],
    );
  }

  /// `Staking`
  String get g_key_stake_title {
    return Intl.message(
      'Staking',
      name: 'g_key_stake_title',
      desc: '',
      args: [],
    );
  }

  /// `Stake`
  String get g_key_stake_stake {
    return Intl.message('Stake', name: 'g_key_stake_stake', desc: '', args: []);
  }

  /// `Unstake`
  String get g_key_stake_unstake {
    return Intl.message(
      'Unstake',
      name: 'g_key_stake_unstake',
      desc: '',
      args: [],
    );
  }

  /// `Claim Rewards`
  String get g_key_stake_claim {
    return Intl.message(
      'Claim Rewards',
      name: 'g_key_stake_claim',
      desc: '',
      args: [],
    );
  }

  /// `Restake`
  String get g_key_stake_restake {
    return Intl.message(
      'Restake',
      name: 'g_key_stake_restake',
      desc: '',
      args: [],
    );
  }

  /// `APY`
  String get g_key_stake_apy {
    return Intl.message('APY', name: 'g_key_stake_apy', desc: '', args: []);
  }

  /// `Total Staked`
  String get g_key_stake_total_staked {
    return Intl.message(
      'Total Staked',
      name: 'g_key_stake_total_staked',
      desc: '',
      args: [],
    );
  }

  /// `Rewards`
  String get g_key_stake_rewards {
    return Intl.message(
      'Rewards',
      name: 'g_key_stake_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Pending Rewards`
  String get g_key_stake_pending_rewards {
    return Intl.message(
      'Pending Rewards',
      name: 'g_key_stake_pending_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Unbonding`
  String get g_key_stake_unbonding {
    return Intl.message(
      'Unbonding',
      name: 'g_key_stake_unbonding',
      desc: '',
      args: [],
    );
  }

  /// `Unbonding Period`
  String get g_key_stake_unbonding_period {
    return Intl.message(
      'Unbonding Period',
      name: 'g_key_stake_unbonding_period',
      desc: '',
      args: [],
    );
  }

  /// `{value} days left`
  String g_key_stake_days_left(Object value) {
    return Intl.message(
      '$value days left',
      name: 'g_key_stake_days_left',
      desc: '',
      args: [value],
    );
  }

  /// `Validator`
  String get g_key_stake_validator {
    return Intl.message(
      'Validator',
      name: 'g_key_stake_validator',
      desc: '',
      args: [],
    );
  }

  /// `Validators`
  String get g_key_stake_validators {
    return Intl.message(
      'Validators',
      name: 'g_key_stake_validators',
      desc: '',
      args: [],
    );
  }

  /// `Select Validator`
  String get g_key_stake_select_validator {
    return Intl.message(
      'Select Validator',
      name: 'g_key_stake_select_validator',
      desc: '',
      args: [],
    );
  }

  /// `Commission`
  String get g_key_stake_commission {
    return Intl.message(
      'Commission',
      name: 'g_key_stake_commission',
      desc: '',
      args: [],
    );
  }

  /// `Uptime`
  String get g_key_stake_uptime {
    return Intl.message(
      'Uptime',
      name: 'g_key_stake_uptime',
      desc: '',
      args: [],
    );
  }

  /// `Delegators`
  String get g_key_stake_delegators {
    return Intl.message(
      'Delegators',
      name: 'g_key_stake_delegators',
      desc: '',
      args: [],
    );
  }

  /// `Minimum Stake`
  String get g_key_stake_min_stake {
    return Intl.message(
      'Minimum Stake',
      name: 'g_key_stake_min_stake',
      desc: '',
      args: [],
    );
  }

  /// `Liquid Staking`
  String get g_key_stake_liquid {
    return Intl.message(
      'Liquid Staking',
      name: 'g_key_stake_liquid',
      desc: '',
      args: [],
    );
  }

  /// `My Positions`
  String get g_key_stake_positions {
    return Intl.message(
      'My Positions',
      name: 'g_key_stake_positions',
      desc: '',
      args: [],
    );
  }

  /// `No staking positions`
  String get g_key_stake_no_positions {
    return Intl.message(
      'No staking positions',
      name: 'g_key_stake_no_positions',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get g_key_stake_active {
    return Intl.message(
      'Active',
      name: 'g_key_stake_active',
      desc: '',
      args: [],
    );
  }

  /// `Protocol`
  String get g_key_stake_protocol {
    return Intl.message(
      'Protocol',
      name: 'g_key_stake_protocol',
      desc: '',
      args: [],
    );
  }

  /// `Protocols`
  String get g_key_stake_protocols {
    return Intl.message(
      'Protocols',
      name: 'g_key_stake_protocols',
      desc: '',
      args: [],
    );
  }

  /// `Liquid`
  String get g_key_stake_liquid_tag {
    return Intl.message(
      'Liquid',
      name: 'g_key_stake_liquid_tag',
      desc: '',
      args: [],
    );
  }

  /// `No lock`
  String get g_key_stake_no_lock {
    return Intl.message(
      'No lock',
      name: 'g_key_stake_no_lock',
      desc: '',
      args: [],
    );
  }

  /// `{value}d unbond`
  String g_key_stake_d_unbond(Object value) {
    return Intl.message(
      '${value}d unbond',
      name: 'g_key_stake_d_unbond',
      desc: '',
      args: [value],
    );
  }

  /// `No staking positions yet`
  String get g_key_stake_no_positions_yet {
    return Intl.message(
      'No staking positions yet',
      name: 'g_key_stake_no_positions_yet',
      desc: '',
      args: [],
    );
  }

  /// `Start Staking`
  String get g_key_stake_start_staking {
    return Intl.message(
      'Start Staking',
      name: 'g_key_stake_start_staking',
      desc: '',
      args: [],
    );
  }

  /// `Total Staking Overview`
  String get g_key_stake_overview {
    return Intl.message(
      'Total Staking Overview',
      name: 'g_key_stake_overview',
      desc: '',
      args: [],
    );
  }

  /// `Active Positions`
  String get g_key_stake_active_positions {
    return Intl.message(
      'Active Positions',
      name: 'g_key_stake_active_positions',
      desc: '',
      args: [],
    );
  }

  /// `Avg APY`
  String get g_key_stake_avg_apy {
    return Intl.message(
      'Avg APY',
      name: 'g_key_stake_avg_apy',
      desc: '',
      args: [],
    );
  }

  /// `Staked`
  String get g_key_stake_staked {
    return Intl.message(
      'Staked',
      name: 'g_key_stake_staked',
      desc: '',
      args: [],
    );
  }

  /// `{value} days remaining`
  String g_key_stake_days_remaining(Object value) {
    return Intl.message(
      '$value days remaining',
      name: 'g_key_stake_days_remaining',
      desc: '',
      args: [value],
    );
  }

  /// `Amount`
  String get g_key_stake_amount {
    return Intl.message(
      'Amount',
      name: 'g_key_stake_amount',
      desc: '',
      args: [],
    );
  }

  /// `Amount to Unstake`
  String get g_key_stake_amount_unstake {
    return Intl.message(
      'Amount to Unstake',
      name: 'g_key_stake_amount_unstake',
      desc: '',
      args: [],
    );
  }

  /// `Est. Daily Reward`
  String get g_key_stake_estimated_daily {
    return Intl.message(
      'Est. Daily Reward',
      name: 'g_key_stake_estimated_daily',
      desc: '',
      args: [],
    );
  }

  /// `Est. Yearly Reward`
  String get g_key_stake_estimated_yearly {
    return Intl.message(
      'Est. Yearly Reward',
      name: 'g_key_stake_estimated_yearly',
      desc: '',
      args: [],
    );
  }

  /// `You will receive`
  String get g_key_stake_you_receive {
    return Intl.message(
      'You will receive',
      name: 'g_key_stake_you_receive',
      desc: '',
      args: [],
    );
  }

  /// `Go to Swap`
  String get g_key_stake_go_to_swap {
    return Intl.message(
      'Go to Swap',
      name: 'g_key_stake_go_to_swap',
      desc: '',
      args: [],
    );
  }

  /// `Liquid Staking`
  String get g_key_stake_liquid_staking_label {
    return Intl.message(
      'Liquid Staking',
      name: 'g_key_stake_liquid_staking_label',
      desc: '',
      args: [],
    );
  }

  /// `Your liquid token can be traded on DEX directly. Use Swap to exchange it back to the native asset.`
  String get g_key_stake_liquid_unstake_desc {
    return Intl.message(
      'Your liquid token can be traded on DEX directly. Use Swap to exchange it back to the native asset.',
      name: 'g_key_stake_liquid_unstake_desc',
      desc: '',
      args: [],
    );
  }

  /// `Unstaking takes {value} days. Your tokens will be locked during this period.`
  String g_key_stake_unbonding_warning(Object value) {
    return Intl.message(
      'Unstaking takes $value days. Your tokens will be locked during this period.',
      name: 'g_key_stake_unbonding_warning',
      desc: '',
      args: [value],
    );
  }

  /// `No active positions to unstake`
  String get g_key_stake_no_active_positions {
    return Intl.message(
      'No active positions to unstake',
      name: 'g_key_stake_no_active_positions',
      desc: '',
      args: [],
    );
  }

  /// `Select a position to unstake`
  String get g_key_stake_select_position {
    return Intl.message(
      'Select a position to unstake',
      name: 'g_key_stake_select_position',
      desc: '',
      args: [],
    );
  }

  /// `Transaction prepared successfully`
  String get g_key_stake_tx_prepared {
    return Intl.message(
      'Transaction prepared successfully',
      name: 'g_key_stake_tx_prepared',
      desc: '',
      args: [],
    );
  }

  /// `Wallet address not available`
  String get g_key_stake_no_wallet {
    return Intl.message(
      'Wallet address not available',
      name: 'g_key_stake_no_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Search validators...`
  String get g_key_stake_search_validator {
    return Intl.message(
      'Search validators...',
      name: 'g_key_stake_search_validator',
      desc: '',
      args: [],
    );
  }

  /// `Sort by`
  String get g_key_stake_sort_by {
    return Intl.message(
      'Sort by',
      name: 'g_key_stake_sort_by',
      desc: '',
      args: [],
    );
  }

  /// `No validators found`
  String get g_key_stake_no_validators {
    return Intl.message(
      'No validators found',
      name: 'g_key_stake_no_validators',
      desc: '',
      args: [],
    );
  }

  /// `Select a validator`
  String get g_key_stake_select_a_validator {
    return Intl.message(
      'Select a validator',
      name: 'g_key_stake_select_a_validator',
      desc: '',
      args: [],
    );
  }

  /// `Updating...`
  String get g_key_stake_updating {
    return Intl.message(
      'Updating...',
      name: 'g_key_stake_updating',
      desc: '',
      args: [],
    );
  }

  /// `BTC Self-Custody Staking`
  String get g_key_btc_stake_title {
    return Intl.message(
      'BTC Self-Custody Staking',
      name: 'g_key_btc_stake_title',
      desc: '',
      args: [],
    );
  }

  /// `Lock BTC to mint vBTC and earn rewards`
  String get g_key_btc_stake_subtitle {
    return Intl.message(
      'Lock BTC to mint vBTC and earn rewards',
      name: 'g_key_btc_stake_subtitle',
      desc: '',
      args: [],
    );
  }

  /// `How It Works`
  String get g_key_btc_stake_how_it_works {
    return Intl.message(
      'How It Works',
      name: 'g_key_btc_stake_how_it_works',
      desc: '',
      args: [],
    );
  }

  /// `Lock Your BTC`
  String get g_key_btc_stake_step1_title {
    return Intl.message(
      'Lock Your BTC',
      name: 'g_key_btc_stake_step1_title',
      desc: '',
      args: [],
    );
  }

  /// `Your BTC is locked in a 2-of-2 multisig address with a time-lock (CLTV), secured by your key and the N42 canister key.`
  String get g_key_btc_stake_step1_desc {
    return Intl.message(
      'Your BTC is locked in a 2-of-2 multisig address with a time-lock (CLTV), secured by your key and the N42 canister key.',
      name: 'g_key_btc_stake_step1_desc',
      desc: '',
      args: [],
    );
  }

  /// `Mint vBTC`
  String get g_key_btc_stake_step2_title {
    return Intl.message(
      'Mint vBTC',
      name: 'g_key_btc_stake_step2_title',
      desc: '',
      args: [],
    );
  }

  /// `After on-chain confirmation, vBTC is minted to your wallet at a 1:1 ratio.`
  String get g_key_btc_stake_step2_desc {
    return Intl.message(
      'After on-chain confirmation, vBTC is minted to your wallet at a 1:1 ratio.',
      name: 'g_key_btc_stake_step2_desc',
      desc: '',
      args: [],
    );
  }

  /// `Earn Rewards`
  String get g_key_btc_stake_step3_title {
    return Intl.message(
      'Earn Rewards',
      name: 'g_key_btc_stake_step3_title',
      desc: '',
      args: [],
    );
  }

  /// `Hold vBTC to earn staking rewards. vBTC is also usable in DeFi protocols.`
  String get g_key_btc_stake_step3_desc {
    return Intl.message(
      'Hold vBTC to earn staking rewards. vBTC is also usable in DeFi protocols.',
      name: 'g_key_btc_stake_step3_desc',
      desc: '',
      args: [],
    );
  }

  /// `Redeem After Unlock`
  String get g_key_btc_stake_step4_title {
    return Intl.message(
      'Redeem After Unlock',
      name: 'g_key_btc_stake_step4_title',
      desc: '',
      args: [],
    );
  }

  /// `When the lock period expires, burn your vBTC to receive your original BTC back.`
  String get g_key_btc_stake_step4_desc {
    return Intl.message(
      'When the lock period expires, burn your vBTC to receive your original BTC back.',
      name: 'g_key_btc_stake_step4_desc',
      desc: '',
      args: [],
    );
  }

  /// `Risk Warning`
  String get g_key_btc_stake_risk_warning {
    return Intl.message(
      'Risk Warning',
      name: 'g_key_btc_stake_risk_warning',
      desc: '',
      args: [],
    );
  }

  /// `Your BTC will be locked for the full staking period. Early withdrawal is not possible.`
  String get g_key_btc_stake_risk1 {
    return Intl.message(
      'Your BTC will be locked for the full staking period. Early withdrawal is not possible.',
      name: 'g_key_btc_stake_risk1',
      desc: '',
      args: [],
    );
  }

  /// `The lock is enforced by Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) and cannot be bypassed.`
  String get g_key_btc_stake_risk2 {
    return Intl.message(
      'The lock is enforced by Bitcoin OP_CHECKLOCKTIMEVERIFY (CLTV) and cannot be bypassed.',
      name: 'g_key_btc_stake_risk2',
      desc: '',
      args: [],
    );
  }

  /// `Smart contract risk: although audited, no protocol is entirely risk-free.`
  String get g_key_btc_stake_risk3 {
    return Intl.message(
      'Smart contract risk: although audited, no protocol is entirely risk-free.',
      name: 'g_key_btc_stake_risk3',
      desc: '',
      args: [],
    );
  }

  /// `Minimum staking: 0.001 BTC. Minimum lock period: 0.125 days (~3 hours).`
  String get g_key_btc_stake_risk4 {
    return Intl.message(
      'Minimum staking: 0.001 BTC. Minimum lock period: 0.125 days (~3 hours).',
      name: 'g_key_btc_stake_risk4',
      desc: '',
      args: [],
    );
  }

  /// `I understand the risks and wish to proceed`
  String get g_key_btc_stake_acknowledge {
    return Intl.message(
      'I understand the risks and wish to proceed',
      name: 'g_key_btc_stake_acknowledge',
      desc: '',
      args: [],
    );
  }

  /// `Continue to Stake`
  String get g_key_btc_stake_continue {
    return Intl.message(
      'Continue to Stake',
      name: 'g_key_btc_stake_continue',
      desc: '',
      args: [],
    );
  }

  /// `BTC will be locked until the timelock expires. Complete the staking process in the interface below.`
  String get g_key_btc_stake_reminder {
    return Intl.message(
      'BTC will be locked until the timelock expires. Complete the staking process in the interface below.',
      name: 'g_key_btc_stake_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Redeem vBTC`
  String get g_key_btc_redeem_title {
    return Intl.message(
      'Redeem vBTC',
      name: 'g_key_btc_redeem_title',
      desc: '',
      args: [],
    );
  }

  /// `Locked until`
  String get g_key_btc_redeem_locked_until {
    return Intl.message(
      'Locked until',
      name: 'g_key_btc_redeem_locked_until',
      desc: '',
      args: [],
    );
  }

  /// `Unlocked — ready to redeem`
  String get g_key_btc_redeem_unlocked {
    return Intl.message(
      'Unlocked — ready to redeem',
      name: 'g_key_btc_redeem_unlocked',
      desc: '',
      args: [],
    );
  }

  /// `BTC still locked`
  String get g_key_btc_redeem_still_locked {
    return Intl.message(
      'BTC still locked',
      name: 'g_key_btc_redeem_still_locked',
      desc: '',
      args: [],
    );
  }

  /// `Verify the lock period has expired before submitting your redemption.`
  String get g_key_btc_redeem_reminder {
    return Intl.message(
      'Verify the lock period has expired before submitting your redemption.',
      name: 'g_key_btc_redeem_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get g_key_change_password {
    return Intl.message(
      'Change Password',
      name: 'g_key_change_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter your current password and set a new password`
  String get g_key_change_password_desc {
    return Intl.message(
      'Enter your current password and set a new password',
      name: 'g_key_change_password_desc',
      desc: '',
      args: [],
    );
  }

  /// `Current Password`
  String get g_key_old_password {
    return Intl.message(
      'Current Password',
      name: 'g_key_old_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter current password`
  String get g_key_enter_old_password {
    return Intl.message(
      'Enter current password',
      name: 'g_key_enter_old_password',
      desc: '',
      args: [],
    );
  }

  /// `New Password`
  String get g_key_new_password {
    return Intl.message(
      'New Password',
      name: 'g_key_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter new password`
  String get g_key_enter_new_password {
    return Intl.message(
      'Enter new password',
      name: 'g_key_enter_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Confirm New Password`
  String get g_key_confirm_new_password {
    return Intl.message(
      'Confirm New Password',
      name: 'g_key_confirm_new_password',
      desc: '',
      args: [],
    );
  }

  /// `Re-enter new password`
  String get g_key_enter_confirm_password {
    return Intl.message(
      'Re-enter new password',
      name: 'g_key_enter_confirm_password',
      desc: '',
      args: [],
    );
  }

  /// `Password is required`
  String get g_key_password_required {
    return Intl.message(
      'Password is required',
      name: 'g_key_password_required',
      desc: '',
      args: [],
    );
  }

  /// `Password must be at least 6 characters`
  String get g_key_password_min_length {
    return Intl.message(
      'Password must be at least 6 characters',
      name: 'g_key_password_min_length',
      desc: '',
      args: [],
    );
  }

  /// `New password must be different from current password`
  String get g_key_new_password_same_as_old {
    return Intl.message(
      'New password must be different from current password',
      name: 'g_key_new_password_same_as_old',
      desc: '',
      args: [],
    );
  }

  /// `Passwords do not match`
  String get g_key_passwords_not_match {
    return Intl.message(
      'Passwords do not match',
      name: 'g_key_passwords_not_match',
      desc: '',
      args: [],
    );
  }

  /// `Password Requirements`
  String get g_key_password_requirements {
    return Intl.message(
      'Password Requirements',
      name: 'g_key_password_requirements',
      desc: '',
      args: [],
    );
  }

  /// `At least 6 characters`
  String get g_key_password_req_length {
    return Intl.message(
      'At least 6 characters',
      name: 'g_key_password_req_length',
      desc: '',
      args: [],
    );
  }

  /// `Different from current password`
  String get g_key_password_req_different {
    return Intl.message(
      'Different from current password',
      name: 'g_key_password_req_different',
      desc: '',
      args: [],
    );
  }

  /// `Password changed successfully`
  String get g_key_password_changed_success {
    return Intl.message(
      'Password changed successfully',
      name: 'g_key_password_changed_success',
      desc: '',
      args: [],
    );
  }

  /// `Reset Password`
  String get g_key_reset_password {
    return Intl.message(
      'Reset Password',
      name: 'g_key_reset_password',
      desc: '',
      args: [],
    );
  }

  /// `Enter your email address to receive a verification code`
  String get g_key_reset_password_email_desc {
    return Intl.message(
      'Enter your email address to receive a verification code',
      name: 'g_key_reset_password_email_desc',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get g_key_email {
    return Intl.message('Email', name: 'g_key_email', desc: '', args: []);
  }

  /// `Enter your email address`
  String get g_key_enter_email {
    return Intl.message(
      'Enter your email address',
      name: 'g_key_enter_email',
      desc: '',
      args: [],
    );
  }

  /// `Email is required`
  String get g_key_email_required {
    return Intl.message(
      'Email is required',
      name: 'g_key_email_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter a valid email address`
  String get g_key_email_invalid {
    return Intl.message(
      'Please enter a valid email address',
      name: 'g_key_email_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Send Verification Code`
  String get g_key_send_code {
    return Intl.message(
      'Send Verification Code',
      name: 'g_key_send_code',
      desc: '',
      args: [],
    );
  }

  /// `Email`
  String get g_key_step_email {
    return Intl.message('Email', name: 'g_key_step_email', desc: '', args: []);
  }

  /// `Verify`
  String get g_key_step_verify {
    return Intl.message(
      'Verify',
      name: 'g_key_step_verify',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get g_key_step_password {
    return Intl.message(
      'Password',
      name: 'g_key_step_password',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent to {value}`
  String g_key_verification_code_sent(Object value) {
    return Intl.message(
      'Verification code sent to $value',
      name: 'g_key_verification_code_sent',
      desc: '',
      args: [value],
    );
  }

  /// `Verification Code`
  String get g_key_verification_code {
    return Intl.message(
      'Verification Code',
      name: 'g_key_verification_code',
      desc: '',
      args: [],
    );
  }

  /// `Verification code is required`
  String get g_key_code_required {
    return Intl.message(
      'Verification code is required',
      name: 'g_key_code_required',
      desc: '',
      args: [],
    );
  }

  /// `Please enter 6-digit code`
  String get g_key_code_length {
    return Intl.message(
      'Please enter 6-digit code',
      name: 'g_key_code_length',
      desc: '',
      args: [],
    );
  }

  /// `Change Email`
  String get g_key_change_email {
    return Intl.message(
      'Change Email',
      name: 'g_key_change_email',
      desc: '',
      args: [],
    );
  }

  /// `Resend Code`
  String get g_key_resend_code {
    return Intl.message(
      'Resend Code',
      name: 'g_key_resend_code',
      desc: '',
      args: [],
    );
  }

  /// `Verification code sent`
  String get g_key_code_sent {
    return Intl.message(
      'Verification code sent',
      name: 'g_key_code_sent',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get g_key_next {
    return Intl.message('Next', name: 'g_key_next', desc: '', args: []);
  }

  /// `Set your new password`
  String get g_key_set_new_password_desc {
    return Intl.message(
      'Set your new password',
      name: 'g_key_set_new_password_desc',
      desc: '',
      args: [],
    );
  }

  /// `Password reset successfully`
  String get g_key_password_reset_success {
    return Intl.message(
      'Password reset successfully',
      name: 'g_key_password_reset_success',
      desc: '',
      args: [],
    );
  }

  /// `Forgot Password?`
  String get g_key_forgot_password {
    return Intl.message(
      'Forgot Password?',
      name: 'g_key_forgot_password',
      desc: '',
      args: [],
    );
  }

  /// `Hardware Wallet`
  String get g_key_hw_title {
    return Intl.message(
      'Hardware Wallet',
      name: 'g_key_hw_title',
      desc: '',
      args: [],
    );
  }

  /// `Connect Hardware Wallet`
  String get g_key_hw_connect {
    return Intl.message(
      'Connect Hardware Wallet',
      name: 'g_key_hw_connect',
      desc: '',
      args: [],
    );
  }

  /// `Scanning for devices...`
  String get g_key_hw_scanning {
    return Intl.message(
      'Scanning for devices...',
      name: 'g_key_hw_scanning',
      desc: '',
      args: [],
    );
  }

  /// `Disconnected`
  String get g_key_hw_disconnected {
    return Intl.message(
      'Disconnected',
      name: 'g_key_hw_disconnected',
      desc: '',
      args: [],
    );
  }

  /// `Ledger`
  String get g_key_hw_ledger {
    return Intl.message('Ledger', name: 'g_key_hw_ledger', desc: '', args: []);
  }

  /// `Trezor`
  String get g_key_hw_trezor {
    return Intl.message('Trezor', name: 'g_key_hw_trezor', desc: '', args: []);
  }

  /// `Select Device`
  String get g_key_hw_select_device {
    return Intl.message(
      'Select Device',
      name: 'g_key_hw_select_device',
      desc: '',
      args: [],
    );
  }

  /// `No devices found`
  String get g_key_hw_no_devices {
    return Intl.message(
      'No devices found',
      name: 'g_key_hw_no_devices',
      desc: '',
      args: [],
    );
  }

  /// `Please enable Bluetooth`
  String get g_key_hw_enable_bluetooth {
    return Intl.message(
      'Please enable Bluetooth',
      name: 'g_key_hw_enable_bluetooth',
      desc: '',
      args: [],
    );
  }

  /// `Please open the {value} app on your device`
  String g_key_hw_open_app(Object value) {
    return Intl.message(
      'Please open the $value app on your device',
      name: 'g_key_hw_open_app',
      desc: '',
      args: [value],
    );
  }

  /// `Confirm on your device`
  String get g_key_hw_confirm_on_device {
    return Intl.message(
      'Confirm on your device',
      name: 'g_key_hw_confirm_on_device',
      desc: '',
      args: [],
    );
  }

  /// `Sign Transaction`
  String get g_key_hw_sign_tx {
    return Intl.message(
      'Sign Transaction',
      name: 'g_key_hw_sign_tx',
      desc: '',
      args: [],
    );
  }

  /// `Sign Message`
  String get g_key_hw_sign_message {
    return Intl.message(
      'Sign Message',
      name: 'g_key_hw_sign_message',
      desc: '',
      args: [],
    );
  }

  /// `Rejected on device`
  String get g_key_hw_rejected {
    return Intl.message(
      'Rejected on device',
      name: 'g_key_hw_rejected',
      desc: '',
      args: [],
    );
  }

  /// `Connection timeout`
  String get g_key_hw_timeout {
    return Intl.message(
      'Connection timeout',
      name: 'g_key_hw_timeout',
      desc: '',
      args: [],
    );
  }

  /// `Accounts`
  String get g_key_hw_accounts {
    return Intl.message(
      'Accounts',
      name: 'g_key_hw_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Add Account`
  String get g_key_hw_add_account {
    return Intl.message(
      'Add Account',
      name: 'g_key_hw_add_account',
      desc: '',
      args: [],
    );
  }

  /// `Derivation Path`
  String get g_key_hw_derivation_path {
    return Intl.message(
      'Derivation Path',
      name: 'g_key_hw_derivation_path',
      desc: '',
      args: [],
    );
  }

  /// `Firmware Version`
  String get g_key_hw_firmware {
    return Intl.message(
      'Firmware Version',
      name: 'g_key_hw_firmware',
      desc: '',
      args: [],
    );
  }

  /// `Signal Strength`
  String get g_key_hw_signal_strength {
    return Intl.message(
      'Signal Strength',
      name: 'g_key_hw_signal_strength',
      desc: '',
      args: [],
    );
  }

  /// `Batch Transfer`
  String get g_key_batch_title {
    return Intl.message(
      'Batch Transfer',
      name: 'g_key_batch_title',
      desc: '',
      args: [],
    );
  }

  /// `Add Recipient`
  String get g_key_batch_add_recipient {
    return Intl.message(
      'Add Recipient',
      name: 'g_key_batch_add_recipient',
      desc: '',
      args: [],
    );
  }

  /// `Recipients`
  String get g_key_batch_recipients {
    return Intl.message(
      'Recipients',
      name: 'g_key_batch_recipients',
      desc: '',
      args: [],
    );
  }

  /// `Total Amount`
  String get g_key_batch_total_amount {
    return Intl.message(
      'Total Amount',
      name: 'g_key_batch_total_amount',
      desc: '',
      args: [],
    );
  }

  /// `Gas Savings`
  String get g_key_batch_gas_savings {
    return Intl.message(
      'Gas Savings',
      name: 'g_key_batch_gas_savings',
      desc: '',
      args: [],
    );
  }

  /// `Import CSV`
  String get g_key_batch_import_csv {
    return Intl.message(
      'Import CSV',
      name: 'g_key_batch_import_csv',
      desc: '',
      args: [],
    );
  }

  /// `Export CSV`
  String get g_key_batch_export_csv {
    return Intl.message(
      'Export CSV',
      name: 'g_key_batch_export_csv',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get g_key_batch_clear_all {
    return Intl.message(
      'Clear All',
      name: 'g_key_batch_clear_all',
      desc: '',
      args: [],
    );
  }

  /// `Preview`
  String get g_key_batch_preview {
    return Intl.message(
      'Preview',
      name: 'g_key_batch_preview',
      desc: '',
      args: [],
    );
  }

  /// `Execute Batch`
  String get g_key_batch_execute {
    return Intl.message(
      'Execute Batch',
      name: 'g_key_batch_execute',
      desc: '',
      args: [],
    );
  }

  /// `Invalid address at row {value}`
  String g_key_batch_invalid_address(Object value) {
    return Intl.message(
      'Invalid address at row $value',
      name: 'g_key_batch_invalid_address',
      desc: '',
      args: [value],
    );
  }

  /// `Invalid amount at row {value}`
  String g_key_batch_invalid_amount(Object value) {
    return Intl.message(
      'Invalid amount at row $value',
      name: 'g_key_batch_invalid_amount',
      desc: '',
      args: [value],
    );
  }

  /// `Duplicate address at row {value}`
  String g_key_batch_duplicate_address(Object value) {
    return Intl.message(
      'Duplicate address at row $value',
      name: 'g_key_batch_duplicate_address',
      desc: '',
      args: [value],
    );
  }

  /// `CSV Format: address,amount,label`
  String get g_key_batch_csv_format {
    return Intl.message(
      'CSV Format: address,amount,label',
      name: 'g_key_batch_csv_format',
      desc: '',
      args: [],
    );
  }

  /// `Maximum {value} recipients`
  String g_key_batch_max_recipients(Object value) {
    return Intl.message(
      'Maximum $value recipients',
      name: 'g_key_batch_max_recipients',
      desc: '',
      args: [value],
    );
  }

  /// `Airdrop Tracker`
  String get g_key_airdrop_title {
    return Intl.message(
      'Airdrop Tracker',
      name: 'g_key_airdrop_title',
      desc: '',
      args: [],
    );
  }

  /// `Upcoming`
  String get g_key_airdrop_upcoming {
    return Intl.message(
      'Upcoming',
      name: 'g_key_airdrop_upcoming',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get g_key_airdrop_active {
    return Intl.message(
      'Active',
      name: 'g_key_airdrop_active',
      desc: '',
      args: [],
    );
  }

  /// `Claimed`
  String get g_key_airdrop_claimed {
    return Intl.message(
      'Claimed',
      name: 'g_key_airdrop_claimed',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get g_key_airdrop_expired {
    return Intl.message(
      'Expired',
      name: 'g_key_airdrop_expired',
      desc: '',
      args: [],
    );
  }

  /// `Eligible`
  String get g_key_airdrop_eligible {
    return Intl.message(
      'Eligible',
      name: 'g_key_airdrop_eligible',
      desc: '',
      args: [],
    );
  }

  /// `Not Eligible`
  String get g_key_airdrop_not_eligible {
    return Intl.message(
      'Not Eligible',
      name: 'g_key_airdrop_not_eligible',
      desc: '',
      args: [],
    );
  }

  /// `Check Eligibility`
  String get g_key_airdrop_check_eligibility {
    return Intl.message(
      'Check Eligibility',
      name: 'g_key_airdrop_check_eligibility',
      desc: '',
      args: [],
    );
  }

  /// `Claim`
  String get g_key_airdrop_claim {
    return Intl.message(
      'Claim',
      name: 'g_key_airdrop_claim',
      desc: '',
      args: [],
    );
  }

  /// `Estimated Value`
  String get g_key_airdrop_estimated_value {
    return Intl.message(
      'Estimated Value',
      name: 'g_key_airdrop_estimated_value',
      desc: '',
      args: [],
    );
  }

  /// `Deadline`
  String get g_key_airdrop_deadline {
    return Intl.message(
      'Deadline',
      name: 'g_key_airdrop_deadline',
      desc: '',
      args: [],
    );
  }

  /// `{value} days left`
  String g_key_airdrop_days_left(Object value) {
    return Intl.message(
      '$value days left',
      name: 'g_key_airdrop_days_left',
      desc: '',
      args: [value],
    );
  }

  /// `Requirements`
  String get g_key_airdrop_requirements {
    return Intl.message(
      'Requirements',
      name: 'g_key_airdrop_requirements',
      desc: '',
      args: [],
    );
  }

  /// `Requirement met`
  String get g_key_airdrop_requirement_met {
    return Intl.message(
      'Requirement met',
      name: 'g_key_airdrop_requirement_met',
      desc: '',
      args: [],
    );
  }

  /// `Not met`
  String get g_key_airdrop_requirement_not_met {
    return Intl.message(
      'Not met',
      name: 'g_key_airdrop_requirement_not_met',
      desc: '',
      args: [],
    );
  }

  /// `Total Claimed`
  String get g_key_airdrop_total_claimed {
    return Intl.message(
      'Total Claimed',
      name: 'g_key_airdrop_total_claimed',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get g_key_airdrop_pending {
    return Intl.message(
      'Pending',
      name: 'g_key_airdrop_pending',
      desc: '',
      args: [],
    );
  }

  /// `High Priority`
  String get g_key_airdrop_priority_high {
    return Intl.message(
      'High Priority',
      name: 'g_key_airdrop_priority_high',
      desc: '',
      args: [],
    );
  }

  /// `Medium Priority`
  String get g_key_airdrop_priority_medium {
    return Intl.message(
      'Medium Priority',
      name: 'g_key_airdrop_priority_medium',
      desc: '',
      args: [],
    );
  }

  /// `Low Priority`
  String get g_key_airdrop_priority_low {
    return Intl.message(
      'Low Priority',
      name: 'g_key_airdrop_priority_low',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get g_key_airdrop_filter {
    return Intl.message(
      'Filter',
      name: 'g_key_airdrop_filter',
      desc: '',
      args: [],
    );
  }

  /// `Sort By`
  String get g_key_airdrop_sort_by {
    return Intl.message(
      'Sort By',
      name: 'g_key_airdrop_sort_by',
      desc: '',
      args: [],
    );
  }

  /// `No airdrops available`
  String get g_key_airdrop_no_airdrops {
    return Intl.message(
      'No airdrops available',
      name: 'g_key_airdrop_no_airdrops',
      desc: '',
      args: [],
    );
  }

  /// `Points`
  String get g_key_loyalty_title {
    return Intl.message(
      'Points',
      name: 'g_key_loyalty_title',
      desc: '',
      args: [],
    );
  }

  /// `Points`
  String get g_key_loyalty_points {
    return Intl.message(
      'Points',
      name: 'g_key_loyalty_points',
      desc: '',
      args: [],
    );
  }

  /// `Total Points`
  String get g_key_loyalty_total_points {
    return Intl.message(
      'Total Points',
      name: 'g_key_loyalty_total_points',
      desc: '',
      args: [],
    );
  }

  /// `Available Points`
  String get g_key_loyalty_available_points {
    return Intl.message(
      'Available Points',
      name: 'g_key_loyalty_available_points',
      desc: '',
      args: [],
    );
  }

  /// `Tier`
  String get g_key_loyalty_tier {
    return Intl.message('Tier', name: 'g_key_loyalty_tier', desc: '', args: []);
  }

  /// `Bronze`
  String get g_key_loyalty_tier_bronze {
    return Intl.message(
      'Bronze',
      name: 'g_key_loyalty_tier_bronze',
      desc: '',
      args: [],
    );
  }

  /// `Silver`
  String get g_key_loyalty_tier_silver {
    return Intl.message(
      'Silver',
      name: 'g_key_loyalty_tier_silver',
      desc: '',
      args: [],
    );
  }

  /// `Gold`
  String get g_key_loyalty_tier_gold {
    return Intl.message(
      'Gold',
      name: 'g_key_loyalty_tier_gold',
      desc: '',
      args: [],
    );
  }

  /// `Platinum`
  String get g_key_loyalty_tier_platinum {
    return Intl.message(
      'Platinum',
      name: 'g_key_loyalty_tier_platinum',
      desc: '',
      args: [],
    );
  }

  /// `Diamond`
  String get g_key_loyalty_tier_diamond {
    return Intl.message(
      'Diamond',
      name: 'g_key_loyalty_tier_diamond',
      desc: '',
      args: [],
    );
  }

  /// `Next Tier`
  String get g_key_loyalty_next_tier {
    return Intl.message(
      'Next Tier',
      name: 'g_key_loyalty_next_tier',
      desc: '',
      args: [],
    );
  }

  /// `{value} points to next tier`
  String g_key_loyalty_points_to_next(Object value) {
    return Intl.message(
      '$value points to next tier',
      name: 'g_key_loyalty_points_to_next',
      desc: '',
      args: [value],
    );
  }

  /// `Tasks`
  String get g_key_loyalty_tasks {
    return Intl.message(
      'Tasks',
      name: 'g_key_loyalty_tasks',
      desc: '',
      args: [],
    );
  }

  /// `Daily Check-in`
  String get g_key_loyalty_daily_checkin {
    return Intl.message(
      'Daily Check-in',
      name: 'g_key_loyalty_daily_checkin',
      desc: '',
      args: [],
    );
  }

  /// `Task Complete`
  String get g_key_loyalty_task_complete {
    return Intl.message(
      'Task Complete',
      name: 'g_key_loyalty_task_complete',
      desc: '',
      args: [],
    );
  }

  /// `Claim Points`
  String get g_key_loyalty_claim_points {
    return Intl.message(
      'Claim Points',
      name: 'g_key_loyalty_claim_points',
      desc: '',
      args: [],
    );
  }

  /// `Rewards`
  String get g_key_loyalty_rewards {
    return Intl.message(
      'Rewards',
      name: 'g_key_loyalty_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Redeem`
  String get g_key_loyalty_redeem {
    return Intl.message(
      'Redeem',
      name: 'g_key_loyalty_redeem',
      desc: '',
      args: [],
    );
  }

  /// `Points History`
  String get g_key_loyalty_history {
    return Intl.message(
      'Points History',
      name: 'g_key_loyalty_history',
      desc: '',
      args: [],
    );
  }

  /// `Earned`
  String get g_key_loyalty_earned {
    return Intl.message(
      'Earned',
      name: 'g_key_loyalty_earned',
      desc: '',
      args: [],
    );
  }

  /// `Spent`
  String get g_key_loyalty_spent {
    return Intl.message(
      'Spent',
      name: 'g_key_loyalty_spent',
      desc: '',
      args: [],
    );
  }

  /// `Referral`
  String get g_key_loyalty_referral {
    return Intl.message(
      'Referral',
      name: 'g_key_loyalty_referral',
      desc: '',
      args: [],
    );
  }

  /// `Your Referral Code`
  String get g_key_loyalty_referral_code {
    return Intl.message(
      'Your Referral Code',
      name: 'g_key_loyalty_referral_code',
      desc: '',
      args: [],
    );
  }

  /// `Referral Link`
  String get g_key_loyalty_referral_link {
    return Intl.message(
      'Referral Link',
      name: 'g_key_loyalty_referral_link',
      desc: '',
      args: [],
    );
  }

  /// `Invited Friends`
  String get g_key_loyalty_invited_friends {
    return Intl.message(
      'Invited Friends',
      name: 'g_key_loyalty_invited_friends',
      desc: '',
      args: [],
    );
  }

  /// `Referral Bonus`
  String get g_key_loyalty_referral_bonus {
    return Intl.message(
      'Referral Bonus',
      name: 'g_key_loyalty_referral_bonus',
      desc: '',
      args: [],
    );
  }

  /// `No tasks available`
  String get g_key_loyalty_no_tasks {
    return Intl.message(
      'No tasks available',
      name: 'g_key_loyalty_no_tasks',
      desc: '',
      args: [],
    );
  }

  /// `No rewards available`
  String get g_key_loyalty_no_rewards {
    return Intl.message(
      'No rewards available',
      name: 'g_key_loyalty_no_rewards',
      desc: '',
      args: [],
    );
  }

  /// `Check-in successful!`
  String get g_key_loyalty_checkin_success {
    return Intl.message(
      'Check-in successful!',
      name: 'g_key_loyalty_checkin_success',
      desc: '',
      args: [],
    );
  }

  /// `Check-in failed, please try again`
  String get g_key_loyalty_checkin_failed {
    return Intl.message(
      'Check-in failed, please try again',
      name: 'g_key_loyalty_checkin_failed',
      desc: '',
      args: [],
    );
  }

  /// `Task completed!`
  String get g_key_loyalty_complete_success {
    return Intl.message(
      'Task completed!',
      name: 'g_key_loyalty_complete_success',
      desc: '',
      args: [],
    );
  }

  /// `Task failed, please try again`
  String get g_key_loyalty_complete_failed {
    return Intl.message(
      'Task failed, please try again',
      name: 'g_key_loyalty_complete_failed',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get g_key_loyalty_checkin_done {
    return Intl.message(
      'Done',
      name: 'g_key_loyalty_checkin_done',
      desc: '',
      args: [],
    );
  }

  /// `Check In`
  String get g_key_loyalty_checkin_btn {
    return Intl.message(
      'Check In',
      name: 'g_key_loyalty_checkin_btn',
      desc: '',
      args: [],
    );
  }

  /// `Checked in today!`
  String get g_key_loyalty_checked_today {
    return Intl.message(
      'Checked in today!',
      name: 'g_key_loyalty_checked_today',
      desc: '',
      args: [],
    );
  }

  /// `Earn {value} points`
  String g_key_loyalty_earn_points(Object value) {
    return Intl.message(
      'Earn $value points',
      name: 'g_key_loyalty_earn_points',
      desc: '',
      args: [value],
    );
  }

  /// `Invite`
  String get g_key_loyalty_invite {
    return Intl.message(
      'Invite',
      name: 'g_key_loyalty_invite',
      desc: '',
      args: [],
    );
  }

  /// `Invite Friends`
  String get g_key_loyalty_invite_friends {
    return Intl.message(
      'Invite Friends',
      name: 'g_key_loyalty_invite_friends',
      desc: '',
      args: [],
    );
  }

  /// `Earn {value} points for each friend who joins!`
  String g_key_loyalty_invite_bonus(Object value) {
    return Intl.message(
      'Earn $value points for each friend who joins!',
      name: 'g_key_loyalty_invite_bonus',
      desc: '',
      args: [value],
    );
  }

  /// `Total Earned`
  String get g_key_loyalty_total_earned {
    return Intl.message(
      'Total Earned',
      name: 'g_key_loyalty_total_earned',
      desc: '',
      args: [],
    );
  }

  /// `Used`
  String get g_key_loyalty_used {
    return Intl.message('Used', name: 'g_key_loyalty_used', desc: '', args: []);
  }

  /// `Copy`
  String get g_key_loyalty_copy {
    return Intl.message('Copy', name: 'g_key_loyalty_copy', desc: '', args: []);
  }

  /// `Share`
  String get g_key_loyalty_share {
    return Intl.message(
      'Share',
      name: 'g_key_loyalty_share',
      desc: '',
      args: [],
    );
  }

  /// `Max Level`
  String get g_key_loyalty_max_level {
    return Intl.message(
      'Max Level',
      name: 'g_key_loyalty_max_level',
      desc: '',
      args: [],
    );
  }

  /// `Next`
  String get g_key_loyalty_next_prefix {
    return Intl.message(
      'Next',
      name: 'g_key_loyalty_next_prefix',
      desc: '',
      args: [],
    );
  }

  /// `{value}m ago`
  String g_key_time_minutes_ago(Object value) {
    return Intl.message(
      '${value}m ago',
      name: 'g_key_time_minutes_ago',
      desc: '',
      args: [value],
    );
  }

  /// `{value}h ago`
  String g_key_time_hours_ago(Object value) {
    return Intl.message(
      '${value}h ago',
      name: 'g_key_time_hours_ago',
      desc: '',
      args: [value],
    );
  }

  /// `{value}d ago`
  String g_key_time_days_ago(Object value) {
    return Intl.message(
      '${value}d ago',
      name: 'g_key_time_days_ago',
      desc: '',
      args: [value],
    );
  }

  /// `Just now`
  String get g_key_time_just_now {
    return Intl.message(
      'Just now',
      name: 'g_key_time_just_now',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get g_key_mining_available {
    return Intl.message(
      'Available',
      name: 'g_key_mining_available',
      desc: '',
      args: [],
    );
  }

  /// `Requires staking`
  String get g_key_mining_requires_staking {
    return Intl.message(
      'Requires staking',
      name: 'g_key_mining_requires_staking',
      desc: '',
      args: [],
    );
  }

  /// `Earn`
  String get g_key_earn_title {
    return Intl.message('Earn', name: 'g_key_earn_title', desc: '', args: []);
  }

  /// `Total Earnings`
  String get g_key_earn_total_earnings {
    return Intl.message(
      'Total Earnings',
      name: 'g_key_earn_total_earnings',
      desc: '',
      args: [],
    );
  }

  /// `Earn More`
  String get g_key_earn_more {
    return Intl.message(
      'Earn More',
      name: 'g_key_earn_more',
      desc: '',
      args: [],
    );
  }

  /// `Quick Tools`
  String get g_key_earn_quick_tools {
    return Intl.message(
      'Quick Tools',
      name: 'g_key_earn_quick_tools',
      desc: '',
      args: [],
    );
  }

  /// `Active Products`
  String get g_key_earn_active_products {
    return Intl.message(
      'Active Products',
      name: 'g_key_earn_active_products',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get g_key_earn_recommended {
    return Intl.message(
      'Recommended',
      name: 'g_key_earn_recommended',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get g_key_earn_view_all {
    return Intl.message(
      'View All',
      name: 'g_key_earn_view_all',
      desc: '',
      args: [],
    );
  }

  /// `Earn up to {value}% APY`
  String g_key_earn_up_to_apy(Object value) {
    return Intl.message(
      'Earn up to $value% APY',
      name: 'g_key_earn_up_to_apy',
      desc: '',
      args: [value],
    );
  }

  /// `Cross-chain transfer`
  String get g_key_earn_cross_chain {
    return Intl.message(
      'Cross-chain transfer',
      name: 'g_key_earn_cross_chain',
      desc: '',
      args: [],
    );
  }

  /// `Claim free tokens`
  String get g_key_earn_claim_free {
    return Intl.message(
      'Claim free tokens',
      name: 'g_key_earn_claim_free',
      desc: '',
      args: [],
    );
  }

  /// `Daily check-in bonus`
  String get g_key_earn_daily_bonus {
    return Intl.message(
      'Daily check-in bonus',
      name: 'g_key_earn_daily_bonus',
      desc: '',
      args: [],
    );
  }

  /// `Stake ETH with Lido`
  String get g_key_earn_stake_eth_lido {
    return Intl.message(
      'Stake ETH with Lido',
      name: 'g_key_earn_stake_eth_lido',
      desc: '',
      args: [],
    );
  }

  /// `Native Solana staking`
  String get g_key_earn_native_sol {
    return Intl.message(
      'Native Solana staking',
      name: 'g_key_earn_native_sol',
      desc: '',
      args: [],
    );
  }

  /// `Earn points daily`
  String get g_key_earn_points_daily {
    return Intl.message(
      'Earn points daily',
      name: 'g_key_earn_points_daily',
      desc: '',
      args: [],
    );
  }

  /// `+{value} pts/day`
  String g_key_earn_pts_day(Object value) {
    return Intl.message(
      '+$value pts/day',
      name: 'g_key_earn_pts_day',
      desc: '',
      args: [value],
    );
  }

  /// `Ledger`
  String get g_key_earn_ledger {
    return Intl.message(
      'Ledger',
      name: 'g_key_earn_ledger',
      desc: '',
      args: [],
    );
  }

  /// `Gas`
  String get g_key_earn_gas {
    return Intl.message('Gas', name: 'g_key_earn_gas', desc: '', args: []);
  }

  /// `Batch`
  String get g_key_earn_batch {
    return Intl.message('Batch', name: 'g_key_earn_batch', desc: '', args: []);
  }

  /// `Burn`
  String get g_key_earn_burn {
    return Intl.message('Burn', name: 'g_key_earn_burn', desc: '', args: []);
  }

  /// `Mining`
  String get g_key_earn_mining {
    return Intl.message(
      'Mining',
      name: 'g_key_earn_mining',
      desc: '',
      args: [],
    );
  }

  /// `Swap`
  String get g_key_earn_swap {
    return Intl.message('Swap', name: 'g_key_earn_swap', desc: '', args: []);
  }

  /// `Node Mining`
  String get g_key_earn_node_mining {
    return Intl.message(
      'Node Mining',
      name: 'g_key_earn_node_mining',
      desc: '',
      args: [],
    );
  }

  /// `Earn rewards by participating in node mining`
  String get g_key_earn_node_mining_desc {
    return Intl.message(
      'Earn rewards by participating in node mining',
      name: 'g_key_earn_node_mining_desc',
      desc: '',
      args: [],
    );
  }

  /// `No active positions`
  String get g_key_earn_no_positions {
    return Intl.message(
      'No active positions',
      name: 'g_key_earn_no_positions',
      desc: '',
      args: [],
    );
  }

  /// `Start Staking`
  String get g_key_earn_go_staking {
    return Intl.message(
      'Start Staking',
      name: 'g_key_earn_go_staking',
      desc: '',
      args: [],
    );
  }

  /// `Buy N`
  String get g_key_earn_buy_n {
    return Intl.message('Buy N', name: 'g_key_earn_buy_n', desc: '', args: []);
  }

  /// `Buy N with AST protocol`
  String get g_key_earn_buy_n_desc {
    return Intl.message(
      'Buy N with AST protocol',
      name: 'g_key_earn_buy_n_desc',
      desc: '',
      args: [],
    );
  }

  /// `DEX Swap`
  String get g_key_earn_dex_swap {
    return Intl.message(
      'DEX Swap',
      name: 'g_key_earn_dex_swap',
      desc: '',
      args: [],
    );
  }

  /// `Swap any token via Uniswap / 1inch`
  String get g_key_earn_dex_desc {
    return Intl.message(
      'Swap any token via Uniswap / 1inch',
      name: 'g_key_earn_dex_desc',
      desc: '',
      args: [],
    );
  }

  /// `Select Swap Type`
  String get g_key_earn_select_swap {
    return Intl.message(
      'Select Swap Type',
      name: 'g_key_earn_select_swap',
      desc: '',
      args: [],
    );
  }

  /// `Loading APY...`
  String get g_key_earn_loading_apy {
    return Intl.message(
      'Loading APY...',
      name: 'g_key_earn_loading_apy',
      desc: '',
      args: [],
    );
  }

  /// `Burn NFT`
  String get g_key_burn_nft_title {
    return Intl.message(
      'Burn NFT',
      name: 'g_key_burn_nft_title',
      desc: '',
      args: [],
    );
  }

  /// `To burn an NFT, please go to the NFT details page and tap the "Burn" button.`
  String get g_key_burn_nft_tip {
    return Intl.message(
      'To burn an NFT, please go to the NFT details page and tap the "Burn" button.',
      name: 'g_key_burn_nft_tip',
      desc: '',
      args: [],
    );
  }

  /// `Steps:`
  String get g_key_burn_nft_steps {
    return Intl.message(
      'Steps:',
      name: 'g_key_burn_nft_steps',
      desc: '',
      args: [],
    );
  }

  /// `1. Select a token with NFT support`
  String get g_key_burn_nft_step1 {
    return Intl.message(
      '1. Select a token with NFT support',
      name: 'g_key_burn_nft_step1',
      desc: '',
      args: [],
    );
  }

  /// `2. Go to NFT tab`
  String get g_key_burn_nft_step2 {
    return Intl.message(
      '2. Go to NFT tab',
      name: 'g_key_burn_nft_step2',
      desc: '',
      args: [],
    );
  }

  /// `3. Select the NFT you want to burn`
  String get g_key_burn_nft_step3 {
    return Intl.message(
      '3. Select the NFT you want to burn',
      name: 'g_key_burn_nft_step3',
      desc: '',
      args: [],
    );
  }

  /// `4. Tap "Burn" button`
  String get g_key_burn_nft_step4 {
    return Intl.message(
      '4. Tap "Burn" button',
      name: 'g_key_burn_nft_step4',
      desc: '',
      args: [],
    );
  }

  /// `Got it`
  String get g_key_burn_got_it {
    return Intl.message(
      'Got it',
      name: 'g_key_burn_got_it',
      desc: '',
      args: [],
    );
  }

  /// `Real-time Gas Prices`
  String get g_key_gas_realtime_prices {
    return Intl.message(
      'Real-time Gas Prices',
      name: 'g_key_gas_realtime_prices',
      desc: '',
      args: [],
    );
  }

  /// `Auto-refresh every {value} seconds`
  String g_key_gas_auto_refresh(Object value) {
    return Intl.message(
      'Auto-refresh every $value seconds',
      name: 'g_key_gas_auto_refresh',
      desc: '',
      args: [value],
    );
  }

  /// `Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.`
  String get g_key_gas_footer {
    return Intl.message(
      'Gas prices fluctuate based on network demand. Lower gas = slower confirmation, higher gas = faster confirmation.',
      name: 'g_key_gas_footer',
      desc: '',
      args: [],
    );
  }

  /// `Gas Tracker`
  String get g_key_gas_tracker {
    return Intl.message(
      'Gas Tracker',
      name: 'g_key_gas_tracker',
      desc: '',
      args: [],
    );
  }

  /// `Price Trend`
  String get g_key_gas_price_trend {
    return Intl.message(
      'Price Trend',
      name: 'g_key_gas_price_trend',
      desc: '',
      args: [],
    );
  }

  /// `Gas Alert`
  String get g_key_gas_alert {
    return Intl.message(
      'Gas Alert',
      name: 'g_key_gas_alert',
      desc: '',
      args: [],
    );
  }

  /// `Threshold (Gwei)`
  String get g_key_gas_alert_threshold {
    return Intl.message(
      'Threshold (Gwei)',
      name: 'g_key_gas_alert_threshold',
      desc: '',
      args: [],
    );
  }

  /// `Alert when below`
  String get g_key_gas_alert_below {
    return Intl.message(
      'Alert when below',
      name: 'g_key_gas_alert_below',
      desc: '',
      args: [],
    );
  }

  /// `Alert when above`
  String get g_key_gas_alert_above {
    return Intl.message(
      'Alert when above',
      name: 'g_key_gas_alert_above',
      desc: '',
      args: [],
    );
  }

  /// `Save`
  String get g_key_gas_alert_save {
    return Intl.message(
      'Save',
      name: 'g_key_gas_alert_save',
      desc: '',
      args: [],
    );
  }

  /// `Select Token`
  String get g_key_batch_select_token {
    return Intl.message(
      'Select Token',
      name: 'g_key_batch_select_token',
      desc: '',
      args: [],
    );
  }

  /// `No supported tokens`
  String get g_key_batch_no_supported {
    return Intl.message(
      'No supported tokens',
      name: 'g_key_batch_no_supported',
      desc: '',
      args: [],
    );
  }

  /// `Batch transfer supports EVM chains only`
  String get g_key_batch_evm_only {
    return Intl.message(
      'Batch transfer supports EVM chains only',
      name: 'g_key_batch_evm_only',
      desc: '',
      args: [],
    );
  }

  /// `Send tokens to multiple addresses in one transaction`
  String get g_key_batch_send_multiple {
    return Intl.message(
      'Send tokens to multiple addresses in one transaction',
      name: 'g_key_batch_send_multiple',
      desc: '',
      args: [],
    );
  }

  /// `Estimating Gas...`
  String get g_key_batch_estimating_gas {
    return Intl.message(
      'Estimating Gas...',
      name: 'g_key_batch_estimating_gas',
      desc: '',
      args: [],
    );
  }

  /// `Signing...`
  String get g_key_batch_signing {
    return Intl.message(
      'Signing...',
      name: 'g_key_batch_signing',
      desc: '',
      args: [],
    );
  }

  /// `Broadcasting...`
  String get g_key_batch_broadcasting {
    return Intl.message(
      'Broadcasting...',
      name: 'g_key_batch_broadcasting',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get g_key_batch_done {
    return Intl.message('Done', name: 'g_key_batch_done', desc: '', args: []);
  }

  /// `Continue`
  String get g_key_batch_continue {
    return Intl.message(
      'Continue',
      name: 'g_key_batch_continue',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Batch Transfer`
  String get g_key_batch_confirm_title {
    return Intl.message(
      'Confirm Batch Transfer',
      name: 'g_key_batch_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `Batch Transfer Help`
  String get g_key_batch_help_title {
    return Intl.message(
      'Batch Transfer Help',
      name: 'g_key_batch_help_title',
      desc: '',
      args: [],
    );
  }

  /// `Swipe left to remove a recipient`
  String get g_key_batch_swipe_remove {
    return Intl.message(
      'Swipe left to remove a recipient',
      name: 'g_key_batch_swipe_remove',
      desc: '',
      args: [],
    );
  }

  /// `Memo is optional`
  String get g_key_batch_memo_optional {
    return Intl.message(
      'Memo is optional',
      name: 'g_key_batch_memo_optional',
      desc: '',
      args: [],
    );
  }

  /// `Use Multicall3 for lower gas fees`
  String get g_key_batch_multicall_tip {
    return Intl.message(
      'Use Multicall3 for lower gas fees',
      name: 'g_key_batch_multicall_tip',
      desc: '',
      args: [],
    );
  }

  /// `Confirm ENS Resolution`
  String get g_key_ens_confirm_title {
    return Intl.message(
      'Confirm ENS Resolution',
      name: 'g_key_ens_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `ENS Name Detected`
  String get g_key_ens_detected {
    return Intl.message(
      'ENS Name Detected',
      name: 'g_key_ens_detected',
      desc: '',
      args: [],
    );
  }

  /// `ENS Name`
  String get g_key_ens_name {
    return Intl.message('ENS Name', name: 'g_key_ens_name', desc: '', args: []);
  }

  /// `Resolved Address`
  String get g_key_ens_resolved_address {
    return Intl.message(
      'Resolved Address',
      name: 'g_key_ens_resolved_address',
      desc: '',
      args: [],
    );
  }

  /// `Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.`
  String get g_key_ens_warning {
    return Intl.message(
      'Please verify the resolved address before proceeding. ENS names can be transferred or changed by their owner.',
      name: 'g_key_ens_warning',
      desc: '',
      args: [],
    );
  }

  /// `Confirm & Send`
  String get g_key_ens_confirm_send {
    return Intl.message(
      'Confirm & Send',
      name: 'g_key_ens_confirm_send',
      desc: '',
      args: [],
    );
  }

  /// `Resolving ENS...`
  String get g_key_ens_resolving {
    return Intl.message(
      'Resolving ENS...',
      name: 'g_key_ens_resolving',
      desc: '',
      args: [],
    );
  }

  /// `ENS resolution failed`
  String get g_key_ens_resolution_failed {
    return Intl.message(
      'ENS resolution failed',
      name: 'g_key_ens_resolution_failed',
      desc: '',
      args: [],
    );
  }

  /// `Invalid ENS name`
  String get g_key_ens_invalid_name {
    return Intl.message(
      'Invalid ENS name',
      name: 'g_key_ens_invalid_name',
      desc: '',
      args: [],
    );
  }

  /// `ENS Manager`
  String get g_key_ens_title {
    return Intl.message(
      'ENS Manager',
      name: 'g_key_ens_title',
      desc: '',
      args: [],
    );
  }

  /// `ENS Manager`
  String get g_key_ens_home_title {
    return Intl.message(
      'ENS Manager',
      name: 'g_key_ens_home_title',
      desc: '',
      args: [],
    );
  }

  /// `Ethereum Name Service`
  String get g_key_ens_service {
    return Intl.message(
      'Ethereum Name Service',
      name: 'g_key_ens_service',
      desc: '',
      args: [],
    );
  }

  /// `Register and manage your .eth domain names`
  String get g_key_ens_description {
    return Intl.message(
      'Register and manage your .eth domain names',
      name: 'g_key_ens_description',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get g_key_ens_search {
    return Intl.message('Search', name: 'g_key_ens_search', desc: '', args: []);
  }

  /// `Search ENS`
  String get g_key_ens_search_title {
    return Intl.message(
      'Search ENS',
      name: 'g_key_ens_search_title',
      desc: '',
      args: [],
    );
  }

  /// `Search for a .eth name`
  String get g_key_ens_search_hint {
    return Intl.message(
      'Search for a .eth name',
      name: 'g_key_ens_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `Find available .eth names`
  String get g_key_ens_search_desc {
    return Intl.message(
      'Find available .eth names',
      name: 'g_key_ens_search_desc',
      desc: '',
      args: [],
    );
  }

  /// `Search & Register`
  String get g_key_ens_search_register {
    return Intl.message(
      'Search & Register',
      name: 'g_key_ens_search_register',
      desc: '',
      args: [],
    );
  }

  /// `Extend your domain registration`
  String get g_key_ens_renew_desc {
    return Intl.message(
      'Extend your domain registration',
      name: 'g_key_ens_renew_desc',
      desc: '',
      args: [],
    );
  }

  /// `No domains yet`
  String get g_key_ens_no_domains {
    return Intl.message(
      'No domains yet',
      name: 'g_key_ens_no_domains',
      desc: '',
      args: [],
    );
  }

  /// `My Domains`
  String get g_key_ens_my_domains {
    return Intl.message(
      'My Domains',
      name: 'g_key_ens_my_domains',
      desc: '',
      args: [],
    );
  }

  /// `Get started with ENS`
  String get g_key_ens_get_started {
    return Intl.message(
      'Get started with ENS',
      name: 'g_key_ens_get_started',
      desc: '',
      args: [],
    );
  }

  /// `Primary`
  String get g_key_ens_primary {
    return Intl.message(
      'Primary',
      name: 'g_key_ens_primary',
      desc: '',
      args: [],
    );
  }

  /// `Primary name set successfully`
  String get g_key_ens_primary_set {
    return Intl.message(
      'Primary name set successfully',
      name: 'g_key_ens_primary_set',
      desc: '',
      args: [],
    );
  }

  /// `Transfer is irreversible. Make sure the new owner address is correct.`
  String get g_key_ens_transfer_warning {
    return Intl.message(
      'Transfer is irreversible. Make sure the new owner address is correct.',
      name: 'g_key_ens_transfer_warning',
      desc: '',
      args: [],
    );
  }

  /// `New Owner Address`
  String get g_key_ens_new_owner {
    return Intl.message(
      'New Owner Address',
      name: 'g_key_ens_new_owner',
      desc: '',
      args: [],
    );
  }

  /// `Transfer successful`
  String get g_key_ens_transfer_success {
    return Intl.message(
      'Transfer successful',
      name: 'g_key_ens_transfer_success',
      desc: '',
      args: [],
    );
  }

  /// `Available`
  String get g_key_ens_available {
    return Intl.message(
      'Available',
      name: 'g_key_ens_available',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get g_key_ens_unavailable {
    return Intl.message(
      'Unavailable',
      name: 'g_key_ens_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Checking availability...`
  String get g_key_ens_checking {
    return Intl.message(
      'Checking availability...',
      name: 'g_key_ens_checking',
      desc: '',
      args: [],
    );
  }

  /// `per year`
  String get g_key_ens_price_per_year {
    return Intl.message(
      'per year',
      name: 'g_key_ens_price_per_year',
      desc: '',
      args: [],
    );
  }

  /// `Register Now`
  String get g_key_ens_register_now {
    return Intl.message(
      'Register Now',
      name: 'g_key_ens_register_now',
      desc: '',
      args: [],
    );
  }

  /// `My ENS Names`
  String get g_key_ens_owned_names {
    return Intl.message(
      'My ENS Names',
      name: 'g_key_ens_owned_names',
      desc: '',
      args: [],
    );
  }

  /// `You don't own any ENS names yet`
  String get g_key_ens_no_names {
    return Intl.message(
      'You don\'t own any ENS names yet',
      name: 'g_key_ens_no_names',
      desc: '',
      args: [],
    );
  }

  /// `Expires`
  String get g_key_ens_expires {
    return Intl.message(
      'Expires',
      name: 'g_key_ens_expires',
      desc: '',
      args: [],
    );
  }

  /// `Expired`
  String get g_key_ens_expired {
    return Intl.message(
      'Expired',
      name: 'g_key_ens_expired',
      desc: '',
      args: [],
    );
  }

  /// `Expiring Soon`
  String get g_key_ens_expiring_soon {
    return Intl.message(
      'Expiring Soon',
      name: 'g_key_ens_expiring_soon',
      desc: '',
      args: [],
    );
  }

  /// `Register ENS`
  String get g_key_ens_purchase_title {
    return Intl.message(
      'Register ENS',
      name: 'g_key_ens_purchase_title',
      desc: '',
      args: [],
    );
  }

  /// `Commit`
  String get g_key_ens_step_commit {
    return Intl.message(
      'Commit',
      name: 'g_key_ens_step_commit',
      desc: '',
      args: [],
    );
  }

  /// `Wait`
  String get g_key_ens_step_wait {
    return Intl.message(
      'Wait',
      name: 'g_key_ens_step_wait',
      desc: '',
      args: [],
    );
  }

  /// `Register`
  String get g_key_ens_step_register {
    return Intl.message(
      'Register',
      name: 'g_key_ens_step_register',
      desc: '',
      args: [],
    );
  }

  /// `Success`
  String get g_key_ens_step_success {
    return Intl.message(
      'Success',
      name: 'g_key_ens_step_success',
      desc: '',
      args: [],
    );
  }

  /// `Committing transaction...`
  String get g_key_ens_commit_tx {
    return Intl.message(
      'Committing transaction...',
      name: 'g_key_ens_commit_tx',
      desc: '',
      args: [],
    );
  }

  /// `Please wait {value} seconds`
  String g_key_ens_wait_timer(Object value) {
    return Intl.message(
      'Please wait $value seconds',
      name: 'g_key_ens_wait_timer',
      desc: '',
      args: [value],
    );
  }

  /// `Registering name...`
  String get g_key_ens_register_tx {
    return Intl.message(
      'Registering name...',
      name: 'g_key_ens_register_tx',
      desc: '',
      args: [],
    );
  }

  /// `Congratulations! You now own {value}`
  String g_key_ens_success_message(Object value) {
    return Intl.message(
      'Congratulations! You now own $value',
      name: 'g_key_ens_success_message',
      desc: '',
      args: [value],
    );
  }

  /// `Registration Period`
  String get g_key_ens_duration {
    return Intl.message(
      'Registration Period',
      name: 'g_key_ens_duration',
      desc: '',
      args: [],
    );
  }

  /// `year`
  String get g_key_ens_year {
    return Intl.message('year', name: 'g_key_ens_year', desc: '', args: []);
  }

  /// `years`
  String get g_key_ens_years {
    return Intl.message('years', name: 'g_key_ens_years', desc: '', args: []);
  }

  /// `Total Cost`
  String get g_key_ens_total_cost {
    return Intl.message(
      'Total Cost',
      name: 'g_key_ens_total_cost',
      desc: '',
      args: [],
    );
  }

  /// `Manage ENS`
  String get g_key_ens_management_title {
    return Intl.message(
      'Manage ENS',
      name: 'g_key_ens_management_title',
      desc: '',
      args: [],
    );
  }

  /// `Records`
  String get g_key_ens_records {
    return Intl.message(
      'Records',
      name: 'g_key_ens_records',
      desc: '',
      args: [],
    );
  }

  /// `Edit Records`
  String get g_key_ens_edit_records {
    return Intl.message(
      'Edit Records',
      name: 'g_key_ens_edit_records',
      desc: '',
      args: [],
    );
  }

  /// `Set as Primary`
  String get g_key_ens_set_primary {
    return Intl.message(
      'Set as Primary',
      name: 'g_key_ens_set_primary',
      desc: '',
      args: [],
    );
  }

  /// `Transfer`
  String get g_key_ens_transfer {
    return Intl.message(
      'Transfer',
      name: 'g_key_ens_transfer',
      desc: '',
      args: [],
    );
  }

  /// `Renew`
  String get g_key_ens_renew {
    return Intl.message('Renew', name: 'g_key_ens_renew', desc: '', args: []);
  }

  /// `Renew ENS`
  String get g_key_ens_renew_title {
    return Intl.message(
      'Renew ENS',
      name: 'g_key_ens_renew_title',
      desc: '',
      args: [],
    );
  }

  /// `Current Expiry`
  String get g_key_ens_current_expiry {
    return Intl.message(
      'Current Expiry',
      name: 'g_key_ens_current_expiry',
      desc: '',
      args: [],
    );
  }

  /// `New Expiry`
  String get g_key_ens_new_expiry {
    return Intl.message(
      'New Expiry',
      name: 'g_key_ens_new_expiry',
      desc: '',
      args: [],
    );
  }

  /// `Renewal Cost`
  String get g_key_ens_renew_cost {
    return Intl.message(
      'Renewal Cost',
      name: 'g_key_ens_renew_cost',
      desc: '',
      args: [],
    );
  }

  /// `days left`
  String get g_key_ens_days_left {
    return Intl.message(
      'days left',
      name: 'g_key_ens_days_left',
      desc: '',
      args: [],
    );
  }

  /// `Text Records`
  String get g_key_ens_text_records {
    return Intl.message(
      'Text Records',
      name: 'g_key_ens_text_records',
      desc: '',
      args: [],
    );
  }

  /// `Advanced`
  String get g_key_ens_advanced {
    return Intl.message(
      'Advanced',
      name: 'g_key_ens_advanced',
      desc: '',
      args: [],
    );
  }

  /// `Transfer ownership to another address`
  String get g_key_ens_transfer_desc {
    return Intl.message(
      'Transfer ownership to another address',
      name: 'g_key_ens_transfer_desc',
      desc: '',
      args: [],
    );
  }

  /// `Commit failed`
  String get g_key_ens_commit_failed {
    return Intl.message(
      'Commit failed',
      name: 'g_key_ens_commit_failed',
      desc: '',
      args: [],
    );
  }

  /// `Registration commitment expired. Please start the registration process again.`
  String get g_key_ens_commitment_expired_msg {
    return Intl.message(
      'Registration commitment expired. Please start the registration process again.',
      name: 'g_key_ens_commitment_expired_msg',
      desc: '',
      args: [],
    );
  }

  /// `Expiry reminder is off`
  String get g_key_ens_reminder_disabled {
    return Intl.message(
      'Expiry reminder is off',
      name: 'g_key_ens_reminder_disabled',
      desc: '',
      args: [],
    );
  }

  /// `Expiry reminder is on`
  String get g_key_ens_reminder_enabled {
    return Intl.message(
      'Expiry reminder is on',
      name: 'g_key_ens_reminder_enabled',
      desc: '',
      args: [],
    );
  }

  /// `Notify 30, 7 and 1 day before expiry`
  String get g_key_ens_reminder_hint {
    return Intl.message(
      'Notify 30, 7 and 1 day before expiry',
      name: 'g_key_ens_reminder_hint',
      desc: '',
      args: [],
    );
  }

  /// `Enable expiry reminder`
  String get g_key_ens_reminder_enable {
    return Intl.message(
      'Enable expiry reminder',
      name: 'g_key_ens_reminder_enable',
      desc: '',
      args: [],
    );
  }

  /// `Subdomains`
  String get g_key_ens_subdomains {
    return Intl.message(
      'Subdomains',
      name: 'g_key_ens_subdomains',
      desc: '',
      args: [],
    );
  }

  /// `Create Subdomain`
  String get g_key_ens_subdomain_create {
    return Intl.message(
      'Create Subdomain',
      name: 'g_key_ens_subdomain_create',
      desc: '',
      args: [],
    );
  }

  /// `Subdomain label`
  String get g_key_ens_subdomain_label {
    return Intl.message(
      'Subdomain label',
      name: 'g_key_ens_subdomain_label',
      desc: '',
      args: [],
    );
  }

  /// `e.g. blog, mail, app`
  String get g_key_ens_subdomain_label_hint {
    return Intl.message(
      'e.g. blog, mail, app',
      name: 'g_key_ens_subdomain_label_hint',
      desc: '',
      args: [],
    );
  }

  /// `Owner address`
  String get g_key_ens_subdomain_owner {
    return Intl.message(
      'Owner address',
      name: 'g_key_ens_subdomain_owner',
      desc: '',
      args: [],
    );
  }

  /// `Leave empty to use current wallet`
  String get g_key_ens_subdomain_owner_hint {
    return Intl.message(
      'Leave empty to use current wallet',
      name: 'g_key_ens_subdomain_owner_hint',
      desc: '',
      args: [],
    );
  }

  /// `Subdomain created`
  String get g_key_ens_subdomain_created {
    return Intl.message(
      'Subdomain created',
      name: 'g_key_ens_subdomain_created',
      desc: '',
      args: [],
    );
  }

  /// `Subdomain deleted`
  String get g_key_ens_subdomain_deleted {
    return Intl.message(
      'Subdomain deleted',
      name: 'g_key_ens_subdomain_deleted',
      desc: '',
      args: [],
    );
  }

  /// `No subdomains yet`
  String get g_key_ens_subdomain_empty {
    return Intl.message(
      'No subdomains yet',
      name: 'g_key_ens_subdomain_empty',
      desc: '',
      args: [],
    );
  }

  /// `Delete Subdomain`
  String get g_key_ens_subdomain_delete {
    return Intl.message(
      'Delete Subdomain',
      name: 'g_key_ens_subdomain_delete',
      desc: '',
      args: [],
    );
  }

  /// `This subdomain will be permanently deleted.`
  String get g_key_ens_subdomain_delete_confirm {
    return Intl.message(
      'This subdomain will be permanently deleted.',
      name: 'g_key_ens_subdomain_delete_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Use letters, numbers and hyphens only`
  String get g_key_ens_subdomain_invalid_label {
    return Intl.message(
      'Use letters, numbers and hyphens only',
      name: 'g_key_ens_subdomain_invalid_label',
      desc: '',
      args: [],
    );
  }

  /// `Resolved address updated`
  String get g_key_ens_address_updated {
    return Intl.message(
      'Resolved address updated',
      name: 'g_key_ens_address_updated',
      desc: '',
      args: [],
    );
  }

  /// `Invalid address (must be 0x + 40 hex chars)`
  String get g_key_ens_invalid_address {
    return Intl.message(
      'Invalid address (must be 0x + 40 hex chars)',
      name: 'g_key_ens_invalid_address',
      desc: '',
      args: [],
    );
  }

  /// `Registration failed`
  String get g_key_ens_register_failed {
    return Intl.message(
      'Registration failed',
      name: 'g_key_ens_register_failed',
      desc: '',
      args: [],
    );
  }

  /// `Registration Info`
  String get g_key_ens_registration_info {
    return Intl.message(
      'Registration Info',
      name: 'g_key_ens_registration_info',
      desc: '',
      args: [],
    );
  }

  /// `ENS registration is a two-step process`
  String get g_key_ens_two_step_process {
    return Intl.message(
      'ENS registration is a two-step process',
      name: 'g_key_ens_two_step_process',
      desc: '',
      args: [],
    );
  }

  /// `A waiting period prevents front-running`
  String get g_key_ens_wait_time_info {
    return Intl.message(
      'A waiting period prevents front-running',
      name: 'g_key_ens_wait_time_info',
      desc: '',
      args: [],
    );
  }

  /// `Please keep the app open during registration`
  String get g_key_ens_keep_app_open {
    return Intl.message(
      'Please keep the app open during registration',
      name: 'g_key_ens_keep_app_open',
      desc: '',
      args: [],
    );
  }

  /// `Committing...`
  String get g_key_ens_committing {
    return Intl.message(
      'Committing...',
      name: 'g_key_ens_committing',
      desc: '',
      args: [],
    );
  }

  /// `Please wait`
  String get g_key_ens_please_wait {
    return Intl.message(
      'Please wait',
      name: 'g_key_ens_please_wait',
      desc: '',
      args: [],
    );
  }

  /// `Waiting...`
  String get g_key_ens_waiting {
    return Intl.message(
      'Waiting...',
      name: 'g_key_ens_waiting',
      desc: '',
      args: [],
    );
  }

  /// `Waiting period prevents front-running attacks`
  String get g_key_ens_wait_explanation {
    return Intl.message(
      'Waiting period prevents front-running attacks',
      name: 'g_key_ens_wait_explanation',
      desc: '',
      args: [],
    );
  }

  /// `Registering...`
  String get g_key_ens_registering {
    return Intl.message(
      'Registering...',
      name: 'g_key_ens_registering',
      desc: '',
      args: [],
    );
  }

  /// `Finalizing registration`
  String get g_key_ens_finalizing {
    return Intl.message(
      'Finalizing registration',
      name: 'g_key_ens_finalizing',
      desc: '',
      args: [],
    );
  }

  /// `Success!`
  String get g_key_ens_success {
    return Intl.message(
      'Success!',
      name: 'g_key_ens_success',
      desc: '',
      args: [],
    );
  }

  /// `is now yours!`
  String get g_key_ens_is_yours {
    return Intl.message(
      'is now yours!',
      name: 'g_key_ens_is_yours',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get g_key_ens_failed {
    return Intl.message('Failed', name: 'g_key_ens_failed', desc: '', args: []);
  }

  /// `Start Registration`
  String get g_key_ens_start_registration {
    return Intl.message(
      'Start Registration',
      name: 'g_key_ens_start_registration',
      desc: '',
      args: [],
    );
  }

  /// `Processing...`
  String get g_key_ens_processing {
    return Intl.message(
      'Processing...',
      name: 'g_key_ens_processing',
      desc: '',
      args: [],
    );
  }

  /// `Extend Registration Period`
  String get g_key_ens_extend_period {
    return Intl.message(
      'Extend Registration Period',
      name: 'g_key_ens_extend_period',
      desc: '',
      args: [],
    );
  }

  /// `Renewal successful`
  String get g_key_ens_renew_success {
    return Intl.message(
      'Renewal successful',
      name: 'g_key_ens_renew_success',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Renewal`
  String get g_key_ens_confirm_renew {
    return Intl.message(
      'Confirm Renewal',
      name: 'g_key_ens_confirm_renew',
      desc: '',
      args: [],
    );
  }

  /// `Enter an ENS name to search`
  String get g_key_ens_search_prompt {
    return Intl.message(
      'Enter an ENS name to search',
      name: 'g_key_ens_search_prompt',
      desc: '',
      args: [],
    );
  }

  /// `Minimum 3 characters`
  String get g_key_ens_min_length {
    return Intl.message(
      'Minimum 3 characters',
      name: 'g_key_ens_min_length',
      desc: '',
      args: [],
    );
  }

  /// `Suggestions`
  String get g_key_ens_suggestions {
    return Intl.message(
      'Suggestions',
      name: 'g_key_ens_suggestions',
      desc: '',
      args: [],
    );
  }

  /// `Try another name`
  String get g_key_ens_try_another {
    return Intl.message(
      'Try another name',
      name: 'g_key_ens_try_another',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get g_key_ens_owner {
    return Intl.message('Owner', name: 'g_key_ens_owner', desc: '', args: []);
  }

  /// `Registration Period`
  String get g_key_ens_registration_period {
    return Intl.message(
      'Registration Period',
      name: 'g_key_ens_registration_period',
      desc: '',
      args: [],
    );
  }

  /// `Price Breakdown`
  String get g_key_ens_price_breakdown {
    return Intl.message(
      'Price Breakdown',
      name: 'g_key_ens_price_breakdown',
      desc: '',
      args: [],
    );
  }

  /// `Base Price`
  String get g_key_ens_base_price {
    return Intl.message(
      'Base Price',
      name: 'g_key_ens_base_price',
      desc: '',
      args: [],
    );
  }

  /// `Annual Fee`
  String get g_key_ens_annual_fee {
    return Intl.message(
      'Annual Fee',
      name: 'g_key_ens_annual_fee',
      desc: '',
      args: [],
    );
  }

  /// `Total`
  String get g_key_ens_total {
    return Intl.message('Total', name: 'g_key_ens_total', desc: '', args: []);
  }

  /// `Premium Name`
  String get g_key_ens_premium_name {
    return Intl.message(
      'Premium Name',
      name: 'g_key_ens_premium_name',
      desc: '',
      args: [],
    );
  }

  /// `Standard Name`
  String get g_key_ens_standard_name {
    return Intl.message(
      'Standard Name',
      name: 'g_key_ens_standard_name',
      desc: '',
      args: [],
    );
  }

  /// `Step 1`
  String get g_key_ens_step_1 {
    return Intl.message('Step 1', name: 'g_key_ens_step_1', desc: '', args: []);
  }

  /// `Step 2`
  String get g_key_ens_step_2 {
    return Intl.message('Step 2', name: 'g_key_ens_step_2', desc: '', args: []);
  }

  /// `Step 3`
  String get g_key_ens_step_3 {
    return Intl.message('Step 3', name: 'g_key_ens_step_3', desc: '', args: []);
  }

  /// `Commit`
  String get g_key_ens_commit {
    return Intl.message('Commit', name: 'g_key_ens_commit', desc: '', args: []);
  }

  /// `Wait`
  String get g_key_ens_wait {
    return Intl.message('Wait', name: 'g_key_ens_wait', desc: '', args: []);
  }

  /// `Register`
  String get g_key_ens_register {
    return Intl.message(
      'Register',
      name: 'g_key_ens_register',
      desc: '',
      args: [],
    );
  }

  /// `Smart Account`
  String get g_key_aa_title {
    return Intl.message(
      'Smart Account',
      name: 'g_key_aa_title',
      desc: '',
      args: [],
    );
  }

  /// `Account Abstraction`
  String get g_key_aa_home_title {
    return Intl.message(
      'Account Abstraction',
      name: 'g_key_aa_home_title',
      desc: '',
      args: [],
    );
  }

  /// `My Smart Accounts`
  String get g_key_aa_my_accounts {
    return Intl.message(
      'My Smart Accounts',
      name: 'g_key_aa_my_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Create Smart Account`
  String get g_key_aa_create_account {
    return Intl.message(
      'Create Smart Account',
      name: 'g_key_aa_create_account',
      desc: '',
      args: [],
    );
  }

  /// `Account Created Successfully`
  String get g_key_aa_account_created {
    return Intl.message(
      'Account Created Successfully',
      name: 'g_key_aa_account_created',
      desc: '',
      args: [],
    );
  }

  /// `Account Name`
  String get g_key_aa_account_name {
    return Intl.message(
      'Account Name',
      name: 'g_key_aa_account_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter account name`
  String get g_key_aa_account_name_hint {
    return Intl.message(
      'Enter account name',
      name: 'g_key_aa_account_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Account Type`
  String get g_key_aa_account_type {
    return Intl.message(
      'Account Type',
      name: 'g_key_aa_account_type',
      desc: '',
      args: [],
    );
  }

  /// `Coming Soon`
  String get g_key_aa_coming_soon {
    return Intl.message(
      'Coming Soon',
      name: 'g_key_aa_coming_soon',
      desc: '',
      args: [],
    );
  }

  /// `Preview Address`
  String get g_key_aa_preview_address {
    return Intl.message(
      'Preview Address',
      name: 'g_key_aa_preview_address',
      desc: '',
      args: [],
    );
  }

  /// `This is a counterfactual address. It will be deployed on your first transaction.`
  String get g_key_aa_counterfactual_note {
    return Intl.message(
      'This is a counterfactual address. It will be deployed on your first transaction.',
      name: 'g_key_aa_counterfactual_note',
      desc: '',
      args: [],
    );
  }

  /// `Deployment will occur automatically with your first transaction.`
  String get g_key_aa_deployment_note {
    return Intl.message(
      'Deployment will occur automatically with your first transaction.',
      name: 'g_key_aa_deployment_note',
      desc: '',
      args: [],
    );
  }

  /// `Simple Account`
  String get g_key_aa_simple_account {
    return Intl.message(
      'Simple Account',
      name: 'g_key_aa_simple_account',
      desc: '',
      args: [],
    );
  }

  /// `Basic smart account with single owner - recommended for most users`
  String get g_key_aa_simple_desc {
    return Intl.message(
      'Basic smart account with single owner - recommended for most users',
      name: 'g_key_aa_simple_desc',
      desc: '',
      args: [],
    );
  }

  /// `EIP-7702 Account`
  String get g_key_aa_eip7702_account {
    return Intl.message(
      'EIP-7702 Account',
      name: 'g_key_aa_eip7702_account',
      desc: '',
      args: [],
    );
  }

  /// `Hybrid EOA/Smart Account - No deployment needed`
  String get g_key_aa_eip7702_desc {
    return Intl.message(
      'Hybrid EOA/Smart Account - No deployment needed',
      name: 'g_key_aa_eip7702_desc',
      desc: '',
      args: [],
    );
  }

  /// `Safe Account`
  String get g_key_aa_safe_account {
    return Intl.message(
      'Safe Account',
      name: 'g_key_aa_safe_account',
      desc: '',
      args: [],
    );
  }

  /// `Multi-signature account with advanced security features`
  String get g_key_aa_safe_desc {
    return Intl.message(
      'Multi-signature account with advanced security features',
      name: 'g_key_aa_safe_desc',
      desc: '',
      args: [],
    );
  }

  /// `Kernel Account`
  String get g_key_aa_kernel_account {
    return Intl.message(
      'Kernel Account',
      name: 'g_key_aa_kernel_account',
      desc: '',
      args: [],
    );
  }

  /// `Modular account with plugin support from ZeroDev`
  String get g_key_aa_kernel_desc {
    return Intl.message(
      'Modular account with plugin support from ZeroDev',
      name: 'g_key_aa_kernel_desc',
      desc: '',
      args: [],
    );
  }

  /// `Select Chain`
  String get g_key_aa_select_chain {
    return Intl.message(
      'Select Chain',
      name: 'g_key_aa_select_chain',
      desc: '',
      args: [],
    );
  }

  /// `Select Account Type`
  String get g_key_aa_select_type {
    return Intl.message(
      'Select Account Type',
      name: 'g_key_aa_select_type',
      desc: '',
      args: [],
    );
  }

  /// `Counterfactual Address`
  String get g_key_aa_counterfactual_address {
    return Intl.message(
      'Counterfactual Address',
      name: 'g_key_aa_counterfactual_address',
      desc: '',
      args: [],
    );
  }

  /// `This address is pre-computed and will be deployed when you make your first transaction.`
  String get g_key_aa_address_preview {
    return Intl.message(
      'This address is pre-computed and will be deployed when you make your first transaction.',
      name: 'g_key_aa_address_preview',
      desc: '',
      args: [],
    );
  }

  /// `Deployed`
  String get g_key_aa_deployed {
    return Intl.message(
      'Deployed',
      name: 'g_key_aa_deployed',
      desc: '',
      args: [],
    );
  }

  /// `Not Deployed`
  String get g_key_aa_not_deployed {
    return Intl.message(
      'Not Deployed',
      name: 'g_key_aa_not_deployed',
      desc: '',
      args: [],
    );
  }

  /// `Deploying...`
  String get g_key_aa_deploying {
    return Intl.message(
      'Deploying...',
      name: 'g_key_aa_deploying',
      desc: '',
      args: [],
    );
  }

  /// `Deploy`
  String get g_key_aa_deploy {
    return Intl.message('Deploy', name: 'g_key_aa_deploy', desc: '', args: []);
  }

  /// `Deployment started`
  String get g_key_aa_deploy_started {
    return Intl.message(
      'Deployment started',
      name: 'g_key_aa_deploy_started',
      desc: '',
      args: [],
    );
  }

  /// `Account Details`
  String get g_key_aa_account_details {
    return Intl.message(
      'Account Details',
      name: 'g_key_aa_account_details',
      desc: '',
      args: [],
    );
  }

  /// `Chain ID`
  String get g_key_aa_chain_id {
    return Intl.message(
      'Chain ID',
      name: 'g_key_aa_chain_id',
      desc: '',
      args: [],
    );
  }

  /// `Factory`
  String get g_key_aa_factory {
    return Intl.message(
      'Factory',
      name: 'g_key_aa_factory',
      desc: '',
      args: [],
    );
  }

  /// `Owner`
  String get g_key_aa_owner {
    return Intl.message('Owner', name: 'g_key_aa_owner', desc: '', args: []);
  }

  /// `Created`
  String get g_key_aa_created {
    return Intl.message(
      'Created',
      name: 'g_key_aa_created',
      desc: '',
      args: [],
    );
  }

  /// `Last Activity`
  String get g_key_aa_last_activity {
    return Intl.message(
      'Last Activity',
      name: 'g_key_aa_last_activity',
      desc: '',
      args: [],
    );
  }

  /// `View All`
  String get g_key_aa_view_all {
    return Intl.message(
      'View All',
      name: 'g_key_aa_view_all',
      desc: '',
      args: [],
    );
  }

  /// `No smart accounts yet`
  String get g_key_aa_no_accounts {
    return Intl.message(
      'No smart accounts yet',
      name: 'g_key_aa_no_accounts',
      desc: '',
      args: [],
    );
  }

  /// `No accounts match your filter`
  String get g_key_aa_no_accounts_filter {
    return Intl.message(
      'No accounts match your filter',
      name: 'g_key_aa_no_accounts_filter',
      desc: '',
      args: [],
    );
  }

  /// `Smart Accounts`
  String get g_key_aa_smart_accounts {
    return Intl.message(
      'Smart Accounts',
      name: 'g_key_aa_smart_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Experience the next generation of Ethereum accounts with enhanced features`
  String get g_key_aa_description {
    return Intl.message(
      'Experience the next generation of Ethereum accounts with enhanced features',
      name: 'g_key_aa_description',
      desc: '',
      args: [],
    );
  }

  /// `Pay gas in any token`
  String get g_key_aa_feature_gas {
    return Intl.message(
      'Pay gas in any token',
      name: 'g_key_aa_feature_gas',
      desc: '',
      args: [],
    );
  }

  /// `Batch multiple transactions`
  String get g_key_aa_feature_batch {
    return Intl.message(
      'Batch multiple transactions',
      name: 'g_key_aa_feature_batch',
      desc: '',
      args: [],
    );
  }

  /// `Enhanced security`
  String get g_key_aa_feature_security {
    return Intl.message(
      'Enhanced security',
      name: 'g_key_aa_feature_security',
      desc: '',
      args: [],
    );
  }

  /// `Send tokens using your smart account`
  String get g_key_aa_send_desc {
    return Intl.message(
      'Send tokens using your smart account',
      name: 'g_key_aa_send_desc',
      desc: '',
      args: [],
    );
  }

  /// `Batch`
  String get g_key_aa_batch {
    return Intl.message('Batch', name: 'g_key_aa_batch', desc: '', args: []);
  }

  /// `Execute multiple operations at once`
  String get g_key_aa_batch_desc {
    return Intl.message(
      'Execute multiple operations at once',
      name: 'g_key_aa_batch_desc',
      desc: '',
      args: [],
    );
  }

  /// `Create your first smart account`
  String get g_key_aa_create_first {
    return Intl.message(
      'Create your first smart account',
      name: 'g_key_aa_create_first',
      desc: '',
      args: [],
    );
  }

  /// `Create a smart account to get started`
  String get g_key_aa_create_first_account {
    return Intl.message(
      'Create a smart account to get started',
      name: 'g_key_aa_create_first_account',
      desc: '',
      args: [],
    );
  }

  /// `Change`
  String get g_key_aa_change {
    return Intl.message('Change', name: 'g_key_aa_change', desc: '', args: []);
  }

  /// `Estimated Gas`
  String get g_key_aa_estimated_gas {
    return Intl.message(
      'Estimated Gas',
      name: 'g_key_aa_estimated_gas',
      desc: '',
      args: [],
    );
  }

  /// `AA Transfer`
  String get g_key_aa_send_title {
    return Intl.message(
      'AA Transfer',
      name: 'g_key_aa_send_title',
      desc: '',
      args: [],
    );
  }

  /// `Gas Payment`
  String get g_key_aa_gas_payment {
    return Intl.message(
      'Gas Payment',
      name: 'g_key_aa_gas_payment',
      desc: '',
      args: [],
    );
  }

  /// `Select Paymaster`
  String get g_key_aa_select_paymaster {
    return Intl.message(
      'Select Paymaster',
      name: 'g_key_aa_select_paymaster',
      desc: '',
      args: [],
    );
  }

  /// `Gas Payment Options`
  String get g_key_aa_gas_payment_options {
    return Intl.message(
      'Gas Payment Options',
      name: 'g_key_aa_gas_payment_options',
      desc: '',
      args: [],
    );
  }

  /// `Choose how you want to pay for transaction gas fees`
  String get g_key_aa_paymaster_description {
    return Intl.message(
      'Choose how you want to pay for transaction gas fees',
      name: 'g_key_aa_paymaster_description',
      desc: '',
      args: [],
    );
  }

  /// `Pay with ETH`
  String get g_key_aa_pay_with_eth {
    return Intl.message(
      'Pay with ETH',
      name: 'g_key_aa_pay_with_eth',
      desc: '',
      args: [],
    );
  }

  /// `Sponsored (Free)`
  String get g_key_aa_sponsored {
    return Intl.message(
      'Sponsored (Free)',
      name: 'g_key_aa_sponsored',
      desc: '',
      args: [],
    );
  }

  /// `Pay with`
  String get g_key_aa_pay_with {
    return Intl.message(
      'Pay with',
      name: 'g_key_aa_pay_with',
      desc: '',
      args: [],
    );
  }

  /// `FREE`
  String get g_key_aa_free {
    return Intl.message('FREE', name: 'g_key_aa_free', desc: '', args: []);
  }

  /// `Selected`
  String get g_key_aa_selected {
    return Intl.message(
      'Selected',
      name: 'g_key_aa_selected',
      desc: '',
      args: [],
    );
  }

  /// `Unavailable`
  String get g_key_aa_unavailable {
    return Intl.message(
      'Unavailable',
      name: 'g_key_aa_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Estimating...`
  String get g_key_aa_estimating {
    return Intl.message(
      'Estimating...',
      name: 'g_key_aa_estimating',
      desc: '',
      args: [],
    );
  }

  /// `Gas Estimate`
  String get g_key_aa_gas_estimate {
    return Intl.message(
      'Gas Estimate',
      name: 'g_key_aa_gas_estimate',
      desc: '',
      args: [],
    );
  }

  /// `Gas Sponsored`
  String get g_key_aa_gas_sponsored {
    return Intl.message(
      'Gas Sponsored',
      name: 'g_key_aa_gas_sponsored',
      desc: '',
      args: [],
    );
  }

  /// `Batch Transfer`
  String get g_key_aa_batch_title {
    return Intl.message(
      'Batch Transfer',
      name: 'g_key_aa_batch_title',
      desc: '',
      args: [],
    );
  }

  /// `Batch Transaction`
  String get g_key_aa_batch_transaction {
    return Intl.message(
      'Batch Transaction',
      name: 'g_key_aa_batch_transaction',
      desc: '',
      args: [],
    );
  }

  /// `Send multiple transactions in a single operation`
  String get g_key_aa_batch_description {
    return Intl.message(
      'Send multiple transactions in a single operation',
      name: 'g_key_aa_batch_description',
      desc: '',
      args: [],
    );
  }

  /// `Save Gas`
  String get g_key_aa_batch_save_gas {
    return Intl.message(
      'Save Gas',
      name: 'g_key_aa_batch_save_gas',
      desc: '',
      args: [],
    );
  }

  /// `Atomic Execution`
  String get g_key_aa_batch_atomic {
    return Intl.message(
      'Atomic Execution',
      name: 'g_key_aa_batch_atomic',
      desc: '',
      args: [],
    );
  }

  /// `Add Operation`
  String get g_key_aa_add_operation {
    return Intl.message(
      'Add Operation',
      name: 'g_key_aa_add_operation',
      desc: '',
      args: [],
    );
  }

  /// `Total Value`
  String get g_key_aa_total_value {
    return Intl.message(
      'Total Value',
      name: 'g_key_aa_total_value',
      desc: '',
      args: [],
    );
  }

  /// `Total Gas`
  String get g_key_aa_total_gas {
    return Intl.message(
      'Total Gas',
      name: 'g_key_aa_total_gas',
      desc: '',
      args: [],
    );
  }

  /// `Operations`
  String get g_key_aa_operations {
    return Intl.message(
      'Operations',
      name: 'g_key_aa_operations',
      desc: '',
      args: [],
    );
  }

  /// `No operations added`
  String get g_key_aa_no_operations {
    return Intl.message(
      'No operations added',
      name: 'g_key_aa_no_operations',
      desc: '',
      args: [],
    );
  }

  /// `Add your first operation`
  String get g_key_aa_add_first_operation {
    return Intl.message(
      'Add your first operation',
      name: 'g_key_aa_add_first_operation',
      desc: '',
      args: [],
    );
  }

  /// `Clear All`
  String get g_key_aa_clear_all {
    return Intl.message(
      'Clear All',
      name: 'g_key_aa_clear_all',
      desc: '',
      args: [],
    );
  }

  /// `Execute Batch`
  String get g_key_aa_execute_batch {
    return Intl.message(
      'Execute Batch',
      name: 'g_key_aa_execute_batch',
      desc: '',
      args: [],
    );
  }

  /// `Batch submitted successfully`
  String get g_key_aa_batch_success {
    return Intl.message(
      'Batch submitted successfully',
      name: 'g_key_aa_batch_success',
      desc: '',
      args: [],
    );
  }

  /// `Batch execution failed`
  String get g_key_aa_batch_failed {
    return Intl.message(
      'Batch execution failed',
      name: 'g_key_aa_batch_failed',
      desc: '',
      args: [],
    );
  }

  /// `Template saved`
  String get g_key_aa_batch_template_saved {
    return Intl.message(
      'Template saved',
      name: 'g_key_aa_batch_template_saved',
      desc: '',
      args: [],
    );
  }

  /// `Load Template`
  String get g_key_aa_batch_template_load {
    return Intl.message(
      'Load Template',
      name: 'g_key_aa_batch_template_load',
      desc: '',
      args: [],
    );
  }

  /// `Template Name`
  String get g_key_aa_batch_template_name {
    return Intl.message(
      'Template Name',
      name: 'g_key_aa_batch_template_name',
      desc: '',
      args: [],
    );
  }

  /// `Enter template name`
  String get g_key_aa_batch_template_name_hint {
    return Intl.message(
      'Enter template name',
      name: 'g_key_aa_batch_template_name_hint',
      desc: '',
      args: [],
    );
  }

  /// `Save as Template`
  String get g_key_aa_batch_save_template {
    return Intl.message(
      'Save as Template',
      name: 'g_key_aa_batch_save_template',
      desc: '',
      args: [],
    );
  }

  /// `Templates`
  String get g_key_aa_batch_templates {
    return Intl.message(
      'Templates',
      name: 'g_key_aa_batch_templates',
      desc: '',
      args: [],
    );
  }

  /// `No saved templates`
  String get g_key_aa_batch_no_templates {
    return Intl.message(
      'No saved templates',
      name: 'g_key_aa_batch_no_templates',
      desc: '',
      args: [],
    );
  }

  /// `Submitting...`
  String get g_key_aa_batch_submitting {
    return Intl.message(
      'Submitting...',
      name: 'g_key_aa_batch_submitting',
      desc: '',
      args: [],
    );
  }

  /// `EIP-7702`
  String get g_key_aa_eip7702_badge {
    return Intl.message(
      'EIP-7702',
      name: 'g_key_aa_eip7702_badge',
      desc: '',
      args: [],
    );
  }

  /// `v0.7`
  String get g_key_aa_version_v07 {
    return Intl.message(
      'v0.7',
      name: 'g_key_aa_version_v07',
      desc: '',
      args: [],
    );
  }

  /// `v0.8`
  String get g_key_aa_version_v08 {
    return Intl.message(
      'v0.8',
      name: 'g_key_aa_version_v08',
      desc: '',
      args: [],
    );
  }

  /// `Recommended`
  String get g_key_aa_recommended {
    return Intl.message(
      'Recommended',
      name: 'g_key_aa_recommended',
      desc: '',
      args: [],
    );
  }

  /// `Gas Savings`
  String get g_key_aa_gas_savings {
    return Intl.message(
      'Gas Savings',
      name: 'g_key_aa_gas_savings',
      desc: '',
      args: [],
    );
  }

  /// `Batch Operations`
  String get g_key_aa_batch_operations {
    return Intl.message(
      'Batch Operations',
      name: 'g_key_aa_batch_operations',
      desc: '',
      args: [],
    );
  }

  /// `Approve`
  String get g_key_aa_approve {
    return Intl.message(
      'Approve',
      name: 'g_key_aa_approve',
      desc: '',
      args: [],
    );
  }

  /// `Custom`
  String get g_key_aa_custom {
    return Intl.message('Custom', name: 'g_key_aa_custom', desc: '', args: []);
  }

  /// `Error`
  String get g_key_aa_error {
    return Intl.message('Error', name: 'g_key_aa_error', desc: '', args: []);
  }

  /// `by`
  String get g_key_aa_by {
    return Intl.message('by', name: 'g_key_aa_by', desc: '', args: []);
  }

  /// `saved`
  String get g_key_aa_saved {
    return Intl.message('saved', name: 'g_key_aa_saved', desc: '', args: []);
  }

  /// `Pay gas with your ETH`
  String get g_key_aa_pay_gas_yourself {
    return Intl.message(
      'Pay gas with your ETH',
      name: 'g_key_aa_pay_gas_yourself',
      desc: '',
      args: [],
    );
  }

  /// `Pay gas with token`
  String get g_key_aa_pay_gas_with_token {
    return Intl.message(
      'Pay gas with token',
      name: 'g_key_aa_pay_gas_with_token',
      desc: '',
      args: [],
    );
  }

  /// `Checking availability...`
  String get g_key_aa_paymaster_checking {
    return Intl.message(
      'Checking availability...',
      name: 'g_key_aa_paymaster_checking',
      desc: '',
      args: [],
    );
  }

  /// `Failed to load gas options`
  String get g_key_aa_paymaster_load_failed {
    return Intl.message(
      'Failed to load gas options',
      name: 'g_key_aa_paymaster_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get g_key_aa_paymaster_retry {
    return Intl.message(
      'Retry',
      name: 'g_key_aa_paymaster_retry',
      desc: '',
      args: [],
    );
  }

  /// `Not available on this chain`
  String get g_key_aa_paymaster_not_supported {
    return Intl.message(
      'Not available on this chain',
      name: 'g_key_aa_paymaster_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Sponsorship not available`
  String get g_key_aa_paymaster_sponsored_unavailable {
    return Intl.message(
      'Sponsorship not available',
      name: 'g_key_aa_paymaster_sponsored_unavailable',
      desc: '',
      args: [],
    );
  }

  /// `Est. cost`
  String get g_key_aa_paymaster_est_cost {
    return Intl.message(
      'Est. cost',
      name: 'g_key_aa_paymaster_est_cost',
      desc: '',
      args: [],
    );
  }

  /// `Balance`
  String get g_key_aa_paymaster_balance {
    return Intl.message(
      'Balance',
      name: 'g_key_aa_paymaster_balance',
      desc: '',
      args: [],
    );
  }

  /// `Quote expired`
  String get g_key_aa_paymaster_quote_expired {
    return Intl.message(
      'Quote expired',
      name: 'g_key_aa_paymaster_quote_expired',
      desc: '',
      args: [],
    );
  }

  /// `Chain Coverage`
  String get g_key_aa_paymaster_coverage {
    return Intl.message(
      'Chain Coverage',
      name: 'g_key_aa_paymaster_coverage',
      desc: '',
      args: [],
    );
  }

  /// `chains supported`
  String get g_key_aa_paymaster_chains_supported {
    return Intl.message(
      'chains supported',
      name: 'g_key_aa_paymaster_chains_supported',
      desc: '',
      args: [],
    );
  }

  /// `or`
  String get g_key_or {
    return Intl.message('or', name: 'g_key_or', desc: '', args: []);
  }

  /// `Login successful`
  String get g_key_login_success {
    return Intl.message(
      'Login successful',
      name: 'g_key_login_success',
      desc: '',
      args: [],
    );
  }

  /// `Social Login`
  String get g_key_social_login {
    return Intl.message(
      'Social Login',
      name: 'g_key_social_login',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Google`
  String get g_key_continue_with_google {
    return Intl.message(
      'Continue with Google',
      name: 'g_key_continue_with_google',
      desc: '',
      args: [],
    );
  }

  /// `Continue with Apple`
  String get g_key_continue_with_apple {
    return Intl.message(
      'Continue with Apple',
      name: 'g_key_continue_with_apple',
      desc: '',
      args: [],
    );
  }

  /// `Google sign-in cancelled`
  String get g_key_google_sign_in_cancelled {
    return Intl.message(
      'Google sign-in cancelled',
      name: 'g_key_google_sign_in_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Apple sign-in cancelled`
  String get g_key_apple_sign_in_cancelled {
    return Intl.message(
      'Apple sign-in cancelled',
      name: 'g_key_apple_sign_in_cancelled',
      desc: '',
      args: [],
    );
  }

  /// `Sign in failed`
  String get g_key_sign_in_failed {
    return Intl.message(
      'Sign in failed',
      name: 'g_key_sign_in_failed',
      desc: '',
      args: [],
    );
  }

  /// `Linked Accounts`
  String get g_key_linked_accounts {
    return Intl.message(
      'Linked Accounts',
      name: 'g_key_linked_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Link Account`
  String get g_key_link_account {
    return Intl.message(
      'Link Account',
      name: 'g_key_link_account',
      desc: '',
      args: [],
    );
  }

  /// `Unlink Account`
  String get g_key_unlink_account {
    return Intl.message(
      'Unlink Account',
      name: 'g_key_unlink_account',
      desc: '',
      args: [],
    );
  }

  /// `Account linked successfully`
  String get g_key_account_linked {
    return Intl.message(
      'Account linked successfully',
      name: 'g_key_account_linked',
      desc: '',
      args: [],
    );
  }

  /// `Account unlinked successfully`
  String get g_key_account_unlinked {
    return Intl.message(
      'Account unlinked successfully',
      name: 'g_key_account_unlinked',
      desc: '',
      args: [],
    );
  }

  /// `No linked accounts`
  String get g_key_no_linked_accounts {
    return Intl.message(
      'No linked accounts',
      name: 'g_key_no_linked_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Enterprise Login (SSO)`
  String get g_key_oidc_login {
    return Intl.message(
      'Enterprise Login (SSO)',
      name: 'g_key_oidc_login',
      desc: '',
      args: [],
    );
  }

  /// `Enterprise SSO not configured`
  String get g_key_oidc_not_configured {
    return Intl.message(
      'Enterprise SSO not configured',
      name: 'g_key_oidc_not_configured',
      desc: '',
      args: [],
    );
  }

  /// `SAML Login`
  String get g_key_saml_login {
    return Intl.message(
      'SAML Login',
      name: 'g_key_saml_login',
      desc: '',
      args: [],
    );
  }

  /// `SAML not configured`
  String get g_key_saml_not_configured {
    return Intl.message(
      'SAML not configured',
      name: 'g_key_saml_not_configured',
      desc: '',
      args: [],
    );
  }

  /// `Advanced Features`
  String get g_key_advanced_features {
    return Intl.message(
      'Advanced Features',
      name: 'g_key_advanced_features',
      desc: '',
      args: [],
    );
  }

  /// `Get your .eth name`
  String get g_key_ens_get_your_name {
    return Intl.message(
      'Get your .eth name',
      name: 'g_key_ens_get_your_name',
      desc: '',
      args: [],
    );
  }

  /// `Your decentralized identity on Ethereum`
  String get g_key_ens_register_description {
    return Intl.message(
      'Your decentralized identity on Ethereum',
      name: 'g_key_ens_register_description',
      desc: '',
      args: [],
    );
  }

  /// `Manage your Web3 identity`
  String get g_key_ens_manage_your_identity {
    return Intl.message(
      'Manage your Web3 identity',
      name: 'g_key_ens_manage_your_identity',
      desc: '',
      args: [],
    );
  }

  /// `Your Identity`
  String get g_key_ens_your_identity {
    return Intl.message(
      'Your Identity',
      name: 'g_key_ens_your_identity',
      desc: '',
      args: [],
    );
  }

  /// `Smart Account`
  String get g_key_aa_smart_account {
    return Intl.message(
      'Smart Account',
      name: 'g_key_aa_smart_account',
      desc: '',
      args: [],
    );
  }

  /// `Create Smart Account`
  String get g_key_aa_create_smart_account {
    return Intl.message(
      'Create Smart Account',
      name: 'g_key_aa_create_smart_account',
      desc: '',
      args: [],
    );
  }

  /// `Gasless transactions & batch operations`
  String get g_key_aa_gasless_transactions {
    return Intl.message(
      'Gasless transactions & batch operations',
      name: 'g_key_aa_gasless_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Smart Wallet`
  String get g_key_aa_smart_wallet {
    return Intl.message(
      'Smart Wallet',
      name: 'g_key_aa_smart_wallet',
      desc: '',
      args: [],
    );
  }

  /// `Gasless`
  String get g_key_aa_gasless {
    return Intl.message(
      'Gasless',
      name: 'g_key_aa_gasless',
      desc: '',
      args: [],
    );
  }

  /// `Ready`
  String get g_key_aa_ready {
    return Intl.message('Ready', name: 'g_key_aa_ready', desc: '', args: []);
  }

  /// `Pending`
  String get g_key_aa_pending {
    return Intl.message(
      'Pending',
      name: 'g_key_aa_pending',
      desc: '',
      args: [],
    );
  }

  /// `Session Keys`
  String get g_key_aa_session_keys {
    return Intl.message(
      'Session Keys',
      name: 'g_key_aa_session_keys',
      desc: '',
      args: [],
    );
  }

  /// `Authorize DApps with temporary access to your smart account`
  String get g_key_aa_session_keys_desc {
    return Intl.message(
      'Authorize DApps with temporary access to your smart account',
      name: 'g_key_aa_session_keys_desc',
      desc: '',
      args: [],
    );
  }

  /// `Choose Permission Level`
  String get g_key_aa_session_select_preset {
    return Intl.message(
      'Choose Permission Level',
      name: 'g_key_aa_session_select_preset',
      desc: '',
      args: [],
    );
  }

  /// `Send Only`
  String get g_key_aa_session_preset_transfer {
    return Intl.message(
      'Send Only',
      name: 'g_key_aa_session_preset_transfer',
      desc: '',
      args: [],
    );
  }

  /// `DApp Access`
  String get g_key_aa_session_preset_contract {
    return Intl.message(
      'DApp Access',
      name: 'g_key_aa_session_preset_contract',
      desc: '',
      args: [],
    );
  }

  /// `Full Control`
  String get g_key_aa_session_preset_full {
    return Intl.message(
      'Full Control',
      name: 'g_key_aa_session_preset_full',
      desc: '',
      args: [],
    );
  }

  /// `Low Risk`
  String get g_key_aa_session_risk_low {
    return Intl.message(
      'Low Risk',
      name: 'g_key_aa_session_risk_low',
      desc: '',
      args: [],
    );
  }

  /// `Medium Risk`
  String get g_key_aa_session_risk_medium {
    return Intl.message(
      'Medium Risk',
      name: 'g_key_aa_session_risk_medium',
      desc: '',
      args: [],
    );
  }

  /// `High Risk`
  String get g_key_aa_session_risk_high {
    return Intl.message(
      'High Risk',
      name: 'g_key_aa_session_risk_high',
      desc: '',
      args: [],
    );
  }

  /// `Allowed`
  String get g_key_aa_session_allowed {
    return Intl.message(
      'Allowed',
      name: 'g_key_aa_session_allowed',
      desc: '',
      args: [],
    );
  }

  /// `Blocked`
  String get g_key_aa_session_blocked {
    return Intl.message(
      'Blocked',
      name: 'g_key_aa_session_blocked',
      desc: '',
      args: [],
    );
  }

  /// `Valid For`
  String get g_key_aa_session_expiry {
    return Intl.message(
      'Valid For',
      name: 'g_key_aa_session_expiry',
      desc: '',
      args: [],
    );
  }

  /// `1 Hour`
  String get g_key_aa_session_1h {
    return Intl.message(
      '1 Hour',
      name: 'g_key_aa_session_1h',
      desc: '',
      args: [],
    );
  }

  /// `1 Day`
  String get g_key_aa_session_1d {
    return Intl.message(
      '1 Day',
      name: 'g_key_aa_session_1d',
      desc: '',
      args: [],
    );
  }

  /// `7 Days`
  String get g_key_aa_session_7d {
    return Intl.message(
      '7 Days',
      name: 'g_key_aa_session_7d',
      desc: '',
      args: [],
    );
  }

  /// `30 Days`
  String get g_key_aa_session_30d {
    return Intl.message(
      '30 Days',
      name: 'g_key_aa_session_30d',
      desc: '',
      args: [],
    );
  }

  /// `Label / DApp Name`
  String get g_key_aa_session_dapp_label {
    return Intl.message(
      'Label / DApp Name',
      name: 'g_key_aa_session_dapp_label',
      desc: '',
      args: [],
    );
  }

  /// `e.g. Uniswap, Aave...`
  String get g_key_aa_session_dapp_hint {
    return Intl.message(
      'e.g. Uniswap, Aave...',
      name: 'g_key_aa_session_dapp_hint',
      desc: '',
      args: [],
    );
  }

  /// `Max Amount`
  String get g_key_aa_session_amount_limit {
    return Intl.message(
      'Max Amount',
      name: 'g_key_aa_session_amount_limit',
      desc: '',
      args: [],
    );
  }

  /// `e.g. 100.00`
  String get g_key_aa_session_amount_hint {
    return Intl.message(
      'e.g. 100.00',
      name: 'g_key_aa_session_amount_hint',
      desc: '',
      args: [],
    );
  }

  /// `Session key created`
  String get g_key_aa_session_create_success {
    return Intl.message(
      'Session key created',
      name: 'g_key_aa_session_create_success',
      desc: '',
      args: [],
    );
  }

  /// `Failed to create session key`
  String get g_key_aa_session_create_failed {
    return Intl.message(
      'Failed to create session key',
      name: 'g_key_aa_session_create_failed',
      desc: '',
      args: [],
    );
  }

  /// `I understand this key's permissions`
  String get g_key_aa_session_confirm_risk {
    return Intl.message(
      'I understand this key\'s permissions',
      name: 'g_key_aa_session_confirm_risk',
      desc: '',
      args: [],
    );
  }

  /// `Review permissions before confirming`
  String get g_key_aa_session_risk_warning {
    return Intl.message(
      'Review permissions before confirming',
      name: 'g_key_aa_session_risk_warning',
      desc: '',
      args: [],
    );
  }

  /// `Transfer tokens within set limit`
  String get g_key_aa_session_transfer_can {
    return Intl.message(
      'Transfer tokens within set limit',
      name: 'g_key_aa_session_transfer_can',
      desc: '',
      args: [],
    );
  }

  /// `Interact with approved DApp contracts`
  String get g_key_aa_session_contract_can {
    return Intl.message(
      'Interact with approved DApp contracts',
      name: 'g_key_aa_session_contract_can',
      desc: '',
      args: [],
    );
  }

  /// `High risk — only trust verified DApps`
  String get g_key_aa_session_full_warning {
    return Intl.message(
      'High risk — only trust verified DApps',
      name: 'g_key_aa_session_full_warning',
      desc: '',
      args: [],
    );
  }

  /// `Active`
  String get g_key_aa_active {
    return Intl.message('Active', name: 'g_key_aa_active', desc: '', args: []);
  }

  /// `Expired`
  String get g_key_aa_expired {
    return Intl.message(
      'Expired',
      name: 'g_key_aa_expired',
      desc: '',
      args: [],
    );
  }

  /// `Revoked`
  String get g_key_aa_revoked_status {
    return Intl.message(
      'Revoked',
      name: 'g_key_aa_revoked_status',
      desc: '',
      args: [],
    );
  }

  /// `No session keys`
  String get g_key_aa_no_session_keys {
    return Intl.message(
      'No session keys',
      name: 'g_key_aa_no_session_keys',
      desc: '',
      args: [],
    );
  }

  /// `Revoke Session Key`
  String get g_key_aa_revoke_session {
    return Intl.message(
      'Revoke Session Key',
      name: 'g_key_aa_revoke_session',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.`
  String get g_key_aa_revoke_confirm {
    return Intl.message(
      'Are you sure you want to revoke this session key? The authorized DApp will no longer be able to execute transactions.',
      name: 'g_key_aa_revoke_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Revoke`
  String get g_key_aa_revoke {
    return Intl.message('Revoke', name: 'g_key_aa_revoke', desc: '', args: []);
  }

  /// `Revoking session key...`
  String get g_key_aa_revoking {
    return Intl.message(
      'Revoking session key...',
      name: 'g_key_aa_revoking',
      desc: '',
      args: [],
    );
  }

  /// `Session key revoked`
  String get g_key_aa_revoked {
    return Intl.message(
      'Session key revoked',
      name: 'g_key_aa_revoked',
      desc: '',
      args: [],
    );
  }

  /// `Create Session Key`
  String get g_key_aa_create_session {
    return Intl.message(
      'Create Session Key',
      name: 'g_key_aa_create_session',
      desc: '',
      args: [],
    );
  }

  /// `Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.`
  String get g_key_aa_create_session_desc {
    return Intl.message(
      'Session keys allow DApps to execute transactions on your behalf with limited permissions and time constraints.',
      name: 'g_key_aa_create_session_desc',
      desc: '',
      args: [],
    );
  }

  /// `Details`
  String get g_key_aa_details {
    return Intl.message(
      'Details',
      name: 'g_key_aa_details',
      desc: '',
      args: [],
    );
  }

  /// `Spending Limit`
  String get g_key_aa_spending_limit {
    return Intl.message(
      'Spending Limit',
      name: 'g_key_aa_spending_limit',
      desc: '',
      args: [],
    );
  }

  /// `Session Key Details`
  String get g_key_aa_session_details {
    return Intl.message(
      'Session Key Details',
      name: 'g_key_aa_session_details',
      desc: '',
      args: [],
    );
  }

  /// `Label`
  String get g_key_aa_label {
    return Intl.message('Label', name: 'g_key_aa_label', desc: '', args: []);
  }

  /// `Permission`
  String get g_key_aa_permission {
    return Intl.message(
      'Permission',
      name: 'g_key_aa_permission',
      desc: '',
      args: [],
    );
  }

  /// `Expires`
  String get g_key_aa_expires {
    return Intl.message(
      'Expires',
      name: 'g_key_aa_expires',
      desc: '',
      args: [],
    );
  }

  /// `Transactions`
  String get g_key_aa_transactions {
    return Intl.message(
      'Transactions',
      name: 'g_key_aa_transactions',
      desc: '',
      args: [],
    );
  }

  /// `Contract`
  String get g_key_aa_contract {
    return Intl.message(
      'Contract',
      name: 'g_key_aa_contract',
      desc: '',
      args: [],
    );
  }

  /// `Full Access`
  String get g_key_aa_full_access {
    return Intl.message(
      'Full Access',
      name: 'g_key_aa_full_access',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get g_key_aa_continue {
    return Intl.message(
      'Continue',
      name: 'g_key_aa_continue',
      desc: '',
      args: [],
    );
  }

  /// `Never`
  String get g_key_aa_never {
    return Intl.message('Never', name: 'g_key_aa_never', desc: '', args: []);
  }

  /// `Just now`
  String get g_key_aa_just_now {
    return Intl.message(
      'Just now',
      name: 'g_key_aa_just_now',
      desc: '',
      args: [],
    );
  }

  /// `Chain`
  String get g_key_aa_chain {
    return Intl.message('Chain', name: 'g_key_aa_chain', desc: '', args: []);
  }

  /// `Retry`
  String get g_key_aa_retry {
    return Intl.message('Retry', name: 'g_key_aa_retry', desc: '', args: []);
  }

  /// `Deploy Failed`
  String get g_key_aa_deploy_failed {
    return Intl.message(
      'Deploy Failed',
      name: 'g_key_aa_deploy_failed',
      desc: '',
      args: [],
    );
  }

  /// `Account will be deployed on first transaction`
  String get g_key_aa_not_deployed_desc {
    return Intl.message(
      'Account will be deployed on first transaction',
      name: 'g_key_aa_not_deployed_desc',
      desc: '',
      args: [],
    );
  }

  /// `Deployment transaction is being processed`
  String get g_key_aa_deploying_desc {
    return Intl.message(
      'Deployment transaction is being processed',
      name: 'g_key_aa_deploying_desc',
      desc: '',
      args: [],
    );
  }

  /// `Account is ready to use`
  String get g_key_aa_deployed_desc {
    return Intl.message(
      'Account is ready to use',
      name: 'g_key_aa_deployed_desc',
      desc: '',
      args: [],
    );
  }

  /// `Deployment failed. Please try again.`
  String get g_key_aa_deploy_failed_desc {
    return Intl.message(
      'Deployment failed. Please try again.',
      name: 'g_key_aa_deploy_failed_desc',
      desc: '',
      args: [],
    );
  }

  /// `Biconomy Account`
  String get g_key_aa_biconomy_account {
    return Intl.message(
      'Biconomy Account',
      name: 'g_key_aa_biconomy_account',
      desc: '',
      args: [],
    );
  }

  /// `Modular ERC-7579 smart account with gasless transaction support`
  String get g_key_aa_biconomy_desc {
    return Intl.message(
      'Modular ERC-7579 smart account with gasless transaction support',
      name: 'g_key_aa_biconomy_desc',
      desc: '',
      args: [],
    );
  }

  /// `Calculating address...`
  String get g_key_aa_address_calculating {
    return Intl.message(
      'Calculating address...',
      name: 'g_key_aa_address_calculating',
      desc: '',
      args: [],
    );
  }

  /// `Failed to calculate address. Please try again.`
  String get g_key_aa_address_error {
    return Intl.message(
      'Failed to calculate address. Please try again.',
      name: 'g_key_aa_address_error',
      desc: '',
      args: [],
    );
  }

  /// `Threshold`
  String get g_key_aa_safe_threshold {
    return Intl.message(
      'Threshold',
      name: 'g_key_aa_safe_threshold',
      desc: '',
      args: [],
    );
  }

  /// `Guardians`
  String get g_key_aa_safe_guardians {
    return Intl.message(
      'Guardians',
      name: 'g_key_aa_safe_guardians',
      desc: '',
      args: [],
    );
  }

  /// `New Device Login`
  String get device_login_title {
    return Intl.message(
      'New Device Login',
      name: 'device_login_title',
      desc: '',
      args: [],
    );
  }

  /// `Your account was just logged in on {deviceName} ({os}). If this wasn't you, we recommend changing your password.`
  String device_login_message(Object deviceName, Object os) {
    return Intl.message(
      'Your account was just logged in on $deviceName ($os). If this wasn\'t you, we recommend changing your password.',
      name: 'device_login_message',
      desc: '',
      args: [deviceName, os],
    );
  }

  /// `Got it`
  String get device_login_dismiss {
    return Intl.message(
      'Got it',
      name: 'device_login_dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Change Password`
  String get device_login_change_password {
    return Intl.message(
      'Change Password',
      name: 'device_login_change_password',
      desc: '',
      args: [],
    );
  }

  /// `Filter`
  String get g_key_filter {
    return Intl.message('Filter', name: 'g_key_filter', desc: '', args: []);
  }

  /// `Reset`
  String get g_key_reset {
    return Intl.message('Reset', name: 'g_key_reset', desc: '', args: []);
  }

  /// `Type`
  String get g_key_filter_type {
    return Intl.message('Type', name: 'g_key_filter_type', desc: '', args: []);
  }

  /// `Eligible only`
  String get g_key_eligible_only {
    return Intl.message(
      'Eligible only',
      name: 'g_key_eligible_only',
      desc: '',
      args: [],
    );
  }

  /// `High value only`
  String get g_key_high_value_only {
    return Intl.message(
      'High value only',
      name: 'g_key_high_value_only',
      desc: '',
      args: [],
    );
  }

  /// `Apply`
  String get g_key_apply {
    return Intl.message('Apply', name: 'g_key_apply', desc: '', args: []);
  }

  /// `Notification Settings`
  String get g_key_notification_settings {
    return Intl.message(
      'Notification Settings',
      name: 'g_key_notification_settings',
      desc: '',
      args: [],
    );
  }

  /// `New airdrops`
  String get g_key_new_airdrops {
    return Intl.message(
      'New airdrops',
      name: 'g_key_new_airdrops',
      desc: '',
      args: [],
    );
  }

  /// `Eligibility alerts`
  String get g_key_eligibility_alerts {
    return Intl.message(
      'Eligibility alerts',
      name: 'g_key_eligibility_alerts',
      desc: '',
      args: [],
    );
  }

  /// `Deadline reminders`
  String get g_key_deadline_reminders {
    return Intl.message(
      'Deadline reminders',
      name: 'g_key_deadline_reminders',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient balance: total amount would exceed available {value}`
  String g_key_batch_insufficient_balance(Object value) {
    return Intl.message(
      'Insufficient balance: total amount would exceed available $value',
      name: 'g_key_batch_insufficient_balance',
      desc: '',
      args: [value],
    );
  }

  /// `Account already imported`
  String get g_key_hw_account_already_imported {
    return Intl.message(
      'Account already imported',
      name: 'g_key_hw_account_already_imported',
      desc: '',
      args: [],
    );
  }

  /// `Failed to import account: {value}`
  String g_key_hw_import_failed(Object value) {
    return Intl.message(
      'Failed to import account: $value',
      name: 'g_key_hw_import_failed',
      desc: '',
      args: [value],
    );
  }

  /// `Wallet Accounts`
  String get g_key_hw_wallet_accounts {
    return Intl.message(
      'Wallet Accounts',
      name: 'g_key_hw_wallet_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Device not connected`
  String get g_key_hw_not_connected {
    return Intl.message(
      'Device not connected',
      name: 'g_key_hw_not_connected',
      desc: '',
      args: [],
    );
  }

  /// `Go Back`
  String get g_key_hw_go_back {
    return Intl.message(
      'Go Back',
      name: 'g_key_hw_go_back',
      desc: '',
      args: [],
    );
  }

  /// `Loading accounts...`
  String get g_key_hw_loading_accounts {
    return Intl.message(
      'Loading accounts...',
      name: 'g_key_hw_loading_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Please confirm on your device if prompted`
  String get g_key_hw_loading_hint {
    return Intl.message(
      'Please confirm on your device if prompted',
      name: 'g_key_hw_loading_hint',
      desc: '',
      args: [],
    );
  }

  /// `No accounts found`
  String get g_key_hw_no_accounts_found {
    return Intl.message(
      'No accounts found',
      name: 'g_key_hw_no_accounts_found',
      desc: '',
      args: [],
    );
  }

  /// `Make sure the {app} app is open on your Ledger`
  String g_key_hw_open_ledger_app_hint(String app) {
    return Intl.message(
      'Make sure the $app app is open on your Ledger',
      name: 'g_key_hw_open_ledger_app_hint',
      desc: '',
      args: [app],
    );
  }

  /// `Address copied`
  String get g_key_hw_address_copied {
    return Intl.message(
      'Address copied',
      name: 'g_key_hw_address_copied',
      desc: '',
      args: [],
    );
  }

  /// `Do you want to track this hardware wallet account?\n\nAddress: {address}\nNetwork: {network}`
  String g_key_hw_add_account_content(String address, String network) {
    return Intl.message(
      'Do you want to track this hardware wallet account?\n\nAddress: $address\nNetwork: $network',
      name: 'g_key_hw_add_account_content',
      desc: '',
      args: [address, network],
    );
  }

  /// `Account {address} added`
  String g_key_hw_account_added(String address) {
    return Intl.message(
      'Account $address added',
      name: 'g_key_hw_account_added',
      desc: '',
      args: [address],
    );
  }

  /// `Cancel`
  String get g_key_hw_cancel {
    return Intl.message('Cancel', name: 'g_key_hw_cancel', desc: '', args: []);
  }

  /// `Add`
  String get g_key_hw_add {
    return Intl.message('Add', name: 'g_key_hw_add', desc: '', args: []);
  }

  /// `Load More`
  String get g_key_hw_load_more {
    return Intl.message(
      'Load More',
      name: 'g_key_hw_load_more',
      desc: '',
      args: [],
    );
  }

  /// `Connected`
  String get g_key_hw_connected {
    return Intl.message(
      'Connected',
      name: 'g_key_hw_connected',
      desc: '',
      args: [],
    );
  }

  /// `Not Connected`
  String get g_key_hw_not_connected_label {
    return Intl.message(
      'Not Connected',
      name: 'g_key_hw_not_connected_label',
      desc: '',
      args: [],
    );
  }

  /// `Disconnect`
  String get g_key_hw_disconnect {
    return Intl.message(
      'Disconnect',
      name: 'g_key_hw_disconnect',
      desc: '',
      args: [],
    );
  }

  /// `View Accounts`
  String get g_key_hw_view_accounts {
    return Intl.message(
      'View Accounts',
      name: 'g_key_hw_view_accounts',
      desc: '',
      args: [],
    );
  }

  /// `Check App`
  String get g_key_hw_check_app {
    return Intl.message(
      'Check App',
      name: 'g_key_hw_check_app',
      desc: '',
      args: [],
    );
  }

  /// `Saved Devices`
  String get g_key_hw_saved_devices {
    return Intl.message(
      'Saved Devices',
      name: 'g_key_hw_saved_devices',
      desc: '',
      args: [],
    );
  }

  /// `Connect New Device`
  String get g_key_hw_connect_new_device {
    return Intl.message(
      'Connect New Device',
      name: 'g_key_hw_connect_new_device',
      desc: '',
      args: [],
    );
  }

  /// `Connect Ledger (Bluetooth)`
  String get g_key_hw_connect_new_ledger {
    return Intl.message(
      'Connect Ledger (Bluetooth)',
      name: 'g_key_hw_connect_new_ledger',
      desc: '',
      args: [],
    );
  }

  /// `Connect Trezor (USB)`
  String get g_key_hw_connect_new_trezor {
    return Intl.message(
      'Connect Trezor (USB)',
      name: 'g_key_hw_connect_new_trezor',
      desc: '',
      args: [],
    );
  }

  /// `Air-gap with Keystone (QR)`
  String get g_key_hw_connect_new_keystone {
    return Intl.message(
      'Air-gap with Keystone (QR)',
      name: 'g_key_hw_connect_new_keystone',
      desc: '',
      args: [],
    );
  }

  /// `Supported Devices`
  String get g_key_hw_supported_devices {
    return Intl.message(
      'Supported Devices',
      name: 'g_key_hw_supported_devices',
      desc: '',
      args: [],
    );
  }

  /// `Make sure your device is unlocked and Bluetooth is enabled before connecting.`
  String get g_key_hw_ble_hint {
    return Intl.message(
      'Make sure your device is unlocked and Bluetooth is enabled before connecting.',
      name: 'g_key_hw_ble_hint',
      desc: '',
      args: [],
    );
  }

  /// `Remove Device`
  String get g_key_hw_remove_device {
    return Intl.message(
      'Remove Device',
      name: 'g_key_hw_remove_device',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure you want to remove "{name}" from saved devices?`
  String g_key_hw_remove_device_confirm(String name) {
    return Intl.message(
      'Are you sure you want to remove "$name" from saved devices?',
      name: 'g_key_hw_remove_device_confirm',
      desc: '',
      args: [name],
    );
  }

  /// `Remove`
  String get g_key_hw_remove {
    return Intl.message('Remove', name: 'g_key_hw_remove', desc: '', args: []);
  }

  /// `Current app: {app}`
  String g_key_hw_current_app_label(String app) {
    return Intl.message(
      'Current app: $app',
      name: 'g_key_hw_current_app_label',
      desc: '',
      args: [app],
    );
  }

  /// `No app is currently open`
  String get g_key_hw_no_app_open {
    return Intl.message(
      'No app is currently open',
      name: 'g_key_hw_no_app_open',
      desc: '',
      args: [],
    );
  }

  /// `Last connected: {date}`
  String g_key_hw_last_connected(String date) {
    return Intl.message(
      'Last connected: $date',
      name: 'g_key_hw_last_connected',
      desc: '',
      args: [date],
    );
  }

  /// `Today`
  String get g_key_hw_today {
    return Intl.message('Today', name: 'g_key_hw_today', desc: '', args: []);
  }

  /// `Yesterday`
  String get g_key_hw_yesterday {
    return Intl.message(
      'Yesterday',
      name: 'g_key_hw_yesterday',
      desc: '',
      args: [],
    );
  }

  /// `{days} days ago`
  String g_key_hw_days_ago(int days) {
    return Intl.message(
      '$days days ago',
      name: 'g_key_hw_days_ago',
      desc: '',
      args: [days],
    );
  }

  /// `Connecting...`
  String get g_key_hw_connecting {
    return Intl.message(
      'Connecting...',
      name: 'g_key_hw_connecting',
      desc: '',
      args: [],
    );
  }

  /// `Connect Trezor`
  String get g_key_hw_trezor_connect_title {
    return Intl.message(
      'Connect Trezor',
      name: 'g_key_hw_trezor_connect_title',
      desc: '',
      args: [],
    );
  }

  /// `Connect your Trezor device via USB cable and unlock it`
  String get g_key_hw_trezor_usb_hint {
    return Intl.message(
      'Connect your Trezor device via USB cable and unlock it',
      name: 'g_key_hw_trezor_usb_hint',
      desc: '',
      args: [],
    );
  }

  /// `Connecting to Trezor...`
  String get g_key_hw_trezor_connecting {
    return Intl.message(
      'Connecting to Trezor...',
      name: 'g_key_hw_trezor_connecting',
      desc: '',
      args: [],
    );
  }

  /// `Enter PIN on your Trezor device`
  String get g_key_hw_trezor_pin_required {
    return Intl.message(
      'Enter PIN on your Trezor device',
      name: 'g_key_hw_trezor_pin_required',
      desc: '',
      args: [],
    );
  }

  /// `Enter passphrase on your Trezor device`
  String get g_key_hw_trezor_passphrase_required {
    return Intl.message(
      'Enter passphrase on your Trezor device',
      name: 'g_key_hw_trezor_passphrase_required',
      desc: '',
      args: [],
    );
  }

  /// `Trezor connected successfully`
  String get g_key_hw_trezor_connected {
    return Intl.message(
      'Trezor connected successfully',
      name: 'g_key_hw_trezor_connected',
      desc: '',
      args: [],
    );
  }

  /// `Failed to connect to Trezor. Make sure USB is connected.`
  String get g_key_hw_trezor_connect_failed {
    return Intl.message(
      'Failed to connect to Trezor. Make sure USB is connected.',
      name: 'g_key_hw_trezor_connect_failed',
      desc: '',
      args: [],
    );
  }

  /// `Connect Keystone`
  String get g_key_hw_keystone_connect_title {
    return Intl.message(
      'Connect Keystone',
      name: 'g_key_hw_keystone_connect_title',
      desc: '',
      args: [],
    );
  }

  /// `Scan the QR code from your Keystone device to import accounts`
  String get g_key_hw_keystone_scan_xpub_hint {
    return Intl.message(
      'Scan the QR code from your Keystone device to import accounts',
      name: 'g_key_hw_keystone_scan_xpub_hint',
      desc: '',
      args: [],
    );
  }

  /// `Scan this QR code with your Keystone device to sign the transaction`
  String get g_key_hw_keystone_scan_request_hint {
    return Intl.message(
      'Scan this QR code with your Keystone device to sign the transaction',
      name: 'g_key_hw_keystone_scan_request_hint',
      desc: '',
      args: [],
    );
  }

  /// `Scan Keystone Signature`
  String get g_key_hw_keystone_scan_response_title {
    return Intl.message(
      'Scan Keystone Signature',
      name: 'g_key_hw_keystone_scan_response_title',
      desc: '',
      args: [],
    );
  }

  /// `Point your camera at the QR code displayed on your Keystone device`
  String get g_key_hw_keystone_scan_response_hint {
    return Intl.message(
      'Point your camera at the QR code displayed on your Keystone device',
      name: 'g_key_hw_keystone_scan_response_hint',
      desc: '',
      args: [],
    );
  }

  /// `Waiting for Keystone signature...`
  String get g_key_hw_keystone_signing {
    return Intl.message(
      'Waiting for Keystone signature...',
      name: 'g_key_hw_keystone_signing',
      desc: '',
      args: [],
    );
  }

  /// `Signature received successfully`
  String get g_key_hw_keystone_signature_received {
    return Intl.message(
      'Signature received successfully',
      name: 'g_key_hw_keystone_signature_received',
      desc: '',
      args: [],
    );
  }

  /// `Failed to parse QR code. Please try again.`
  String get g_key_hw_keystone_scan_error {
    return Intl.message(
      'Failed to parse QR code. Please try again.',
      name: 'g_key_hw_keystone_scan_error',
      desc: '',
      args: [],
    );
  }

  /// `Invalid response from Keystone device`
  String get g_key_hw_keystone_invalid_response {
    return Intl.message(
      'Invalid response from Keystone device',
      name: 'g_key_hw_keystone_invalid_response',
      desc: '',
      args: [],
    );
  }

  /// `Tap to scan Keystone response`
  String get g_key_hw_keystone_tap_to_scan {
    return Intl.message(
      'Tap to scan Keystone response',
      name: 'g_key_hw_keystone_tap_to_scan',
      desc: '',
      args: [],
    );
  }

  /// `Pending`
  String get g_key_bridge_status_pending {
    return Intl.message(
      'Pending',
      name: 'g_key_bridge_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `In Progress`
  String get g_key_bridge_status_in_progress {
    return Intl.message(
      'In Progress',
      name: 'g_key_bridge_status_in_progress',
      desc: '',
      args: [],
    );
  }

  /// `Completed`
  String get g_key_bridge_status_completed {
    return Intl.message(
      'Completed',
      name: 'g_key_bridge_status_completed',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get g_key_bridge_status_failed {
    return Intl.message(
      'Failed',
      name: 'g_key_bridge_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Chain not supported`
  String get g_key_bridge_chain_not_supported {
    return Intl.message(
      'Chain not supported',
      name: 'g_key_bridge_chain_not_supported',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get g_key_bridge_select {
    return Intl.message(
      'Select',
      name: 'g_key_bridge_select',
      desc: '',
      args: [],
    );
  }

  /// `Other assets`
  String get g_key_coin_list_separator {
    return Intl.message(
      'Other assets',
      name: 'g_key_coin_list_separator',
      desc: '',
      args: [],
    );
  }

  /// `All assets are below $1`
  String get g_key_coin_list_all_hidden {
    return Intl.message(
      'All assets are below \$1',
      name: 'g_key_coin_list_all_hidden',
      desc: '',
      args: [],
    );
  }

  /// `Tap to show all`
  String get g_key_coin_list_show_all {
    return Intl.message(
      'Tap to show all',
      name: 'g_key_coin_list_show_all',
      desc: '',
      args: [],
    );
  }

  /// `Recent`
  String get g_key_coin_search_recent {
    return Intl.message(
      'Recent',
      name: 'g_key_coin_search_recent',
      desc: '',
      args: [],
    );
  }

  /// `Direction`
  String get g_key_tx_filter_direction {
    return Intl.message(
      'Direction',
      name: 'g_key_tx_filter_direction',
      desc: '',
      args: [],
    );
  }

  /// `Date Range`
  String get g_key_tx_filter_date_range {
    return Intl.message(
      'Date Range',
      name: 'g_key_tx_filter_date_range',
      desc: '',
      args: [],
    );
  }

  /// `Start Date`
  String get g_key_tx_filter_date_from {
    return Intl.message(
      'Start Date',
      name: 'g_key_tx_filter_date_from',
      desc: '',
      args: [],
    );
  }

  /// `End Date`
  String get g_key_tx_filter_date_to {
    return Intl.message(
      'End Date',
      name: 'g_key_tx_filter_date_to',
      desc: '',
      args: [],
    );
  }

  /// `No transactions match your filter`
  String get g_key_tx_no_results {
    return Intl.message(
      'No transactions match your filter',
      name: 'g_key_tx_no_results',
      desc: '',
      args: [],
    );
  }

  /// `Payment History`
  String get g_key_payment_history {
    return Intl.message(
      'Payment History',
      name: 'g_key_payment_history',
      desc: '',
      args: [],
    );
  }

  /// `Load failed`
  String get g_key_payment_load_failed {
    return Intl.message(
      'Load failed',
      name: 'g_key_payment_load_failed',
      desc: '',
      args: [],
    );
  }

  /// `Incoming`
  String get g_key_payment_incoming {
    return Intl.message(
      'Incoming',
      name: 'g_key_payment_incoming',
      desc: '',
      args: [],
    );
  }

  /// `Outgoing`
  String get g_key_payment_outgoing {
    return Intl.message(
      'Outgoing',
      name: 'g_key_payment_outgoing',
      desc: '',
      args: [],
    );
  }

  /// `≈ {amount}{token}`
  String g_key_payment_approx_token(String amount, String token) {
    return Intl.message(
      '≈ $amount$token',
      name: 'g_key_payment_approx_token',
      desc: '',
      args: [amount, token],
    );
  }

  /// `Payment QR`
  String get g_key_payment_code_title {
    return Intl.message(
      'Payment QR',
      name: 'g_key_payment_code_title',
      desc: '',
      args: [],
    );
  }

  /// `History`
  String get g_key_payment_history_btn {
    return Intl.message(
      'History',
      name: 'g_key_payment_history_btn',
      desc: '',
      args: [],
    );
  }

  /// `Not Set`
  String get g_key_payment_name_not_set {
    return Intl.message(
      'Not Set',
      name: 'g_key_payment_name_not_set',
      desc: '',
      args: [],
    );
  }

  /// `Set Payment Amount`
  String get g_key_payment_set_amount_title {
    return Intl.message(
      'Set Payment Amount',
      name: 'g_key_payment_set_amount_title',
      desc: '',
      args: [],
    );
  }

  /// `Confirm`
  String get g_key_payment_confirm {
    return Intl.message(
      'Confirm',
      name: 'g_key_payment_confirm',
      desc: '',
      args: [],
    );
  }

  /// `Invalid payment amount`
  String get g_key_payment_amount_invalid {
    return Intl.message(
      'Invalid payment amount',
      name: 'g_key_payment_amount_invalid',
      desc: '',
      args: [],
    );
  }

  /// `Payment`
  String get g_key_payment_title {
    return Intl.message(
      'Payment',
      name: 'g_key_payment_title',
      desc: '',
      args: [],
    );
  }

  /// `Payment successful!`
  String get g_key_payment_success {
    return Intl.message(
      'Payment successful!',
      name: 'g_key_payment_success',
      desc: '',
      args: [],
    );
  }

  /// `Wallet`
  String get g_key_payment_wallet {
    return Intl.message(
      'Wallet',
      name: 'g_key_payment_wallet',
      desc: '',
      args: [],
    );
  }

  /// `≈ {amount} USDT`
  String g_key_payment_approx_usdt(String amount) {
    return Intl.message(
      '≈ $amount USDT',
      name: 'g_key_payment_approx_usdt',
      desc: '',
      args: [amount],
    );
  }

  /// `Insufficient USDT balance!`
  String get g_key_payment_usdt_insufficient {
    return Intl.message(
      'Insufficient USDT balance!',
      name: 'g_key_payment_usdt_insufficient',
      desc: '',
      args: [],
    );
  }

  /// `Please add USDT token!`
  String get g_key_payment_usdt_not_found {
    return Intl.message(
      'Please add USDT token!',
      name: 'g_key_payment_usdt_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Insufficient native balance!`
  String get g_key_payment_native_insufficient {
    return Intl.message(
      'Insufficient native balance!',
      name: 'g_key_payment_native_insufficient',
      desc: '',
      args: [],
    );
  }

  /// `Native chain not found!`
  String get g_key_payment_native_not_found {
    return Intl.message(
      'Native chain not found!',
      name: 'g_key_payment_native_not_found',
      desc: '',
      args: [],
    );
  }

  /// `Gas Limit Very High`
  String get g_key_aa_gas_warn_total_high {
    return Intl.message(
      'Gas Limit Very High',
      name: 'g_key_aa_gas_warn_total_high',
      desc: '',
      args: [],
    );
  }

  /// `Estimated total gas ({gas}) is unusually high. Check your transaction for errors.`
  String g_key_aa_gas_warn_total_high_desc(String gas) {
    return Intl.message(
      'Estimated total gas ($gas) is unusually high. Check your transaction for errors.',
      name: 'g_key_aa_gas_warn_total_high_desc',
      desc: '',
      args: [gas],
    );
  }

  /// `Verification Gas High`
  String get g_key_aa_gas_warn_verify_high {
    return Intl.message(
      'Verification Gas High',
      name: 'g_key_aa_gas_warn_verify_high',
      desc: '',
      args: [],
    );
  }

  /// `Verification gas ({gas}) may be too high. This can happen with complex account logic.`
  String g_key_aa_gas_warn_verify_high_desc(String gas) {
    return Intl.message(
      'Verification gas ($gas) may be too high. This can happen with complex account logic.',
      name: 'g_key_aa_gas_warn_verify_high_desc',
      desc: '',
      args: [gas],
    );
  }

  /// `Execution Gas High`
  String get g_key_aa_gas_warn_call_high {
    return Intl.message(
      'Execution Gas High',
      name: 'g_key_aa_gas_warn_call_high',
      desc: '',
      args: [],
    );
  }

  /// `Execution gas ({gas}) is high. The called contract may consume more gas than expected.`
  String g_key_aa_gas_warn_call_high_desc(String gas) {
    return Intl.message(
      'Execution gas ($gas) is high. The called contract may consume more gas than expected.',
      name: 'g_key_aa_gas_warn_call_high_desc',
      desc: '',
      args: [gas],
    );
  }

  /// `Paymaster Overhead High`
  String get g_key_aa_gas_warn_paymaster {
    return Intl.message(
      'Paymaster Overhead High',
      name: 'g_key_aa_gas_warn_paymaster',
      desc: '',
      args: [],
    );
  }

  /// `Paymaster gas overhead ({gas}) is high. Gas-free transactions may cost more.`
  String g_key_aa_gas_warn_paymaster_desc(String gas) {
    return Intl.message(
      'Paymaster gas overhead ($gas) is high. Gas-free transactions may cost more.',
      name: 'g_key_aa_gas_warn_paymaster_desc',
      desc: '',
      args: [gas],
    );
  }

  /// `Deployment Gas Overhead`
  String get g_key_aa_gas_warn_deploy {
    return Intl.message(
      'Deployment Gas Overhead',
      name: 'g_key_aa_gas_warn_deploy',
      desc: '',
      args: [],
    );
  }

  /// `First transaction includes account deployment (~{gas} gas). Subsequent transactions will be cheaper.`
  String g_key_aa_gas_warn_deploy_desc(String gas) {
    return Intl.message(
      'First transaction includes account deployment (~$gas gas). Subsequent transactions will be cheaper.',
      name: 'g_key_aa_gas_warn_deploy_desc',
      desc: '',
      args: [gas],
    );
  }

  /// `Possible Gas Under-Estimate`
  String get g_key_aa_gas_warn_under_est {
    return Intl.message(
      'Possible Gas Under-Estimate',
      name: 'g_key_aa_gas_warn_under_est',
      desc: '',
      args: [],
    );
  }

  /// `The actual gas used may exceed the estimate. Consider adding a larger buffer.`
  String get g_key_aa_gas_warn_under_est_desc {
    return Intl.message(
      'The actual gas used may exceed the estimate. Consider adding a larger buffer.',
      name: 'g_key_aa_gas_warn_under_est_desc',
      desc: '',
      args: [],
    );
  }

  /// `Confirm Swap`
  String get g_key_dex_confirm_title {
    return Intl.message(
      'Confirm Swap',
      name: 'g_key_dex_confirm_title',
      desc: '',
      args: [],
    );
  }

  /// `DEX History`
  String get g_key_dex_history_title {
    return Intl.message(
      'DEX History',
      name: 'g_key_dex_history_title',
      desc: '',
      args: [],
    );
  }

  /// `Best Route`
  String get g_key_dex_best_route {
    return Intl.message(
      'Best Route',
      name: 'g_key_dex_best_route',
      desc: '',
      args: [],
    );
  }

  /// `Price Impact`
  String get g_key_dex_price_impact {
    return Intl.message(
      'Price Impact',
      name: 'g_key_dex_price_impact',
      desc: '',
      args: [],
    );
  }

  /// `Gas Estimate`
  String get g_key_dex_gas_estimate {
    return Intl.message(
      'Gas Estimate',
      name: 'g_key_dex_gas_estimate',
      desc: '',
      args: [],
    );
  }

  /// `You Pay`
  String get g_key_dex_you_pay {
    return Intl.message(
      'You Pay',
      name: 'g_key_dex_you_pay',
      desc: '',
      args: [],
    );
  }

  /// `You Receive`
  String get g_key_dex_you_receive {
    return Intl.message(
      'You Receive',
      name: 'g_key_dex_you_receive',
      desc: '',
      args: [],
    );
  }

  /// `Best Source`
  String get g_key_dex_best_source {
    return Intl.message(
      'Best Source',
      name: 'g_key_dex_best_source',
      desc: '',
      args: [],
    );
  }

  /// `Chain`
  String get g_key_dex_chain {
    return Intl.message('Chain', name: 'g_key_dex_chain', desc: '', args: []);
  }

  /// `Slippage Tolerance`
  String get g_key_dex_slippage {
    return Intl.message(
      'Slippage Tolerance',
      name: 'g_key_dex_slippage',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get g_key_dex_select_token {
    return Intl.message(
      'Select',
      name: 'g_key_dex_select_token',
      desc: '',
      args: [],
    );
  }

  /// `Search symbol / name / address`
  String get g_key_dex_search_hint {
    return Intl.message(
      'Search symbol / name / address',
      name: 'g_key_dex_search_hint',
      desc: '',
      args: [],
    );
  }

  /// `No tokens`
  String get g_key_dex_no_tokens {
    return Intl.message(
      'No tokens',
      name: 'g_key_dex_no_tokens',
      desc: '',
      args: [],
    );
  }

  /// `No tokens found`
  String get g_key_dex_no_tokens_found {
    return Intl.message(
      'No tokens found',
      name: 'g_key_dex_no_tokens_found',
      desc: '',
      args: [],
    );
  }

  /// `Swap submitted successfully`
  String get g_key_dex_swap_success {
    return Intl.message(
      'Swap submitted successfully',
      name: 'g_key_dex_swap_success',
      desc: '',
      args: [],
    );
  }

  /// `Solana DEX swap not yet supported in-app`
  String get g_key_dex_sol_unsupported {
    return Intl.message(
      'Solana DEX swap not yet supported in-app',
      name: 'g_key_dex_sol_unsupported',
      desc: '',
      args: [],
    );
  }

  /// `Quote failed`
  String get g_key_dex_quote_failed {
    return Intl.message(
      'Quote failed',
      name: 'g_key_dex_quote_failed',
      desc: '',
      args: [],
    );
  }

  /// `Transaction failed`
  String get g_key_dex_tx_failed {
    return Intl.message(
      'Transaction failed',
      name: 'g_key_dex_tx_failed',
      desc: '',
      args: [],
    );
  }

  /// `Retry`
  String get g_key_dex_retry {
    return Intl.message('Retry', name: 'g_key_dex_retry', desc: '', args: []);
  }

  /// `Swap`
  String get g_key_dex_swap_btn {
    return Intl.message('Swap', name: 'g_key_dex_swap_btn', desc: '', args: []);
  }

  /// `Pending`
  String get g_key_dex_status_pending {
    return Intl.message(
      'Pending',
      name: 'g_key_dex_status_pending',
      desc: '',
      args: [],
    );
  }

  /// `Confirmed`
  String get g_key_dex_status_confirmed {
    return Intl.message(
      'Confirmed',
      name: 'g_key_dex_status_confirmed',
      desc: '',
      args: [],
    );
  }

  /// `Failed`
  String get g_key_dex_status_failed {
    return Intl.message(
      'Failed',
      name: 'g_key_dex_status_failed',
      desc: '',
      args: [],
    );
  }

  /// `Quoted`
  String get g_key_dex_status_quoted {
    return Intl.message(
      'Quoted',
      name: 'g_key_dex_status_quoted',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'de'),
      Locale.fromSubtags(languageCode: 'es', countryCode: 'ES'),
      Locale.fromSubtags(languageCode: 'fr'),
      Locale.fromSubtags(languageCode: 'id'),
      Locale.fromSubtags(languageCode: 'it'),
      Locale.fromSubtags(languageCode: 'ja'),
      Locale.fromSubtags(languageCode: 'ko'),
      Locale.fromSubtags(languageCode: 'pl'),
      Locale.fromSubtags(languageCode: 'pt'),
      Locale.fromSubtags(languageCode: 'ru'),
      Locale.fromSubtags(languageCode: 'tr'),
      Locale.fromSubtags(languageCode: 'vi'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
