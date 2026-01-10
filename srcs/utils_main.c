#include "pipex.h"

void	child_process_one(int *fd, char **argv, char **envp, int infile)
{
	if (infile < 0)
	{
		close(fd[0]);
		close(fd[1]);
		exit(1);
	}
	if (dup2(infile, STDIN_FILENO) == -1)
		error_and_exit("dup2");
	if (dup2(fd[1], STDOUT_FILENO) == -1)
		error_and_exit("dup2");
	close(fd[0]);
	close(fd[1]);
	close(infile);
	execute_cmd(argv[2], envp);
}

void	child_process_two(int *fd, char **argv, char **envp, int outfile)
{
	if (dup2(fd[0], STDIN_FILENO) == -1)
		error_and_exit("dup2");
	if (dup2(outfile, STDOUT_FILENO) == -1)
		error_and_exit("dup2");
	close(fd[1]);
	close(fd[0]);
	close(outfile);
	execute_cmd(argv[3], envp);
}

void	open_files(t_pipex *p, char **argv)
{
	p->infile = open(argv[1], O_RDONLY);
	if (p->infile < 0)
	{
		perror(argv[1]);
		p->infile = -1;
	}
	p->outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (p->outfile < 0)
		error_and_exit("outfile");
}

void	close_pipes(t_pipex *p)
{
	close(p->fd[0]);
	close(p->fd[1]);
}
