#include "pipex.h"

static void	exec_with_error_handling(char *path, char **args, char **paths, char **envp)
{
	int	exit_code;

	execve(path, args, envp);
	perror("execve");
	if (errno == EACCES)
		exit_code = 126;
	else
		exit_code = 1;
	cleanup_and_exit(path, args, paths, exit_code);
}

void	execute_cmd(char *cmd, char **envp)
{
	char	**args;
	char	**paths;
	char	*path;

	args = parse_cmd(cmd);
	if (!args || !args[0] || args[0][0] == '\0')
	{
		if (args)
			free_matrix(args);
		write(2, "command not found\n", 18);
		exit(127);
	}
	paths = get_paths(envp);
	path = find_cmd(paths, args[0]);
	if (!path)
	{
		write(2, "command not found\n", 18);
		cleanup_and_exit(NULL, args, paths, 127);
	}
	exec_with_error_handling(path, args, paths, envp);
}
