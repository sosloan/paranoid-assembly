# Catalog of Analyses

This file tracks completed writeups and pending candidates for *paranoid-assembly*.

---

## ✓ COMPLETE

### CIRCUITS_POWER.md
**Routine:** `circuits.txt` (AdaIC flyer on Dolphin Integration GDS compiler)
**Focus:** Parametric generator compiler pipeline, language-level safety, modular VLSI infrastructure
**Theme:** Grove-style paranoia before tape-out: software flaws must not become silicon defects
**Status:** Complete
**Link:** [writeups/CIRCUITS_POWER.md](writeups/CIRCUITS_POWER.md)

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

### SUPER_HVAC_POWER.md
**Routine:** `cadhvac.txt` (Ada Super-CAD / Integrated Engineering System)
**Focus:** Database-first engineering model, integrated HVAC/FM tools, typed large-scale evolution
**Theme:** Shared object truth as anti-fragile infrastructure for design and operations
**Status:** Complete
**Link:** [writeups/SUPER_HVAC_POWER.md](writeups/SUPER_HVAC_POWER.md)

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

### SWIZZLING_SSE_POWER.md
**Routine:** `swizzling_sse.asm` (Intel SSE AOS→SOA vertex transpose)
**Focus:** Dual-dance half-register + `shufps` weave; 4 vertices / 64 bytes; Windows x64 ABI spills
**Theme:** Ada Lovelace's algebraic loom meets Grove's layout paranoia at the SIMD boundary
**Status:** Complete
**Link:** [writeups/SWIZZLING_SSE_POWER.md](writeups/SWIZZLING_SSE_POWER.md)
**Dual-Dance:** [SWIZZLING_SSE_POWER.html](SWIZZLING_SSE_POWER.html) — Nikolas Bourbaki × Andy Grove

---

### MARKETFIXED_POWER.md
**Routine:** `MarketFixed.asm` (posted-price stall · range-rate gate · 1p levy)
**Focus:** Band algebra, levy-by-subtraction identity, wallet fail-closed composition; 28-byte MarketQuote
**Theme:** Tri-partner paranoia — structure, tax, solvency before any handshake
**Status:** Complete
**Link:** [writeups/MARKETFIXED_POWER.md](writeups/MARKETFIXED_POWER.md)
**Tri-Partner Dance:** [MarketFixed.html](MarketFixed.html) — Nikolas Bourbaki × Andy Grove × Posted Stall

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
