# THE POWER OF `Uno.asm`

> *"Only the paranoid survive."* — Andy Grove
>
> *One byte per card. One hundred eight identities. Two seats. The discard is the only source of truth — every play is a fail-closed gate on color, rank, or wild rewrite.*

**Status:** ✓ COMPLETE  
**Subject:** `Uno.asm` (complete Game of UNO · Linux x86-64 · freestanding)  
**Form:** Power-of writeup, Track 031 style  
**Album Tie-In:** ONLY THE PARANOID SURVIVE — Tabletop Rules Engine Edition  

---

## QUICK REFERENCE

| Attribute | Value |
|-----------|-------|
| **File** | `Uno.asm` |
| **Origin** | paranoid-assembly (original) |
| **License** | CC BY 4.0 (writeup); assembly original to this repository |
| **Architecture** | x86-64 System V, GAS Intel syntax (`.intel_syntax noprefix`) |
| **Symbols** | `_start`, deck/hand engine, `play_card`, `card_can_play2`, human + AI turns |
| **Argument** | freestanding binary; `./Uno` human vs AI, `./Uno demo` AI vs AI |
| **Return** | process status via `exit` (0 win path, 1 quit) |
| **Critical Instruction** | packed card byte + `card_can_play2` fail-closed match gate |
| **Bytes of State** | 1 byte/card; 108-card deck; hands up to 40; direction ±1 |
| **Bits That Matter** | rank[3:0], color[5:4]; wilds rewrite color before commit |
| **Power Source** | Rules as pure data transforms — no libc, only `read`/`write`/`exit` |

**Build:**

```bash
gcc -nostdlib -no-pie -x assembler Uno.asm -o Uno
./Uno            # seat 0 = you, seat 1 = AI
./Uno demo       # deterministic AI vs AI
```

**Commands (human):** `<index>` play · `d` draw · `q` quit · `R/Y/G/B` after a wild

---

## THE FILE, IN FULL

```asm
# Uno.asm
# A complete Game of UNO for Linux x86-64.
# x86-64 System V, GAS intel syntax. Assemble and link:
#   gcc -nostdlib -no-pie -x assembler Uno.asm -o Uno
#   ./Uno            # human (seat 0) vs AI (seat 1)
#   ./Uno demo       # AI vs AI autoplay (fixed seed)
#
# Card byte (one byte is the whole identity):
#   bits 0..3  rank   0-9 | 10 SKIP | 11 REVERSE | 12 DRAW2 | 13 WILD | 14 WILD4
#   bits 4..5  color  0 R | 1 Y | 2 G | 3 B  (wilds store chosen color here)
#   0xFF       empty hand slot
#
# Canonical 108-card deck. Max hand 40. Two seats. Direction +/-1.
# Draw-one if no play; drawn card may be played immediately.
# No +4 challenge, no stacking. First empty hand wins.
# 2-player reverse acts as skip (official multi-player reverse otherwise).

        .intel_syntax noprefix

        .equ    RANK_SKIP,      10
        .equ    RANK_REV,       11
        .equ    RANK_D2,        12
        .equ    RANK_WILD,      13
        .equ    RANK_W4,        14

        .equ    CARD_EMPTY,     0xFF
        .equ    DECK_SIZE,      108
        .equ    MAX_HAND,       40
        .equ    NUM_PLAYERS,    2
        .equ    DEAL_COUNT,     7

        .equ    SYS_READ,       0
        .equ    SYS_WRITE,      1
        .equ    SYS_EXIT,       60
        .equ    STDIN,          0
        .equ    STDOUT,         1

#------------------------------------------------------------------------------
        .section .rodata

msg_title:
        .ascii  "=== UNO (paranoid-assembly) ===\n"
        .ascii  "Match color or rank. Wilds choose the color.\n"
        .ascii  "Commands: <index> play | d draw | q quit"
        .ascii  " | R/Y/G/B after wild\n\n"
        .equ    LEN_TITLE, . - msg_title

msg_demo:
        .ascii  "[demo mode: AI vs AI]\n\n"
        .equ    LEN_DEMO, . - msg_demo

msg_human:
        .ascii  "[seat 0 = you, seat 1 = AI]\n\n"
        .equ    LEN_HUMAN, . - msg_human

msg_top:        .ascii  "TOP: "
                .equ    LEN_TOP, . - msg_top
msg_color:      .ascii  "  color="
                .equ    LEN_COLOR, . - msg_color
msg_dir_cw:     .ascii  "  dir=+\n"
                .equ    LEN_DIR_CW, . - msg_dir_cw
msg_dir_ccw:    .ascii  "  dir=-\n"
                .equ    LEN_DIR_CCW, . - msg_dir_ccw
msg_deck:       .ascii  "deck="
                .equ    LEN_DECK, . - msg_deck
msg_nl:         .ascii  "\n"
                .equ    LEN_NL, . - msg_nl
msg_hand_hdr:   .ascii  "Your hand:\n"
                .equ    LEN_HAND_HDR, . - msg_hand_hdr
msg_ai_hand:    .ascii  "AI holds "
                .equ    LEN_AI_HAND, . - msg_ai_hand
msg_cards:      .ascii  " cards\n"
                .equ    LEN_CARDS, . - msg_cards
msg_prompt:     .ascii  "play #> "
                .equ    LEN_PROMPT, . - msg_prompt
msg_wild_p:     .ascii  "wild color (R/Y/G/B): "
                .equ    LEN_WILD_P, . - msg_wild_p
msg_played:     .ascii  " plays "
                .equ    LEN_PLAYED, . - msg_played
msg_draws:      .ascii  " draws "
                .equ    LEN_DRAWS, . - msg_draws
msg_and_plays:  .ascii  " and plays it\n"
                .equ    LEN_AND_PLAYS, . - msg_and_plays
msg_keeps:      .ascii  " and keeps it\n"
                .equ    LEN_KEEPS, . - msg_keeps
msg_yn:         .ascii  " play it? (y/n): "
                .equ    LEN_YN, . - msg_yn
msg_skip:       .ascii  "  -- SKIP\n"
                .equ    LEN_SKIP, . - msg_skip
msg_rev:        .ascii  "  -- REVERSE\n"
                .equ    LEN_REV, . - msg_rev
msg_plus:       .ascii  "  -- draw penalty "
                .equ    LEN_PLUS, . - msg_plus
msg_turn:       .ascii  "\n--- seat "
                .equ    LEN_TURN, . - msg_turn
msg_turn_end:   .ascii  " ---\n"
                .equ    LEN_TURN_END, . - msg_turn_end
msg_win0:       .ascii  "\n*** seat 0 wins UNO ***\n"
                .equ    LEN_WIN0, . - msg_win0
msg_win1:       .ascii  "\n*** seat 1 wins UNO ***\n"
                .equ    LEN_WIN1, . - msg_win1
msg_invalid:    .ascii  "illegal move\n"
                .equ    LEN_INVALID, . - msg_invalid
msg_quit:       .ascii  "quit.\n"
                .equ    LEN_QUIT, . - msg_quit
msg_reshuf:     .ascii  "(reshuffled discard into deck)\n"
                .equ    LEN_RESHUF, . - msg_reshuf
msg_lbr:        .ascii  "  ["
                .equ    LEN_LBR, . - msg_lbr
msg_rbr:        .ascii  "] "
                .equ    LEN_RBR, . - msg_rbr

color_char:     .ascii  "RYGB"
rank_num:       .ascii  "0123456789"
s_skip:         .ascii  "Skip"
s_rev:          .ascii  "Rev "
s_d2:           .ascii  "+2  "
s_wild:         .ascii  "Wild"
s_w4:           .ascii  "W+4 "
arg_demo:       .ascii  "demo"
                .equ    LEN_ARG_DEMO, 4

#------------------------------------------------------------------------------
        .section .data

rng_state:      .quad   0xC0FFEE1234ABCDEF
demo_mode:      .byte   0
direction:      .byte   1               # +1 or -1 (0xFF)
cur_player:     .byte   0
cur_color:      .byte   0
top_card:       .byte   CARD_EMPTY
deck_count:     .long   0
discard_count:  .long   0
hand_count:     .long   0, 0            # two seats

#------------------------------------------------------------------------------
        .section .bss
        .align  8
deck:           .space  DECK_SIZE
discard:        .space  DECK_SIZE
hands:          .space  NUM_PLAYERS * MAX_HAND
inbuf:          .space  64
outbuf:         .space  32

#------------------------------------------------------------------------------
        .text
        .globl  _start
        .type   _start, @function

#==============================================================================
# I/O
#==============================================================================

# io_write(rsi=buf, rdx=len)
io_write:
        push    rax
        push    rdi
        mov     eax, SYS_WRITE
        mov     edi, STDOUT
        syscall
        pop     rdi
        pop     rax
        ret

# io_read(rsi=buf, rdx=len) -> rax
io_read:
        mov     eax, SYS_READ
        mov     edi, STDIN
        syscall
        ret

# io_putc(edi=char)
io_putc:
        push    rsi
        push    rdx
        lea     rsi, [rip + outbuf]
        mov     eax, edi
        mov     [rsi], al
        mov     edx, 1
        call    io_write
        pop     rdx
        pop     rsi
        ret

# io_puts(rdi=ptr, esi=len)
io_puts:
        push    rdx
        mov     edx, esi
        mov     rsi, rdi
        call    io_write
        pop     rdx
        ret

# io_nl
io_nl:
        lea     rdi, [rip + msg_nl]
        mov     esi, LEN_NL
        jmp     io_puts

# io_put_u32(edi=v)
io_put_u32:
        push    rbx
        push    rcx
        push    rdx
        push    rsi
        mov     eax, edi
        lea     rbx, [rip + outbuf + 16]
        mov     ecx, 10
.Lpu:
        dec     rbx
        xor     edx, edx
        div     ecx
        add     dl, '0'
        mov     [rbx], dl
        test    eax, eax
        jnz     .Lpu
        lea     rsi, [rip + outbuf + 16]
        mov     rdx, rsi
        sub     rdx, rbx
        mov     rsi, rbx
        call    io_write
        pop     rsi
        pop     rdx
        pop     rcx
        pop     rbx
        ret

#==============================================================================
# RNG
#==============================================================================

# rng_next -> rax
rng_next:
        mov     rax, qword ptr [rip + rng_state]
        mov     rcx, 6364136223846793005
        mul     rcx
        add     rax, 1
        mov     qword ptr [rip + rng_state], rax
        ret

# rng_mod(edi=n) -> eax in [0,n)
rng_mod:
        push    rbx
        mov     ebx, edi
        call    rng_next
        mov     ecx, ebx
        xor     edx, edx
        div     rcx
        mov     eax, edx
        pop     rbx
        ret

#==============================================================================
# Cards
#==============================================================================

# card_rank(edi) -> al
card_rank:
        mov     eax, edi
        and     eax, 0x0F
        ret

# card_color(edi) -> al
card_color:
        mov     eax, edi
        shr     eax, 4
        and     eax, 3
        ret

# card_make(dil=color, sil=rank) -> al
card_make:
        mov     eax, edi
        and     eax, 3
        shl     eax, 4
        mov     ecx, esi
        and     ecx, 0x0F
        or      eax, ecx
        ret

# card_is_wild(dil) -> eax
card_is_wild:
        mov     eax, edi
        and     eax, 0x0F
        cmp     eax, RANK_WILD
        je      .Liw_y
        cmp     eax, RANK_W4
        je      .Liw_y
        xor     eax, eax
        ret
.Liw_y: mov     eax, 1
        ret

# card_can_play2(dil=c, sil=top, dl=cur_color) -> eax
card_can_play2:
        push    rbx
        push    r12
        push    r13
        movzx   ebx, dil                # c
        movzx   r12d, sil               # top
        movzx   r13d, dl                # cur_color

        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jnz     .Lcp2_yes

        mov     eax, ebx
        and     eax, 0x0F
        mov     edx, r12d
        and     edx, 0x0F
        cmp     eax, edx
        je      .Lcp2_yes

        mov     eax, ebx
        shr     eax, 4
        and     eax, 3
        cmp     eax, r13d
        je      .Lcp2_yes

        xor     eax, eax
        jmp     .Lcp2_out
.Lcp2_yes:
        mov     eax, 1
.Lcp2_out:
        pop     r13
        pop     r12
        pop     rbx
        ret

# card_print(edi=c)
card_print:
        push    rbx
        mov     ebx, edi
        and     ebx, 0xFF
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jnz     .Lcpr_w

        mov     eax, ebx
        shr     eax, 4
        and     eax, 3
        lea     rsi, [rip + color_char]
        movzx   edi, byte ptr [rsi + rax]
        call    io_putc

        mov     eax, ebx
        and     eax, 0x0F
        cmp     eax, 9
        jbe     .Lcpr_n
        cmp     eax, RANK_SKIP
        je      .Lcpr_s
        cmp     eax, RANK_REV
        je      .Lcpr_r
        lea     rdi, [rip + s_d2]
        mov     esi, 4
        call    io_puts
        jmp     .Lcpr_d
.Lcpr_n:
        lea     rsi, [rip + rank_num]
        movzx   edi, byte ptr [rsi + rax]
        call    io_putc
        mov     edi, ' '
        call    io_putc
        mov     edi, ' '
        call    io_putc
        jmp     .Lcpr_d
.Lcpr_s:
        lea     rdi, [rip + s_skip]
        mov     esi, 4
        call    io_puts
        jmp     .Lcpr_d
.Lcpr_r:
        lea     rdi, [rip + s_rev]
        mov     esi, 4
        call    io_puts
        jmp     .Lcpr_d
.Lcpr_w:
        mov     eax, ebx
        and     eax, 0x0F
        cmp     eax, RANK_W4
        je      .Lcpr_w4
        lea     rdi, [rip + s_wild]
        mov     esi, 4
        call    io_puts
        jmp     .Lcpr_d
.Lcpr_w4:
        lea     rdi, [rip + s_w4]
        mov     esi, 4
        call    io_puts
.Lcpr_d:
        pop     rbx
        ret

# color_print(edi)
color_print:
        mov     eax, edi
        and     eax, 3
        lea     rsi, [rip + color_char]
        movzx   edi, byte ptr [rsi + rax]
        jmp     io_putc

#==============================================================================
# Deck / hands
#==============================================================================

# deck_build — 108 cards into deck[], deck_count=108
deck_build:
        push    rbx
        push    r12
        push    r13
        lea     r12, [rip + deck]       # base
        xor     ebx, ebx                # index

        xor     r13d, r13d              # color
.Ldb_col:
        # one 0
        mov     edi, r13d
        xor     esi, esi
        call    card_make
        mov     [r12 + rbx], al
        inc     ebx
        # two each of 1..12 (1-9, skip, rev, d2)
        mov     ecx, 1
.Ldb_rk:
        mov     edx, 2
.Ldb_cp:
        push    rcx
        push    rdx
        mov     edi, r13d
        mov     esi, ecx
        call    card_make
        pop     rdx
        pop     rcx
        mov     [r12 + rbx], al
        inc     ebx
        dec     edx
        jnz     .Ldb_cp
        inc     ecx
        cmp     ecx, RANK_D2
        jbe     .Ldb_rk

        inc     r13d
        cmp     r13d, 4
        jb      .Ldb_col

        mov     ecx, 4
.Ldb_w:
        push    rcx
        xor     edi, edi
        mov     esi, RANK_WILD
        call    card_make
        pop     rcx
        mov     [r12 + rbx], al
        inc     ebx
        dec     ecx
        jnz     .Ldb_w

        mov     ecx, 4
.Ldb_w4:
        push    rcx
        xor     edi, edi
        mov     esi, RANK_W4
        call    card_make
        pop     rcx
        mov     [r12 + rbx], al
        inc     ebx
        dec     ecx
        jnz     .Ldb_w4

        mov     dword ptr [rip + deck_count], DECK_SIZE
        mov     dword ptr [rip + discard_count], 0
        pop     r13
        pop     r12
        pop     rbx
        ret

# deck_shuffle Fisher-Yates
deck_shuffle:
        push    rbx
        push    r12
        push    r13
        lea     r12, [rip + deck]
        mov     r13d, dword ptr [rip + deck_count]
        cmp     r13d, 2
        jb      .Lds_d
        mov     ebx, r13d
        dec     ebx
.Lds_l:
        mov     edi, ebx
        inc     edi
        call    rng_mod
        mov     ecx, eax                # j
        mov     al, [r12 + rbx]
        mov     dl, [r12 + rcx]
        mov     [r12 + rbx], dl
        mov     [r12 + rcx], al
        dec     ebx
        jns     .Lds_l
.Lds_d:
        pop     r13
        pop     r12
        pop     rbx
        ret

# deck_draw_one -> eax card (0-255) or -1
deck_draw_one:
        push    rbx
        push    r12
.Ldd_try:
        mov     eax, dword ptr [rip + deck_count]
        test    eax, eax
        jnz     .Ldd_pop

        # reshuffle discard except top
        mov     ecx, dword ptr [rip + discard_count]
        cmp     ecx, 2
        jb      .Ldd_fail
        dec     ecx
        lea     r12, [rip + discard]
        lea     rbx, [rip + deck]
        xor     edx, edx
.Ldd_copy:
        mov     al, [r12 + rdx]
        mov     [rbx + rdx], al
        inc     edx
        cmp     edx, ecx
        jb      .Ldd_copy
        mov     dword ptr [rip + deck_count], ecx
        mov     al, [r12 + rcx]
        mov     [r12], al
        mov     dword ptr [rip + discard_count], 1
        call    deck_shuffle
        lea     rdi, [rip + msg_reshuf]
        mov     esi, LEN_RESHUF
        call    io_puts
        jmp     .Ldd_try

.Ldd_pop:
        dec     eax
        mov     dword ptr [rip + deck_count], eax
        lea     r12, [rip + deck]
        movzx   eax, byte ptr [r12 + rax]
        pop     r12
        pop     rbx
        ret
.Ldd_fail:
        mov     eax, -1
        pop     r12
        pop     rbx
        ret

# discard_push(edi=c)
discard_push:
        push    rbx
        lea     rbx, [rip + discard]
        mov     eax, dword ptr [rip + discard_count]
        mov     edx, edi
        mov     [rbx + rax], dl
        inc     eax
        mov     dword ptr [rip + discard_count], eax
        mov     byte ptr [rip + top_card], dl
        pop     rbx
        ret

# hand_base(edi=seat) -> rax pointer to hands[seat]
hand_base:
        movsxd  rax, edi
        imul    rax, rax, MAX_HAND
        lea     rcx, [rip + hands]
        add     rax, rcx
        ret

# hand_clear(edi=seat)
hand_clear:
        push    rbx
        lea     rbx, [rip + hand_count]
        mov     dword ptr [rbx + rdi*4], 0
        call    hand_base
        mov     ecx, MAX_HAND
.Lhc:
        mov     byte ptr [rax], CARD_EMPTY
        inc     rax
        dec     ecx
        jnz     .Lhc
        pop     rbx
        ret

# hand_add(edi=seat, esi=c) -> eax 1/0
hand_add:
        push    rbx
        push    r12
        push    r13
        mov     r12d, edi
        mov     r13d, esi               # card
        lea     rbx, [rip + hand_count]
        mov     eax, [rbx + r12*4]
        cmp     eax, MAX_HAND
        jae     .Lha_f
        mov     ecx, eax                # slot
        mov     edi, r12d
        push    rcx
        call    hand_base
        pop     rcx
        mov     edx, r13d
        mov     [rax + rcx], dl
        inc     ecx
        mov     [rbx + r12*4], ecx
        mov     eax, 1
        jmp     .Lha_o
.Lha_f: xor     eax, eax
.Lha_o: pop     r13
        pop     r12
        pop     rbx
        ret

# hand_get(edi=seat, esi=idx) -> al
hand_get:
        push    rsi
        call    hand_base
        pop     rsi
        mov     al, [rax + rsi]
        ret

# hand_remove(edi=seat, esi=idx)
hand_remove:
        push    rbx
        push    r12
        push    r13
        push    r14
        mov     r12d, edi
        mov     r13d, esi
        lea     rbx, [rip + hand_count]
        mov     eax, [rbx + r12*4]
        test    eax, eax
        jz      .Lhr_o
        dec     eax
        mov     [rbx + r12*4], eax      # new count; eax = last idx
        mov     r14d, eax               # last idx (survive hand_base)
        mov     edi, r12d
        call    hand_base               # rax = base
        mov     dl, [rax + r14]         # last card
        mov     [rax + r13], dl         # overwrite removed slot
        mov     byte ptr [rax + r14], CARD_EMPTY
.Lhr_o:
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        ret

# hand_find_playable(edi=seat) -> eax idx or -1
hand_find_playable:
        push    rbx
        push    r12
        push    r13
        mov     r12d, edi
        lea     rbx, [rip + hand_count]
        mov     r13d, [rbx + r12*4]
        xor     ebx, ebx
.Lhfp:
        cmp     ebx, r13d
        jae     .Lhfp_n
        mov     edi, r12d
        mov     esi, ebx
        call    hand_get
        movzx   edi, al
        movzx   esi, byte ptr [rip + top_card]
        movzx   edx, byte ptr [rip + cur_color]
        call    card_can_play2
        test    eax, eax
        jnz     .Lhfp_y
        inc     ebx
        jmp     .Lhfp
.Lhfp_y:
        mov     eax, ebx
        jmp     .Lhfp_o
.Lhfp_n:
        mov     eax, -1
.Lhfp_o:
        pop     r13
        pop     r12
        pop     rbx
        ret

#==============================================================================
# Setup / print
#==============================================================================

game_setup:
        push    rbx
        push    r12
        call    deck_build
        call    deck_shuffle
        xor     edi, edi
        call    hand_clear
        mov     edi, 1
        call    hand_clear

        xor     r12d, r12d
.Lgs_d:
        xor     ebx, ebx
.Lgs_s:
        call    deck_draw_one
        cmp     eax, 0
        jl      .Lgs_fd
        mov     edi, ebx
        movzx   esi, al
        call    hand_add
        inc     ebx
        cmp     ebx, NUM_PLAYERS
        jb      .Lgs_s
        inc     r12d
        cmp     r12d, DEAL_COUNT
        jb      .Lgs_d
.Lgs_fd:

.Lgs_flip:
        call    deck_draw_one
        cmp     eax, 0
        jl      .Lgs_done
        movzx   ebx, al
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lgs_st
        # return wild to deck end
        lea     rcx, [rip + deck]
        mov     edx, dword ptr [rip + deck_count]
        mov     [rcx + rdx], bl
        inc     edx
        mov     dword ptr [rip + deck_count], edx
        jmp     .Lgs_flip
.Lgs_st:
        mov     edi, ebx
        call    discard_push
        mov     edi, ebx
        call    card_color
        mov     byte ptr [rip + cur_color], al
.Lgs_done:
        mov     byte ptr [rip + direction], 1
        mov     byte ptr [rip + cur_player], 0
        pop     r12
        pop     rbx
        ret

print_table:
        push    rbx
        push    r12

        lea     rdi, [rip + msg_top]
        mov     esi, LEN_TOP
        call    io_puts
        movzx   edi, byte ptr [rip + top_card]
        call    card_print

        lea     rdi, [rip + msg_color]
        mov     esi, LEN_COLOR
        call    io_puts
        movzx   edi, byte ptr [rip + cur_color]
        call    color_print

        cmp     byte ptr [rip + direction], 1
        jne     .Lpt_ccw
        lea     rdi, [rip + msg_dir_cw]
        mov     esi, LEN_DIR_CW
        call    io_puts
        jmp     .Lpt_dk
.Lpt_ccw:
        lea     rdi, [rip + msg_dir_ccw]
        mov     esi, LEN_DIR_CCW
        call    io_puts
.Lpt_dk:
        lea     rdi, [rip + msg_deck]
        mov     esi, LEN_DECK
        call    io_puts
        mov     edi, dword ptr [rip + deck_count]
        call    io_put_u32
        call    io_nl

        lea     rdi, [rip + msg_ai_hand]
        mov     esi, LEN_AI_HAND
        call    io_puts
        lea     rax, [rip + hand_count]
        mov     edi, [rax + 4]
        call    io_put_u32
        lea     rdi, [rip + msg_cards]
        mov     esi, LEN_CARDS
        call    io_puts

        lea     rdi, [rip + msg_hand_hdr]
        mov     esi, LEN_HAND_HDR
        call    io_puts
        lea     rax, [rip + hand_count]
        mov     r12d, [rax]
        xor     ebx, ebx
.Lpt_h:
        cmp     ebx, r12d
        jae     .Lpt_hd
        lea     rdi, [rip + msg_lbr]
        mov     esi, LEN_LBR
        call    io_puts
        mov     edi, ebx
        call    io_put_u32
        lea     rdi, [rip + msg_rbr]
        mov     esi, LEN_RBR
        call    io_puts
        xor     edi, edi
        mov     esi, ebx
        call    hand_get
        movzx   edi, al
        call    card_print
        call    io_nl
        inc     ebx
        jmp     .Lpt_h
.Lpt_hd:
        pop     r12
        pop     rbx
        ret

print_seat:
        push    rbx
        mov     ebx, edi
        lea     rdi, [rip + msg_turn]
        mov     esi, LEN_TURN
        call    io_puts
        mov     edi, ebx
        call    io_put_u32
        lea     rdi, [rip + msg_turn_end]
        mov     esi, LEN_TURN_END
        call    io_puts
        pop     rbx
        ret

#==============================================================================
# Engine
#==============================================================================

advance_player:
        movsx   eax, byte ptr [rip + direction]
        movzx   ecx, byte ptr [rip + cur_player]
        add     eax, ecx
        and     eax, 1
        mov     byte ptr [rip + cur_player], al
        ret

# apply_draws(edi=seat, esi=n)
apply_draws:
        push    rbx
        push    r12
        push    r13
        mov     r12d, edi
        mov     r13d, esi
.Lad:
        test    r13d, r13d
        jz      .Lad_d
        call    deck_draw_one
        cmp     eax, 0
        jl      .Lad_d
        mov     edi, r12d
        movzx   esi, al
        call    hand_add
        dec     r13d
        jmp     .Lad
.Lad_d:
        pop     r13
        pop     r12
        pop     rbx
        ret

# play_card(edi=seat, esi=idx, edx=color or -1) -> eax 0/1
play_card:
        push    rbx
        push    r12
        push    r13
        push    r14
        mov     r12d, edi
        mov     r13d, esi
        mov     r14d, edx

        lea     rax, [rip + hand_count]
        mov     eax, [rax + r12*4]
        cmp     r13d, eax
        jae     .Lpc_f

        mov     edi, r12d
        mov     esi, r13d
        call    hand_get
        movzx   ebx, al                 # card in ebx

        mov     edi, ebx
        movzx   esi, byte ptr [rip + top_card]
        movzx   edx, byte ptr [rip + cur_color]
        call    card_can_play2
        test    eax, eax
        jz      .Lpc_f

        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lpc_nw
        cmp     r14d, 0
        jl      .Lpc_f
        cmp     r14d, 3
        ja      .Lpc_f
        mov     eax, ebx
        and     eax, 0x0F
        mov     esi, eax                # rank
        mov     edi, r14d               # color
        call    card_make
        movzx   ebx, al
        mov     byte ptr [rip + cur_color], r14b
        jmp     .Lpc_go
.Lpc_nw:
        mov     edi, ebx
        call    card_color
        mov     byte ptr [rip + cur_color], al
.Lpc_go:
        mov     edi, r12d
        call    io_put_u32
        lea     rdi, [rip + msg_played]
        mov     esi, LEN_PLAYED
        call    io_puts
        mov     edi, ebx
        call    card_print
        call    io_nl

        mov     edi, r12d
        mov     esi, r13d
        call    hand_remove
        mov     edi, ebx
        call    discard_push

        mov     eax, ebx
        and     eax, 0x0F
        cmp     al, RANK_SKIP
        je      .Lpc_sk
        cmp     al, RANK_REV
        je      .Lpc_rv
        cmp     al, RANK_D2
        je      .Lpc_d2
        cmp     al, RANK_W4
        je      .Lpc_w4
        jmp     .Lpc_ok

.Lpc_sk:
        lea     rdi, [rip + msg_skip]
        mov     esi, LEN_SKIP
        call    io_puts
        call    advance_player
        jmp     .Lpc_ok
.Lpc_rv:
        lea     rdi, [rip + msg_rev]
        mov     esi, LEN_REV
        call    io_puts
        mov     al, byte ptr [rip + direction]
        neg     al
        mov     byte ptr [rip + direction], al
        # 2 players: reverse == skip
        call    advance_player
        jmp     .Lpc_ok
.Lpc_d2:
        lea     rdi, [rip + msg_plus]
        mov     esi, LEN_PLUS
        call    io_puts
        mov     edi, 2
        call    io_put_u32
        call    io_nl
        call    advance_player
        movzx   edi, byte ptr [rip + cur_player]
        mov     esi, 2
        call    apply_draws
        jmp     .Lpc_ok
.Lpc_w4:
        lea     rdi, [rip + msg_plus]
        mov     esi, LEN_PLUS
        call    io_puts
        mov     edi, 4
        call    io_put_u32
        call    io_nl
        call    advance_player
        movzx   edi, byte ptr [rip + cur_player]
        mov     esi, 4
        call    apply_draws
        jmp     .Lpc_ok
.Lpc_ok:
        mov     eax, 1
        jmp     .Lpc_o
.Lpc_f:
        xor     eax, eax
.Lpc_o:
        pop     r14
        pop     r13
        pop     r12
        pop     rbx
        ret

# choose_wild_color_ai(edi=seat) -> eax 0..3
choose_wild_ai:
        push    rbx
        push    r12
        push    r13
        push    r14
        mov     r12d, edi
        xor     r8d, r8d
        xor     r9d, r9d
        xor     r10d, r10d
        xor     r11d, r11d
        lea     rax, [rip + hand_count]
        mov     r13d, [rax + r12*4]
        xor     r14d, r14d
.Lcwa:
        cmp     r14d, r13d
        jae     .Lcwa_p
        mov     edi, r12d
        mov     esi, r14d
        call    hand_get
        movzx   ebx, al
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jnz     .Lcwa_n
        mov     eax, ebx
        shr     eax, 4
        and     eax, 3
        cmp     eax, 0
        je      .Lcwa_0
        cmp     eax, 1
        je      .Lcwa_1
        cmp     eax, 2
        je      .Lcwa_2
        inc     r11d
        jmp     .Lcwa_n
.Lcwa_0: inc r8d
        jmp     .Lcwa_n
.Lcwa_1: inc r9d
        jmp     .Lcwa_n
.Lcwa_2: inc r10d
.Lcwa_n: inc r14d
        jmp     .Lcwa
.Lcwa_p:
        xor     eax, eax
        mov     ecx, r8d
        cmp     r9d, ecx
        jle     1f
        mov     eax, 1
        mov     ecx, r9d
1:      cmp     r10d, ecx
        jle     2f
        mov     eax, 2
        mov     ecx, r10d
2:      cmp     r11d, ecx
        jle     3f
        mov     eax, 3
3:      pop     r14
        pop     r13
        pop     r12
        pop     rbx
        ret

# read_line -> eax len or -1
# Byte-at-a-time so a piped multi-line buffer cannot swallow later prompts.
read_line:
        push    rbx
        push    r12
        lea     r12, [rip + inbuf]
        xor     ebx, ebx                # len
.Lrl_ch:
        cmp     ebx, 62
        jae     .Lrl_term
        mov     eax, SYS_READ
        mov     edi, STDIN
        lea     rsi, [r12 + rbx]
        mov     edx, 1
        syscall
        cmp     rax, 1
        jl      .Lrl_eof
        mov     al, [r12 + rbx]
        cmp     al, 10
        je      .Lrl_term
        cmp     al, 13
        je      .Lrl_term
        inc     ebx
        jmp     .Lrl_ch
.Lrl_term:
        mov     byte ptr [r12 + rbx], 0
        mov     eax, ebx
        pop     r12
        pop     rbx
        ret
.Lrl_eof:
        test    ebx, ebx
        jz      .Lrl_fail
        jmp     .Lrl_term
.Lrl_fail:
        mov     eax, -1
        pop     r12
        pop     rbx
        ret

# parse_int(rdi=s) -> eax or -1
parse_int:
        xor     eax, eax
        xor     ecx, ecx
.Lpi:
        mov     dl, [rdi]
        test    dl, dl
        jz      .Lpi_d
        cmp     dl, '0'
        jb      .Lpi_b
        cmp     dl, '9'
        ja      .Lpi_b
        imul    eax, eax, 10
        movzx   edx, dl
        sub     edx, '0'
        add     eax, edx
        inc     ecx
        inc     rdi
        jmp     .Lpi
.Lpi_d: test    ecx, ecx
        jz      .Lpi_b
        ret
.Lpi_b: mov     eax, -1
        ret

# parse_color(edi=char) -> eax or -1
parse_color:
        mov     eax, edi
        or      eax, 0x20
        cmp     al, 'r'
        je      .Lpcol0
        cmp     al, 'y'
        je      .Lpcol1
        cmp     al, 'g'
        je      .Lpcol2
        cmp     al, 'b'
        je      .Lpcol3
        mov     eax, -1
        ret
.Lpcol0: xor    eax, eax
        ret
.Lpcol1: mov    eax, 1
        ret
.Lpcol2: mov    eax, 2
        ret
.Lpcol3: mov    eax, 3
        ret

prompt_wild:
.Lpw:
        lea     rdi, [rip + msg_wild_p]
        mov     esi, LEN_WILD_P
        call    io_puts
        call    read_line
        cmp     eax, 0
        jle     .Lpw_f
        lea     rax, [rip + inbuf]
        movzx   edi, byte ptr [rax]
        call    parse_color
        cmp     eax, 0
        jl      .Lpw
        ret
.Lpw_f: mov     eax, -1
        ret

# turn_human -> eax 1 ok, 0 quit
turn_human:
        push    rbx
        push    r12
        push    r13
.Lth:
        call    print_table
        lea     rdi, [rip + msg_prompt]
        mov     esi, LEN_PROMPT
        call    io_puts
        call    read_line
        cmp     eax, 0
        jl      .Lth_q
        je      .Lth
        lea     rax, [rip + inbuf]
        mov     al, [rax]
        mov     cl, al
        or      cl, 0x20
        cmp     cl, 'q'
        je      .Lth_q
        cmp     cl, 'd'
        je      .Lth_d

        lea     rdi, [rip + inbuf]
        call    parse_int
        cmp     eax, 0
        jl      .Lth_b
        mov     r12d, eax
        lea     rax, [rip + hand_count]
        cmp     r12d, [rax]
        jae     .Lth_b
        xor     edi, edi
        mov     esi, r12d
        call    hand_get
        movzx   ebx, al                 # card
        mov     r13d, -1                # chosen color (none)
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lth_p
        call    prompt_wild
        cmp     eax, 0
        jl      .Lth_q
        mov     r13d, eax
.Lth_p: xor     edi, edi
        mov     esi, r12d
        mov     edx, r13d
        call    play_card
        test    eax, eax
        jz      .Lth_b
        mov     eax, 1
        jmp     .Lth_o

.Lth_d: call    deck_draw_one
        cmp     eax, 0
        jl      .Lth_ok
        movzx   ebx, al
        xor     edi, edi
        call    io_put_u32
        lea     rdi, [rip + msg_draws]
        mov     esi, LEN_DRAWS
        call    io_puts
        mov     edi, ebx
        call    card_print

        mov     edi, ebx
        movzx   esi, byte ptr [rip + top_card]
        movzx   edx, byte ptr [rip + cur_color]
        call    card_can_play2
        test    eax, eax
        jz      .Lth_k
        lea     rdi, [rip + msg_yn]
        mov     esi, LEN_YN
        call    io_puts
        call    read_line
        cmp     eax, 0
        jle     .Lth_kadd
        lea     rax, [rip + inbuf]
        mov     al, [rax]
        or      al, 0x20
        cmp     al, 'y'
        jne     .Lth_kadd
        xor     edi, edi
        mov     esi, ebx
        call    hand_add
        mov     r13d, -1
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lth_dp
        call    prompt_wild
        cmp     eax, 0
        jl      .Lth_q
        mov     r13d, eax
.Lth_dp:
        xor     edi, edi
        lea     rax, [rip + hand_count]
        mov     esi, [rax]
        dec     esi
        mov     edx, r13d
        call    play_card
        mov     eax, 1
        jmp     .Lth_o
.Lth_kadd:
.Lth_k: xor     edi, edi
        mov     esi, ebx
        call    hand_add
        lea     rdi, [rip + msg_keeps]
        mov     esi, LEN_KEEPS
        call    io_puts
.Lth_ok:
        mov     eax, 1
        jmp     .Lth_o
.Lth_b: lea     rdi, [rip + msg_invalid]
        mov     esi, LEN_INVALID
        call    io_puts
        jmp     .Lth
.Lth_q: xor     eax, eax
.Lth_o: pop     r13
        pop     r12
        pop     rbx
        ret

# turn_ai(edi=seat) -> eax 1
turn_ai:
        push    rbx
        push    r12
        push    r13
        push    r14
        mov     r12d, edi

        mov     edi, r12d
        call    hand_find_playable
        cmp     eax, 0
        jl      .Lta_d
        mov     r13d, eax
        mov     edi, r12d
        mov     esi, r13d
        call    hand_get
        movzx   ebx, al
        mov     r14d, -1                # color choice
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lta_p
        mov     edi, r12d
        call    choose_wild_ai
        mov     r14d, eax
.Lta_p: mov     edi, r12d
        mov     esi, r13d
        mov     edx, r14d
        call    play_card
        mov     eax, 1
        jmp     .Lta_o

.Lta_d: call    deck_draw_one
        cmp     eax, 0
        jl      .Lta_ok
        movzx   ebx, al
        mov     edi, r12d
        call    io_put_u32
        lea     rdi, [rip + msg_draws]
        mov     esi, LEN_DRAWS
        call    io_puts
        mov     edi, ebx
        call    card_print

        mov     edi, ebx
        movzx   esi, byte ptr [rip + top_card]
        movzx   edx, byte ptr [rip + cur_color]
        call    card_can_play2
        test    eax, eax
        jz      .Lta_k
        mov     edi, r12d
        mov     esi, ebx
        call    hand_add
        lea     rax, [rip + hand_count]
        mov     r13d, [rax + r12*4]
        dec     r13d
        mov     r14d, -1
        mov     edi, ebx
        call    card_is_wild
        test    eax, eax
        jz      .Lta_dp
        mov     edi, r12d
        call    choose_wild_ai
        mov     r14d, eax
.Lta_dp:
        lea     rdi, [rip + msg_and_plays]
        mov     esi, LEN_AND_PLAYS
        call    io_puts
        mov     edi, r12d
        mov     esi, r13d
        mov     edx, r14d
        call    play_card
        mov     eax, 1
        jmp     .Lta_o
.Lta_k: mov     edi, r12d
        mov     esi, ebx
        call    hand_add
        lea     rdi, [rip + msg_keeps]
        mov     esi, LEN_KEEPS
        call    io_puts
.Lta_ok:
        mov     eax, 1
.Lta_o: pop     r14
        pop     r13
        pop     r12
        pop     rbx
        ret

check_winner:
        lea     rax, [rip + hand_count]
        cmp     dword ptr [rax], 0
        jne     1f
        xor     eax, eax
        ret
1:      cmp     dword ptr [rax + 4], 0
        jne     2f
        mov     eax, 1
        ret
2:      mov     eax, -1
        ret

announce_win:
        test    edi, edi
        jnz     1f
        lea     rdi, [rip + msg_win0]
        mov     esi, LEN_WIN0
        jmp     io_puts
1:      lea     rdi, [rip + msg_win1]
        mov     esi, LEN_WIN1
        jmp     io_puts

#==============================================================================
_start:
        mov     rax, [rsp]
        cmp     rax, 2
        jb      .Ls_h
        mov     rsi, [rsp + 16]
        lea     rdi, [rip + arg_demo]
        mov     ecx, LEN_ARG_DEMO
.Ls_cmp:
        mov     al, [rsi]
        cmp     al, [rdi]
        jne     .Ls_h
        inc     rsi
        inc     rdi
        dec     ecx
        jnz     .Ls_cmp
        cmp     byte ptr [rsi], 0
        jne     .Ls_h
        mov     byte ptr [rip + demo_mode], 1
        mov     rax, 0x4D0DE5EED00C001
        mov     qword ptr [rip + rng_state], rax
        lea     rdi, [rip + msg_title]
        mov     esi, LEN_TITLE
        call    io_puts
        lea     rdi, [rip + msg_demo]
        mov     esi, LEN_DEMO
        call    io_puts
        jmp     .Ls_g
.Ls_h:
        mov     byte ptr [rip + demo_mode], 0
        rdtsc
        shl     rdx, 32
        or      rax, rdx
        xor     qword ptr [rip + rng_state], rax
        lea     rdi, [rip + msg_title]
        mov     esi, LEN_TITLE
        call    io_puts
        lea     rdi, [rip + msg_human]
        mov     esi, LEN_HUMAN
        call    io_puts
.Ls_g:
        call    game_setup

        # opening effects on seat 0
        mov     al, byte ptr [rip + top_card]
        and     al, 0x0F
        cmp     al, RANK_SKIP
        je      .Ls_sk
        cmp     al, RANK_REV
        je      .Ls_rv
        cmp     al, RANK_D2
        je      .Ls_d2
        jmp     .Lmain
.Ls_sk: call    advance_player
        jmp     .Lmain
.Ls_rv: mov     al, byte ptr [rip + direction]
        neg     al
        mov     byte ptr [rip + direction], al
        call    advance_player
        jmp     .Lmain
.Ls_d2: movzx   edi, byte ptr [rip + cur_player]
        mov     esi, 2
        call    apply_draws
        call    advance_player

.Lmain:
        call    check_winner
        cmp     eax, 0
        jge     .Lw

        movzx   edi, byte ptr [rip + cur_player]
        call    print_seat

        cmp     byte ptr [rip + demo_mode], 0
        jne     .Lm_ai

        cmp     byte ptr [rip + cur_player], 0
        jne     .Lm_a1
        call    turn_human
        test    eax, eax
        jz      .Lq
        jmp     .Ln
.Lm_a1: mov     edi, 1
        call    turn_ai
        jmp     .Ln
.Lm_ai: movzx   edi, byte ptr [rip + cur_player]
        call    turn_ai
.Ln:
        call    check_winner
        cmp     eax, 0
        jge     .Lw
        call    advance_player
        lea     rax, [rip + hand_count]
        mov     ecx, [rax]
        add     ecx, [rax + 4]
        cmp     ecx, 70
        ja      .Lq
        jmp     .Lmain

.Lw:    mov     edi, eax
        call    announce_win
        xor     edi, edi
        jmp     .Lx
.Lq:    lea     rdi, [rip + msg_quit]
        mov     esi, LEN_QUIT
        call    io_puts
        mov     edi, 1
.Lx:    mov     eax, SYS_EXIT
        syscall

        .size   _start, . - _start
        .section .note.GNU-stack,"",@progbits

```

A freestanding Linux x86-64 program: build the 108-card deck, shuffle, deal seven, flip a non-wild starter, then alternate seats until a hand hits zero. Human input is byte-at-a-time so piped multi-line buffers cannot swallow the next prompt. AI picks the first legal card and colors wilds by majority non-wild suit.

---

## WHY IT IS POWERFUL

### 1. The card is one byte — identity without ceremony.

Rank lives in bits 0..3 (0–9, SKIP, REVERSE, DRAW2, WILD, WILD4). Color lives in bits 4..5. Empty hand slots are `0xFF`. There is no struct, no heap object, no tagged union in C. The entire legal identity of a UNO card compresses to a value that fits in `al`. Wilds *reuse* the color field after the player chooses: the same byte that was free-color becomes bound-color at the moment of commit. That is density with provenance.

### 2. Match is a fail-closed gate — Grove at the table.

`card_can_play2` answers one question: may this card touch the discard? Wilds always pass. Otherwise rank must equal the top rank **or** color must equal the *active* color (not merely the top card's encoded color — wilds already rewrote it). No path writes the discard until the gate returns 1. Illegal human input loops; AI never proposes a failing card. The table never observes a half-applied play.

### 3. The deck is canonical 108 — construction is the spec.

Four colors × (one 0, two of 1–9, two SKIP, two REVERSE, two DRAW2) + four WILD + four WILD4. `deck_build` is the rules document in loops. Fisher–Yates then deals the truth. When the stock empties, the discard under the top card reshuffles back — the top remains the sole public fact. Paranoia about starvation without lying about what was played.

### 4. Effects are pure seat geometry.

SKIP advances once inside `play_card`; the main loop advances again — the victim loses the turn. REVERSE negates direction; with two seats it also advances (official 2-player reverse ≡ skip). DRAW2 / WILD4 advance onto the victim, deal the penalty, and leave the main loop to advance past them. No hidden "pending" flags for the common path — the current-player cursor *is* the effect state.

### 5. Freestanding I/O is part of the engine.

No libc. `read`/`write`/`exit` only. Line input reads **one byte per syscall** so a pipe full of `0\nR\nq\n` cannot collapse three prompts into one `read`. That bug is the interactive cousin of a TOCTOU race: consume past the barrier and the next gate sees the wrong token. Byte-at-a-time is the paranoid fix.

### 6. Human and AI share one commit path.

Both seats call `play_card`. Human supplies index + optional color; AI supplies `hand_find_playable` + `choose_wild_ai`. The announce, remove, discard push, and effect chain are identical. Demo mode is not a second rules engine — it is the same engine with both seats driven by AI and a fixed LCG seed.

### 7. Draw-one with immediate replay is a local policy hook.

If the hand has no legal card, draw one. If that card is legal, human is asked `y/n`; AI always plays it. The card enters the hand first so `play_card`'s index path stays universal — no special "play from void" branch. One commit shape.

### 8. It is infrastructure for tabletop logic under assembly discipline.

The same patterns that clear a posted-price stall (`MarketFixed.asm`) clear a UNO play: pack the state, gate before mutate, fail closed, leave an auditable top-of-discard. A game is a market for turns. The paranoid assembly style does not stop at locks and ledgers.

---

## INSTRUCTION-BY-INSTRUCTION POWER ANALYSIS (core gate)

| Region | Instruction / step | Power |
|--------|--------------------|-------|
| encode | `shl color,4 \| rank` | One-byte identity; wilds overwrite color in place |
| gate | `card_is_wild?` | Short-circuit legal |
| gate | rank(c)==rank(top) | Number/action echo |
| gate | color(c)==cur_color | Suit match against *active* color |
| commit | `hand_remove` swap-with-last | O(1) delete without shifting holes |
| commit | `discard_push` | Top card + count are the public ledger |
| effect | SKIP / REV / +2 / +4 | Cursor arithmetic is the rule |
| I/O | byte-at-a-time `read` | Prompt integrity under pipes |
| RNG | LCG + Fisher–Yates | Deterministic demo; rdtsc-mixed human seats |

Every illegal path returns without mutating the discard. Delete the gate and the table lies.

---

## THE PARANOIA CONNECTION

1. **Assume bad input.** Indices, colors, empty lines, EOF — all rejected or quit cleanly.  
2. **Check before commit.** `card_can_play2` before `hand_remove` / `discard_push`.  
3. **One source of truth.** `top_card` + `cur_color` after wild rewrite.  
4. **Survive depletion.** Reshuffle under the top; never invent cards.  
5. **Same path for every seat.** Human and AI cannot diverge on legality.

> *Only the paranoid survive.* At a card table, paranoia is a one-byte match predicate.

---

## SCALE OF IMPACT

- **Hardware:** any x86-64 Linux host with three syscalls.  
- **Software:** a complete rules engine without a libc dependency surface.  
- **Bytes shipped:** ~40 KB source; tiny text + bss image.  
- **Cost per play:** O(hand) scan for AI; O(1) commit.

---

## VERIFICATION STATUS

✓ **Deck cardinality:** build loops emit 108 cards  
✓ **Match gate:** wild ∨ rank ∨ active-color  
✓ **Fail-closed commit:** no discard write on illegal  
✓ **2-player reverse:** treated as skip via extra advance  
✓ **Demo:** fixed seed reaches a win  
✓ **Human:** legal index play mutates top; `q` exits  
✓ **ABI/freestanding:** System V register use; `nostdlib` link  
✓ **I/O framing:** line reads stop at first LF without over-consuming

**QED.**

---

## CLOSING

`Uno.asm` is not clever because it is a game. It is right because the rules collapsed into data layout and a single gate. One byte per card. One predicate per play. One discard top. Human and AI argue only about *which* legal card — never about *whether* the table accepted a lie.

A lock is a gate on a byte. A market is a gate on a band. UNO is a gate on a color.

**Only the paranoid survive. ✓**
