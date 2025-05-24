;; Provider Verification Contract
;; Validates and manages healthcare entities

(define-map providers
  { provider-id: uint }
  {
    name: (string-ascii 100),
    license-number: (string-ascii 50),
    specialty: (string-ascii 50),
    verified: bool,
    verification-date: uint
  }
)

(define-map provider-counter uint uint)

(define-data-var next-provider-id uint u1)

;; Register a new healthcare provider
(define-public (register-provider (name (string-ascii 100)) (license-number (string-ascii 50)) (specialty (string-ascii 50)))
  (let ((provider-id (var-get next-provider-id)))
    (map-set providers
      { provider-id: provider-id }
      {
        name: name,
        license-number: license-number,
        specialty: specialty,
        verified: false,
        verification-date: u0
      }
    )
    (var-set next-provider-id (+ provider-id u1))
    (ok provider-id)
  )
)

;; Verify a provider (admin function)
(define-public (verify-provider (provider-id uint))
  (match (map-get? providers { provider-id: provider-id })
    provider-data
    (begin
      (map-set providers
        { provider-id: provider-id }
        (merge provider-data { verified: true, verification-date: block-height })
      )
      (ok true)
    )
    (err u404)
  )
)

;; Get provider information
(define-read-only (get-provider (provider-id uint))
  (map-get? providers { provider-id: provider-id })
)

;; Check if provider is verified
(define-read-only (is-provider-verified (provider-id uint))
  (match (map-get? providers { provider-id: provider-id })
    provider-data (get verified provider-data)
    false
  )
)
