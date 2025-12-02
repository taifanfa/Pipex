#include "pipex.h"

int execute_cmd(char *cmd, char **envp)
{
    char    **args;
    char    **paths;
    char    *path;

    args = ft_split(cmd, ' ');
    if (!args || !args[0])
        error_and_exit("split args");
    paths = get_paths(envp);
    path = find_cmd(paths, args[0]);
    if (!path)
    {
        write(2, "command not found\n", 18);
        free_matrix(args);
        free_matrix(paths);
        exit(127);
    }
    execve(path, args, envp);
    perror("exceve");
    free(path);
    free_matrix(args);
    free_matrix(paths);
    exit(errno);
}
