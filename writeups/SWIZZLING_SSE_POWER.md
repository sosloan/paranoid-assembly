# THE POWER OF `swizzling_sse.asm`

> *"The Analytical Engine weaves algebraic patterns just as the Jacquard loom weaves flowers and leaves."* — Ada Lovelace
>
> *"Only the paranoid survive."* — Andy Grove
>
> *Four vertices enter as objects. Four lanes leave as pure coordinates. The dual-dance is the loom.*

**Status:** ✓ COMPLETE
**Subject:** `swizzling_sse.asm` (Intel AOS→SOA vertex transpose, SSE)
**Form:** Power-of writeup, Track 031 style
**Album Tie-In:** ONLY THE PARANOID SURVIVE — SIMD Layout Edition
**Dual-Dance:** [SWIZZLING_SSE_POWER.html](../SWIZZLING_SSE_POWER.html) — Nikolas Bourbaki × Andy Grove interactive weave

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `swizzling_sse.asm` |
| **Origin** | Intel Corporation sample / intrinsic companion (2022 copyright block) |
| **License** | ISC-style permissive ("with or without fee") |
| **Architecture** | x86-64 SSE (`movaps`, `movhlps`, `movlhps`, `shufps`) |
| **Symbol** | `swizzling_sse` |
| **Calling Convention** | Windows x64: `rcx = Vertex_aos *in`, `rdx = Vertex_soa *out` |
| **Return** | void (side-effect stores to `*out`) |
| **Critical Instructions** | Dual-dance: `movhlps`/`movlhps` pairing + `shufps` with `088h`/`0DDh` |
| **Bytes of State** | 64 in → 64 out (4× `float4` vertices, transposed in-register) |
| **Bits That Matter** | Every lane of XMM1–XMM7 during the weave; XMM6/XMM7 callee-saved |
| **Power Source** | Layout transformation as bandwidth survival — AOS for authors, SOA for silicon |

---

## THE FILE, IN FULL

```asm
;
; Copyright (C) 2022 by Intel Corporation
;
; Permission to use, copy, modify, and/or distribute this software for any
; purpose with or without fee is hereby granted.
;
; THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
; REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
; AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
; INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
; LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
; OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
; PERFORMANCE OF THIS SOFTWARE.
;

;    .globl swizzling_sse

    ; void swizzling_sse(Vertex_aos *in, Vertex_soa *out)
    ; On entry:
    ;     rcx = in
    ;     rdx = out


.code
swizzling_sse PROC public
    ; store non-volatile registers on stack
    push rbx
    sub rsp, 32
    movaps xmmword ptr[rsp], xmm6
    movaps  xmmword ptr[rsp+16], xmm7

    mov rbx, rcx               ; mov rbx, aos*
    ;out is already in rdx

    movaps xmm1, [rbx]         ; w0 z0 y0 x0
    movaps xmm2, [rbx+16]      ; w1 z1 y1 x1
    movaps xmm3, [rbx+32]      ; w2 z2 y2 x2
    movaps xmm4, [rbx+48]      ; w3 z3 y3 x3
    movaps xmm7, xmm4          ; xmm7= w3 z3 y3 x3
    movhlps xmm7, xmm3         ; xmm7= w3 z3 w2 z2
    movaps xmm6, xmm2          ; xmm6= w1 z1 y1 x1
    movlhps xmm3, xmm4         ; xmm3= y3 x3 y2 x2
    movhlps xmm2, xmm1         ; xmm2= w1 z1 w0 z0
    movlhps xmm1, xmm6         ; xmm1= y1 x1 y0 x0
    movaps xmm6, xmm2          ; xmm6= w1 z1 w0 z0
    movaps xmm5, xmm1          ; xmm5= y1 x1 y0 x0
    shufps xmm2, xmm7, 0DDh    ; xmm2= w3 w2 w1 w0 => W
    shufps xmm1, xmm3, 088h    ; xmm1= x3 x2 x1 x0 => X
    shufps xmm5, xmm3, 0DDh    ; xmm5= y3 y2 y1 y0 => Y
    shufps xmm6, xmm7, 088h    ; xmm6= z3 z2 z1 z0 => Z
    movaps [rdx], xmm1         ; store X
    movaps [rdx+16], xmm5      ; store Y
    movaps [rdx+32], xmm6      ; store Z
    movaps [rdx+48], xmm2      ; store W

    movaps xmm6, xmmword ptr[rsp]
    movaps xmm7, xmmword ptr[rsp+16]
    add rsp, 32
    pop rbx
    ret

swizzling_sse ENDP
end
```

Sixty-three lines of MASM. Four loads. One dual-dance. Four stores. No branches, no locks, no scalar cleanup. The entire correctness proof is a permutation of sixteen floats.

---

## WHY IT IS POWERFUL

### 1. It is a dual-dance — two choreographies, one transposition.

The heart of the routine is not a single clever instruction. It is a **pair** of register dances that must complete in order:

1. **Half-register dance** (`movhlps` / `movlhps` + copies): packs high/low 64-bit halves so XY pairs live together and ZW pairs live together across vertices.
2. **Lane-shuffle dance** (`shufps` with immediates `088h` and `0DDh`): extracts pure X, pure Y, pure Z, pure W into four SOA vectors.

Delete either dance and the transpose fails. That is dualism as engineering: two incomplete motions that together produce a total order on the data.

Ada Lovelace described the Engine as a weaver of algebraic patterns. This file is that metaphor made concrete — sixteen floats enter as four objects; the loom rethreads them into four homogeneous lanes.

### 2. It separates human layout from machine layout — and refuses to confuse them.

**AOS** (array-of-structures) is how artists, loaders, and APIs think:

```
vertex0: {x0, y0, z0, w0}
vertex1: {x1, y1, z1, w1}
...
```

**SOA** (structure-of-arrays) is how SSE thinks:

```
X: {x0, x1, x2, x3}
Y: {y0, y1, y2, y3}
...
```

The routine is the **boundary object** between those worlds. It does not ask the application to store SOA forever, and it does not ask the SIMD kernel to unpack AOS on every arithmetic op. One paid transform, then pure-lane math. Grove's paranoia applied to bandwidth: never let the comfortable layout tax the hot path forever.

### 3. The shuffle immediates are the score — `088h` and `0DDh` as twin motifs.

`shufps dest, src, imm8` selects two floats from `dest` (low half of result) and two from `src` (high half), using bit pairs in `imm8`.

- **`088h` = `10_00_10_00` binary** — pick lane 0, then lane 2, twice. From the packed XY or ZW pairs this yields the even components: **X** from XY-pairs, **Z** from ZW-pairs.
- **`0DDh` = `11_01_11_01` binary** — pick lane 1, then lane 3, twice. From the same pairs this yields the odd components: **Y** from XY-pairs, **W** from ZW-pairs.

Four `shufps` calls, two immediates, four pure channels. The constants are not magic; they are the musical motif of the second dance. Lovelace would have recognized them as the punched cards of the Jacquard — the pattern that decides which threads rise.

### 4. It is branchless, allocation-free, and kernel-free — paranoia about the cost of *control*.

No `jcc`. No heap. No syscall. Control flow is a straight line from prologue to epilogue. Every cycle goes into data motion. Under a graphics or simulation inner loop that may hit this thousands of times per frame, the absence of a mispredicted branch is not a style choice — it is survival. Grove: assume the worst (a cold predictor, a contended allocator) and design so those threats never get a vote.

### 5. It respects the ABI with surgical care — XMM6/XMM7 are restored, not sacrificed.

Windows x64 marks XMM6–XMM15 non-volatile. The routine needs seven XMM registers for the weave (XMM1–XMM7). Rather than rewrite the algorithm around volatile-only registers, it:

- `sub rsp, 32`
- saves XMM6 and XMM7 with `movaps`
- dances
- restores exactly what it borrowed

`rbx` is likewise preserved. This is paranoia about contracts: the dual-dance is free to be dense *inside* the routine because the edges honor the calling convention completely. A clever transpose that corrupts callee-saved state is not clever; it is a latent crash in someone else's frame.

### 6. Alignment is assumed — and that assumption is load-bearing.

Every `movaps` load and store requires 16-byte alignment. The comments and the instruction choice encode a contract with the caller: `Vertex_aos *in` and `Vertex_soa *out` are SIMD-aligned. Use `movups` and you pay a penalty (or a fault on older silicon paths). The routine chooses the fast instruction and trusts the type system / allocator above it. That is the same doctrine as Ada strong typing moved down to the metal: invalid states (misaligned buffers) are outside the representable contract of the hot path.

### 7. Four vertices is the natural quantum of SSE — the routine is sized to the machine, not the mesh.

SSE registers hold four floats. The routine therefore processes **exactly four vertices** per call. Larger meshes are the caller's loop; smaller tails are the caller's remainder. By refusing to internalize variable-length logic, the dual-dance stays a pure permutation. Composition (loop over groups of four) is left to the layer that knows the mesh cardinality. Smallest correct quantum. Maximum reuse.

### 8. It is the substrate beneath every SOA-first kernel.

Once X, Y, Z, W live in separate vectors:

- Dot products become four-wide multiplies and horizontal sums with no gather.
- Frustum tests, skinning blends, particle integrates, and lighting math stop fighting structure stride.
- Cache lines fill with *homogeneous* work, not interleaved attributes.

This file is not "just a transpose." It is the on-ramp to an entire class of paranoid SIMD kernels that assume SOA. Without it (or its AVX cousins), those kernels either gather clumsily or force the whole asset pipeline into SOA storage — a global tax. The dual-dance localizes the tax to one paid boundary.

### 9. Ada + Grove: poetical science meets strategic inflection.

Lovelace insisted the Engine could manipulate symbols beyond mere number-crunching — that arrangement *is* computation. Grove insisted that inflection points kill the unprepared — that you must see the 10× force before it arrives.

`swizzling_sse.asm` sits at their intersection:

- **Lovelace:** the pattern of rearrangement *is* the algorithm; the dual-dance is algebraic weaving.
- **Grove:** memory layout is a strategic inflection point for SIMD throughput; convert early, convert once, survive the bandwidth wall.

The writeup's dual epigraph is not decoration. It is the dual-dance stated in prose.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

| Line | Instruction | Power |
|------|-------------|-------|
| — | `push rbx` | Preserve non-volatile GPR; free `rbx` as stable AOS base. |
| — | `sub rsp, 32` | Open a 32-byte home for XMM6/XMM7 spill (two `movaps` slots). |
| — | `movaps [rsp], xmm6` | Save callee-saved XMM6 before the dance borrows it. |
| — | `movaps [rsp+16], xmm7` | Save callee-saved XMM7. Contract first, cleverness second. |
| — | `mov rbx, rcx` | Pin AOS pointer; `rcx` may be clobbered by later patterns, `rbx` will not. |
| — | `movaps xmm1, [rbx]` | Load vertex 0 as `w0 z0 y0 x0` (little-endian lane order in comments). |
| — | `movaps xmm2, [rbx+16]` | Load vertex 1. |
| — | `movaps xmm3, [rbx+32]` | Load vertex 2. |
| — | `movaps xmm4, [rbx+48]` | Load vertex 3. Four loads complete the AOS snapshot. |
| — | `movaps xmm7, xmm4` | Stage vertex 3 for high-half merge. |
| — | `movhlps xmm7, xmm3` | **Dance 1a:** `xmm7 ← (hi(xmm7), hi(xmm3))` → `w3 z3 w2 z2`. |
| — | `movaps xmm6, xmm2` | Snapshot vertex 1 before half-moves destroy the original packing. |
| — | `movlhps xmm3, xmm4` | **Dance 1b:** `xmm3 ← (lo(xmm4), lo(xmm3))` → `y3 x3 y2 x2`. |
| — | `movhlps xmm2, xmm1` | **Dance 1c:** `xmm2 ← (hi(xmm2), hi(xmm1))` → `w1 z1 w0 z0`. |
| — | `movlhps xmm1, xmm6` | **Dance 1d:** `xmm1 ← (lo(xmm6), lo(xmm1))` → `y1 x1 y0 x0`. Half-register dance complete. |
| — | `movaps xmm6, xmm2` | Clone ZW-pair register so shuffle can destroy one copy. |
| — | `movaps xmm5, xmm1` | Clone XY-pair register for the Y extraction path. |
| — | `shufps xmm2, xmm7, 0DDh` | **Dance 2a:** odd lanes from ZW pairs → pure **W**. |
| — | `shufps xmm1, xmm3, 088h` | **Dance 2b:** even lanes from XY pairs → pure **X**. |
| — | `shufps xmm5, xmm3, 0DDh` | **Dance 2c:** odd lanes from XY pairs → pure **Y**. |
| — | `shufps xmm6, xmm7, 088h` | **Dance 2d:** even lanes from ZW pairs → pure **Z**. Lane dance complete. |
| — | `movaps [rdx], xmm1` | Store SOA X. |
| — | `movaps [rdx+16], xmm5` | Store SOA Y. |
| — | `movaps [rdx+32], xmm6` | Store SOA Z. |
| — | `movaps [rdx+48], xmm2` | Store SOA W. Four stores complete the boundary. |
| — | `movaps xmm6, [rsp]` | Restore XMM6 — leave no footprints. |
| — | `movaps xmm7, [rsp+16]` | Restore XMM7. |
| — | `add rsp, 32` | Collapse spill frame. |
| — | `pop rbx` | Restore RBX. |
| — | `ret` | Void return; the world changed only at `*out`. |

Every move either stages, dances, stores, or restores. There is no spectator instruction.

---

## THE DUAL-DANCE DIAGRAM

```
AOS in-registers                 After half-register dance
─────────────────                ─────────────────────────
xmm1: x0 y0 z0 w0                xmm1: x0 y0 x1 y1   (XY pairs 0,1)
xmm2: x1 y1 z1 w1                xmm2: z0 w0 z1 w1   (ZW pairs 0,1)
xmm3: x2 y2 z2 w2                xmm3: x2 y2 x3 y3   (XY pairs 2,3)
xmm4: x3 y3 z3 w3                xmm7: z2 w2 z3 w3   (ZW pairs 2,3)

                                 After shufps dance (088h / 0DDh)
                                 ────────────────────────────────
                                 xmm1: x0 x1 x2 x3   => X
                                 xmm5: y0 y1 y2 y3   => Y
                                 xmm6: z0 z1 z2 z3   => Z
                                 xmm2: w0 w1 w2 w3   => W
```

(Comment-order in the source uses little-endian lane diagrams `w z y x`; the diagram above uses mathematical component order for readability. Both describe the same sixteen floats.)

Two dances. One isomorphism. AOS ≅ SOA.

---

## THE PARANOIA CONNECTION

`swizzling_sse.asm` is Grove doctrine applied to data shape:

1. **Assume the worst layout tax.** If you leave vertices in AOS, every SSE kernel pays gather forever.
2. **Convert at the boundary.** Pay the dual-dance once; let pure-lane math run uncontended.
3. **Fail the contract early.** Misaligned pointers violate `movaps` — better a loud fault than silent slowdown buried in a profiler three weeks later.
4. **Honor the ABI.** Spill what you borrow. Paranoia includes not poisoning the caller's XMM state.
5. **Size to the machine quantum.** Four vertices, sixteen floats, sixty-four bytes — the width of the execution resource, not the width of the asset.

And Lovelace's half of the dual epigraph:

6. **Arrangement is computation.** The weave *is* the work. Swizzling is not preamble to the "real" algorithm; for bandwidth-bound codes, it *is* the algorithm that makes the rest possible.

> *Only the paranoid survive.* In the SIMD hierarchy, paranoia is a layout transform and two shuffle immediates. In this repository, it is this file.

---

## SCALE OF IMPACT

- **Hardware:** every x86 CPU with SSE (Pentium III forward) implements `movaps`/`shufps`/`movhlps`/`movlhps` so patterns like this are single-digit-cycle permutations rather than scalar scrapes.
- **Software:** mesh loaders, particle systems, audio deinterleavers, and scientific AoS→SoA bridges all reimplement this shape — often via intrinsics that lower to the same dual-dance.
- **Bytes shipped:** the routine is on the order of ~100 bytes of machine code; the *pattern* has shipped in every major game engine and many numerical libraries for two decades.
- **Cost per call:** on the order of a handful of load/shuffle/store cycles for 64 bytes of structured data — vastly cheaper than four gather-style accesses inside a hot kernel loop.

A sixty-four-byte transpose, repeated per mesh chunk per frame, is infrastructure.

---

## WHAT WOULD BREAK WITHOUT IT

Remove `swizzling_sse.asm` (and its conceptual equivalents) from the universe and:

- SOA kernels either gather from AOS (throughput collapse) or force global SOA storage (tooling and artist-pipeline pain).
- Inner loops re-acquire the layout tax on every arithmetic instruction.
- The clean boundary between "object thinking" and "lane thinking" dissolves into ad-hoc shuffles scattered through business logic.

The file is small. The boundary it enforces is not.

---

## VERIFICATION STATUS

✓ **Permutation completeness:** sixteen input floats appear exactly once each in the four output vectors (X,Y,Z,W)
✓ **Branch freedom:** straight-line control flow; always terminates
✓ **ABI compliance:** RBX, XMM6, XMM7 saved/restored; Windows x64 volatile set otherwise free
✓ **Alignment contract:** `movaps` requires 16-byte-aligned `in`/`out` (caller obligation)
✓ **No clobber of `rdx` base across stores:** output pointer remains stable through the dance
✓ **License:** permissive Intel notice, redistributable with copyright retained
✓ **Production pattern:** canonical SSE AOS→SOA transpose taught in Intel optimization materials

**QED.**

---

## CLOSING

`swizzling_sse.asm` is not powerful because it invents new arithmetic. It is powerful because it **admits two truths at once**:

- Humans and scene graphs need objects (AOS).
- Vector units need lanes (SOA).

The dual-dance is the diplomatic protocol between those truths — half-register steps, then shuffle steps, then four clean stores. Ada Lovelace named the weaving. Andy Grove named the survival pressure. This file performs both in thirty-odd executable instructions.

Four vertices enter. Four lanes leave. Nothing else is on the floor.

**The dual-dance holds. Only the paranoid survive. ✓**
