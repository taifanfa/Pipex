/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils_ftsplit.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tmorais- <tmorais-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/12/10 14:57:26 by tmorais-          #+#    #+#             */
/*   Updated: 2025/12/10 14:59:11 by tmorais-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

static int	is_quote(char c)
{
	return (c == '\'' || c == '"');
}

static int	count_words_quotes(char const *s, char c)
{
	int		count;
	int		in_word;
	char	quote;

	count = 0;
	in_word = 0;
	quote = 0;
	while (*s)
	{
		if (is_quote(*s) && !quote)
			quote = *s;
		else if (*s == quote)
			quote = 0;
		else if (*s != c && !in_word && !quote)
		{
			in_word = 1;
			count++;
		}
		else if (*s == c && !quote)
			in_word = 0;
		s++;
	}
	return (count);
}

static int	get_word_len(const char *s, int start, char c)
{
	int		len;
	char	quote;

	len = 0;
	quote = 0;
	while (s[start + len])
	{
		if (is_quote(s[start + len]) && !quote)
			quote = s[start + len];
		else if (s[start + len] == quote)
			quote = 0;
		else if (s[start + len] == c && !quote)
			break ;
		len++;
	}
	return (len);
}

static char	*dup_word_quotes(const char *s, int start, int len)
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
	{
		if (is_quote(s[start + i]) && !quote)
			quote = s[start + i];
		else if (s[start + i] == quote)
			quote = 0;
		else
			word[j++] = s[start + i];
		i++;
	}
	word[j] = '\0';
	return (word);
}

char	**ft_split(char const *s, char c)
{
	char	**arr;
	int		i;
	int		j;
	int		word_len;

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
			word_len = get_word_len(s, i, c);
			arr[j++] = dup_word_quotes(s, i, word_len);
			i += word_len;
		}
	}
	arr[j] = NULL;
	return (arr);
}
