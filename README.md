# N42 Wallet

A comprehensive cross-platform cryptocurrency wallet built with Flutter, featuring multi-chain support, DeFi integration, secure messaging, and advanced Web3 capabilities.

## Features Overview

### Multi-Chain Wallet

Support for **200+ blockchain networks**:

#### Layer 1 Blockchains

| Category | Chains |
|----------|--------|
| **Bitcoin & Forks** | BTC, BCH, BTG, DASH, DCR, DGB, DOGE, LTC, RVN, ZEN |
| **Ethereum & EVM** | ETH, ETC, N (N42) |
| **Smart Contract Platforms** | ADA, ALGO, APT, ATOM, DOT, EOS, FIL, HBAR, ICX, IOST, NEAR, NEO, ONT, SOL, SUI, TIA, TON, TRX, VET, WAVES, XEM, XLM, XRP, XTZ, ZIL |
| **Cosmos Ecosystem** | ATOM, AKT, CMDX, CRE, DYM, EVMOS, INJ, JUNO, KUJI, NTRN, OSMO, RUNE, SCRT, SEI, SOMM, STRD, XPRT |
| **Polkadot Ecosystem** | DOT, KSM, ACA, ASTR, SDN |
| **Other L1s** | EGLD, THETA, NANO, STEEM, HIVE, WAX, ARK, LSK, XYM, ELA, QTUM2 |

#### Layer 2 & Scaling Solutions

| Network | Symbol | Type |
|---------|--------|------|
| Arbitrum One | ARB | Optimistic Rollup |
| Optimism | OP | Optimistic Rollup |
| Base | BASE | Optimistic Rollup |
| zkSync Era | ZKSYNC | ZK Rollup |
| Polygon zkEVM | ZKPOLYGON | ZK Rollup |
| Linea | LINEA | ZK Rollup |
| Scroll | SCROLL | ZK Rollup |
| Starknet | STRK | ZK Rollup |
| zkLink Nova | ZKLINK | ZK Rollup |
| zkFair | ZKFAIR | ZK Rollup |
| Manta Pacific | MANTA | Modular L2 |
| Metis | METIS | Optimistic Rollup |
| Boba Network | BOBA | Optimistic Rollup |
| Mode | MODE | Optimistic Rollup |
| Blast | BLAST | Optimistic Rollup |
| Zora | ZORA | Optimistic Rollup |
| Taiko | TAIKO | Based Rollup |
| Kroma | KROMA | Optimistic Rollup |
| Frax | FRAX | Hybrid Rollup |
| opBNB | OPBNB | Optimistic Rollup |
| BOB | BOB | Hybrid L2 |
| Polynomial | POLYNOMIAL | Derivatives L2 |
| Redstone | REDSTONE | OP Stack |
| Cyber | CYBER | OP Stack |
| Mint | MINT | OP Stack |
| Lisk | LISK | OP Stack |
| World Chain | WORLD | OP Stack |
| Ink | INK | OP Stack |
| Soneium | SONEIUM | OP Stack |
| Unichain | UNICHAIN | OP Stack |
| Shape | SHAPE | OP Stack |
| Hemi | HEMI | Bitcoin L2 |
| Swan Chain | SWAN | AI L2 |
| Superposition | SUPERPOSITION | DeFi L2 |

#### EVM Compatible Chains

| Network | Symbol | Chain ID |
|---------|--------|----------|
| BNB Smart Chain | BNB | 56 |
| Polygon PoS | MATIC | 137 |
| Avalanche C-Chain | AVAX | 43114 |
| Fantom | FTM | 250 |
| Cronos | CRO | 25 |
| Gnosis Chain | GNOSIS/XDAI | 100 |
| Celo | CELO | 42220 |
| Harmony | ONE | 1666600000 |
| Moonbeam | GLMR | 1284 |
| Moonriver | MOVR | 1285 |
| Aurora | AURORA | 1313161554 |
| Klaytn | KLAY | 8217 |
| Fuse | FUSE | 122 |
| Meter | MTR | 82 |
| OKX Chain | OKT | 66 |
| Huobi ECO Chain | HT | 128 |
| KuCoin Chain | KCS | 321 |
| Gate Chain | GT | 86 |
| Conflux eSpace | CFX | 1030 |
| IoTeX | IOTX | 4689 |
| Elastos | ELA | 20 |
| Wanchain | WAN | 888 |
| Theta | THETA | 361 |
| PulseChain | PLS | 369 |
| Canto | CANTO | 7700 |
| Kava EVM | KAVA | 2222 |
| Telos EVM | TLOS | 40 |
| Neon EVM | NEON | 245022934 |
| Reef | REEF | 13939 |
| Syscoin NEVM | SYS | 57 |
| Dogechain | DOGECHAIN | 2000 |
| Flare | FLR | 14 |
| Songbird | SGB | 19 |
| Palm | PALM | 11297108109 |
| Oasis Emerald | ROSE | 42262 |
| Evmos | EVMOS | 9001 |
| Astar | ASTR | 592 |
| Shiden | SDN | 336 |
| Bittorrent Chain | BTT | 199 |
| Fusion | FSN | 32659 |
| GoChain | GO | 60 |
| POA Network | POA | 99 |
| Energy Web | EWT | 246 |
| Callisto | CLO | 820 |
| Milkomeda C1 | MILKOMEDA | 2001 |
| ThunderCore | TT | 108 |
| Viction | VIC | 88 |
| Chiliz | CHZ | 88888 |
| Ronin | RON | 2020 |
| Immutable X | IMX | 13371 |
| Core | CORE | 1116 |
| Mantle | MNT | 5000 |
| X Layer | XLAYER | 196 |
| Sei EVM | SEI | 1329 |
| Merlin | MERLIN | 4200 |
| BEVM | BEVM | 1501 |
| Bitlayer | BITLAYER | 200901 |
| BOB ETH | BOBAETH | 60808 |
| BOB BNB | BOBBNB | 60808 |
| Movement | MOVE | 30730 |
| Corn | CORN | 21000000 |
| Gravity | GRAVITY | 1625 |
| Hype | HYPE | 999 |
| Plume | PLUME | 161221135 |
| Abstract | ABSTRACT | 2741 |
| Lens Network | LENSNETWORK | 37111 |
| MegaETH | MEGAETH | 18233 |
| Monad | MON | 10000 |
| Berachain | BERA | 80094 |
| Story Protocol | IP | 1513 |
| Saakuru | SAAKURU | 7225878 |
| HashKey Chain | HSK | 177 |
| Metal L2 | METAL | 1750 |
| Goat Network | GOAT | 2345 |
| Katana | KATANA | 1868 |
| Tempo | TEMPO | 1234 |
| Strato | STRATO | 93747 |
| Zircuit | ZIRCUIT | 48900 |
| Zeta Chain | ZETA | 7000 |
| F(x) Core | FX | 530 |
| Bone | BONE | 516 |
| Bitrise | BRISE | 32520 |
| Mars | MARS | 2525 |
| Nova Network | NOVA | 87 |
| Numblock | NUM | 5025 |
| Onus Chain | ONG | 1975 |
| Velas | VIA | 106 |
| World | WLD | 480 |
| Ape Chain | APECHAIN | 33139 |
| APE | APE | 33139 |
| dYdX | DYDX | 1100 |
| EDU Chain | EDU | 41923 |
| Gas | GAS | 9797 |
| Islamic Coin | ISLM | 11235 |
| Mona | MONA | 12553 |
| BB | BB | 6001 |
| BNC | BNC | 6002 |
| S | S | 6003 |

#### Complete Chain List (200 Networks)

<details>
<summary>Click to expand full list</summary>

| # | Symbol | Network Name |
|---|--------|--------------|
| 1 | N | N42 (Native) |
| 2 | ETH | Ethereum |
| 3 | BTC | Bitcoin |
| 4 | BNB | BNB Smart Chain |
| 5 | SOL | Solana |
| 6 | MATIC | Polygon |
| 7 | ARB | Arbitrum One |
| 8 | OP | Optimism |
| 9 | AVAX | Avalanche |
| 10 | DOT | Polkadot |
| 11 | ATOM | Cosmos |
| 12 | TRX | TRON |
| 13 | TON | TON |
| 14 | XRP | Ripple |
| 15 | ADA | Cardano |
| 16 | ALGO | Algorand |
| 17 | APT | Aptos |
| 18 | SUI | Sui |
| 19 | FIL | Filecoin |
| 20 | NEAR | NEAR Protocol |
| 21 | FTM | Fantom |
| 22 | EGLD | MultiversX |
| 23 | HBAR | Hedera |
| 24 | XTZ | Tezos |
| 25 | XLM | Stellar |
| 26 | EOS | EOS |
| 27 | VET | VeChain |
| 28 | ZIL | Zilliqa |
| 29 | NEO | Neo |
| 30 | ICX | ICON |
| 31 | ONT | Ontology |
| 32 | WAVES | Waves |
| 33 | THETA | Theta |
| 34 | IOST | IOST |
| 35 | NANO | Nano |
| 36 | DOGE | Dogecoin |
| 37 | LTC | Litecoin |
| 38 | BCH | Bitcoin Cash |
| 39 | ETC | Ethereum Classic |
| 40 | DASH | Dash |
| 41 | DCR | Decred |
| 42 | DGB | DigiByte |
| 43 | ZEN | Horizen |
| 44 | RVN | Ravencoin |
| 45 | BTG | Bitcoin Gold |
| 46 | BASE | Base |
| 47 | ZKSYNC | zkSync Era |
| 48 | LINEA | Linea |
| 49 | SCROLL | Scroll |
| 50 | MANTA | Manta Pacific |
| 51 | BLAST | Blast |
| 52 | MODE | Mode |
| 53 | ZORA | Zora |
| 54 | TAIKO | Taiko |
| 55 | KROMA | Kroma |
| 56 | METIS | Metis |
| 57 | BOBA | Boba Network |
| 58 | ZKPOLYGON | Polygon zkEVM |
| 59 | ZKLINK | zkLink Nova |
| 60 | ZKFAIR | zkFair |
| 61 | STRK | Starknet |
| 62 | OPBNB | opBNB |
| 63 | CRO | Cronos |
| 64 | GNOSIS | Gnosis Chain |
| 65 | XDAI | xDai |
| 66 | CELO | Celo |
| 67 | ONE | Harmony |
| 68 | GLMR | Moonbeam |
| 69 | MOVR | Moonriver |
| 70 | AURORA | Aurora |
| 71 | KLAY | Klaytn |
| 72 | FUSE | Fuse |
| 73 | MTR | Meter |
| 74 | OKT | OKX Chain |
| 75 | HT | Huobi ECO |
| 76 | KCS | KuCoin Chain |
| 77 | GT | Gate Chain |
| 78 | CFX | Conflux |
| 79 | IOTX | IoTeX |
| 80 | ELA | Elastos |
| 81 | WAN | Wanchain |
| 82 | PLS | PulseChain |
| 83 | CANTO | Canto |
| 84 | KAVA | Kava EVM |
| 85 | KAVA2 | Kava Cosmos |
| 86 | TLOS | Telos |
| 87 | NEON | Neon EVM |
| 88 | REEF | Reef |
| 89 | SYS | Syscoin |
| 90 | DOGECHAIN | Dogechain |
| 91 | FLR | Flare |
| 92 | SGB | Songbird |
| 93 | PALM | Palm |
| 94 | ROSE | Oasis |
| 95 | EVMOS | Evmos |
| 96 | ASTR | Astar |
| 97 | SDN | Shiden |
| 98 | BTT | BitTorrent |
| 99 | FSN | Fusion |
| 100 | GO | GoChain |
| 101 | POA | POA Network |
| 102 | EWT | Energy Web |
| 103 | CLO | Callisto |
| 104 | MILKOMEDA | Milkomeda |
| 105 | TT | ThunderCore |
| 106 | VIC | Viction |
| 107 | CHZ | Chiliz |
| 108 | RON | Ronin |
| 109 | IMX | Immutable X |
| 110 | CORE | Core |
| 111 | MNT | Mantle |
| 112 | XLAYER | X Layer |
| 113 | SEI | Sei |
| 114 | MERLIN | Merlin |
| 115 | BEVM | BEVM |
| 116 | BITLAYER | Bitlayer |
| 117 | BOB | BOB |
| 118 | BOBAETH | BOB ETH |
| 119 | BOBBNB | BOB BNB |
| 120 | MOVE | Movement |
| 121 | CORN | Corn |
| 122 | GRAVITY | Gravity |
| 123 | HYPE | Hype |
| 124 | PLUME | Plume |
| 125 | ABSTRACT | Abstract |
| 126 | LENSNETWORK | Lens Network |
| 127 | MEGAETH | MegaETH |
| 128 | MON | Monad |
| 129 | BERA | Berachain |
| 130 | IP | Story Protocol |
| 131 | SAAKURU | Saakuru |
| 132 | HSK | HashKey |
| 133 | METAL | Metal L2 |
| 134 | GOAT | Goat Network |
| 135 | KATANA | Katana |
| 136 | TEMPO | Tempo |
| 137 | STRATO | Strato |
| 138 | ZIRCUIT | Zircuit |
| 139 | ZETA | Zeta Chain |
| 140 | FX | F(x) Core |
| 141 | BONE | Bone |
| 142 | BRISE | Bitrise |
| 143 | MARS | Mars |
| 144 | NOVA | Nova |
| 145 | NUM | Numblock |
| 146 | ONG | Onus |
| 147 | VIA | Velas |
| 148 | WLD | Worldcoin |
| 149 | WORLD | World Chain |
| 150 | FRAX | Fraxtal |
| 151 | CYBER | Cyber |
| 152 | MINT | Mint |
| 153 | LISK | Lisk |
| 154 | INK | Ink |
| 155 | INK2 | Ink v2 |
| 156 | SONEIUM | Soneium |
| 157 | UNICHAIN | Unichain |
| 158 | SHAPE | Shape |
| 159 | HEMI | Hemi |
| 160 | SWAN | Swan Chain |
| 161 | SUPERPOSITION | Superposition |
| 162 | POLYNOMIAL | Polynomial |
| 163 | REDSTONE | Redstone |
| 164 | AKT | Akash |
| 165 | CMDX | Comdex |
| 166 | CRE | Crescent |
| 167 | DYM | Dymension |
| 168 | INJ | Injective |
| 169 | JUNO | Juno |
| 170 | KUJI | Kujira |
| 171 | NTRN | Neutron |
| 172 | OSMO | Osmosis |
| 173 | RUNE | THORChain |
| 174 | SCRT | Secret |
| 175 | SOMM | Sommelier |
| 176 | STRD | Stride |
| 177 | XPRT | Persistence |
| 178 | TIA | Celestia |
| 179 | ACA | Acala |
| 180 | KSM | Kusama |
| 181 | LSK | Lisk |
| 182 | ARK | Ark |
| 183 | XYM | Symbol |
| 184 | XEM | NEM |
| 185 | STEEM | Steem |
| 186 | HIVE | Hive |
| 187 | WAX | WAX |
| 188 | QTUM2 | Qtum |
| 189 | APECHAIN | Ape Chain |
| 190 | APE | ApeCoin |
| 191 | DYDX | dYdX |
| 192 | EDU | EDU Chain |
| 193 | GAS | Gas DAO |
| 194 | ISLM | Islamic Coin |
| 195 | MONA | Mona |
| 196 | BB | BounceBit |
| 197 | BNC | Bifrost |
| 198 | S | Sonic |
| 199 | DFI | DeFiChain |
| 200 | RBTC | RSK |

</details>

#### Test Networks (46 Chains)

The following chains support testnet for development and testing:

| Category | Testnets |
|----------|----------|
| **EVM L1** | ETH (Sepolia/Goerli), BNB (Testnet), AVAX (Fuji), FTM (Testnet), MATIC (Mumbai) |
| **EVM L2** | OP (Sepolia), ARB (Sepolia), BASE (Sepolia), METIS (Sepolia), BOBA (Testnet) |
| **N42** | N (N42 Testnet) |
| **Smart Contracts** | SOL (Devnet), TRX (Shasta/Nile), EOS (Jungle), NEO (Testnet), NEAR (Testnet) |
| **Cosmos** | ATOM (Testnet), STRK (Sepolia) |
| **Other** | ADA (Preview), XLM (Testnet), XRP (Testnet), DOT (Westend), ZIL (Testnet) |

<details>
<summary>Full Testnet Support List (46 Networks)</summary>

| # | Symbol | Mainnet | Testnet |
|---|--------|---------|---------|
| 1 | N | N42 Mainnet | N42 Testnet |
| 2 | ETH | Ethereum | Sepolia/Goerli |
| 3 | BNB | BNB Smart Chain | BSC Testnet |
| 4 | MATIC | Polygon | Mumbai |
| 5 | AVAX | Avalanche | Fuji |
| 6 | FTM | Fantom | Fantom Testnet |
| 7 | OP | Optimism | OP Sepolia |
| 8 | SOL | Solana | Devnet |
| 9 | TRX | TRON | Shasta/Nile |
| 10 | NEAR | NEAR | Testnet |
| 11 | STRK | Starknet | Sepolia |
| 12 | CELO | Celo | Alfajores |
| 13 | ONE | Harmony | Testnet |
| 14 | GLMR | Moonbeam | Moonbase Alpha |
| 15 | KLAY | Klaytn | Baobab |
| 16 | OKT | OKX Chain | Testnet |
| 17 | HT | Huobi ECO | Testnet |
| 18 | KCS | KuCoin | Testnet |
| 19 | METIS | Metis | Sepolia |
| 20 | BOBA | Boba | Testnet |
| 21 | ETC | Ethereum Classic | Mordor |
| 22 | THETA | Theta | Testnet |
| 23 | MTR | Meter | Testnet |
| 24 | IOTX | IoTeX | Testnet |
| 25 | WAN | Wanchain | Testnet |
| 26 | GO | GoChain | Testnet |
| 27 | TT | ThunderCore | Testnet |
| 28 | ADA | Cardano | Preview |
| 29 | XLM | Stellar | Testnet |
| 30 | XEM | NEM | Testnet |
| 31 | XYM | Symbol | Testnet |
| 32 | NEO | Neo | Testnet |
| 33 | EOS | EOS | Jungle |
| 34 | VET | VeChain | Testnet |
| 35 | ZIL | Zilliqa | Testnet |
| 36 | WAVES | Waves | Testnet |
| 37 | ICX | ICON | Testnet |
| 38 | IOST | IOST | Testnet |
| 39 | ONT | Ontology | Testnet |
| 40 | LSK | Lisk | Testnet |
| 41 | ARK | Ark | Devnet |
| 42 | DCR | Decred | Testnet |
| 43 | EGLD | MultiversX | Devnet |
| 44 | QTUM2 | Qtum | Testnet |
| 45 | ONG | Onus | Testnet |
| 46 | GAS | Gas | Testnet |

</details>

### Wallet Management
- **Create Wallet**: Generate new HD wallet with BIP-39 mnemonic
- **Import Wallet**: Mnemonic phrase, private key, or keystore file
- **Multi-Account**: Manage multiple accounts per wallet
- **Address Book**: Save and manage recipient addresses
- **Transaction History**: Full history with status tracking
- **QR Code**: Generate and scan payment QR codes
- **Token Management**: Add custom ERC-20/BEP-20/SPL tokens

### ENS Support (Ethereum Name Service)
- **Forward Resolution**: Resolve .eth, .n42, .xyz names to addresses
- **Reverse Resolution**: Display ENS name for addresses
- **N42 Priority**: N42 Name Service (.n42) takes precedence
- **Multi-Chain**: Works across all EVM-compatible chains
- **Avatar Support**: Display ENS profile avatars
- **Text Records**: Access social links (Twitter, GitHub, etc.)
- **Name Registration**: Register new ENS names with multi-year options
- **Name Management**: Update records, set primary name, transfer ownership
- **Renewal**: Extend registration period for owned names
- **Address Input**: Smart address field with ENS auto-resolution

### Account Abstraction (ERC-4337)

Smart Account features powered by ERC-4337:

#### Smart Accounts
| Account Type | Description |
|--------------|-------------|
| **Simple Account** | Basic smart account with single owner - recommended for most users |
| **EIP-7702 Account** | Hybrid EOA/Smart Account - No deployment needed |
| **Safe Account** | Multi-signature account with advanced security features |
| **Kernel Account** | Modular account with plugin support from ZeroDev |

#### Core Features
- **Gasless Transactions**: Pay gas fees in any ERC-20 token or get sponsored
- **Batch Operations**: Execute multiple transactions in a single call
- **Session Keys**: Delegate limited permissions to DApps with time constraints
- **Counterfactual Deployment**: Use your smart account before deployment

#### Session Key Management
- **Permission Control**: Grant transfer, approve, contract call, or full access
- **Spending Limits**: Set maximum spending amount per session
- **Time Constraints**: Configure expiration dates for sessions
- **DApp Authorization**: Track and revoke DApp permissions
- **Usage Monitoring**: View transaction count and spending progress

#### Paymaster Integration
| Type | Description |
|------|-------------|
| **Sponsored** | Gas fees paid by DApp or protocol |
| **ERC-20 Gas** | Pay gas in USDC, USDT, or other tokens |
| **Self-Pay** | Standard ETH gas payment |

#### Supported Networks
- Ethereum Mainnet & Sepolia
- Polygon, Arbitrum, Optimism, Base
- All EVM-compatible L2s with Bundler support

### NFT Management
- **Multi-Standard**: ERC-721, ERC-1155, SPL NFTs
- **Gallery View**: Visual display of NFT collections
- **Transfer**: Send NFTs to other addresses
- **Burn**: Permanently destroy unwanted NFTs
- **Metadata**: View NFT attributes and properties

### DeFi Features

#### Swap
- **DEX Aggregation**: Best rates across multiple DEXs
- **Cross-Chain Swaps**: Swap tokens across different networks
- **Slippage Control**: Configurable slippage tolerance
- **Price Impact**: Real-time price impact warnings

#### Cross-Chain Bridge
- **LI.FI Integration**: Access 15+ bridge protocols
- **Supported Routes**: ETH, BSC, Polygon, Arbitrum, Optimism, Avalanche
- **Bridge History**: Track all bridge transactions
- **Gas Estimation**: Accurate cross-chain gas fees

#### Multi-Chain Staking
| Protocol | Chain | Est. APY |
|----------|-------|----------|
| Lido | ETH | ~4% |
| Native | SOL | ~7% |
| Native | ATOM | ~15% |
| Native | DOT | ~12% |
| BTC Staking | BTC | Variable |

#### Gas Tracker
- **Real-Time Prices**: Live gas prices for major networks
- **Network Status**: Idle/Normal/Busy indicators
- **Auto-Refresh**: Updates every 15 seconds
- **EIP-1559**: Base fee and priority fee breakdown
- **Gas Presets**: Slow/Standard/Fast options

#### Batch Transfer
- **Multicall3**: Send to multiple addresses in one transaction
- **CSV Import**: Import recipient lists from CSV files
- **Gas Savings**: Up to 40% gas savings vs individual transfers
- **EVM Chains**: Supported on all EVM-compatible networks

### Earn Features
- **Staking Dashboard**: View all staking positions
- **Yield Aggregation**: Compare yields across protocols
- **Claim Rewards**: One-click reward claiming
- **Portfolio Tracking**: Total staked value and earnings

### Airdrop Tracker
- **Eligibility Check**: Check wallet eligibility for airdrops
- **Claim Alerts**: Notifications for claimable airdrops
- **History**: Track all claimed airdrops
- **Multi-Wallet**: Check eligibility across wallets

### Loyalty & Rewards
- **Points System**: Earn points for wallet activities
- **Daily Login**: +10 points per day
- **Transactions**: +50 points per transaction
- **Referrals**: +100 points per friend invited
- **Rewards Store**: Redeem points for rewards

### Hardware Wallet Support
- **Ledger**: Bluetooth connection via `ledger_flutter_plus`
- **Account Import**: Import hardware wallet accounts
- **Secure Signing**: Sign transactions on device
- **Multi-Account**: Manage multiple hardware accounts

### Mining (N42)
- **Mining Dashboard**: Real-time mining statistics
- **Pool Configuration**: Connect to mining pools
- **Key Management**: BLS12-381 keypair generation
- **Encrypted Storage**: Secure key encryption

### Secure Messaging (Chat)
- **End-to-End Encryption**: Matrix protocol integration
- **Direct Messages**: 1-on-1 encrypted conversations
- **Group Chats**: Create and manage group conversations
- **File Sharing**: Send images, documents, audio
- **Friend Requests**: Social contact management
- **Polls**: Create polls and voting
- **Music Sharing**: Share audio content
- **Read Receipts**: Message delivery status
- **Notifications**: Push notifications for messages

### DApp Browser
- **Web3 Injection**: Full Web3 provider support
- **WalletConnect v2**: Connect to any WalletConnect dApp
- **Bookmarks**: Save favorite dApps
- **History**: Browse history management
- **Search**: Built-in search functionality
- **Multi-Chain**: Switch networks within browser

### WalletConnect
- **Protocol v2**: Latest WalletConnect specification
- **Session Management**: Manage connected dApps
- **Transaction Signing**: Approve/reject transactions
- **Message Signing**: Personal sign, typed data (EIP-712)
- **Chain Switching**: Handle network switch requests

### Security

#### Authentication
- **Biometric**: Fingerprint and Face ID/Face Recognition
- **Gesture Password**: Pattern-based authentication
- **PIN Code**: Numeric PIN protection
- **2FA**: Google Authenticator integration

#### Data Protection
- **Encryption**: AES-256-GCM for all sensitive data
- **Secure Storage**: Platform keychain/keystore
- **Memory Protection**: Secure memory handling
- **Key Derivation**: BIP-32/44 HD key derivation

#### Additional Security
- **Self-Transfer Prevention**: Block transfers to same address
- **Address Validation**: EIP-55 checksum verification
- **Phishing Protection**: Domain verification warnings
- **Transaction Preview**: Detailed transaction breakdown

### Payment Integration
- **MoonPay**: Buy crypto with credit/debit cards
- **Fiat On-Ramp**: Support for 100+ fiat currencies
- **Fiat Off-Ramp**: Sell crypto to bank account

## Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.9.2+ |
| Language | Dart 3.0+ |
| State Management | Riverpod, Provider |
| Blockchain | web3dart, bitcoin_base, solana |
| Database | SQLite (drift), Secure Storage |
| Networking | Dio, http |
| Authentication | Firebase Auth, Google, Apple |
| Push Notifications | Firebase Cloud Messaging |
| Encryption | PointyCastle, cryptography |
| WalletConnect | walletconnect_flutter_v2 |

## Supported Languages

| Language | Code |
|----------|------|
| English | en |
| Spanish | es_ES |
| Korean | ko |
| Japanese | ja |
| Vietnamese | vi |
| Portuguese | pt |
| Turkish | tr |
| Russian | ru |
| Indonesian | id |
| German | de |
| French | fr |
| Italian | it |
| Polish | pl |

## Getting Started

### Prerequisites
- Flutter SDK 3.9.2 or higher
- Dart SDK 3.0 or higher
- Android Studio / Xcode
- iOS 17.0+ / Android 7.0+

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

3. Generate localization files
```bash
flutter pub run intl_utils:generate
```

4. Run the app
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

iOS build:
```bash
flutter build ios --release
```

## Project Structure

```
lib/
├── src/
│   ├── wallet/           # Wallet management, transfers, tokens
│   │   ├── aa/           # Account Abstraction (ERC-4337)
│   │   │   ├── models/   # SmartAccount, UserOperation
│   │   │   ├── bundler/  # Bundler client
│   │   │   ├── paymaster/# Paymaster integration
│   │   │   └── utils/    # AA utilities
│   │   ├── api/          # Blockchain APIs
│   │   ├── models/       # Data models
│   │   ├── pages/        # Wallet UI pages
│   │   │   ├── aa/       # Smart Account pages
│   │   │   └── ens/      # ENS management pages
│   │   ├── provider/     # State management
│   │   ├── services/     # ENS, validation services
│   │   ├── utils/        # Utilities
│   │   └── widgets/      # Reusable widgets
│   ├── bridge/           # Cross-chain bridge (LI.FI)
│   ├── staking/          # Multi-chain staking
│   ├── earn/             # Yield aggregation
│   ├── airdrop/          # Airdrop tracker
│   ├── loyalty/          # Points & rewards
│   ├── hardware_wallet/  # Ledger integration
│   ├── miningV2/         # N42 mining
│   ├── chat/             # Secure messaging
│   ├── browser/          # DApp browser
│   ├── wallet_connect/   # WalletConnect v2
│   ├── pay/              # MoonPay integration
│   ├── login/            # Authentication
│   ├── home/             # Main navigation
│   ├── profile/          # User profile
│   ├── notification/     # Push notifications
│   └── widgets/          # Shared UI components
├── core/
│   ├── config/           # App configuration
│   ├── network/          # HTTP client
│   ├── security/         # Encryption, secure storage
│   ├── storage/          # Database, preferences
│   ├── providers/        # Global state
│   ├── router/           # Navigation
│   └── utils/            # Core utilities
├── features/             # Feature modules (Clean Architecture)
├── shared/               # Cross-feature shared code
├── presentation/         # Themes, UI adaptation
└── generated/            # Generated code (l10n, protobuf)
```

## API Endpoints

The app connects to the following backend services:

| Service | Purpose |
|---------|---------|
| N42 API | Wallet operations, ENS, transactions |
| LI.FI API | Cross-chain bridge quotes and routes |
| CoinGecko | Token prices and market data |
| MoonPay | Fiat on/off ramp |

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow Dart style guide
- Use meaningful variable and function names
- Add comments for complex logic
- Write unit tests for new features

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 2.1.0 | 2026-01 | Account Abstraction (ERC-4337), Session Keys, ENS Registration |
| 2.0.0 | 2026-01 | ENS support, Gas tracker, Batch transfer, Bridge, 200+ chains |
| 1.5.0 | 2025-12 | Multi-chain staking, Hardware wallet |
| 1.0.0 | 2025-06 | Initial release |

## License

Copyright 2021-2026 N42 Inc. All rights reserved.

This software is licensed under a dual license:
- Apache License 2.0
- MIT License

See LICENSE file for full license information.

## Support

- Issues: [GitHub Issues](https://github.com/n42/n42appv2/issues)
- Documentation: [docs.n42.io](https://docs.n42.io)
- Community: [Discord](https://discord.gg/n42)
