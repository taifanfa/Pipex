#include "pipex.h"

int	is_quote(char c)
{
	return (c == '"' || c == '\'');
}

int	count_args(char *cmd)
{
	int		count;
	int		i;
	char	quote;

	count = 0;
	i = 0;
	while (cmd[i])
	{
		while (cmd[i] == ' ')
			i++;
		if (!cmd[i])
			break;
		count++;
		quote = 0;
		while (cmd[i] && (cmd[i] != ' ' || quote))
		{
			if (is_quote(cmd[i]) && !quote)
				quote = cmd[i];
			else if (cmd[i] == quote)
				quote = 0;
			i++;
		}
	}
	return (count);
}

char	*extract_arg(char *start, int len)
{
	char	*arg;
	int		i;
	int		j;
	char	in_quote;

	arg = malloc(len + 1);
	if (!arg)
		return (NULL);
	i = 0;
	j = 0;
	in_quote = 0;
	while (i < len)
	{
		if (is_quote(start[i]) && !in_quote)
			in_quote = start[i];
		else if (start[i] == in_quote)
			in_quote = 0;
		else
			arg[j++] = start[i];
		i++;
	}
	arg[j] = '\0';
	return (arg);
}

int	get_arg_end(char *cmd, int i)
{
	char	quote;

	quote = 0;
	while (cmd[i] && (cmd[i] != ' ' || quote))
	{
		if (is_quote(cmd[i]) && !quote)
			quote = cmd[i];
		else if (cmd[i] == quote)
			quote = 0;
		i++;
	}
	return (i);
}

char	**parse_cmd(char *cmd)
{
	char	**args;
	int		i;
	int		j;
	int		end;

	args = malloc((count_args(cmd) + 1) * sizeof(char *));
	if (!args)
		return (NULL);
	i = 0;
	j = 0;
	while (cmd[i])
	{
		while (cmd[i] == ' ')
			i++;
		if (!cmd[i])
			break;
		end = get_arg_end(cmd, i);
		args[j++] = extract_arg(&cmd[i], end - i);
		if (!args[j - 1])
			return (free_matrix(args), NULL);
		i = end;
	}
	args[j] = NULL;
	return (args);
}
