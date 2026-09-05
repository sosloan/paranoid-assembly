# Bandit.asm
# General adversarial bandit interval primitives.
# Semantics do not matter here: these entry points only do overlap and midpoint
# selection over unsigned price intervals.
# x86-64 System V, GAS intel syntax.

        .intel_syntax noprefix
        .text

#------------------------------------------------------------------------------
# uint32_t bandit_intersect(uint32_t a_lo, uint32_t a_hi,
#                           uint32_t b_lo, uint32_t b_hi,
#                           uint32_t *out_lo, uint32_t *out_hi)
#   rdi=a_lo  esi=a_hi  edx=b_lo  ecx=b_hi  r8=out_lo  r9=out_hi
#   lo = max(a_lo, b_lo), hi = min(a_hi, b_hi). Returns 1 if lo <= hi.
#------------------------------------------------------------------------------
        .globl  bandit_intersect
bandit_intersect:
        mov     eax, edi
        cmp     eax, edx
        cmovb   eax, edx

        mov     r10d, esi
        cmp     r10d, ecx
        cmova   r10d, ecx

        mov     dword ptr [r8], eax
        mov     dword ptr [r9], r10d

        xor     edx, edx
        cmp     eax, r10d
        setbe   dl
        mov     eax, edx
        ret

#------------------------------------------------------------------------------
# uint32_t bandit_midpoint(uint32_t lo, uint32_t hi)
#   edi=lo  esi=hi
#   Returns floor((lo + hi) / 2), computed without overflow.
#------------------------------------------------------------------------------
        .globl  bandit_midpoint
bandit_midpoint:
        mov     eax, edi
        xor     eax, esi
        shr     eax, 1
        and     edi, esi
        add     eax, edi
        ret

#------------------------------------------------------------------------------
# uint32_t bandit_pick(uint32_t a_lo, uint32_t a_hi,
#                      uint32_t b_lo, uint32_t b_hi,
#                      uint32_t *out_mid)
#   rdi=a_lo  esi=a_hi  edx=b_lo  ecx=b_hi  r8=out_mid
#   Returns 1 and writes midpoint of the intersection on success.
#   Returns 0 when intersection is empty and leaves *out_mid unchanged.
#------------------------------------------------------------------------------
        .globl  bandit_pick
bandit_pick:
        mov     eax, edi
        cmp     eax, edx
        cmovb   eax, edx                # lo = max(a_lo, b_lo)

        mov     r10d, esi
        cmp     r10d, ecx
        cmova   r10d, ecx               # hi = min(a_hi, b_hi)

        cmp     eax, r10d
        ja      .Lpick_none

        mov     edx, eax
        xor     edx, r10d
        shr     edx, 1
        and     eax, r10d
        add     eax, edx                # midpoint of [lo, hi]

        mov     dword ptr [r8], eax
        mov     eax, 1
        ret

.Lpick_none:
        xor     eax, eax
        ret
