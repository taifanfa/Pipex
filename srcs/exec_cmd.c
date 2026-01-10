#include "pipex.h"

static void	handle_cmd_error(char **args, char **paths)
{
	write(2, args[0], ft_strlen(args[0]));
	write(2, ": command not found\n", 20);
	free_matrix(args);
	free_matrix(paths);
	exit(127);
}

static void	handle_execve_error(char *path, char **args, char **paths)
{
	perror("execve");
	free(path);
	free_matrix(args);
	free_matrix(paths);
	exit(126);
}

/* NOVA FUNÇÃO - detecta se comando precisa de shell */
static int	needs_shell(char *cmd)
{
	int	i;

	i = 0;
	while (cmd && cmd[i])
	{
		if (cmd[i] == '\'' || cmd[i] == '"' || cmd[i] == '{' || cmd[i] == '}')
			return (1);
		i++;
	}
	return (0);
}

/* NOVA FUNÇÃO - executa comando via shell */
static void	execute_via_shell(char *cmd, char **envp)
{
	char	**args;

	args = malloc(sizeof(char *) * 4);
	if (!args)
		exit(127);
	args[0] = ft_strdup("/bin/sh");
	args[1] = ft_strdup("-c");
	args[2] = ft_strdup(cmd);
	args[3] = NULL;
	if (!args[0] || !args[1] || !args[2])
	{
		free_matrix(args);
		exit(127);
	}
	execve("/bin/sh", args, envp);
	free_matrix(args);
	exit(127);
}

int	execute_cmd(char *cmd, char **envp)
{
	char	**args;
	char	**paths;
	char	*path;

	/* SE TEM ASPAS OU CHAVES, USA SHELL */
	if (needs_shell(cmd))
		execute_via_shell(cmd, envp);

	/* RESTO DO CÓDIGO ORIGINAL */
	args = ft_split(cmd, ' ');
	if (!args || !args[0])
	{
		write(2, "Error: empty command\n", 21);
		if (args)
			free_matrix(args);
		exit(127);
	}
	paths = get_paths(envp);
	path = find_cmd(paths, args[0]);
	if (!path)
		handle_cmd_error(args, paths);
	execve(path, args, envp);
	handle_execve_error(path, args, paths);
	return (1);
}
