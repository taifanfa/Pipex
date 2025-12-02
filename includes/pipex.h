#ifndef PIPEX_H
# define PIPEX_X

#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>
#include <fcntl.h>
#include <sys/wait.h>
#include <string.h>
#include <errno.h>

/* FUNÇÕES PRINCIPAIS */
int     execute_cmd(char *cmd, char **envp);
char    **get_paths(char **envp);
char    *find_cmd(char **paths, char cmd);
void    error_and_exit(const char *msg);

/* UTILIDADADES STRINGS */

char    **ft_split(char const *s, char c);
char    *ft_strdup(const char *s1);
size_t  ft_strlen(const char *s);
char    *ft_strjoin(const char *s1, const char *s2);

/* FREE */

void    free_matrix(char **mat);

#endif
