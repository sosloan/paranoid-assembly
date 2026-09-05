# Catalog of Analyses

This file tracks completed writeups and pending candidates for *paranoid-assembly*.

---

## ✓ COMPLETE

### ADA_TYPES_POWER.md
**Routine:** `ada-types.txt` (Ada 95 language overview)
**Focus:** Type constraints, abstraction boundaries, protected concurrency, and explicit low-level control
**Theme:** Strategic paranoia encoded before code reaches silicon
**Status:** Complete
**Link:** [writeups/ADA_TYPES_POWER.md](writeups/ADA_TYPES_POWER.md)

---

### BFGOODRICH_POWER.md
**Routine:** `BFGoodrich.txt` (IMD-HUMS architecture case study)
**Focus:** Safety-critical telemetry software, deterministic concurrency, certification-driven design
**Theme:** “Data change, not software” as paranoid systems doctrine
**Status:** Complete
**Link:** [writeups/ASTROPHYSICS_POWER.md](writeups/ASTROPHYSICS_POWER.md)

---

### CLUSTER_BALANCE_SHEET_POWER.md
**Routine:** `cluster_balance_sheet.asm` (65-node cluster accounting primitive)
**Focus:** Atomic balance commits, quorum mathematics, reconciliation sweep — 520 bytes of state for 65 servers
**Theme:** Distributed accounting at memory speed; paranoid gate on every entry point
**Status:** Complete
**Link:** [writeups/CLUSTER_BALANCE_SHEET_POWER.md](writeups/CLUSTER_BALANCE_SHEET_POWER.md)

---

### LOCK_BYTE_POWER.md
**Routine:** `__TBB_machine_trylockbyte` (Intel TBB)
**Focus:** Try-lock primitive, 13 instructions, 1 byte of state
**Theme:** Paranoid optimization under contention
**Status:** Complete
**Link:** [writeups/LOCK_BYTE_POWER.md](writeups/LOCK_BYTE_POWER.md)

---

### 3. FORTY_NINERS_TRAVEL_POWER.md
**Routine:** `forty_niners_schedule.fpp` (San Francisco 49ers 2026 season travel model)
**Focus:** Typed weekly travel legs, international venue semantics, explicit bye-week state
**Theme:** Mission-grade schedule specification for an NFL season
**Status:** Complete
**Link:** [writeups/FORTY_NINERS_TRAVEL_POWER.md](writeups/FORTY_NINERS_TRAVEL_POWER.md)

---

### TRI_ADA_93_OUTLINE_POWER.md
**Routine:** `TRI-Ada-93-outline.txt` (TRI-Ada '93 Ada 9X OOP tutorial outline)
**Focus:** Tagged-type hierarchies, dispatching model, and reuse-first programming techniques under strong typing
**Theme:** Paranoid language design as upstream infrastructure for safe reusable systems
**Status:** Complete
**Link:** [writeups/TRI_ADA_93_OUTLINE_POWER.md](writeups/TRI_ADA_93_OUTLINE_POWER.md)

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
