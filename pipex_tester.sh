#!/bin/bash

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Contadores
PASS=0
FAIL=0

# Função para imprimir cabeçalhos
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

# Função para comparar resultados
compare_results() {
    local test_name=$1
    local pipex_out=$2
    local shell_out=$3
    local pipex_exit=$4
    local shell_exit=$5

    if diff -q "$pipex_out" "$shell_out" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ $test_name - Output correto${NC}"
        ((PASS++))
    else
        echo -e "${RED}✗ $test_name - Output diferente${NC}"
        echo "Diferenças encontradas:"
        diff "$pipex_out" "$shell_out"
        ((FAIL++))
    fi
}

# Função para teste básico
run_test() {
    local test_name=$1
    local cmd=$2
    local shell_cmd=$3

    echo -e "${YELLOW}Testando: $test_name${NC}"
    echo "Comando pipex: $cmd"
    echo "Comando shell: $shell_cmd"

    eval "$cmd" 2>/dev/null
    local pipex_exit=$?

    eval "$shell_cmd" 2>/dev/null
    local shell_exit=$?

    compare_results "$test_name" "outfile" "outfile_shell" "$pipex_exit" "$shell_exit"
    echo ""
}

# Limpeza inicial
cleanup() {
    rm -f infile outfile outfile_shell test_*.txt
}

print_header "PIPEX TESTER - 42 School"

# Verifica se o executável existe
if [ ! -f "./pipex" ]; then
    echo -e "${RED}Erro: Executável ./pipex não encontrado!${NC}"
    echo "Compilando com make..."
    make
    if [ ! -f "./pipex" ]; then
        echo -e "${RED}Falha na compilação!${NC}"
        exit 1
    fi
fi

cleanup

# ============================================
# TESTES OBRIGATÓRIOS
# ============================================

print_header "PARTE OBRIGATÓRIA - TESTES BÁSICOS"

# Criar arquivo de entrada
echo -e "Hello World\nThis is a test\nPipex project\n42 School" > infile

echo -e "${YELLOW}Teste 1: Comandos básicos (cat + grep)${NC}"
./pipex infile "cat" "grep test" outfile
< infile cat | grep test > outfile_shell
compare_results "cat | grep" "outfile" "outfile_shell" 0 0
echo ""

echo -e "${YELLOW}Teste 2: ls + wc${NC}"
./pipex infile "ls -l" "wc -l" outfile
< infile ls -l | wc -l > outfile_shell
compare_results "ls | wc" "outfile" "outfile_shell" 0 0
echo ""

echo -e "${YELLOW}Teste 3: cat + sed${NC}"
./pipex infile "cat" "sed s/test/TEST/" outfile
< infile cat | sed s/test/TEST/ > outfile_shell
compare_results "cat | sed" "outfile" "outfile_shell" 0 0
echo ""

echo -e "${YELLOW}Teste 4: grep + wc${NC}"
./pipex infile "grep a" "wc -w" outfile
< infile grep a | wc -w > outfile_shell
compare_results "grep | wc" "outfile" "outfile_shell" 0 0
echo ""

echo -e "${YELLOW}Teste 5: cat + tr (uppercase)${NC}"
./pipex infile "cat" "tr '[:lower:]' '[:upper:]'" outfile
< infile cat | tr '[:lower:]' '[:upper:]' > outfile_shell
compare_results "cat | tr" "outfile" "outfile_shell" 0 0
echo ""

# ============================================
# TESTES DE GERENCIAMENTO DE ERROS
# ============================================

print_header "GERENCIAMENTO DE ERROS"

echo -e "${YELLOW}Teste 6: Arquivo de entrada inexistente${NC}"
./pipex arquivo_inexistente "cat" "wc -l" outfile 2>/dev/null
pipex_exit=$?
< arquivo_inexistente cat | wc -l > outfile_shell 2>/dev/null
shell_exit=$?
if [ $pipex_exit -ne 0 ]; then
    echo -e "${GREEN}✓ Retornou erro corretamente (exit: $pipex_exit)${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Deveria retornar erro${NC}"
    ((FAIL++))
fi
echo ""

echo -e "${YELLOW}Teste 7: Comando inexistente (cmd1)${NC}"
./pipex infile "comando_invalido" "wc -l" outfile 2>/dev/null
pipex_exit=$?
if [ $pipex_exit -ne 0 ]; then
    echo -e "${GREEN}✓ Tratou comando inválido corretamente${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Deveria tratar erro de comando inválido${NC}"
    ((FAIL++))
fi
echo ""

echo -e "${YELLOW}Teste 8: Comando inexistente (cmd2)${NC}"
./pipex infile "cat" "comando_invalido" outfile 2>/dev/null
pipex_exit=$?
if [ $pipex_exit -ne 0 ]; then
    echo -e "${GREEN}✓ Tratou comando inválido corretamente${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Deveria tratar erro de comando inválido${NC}"
    ((FAIL++))
fi
echo ""

echo -e "${YELLOW}Teste 9: Arquivo sem permissão de leitura${NC}"
touch no_read_file
chmod 000 no_read_file
./pipex no_read_file "cat" "wc -l" outfile 2>/dev/null
pipex_exit=$?
if [ $pipex_exit -ne 0 ]; then
    echo -e "${GREEN}✓ Tratou falta de permissão corretamente${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Deveria retornar erro de permissão${NC}"
    ((FAIL++))
fi
chmod 644 no_read_file
rm -f no_read_file
echo ""

echo -e "${YELLOW}Teste 10: Número incorreto de argumentos${NC}"
./pipex infile "cat" outfile 2>/dev/null
pipex_exit=$?
if [ $pipex_exit -ne 0 ]; then
    echo -e "${GREEN}✓ Rejeitou número incorreto de argumentos${NC}"
    ((PASS++))
else
    echo -e "${RED}✗ Deveria rejeitar argumentos insuficientes${NC}"
    ((FAIL++))
fi
echo ""

# ============================================
# TESTES COM COMANDOS COMPLEXOS
# ============================================

print_header "COMANDOS COMPLEXOS"

echo -e "${YELLOW}Teste 11: Comandos com múltiplas flags${NC}"
./pipex infile "ls -la" "grep pipex" outfile 2>/dev/null
< infile ls -la | grep pipex > outfile_shell 2>/dev/null
compare_results "ls -la | grep" "outfile" "outfile_shell" 0 0
echo ""

echo -e "${YELLOW}Teste 12: awk com padrões${NC}"
./pipex infile "cat" "awk '{print \$1}'" outfile
< infile cat | awk '{print $1}' > outfile_shell
compare_results "cat | awk" "outfile" "outfile_shell" 0 0
echo ""

# ============================================
# TESTES DE BONUS (se implementado)
# ============================================

print_header "TESTES DE BONUS (Múltiplos Pipes)"

echo -e "${YELLOW}Teste Bonus 1: 3 pipes${NC}"
if ./pipex infile "cat" "grep -v '^$'" "tr '[:lower:]' '[:upper:]'" "wc -l" outfile 2>/dev/null; then
    echo -e "${GREEN}✓ Suporta múltiplos pipes (3 pipes)${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⊘ Bonus não implementado ou falhou${NC}"
fi
echo ""

echo -e "${YELLOW}Teste Bonus 2: 5 pipes${NC}"
if ./pipex infile "cat" "grep a" "tr 'a' 'A'" "grep A" "wc -l" "cat" outfile 2>/dev/null; then
    echo -e "${GREEN}✓ Suporta múltiplos pipes (5 pipes)${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⊘ Bonus não implementado ou falhou${NC}"
fi
echo ""

print_header "TESTES DE BONUS (Here_doc)"

echo -e "${YELLOW}Teste Bonus 3: here_doc básico${NC}"
if command -v here_doc &> /dev/null || ./pipex here_doc LIMITER "cat" "wc -l" outfile 2>/dev/null; then
    echo -e "${GREEN}✓ Suporta here_doc${NC}"
    ((PASS++))
else
    echo -e "${YELLOW}⊘ Bonus here_doc não implementado${NC}"
fi
echo ""

# ============================================
# VERIFICAÇÃO DE LEAKS (se valgrind disponível)
# ============================================

if command -v valgrind &> /dev/null; then
    print_header "VERIFICAÇÃO DE MEMORY LEAKS"

    echo -e "${YELLOW}Executando valgrind...${NC}"
    valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes \
             ./pipex infile "cat" "grep test" outfile 2> valgrind_output.txt

    if grep -q "no leaks are possible" valgrind_output.txt || \
       grep -q "All heap blocks were freed" valgrind_output.txt; then
        echo -e "${GREEN}✓ Sem memory leaks detectados${NC}"
        ((PASS++))
    else
        echo -e "${RED}✗ Memory leaks detectados!${NC}"
        echo "Verifique valgrind_output.txt para detalhes"
        ((FAIL++))
    fi
    echo ""
fi

# ============================================
# RESUMO FINAL
# ============================================

cleanup

print_header "RESUMO DOS TESTES"

TOTAL=$((PASS + FAIL))
echo -e "Total de testes: $TOTAL"
echo -e "${GREEN}Testes passados: $PASS${NC}"
echo -e "${RED}Testes falhados: $FAIL${NC}"

if [ $FAIL -eq 0 ]; then
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}   TODOS OS TESTES PASSARAM! 🎉${NC}"
    echo -e "${GREEN}========================================${NC}\n"
else
    echo -e "\n${YELLOW}========================================${NC}"
    echo -e "${YELLOW}   Alguns testes falharam${NC}"
    echo -e "${YELLOW}   Revise os erros acima${NC}"
    echo -e "${YELLOW}========================================${NC}\n"
fi

# Limpeza final
rm -f outfile outfile_shell valgrind_output.txt