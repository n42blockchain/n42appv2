/// Information extracted from a keystore file.
class KeystoreInfo {
  final String address;
  final String privateKey;

  const KeystoreInfo({required this.address, required this.privateKey});

  bool get isEmpty => address.isEmpty && privateKey.isEmpty;

  const KeystoreInfo.empty() : address = '', privateKey = '';
}
