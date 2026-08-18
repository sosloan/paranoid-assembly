# Catalog of Analyses

This file tracks completed writeups and pending candidates for *paranoid-assembly*.

---

## ✓ COMPLETE

### 1. LOCK_BYTE_POWER.md
**Routine:** `__TBB_machine_trylockbyte` (Intel TBB)
**Focus:** Try-lock primitive, 13 instructions, 1 byte of state
**Theme:** Paranoid optimization under contention
**Status:** Complete
**Link:** [writeups/LOCK_BYTE_POWER.md](writeups/LOCK_BYTE_POWER.md)

---

## 📋 CANDIDATES (Pending)

The following are strong candidates for future writeups:

### TBB Synchronization Primitives
- `__TBB_machine_compare_and_swap` — CAS on various architectures
- `__TBB_machine_acquire_load` / `release_store` — memory ordering
- `__TBB_machine_pause` — pause hint / PAUSE instruction
- Queuing mutex — multi-instruction acquire/release dance

### x86 Atomic Operations
- `xchg` — exchange (implicit LOCK prefix)
- `cmpxchg8b` — 64-bit CAS on 32-bit x86
- Memory barriers — `mfence`, `sfence`, `lfence`

### Work-Stealing & Scheduling
- Task deque push/pop — TBB's work-stealing core
- Affinity binding — CPU topology and thread placement
- Context switching — OS/scheduler interaction

### Historical/Canonical Primitives
- Spin loops — PAUSE-based spinning in TBB
- Reader-writer locks — classical RW lock implementation
- Ticket locks — fairness via sequencing

---

## 🔄 IN PROGRESS

(None at present — but this section will track writeups under active development.)

---

## How to Contribute

1. Identify a candidate routine (see **CANDIDATES** above, or propose a new one).
2. Fork this repo and create a branch: `writeup/[routine-name]`.
3. Use **TEMPLATE.md** as your scaffold.
4. Write the analysis with the same rigor and reverence as **LOCK_BYTE_POWER.md**.
5. Open a PR.

See **CONTRIBUTING.md** for full guidelines.
