#ifndef PIPEX_H
# define PIPEX_H

# include <unistd.h>
# include <stdlib.h>
# include <stdio.h>
# include <fcntl.h>
# include <sys/wait.h>
# include <string.h>
# include <errno.h>

typedef struct s_pipex
{
    int     fd[2];
    int     infile;
    int     outfile;
    pid_t   pid1;
    pid_t   pid2;
}   t_pipex;

void	child_process_one(int *fd, char **argv, char **envp, int infile);
void	child_process_two(int *fd, char **argv, char **envp, int outfile);
int		wait_children(pid_t pid1, pid_t pid2);
void	open_files(t_pipex *p, char **argv);
void	close_pipes(t_pipex *p);

int		execute_cmd(char *cmd, char **envp);
char	**get_paths(char **envp);
char	*find_cmd(char **paths, char *cmd);
void	error_and_exit(const char *msg);

char	**ft_split(char const *s, char c);
char	*ft_strdup(const char *s1);
size_t	ft_strlen(const char *s);
char	*ft_strjoin(const char *s1, const char *s2);
int		ft_strncmp(const char *s1, const char *s2, size_t n);

char	*dup_word_quotes(const char *s, int start, int len);
int		get_word_len(const char *s, int start, char c);
int		count_words_quotes(char const *s, char c);
int		is_quote(char c);

void	free_matrix(char **mat);

#endif
