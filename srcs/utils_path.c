#include "pipex.h"

static char	*get_env_path(char **envp)
{
	int	i;

	i = 0;
	while (envp && envp[i])
	{
		if (ft_strncmp(envp[i], "PATH=", 5) == 0)
			return (envp[i] + 5);
		i++;
	}
	return (NULL);
}

char	**get_paths(char **envp)
{
	char	*path_env;

	path_env = get_env_path(envp);
	if (!path_env)
		return (NULL);
	return (ft_split(path_env, ':'));
}

static char *join_path_cmd(char *dir, char *cmd)
{
    char *tmp;
    char *full;

    tmp = ft_strjoin(dir, "/");
    if (!tmp)
        return (NULL);
    full = ft_strjoin(tmp, cmd);
    free(tmp);
    return (full);
}

char	*find_cmd(char **paths, char *cmd)
{
	int		i;
	char	*full;

	if (!cmd)
		return (NULL);
	if (access(cmd, X_OK) == 0)
		return (ft_strdup(cmd));
	if (!paths)
		return (NULL);
	i = 0;
	while (paths[i])
	{
		full = join_path_cmd(paths[i], cmd);
		if (full && access(full, X_OK) == 0)
			return (full);
		if (full)
			free(full);
		i++;
	}
	return (NULL);
}
