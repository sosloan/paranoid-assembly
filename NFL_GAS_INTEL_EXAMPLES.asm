# GAS Intel syntax examples: running backs and linebackers.
# Assemble on Linux:
#   gcc -c NFL_GAS_INTEL_EXAMPLES.asm -o NFL_GAS_INTEL_EXAMPLES.o

        .intel_syntax noprefix
        .text

# int give_ball_to_running_back(int yard_line)
# edi = yard_line (the source value)
# eax = return value (the destination)
#
# Intel syntax reads like an assignment:
#   mov eax, edi       means eax = edi
        .globl  give_ball_to_running_back
give_ball_to_running_back:
        mov     eax, edi        # The running back receives the ball.
        ret

# int running_back_gains_yards(int current_yards, int gained_yards)
# edi = current_yards, esi = gained_yards
# Returns current_yards + gained_yards in eax.
        .globl  running_back_gains_yards
running_back_gains_yards:
        mov     eax, edi        # eax = current_yards
        add     eax, esi        # eax = eax + gained_yards
        ret

# int linebacker_makes_tackle(int runner_yards, int tackle_line)
# Return 1 when the linebacker stops the runner at or before tackle_line;
# otherwise return 0.
        .globl  linebacker_makes_tackle
linebacker_makes_tackle:
        xor     eax, eax        # eax = 0: no tackle yet
        cmp     edi, esi        # Compare runner_yards with tackle_line.
        jg      .Lmissed        # Jump when runner_yards > tackle_line.
        mov     eax, 1          # eax = 1: tackle made
.Lmissed:
        ret

# struct BallCarrier {
#     int yards;                 # offset 0
# };
#
# int record_running_back_yards(struct BallCarrier *back, int gained_yards)
# rdi = address of the running back, esi = gained_yards
# Square brackets mean "the memory at this address."
        .globl  record_running_back_yards
record_running_back_yards:
        mov     eax, [rdi]      # eax = back->yards
        add     eax, esi        # eax = eax + gained_yards
        mov     [rdi], eax      # back->yards = eax
        ret
