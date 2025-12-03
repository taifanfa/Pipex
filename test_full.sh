#!/bin/bash

# ==========================================
#  PIPEX COMPREHENSIVE TEST SUITE
#  42 School - Complete Testing Framework
# ==========================================

RED="\033[0;31m"
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
MAGENTA="\033[0;35m"
CYAN="\033[0;36m"
BOLD="\033[1m"
NC="\033[0m"

PIPEX=./pipex
PASSED=0
FAILED=0
TOTAL=0

if [ ! -f "$PIPEX" ]; then
    echo -e "${RED}${BOLD}[ERRO]${NC} Compile o projeto primeiro!"
    echo -e "Execute: ${CYAN}make${NC}"
    exit 1
fi

print_header() {
    echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${NC} ${BOLD}$1${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
}

print_test() {
    ((TOTAL++))
    echo -e "\n${YELLOW}━━━ TESTE $TOTAL: $1 ━━━${NC}"
}

print_command() {
    echo -e "${BLUE}Comando:${NC} $1"
}

print_comparison() {
    echo -e "\n${MAGENTA}┌─ Esperado (Shell):${NC}"
    if [ -f out_shell ]; then
        cat out_shell | head -20
        [ $(wc -l < out_shell) -gt 20 ] && echo "... (truncado)"
    else
        echo "(arquivo não existe)"
    fi

    echo -e "${MAGENTA}├─ Recebido (Pipex):${NC}"
    if [ -f out_pipex ]; then
        cat out_pipex | head -20
        [ $(wc -l < out_pipex) -gt 20 ] && echo "... (truncado)"
    else
        echo "(arquivo não existe)"
    fi
    echo -e "${MAGENTA}└─${NC}"
}

print_exit_codes() {
    local pipex_exit=$1
    local shell_exit=$2
    echo -e "${BLUE}Exit Code Pipex:${NC} $pipex_exit | ${BLUE}Exit Code Shell:${NC} $shell_exit"
}

check_result() {
    local output_match=$1
    local exit_match=$2

    if [ "$output_match" = "true" ] && [ "$exit_match" = "true" ]; then
        echo -e "${GREEN}${BOLD}✓ PASSOU${NC}"
        ((PASSED++))
        return 0
    else
        echo -e "${RED}${BOLD}✗ FALHOU${NC}"
        [ "$output_match" = "false" ] && echo -e "  ${RED}→ Output diferente${NC}"
        [ "$exit_match" = "false" ] && echo -e "  ${RED}→ Exit code diferente${NC}"
        ((FAILED++))
        return 1
    fi
}

compare_files() {
    if diff out_pipex out_shell >/dev/null 2>&1; then
        echo "true"
    else
        echo "false"
    fi
}

compare_exit() {
    if [ $1 -eq $2 ]; then
        echo "true"
    else
        echo "false"
    fi
}

# ==========================================
# SEÇÃO 1: TESTES BÁSICOS
# ==========================================
print_header "SEÇÃO 1: TESTES BÁSICOS DE FUNCIONALIDADE"

# TEST 1
print_test "Pipeline simples (cat | wc -l)"
echo -e "linha1\nlinha2\nlinha3" > infile
print_command "./pipex infile \"cat\" \"wc -l\" outfile"
$PIPEX infile "cat" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 2
print_test "Pipeline com grep (grep pattern | wc -l)"
echo -e "apple\nbanana\napricot\navocado" > infile
print_command "./pipex infile \"grep a\" \"wc -l\" outfile"
$PIPEX infile "grep a" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< infile grep a | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 3
print_test "Comando com múltiplos argumentos (ls -la | wc -l)"
print_command "./pipex infile \"ls -la\" \"wc -l\" outfile"
$PIPEX infile "ls -la" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
ls -la | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 4
print_test "Pipeline com sort (cat | sort)"
echo -e "zebra\napple\nmango\nbanana" > infile
print_command "./pipex infile \"cat\" \"sort\" outfile"
$PIPEX infile "cat" "sort" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | sort > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# ==========================================
# SEÇÃO 2: TESTES DE ERRO
# ==========================================
print_header "SEÇÃO 2: TRATAMENTO DE ERROS"

# TEST 5
print_test "Infile inexistente"
rm -f arquivo_que_nao_existe
print_command "./pipex arquivo_que_nao_existe \"cat\" \"wc -l\" outfile"
$PIPEX arquivo_que_nao_existe "cat" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< arquivo_que_nao_existe cat 2>/dev/null | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 6
print_test "Infile sem permissão de leitura"
echo "conteúdo secreto" > infile_sem_permissao
chmod 000 infile_sem_permissao
print_command "./pipex infile_sem_permissao \"cat\" \"wc\" outfile"
$PIPEX infile_sem_permissao "cat" "wc" out_pipex 2>/dev/null
EXIT_P=$?
< infile_sem_permissao cat 2>/dev/null | wc > out_shell 2>/dev/null
EXIT_S=$?
chmod 644 infile_sem_permissao
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 7
print_test "Primeiro comando inexistente"
echo "teste" > infile
print_command "./pipex infile \"comando_invalido\" \"wc -l\" outfile"
$PIPEX infile "comando_invalido" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< infile comando_invalido 2>/dev/null | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 8
print_test "Segundo comando inexistente"
echo "teste" > infile
print_command "./pipex infile \"cat\" \"comando_invalido\" outfile"
$PIPEX infile "cat" "comando_invalido" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | comando_invalido > out_shell 2>/dev/null
EXIT_S=$?
print_exit_codes $EXIT_P $EXIT_S
# Não compara output pois ambos falham
check_result "true" $(compare_exit $EXIT_P $EXIT_S)

# TEST 9
print_test "Ambos comandos inexistentes"
echo "teste" > infile
print_command "./pipex infile \"cmd1_invalido\" \"cmd2_invalido\" outfile"
$PIPEX infile "cmd1_invalido" "cmd2_invalido" out_pipex 2>/dev/null
EXIT_P=$?
< infile cmd1_invalido 2>/dev/null | cmd2_invalido > out_shell 2>/dev/null
EXIT_S=$?
print_exit_codes $EXIT_P $EXIT_S
check_result "true" $(compare_exit $EXIT_P $EXIT_S)

# TEST 10
print_test "Outfile criado mesmo com infile inexistente"
rm -f outfile_teste
print_command "./pipex nofile \"cat\" \"wc\" outfile_teste"
$PIPEX nofile "cat" "wc" outfile_teste 2>/dev/null
if [ -f outfile_teste ]; then
    echo -e "${GREEN}✓ Outfile foi criado${NC}"
    ((PASSED++))
else
    echo -e "${RED}✗ Outfile não foi criado${NC}"
    ((FAILED++))
fi

# ==========================================
# SEÇÃO 3: TESTES COM ASPAS E CARACTERES ESPECIAIS
# ==========================================
print_header "SEÇÃO 3: ARGUMENTOS COMPLEXOS"

# TEST 11
print_test "Argumentos entre aspas"
echo -e "hello world\nfoo bar\nhello universe" > infile
print_command "./pipex infile \"cat\" \"grep \\\"hello world\\\"\" outfile"
$PIPEX infile "cat" "grep \"hello world\"" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | grep "hello world" > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 12
print_test "Comando com path absoluto"
echo "teste path absoluto" > infile
print_command "./pipex infile \"/bin/cat\" \"/usr/bin/wc -w\" outfile"
$PIPEX infile "/bin/cat" "/usr/bin/wc -w" out_pipex 2>/dev/null
EXIT_P=$?
< infile /bin/cat | /usr/bin/wc -w > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 13
print_test "Múltiplos espaços nos argumentos"
echo -e "a  b  c\nd    e    f" > infile
print_command "./pipex infile \"cat\" \"wc -w\" outfile"
$PIPEX infile "cat" "wc -w" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | wc -w > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# ==========================================
# SEÇÃO 4: TESTES DE PERFORMANCE E DADOS
# ==========================================
print_header "SEÇÃO 4: VOLUME DE DADOS"

# TEST 14
print_test "Arquivo grande (1000 linhas)"
seq 1 1000 > infile
print_command "./pipex infile \"cat\" \"wc -l\" outfile"
$PIPEX infile "cat" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 15
print_test "Arquivo vazio"
> infile
print_command "./pipex infile \"cat\" \"wc -l\" outfile"
$PIPEX infile "cat" "wc -l" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | wc -l > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 16
print_test "Linha muito longa"
python3 -c "print('a' * 10000)" > infile 2>/dev/null || perl -e 'print "a" x 10000' > infile
print_command "./pipex infile \"cat\" \"wc -c\" outfile"
$PIPEX infile "cat" "wc -c" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | wc -c > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# ==========================================
# SEÇÃO 5: TESTES COM COMANDOS REAIS
# ==========================================
print_header "SEÇÃO 5: COMBINAÇÕES DE COMANDOS REAIS"

# TEST 17
print_test "awk - processamento de texto"
echo -e "nome idade\njoao 25\nmaria 30\ncarlos 22" > infile
print_command "./pipex infile \"cat\" \"awk '{print \$1}'\" outfile"
$PIPEX infile "cat" "awk '{print \$1}'" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | awk '{print $1}' > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 18
print_test "cut - extração de campos"
echo -e "a:b:c\nd:e:f\ng:h:i" > infile
print_command "./pipex infile \"cat\" \"cut -d: -f2\" outfile"
$PIPEX infile "cat" "cut -d: -f2" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | cut -d: -f2 > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 19
print_test "head e tail - primeiras/últimas linhas"
seq 1 100 > infile
print_command "./pipex infile \"head -20\" \"tail -5\" outfile"
$PIPEX infile "head -20" "tail -5" out_pipex 2>/dev/null
EXIT_P=$?
< infile head -20 | tail -5 > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# TEST 20
print_test "tr - transformação de caracteres"
echo "HELLO WORLD" > infile
print_command "./pipex infile \"cat\" \"tr A-Z a-z\" outfile"
$PIPEX infile "cat" "tr A-Z a-z" out_pipex 2>/dev/null
EXIT_P=$?
< infile cat | tr A-Z a-z > out_shell 2>/dev/null
EXIT_S=$?
print_comparison
print_exit_codes $EXIT_P $EXIT_S
check_result $(compare_files) $(compare_exit $EXIT_P $EXIT_S)

# ==========================================
# SEÇÃO 6: VALGRIND (MEMORY LEAKS)
# ==========================================
print_header "SEÇÃO 6: VERIFICAÇÃO DE MEMÓRIA"

print_test "Valgrind - leak check"
echo "memory test" > infile
print_command "valgrind ./pipex infile \"cat\" \"wc\" outfile"

valgrind --leak-check=full --show-leak-kinds=all \
    --error-exitcode=42 --track-origins=yes \
    $PIPEX infile "cat" "wc" out_pipex 2>&1 | tee valgrind.log > /dev/null

if grep -q "All heap blocks were freed" valgrind.log && \
   grep -q "ERROR SUMMARY: 0 errors" valgrind.log; then
    echo -e "${GREEN}${BOLD}✓ Nenhum leak detectado${NC}"
    ((PASSED++))
else
    echo -e "${RED}${BOLD}✗ Leaks ou erros detectados${NC}"
    grep -E "(definitely lost|indirectly lost|ERROR SUMMARY)" valgrind.log
    ((FAILED++))
fi

# ==========================================
# RESULTADO FINAL
# ==========================================
print_header "RESULTADO FINAL"

TOTAL=$((PASSED + FAILED))
PERCENTAGE=$((PASSED * 100 / TOTAL))

echo -e "${BOLD}Total de testes:${NC} $TOTAL"
echo -e "${GREEN}${BOLD}✓ Passaram:${NC} $PASSED"
echo -e "${RED}${BOLD}✗ Falharam:${NC} $FAILED"
echo -e "${CYAN}${BOLD}Taxa de sucesso:${NC} $PERCENTAGE%"

if [ $FAILED -eq 0 ]; then
    echo -e "\n${GREEN}${BOLD}╔═══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}${BOLD}║  🎉  PARABÉNS! TODOS OS TESTES OK!  🎉  ║${NC}"
    echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "\n${RED}${BOLD}╔═══════════════════════════════════════╗${NC}"
    echo -e "${RED}${BOLD}║     ⚠️  ALGUNS TESTES FALHARAM  ⚠️      ║${NC}"
    echo -e "${RED}${BOLD}╚═══════════════════════════════════════╝${NC}"
    exit 1
fi

# Cleanup
rm -f infile out_pipex out_shell infile_sem_permissao outfile_teste valgrind.log 2>/dev/null
