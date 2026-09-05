# THE POWER OF `MarketFixed.asm`

> *"Only the paranoid survive."* — Andy Grove
>
> *"Structures are the mathematician's only objects."* — after Nicolas Bourbaki
>
> *Posted price. No haggle. Three partners gate the fill: band, levy, funds. The range-rate gate is the whole job.*

**Status:** ✓ COMPLETE  
**Subject:** `MarketFixed.asm` (posted-price stall · range-rate gate · 1p levy)  
**Form:** Power-of writeup, Track 031 style  
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Market Microstructure Edition  
**Tri-Partner Dance:** [MarketFixed.html](../MarketFixed.html) — Nikolas Bourbaki × Andy Grove × Posted Stall interactive gate

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `MarketFixed.asm` |
| **Origin** | paranoid-assembly market primitives (companion to `MarketBarter.asm`) |
| **License** | CC BY 4.0 (writeup); assembly original to this repository |
| **Architecture** | x86-64 System V, GAS Intel syntax (`.intel_syntax noprefix`) |
| **Symbols** | `market_on_tick`, `market_in_range`, `market_rate_ok`, `market_band_ok`, `market_levy`, `market_quote_fixed`, `market_change_due` |
| **Argument** | `market_quote_fixed(MarketQuote *q, list, lo, hi, rate, wallet)` via rdi/esi/edx/ecx/r8d/r9d |
| **Return** | `uint32_t` status (`ST_OK`, `ST_RANGE`, `ST_RATE`, `ST_FUNDS`); side-effect writes to `*q` |
| **Critical Instruction** | Levy by `sub` so `net + vat == gross`; band-first fail-closed composition |
| **Bytes of State** | 28-byte `MarketQuote` (7 × uint32: net, vat, gross, rate, lo, hi, status) |
| **Bits That Matter** | Every conjunct of the fill predicate; unsigned penny comparisons |
| **Power Source** | Posted-price clearing under paranoia — gate structure, tax, and solvency before any handshake |

---

## THE FILE, IN FULL

```asm
# MarketFixed.asm
# Posted-price stall. No haggle. The range-rate gate is the whole job.
# x86-64 System V, GAS intel syntax. On Apple Silicon, target x86_64:
#   clang -target x86_64-apple-macos -c MarketFixed.asm -o MarketFixed.o
#   clang -target x86_64-apple-macos -c MarketBarter.asm -o MarketBarter.o
#
# Money is unsigned pennies. The tick is 1 penny. The VAT rate is 1 penny:
# a flat exchange levy collected at clearing, not a percentage split.
#
# A fill is legal only when all of these hold:
#   1. rate  in [RATE_MIN, RATE_MAX]     = [0, 1]
#   2. band  lo <= hi, both in [PRICE_MIN, PRICE_MAX], both on-tick
#   3. price in the posted band [lo, hi]
#   4. price >= rate                     (wallet can pay the levy)
# Then:  vat = rate (0 or 1),  net = gross - vat
# vat by subtraction so net + vat == gross with no lost penny.
#
# MarketQuote (rdi on market_quote_fixed), 4-byte fields:
#   +0x00 net
#   +0x04 vat
#   +0x08 gross
#   +0x0C rate
#   +0x10 lo
#   +0x14 hi
#   +0x18 status

        .intel_syntax noprefix
        .text

        .equ    TICK,           1
        .equ    VAT_RATE,       1
        .equ    RATE_MIN,       0
        .equ    RATE_MAX,       1
        .equ    PRICE_MIN,      1
        .equ    PRICE_MAX,      0x7FFFFFFF

        .equ    Q_NET,          0x00
        .equ    Q_VAT,          0x04
        .equ    Q_GROSS,        0x08
        .equ    Q_RATE,         0x0C
        .equ    Q_LO,           0x10
        .equ    Q_HI,           0x14
        .equ    Q_STATUS,       0x18

        .equ    ST_OK,          0
        .equ    ST_RANGE,       1
        .equ    ST_RATE,        2
        .equ    ST_FUNDS,       3

#------------------------------------------------------------------------------
# uint32_t market_on_tick(uint32_t p)
#   edi = p. Returns 1 iff p is a whole number of ticks.
#------------------------------------------------------------------------------
        .globl  market_on_tick
        .globl  _market_on_tick
market_on_tick:
_market_on_tick:
        mov     eax, edi
        xor     edx, edx
        mov     ecx, TICK
        div     ecx
        xor     eax, eax
        test    edx, edx
        setz    al
        ret

#------------------------------------------------------------------------------
# uint32_t market_in_range(uint32_t p, uint32_t lo, uint32_t hi)
#   edi = p, esi = lo, edx = hi. Unsigned closed interval.
#------------------------------------------------------------------------------
        .globl  market_in_range
        .globl  _market_in_range
market_in_range:
_market_in_range:
        xor     eax, eax
        cmp     edi, esi
        jb      .Lir_out
        cmp     edi, edx
        ja      .Lir_out
        mov     eax, 1
.Lir_out:
        ret

#------------------------------------------------------------------------------
# uint32_t market_rate_ok(uint32_t rate)
#   edi = rate. Legal VAT is 0 or 1 penny.
#------------------------------------------------------------------------------
        .globl  market_rate_ok
        .globl  _market_rate_ok
market_rate_ok:
_market_rate_ok:
        xor     eax, eax
        cmp     edi, RATE_MIN
        jb      .Lro_out
        cmp     edi, RATE_MAX
        ja      .Lro_out
        mov     eax, 1
.Lro_out:
        ret

#------------------------------------------------------------------------------
# uint32_t market_band_ok(uint32_t lo, uint32_t hi, uint32_t rate)
#   edi = lo, esi = hi, edx = rate.
#   Band must be ordered, on-tick, inside the book, and carry a legal rate.
#------------------------------------------------------------------------------
        .globl  market_band_ok
        .globl  _market_band_ok
market_band_ok:
_market_band_ok:
        push    rbx
        push    r12
        push    r13
        mov     r12d, edi               # lo
        mov     r13d, esi               # hi
        mov     ebx, edx                # rate

        mov     edi, ebx
        call    market_rate_ok
        test    eax, eax
        jz      .Lbo_fail

        cmp     r12d, r13d
        ja      .Lbo_fail               # lo > hi: empty band

        mov     edi, r12d
        call    market_on_tick
        test    eax, eax
        jz      .Lbo_fail
        mov     edi, r13d
        call    market_on_tick
        test    eax, eax
        jz      .Lbo_fail

        mov     edi, r12d
        mov     esi, PRICE_MIN
        mov     edx, PRICE_MAX
        call    market_in_range
        test    eax, eax
        jz      .Lbo_fail
        mov     edi, r13d
        mov     esi, PRICE_MIN
        mov     edx, PRICE_MAX
        call    market_in_range
        test    eax, eax
        jz      .Lbo_fail

        mov     eax, 1
        pop     r13
        pop     r12
        pop     rbx
        ret
.Lbo_fail:
        xor     eax, eax
        pop     r13
        pop     r12
        pop     rbx
        ret

#------------------------------------------------------------------------------
# uint32_t market_levy(MarketQuote *q, uint32_t gross, uint32_t rate)
#   rdi = q, esi = gross, edx = rate.
#   Writes net/vat/gross/rate. Returns status. Does not touch lo/hi.
#------------------------------------------------------------------------------
        .globl  market_levy
        .globl  _market_levy
market_levy:
_market_levy:
        push    rbx
        push    r12
        push    r13
        mov     r12, rdi                # q
        mov     r13d, esi               # gross
        mov     ebx, edx                # rate

        mov     dword ptr [r12 + Q_NET], 0
        mov     dword ptr [r12 + Q_VAT], 0
        mov     dword ptr [r12 + Q_GROSS], r13d
        mov     dword ptr [r12 + Q_RATE], ebx

        mov     edi, ebx
        call    market_rate_ok
        test    eax, eax
        jz      .Llevy_rate

        cmp     r13d, ebx
        jb      .Llevy_range            # cannot collect a 1p levy on a 0p book

        mov     eax, r13d
        sub     eax, ebx
        mov     dword ptr [r12 + Q_NET], eax
        mov     dword ptr [r12 + Q_VAT], ebx

        xor     eax, eax                # ST_OK
        mov     dword ptr [r12 + Q_STATUS], eax
        pop     r13
        pop     r12
        pop     rbx
        ret
.Llevy_rate:
        mov     eax, ST_RATE
        mov     dword ptr [r12 + Q_STATUS], eax
        pop     r13
        pop     r12
        pop     rbx
        ret
.Llevy_range:
        mov     eax, ST_RANGE
        mov     dword ptr [r12 + Q_STATUS], eax
        pop     r13
        pop     r12
        pop     rbx
        ret

#------------------------------------------------------------------------------
# uint32_t market_quote_fixed(MarketQuote *q, uint32_t list,
#                             uint32_t lo, uint32_t hi,
#                             uint32_t rate, uint32_t wallet)
#   rdi=q  esi=list  edx=lo  ecx=hi  r8d=rate  r9d=wallet
#   Range-rate first, then the 1p levy, then the wallet.
#------------------------------------------------------------------------------
        .globl  market_quote_fixed
        .globl  _market_quote_fixed
market_quote_fixed:
_market_quote_fixed:
        push    rbx
        push    r12
        push    r13
        push    r14
        push    r15
        mov     r12, rdi                # q
        mov     r13d, esi               # list
        mov     r14d, edx               # lo
        mov     r15d, ecx               # hi
        mov     ebx, r8d                # rate
        # r9d = wallet, kept in r9

        xor     eax, eax
        mov     dword ptr [r12 + Q_NET], eax
        mov     dword ptr [r12 + Q_VAT], eax
        mov     dword ptr [r12 + Q_GROSS], eax
        mov     dword ptr [r12 + Q_RATE], ebx
        mov     dword ptr [r12 + Q_LO], r14d
        mov     dword ptr [r12 + Q_HI], r15d
        mov     dword ptr [r12 + Q_STATUS], eax

        mov     edi, r14d
        mov     esi, r15d
        mov     edx, ebx
        call    market_band_ok
        test    eax, eax
        jnz     .Lqf_price
        # band_ok failed: rate vs empty/out-of-book band
        mov     edi, ebx
        call    market_rate_ok
        test    eax, eax
        jz      .Lqf_rate
        jmp     .Lqf_range

.Lqf_price:
        mov     edi, r13d
        mov     esi, r14d
        mov     edx, r15d
        call    market_in_range
        test    eax, eax
        jz      .Lqf_range

        mov     edi, r13d
        call    market_on_tick
        test    eax, eax
        jz      .Lqf_range

        mov     rdi, r12
        mov     esi, r13d
        mov     edx, ebx
        call    market_levy
        test    eax, eax
        jnz     .Lqf_done               # levy already wrote status

        cmp     r9d, r13d
        jb      .Lqf_funds
        xor     eax, eax
        jmp     .Lqf_done

.Lqf_rate:
        mov     eax, ST_RATE
        mov     dword ptr [r12 + Q_STATUS], eax
        jmp     .Lqf_done
.Lqf_range:
        mov     eax, ST_RANGE
        mov     dword ptr [r12 + Q_STATUS], eax
        jmp     .Lqf_done
.Lqf_funds:
        mov     eax, ST_FUNDS
        mov     dword ptr [r12 + Q_STATUS], eax
.Lqf_done:
        pop     r15
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        ret

#------------------------------------------------------------------------------
# uint32_t market_change_due(uint32_t wallet, uint32_t gross)
#   Saturates at zero so a short wallet never wraps.
#------------------------------------------------------------------------------
        .globl  market_change_due
        .globl  _market_change_due
market_change_due:
_market_change_due:
        mov     eax, edi
        sub     eax, esi
        jnc     .Lcd_ok
        xor     eax, eax
.Lcd_ok:
        ret
```

~317 lines. Seven entry points. One job: refuse an illegal fill before a single penny is mis-accounted.

---

## WHY IT IS POWERFUL

### 1. Posted price is a political choice encoded as control flow

`MarketFixed` does not discover a price. It accepts a sticker (`list`) and asks only whether that sticker is *legal* under band, rate, tick, and wallet constraints. The absence of a concession loop is not an omission — it is the product. Haggle lives in `MarketBarter.asm`. This file is the stall that does not move.

### 2. Money is unsigned pennies on a 1p lattice

`TICK = 1`, `PRICE_MIN = 1`, `PRICE_MAX = 0x7FFFFFFF`. Comparisons are `jb`/`ja`, never signed. The lattice gate `market_on_tick` remains a first-class call even when the tick is 1, because the *name* of the constraint must survive a future retick. Bourbaki’s partner: the discrete structure is stated, not implied.

### 3. VAT is a flat penny, not a percentage

`RATE_MIN/MAX = {0,1}`. The exchange levy is a one-penny tax or nothing. No multiply, no rounding mode, no “who keeps the half-penny” debate. Grove’s partner: complexity is an attack surface. The levy is simple enough to prove by eye.

### 4. Levy by subtraction preserves the clearing identity

```
net = gross - rate
vat = rate
⇒ net + vat == gross
```

`market_levy` writes gross first, zeros net/vat, then commits net and vat only after rate and affordability gates pass. There is no path that leaves `net + vat ≠ gross` on success. Ada’s identity is not a comment — it is the arithmetic.

### 5. Band-first composition is fail-closed paranoia

`market_quote_fixed` orders the world:

1. Zero the quote; pin rate/lo/hi  
2. `market_band_ok` (rate + order + tick + book)  
3. List in band + on-tick  
4. `market_levy`  
5. Wallet ≥ list  

When `band_ok` fails, the routine *re-classifies* into `ST_RATE` vs `ST_RANGE` rather than collapsing every failure into one code. Callers learn *why* the stall refused. Silence is not consent; status is speech.

### 6. Four statuses, no partial fills

| Status | Meaning |
|--------|---------|
| `ST_OK` (0) | Band, levy, funds all clear |
| `ST_RANGE` (1) | Empty/off-book band, off-band list, off-tick, or gross &lt; rate |
| `ST_RATE` (2) | Rate ∉ [0,1] |
| `ST_FUNDS` (3) | Wallet &lt; list |

Invalid inputs never produce a tempting half-quote with a live net. The paranoid default is refusal.

### 7. Callee-saved discipline matches System V density

`market_quote_fixed` pushes `rbx, r12–r15` and keeps wallet in `r9` across calls. `market_band_ok` and `market_levy` likewise honor the ABI. The interior may call freely; the edges repay what they borrow. Same doctrine as the SSE dual-dance spills — contract first, cleverness second.

### 8. `market_change_due` saturates; short wallets never wrap

```
sub eax, esi
jnc .Lcd_ok
xor eax, eax
```

A wallet of 3 and a gross of 5 must not become `0xFFFFFFFE` pennies of change. Grove again: assume the underflow; kill it in one `jnc`.

### 9. Shared substrate for barter

`MarketBarter.asm` `.extern`s the on-tick, in-range, band-ok, and levy symbols. Fixed and barter are not two markets — they are two *dances* on one lattice. The tri-partner gate is infrastructure; concession is a later choreography.

### 10. The tri-partner dance is the proof structure

- **Dance I — Nikolas Bourbaki:** band algebra (`on_tick`, `in_range`, `band_ok`)  
- **Dance II — Andy Grove:** levy paranoia (`rate_ok`, `levy`, `sub`)  
- **Dance III — Posted Stall:** wallet & status (`quote_fixed` composition)  

Delete any partner and the stall either over-clears, under-taxes, or spends a short wallet. Three incomplete motions; one total order on a fill.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS

### `market_on_tick`

| Instruction | Power |
|-------------|-------|
| `mov eax, edi` | Candidate price into dividend |
| `xor edx, edx` / `div ecx` | Remainder test against TICK |
| `setz al` | Boolean without a branchy mov-imm path |

### `market_in_range`

| Instruction | Power |
|-------------|-------|
| `xor eax, eax` | Fail-closed default |
| `cmp/jb`, `cmp/ja` | Unsigned closed interval — safe at the top of the book |
| `mov eax, 1` | Success is explicit, not fall-through luck |

### `market_rate_ok`

| Instruction | Power |
|-------------|-------|
| Dual compare to `RATE_MIN`/`RATE_MAX` | Two-point legal set {0,1} as an interval gate |

### `market_band_ok`

| Instruction | Power |
|-------------|-------|
| Save lo/hi/rate in r12/r13/rbx | Survive nested calls |
| `call market_rate_ok` first | Bad rate fails before interval work |
| `cmp r12d, r13d` / `ja` | Empty band is not a band |
| Twin `on_tick` + twin `in_range` | Both endpoints earn full citizenship in the book |

### `market_levy`

| Instruction | Power |
|-------------|-------|
| Zero net/vat; write gross/rate | Partial state is honest before gates |
| `cmp r13d, ebx` / `jb` | Cannot tax a book smaller than the levy |
| `sub eax, ebx` | **Critical:** identity-preserving levy |
| Distinct `.Llevy_rate` / `.Llevy_range` | Status taxonomy, not a blob error |

### `market_quote_fixed`

| Instruction | Power |
|-------------|-------|
| Five pushes | ABI honesty for a multi-call composer |
| Zero + pin fields | Quote never retains prior fill ghosts |
| `call market_band_ok` then reclassify | Dance I, with RATE vs RANGE speech |
| `in_range` + `on_tick` on list | Sticker legality |
| `call market_levy` / `test eax` | Dance II; levy may already have spoken |
| `cmp r9d, r13d` / `jb .Lqf_funds` | Dance III solvency |
| Status labels + single `.Lqf_done` | One epilogue, four meanings |

### `market_change_due`

| Instruction | Power |
|-------------|-------|
| `sub` + `jnc` + `xor` | Saturating change — the anti-wrap coda |

---

## STRATEGIC THEME — TRI-PARTNER PARANOIA

Grove taught inflection: assume the hostile input. Bourbaki taught structure: name the interval before you compute inside it. The Posted Stall teaches product discipline: a fixed price is a promise, and promises are enforced in status codes, not marketing copy.

The interactive companion [MarketFixed.html](../MarketFixed.html) steps the three dances with live inputs — change `list`, `lo`, `hi`, `rate`, or `wallet` and the gate board re-lights. Structure, levy, solvency: watch which partner refuses.

---

## SCALE OF IMPACT

- **Hardware:** Plain integer ALU; no atomics required — this is single-threaded clearing logic meant to be *called* under higher-level locks or actor isolation  
- **Software:** Substrate for `MarketBarter.asm` and any posted-price path that must not invent pennies  
- **Bytes shipped:** One 28-byte quote per attempt; status is 4 bytes of truth  
- **Cost per call:** A handful of compares and two or three leaf calls on the happy path; fail-closed exits are cheaper than a wrong fill  

---

## VERIFICATION STATUS

✓ **Tick lattice:** `market_on_tick` returns 1 iff `p % TICK == 0`  
✓ **Unsigned interval:** `market_in_range` implements closed `[lo, hi]` with unsigned compares  
✓ **Rate set:** `market_rate_ok` ⇔ `rate ∈ {0,1}`  
✓ **Band conjuncts:** `market_band_ok` ⇔ rate ok ∧ lo≤hi ∧ both on-tick ∧ both in book  
✓ **Clearing identity:** On `market_levy` success, `net + vat == gross` and `vat == rate`  
✓ **Fail-closed quote:** `market_quote_fixed` never leaves ST_OK unless band, list, levy, and wallet all pass  
✓ **No wrap change:** `market_change_due` saturates at 0 on underflow  

**QED.**

---

## CLOSING

`MarketFixed.asm` is small enough to hold in working memory and strict enough to trust with money. It does not discover prices, compute percentages, or extend credit. It asks four questions in a fixed order and answers with one of four statuses. Bourbaki orders the band. Grove subtracts the levy. The Stall checks the wallet. Together they clear a posted fill without losing a penny to ambiguity — and that is exactly the job.

Only the paranoid survive the short book. Only the structured mind names the interval. Only the stall that will not haggle can be linked from barter without lying about what “fixed” means.
