;; Title: BitcoinYield - Non-Custodial Bitcoin Staking Protocol
;;
;; Summary: 
;; A trustless yield generation protocol that enables Bitcoin holders to earn 
;; passive income on their sBTC holdings through time-locked staking mechanisms
;; on the Stacks Layer 2 network, maintaining full Bitcoin sovereignty.
;;
;; Description:
;; BitcoinYield revolutionizes Bitcoin DeFi by providing a secure, non-custodial
;; staking solution for sBTC holders. Built on Stacks Layer 2, this protocol
;; combines Bitcoin's security with smart contract functionality to offer:
;;
;; - Time-weighted reward distribution based on stake duration
;; - Flexible staking periods with configurable minimum lock times
;; - Transparent reward pool management with real-time APY calculations
;; - Emergency-resistant architecture with owner-controlled parameters
;; - Gas-efficient operations optimized for the Stacks network
;;
;; Perfect for Bitcoin maximalists seeking yield without compromising on
;; self-custody principles or exposing assets to traditional DeFi risks.

;; ERROR CONSTANTS

(define-constant ERR_NOT_AUTHORIZED (err u100))
(define-constant ERR_ZERO_STAKE (err u101))
(define-constant ERR_NO_STAKE_FOUND (err u102))
(define-constant ERR_TOO_EARLY_TO_UNSTAKE (err u103))
(define-constant ERR_INVALID_REWARD_RATE (err u104))
(define-constant ERR_NOT_ENOUGH_REWARDS (err u105))

;; DATA STORAGE

;; Stake tracking per user
(define-map stakes
  { staker: principal }
  {
    amount: uint,
    staked-at: uint,
  }
)

;; Cumulative rewards claimed per user
(define-map rewards-claimed
  { staker: principal }
  { amount: uint }
)

;; PROTOCOL PARAMETERS

(define-data-var reward-rate uint u5) ;; 0.5% in basis points (5/1000)
(define-data-var reward-pool uint u0) ;; Available reward tokens
(define-data-var min-stake-period uint u1440) ;; Minimum stake period (~10 days)
(define-data-var total-staked uint u0) ;; Total sBTC staked in protocol
(define-data-var contract-owner principal tx-sender)

;; ADMINISTRATIVE FUNCTIONS

(define-read-only (get-contract-owner)
  (var-get contract-owner)
)

(define-public (set-contract-owner (new-owner principal))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (not (is-eq new-owner (var-get contract-owner))) (ok true))
    (ok (var-set contract-owner new-owner))
  )
)

(define-public (set-reward-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (< new-rate u1000) ERR_INVALID_REWARD_RATE) ;; Max 100%
    (ok (var-set reward-rate new-rate))
  )
)

(define-public (set-min-stake-period (new-period uint))
  (begin
    (asserts! (is-eq tx-sender (var-get contract-owner)) ERR_NOT_AUTHORIZED)
    (asserts! (> new-period u0) ERR_INVALID_REWARD_RATE)
    (ok (var-set min-stake-period new-period))
  )
)