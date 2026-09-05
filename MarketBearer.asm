# MarketBearer.asm
# Matching engine: the fill is the overlap of three ranges, then the 1p levy.
# x86-64 System V, GAS intel syntax. Same assembler invocation as MarketFixed.asm.
# Links against MarketFixed.o for the range-rate gate and the levy.
#
# Seller lives on [reserve, ask]. Buyer lives on [offer, ceiling].
# The tax band is [lo, hi]. The book is [PRICE_MIN, PRICE_MAX].
# A deal exists only when those four intervals have a non-empty intersection
# and the VAT rate is in [0, 1] pennies. That intersection is the match window.
#
# Each step both sides concede (gap >> 3), floored at one tick, clamped to
# the match window. Bounded by MAX_ROUNDS. Settle at the midpoint, on-tick,
# then tax what was agreed — the levy follows the fill, not the sticker.
#
# BarterSession (rdi throughout), 4-byte fields. Caller fills
# ask/reserve/ceiling/lo/hi/rate, then calls barter_open:
#   +0x00 ask
#   +0x04 offer
#   +0x08 reserve
#   +0x0C ceiling
#   +0x10 lo            tax-band floor
#   +0x14 hi            tax-band ceiling
#   +0x18 rate          0 or 1 penny
#   +0x1C rounds
#   +0x20 deal          1 = hands shaken
#   +0x24 net
#   +0x28 vat
#   +0x2C gross         settled fill
#   +0x30 saved         list - settled
#   +0x34 status
#   +0x38 list          opening ask
#   +0x3C match_lo      intersection after open
#   +0x40 match_hi

        .intel_syntax noprefix
        .text

        .extern market_in_range
        .extern _market_in_range
        .extern market_band_ok
        .extern _market_band_ok
        .extern market_rate_ok
        .extern _market_rate_ok
        .extern market_levy
        .extern _market_levy
        .equ    S_ASK,          0x00
        .equ    S_OFFER,        0x04
        .equ    S_RESERVE,      0x08
        .equ    S_CEILING,      0x0C
        .equ    S_LO,           0x10
        .equ    S_HI,           0x14
        .equ    S_RATE,         0x18
        .equ    S_ROUNDS,       0x1C
        .equ    S_DEAL,         0x20
        .equ    S_NET,          0x24
        .equ    S_VAT,          0x28
        .equ    S_GROSS,        0x2C
        .equ    S_SAVED,        0x30
        .equ    S_STATUS,       0x34
        .equ    S_LIST,         0x38
        .equ    S_MATCH_LO,     0x3C
        .equ    S_MATCH_HI,     0x40

        .equ    MAX_ROUNDS,       8
        .equ    CONCESSION_SHIFT, 3
        .equ    TICK,             1
        .equ    LEVY_QUOTE_BYTES, 0x1C
        .equ    LEVY_STACK_BYTES, LEVY_QUOTE_BYTES + 12
        .equ    PRICE_MIN,        1
        .equ    PRICE_MAX,        0x7FFFFFFF

        .equ    ST_OK,          0
        .equ    ST_RANGE,       1
        .equ    ST_RATE,        2
        .equ    ST_NO_DEAL,     4

        .equ    Q_STATUS,       0x18

#------------------------------------------------------------------------------
# uint32_t barter_intersect(uint32_t a_lo, uint32_t a_hi,
#                           uint32_t b_lo, uint32_t b_hi,
#                           uint32_t *out_lo, uint32_t *out_hi)
#   rdi=a_lo  esi=a_hi  edx=b_lo  ecx=b_hi  r8=out_lo  r9=out_hi
#   lo = max(a_lo, b_lo), hi = min(a_hi, b_hi). Returns 1 if lo <= hi.
#------------------------------------------------------------------------------
        .globl  barter_intersect
        .globl  _barter_intersect
barter_intersect:
_barter_intersect:
        mov     eax, edi                # a_lo
        cmp     eax, edx
        cmovb   eax, edx                # max
        mov     r10d, esi               # a_hi
        cmp     r10d, ecx
        cmova   r10d, ecx               # min
        mov     dword ptr [r8], eax
        mov     dword ptr [r9], r10d
        xor     edx, edx
        cmp     eax, r10d
        setbe   dl
        mov     eax, edx
        ret

#------------------------------------------------------------------------------
# void barter_open(BarterSession *s)
#   Snapshot the sticker, open the bid at reserve, compute the match window
#   as the intersection of seller, buyer, tax band, and the book.
#------------------------------------------------------------------------------
        .globl  barter_open
        .globl  _barter_open
barter_open:
_barter_open:
        push    r12
        sub     rsp, 32                 # two uint32 temps + call-safe scratch
        mov     r12, rdi

        mov     eax, dword ptr [r12 + S_ASK]
        mov     dword ptr [r12 + S_LIST], eax

        mov     eax, dword ptr [r12 + S_RESERVE]
        mov     dword ptr [r12 + S_OFFER], eax

        xor     eax, eax
        mov     dword ptr [r12 + S_ROUNDS], eax
        mov     dword ptr [r12 + S_DEAL], eax
        mov     dword ptr [r12 + S_NET], eax
        mov     dword ptr [r12 + S_VAT], eax
        mov     dword ptr [r12 + S_GROSS], eax
        mov     dword ptr [r12 + S_SAVED], eax
        mov     dword ptr [r12 + S_STATUS], eax
        mov     dword ptr [r12 + S_MATCH_LO], eax
        mov     dword ptr [r12 + S_MATCH_HI], eax

        # seller ∩ buyer
        mov     edi, dword ptr [r12 + S_RESERVE]
        mov     esi, dword ptr [r12 + S_ASK]
        mov     edx, dword ptr [r12 + S_OFFER]
        mov     ecx, dword ptr [r12 + S_CEILING]
        lea     r8, [rsp]
        lea     r9, [rsp + 4]
        call    barter_intersect
        test    eax, eax
        jz      .Lopen_empty

        # that ∩ tax band
        mov     edi, dword ptr [rsp]
        mov     esi, dword ptr [rsp + 4]
        mov     edx, dword ptr [r12 + S_LO]
        mov     ecx, dword ptr [r12 + S_HI]
        lea     r8, [rsp + 8]
        lea     r9, [rsp + 12]
        call    barter_intersect
        test    eax, eax
        jz      .Lopen_empty

        # that ∩ book
        mov     edi, dword ptr [rsp + 8]
        mov     esi, dword ptr [rsp + 12]
        mov     edx, PRICE_MIN
        mov     ecx, PRICE_MAX
        lea     r8, [r12 + S_MATCH_LO]
        lea     r9, [r12 + S_MATCH_HI]
        call    barter_intersect
        test    eax, eax
        jz      .Lopen_empty

        # rate must be legal before the band gate runs
        mov     edi, dword ptr [r12 + S_RATE]
        call    market_rate_ok
        test    eax, eax
        jz      .Lopen_rate

        # band itself must now validate as range/order/book/tick correct
        mov     edi, dword ptr [r12 + S_LO]
        mov     esi, dword ptr [r12 + S_HI]
        mov     edx, dword ptr [r12 + S_RATE]
        call    market_band_ok
        test    eax, eax
        jnz     .Lopen_ok
        jmp     .Lopen_band_fail

.Lopen_ok:

        add     rsp, 32
        pop     r12
        ret

.Lopen_empty:
        mov     rdi, r12
        call    barter_walk_away
        mov     dword ptr [r12 + S_STATUS], ST_RANGE
        add     rsp, 32
        pop     r12
        ret

.Lopen_band_fail:
        mov     rdi, r12
        call    barter_walk_away
        mov     dword ptr [r12 + S_STATUS], ST_RANGE
        add     rsp, 32
        pop     r12
        ret

.Lopen_rate:
        mov     rdi, r12
        call    barter_walk_away
        mov     dword ptr [r12 + S_STATUS], ST_RATE
        add     rsp, 32
        pop     r12
        ret

#------------------------------------------------------------------------------
# uint32_t barter_step(BarterSession *s)
#   One concession inside the match window. Returns 1 when the gap has closed.
#------------------------------------------------------------------------------
        .globl  barter_step
        .globl  _barter_step
barter_step:
_barter_step:
        push    rbx
        push    r12
        mov     r12, rdi
        mov     eax, dword ptr [r12 + S_ASK]
        mov     ecx, dword ptr [r12 + S_OFFER]

        cmp     ecx, eax
        jae     .Lstep_closed

        mov     edx, eax
        sub     edx, ecx                # gap
        cmp     edx, TICK
        jbe     .Lstep_closed           # one tick or less: split it

        mov     ebx, edx
        shr     ebx, CONCESSION_SHIFT
        test    ebx, ebx
        jnz     .Lstep_have
        mov     ebx, TICK               # always move, or we stall
.Lstep_have:

        sub     eax, ebx                # seller comes down
        mov     edx, dword ptr [r12 + S_MATCH_LO]
        cmp     eax, edx
        cmovb   eax, edx

        add     ecx, ebx                # buyer comes up
        mov     edx, dword ptr [r12 + S_MATCH_HI]
        cmp     ecx, edx
        cmova   ecx, edx

        mov     dword ptr [r12 + S_ASK], eax
        mov     dword ptr [r12 + S_OFFER], ecx

        mov     eax, dword ptr [r12 + S_ROUNDS]
        add     eax, 1
        mov     dword ptr [r12 + S_ROUNDS], eax

        xor     eax, eax
        pop     r12
        pop     rbx
        ret

.Lstep_closed:
        mov     eax, 1
        pop     r12
        pop     rbx
        ret

#------------------------------------------------------------------------------
# uint32_t barter_settle(BarterSession *s)
#   Haggle, land on-tick inside the window, levy the 1p on the fill.
#------------------------------------------------------------------------------
        .globl  barter_settle
        .globl  _barter_settle
barter_settle:
_barter_settle:
        push    rbx
        push    r12
        push    r13
        mov     r12, rdi

        mov     ebx, dword ptr [r12 + S_STATUS]
        test    ebx, ebx
        jnz     .Lsettle_existing_fail  # open already failed (range/rate)

        mov     ebx, MAX_ROUNDS
.Lhaggle:
        mov     rdi, r12
        call    barter_step
        test    eax, eax
        jnz     .Lshake
        sub     ebx, 1
        jnz     .Lhaggle
        jmp     .Lsettle_walk

.Lshake:
        mov     eax, dword ptr [r12 + S_ASK]
        mov     ecx, dword ptr [r12 + S_OFFER]
        add     eax, ecx
        shr     eax, 1                  # midpoint

        mov     edx, dword ptr [r12 + S_MATCH_LO]
        cmp     eax, edx
        cmovb   eax, edx
        mov     edx, dword ptr [r12 + S_MATCH_HI]
        cmp     eax, edx
        cmova   eax, edx
        mov     r13d, eax               # candidate fill

        mov     edi, r13d
        mov     esi, dword ptr [r12 + S_MATCH_LO]
        mov     edx, dword ptr [r12 + S_MATCH_HI]
        call    market_in_range
        test    eax, eax
        jz      .Lsettle_walk

        # levy writes net/vat/gross/rate/status into a Quote-shaped prefix
        # at S_NET. Layout: net,vat,gross,rate,lo,hi,status — but our
        # session stores net,vat,gross at +0x24 and rate already at +0x18.
        # Call levy with a scratch quote on the stack, then copy back.
        sub     rsp, LEVY_STACK_BYTES     # full quote scratch + alignment slack
        lea     rdi, [rsp]
        mov     esi, r13d
        mov     edx, dword ptr [r12 + S_RATE]
        call    market_levy
        mov     ebx, dword ptr [rsp + Q_STATUS]
        test    ebx, ebx
        jnz     .Lsettle_fail_levy

        mov     eax, dword ptr [rsp + 0x00]
        mov     dword ptr [r12 + S_NET], eax
        mov     eax, dword ptr [rsp + 0x04]
        mov     dword ptr [r12 + S_VAT], eax
        mov     eax, dword ptr [rsp + 0x08]
        mov     dword ptr [r12 + S_GROSS], eax
        add     rsp, LEVY_STACK_BYTES

        mov     dword ptr [r12 + S_DEAL], 1
        mov     eax, dword ptr [r12 + S_LIST]
        sub     eax, r13d
        mov     dword ptr [r12 + S_SAVED], eax
        mov     dword ptr [r12 + S_STATUS], ST_OK
        xor     eax, eax
        pop     r13
        pop     r12
        pop     rbx
        ret

.Lsettle_fail_levy:
        add     rsp, LEVY_STACK_BYTES
        xor     eax, eax
        mov     dword ptr [r12 + S_DEAL], eax
        mov     dword ptr [r12 + S_NET], eax
        mov     dword ptr [r12 + S_VAT], eax
        mov     dword ptr [r12 + S_GROSS], eax
        mov     dword ptr [r12 + S_SAVED], eax
        jmp     .Lsettle_fail

.Lsettle_fail:
        mov     dword ptr [r12 + S_STATUS], ebx
        mov     eax, ebx
        pop     r13
        pop     r12
        pop     rbx
        ret

.Lsettle_walk:
        mov     rdi, r12
        call    barter_walk_away
        mov     dword ptr [r12 + S_STATUS], ST_NO_DEAL
        mov     eax, ST_NO_DEAL
        pop     r13
        pop     r12
        pop     rbx
        ret

.Lsettle_existing_fail:
        mov     r13d, ebx
        mov     rdi, r12
        call    barter_walk_away
        mov     dword ptr [r12 + S_STATUS], r13d
        mov     eax, r13d
        pop     r13
        pop     r12
        pop     rbx
        ret

#------------------------------------------------------------------------------
# void barter_walk_away(BarterSession *s)
#   Zero the money fields so a failed match cannot be mistaken for a free book.
#------------------------------------------------------------------------------
        .globl  barter_walk_away
        .globl  _barter_walk_away
barter_walk_away:
_barter_walk_away:
        xor     eax, eax
        mov     dword ptr [rdi + S_DEAL], eax
        mov     dword ptr [rdi + S_NET], eax
        mov     dword ptr [rdi + S_VAT], eax
        mov     dword ptr [rdi + S_GROSS], eax
        mov     dword ptr [rdi + S_SAVED], eax
        mov     dword ptr [rdi + S_STATUS], ST_NO_DEAL
        ret
