;; Time-Locked Wallet
;; Users lock STX with a release block height.
;; Only owner can withdraw, only after release time.

(define-data-var lock-count uint u0)

(define-map locks
  {id: uint}
  {owner: principal, amount: uint, release: uint, withdrawn: bool}
)

;; Error Codes
;; u100 = lock not found
;; u101 = unauthorized
;; u102 = release height not reached
;; u103 = already withdrawn
;; u104 = invalid amount
;; u105 = transfer failed

;; Read-only: get number of locks created
(define-read-only (get-lock-count)
  (ok (var-get lock-count))
)

;; Read-only: get lock data
(define-read-only (get-lock (id uint))
  ;; <CHANGE> Fixed optional match syntax - map-get? returns optional, not result
  (match (map-get? locks {id: id})
    lock (ok lock)
    (err u100))
)

;; Create a new lock
(define-public (create-lock (amount uint) (release uint))
  (begin
    (asserts! (> amount u0) (err u104))

    (match (stx-transfer? amount tx-sender (as-contract tx-sender))
      result
      (let ((id (var-get lock-count)))
        (map-set locks
          {id: id}
          {
            owner: tx-sender,
            amount: amount,
            release: release,
            withdrawn: false
          }
        )
        (var-set lock-count (+ id u1))
        (ok id)
      )
      e
      (err u105)
    )
  )
)

;; Withdraw STX after lock release
(define-public (withdraw (id uint))
  (match (map-get? locks {id: id})
    lock
    (let (
      (owner (get owner lock))
      (amount (get amount lock))
      (release (get release lock))
      (withdrawn? (get withdrawn lock))
    )
      (begin
        (asserts! (is-eq tx-sender owner) (err u101))
        (asserts! (not withdrawn?) (err u103))
        (asserts! (<= release burn-block-height) (err u102))

        ;; mark withdrawn first
        (map-set locks
          {id: id}
          {
            owner: owner,
            amount: amount,
            release: release,
            withdrawn: true
          }
        )

        (match (stx-transfer? amount (as-contract tx-sender) owner)
          res
          (ok true)
          e
          (begin
            ;; revert withdrawn flag if transfer fails
            (map-set locks
              {id: id}
              {
                owner: owner,
                amount: amount,
                release: release,
                withdrawn: false
              }
            )
            (err u105)
          )
        )
      )
    )
    (err u100)
  )
)