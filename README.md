# N42 Wallet

A cross-platform cryptocurrency wallet application built with Flutter, featuring multi-chain support, mining capabilities, and integrated secure messaging.

## Features

### Multi-Chain Wallet
- Support for 13+ blockchain networks:
  - Bitcoin (BTC)
  - Ethereum (ETH)
  - Solana (SOL)
  - Polkadot (DOT)
  - TRON (TRX)
  - Cosmos (ATOM)
  - Filecoin (FIL)
  - Algorand (ALGO)
  - Aptos (APT)
  - Sui (SUI)
  - TON
  - XRP (Ripple)
  - Tezos (XTZ)

### Wallet Management
- Create and import wallets (mnemonic, private key, keystore)
- Send and receive transactions
- Transaction history tracking
- Address book management
- QR code generation and scanning
- Token management (add custom tokens)
- BTC Staking support

### Mining
- Mining dashboard with real-time statistics
- Mining pool configuration
- Key management with encryption
- BLS12-381 keypair generation

### Secure Messaging
- End-to-end encrypted chat (Matrix protocol)
- Direct messaging and group chats
- File sharing
- Friend requests and contact management
- Poll creation and voting
- Music sharing

### DApp Browser
- Built-in Web3 browser
- Bookmark management
- Browser history
- Search functionality

### WalletConnect
- WalletConnect v2 protocol support
- DApp connection and transaction signing
- Message signing

### Security
- Biometric authentication (fingerprint, face recognition)
- Gesture password
- Secure key storage
- Data encryption (AES-256-GCM)
- Google Authenticator backup

### Payment Integration
- MoonPay integration for fiat on/off ramp

## Tech Stack

- **Framework**: Flutter 3.9.2+
- **State Management**: Riverpod
- **Blockchain**: web3dart, bitcoin_base
- **Database**: SQLite, Secure Storage
- **Networking**: Dio
- **Authentication**: Firebase Auth, Google Sign-in, Apple Sign-in
- **Push Notifications**: Firebase Cloud Messaging

## Supported Languages

English, Spanish, Korean, Japanese, Vietnamese, Portuguese, Turkish, Russian, Indonesian, German, French, Italian, Chinese

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode

### Installation

1. Clone the repository
```bash
git clone https://gitee.com/starlink-world/n42appv2.git
cd n42appv2
```

2. Install dependencies
```bash
flutter pub get
```

3. Run the app
```bash
flutter run
```

### Build

Debug build:
```bash
flutter build apk --debug
```

Release build:
```bash
flutter build apk --release
```

## Project Structure

```
lib/
├── src/
│   ├── wallet/        # Wallet management
│   ├── miningV2/      # Mining features
│   ├── chat/          # Messaging integration
│   ├── browser/       # DApp browser
│   ├── login/         # Authentication
│   ├── home/          # Main navigation
│   ├── wallet_connect/# WalletConnect integration
│   ├── pay/           # Payment services
│   └── widgets/       # UI components
├── core/              # Core utilities
├── shared/            # Shared modules
└── generated/         # Generated code (l10n)
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

Proprietary - All rights reserved.
