# N42 Loyalty Points Contract

`N42LoyaltyPoints` is a non-transferable points ledger for N42 chain. It is
not an ERC-20 token and intentionally has no transfer, approval, mint, or
allowance interface.

The official relayer is registered as an operator and pays transaction gas.
The app authenticates to the loyalty API; the API verifies that the account
owns the submitted wallet before it calls the contract. Never expose the
relayer private key to the app or accept an unverified wallet address.

## Contract behavior

- One daily check-in per address per UTC day, with a default award of 10 points.
- The tasks API reads the current daily amount from the contract, so clients do
  not rely on a hard-coded award value.
- Operator-awarded tasks and referrals with replay-protected request IDs.
- Operator-controlled redemption through `spendFor`.
- Contract events support independent audit and reconciliation; the relayer
  records confirmed operations for API history and leaderboard queries.
- Owner and relayer/operator roles are separate and rotatable.
- The owner can pause all point mutations without disabling read access.

## Verify

```sh
cd contracts/loyalty
forge test
```

## Deploy

Deploy to testnet first (chain ID `1142`), register the relayer address as the
initial operator, verify the contract, then set `LOYALTY_CONTRACT_ADDRESS` on
the API. Mainnet chain ID is `94`.

```sh
forge create src/N42LoyaltyPoints.sol:N42LoyaltyPoints \
  --rpc-url "$N42_RPC_URL" \
  --private-key "$DEPLOYER_PRIVATE_KEY" \
  --constructor-args "$RELAYER_ADDRESS"
```

Secrets belong in the deployment environment only and must not be committed.
