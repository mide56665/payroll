(define-constant ERR_UNAUTHORIZED u100)
(define-constant ERR_INVALID_TIME u101)
(define-constant ERR_INVALID_AMOUNT u102)
(define-constant ERR_NOT_ACTIVE u200)
(define-constant ERR_NOTHING_TO_CLAIM u201)
(define-constant ERR_EMPLOYEE_NOT_FOUND u202)

;; The employer who can manage employees
(define-data-var employer principal tx-sender)

;; Each employee's vesting schedule
(define-map employees
  { employee: principal }
  {
    start-time: uint,          ;; vesting start time
    end-time: uint,            ;; vesting end time
    total-amount: uint,        ;; total amount to vest
    claimed-amount: uint,      ;; amount already claimed
    is-active: bool            ;; active status
  }
)

;; Add a new employee with a vesting schedule
(define-public (add-employee (employee principal) (start-time uint) (end-time uint) (total-amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get employer)) (err ERR_UNAUTHORIZED))
    (asserts! (> end-time start-time) (err ERR_INVALID_TIME))
    (asserts! (> total-amount u0) (err ERR_INVALID_AMOUNT))
    (asserts! (is-eq employee employee) (err ERR_INVALID_AMOUNT))

    (map-set employees
      {employee: employee}
      {
        start-time: start-time,
        end-time: end-time,
        total-amount: total-amount,
        claimed-amount: u0,
        is-active: true
      }
    )
    (ok true)
  )
)

;; Claim vested payment
(define-public (claim)
  (let ((maybe-emp (map-get? employees {employee: tx-sender})))
    (match maybe-emp emp
      (begin
        (asserts! (get is-active emp) (err ERR_NOT_ACTIVE))

        (let
          (
            (now (stx-get-balance tx-sender))
            (start (get start-time emp))
            (end (get end-time emp))
            (total (get total-amount emp))
            (claimed (get claimed-amount emp))

            ;; calculate elapsed time within the vesting window
            (elapsed (if (> now end) (- end start) (if (< now start) u0 (- now start))))
            (duration (- end start))
            (vested (/ (* total elapsed) duration))
            (claimable (if (> vested claimed) (- vested claimed) u0))
          )
          (begin
            (asserts! (> claimable u0) (err ERR_NOTHING_TO_CLAIM))

            ;; update claimed amount
            (map-set employees
              {employee: tx-sender}
              (merge emp {claimed-amount: (+ claimed claimable)})
            )

            ;; transfer STX to employee
            (as-contract (stx-transfer? claimable (var-get employer) tx-sender))
          )
        )
      )
      (err ERR_EMPLOYEE_NOT_FOUND)
    )
  )
)

;; Employer deactivates an employee (e.g., fired/left)
(define-public (deactivate-employee (employee principal))
  (begin
    (asserts! (is-eq tx-sender (var-get employer)) (err ERR_UNAUTHORIZED))
    (asserts! (is-eq employee employee) (err ERR_INVALID_AMOUNT))

    (let ((maybe-emp (map-get? employees {employee: employee})))
      (match maybe-emp emp
        (begin
          (map-set employees
            {employee: employee}
            (merge emp {is-active: false})
          )
          (ok true)
        )
        (err ERR_EMPLOYEE_NOT_FOUND)
      )
    )
  )
)

;; Grant a one-time bonus to an employee
(define-public (grant-bonus (employee principal) (amount uint))
  (begin
    (asserts! (is-eq tx-sender (var-get employer)) (err ERR_UNAUTHORIZED))
    (asserts! (> amount u0) (err ERR_INVALID_AMOUNT))
    (asserts! (is-eq employee employee) (err ERR_INVALID_AMOUNT))
    (as-contract (stx-transfer? amount (var-get employer) employee))
  )
)
