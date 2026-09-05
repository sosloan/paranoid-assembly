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
