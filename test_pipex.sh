#!/bin/bash

# test_pipex.sh
echo "🧪 Testando Pipex..."

passed=0
failed=0

test_case() {
    local name=$1
    local cmd1=$2
    local cmd3=$3

    echo -n "Test: $name... "
    < infile $cmd1 | $cmd3 > expected
    ./pipex infile "$cmd1" "$cmd3" outfile 2>/dev/null

    if diff -q expected outfile > /dev/null 2>&1; then
        echo "✅ PASSOU"
        ((passed++))
    else
        echo "❌ FALHOU"
        echo "  Expected:"
        cat expected | head -3
        echo "  Got:"
        cat outfile | head -3
        ((failed++))
    fi
}

# Setup inicial
echo -e "linha1\nlinha2\nlinha3\nhello\nworld" > infile

# Testes básicos
test_case "cat + wc -l" "cat" "wc -l"
test_case "cat + wc -w" "cat" "wc -w"
test_case "grep linha + wc -l" "grep linha" "wc -l"
test_case "cat + head -2" "cat" "head -2"
test_case "cat + tail -2" "cat" "tail -2"

# Testes com echo
echo "Testing with echo commands..."

echo -e "apple\nbanana\ncherry" > infile
test_case "echo fruits + cat" "cat" "cat"

echo -e "1\n2\n3\n4\n5" > infile
test_case "numbers + cat + wc -l" "cat" "wc -l"

echo -e "hello world\ntest line\nfoo bar" > infile
test_case "multi word + cat + wc -w" "cat" "wc -w"

echo -e "AAA\nBBB\nCCC" > infile
test_case "uppercase + cat + wc -c" "cat" "wc -c"

echo -e "test\ntest\ntest\nother" > infile
test_case "duplicates + cat + sort" "cat" "sort"

echo -e "zebra\napple\nmango" > infile
test_case "unsorted + cat + sort" "cat" "sort"

echo "Hello World 123" > infile
test_case "single line + cat + wc -c" "cat" "wc -c"

echo -e "a b c\nd e f\ng h i" > infile
test_case "columns + cat + wc -w" "cat" "wc -w"

echo -e "test line 1\ntest line 2\nnot matching" > infile
test_case "pattern + grep test + wc -l" "grep test" "wc -l"

echo -e "100\n50\n200\n25" > infile
test_case "numbers + cat + sort -n" "cat" "sort -n"

echo "one two three four five" > infile
test_case "words + cat + wc -w" "cat" "wc -w"

echo -e "a\nb\nc\nd\ne\nf\ng\nh\ni\nj" > infile
test_case "alphabet + cat + head -5" "cat" "head -5"

echo -e "line1\nline2\nline3\nline4\nline5" > infile
test_case "lines + cat + tail -3" "cat" "tail -3"

echo "UPPER lower MiXeD" > infile
test_case "mixed case + cat + tr A-Z a-z" "cat" "tr A-Z a-z"

echo -e "hello\nworld\nhello\ntest\nhello" > infile
test_case "repeated + grep hello + wc -l" "grep hello" "wc -l"

echo -e "aaa\nbbb\naaa\nccc\naaa" > infile
test_case "count aaa + grep aaa + wc -l" "grep aaa" "wc -l"

echo "   spaces   around   words   " > infile
test_case "spaces + cat + wc -w" "cat" "wc -w"

echo -e "\n\n\ntest\n\n" > infile
test_case "empty lines + cat + wc -l" "cat" "wc -l"

echo -e "first\nsecond\nthird" > infile
test_case "three lines + cat + head -1" "cat" "head -1"

echo -e "alpha\nbeta\ngamma\ndelta" > infile
test_case "greek + cat + tail -1" "cat" "tail -1"

# Cleanup
rm -f infile expected outfile

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Resultado Final: $passed ✅ passou, $failed ❌ falhou"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ $failed -eq 0 ]; then
    echo "🎉 Todos os testes passaram!"
    exit 0
else
    echo "⚠️  Alguns testes falharam."
    exit 1
fi
