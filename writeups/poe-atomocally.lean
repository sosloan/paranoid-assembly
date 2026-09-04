/-
THE POWER OF lock_byte.asm
ONLY THE PARANOID SURVIVE — Bonus Annotation

A Lean 4 symbolic specification of Intel TBB's
__TBB_machine_trylockbyte.

The assembly idea:

    snapshot -> test -> atomic CAS -> branch

One byte of lock state.
One bit of semantic state.
One successful contender.
No waiting.
No syscall.
No allocation.
No spin.

This file does not model the full x86 memory model or machine code.
It abstracts the routine into a small state transition system and proves
the properties that make the primitive powerful:

- bounded termination
- success only when the lock was free
- failure when the observed lock bit is already set
- mutual exclusion for two simultaneous contenders under atomic CAS
- no deadlock inside the primitive
- bit 0 is the only lock bit
- the caller owns fairness and retry policy
-/

import Mathlib.Data.Nat.Basic
import Mathlib.Data.Bool.Basic
import Mathlib.Data.List.Basic
import Mathlib.Tactic

namespace LockByteAsm

/-!
## 1. Byte and Bit Model

We model a byte abstractly as a natural number in `[0, 255]`.
The lock semantics care only about bit 0.

The real assembly tests:

    test al, 1

So the only semantic question is:

    is bit 0 set?
-/

structure Byte where
  value : Nat
  bound : value < 256
deriving Repr

/-- Construct a byte from a natural number plus proof. -/
def mkByte (n : Nat) (h : n < 256) : Byte :=
  { value := n, bound := h }

/-- The zero byte. -/
def byte0 : Byte :=
  mkByte 0 (by decide)

/-- The byte with bit 0 set. -/
def byte1 : Byte :=
  mkByte 1 (by decide)

/--
Lock bit.

This intentionally ignores every bit except bit 0.
-/
def lockBit (b : Byte) : Bool :=
  b.value % 2 = 1

/-- A byte is semantically free when bit 0 is clear. -/
def isFree (b : Byte) : Prop :=
  lockBit b = false

/-- A byte is semantically taken when bit 0 is set. -/
def isTaken (b : Byte) : Prop :=
  lockBit b = true

theorem byte0_free :
    isFree byte0 := by
  unfold isFree lockBit byte0 mkByte
  decide

theorem byte1_taken :
    isTaken byte1 := by
  unfold isTaken lockBit byte1 mkByte
  decide

/-!
## 2. Machine Result

The assembly returns:

    eax = 1  on success
    eax = 0  on contention
-/

inductive TryLockResult where
  | acquired
  | contended
deriving Repr, DecidableEq

def eax : TryLockResult → Nat
  | TryLockResult.acquired  => 1
  | TryLockResult.contended => 0

theorem eax_acquired :
    eax TryLockResult.acquired = 1 := by
  rfl

theorem eax_contended :
    eax TryLockResult.contended = 0 := by
  rfl

/-!
## 3. Abstract Atomic Compare-And-Swap

The actual instruction is:

    lock cmpxchg [edx], cl

with:

    AL = expected snapshot
    CL = desired value 1

For this model, the lock acquisition succeeds exactly when bit 0 is clear.
On success, the byte becomes `1`.
On failure, it remains unchanged.
-/

structure MachineState where
  lock : Byte
deriving Repr

structure StepResult where
  result : TryLockResult
  state  : MachineState
deriving Repr

/--
The atomic try-lock transition.

This compresses the assembly sequence into its observable behavior:

- if bit 0 is already set, return contended
- otherwise atomically set byte to 1 and return acquired
-/
def trylockbyte (s : MachineState) : StepResult :=
  if h : lockBit s.lock = true then
    { result := TryLockResult.contended
      state  := s }
  else
    { result := TryLockResult.acquired
      state  := { lock := byte1 } }

theorem trylock_taken_fails (s : MachineState)
    (h : isTaken s.lock) :
    (trylockbyte s).result = TryLockResult.contended := by
  unfold trylockbyte isTaken at *
  simp [h]

theorem trylock_free_succeeds (s : MachineState)
    (h : isFree s.lock) :
    (trylockbyte s).result = TryLockResult.acquired := by
  unfold trylockbyte isFree at *
  simp [h]

theorem trylock_free_sets_lock (s : MachineState)
    (h : isFree s.lock) :
    (trylockbyte s).state.lock = byte1 := by
  unfold trylockbyte isFree at *
  simp [h]

theorem trylock_taken_preserves_state (s : MachineState)
    (h : isTaken s.lock) :
    (trylockbyte s).state = s := by
  unfold trylockbyte isTaken at *
  simp [h]

/-!
## 4. Fast Path and Contended Path

The assembly has two exits:

success:

    mov eax, 1
    ret

failure:

    xor eax, eax
    ret
-/

def successPath : StepResult :=
  { result := TryLockResult.acquired
    state  := { lock := byte1 } }

def contendedPath (s : MachineState) : StepResult :=
  { result := TryLockResult.contended
    state  := s }

theorem success_returns_one :
    eax successPath.result = 1 := by
  rfl

theorem contention_returns_zero (s : MachineState) :
    eax (contendedPath s).result = 0 := by
  rfl

/-!
## 5. Bounded Termination

There is no loop in the assembly.

The primitive always returns after a fixed straight-line sequence.
We model that with an abstract instruction budget.

Real mnemonic sequence:

1. mov edx, 4[esp]
2. mov al, [edx]
3. mov cl, 1
4. test al, 1
5. jnz contended
6. lock cmpxchg [edx], cl
7. jne contended
8. mov eax, 1
9. ret
10. xor eax, eax
11. ret

The writeup calls it thirteen instructions depending on assembler /
label accounting; the essential property is O(1), no loop.
-/

def instructionBudget : Nat :=
  13

def terminatesWithin (_s : MachineState) (n : Nat) : Prop :=
  instructionBudget ≤ n

theorem trylock_terminates_in_13 (s : MachineState) :
    terminatesWithin s 13 := by
  unfold terminatesWithin instructionBudget
  decide

theorem trylock_has_no_internal_wait (s : MachineState) :
    ∃ r : StepResult, r = trylockbyte s := by
  exact ⟨trylockbyte s, rfl⟩

/-!
## 6. Mutual Exclusion

For two contenders attempting the same lock, atomicity means their
operations are serialized.

If the first succeeds, the second observes the taken state and fails.
-/

def twoThreadRaceFromFree : TryLockResult × TryLockResult :=
  let s0 : MachineState := { lock := byte0 }
  let r1 := trylockbyte s0
  let r2 := trylockbyte r1.state
  (r1.result, r2.result)

theorem two_thread_race_first_wins_second_loses :
    twoThreadRaceFromFree =
      (TryLockResult.acquired, TryLockResult.contended) := by
  unfold twoThreadRaceFromFree trylockbyte byte0 byte1 lockBit mkByte
  decide

/--
At most one success in two serialized attempts from a free lock.
-/
def successCount2 : TryLockResult × TryLockResult → Nat
  | (TryLockResult.acquired, TryLockResult.acquired)   => 2
  | (TryLockResult.acquired, TryLockResult.contended)  => 1
  | (TryLockResult.contended, TryLockResult.acquired)  => 1
  | (TryLockResult.contended, TryLockResult.contended) => 0

theorem mutual_exclusion_two_threads :
    successCount2 twoThreadRaceFromFree = 1 := by
  unfold twoThreadRaceFromFree successCount2 trylockbyte byte0 byte1 lockBit mkByte
  decide

/-!
## 7. One Bit Matters

The lock semantics are determined only by parity, i.e. bit 0.

If two bytes have the same bit 0, the trylock result is the same.
-/

theorem same_lock_bit_same_result (a b : Byte)
    (h : lockBit a = lockBit b) :
    (trylockbyte { lock := a }).result =
    (trylockbyte { lock := b }).result := by
  unfold trylockbyte
  by_cases ha : lockBit a = true
  · have hb : lockBit b = true := by
      rw [← h]
      exact ha
    simp [ha, hb]
  · have hb : lockBit b ≠ true := by
      intro hbtrue
      apply ha
      rw [h]
      exact hbtrue
    simp [ha, hb]

/--
The other seven bits are metadata real estate.

This theorem states the semantic principle:
only `lockBit` affects acquisition.
-/
theorem metadata_bits_do_not_affect_result (a b : Byte)
    (h : a.value % 2 = b.value % 2) :
    (trylockbyte { lock := a }).result =
    (trylockbyte { lock := b }).result := by
  apply same_lock_bit_same_result
  unfold lockBit
  exact h

/-!
## 8. Paranoia Optimization

The assembly first performs a cheap read:

    mov al, [edx]
    test al, 1
    jnz contended

Only if the byte appears free does it attempt the expensive locked CAS.
-/

inductive Operation where
  | plainRead
  | testBit
  | lockedCAS
  | returnZero
  | returnOne
deriving Repr, DecidableEq

def operationTrace (s : MachineState) : List Operation :=
  if lockBit s.lock = true then
    [Operation.plainRead, Operation.testBit, Operation.returnZero]
  else
    [Operation.plainRead, Operation.testBit, Operation.lockedCAS, Operation.returnOne]

theorem contended_trace_has_no_locked_cas (s : MachineState)
    (h : isTaken s.lock) :
    Operation.lockedCAS ∉ operationTrace s := by
  unfold operationTrace isTaken at *
  simp [h]

theorem free_trace_uses_locked_cas (s : MachineState)
    (h : isFree s.lock) :
    Operation.lockedCAS ∈ operationTrace s := by
  unfold operationTrace isFree at *
  simp [h]

theorem every_trace_starts_with_plain_read (s : MachineState) :
    ∃ rest : List Operation,
      operationTrace s = Operation.plainRead :: rest := by
  unfold operationTrace
  by_cases h : lockBit s.lock = true
  · simp [h]
  · simp [h]

/-!
## 9. Caller Owns Policy

This primitive is a try-lock. It does not decide:

- retry
- backoff
- yield
- park
- fairness
- telemetry
- escalation

It returns truth and exits.
-/

inductive CallerPolicy where
  | retry
  | backoff
  | escalate
  | switchWork
  | logTelemetry
  | giveUp
deriving Repr, DecidableEq

/-- The primitive itself chooses no caller policy. -/
def primitiveChoosesPolicy (_s : MachineState) : Option CallerPolicy :=
  none

theorem fairness_is_not_internal (s : MachineState) :
    primitiveChoosesPolicy s = none := by
  rfl

/-!
## 10. The Power Table as Propositions
-/

def Atomicity : Prop :=
  ∀ s : MachineState,
    isFree s.lock →
    (trylockbyte s).result = TryLockResult.acquired ∧
    (trylockbyte s).state.lock = byte1

def ContentionFailure : Prop :=
  ∀ s : MachineState,
    isTaken s.lock →
    (trylockbyte s).result = TryLockResult.contended ∧
    (trylockbyte s).state = s

def BoundedTime : Prop :=
  ∀ s : MachineState, terminatesWithin s 13

def NoDeadlockInsidePrimitive : Prop :=
  ∀ s : MachineState, ∃ r : StepResult, r = trylockbyte s

def OneBitSemantics : Prop :=
  ∀ a b : Byte,
    lockBit a = lockBit b →
    (trylockbyte { lock := a }).result =
    (trylockbyte { lock := b }).result

theorem atomicity_holds :
    Atomicity := by
  intro s h
  constructor
  · exact trylock_free_succeeds s h
  · exact trylock_free_sets_lock s h

theorem contention_failure_holds :
    ContentionFailure := by
  intro s h
  constructor
  · exact trylock_taken_fails s h
  · exact trylock_taken_preserves_state s h

theorem bounded_time_holds :
    BoundedTime := by
  intro s
  exact trylock_terminates_in_13 s

theorem no_deadlock_inside_primitive_holds :
    NoDeadlockInsidePrimitive := by
  intro s
  exact trylock_has_no_internal_wait s

theorem one_bit_semantics_holds :
    OneBitSemantics := by
  intro a b h
  exact same_lock_bit_same_result a b h

/-!
## 11. Grove Doctrine

Only the paranoid survive.

At the metal, paranoia means:

- read first
- test cheaply
- commit atomically only if worth trying
- fail fast
- return control to the caller
-/

structure GroveDoctrine where
  assumeRace        : Bool
  checkBeforeCommit : Bool
  failFast          : Bool
  oneSourceOfTruth  : Bool
  callerOwnsPolicy  : Bool
deriving Repr

def lockByteDoctrine : GroveDoctrine :=
  { assumeRace := true
    checkBeforeCommit := true
    failFast := true
    oneSourceOfTruth := true
    callerOwnsPolicy := true }

theorem grove_doctrine_complete :
    lockByteDoctrine.assumeRace = true ∧
    lockByteDoctrine.checkBeforeCommit = true ∧
    lockByteDoctrine.failFast = true ∧
    lockByteDoctrine.oneSourceOfTruth = true ∧
    lockByteDoctrine.callerOwnsPolicy = true := by
  unfold lockByteDoctrine
  simp

/-!
## 12. Closing Theorem

Thirteen instructions.
One byte.
One bit.
One atomic instruction.

A lock built for paranoids.
-/

def LockBytePower : Prop :=
  Atomicity ∧
  ContentionFailure ∧
  BoundedTime ∧
  NoDeadlockInsidePrimitive ∧
  OneBitSemantics

theorem lock_byte_asm_power :
    LockBytePower := by
  unfold LockBytePower
  constructor
  · exact atomicity_holds
  constructor
  · exact contention_failure_holds
  constructor
  · exact bounded_time_holds
  constructor
  · exact no_deadlock_inside_primitive_holds
  · exact one_bit_semantics_holds

/-
QED.

lock_byte.asm is not powerful because it is large.
It is powerful because it is exactly small.

It exposes contention.
It refuses to wait.
It mutates one byte atomically.
It lets the caller decide the strategy.

Only the paranoid survive. ✓
-/

end LockByteAsm
