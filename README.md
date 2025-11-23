# Time-Locked Wallet Smart Contract

This Clarity smart contract allows users to lock STX tokens until a specified block height. Only the lock creator can withdraw the tokens, and only after the release block is reached.

## Features

- **Lock STX:** Users can lock any amount of STX with a chosen release block height.
- **Withdraw:** Only the lock owner can withdraw the locked STX after the release block.
- **Error Handling:** Returns clear error codes for invalid actions.

## Error Codes

| Code  | Meaning                       |
|-------|-------------------------------|
| u100  | Lock not found                |
| u101  | Unauthorized                  |
| u102  | Release height not reached    |
| u103  | Already withdrawn             |
| u104  | Invalid amount                |
| u105  | Transfer failed               |

## Contract Functions

### Public Functions

- `create-lock(amount, release)`
  - Locks `amount` STX until `release` block height.
  - Returns the lock ID.

- `withdraw(id)`
  - Withdraws STX from lock with `id` if release block is reached and caller is owner.

### Read-Only Functions

- `get-lock-count()`
  - Returns the total number of locks created.

- `get-lock(id)`
  - Returns details of the lock with `id`.

## Usage Example

```clarity
;; Lock 100 STX until block 5000
(create-lock u100 u5000)

;; Withdraw after block 5000
(withdraw u0)
```

## Development

- Written in [Clarity](https://docs.stacks.co/docs/clarity-language/overview).
- Compatible with [Clarinet](https://github.com/hirosystems/clarinet) for local testing.

