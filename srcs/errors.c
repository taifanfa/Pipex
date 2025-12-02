#include "pipex.h"

void    error_and_exit(const char *msg)
{
    if (msg)
        perror(msg);
    exit(EXIT_FAILURE);
}
