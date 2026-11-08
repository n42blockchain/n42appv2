import 'dart:convert';

/// Test-only configuration. Never use a production account with this harness.
class DisposableTransferConfig {
  static const chainId = 313371143;
  final Uri rpc;
  final String genesisHash;
  final String clientVersion;
  final String privateKey;
  final String sender;
  final String recipient;

  /// Match the existing wallet import/native signing contract.
  String get walletPrivateKey => base64Encode([
    for (var i = 0; i < privateKey.length; i += 2)
      int.parse(privateKey.substring(i, i + 2), radix: 16),
  ]);

  DisposableTransferConfig.fromJson(Map<String, dynamic> json)
    : rpc = Uri.parse(json['rpc'] is String ? json['rpc'] as String : ''),
      genesisHash = json['genesisHash'] is String
          ? json['genesisHash'] as String
          : '',
      clientVersion = json['clientVersion'] is String
          ? json['clientVersion'] as String
          : '',
      privateKey = json['privateKey'] is String
          ? json['privateKey'] as String
          : '',
      sender = json['sender'] is String ? json['sender'] as String : '',
      recipient = json['recipient'] is String
          ? json['recipient'] as String
          : '' {
    if (json['disposable'] != true ||
        json['chainId'] != chainId ||
        rpc.scheme != 'http' ||
        rpc.host != '127.0.0.1' ||
        !rpc.hasPort ||
        rpc.port < 1024 ||
        rpc.port > 65535 ||
        rpc.userInfo.isNotEmpty ||
        rpc.path.isNotEmpty && rpc.path != '/' ||
        rpc.hasQuery ||
        rpc.hasFragment ||
        !RegExp(r'^0x[0-9a-fA-F]{64}$').hasMatch(genesisHash) ||
        clientVersion.isEmpty ||
        clientVersion.length > 256 ||
        !RegExp(r'^[0-9a-fA-F]{64}$').hasMatch(privateKey) ||
        !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(sender) ||
        !RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch(recipient) ||
        sender.toLowerCase() == recipient.toLowerCase()) {
      throw const FormatException('Invalid disposable transfer configuration');
    }
  }
}
