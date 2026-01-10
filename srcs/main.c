#include "pipex.h"

static void	fork_first_child(t_pipex *p, char **argv, char **envp)
{
	p->pid1 = fork();
	if (p->pid1 == -1)
		error_and_exit("fork");
	if (p->pid1 == 0)
		child_process_one(p->fd, argv, envp, p->infile);
	if (p->infile >= 0)
		close(p->infile);
}

static void	fork_second_child(t_pipex *p, char **argv, char **envp)
{
	p->pid2 = fork();
	if (p->pid2 == -1)
		error_and_exit("fork");
	if (p->pid2 == 0)
		child_process_two(p->fd, argv, envp, p->outfile);
	if (p->outfile >= 0)
		close(p->outfile);
}

int	main(int argc, char **argv, char **envp)
{
	t_pipex	p;

	if (argc != 5)
	{
		write(2, "Usage: ./pipex infile cmd1 cmd2 outfile\n", 41);
		return (1);
	}
	open_files(&p, argv);
	if (pipe(p.fd) == -1)
		error_and_exit("pipe");
	fork_first_child(&p, argv, envp);
	fork_second_child(&p, argv, envp);
	close_pipes(&p);
	return (wait_children(p.pid1, p.pid2));
}
