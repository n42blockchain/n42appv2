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
