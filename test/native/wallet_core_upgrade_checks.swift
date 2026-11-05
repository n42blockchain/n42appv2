// Public BIP-39 vectors and synthetic keystores. Never use funded credentials.
func verifyWalletCoreUpgrade() throws {
  let mnemonic = Array(repeating: "abandon", count: 11).joined(separator: " ") + " about"
  let wallet = try XCTUnwrap(HDWallet(mnemonic: mnemonic, passphrase: ""))
  XCTAssertEqual(wallet.getAddressForCoin(coin: .ethereum), "0x9858EfFD232B4033E47d90003D41EC34EcaEda94")
  XCTAssertEqual(wallet.getAddressForCoin(coin: .bitcoin), "bc1qcr8te4kr609gcawutmrza0j4xv80jy8z306fyu")
  let password = Data("test-only-password".utf8)
  let key = Data(repeating: 1, count: 32)
  let stored = try XCTUnwrap(StoredKey.importPrivateKey(privateKey: key, name: "test", password: password, coin: .ethereum))
  let json = try XCTUnwrap(stored.exportJSON())
  let reopened = try XCTUnwrap(StoredKey.importJSON(json: json))
  XCTAssertEqual(reopened.decryptPrivateKey(password: password), key)
  XCTAssertNil(reopened.decryptPrivateKey(password: Data("wrong-password".utf8)))
  let object = try JSONSerialization.jsonObject(with: json) as! [String: Any]
  let crypto = object["crypto"] as! [String: Any]
  XCTAssertEqual(crypto["kdf"] as? String, "scrypt")
  for length in [0, 16, 64] {
    var mutated = object
    var c = crypto
    var params = c["kdfparams"] as! [String: Any]
    params["dklen"] = length
    c["kdfparams"] = params
    mutated["crypto"] = c
    let encoded = try JSONSerialization.data(withJSONObject: mutated)
    XCTAssertNil(StoredKey.importJSON(json: encoded), "Reject unsupported scrypt dklen=\(length)")
  }
}
