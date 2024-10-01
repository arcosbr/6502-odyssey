.section .data
    star_char:      .asciz "*"

    # Sequência para limpar a tela
    clear_screen:   .asciz "\033[2J"
    srand_seed:     .quad 1        # Semente do gerador de números aleatórios

    buffer_y:       .space 16      # Buffer para conversão de Y para string
    buffer_x:       .space 16      # Buffer para conversão de X para string
    esc_sequence:   .space 32      # Buffer para a sequência de escape

.section .bss
    stars:
        .space 20 * 2 * 4          # 20 estrelas com posições Y e X

    timespec:
        .space 16                  # Estrutura timespec para nanosleep

.section .text
    .globl _start

_start:
    # Limpa a tela
    mov $1, %rax                   # syscall número 1 (sys_write)
    mov $1, %rdi                   # stdout
    lea clear_screen(%rip), %rsi   # Endereço da string para limpar a tela
    mov $4, %edx                   # Tamanho da string (sem o terminador nulo)
    syscall

    # Inicializa as estrelas com posições aleatórias
    xor %edi, %edi                 # Índice inicial (0)
init_stars_loop:
    cmp $20, %edi
    jge stars_initialized

    # Gera posição Y aleatória entre 1 e 24
    call rand
    and $0x17, %eax                # 0-23
    add $1, %eax                   # 1-24
    mov %eax, stars(,%edi,8)       # Armazena Y em `stars`

    # Gera posição X aleatória entre 1 e 80
    call rand
    and $0x4F, %eax                # 0-79
    add $1, %eax                   # 1-80
    mov %eax, stars+4(,%edi,8)     # Armazena X em `stars`

    inc %edi
    jmp init_stars_loop

stars_initialized:
    # Loop principal
main_loop:
    xor %edi, %edi                 # Índice inicial (0)

draw_stars_loop:
    cmp $20, %edi
    jge loop_delay

    # Carrega posição Y
    mov stars(,%edi,8), %eax       # Carrega valor Y (32 bits)
    mov %eax, %esi                 # Guarda Y em %esi

    # Carrega posição X
    mov stars+4(,%edi,8), %eax     # Carrega valor X (32 bits)
    mov %eax, %edx                 # Guarda X em %edx

    # Converte Y para string
    lea buffer_y(%rip), %rdi       # Ponteiro para buffer_y
    mov %esi, %esi                 # Valor Y em %esi
    call int_to_str                # Converte Y para string em buffer_y
    mov %rax, %rsi                 # Ponteiro para o início da string Y

    # Constroi sequência de escape para mover o cursor
    lea esc_sequence(%rip), %rdi   # Ponteiro para esc_sequence
    movb $0x1B, (%rdi)             # ESC
    movb $'[', 1(%rdi)             # '['
    movb $'\0', 2(%rdi)            # Termina a string

    # Concatena Y na sequência de escape
    lea esc_sequence(%rip), %rdi   # Destino: esc_sequence
    call strcat                    # Concatena buffer_y em esc_sequence

    # Adiciona ';' na sequência de escape
    lea esc_sequence(%rip), %rdi
    call strlen                    # Comprimento atual de esc_sequence
    mov %rax, %rcx                 # Guarda comprimento em %rcx
    lea esc_sequence(%rip), %rdi
    add %rcx, %rdi                 # Move ponteiro para o final da string
    movb $';', (%rdi)              # Adiciona ';'
    inc %rdi
    movb $'\0', (%rdi)             # Termina a string

    # Converte X para string
    lea buffer_x(%rip), %rdi       # Ponteiro para buffer_x
    mov %edx, %esi                 # Valor X em %esi
    call int_to_str                # Converte X para string em buffer_x
    mov %rax, %rsi                 # Ponteiro para o início da string X

    # Concatena X na sequência de escape
    lea esc_sequence(%rip), %rdi   # Destino: esc_sequence
    call strcat                    # Concatena buffer_x em esc_sequence

    # Adiciona 'H' na sequência de escape
    lea esc_sequence(%rip), %rdi
    call strlen                    # Comprimento atual de esc_sequence
    mov %rax, %rcx                 # Guarda comprimento em %rcx
    lea esc_sequence(%rip), %rdi
    add %rcx, %rdi                 # Move ponteiro para o final da string
    movb $'H', (%rdi)              # Adiciona 'H'
    inc %rdi
    movb $'\0', (%rdi)             # Termina a string

    # Escreve a sequência de escape para mover o cursor
    mov $1, %rax                   # syscall número 1 (sys_write)
    mov $1, %rdi                   # stdout
    lea esc_sequence(%rip), %rsi
    call strlen
    mov %eax, %edx                 # Tamanho da string
    syscall

    # Escreve a estrela
    mov $1, %rax                   # syscall número 1 (sys_write)
    mov $1, %rdi                   # stdout
    lea star_char(%rip), %rsi
    mov $1, %rdx                   # Tamanho da estrela
    syscall

    # Atualiza posição Y da estrela
    mov stars(,%edi,8), %eax
    add $1, %eax                   # Move para baixo
    cmp $24, %eax
    jle update_star_position
    mov $1, %eax                   # Reinicia no topo

update_star_position:
    mov %eax, stars(,%edi,8)

    # Incrementa índice
    inc %edi
    jmp draw_stars_loop

loop_delay:
    # Inicializa timespec para 50 milissegundos
    movq $0, timespec(%rip)        # tv_sec = 0
    movq $50000000, timespec+8(%rip) # tv_nsec = 50,000,000

    # Espera 50 milissegundos usando nanosleep
    lea timespec(%rip), %rdi       # const struct timespec *req
    mov $35, %rax                  # syscall número 35 (nanosleep)
    xor %rsi, %rsi                 # NULL para rem
    syscall

    # Reinicia loop principal
    jmp main_loop

# Função para gerar um número pseudo-aleatório (LCG)
rand:
    mov srand_seed(%rip), %rax
    imul $1103515245, %rax
    add $12345, %rax
    mov %rax, srand_seed(%rip)
    shr $16, %rax
    and $0x7FFF, %eax
    ret

# Função para converter um inteiro em string
# Argumentos:
#   %esi - valor a converter
#   %rdi - ponteiro para o buffer de destino
# Retorna:
#   %rax - ponteiro para a string (mesmo que %rdi)
int_to_str:
    push %rbx                       # Salva registradores usados
    mov %rdi, %rbx                  # Guarda ponteiro do buffer em %rbx
    mov %esi, %eax                  # Valor a converter em %eax
    xor %edx, %edx                  # Limpa %edx antes da divisão
    mov $10, %ecx                   # Divisor para base decimal

    # Prepara ponteiro para o final do buffer
    lea (%rbx), %rdi
    add $15, %rdi                   # Supondo buffer de pelo menos 16 bytes
    movb $'\0', (%rdi)              # Termina a string
    dec %rdi

convert_loop:
    xor %edx, %edx                  # Limpa %edx antes da divisão
    div %ecx                        # Divide %eax por 10
    add $'0', %edx                  # Converte dígito para ASCII
    movb %dl, (%rdi)                # Armazena caractere no buffer
    dec %rdi
    test %eax, %eax
    jnz convert_loop

    inc %rdi                        # Ajusta ponteiro para o início da string
    mov %rdi, %rax                  # Retorna o ponteiro para a string
    pop %rbx                        # Restaura registradores usados
    ret

# Função strcat simplificada (concatena string de %rsi a %rdi)
strcat:
    push %rdi                       # Salva registradores usados
    push %rsi

    # Encontra o final da string destino
strlen_loop_strcat:
    movb (%rdi), %al
    cmpb $0, %al
    je strcat_start
    inc %rdi
    jmp strlen_loop_strcat

strcat_start:
    # Copia a string fonte para o destino, incluindo o terminador nulo
copy_strcat:
    movb (%rsi), %al
    movb %al, (%rdi)
    inc %rdi
    inc %rsi
    cmpb $0, %al
    jne copy_strcat

    # Não é necessário ajustar o ponteiro ou adicionar um terminador nulo
    # O terminador nulo já foi copiado

    pop %rsi                        # Restaura registradores usados
    pop %rdi
    ret

# Função strlen simplificada
# Argumento:
#   %rdi - ponteiro para a string
# Retorna:
#   %rax - comprimento da string
strlen:
    xor %rax, %rax                 # Inicializa comprimento
strlen_loop:
    movb (%rdi,%rax), %al
    cmpb $0, %al
    je strlen_end
    inc %rax
    jmp strlen_loop
strlen_end:
    ret
