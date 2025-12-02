#include "pipex.h"

void    free_matrix(char **mat)
{
    int i;

    i = 0;
    if (!mat)
        return ;
    while (mat[i])
    {
        free(mat[i]);
        i++;
    }
    free(mat);
}
