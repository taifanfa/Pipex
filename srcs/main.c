#include "pipex.h"

int main(int argc, char **argv, char **envp)
{
    int     fd[2];
    pid_t   pid1;
    pid_t   pid2;
    int     infile;
    int     outfile;

    if (argc != 5)
    {
        write(2, "Usage: ./pipex infile \"cmd1\" "\cmd2)\" outfile\n", 53);
        return (1);
    }
    infile = open(argv[1], O_RDONLY);
    if (infile < 0)
        error_and_exit("infile");
    outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (outfile < 0)
        error_and_exit("outfile");
    if (pipe(fd) == -1)
        error_and_exit("pipe");
    pid1 = fork();
    if (pid1 == -1)
        error_and_exit("fork");
    if (pid1 == 0)
    {
        dup2(infile, STDIN_FILENO);
        dup2(fd[1], STDOUT_FILENO);
        close(fd[0]);
        close(fd[1]);
        close(infile);
        close(outfile);
        execute_cmd(argv[2], envp);
    }
    pid2 = fork();
    if (pid2 == -1)
        error_and_exit("fork");
    if (pid2 == 0)
    {
        dup2(fd[0], STDIN_FILENO);
        dup2(outfile, STDOUT_FILENO);
        close(fd[1]);
        close(fd[0]);
        close(infile);
        close(outfile);
        execute_cmd(argv[3], envp);
    }
    close(fd[0]);
    close(fd[1]);
    close(infile);
    close(outfile);
    waitpid(pid1, NULL, 0);
    waitpid(pid2, NULL, 0);
    return (0);
}
