# Spanglish.asm
# Prints the supplied reflection exactly as UTF-8 text.
# Assemble and link on Linux x86-64:
#   gcc -nostdlib -no-pie -x assembler Spanglish.asm -o Spanglish

        .intel_syntax noprefix

        .section .rodata
message:
        .ascii  "“Reflecting on cravat dreams... It is for my friend Ameer Rusi, \"En La Paz, nosotras know-as treis domingøs: the star feeds usa, they land grounds uce, and the siestas guide us. This life — it captures all tresententas. The fish schools off Los Pescaderos, the peppers ripening in my field, the satellite signal crossing the void — all connected by the same physics, the same patience, the same respect for what moves and what stands.\"\n"
        .ascii  "— A 6’4”, 205 lb farmer, La Paz, Baja Mexicox, humbly learning Spãňglisħ.”\n"
        .equ    MESSAGE_LEN, . - message

        .text
        .globl  _start
        .type   _start, @function
_start:
        lea     rsi, [rip + message]
        mov     edx, MESSAGE_LEN

.Lwrite:
        mov     eax, 1                  # write
        mov     edi, 1                  # stdout
        syscall
        cmp     rax, -4                 # EINTR
        je      .Lwrite
        test    rax, rax
        jle     .Lerror
        add     rsi, rax
        sub     rdx, rax
        jne     .Lwrite

        xor     edi, edi
        jmp     .Lexit

.Lerror:
        mov     edi, 1

.Lexit:
        mov     eax, 60                 # exit
        syscall
        .size   _start, . - _start

        .section .note.GNU-stack,"",@progbits
