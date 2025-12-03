#ifndef PIPEX_H
# define PIPEX_H

# include <unistd.h>
# include <stdlib.h>
# include <stdio.h>
# include <fcntl.h>
# include <sys/wait.h>
# include <errno.h>

typedef struct s_pipex
{
	int		infile;
	int		outfile;
	int		fd[2];
	pid_t	pid1;
	pid_t	pid2;
}	t_pipex;

/* Main functions */
void	init_pipex(t_pipex *pipex, char **argv);
void	first_child(t_pipex *pipex, char **argv, char **envp);
void	second_child(t_pipex *pipex, char **argv, char **envp);
int		parent_process(t_pipex *pipex);

/* Command execution */
void	execute_cmd(char *cmd, char **envp);
int		is_quote(char c);
int		count_args(char *cmd);
char	*extract_arg(char *start, int len);
int		get_arg_end(char *cmd, int i);
char	**parse_cmd(char *cmd);

/* Path utils */
char	**get_paths(char **envp);
char	*find_cmd(char **paths, char *cmd);

/* String utils */
char	**ft_split(char const *s, char c);
char	*ft_strdup(const char *s1);
char	*ft_strjoin(const char *s1, const char *s2);
int		ft_strncmp(const char *s1, const char *s2, size_t n);
size_t	ft_strlen(const char *s);

/* Memory utils */
void	free_matrix(char **mat);
void	cleanup_and_exit(char *path, char **args, char **paths, int code);

/* Error handling */
void	error_and_exit(const char *msg);

#endif
