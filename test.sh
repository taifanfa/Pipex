#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== PIPEX TESTER ==="

# Prepare test files
echo "Hello World from pipex" > infile
echo -e "line1\nline2\nline3" > infile2

# Test 1
echo -n "Test 1 (basic): "
./pipex infile "cat" "wc -w" outfile 2>/dev/null
RESULT=$(cat outfile)
EXPECTED=$(< infile cat | wc -w)
[ "$RESULT" = "$EXPECTED" ] && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAIL${NC}"

# Test 2
echo -n "Test 2 (invalid cmd): "
./pipex infile "invalidcmd" "wc -l" outfile 2>&1 | grep -q "command not found"
[ $? -eq 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAIL${NC}"

# Test 3
echo -n "Test 3 (no file): "
./pipex noexist "cat" "wc -l" outfile 2>&1 | grep -q "No such file"
[ $? -eq 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAIL${NC}"

# Test 4 - Memory leaks
echo -n "Test 4 (memory): "
valgrind --leak-check=full --error-exitcode=1 ./pipex infile "cat" "wc -w" outfile &>/dev/null
[ $? -eq 0 ] && echo -e "${GREEN}OK${NC}" || echo -e "${RED}FAIL (leaks)${NC}"

# Cleanup
rm -f infile infile2 outfile expected
