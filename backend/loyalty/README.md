# N42 Loyalty Relayer

This service restores the main-app points feature on the non-transferable
`N42LoyaltyPoints` contract. The relayer pays N42 gas; clients never receive
the relayer key and cannot choose award amounts.

## Trust boundary

1. App calls the public API with its existing `UUID` and `Token` headers.
2. The service calls `AUTH_VERIFY_URL` and reads the wallet bound to that user.
3. The submitted wallet must match the verified wallet.
4. The relayer sends the contract transaction and waits for a successful receipt.
5. PostgreSQL indexes confirmed history and leaderboard data; account balances
   are refreshed from the contract.

Task and referral awards are service-to-service operations protected by
`X-Internal-Token`. Public clients cannot call them. Rotate the relayer and
internal tokens through the deployment secret manager.

## Routes

- `GET /loyalty/v1/account`
- `GET /loyalty/v1/tasks`
- `GET /loyalty/v1/rewards`
- `GET /loyalty/v1/history`
- `GET /loyalty/v1/referral/list`
- `GET /loyalty/v1/leaderboard`
- `POST /loyalty/v1/check-in`
- `POST /loyalty/v1/internal/award-task`
- `POST /loyalty/v1/internal/referral`

Deploy the contract first, fund only the relayer address with N42 gas, and set
the environment values from `.env.example`. `RELAYER_PRIVATE_KEY`, database
credentials, and tokens must never be committed or passed to the Flutter app.
