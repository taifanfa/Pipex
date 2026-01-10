#include "pipex.h"

static void	skip_word(const char *s, int *i, char c)
{
	char	quote;
	int		iterations;

	quote = 0;
	iterations = 0;
	while (s[*i] && (s[*i] != c || quote))
	{
		iterations++;
		if (iterations > 1000)
			exit(1);
		if (s[*i] == '\\' && s[*i + 1])
			*i += 2;
		else if (is_quote(s[*i]) && !quote)
		{
			quote = s[*i];
			(*i)++;
		}
		else if (s[*i] == quote)
		{
			quote = 0;
			(*i)++;
		}
		else
			(*i)++;
	}
}

int	count_words_quotes(char const *s, char c)
{
	int		count;
	int		i;

	count = 0;
	i = 0;
	while (s[i])
	{
		while (s[i] == c)
			i++;
		if (s[i])
		{
			count++;
			skip_word(s, &i, c);
		}
	}
	return (count);
}

static int	handle_char(const char *s, int start, int *len, char *quote, char c)
{
	if (s[start + *len] == '\\' && s[start + *len + 1])
	{
		*len += 2;
		return (1);
	}
	if (is_quote(s[start + *len]) && !(*quote))
	{
		*quote = s[start + *len];
		(*len)++;
		return (1);
	}
	if (s[start + *len] == *quote)
	{
		*quote = 0;
		(*len)++;
		return (1);
	}
	if (s[start + *len] == c && !(*quote))
		return (0);
	(*len)++;
	return (1);
}

int	get_word_len(const char *s, int start, char c)
{
	int		len;
	char	quote;

	if (!s)
		return (0);
	len = 0;
	quote = 0;
	while (s[start + len])
	{
		if (!handle_char(s, start, &len, &quote, c))
			break ;
	}
	return (len);
}
