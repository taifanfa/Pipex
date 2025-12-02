#include "pipex.h"

static char *get_env_path(char **envp)
{
    int i;

    i = 0;
    while (envp && envp[i])
    {
        if (ft_strncmp(envp[i], "PATH=", 5) == 0)
            return(envp[i] + 5);
        i++;
    }   
    return (NULL);
}

char    **get_paths(char **envp)
{
    char    *path_env;

    path_env = get_env_path(envp);
    if (!path_env)
        return (NULL);
    return (ft_split(path_env, ':'));
}

char *find_cmd(char **paths, char **cmd)
{
    int     i;
    char    *tmp;
    char    *full;

    if(!cmd)
        return (NULL);
    if (access(cmd, X_OK) == 0)
        return (ft_strdup(cmd));
    i = 0;
    while (paths && paths[i])
    {
        tmp = ft_strjoin(paths[i], "/");
        full = ft_strjoin(tmp, cmd);
        free(tmp);
        if (acess(full, X_OK) == 0)
            return (full);
        free(full);
        i++;
    }
    return (NULL);
}
