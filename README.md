# Odyssey - Simulação de Estrelas no Terminal

Bem-vindo ao **Odyssey**, um projeto em Assembly 64 bits que simula estrelas se movendo no terminal, utilizando técnicas de manipulação direta de memória e controle de cursor. Este projeto foi desenvolvido para rodar no ambiente Linux, utilizando o GNU Assembler (`as`) e o Linker (`ld`) como ferramentas principais.

## Sumário

- [Sobre o Projeto](#sobre-o-projeto)
- [Pré-Requisitos](#pré-requisitos)
- [Compilação e Execução](#compilação-e-execução)
- [Como Funciona](#como-funciona)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Contribuição](#contribuição)
- [Licença](#licença)

## Sobre o Projeto

O **Odyssey** é um programa em Assembly que imprime estrelas em posições aleatórias no terminal e as move gradualmente para baixo, criando um efeito visual semelhante ao de estrelas caindo. Este projeto é ideal para aqueles que estão interessados em:

- Aprender Assembly para arquitetura x86-64.
- Explorar manipulação direta de memória e controle de fluxo de programas em baixo nível.
- Entender o uso de syscalls no Linux para realizar operações de entrada e saída.

## Pré-Requisitos

Para compilar e executar o projeto, você precisará das seguintes ferramentas instaladas no seu sistema Linux:

1. **GNU Assembler (`as`)** e **Linker (`ld`)**: Estes fazem parte do pacote `binutils`.
2. **Make**: Para automatizar o processo de compilação.
3. **GCC** (opcional): Pode ser utilizado para linkar e compilar com mais facilidade.

### Instalação via `apt-get`

Você pode instalar as dependências executando:

```bash
sudo apt-get update
sudo apt-get install build-essential binutils
```

## Compilação e Execução

Para compilar e executar o **Odyssey**, siga os passos abaixo:

1. Clone o repositório:

    ```bash
    git clone https://github.com/arcosbr/odyssey.git
    cd odyssey
    ```

2. Compile o código utilizando o **Makefile** incluído no projeto:

    ```bash
    make
    ```

3. Execute o programa:

    ```bash
    ./odyssey
    ```

4. Para limpar os arquivos objetos e o executável:

    ```bash
    make clean
    ```

## Como Funciona

O programa utiliza técnicas de manipulação direta do terminal através de sequências de escape ANSI para mover o cursor e desenhar estrelas (`*`) em posições aleatórias. Ele usa uma combinação de funções customizadas, como `rand`, `int_to_str`, `strcat`, e syscalls para realizar as seguintes operações:

- **Limpar o terminal**: Utilizando uma syscall para escrever uma sequência de escape ANSI que limpa a tela.
- **Gerar Posições Aleatórias**: Uma função Linear Congruential Generator (`rand`) é usada para determinar a posição das estrelas.
- **Converter Coordenadas para String**: Utiliza a função `int_to_str` para gerar a sequência correta de controle ANSI.
- **Mover o Cursor e Imprimir as Estrelas**: Controla o movimento do cursor e desenha as estrelas nas coordenadas especificadas.

O programa simula um efeito visual em que estrelas caem continuamente do topo até a parte inferior do terminal.

## Estrutura do Projeto

- `main.s`: Código fonte principal em Assembly que define a lógica do programa, incluindo a inicialização das estrelas, controle de cursor, e movimentação.

- `Makefile`: Arquivo de automação para compilar e linkar o código Assembly.

## Contribuição

Contribuições são sempre bem-vindas! Se você deseja contribuir com melhorias para este projeto, siga os seguintes passos:

1. Faça um fork do repositório.
2. Crie uma branch para sua feature (`git checkout -b feature/Aprimoramento`).
3. Commit suas alterações (`git commit -m 'Adicionar Aprimoramento'`).
4. Faça um push para a branch (`git push origin feature/Aprimoramento`).
5. Abra um Pull Request.

### Sugestões de Melhorias

- **Suporte a Mais Animações**: Implementar novos efeitos visuais, como estrelas se movendo em direções diferentes.
- **Melhoria na Randomização**: Melhorar a geração de números aleatórios para dar mais variabilidade às posições.
- **Controle de Velocidade**: Adicionar a possibilidade de ajustar a velocidade das estrelas através de parâmetros passados ao executável.

## Licença

Este projeto é licenciado sob a licença MIT - consulte o arquivo [LICENSE](LICENSE) para mais detalhes.
