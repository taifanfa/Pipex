#include "pipex.h"

static void	copy_with_quotes(const char *s, int *i, char *w, int *j, char *q)
{
	if (s[*i] == '\\' && s[*i + 1] && *q != '\'')
	{
		w[(*j)++] = s[*i + 1];
		*i += 2;
		return ;
	}
	if (is_quote(s[*i]) && !(*q))
	{
		*q = s[*i];
		(*i)++;
		return ;
	}
	if (s[*i] == *q)
	{
		*q = 0;
		(*i)++;
		return ;
	}
	w[(*j)++] = s[(*i)++];
}

char	*dup_word_quotes(const char *s, int start, int len)
{
	char	*word;
	int		i;
	int		j;
	char	quote;

	word = malloc(len + 1);
	if (!word)
		return (NULL);
	i = 0;
	j = 0;
	quote = 0;
	while (i < len)
		copy_with_quotes(&s[start], &i, word, &j, &quote);
	word[j] = '\0';
	return (word);
}
