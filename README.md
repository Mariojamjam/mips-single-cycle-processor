# MIPS Single-Cycle Processor

Implementação de um processador MIPS monociclo em Verilog. O processador executa um subconjunto da ISA MIPS, incluindo instruções dos tipos R, I e J, com suporte a operações aritméticas, lógicas, de memória e desvios.

---

## O que será construído

O projeto implementa os seguintes módulos em Verilog, conectados hierarquicamente:

| Módulo | Arquivo | Descrição |
|---|---|---|
| Contador de Programa | `src/pc.v` | Registrador síncrono de 32 bits que armazena o endereço da instrução atual |
| Memória de instrução | `src/i_mem.v` | ROM assíncrona que carrega instruções do arquivo `instruction.list` |
| Memória de dados | `src/d_mem.v` | RAM assíncrona para leitura e escrita de dados |
| Banco de registradores | `src/regfile.v` | 32 registradores de 32 bits com leitura assíncrona e escrita síncrona |
| ULA | `src/ula.v` | Executa operações aritméticas e lógicas |
| Controle da ULA | `src/ula_ctrl.v` | Traduz `ALUOp` + `opcode`/`funct` para o código de operação da ULA |
| Unidade de controle | `src/ctrl.v` | Decodifica o opcode e gera todos os sinais de controle |
| Top-level | `src/mips_top.v` | Instancia e conecta todos os módulos com fios e multiplexadores |

O processador expõe três saídas principais: valor atual do **PC**, resultado da **ULA** e saída da **memória de dados**.

---

## Estrutura do repositório

```
mips-single-cycle-processor/
├── src/                    # módulos Verilog
│   ├── pc.v
│   ├── i_mem.v
│   ├── d_mem.v
│   ├── regfile.v
│   ├── ula.v
│   ├── ula_ctrl.v
│   ├── ctrl.v
│   └── mips_top.v
├── tb/                     # testbenches
│   ├── tb_pc.v
│   ├── tb_ula.v
│   ├── tb_regfile.v
│   ├── tb_i_mem.v
│   ├── tb_d_mem.v
│   └── tb_mips_top.v
├── programs/
│   ├── instruction.list    # programa em binário (lido pela i_mem)
│   └── soma.asm            # fonte assembly de referência
├── sim/                    # gerada pelo Makefile, ignorada pelo git
├── Dockerfile
├── docker-compose.yml
├── Makefile
├── .gitignore
└── README.md
```

---

## Pré-requisitos

Escolhe uma das opções abaixo conforme o teu sistema.

---

### Opção 1 — Linux nativo

Instala as dependências:

```bash
sudo apt install iverilog gtkwave make
```

---

### Opção 2 — Windows puro (sem WSL ou Docker)

1. Baixa e instala o Icarus Verilog em [bleyer.org/icarus](http://bleyer.org/icarus/). Durante a instalação, marca a opção **Add to PATH**. O instalador já inclui o GTKWave.

2. Abre o **Command Prompt** ou **PowerShell** e verifica a instalação:
```cmd
iverilog -v
```

3. Clona o repositório:
```cmd
git clone https://github.com/<org>/mips-single-cycle-processor
cd mips-single-cycle-processor
```

4. Como o `make` não está disponível nativamente no Windows, compila e simula manualmente:
```cmd
iverilog -o sim\mips.out tb\tb_mips_top.v src\pc.v src\i_mem.v src\d_mem.v src\regfile.v src\ula.v src\ula_ctrl.v src\ctrl.v src\mips_top.v
vvp sim\mips.out
```

5. Para visualizar formas de onda:
```cmd
gtkwave sim\mips.vcd
```

> **Nota:** quem usar o Quartus no Windows pode compilar e simular diretamente pela interface gráfica do Quartus, importando os arquivos da pasta `src/`.

---

### Opção 3 — Windows com WSL

1. Instala o WSL caso ainda não tenha:
```powershell
wsl --install
```

2. Abre o terminal WSL e instala as dependências:
```bash
sudo apt install iverilog gtkwave make
```

3. Clona o repositório dentro do WSL (não na pasta `/mnt/c/...`):
```bash
cd ~
git clone https://github.com/<org>/mips-single-cycle-processor
cd mips-single-cycle-processor
```

> **Atenção:** clonar dentro do WSL (`~/`) e não no sistema de arquivos do Windows (`/mnt/c/`) evita problemas de performance e permissão.

---

### Opção 4 — Windows com Docker

1. Instala o [Docker Desktop](https://www.docker.com/products/docker-desktop/)

2. Clona o repositório:
```powershell
git clone https://github.com/<org>/mips-single-cycle-processor
cd mips-single-cycle-processor
```

3. Faz o build da imagem:
```bash
docker compose build
```

4. Entra no container:
```bash
docker compose run mips
```

A partir daqui, o terminal está dentro do container com o ambiente completo. Os comandos são os mesmos do Linux.

> **Nota sobre GTKWave no Docker:** o GTKWave abre uma janela gráfica que não funciona dentro do container. Para visualizar as formas de onda, gera o arquivo `.vcd` dentro do container com `vvp sim/mips.out` e abre o arquivo `sim/mips.vcd` com o GTKWave instalado no Windows.

---

## Como rodar

### Compilar e simular

```bash
make
```

Compila todos os módulos junto com o testbench do top-level e executa a simulação. A saída aparece diretamente no terminal.

### Visualizar formas de onda

```bash
make wave
```

Abre o GTKWave com o arquivo `.vcd` gerado pela simulação. Requer que `make` tenha sido executado antes.

### Limpar artefatos gerados

```bash
make clean
```

Remove os arquivos `.out` e `.vcd` da pasta `sim/`.

### Checar sintaxe de um módulo isolado

```bash
iverilog -tnull src/ula.v
```

Valida a sintaxe sem precisar de testbench. Não produz saída se não houver erros.

### Compilar e testar um módulo isolado

```bash
iverilog -o sim/tb_ula.out src/ula.v tb/tb_ula.v
vvp sim/tb_ula.out
```

---

## Como contribuir

### Branches

```
main        ← código estável, só via PR da dev
dev         ← integração, só via PR de feature branches
feat/<nome> ← onde cada membro desenvolve
```

Nunca commita diretamente em `main` ou `dev`.

### Fluxo de trabalho

```bash
# parte da dev sempre atualizada
git checkout dev
git pull

# cria a branch da tua feature
git checkout -b feat/ula

# desenvolve, commita
git add .
git commit -m "feat: implement arithmetic operations in ALU"

# abre PR para dev
git push origin feat/ula
```

Abre o Pull Request pelo GitHub apontando para `dev`.

### Padrão de commits

```
feat: implement ALU module
fix: fix control signal for beq instruction
test: add regfile testbench
docs: update README
chore: add Makefile
```

### Idioma

Todo o projeto deve ser escrito em inglês: comentários no código, mensagens de commit, nomes de variáveis, módulos e sinais, e descrições nos Pull Requests.

---

## Roadmap de implementação

Implementa os módulos **nessa ordem** — cada um depende dos anteriores estar funcionando e testado antes de avançar.

### Etapa 1 — ULA (`src/ula.v` + `tb/tb_ula.v`)

O módulo mais independente do projeto. Implementa todas as operações aritméticas e lógicas: `add`, `sub`, `and`, `or`, `xor`, `nor`, `slt`, `sltu`, `sll`, `srl`, `sra`, `sllv`, `srlv`, `srav`.

Recebe `In1` (32 bits), `In2` (32 bits) e `OP` (4 bits). Produz `result` (32 bits) e `Zero_flag` (1 bit).

**Critério de conclusão:** testbench passa para todas as operações, incluindo casos de borda (resultado zero, valores negativos, overflow).

---

### Etapa 2 — Banco de registradores (`src/regfile.v` + `tb/tb_regfile.v`)

32 registradores de 32 bits. O registrador `$0` sempre retorna zero e nunca pode ser escrito. Leitura assíncrona em dois registradores simultaneamente. Escrita síncrona na borda de subida do clock quando `RegWrite=1`. Sinal `Reset` zera todos os registradores.

**Critério de conclusão:** escrita e leitura funcionam corretamente, `$0` permanece zero após tentativa de escrita, reset funciona.

---

### Etapa 3 — Memória de instrução (`src/i_mem.v` + `tb/tb_i_mem.v`)

ROM assíncrona com tamanho parametrizável. Carrega as instruções do arquivo `programs/instruction.list` usando `$readmemb`. Recebe `address` (32 bits) e retorna a instrução de 32 bits em `i_out`.

O endereçamento é por byte, então divide o endereço por 4 para indexar o array: `mem[address >> 2]`.

**Critério de conclusão:** instrução correta retornada para cada endereço.

---

### Etapa 4 — Memória de dados (`src/d_mem.v` + `tb/tb_d_mem.v`)

RAM assíncrona com tamanho parametrizável. Quando `MemWrite=1`, escreve `WriteData` no endereço. Quando `MemRead=1`, coloca o conteúdo em `ReadData`. Quando `MemRead=0`, `ReadData` deve ficar em alta impedância (`32'bz`).

**Critério de conclusão:** escrita e leitura no mesmo endereço retornam o valor correto.

---

### Etapa 5 — Contador de Programa (`src/pc.v` + `tb/tb_pc.v`)

Registrador síncrono de 32 bits. Atualiza na borda de subida do clock com o valor de `nextPC`. Inicializa em `32'h00000000`.

**Critério de conclusão:** PC atualiza corretamente com um ciclo de atraso em relação ao `nextPC`.

---

### Etapa 6 — Controle da ULA (`src/ula_ctrl.v` + `tb/tb_ula_ctrl.v`)

Recebe `ALUOp` (2 bits) da unidade de controle, `opcode` (6 bits) e `funct` (6 bits) da instrução. Produz `ULAOp` (4 bits) que vai direto para a ULA.

Lógica de decodificação:
- `ALUOp=00` → add (usado por `lw`/`sw`)
- `ALUOp=01` → sub (usado por `beq`/`bne`)
- `ALUOp=10` → decodifica pelo campo `funct` (instruções tipo R)
- `ALUOp=11` → decodifica pelo campo `opcode` (operações tipo I aritméticas, como `addi`, `andi`, etc.)

**Critério de conclusão:** `ULAOp` correto para cada combinação de `ALUOp` + `opcode`/`funct`.

---

### Etapa 7 — Unidade de controle (`src/ctrl.v` + `tb/tb_ctrl.v`)

Recebe o `opcode` (6 bits) e gera todos os sinais de controle para o restante do processador. Cobre todos os opcodes das instruções do enunciado.

Sinais mínimos: `RegDst`, `Branch`, `MemRead`, `MemtoReg`, `ALUOp`, `MemWrite`, `ALUSrc`, `RegWrite`, `Jump`, `JAL`, `JR`.

**Critério de conclusão:** sinais corretos gerados para cada opcode.

---

### Etapa 8 — Top-level (`src/mips_top.v` + `tb/tb_mips_top.v`)

Instancia todos os módulos anteriores e os conecta com `wire`. Os multiplexadores são implementados com `assign` e operador ternário. Implementa o cálculo do `nextPC` para instruções sequenciais, desvios e saltos. Implementa a extensão de sinal do imediato.

**Critério de conclusão:** processador executa corretamente um programa de teste em `programs/instruction.list` cobrindo instruções tipo R, `lw`, `sw`, `beq` e `j`.

---
