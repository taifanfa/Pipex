#include "pipex.h"

static char	**free_split_array(char **arr, int j)
{
	while (--j >= 0)
		free(arr[j]);
	free(arr);
	return (NULL);
}

static int	add_word_to_array(char **arr, const char *s, int *i, int *j)
{
	int	word_len;

	word_len = get_word_len(s, *i, ' ');
	if (word_len == 0)
	{
		(*i)++;
		return (1);
	}
	arr[*j] = dup_word_quotes(s, *i, word_len);
	if (!arr[*j])
		return (0);
	(*j)++;
	*i += word_len;
	return (1);
}

char	**ft_split(char const *s, char c)
{
	char	**arr;
	int		i;
	int		j;

	if (!s)
		return (NULL);
	arr = malloc(sizeof(char *) * (count_words_quotes(s, c) + 1));
	if (!arr)
		return (NULL);
	i = 0;
	j = 0;
	while (s[i])
	{
		while (s[i] == c)
			i++;
		if (s[i])
		{
			if (!add_word_to_array(arr, s, &i, &j))
				return (free_split_array(arr, j));
		}
	}
	arr[j] = NULL;
	return (arr);
}
