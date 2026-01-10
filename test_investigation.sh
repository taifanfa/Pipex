#!/bin/bash

echo "=== INVESTIGAÇÃO DO TESTE AWK ==="
echo ""

echo "1. O que o SHELL faz com o teste:"
echo -e "a b c\nd e f" > infile

echo "Comando no shell (como o teste faz):"
cmd1="cat"
cmd3="awk '{print \$2}'"
echo "cmd3 = $cmd3"

echo ""
echo "Executando: < infile $cmd1 | $cmd3"
< infile $cmd1 | $cmd3 > expected
echo "Resultado:"
cat expected
echo ""

echo "2. O que DEVERIA acontecer (sem escape):"
< infile cat | awk '{print $2}' > correct
echo "Resultado correto:"
cat correct
echo ""

echo "3. Comparação:"
if diff -q expected correct > /dev/null 2>&1; then
    echo "✅ SÃO IGUAIS"
else
    echo "❌ SÃO DIFERENTES"
    echo "Expected tem: '$(cat expected)'"
    echo "Correct tem: '$(cat correct)'"
fi

echo ""
echo "4. O que o Pipex recebe:"
echo "Argumento: awk '{print \$2}'"
echo "           awk '{print $2}'"

echo ""
echo "5. Teste manual do pipex:"
./pipex infile "cat" "awk '{print \$2}'" outfile 2>/dev/null
echo "Pipex produziu:"
cat outfile

rm -f infile expected correct outfile
