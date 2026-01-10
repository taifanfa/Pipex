#!/bin/bash

# comprehensive_test.sh - Testes Completos para Pipex
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔍 TESTES COMPLETOS PIPEX - AVALIAÇÃO 42"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

passed=0
failed=0
total=0

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

test_case() {
    local name=$1
    local cmd1=$2
    local cmd3=$3
    ((total++))

    echo -n "[$total] $name... "
    # CORRIGIDO: usar eval para interpretar corretamente as aspas
    < infile eval "$cmd1" | eval "$cmd3" > expected 2>/dev/null
    ./pipex infile "$cmd1" "$cmd3" outfile 2>/dev/null

    if diff -q expected outfile > /dev/null 2>&1; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FALHOU${NC}"
        echo "  Expected: $(cat expected | head -1)"
        echo "  Got:      $(cat outfile | head -1)"
        ((failed++))
    fi
}

test_error() {
    local name=$1
    shift
    ((total++))

    echo -n "[$total] ERROR: $name... "
    ./pipex "$@" 2>/dev/null
    local exit_code=$?

    if [ $exit_code -ne 0 ]; then
        echo -e "${GREEN}✅ PASSOU${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FALHOU (deveria dar erro)${NC}"
        ((failed++))
    fi
}

test_exit_code() {
    local name=$1
    local expected_code=$2
    shift 2
    ((total++))

    echo -n "[$total] EXIT CODE: $name... "
    ./pipex "$@" >/dev/null 2>&1
    local exit_code=$?

    if [ $exit_code -eq $expected_code ]; then
        echo -e "${GREEN}✅ PASSOU (exit $exit_code)${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FALHOU (esperado $expected_code, obtido $exit_code)${NC}"
        ((failed++))
    fi
}

echo ""
echo "━━━ CATEGORIA 1: TESTES BÁSICOS ━━━"

echo "test content" > infile
test_case "cat + cat" "cat" "cat"
test_case "cat + wc -l" "cat" "wc -l"
test_case "cat + wc -w" "cat" "wc -w"
test_case "cat + wc -c" "cat" "wc -c"

echo ""
echo "━━━ CATEGORIA 2: GREP E FILTROS ━━━"

echo -e "hello\nworld\nhello again\ntest" > infile
test_case "grep hello + wc -l" "grep hello" "wc -l"
test_case "grep hello + cat" "grep hello" "cat"

echo -e "apple\nbanana\napricot\navocado" > infile
test_case "grep a + wc -l" "grep a" "wc -l"
test_case "grep ^a + wc -l" "grep ^a" "wc -l"

echo ""
echo "━━━ CATEGORIA 3: HEAD E TAIL ━━━"

echo -e "1\n2\n3\n4\n5\n6\n7\n8\n9\n10" > infile
test_case "cat + head -3" "cat" "head -3"
test_case "cat + tail -3" "cat" "tail -3"
test_case "head -5 + tail -2" "head -5" "tail -2"

echo ""
echo "━━━ CATEGORIA 4: SORT E UNIQ ━━━"

echo -e "zebra\napple\nmango\nbanana" > infile
test_case "cat + sort" "cat" "sort"
test_case "sort + head -2" "sort" "head -2"

echo -e "apple\napple\nbanana\napple\ncherry" > infile
test_case "sort + uniq" "sort" "uniq"
test_case "cat + sort" "cat" "sort"

echo ""
echo "━━━ CATEGORIA 5: TR (TRANSFORMAÇÕES) ━━━"

echo "Hello World" > infile
test_case "cat + tr a-z A-Z" "cat" "tr a-z A-Z"
test_case "cat + tr A-Z a-z" "cat" "tr A-Z a-z"

echo "test123test" > infile
test_case "cat + tr -d 0-9" "cat" "tr -d 0-9"

echo ""
echo "━━━ CATEGORIA 6: CUT E AWK ━━━"

echo -e "one:two:three\nfour:five:six" > infile
test_case "cat + cut -d : -f 2" "cat" "cut -d : -f 2"

echo -e "a b c\nd e f" > infile
test_case "cat + awk {print \$2}" "cat" "awk '{print \$2}'"

echo ""
echo "━━━ CATEGORIA 7: LINHAS VAZIAS E ESPECIAIS ━━━"

echo -e "\n\ntest\n\n" > infile
test_case "empty lines + cat + wc -l" "cat" "wc -l"

echo -e "line1\n\nline3" > infile
test_case "mixed empty + cat + grep -v ^$" "cat" "grep -v ^$"

echo "" > infile
test_case "empty file + cat + wc -l" "cat" "wc -l"

echo ""
echo "━━━ CATEGORIA 8: ARQUIVOS GRANDES ━━━"

seq 1 1000 > infile
test_case "1000 lines + cat + wc -l" "cat" "wc -l"
test_case "1000 lines + head -100 + wc -l" "head -100" "wc -l"
test_case "1000 lines + tail -100 + wc -l" "tail -100" "wc -l"

echo ""
echo "━━━ CATEGORIA 9: CARACTERES ESPECIAIS ━━━"

echo "hello world" > infile
test_case "spaces + cat + wc -w" "cat" "wc -w"

echo -e "tab\there" > infile
test_case "tabs + cat + cat" "cat" "cat"

echo "special!@#$%chars" > infile
test_case "special chars + cat + cat" "cat" "cat"

echo ""
echo "━━━ CATEGORIA 10: LS E COMANDOS DO SISTEMA ━━━"

ls > infile
test_case "ls output + cat + wc -l" "cat" "wc -l"
test_case "ls output + grep .c + wc -l" "grep .c" "wc -l"

echo ""
echo "━━━ CATEGORIA 11: SED ━━━"

echo -e "hello\nworld\nhello" > infile
test_case "cat + sed s/hello/hi/" "cat" "sed s/hello/hi/"
test_case "cat + sed s/hello/hi/g" "cat" "sed s/hello/hi/g"

echo ""
echo "━━━ CATEGORIA 12: REV E OUTROS ━━━"

echo "hello" > infile
test_case "cat + rev" "cat" "rev"

echo -e "a\nb\nc" > infile
test_case "cat + sort -r" "cat" "sort -r"

echo ""
echo "━━━ CATEGORIA 13: TESTES DE ERRO ━━━"

test_error "sem argumentos suficientes" infile "cat"
test_error "sem argumentos"
test_error "arquivo inexistente" /tmp/file_does_not_exist_12345 "cat" "wc" outfile
test_error "comando inválido (primeiro)" infile "comando_invalido_xyz" "wc" outfile
test_error "comando inválido (segundo)" infile "cat" "comando_invalido_xyz" outfile

echo ""
echo "━━━ CATEGORIA 14: EXIT CODES ━━━"

echo "test" > infile
test_exit_code "comando válido" 0 infile "cat" "wc" outfile
test_exit_code "argumentos errados" 1 infile "cat"
test_exit_code "comando não encontrado" 127 infile "cmdnotfound" "wc" outfile

echo ""
echo "━━━ CATEGORIA 15: PERMISSÕES ━━━"

echo "test" > infile
chmod 000 infile
test_error "arquivo sem permissão de leitura" infile "cat" "wc" outfile
chmod 644 infile

echo ""
echo "━━━ CATEGORIA 16: CASOS EXTREMOS ━━━"

# Arquivo muito pequeno
echo "a" > infile
test_case "1 char + cat + wc -c" "cat" "wc -c"

# Linha muito longa
python3 -c "print('a' * 10000)" > infile 2>/dev/null || perl -e 'print "a" x 10000' > infile
test_case "linha longa + cat + wc -c" "cat" "wc -c"

# Múltiplas palavras
echo "one two three four five six seven eight nine ten" > infile
test_case "muitas palavras + cat + wc -w" "cat" "wc -w"

echo ""
echo "━━━ CATEGORIA 17: COMANDOS COM MÚLTIPLOS ARGUMENTOS ━━━"

echo -e "apple\nbanana\ncherry" > infile
test_case "grep com -i + wc" "grep -i APPLE" "wc -l"

echo -e "1\n2\n3\n4\n5" > infile
test_case "head -n 3 + tail -n 1" "head -n 3" "tail -n 1"

echo ""
echo "━━━ CATEGORIA 18: WHITESPACE ━━━"

echo "   leading spaces" > infile
test_case "leading spaces + cat + cat" "cat" "cat"

echo "trailing spaces   " > infile
test_case "trailing spaces + cat + cat" "cat" "cat"

echo "     " > infile
test_case "only spaces + cat + wc -c" "cat" "wc -c"

echo ""
echo "━━━ CATEGORIA 19: NÚMEROS ━━━"

echo -e "100\n50\n200\n25\n75" > infile
test_case "números + sort -n + head -1" "sort -n" "head -1"
test_case "números + sort -rn + head -1" "sort -rn" "head -1"

echo ""
echo "━━━ CATEGORIA 20: VERIFICAÇÃO DE LEAKS ━━━"

echo "test" > infile
echo -n "[VALGRIND] Verificando memory leaks... "

if command -v valgrind &> /dev/null; then
    valgrind --leak-check=full --errors-for-leak-kinds=all --error-exitcode=1 \
        ./pipex infile "cat" "wc" outfile > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SEM LEAKS${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ MEMORY LEAKS DETECTADOS${NC}"
        ((failed++))
    fi
    ((total++))
else
    echo -e "${YELLOW}⚠️  VALGRIND NÃO INSTALADO (pulado)${NC}"
fi

echo -n "[VALGRIND] Verificando file descriptor leaks... "

if command -v valgrind &> /dev/null; then
    valgrind --track-fds=yes --error-exitcode=1 \
        ./pipex infile "cat" "wc" outfile > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✅ SEM FD LEAKS${NC}"
        ((passed++))
    else
        echo -e "${RED}❌ FD LEAKS DETECTADOS${NC}"
        ((failed++))
    fi
    ((total++))
else
    echo -e "${YELLOW}⚠️  VALGRIND NÃO INSTALADO (pulado)${NC}"
fi

# Cleanup
rm -f infile expected outfile

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 RESULTADO FINAL"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Total de testes: $total"
echo -e "Passou: ${GREEN}$passed ✅${NC}"
echo -e "Falhou: ${RED}$failed ❌${NC}"

percentage=$((passed * 100 / total))
echo "Taxa de sucesso: $percentage%"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $failed -eq 0 ]; then
    echo -e "${GREEN}"
    echo "🎉🎉🎉 PARABÉNS! TODOS OS TESTES PASSARAM! 🎉🎉🎉"
    echo -e "${NC}"
    echo "Seu pipex está pronto para avaliação! 🚀"
    exit 0
else
    echo -e "${RED}"
    echo "⚠️  ATENÇÃO: $failed teste(s) falharam"
    echo -e "${NC}"
    echo "Revise os erros acima antes da avaliação."
    exit 1
fi
