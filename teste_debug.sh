#!/bin/bash

echo "=== TESTE 1: AWK ==="
echo -e "a b c\nd e f" > infile
echo "Esperado (shell):"
< infile cat | awk '{print $2}'
echo "Obtido (pipex):"
./pipex infile "cat" "awk '{print \$2}'" outfile
cat outfile
echo "Exit code: $?"
echo ""

echo "=== TESTE 2: Arquivo inexistente ==="
./pipex /tmp/file_does_not_exist_12345 "cat" "wc" outfile 2>&1
echo "Exit code: $?"
echo ""

echo "=== TESTE 3: Comando inválido (primeiro) ==="
echo "test" > infile
./pipex infile "comando_invalido_xyz" "wc" outfile 2>&1
echo "Exit code: $?"
echo ""

echo "=== TESTE 4: Comando inválido (segundo) ==="
echo "test" > infile
./pipex infile "cat" "comando_invalido_xyz" outfile 2>&1
echo "Exit code: $?"
echo ""

echo "=== TESTE 5: Arquivo sem permissão ==="
echo "test" > infile
chmod 000 infile
./pipex infile "cat" "wc" outfile 2>&1
echo "Exit code: $?"
chmod 644 infile
echo ""

rm -f infile outfile
