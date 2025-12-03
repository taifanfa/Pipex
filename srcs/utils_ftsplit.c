#include "pipex.h"

static int	count_words(char const *s, char c)
{
	int	count;
	int	in_word;

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

static char	*dup_word(const char *s, int start, int end)
{
	char	*word;
	int		i;

	i = 0;
	word = malloc(end - start + 1);
	if (!word)
		return (NULL);
	while (start < end)
		word[i++] = s[start++];
	word[i] = '\0';
	return (word);
}

static char	**free_split_partial(char **arr, int last)
{
	int	i;

	i = 0;
	while (i <= last)
		free(arr[i++]);
	free(arr);
	return (NULL);
}

static int	process_split(char const *s, char c, char **arr)
{
	int	i;
	int	j;
	int	start;

	i = 0;
	j = 0;
	start = -1;
	while (s[i])
	{
		if (s[i] != c && start < 0)
			start = i;
		else if ((s[i] == c || s[i + 1] == '\0') && start >= 0)
		{
			if (s[i] == c)
				arr[j] = dup_word(s, start, i);
			else
				arr[j] = dup_word(s, start, i + 1);
			if (!arr[j])
    			return ((int)(free_split_partial(arr, j - 1) == NULL));
			j++;
			start = -1;
		}
		i++;
	}
	return (1);
}

char	**ft_split(char const *s, char c)
{
	char	**arr;
	int		words;

	if (!s)
		return (NULL);
	words = count_words(s, c);
	arr = malloc((words + 1) * sizeof(char *));
	if (!arr)
		return (NULL);
	if (!process_split(s, c, arr))
		return (NULL);
	arr[words] = NULL;
	return (arr);
}
