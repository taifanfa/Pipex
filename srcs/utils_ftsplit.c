#include "pipex.h"

static int count_words(char const *s, char c)
{
    int count;
    int in_word;

    count = 0;
    in_word = 0;
    while (*s)
    {
        if (*s != c && !in_word)
        {
            in_word = 1;
            count++;
        }
        else if (*s == c)
            in_word = 0;
        s++;
    }
    return (count);
}

static char *dup_word(const char *s, int start, int end)
{
    char *word;
    int i;

    i = 0;
    word = malloc(end - start + 1);
    if (!word)
        return (NULL);
    while (start < end)
        word[i++] = s[start++];
    word[i] = '\0';
    return (word);
}

char **ft_split(char const *s, char c)
{
    char **arr;
    int i;
    int j;
    int start;

    i = 0;
    j = 0;
    start = -1;
    if (!s)
        return (NULL);
    arr = malloc(sizeof(char *) * (count_words(s, c) + 1));
    if (!arr)
        return (NULL);
    while (s[i])
    {
        if (s[i] != c && start < 0)
           start = i;
        else if ((s[i] == c || s[i + 1] == '\0') && start >= 0)
        {
            arr[j++] = dup_word(s, start, (s[i] == c ? i : i + 1));
            start = -1;
        }
        i++;
    }
    arr[j] = NULL;
    return (arr);
}
