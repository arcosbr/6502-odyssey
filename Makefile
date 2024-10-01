# Makefile para código assembly de 64 bits

# Assembler e Linker
AS = as
LD = ld

# Flags de compilação e linkedição
ASFLAGS = --64 -g
LDFLAGS = -no-pie -s -e _start

# Nome do executável
TARGET = odyssey

# Fontes e objetos
SRC = main.s
OBJ = $(SRC:.s=.o)

# Regra padrão
all: $(TARGET)

# Link
$(TARGET): $(OBJ)
	$(LD) $(LDFLAGS) -o $@ $^

# Compilação
%.o: %.s
	$(AS) $(ASFLAGS) -o $@ $<

# Limpeza
clean:
	rm -f $(OBJ) $(TARGET)
