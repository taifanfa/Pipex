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

static int	count_paths(char *path_env)
{
	int	i;
	int	count;

	i = 0;
	count = 1;
	while (path_env[i])
		if (path_env[i++] == ':')
			count++;
	return (count);
}

static char	*extract_path(char *path_env, int start, int len)
{
	char	*path;
	int		k;

	path = malloc(len + 1);
	if (!path)
		return (NULL);
	k = 0;
	while (k < len)
	{
		path[k] = path_env[start + k];
		k++;
	}
	path[k] = '\0';
	return (path);
}

static void	split_paths(char *path_env, char **paths)
{
	int	i;
	int	j;
	int	start;
	int	len;

	i = 0;
	j = 0;
	start = 0;
	while (path_env[i])
	{
		if (path_env[i] == ':' || path_env[i + 1] == '\0')
		{
			len = i - start + (path_env[i + 1] == '\0' && path_env[i] != ':');
			paths[j++] = extract_path(path_env, start, len);
			start = i + 1;
		}
		i++;
	}
	paths[j] = NULL;
}

char	**get_paths(char **envp)
{
	char	*path_env;
	char	**paths;

	path_env = get_env_path(envp);
	if (!path_env)
		return (NULL);
	paths = malloc(sizeof(char *) * (count_paths(path_env) + 1));
	if (!paths)
		return (NULL);
	split_paths(path_env, paths);
	return (paths);
}
