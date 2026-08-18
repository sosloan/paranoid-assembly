# Contributing to paranoid-assembly

This repository is a collection of deep technical analyses on canonical assembly routines. Contributions should maintain the high standards of rigor, clarity, and reverence established in the initial writeups.

---

## Before You Write

1. **Choose a routine** — Pick something that meets these criteria:
   - **Canonical:** The routine is widely deployed and architecturally significant.
   - **Paranoid:** It embodies careful design under real-world constraints (contention, cache effects, power usage, latency).
   - **Load-bearing:** Systems above depend on it. Its absence would matter.
   - **Source-available:** You can understand it completely (not a black box).

   Check **INDEX.md** for existing candidates or propose a new one.

2. **Study the reference** — Get the original assembly source. For Intel TBB, consult:
   - GitHub: https://github.com/oneapi-src/oneTBB
   - Intel TBB documentation
   - Your architecture's ISA manual (IA-32 SDM, ARM ARM, etc.)

3. **Understand the context** — Read existing writeups (especially LOCK_BYTE_POWER.md) to internalize the form and tone.

---

## Writing Your Writeup

### Structure

Use **TEMPLATE.md** as your scaffold. The sections are:

1. **Epigraph** — A quote that frames the routine (preferably from a systems thinker or strategist).
2. **Quick Reference** — Metadata table. Every routine has different attributes; adapt as needed.
3. **The File, in Full** — Complete assembly source, with a summary line.
4. **Why It Is Powerful** — 6–10 insights, each 100–300 words. This is the heart of the writeup.
5. **Instruction-by-Instruction Analysis** — A table with every instruction and its purpose.
6. **Verification Status** — Properties proven (mutual exclusion, progress, no deadlock, memory order, fairness).
7. **Closing** — Synthesis. Answer: "What makes this routine exactly right?"

### Tone & Style

- **Reverential, not dry.** This code deserves respect. Show it.
- **Concrete, not abstract.** Use specific cycle counts, byte sizes, and architectural details.
- **Strategic, not mechanical.** Connect the code to larger principles (Grove's paranoia, constraints of concurrency, the limits of hardware).
- **Accessible, not esoteric.** Assume the reader understands assembly and concurrency but may not know this specific routine.

### Insights to Cover

Each routine should yield insights on:
- **Atomicity & mutual exclusion** — How does it guarantee correctness?
- **Performance under contention** — What tricks reduce cache thrashing or bus congestion?
- **Memory ordering** — What barriers or semantics are implicit?
- **Hardware exploitation** — What CPU features does it leverage?
- **API design** — What does it expose to the caller? What does it hide?
- **Scale** — How many times does it execute? What's its global impact?
- **Paranoia** — Where does it check before committing? Where does it fail fast?

### Examples

From LOCK_BYTE_POWER.md:

> *Before issuing the expensive locked instruction, the routine does a cheap **unlocked load** and bails out if the byte already looks taken. This is the paranoid optimization: assume the lock is hot, check first, only pay the bus-lock tax if you have a real chance of winning.*

This is good: it names the optimization, explains the strategy, and connects it to a principle.

---

## Submission Process

1. **Create a branch:** `git checkout -b writeup/[routine-name]`
2. **Write your analysis:** Place it in `writeups/[ROUTINE_NAME]_POWER.md` (match the naming convention).
3. **Update INDEX.md:** Move your routine from CANDIDATES to IN PROGRESS (or COMPLETE).
4. **Self-review:**
   - Does every instruction have a purpose? Can you delete any?
   - Are the insights specific to *this* routine or generic?
   - Have you cited your sources (ISA manuals, library code, papers)?
   - Is the tone consistent with existing writeups?
5. **Open a PR:** Include a brief summary of the routine and why it's significant.

---

## Review Criteria

PRs will be evaluated on:

- **Technical accuracy** — Do the claims hold up to scrutiny?
- **Completeness** — Does the writeup cover all major design decisions?
- **Clarity** — Can a competent systems engineer follow the analysis?
- **Reverence** — Does the tone honor the engineering work?
- **Structure** — Does it follow the form established by prior writeups?

---

## Questions?

Open an issue or discussion if you have questions about scope, technique, or contribution guidelines.

Thank you for treating this code with the reverence it deserves.
