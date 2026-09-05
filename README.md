# paranoid-assembly

> *"Only the paranoid survive."* — Andy Grove

**Power-of writeups on canonical assembly:** Intel TBB primitives, concurrency code, and infrastructure shaped by Grove's strategic doctrine applied to silicon.

This repository is a collection of **reverential technical documentation** for assembly routines that power modern parallel computing. Each writeup treats a single subroutine as a subject worthy of deep analysis—not just explaining *what* the code does, but *why* every instruction earns its place and what it reveals about the design constraints of systems under paranoia.

---

## What Lives Here

- **writeups/** — deep dives on canonical routines (lock_byte.asm, spin loops, atomic operations, etc.)
- **templates/** — structure and format for new analyses
- **INDEX.md** — catalog of completed and pending analyses
- **Ada-Lovelace-Grove.html** — creative coding voyage (Ada · Grove · Bourbaki pirate)
- **SWIZZLING_SSE_POWER.html** — Nikolas Bourbaki × Andy Grove dual-dance for the SSE AOS→SOA weave

---

## The Form

Each writeup follows the "Track 031 Power-of" style:

1. **Quick reference** — metadata table
2. **The file in full** — complete source code
3. **Why it is powerful** — 8–10 core insights
4. **Instruction-by-instruction analysis** — every line gets its why
5. **Proof of correctness** — formal verification status
6. **Closing** — synthesis and significance

See **TEMPLATE.md** for the scaffold.

---

## Example: LOCK_BYTE_POWER.md

The first writeup covers `__TBB_machine_trylockbyte` from Intel TBB:

- 13 instructions
- 1 byte of state
- Billions of executions per second across humanity's CPUs
- A masterclass in paranoid optimization

Read it to understand the form.

---

## Why This Matters

Infrastructure code is invisible. A single routine that executes quintillions of times across the global compute base often goes unread and unappreciated. This repository makes that code *visible* and *legible*—showing that systems under constraints are not accidents, but carefully shaped artifacts.

Each writeup is an act of reverence for the engineering that powers everything above.

---

## Contribution

To add a new writeup:

1. Identify a canonical routine (Intel TBB, x86 atomics, work-stealing primitives, etc.)
2. Follow **TEMPLATE.md**
3. Open a PR with the new writeup in **writeups/**

See **CONTRIBUTING.md** for guidelines.

---

## License

Original assembly and reference material is sourced from projects under their original licenses (typically Apache 2.0 for Intel TBB). Writeups and analysis are provided under [CC BY 4.0](https://creativecommons.org/licenses/by/4.0/).

File-specific provenance note (this repository does not define a blanket reproduction policy):
- `writeups/SUPERHVAC_POWER.md` reproduces `cadhvac.txt` for archival analysis and keeps the original flyer attribution and in-text reprint permission language intact.

---

## Status

✓ **In progress** — first writeup complete, catalog growing.