#include "pipex.h"

void	init_pipex(t_pipex *pipex, char **argv)
{
	pipex->outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (pipex->outfile < 0)
		error_and_exit("outfile");
	pipex->infile = open(argv[1], O_RDONLY);
	if (pipex->infile < 0)
	{
		perror(argv[1]);
		pipex->infile = open("/dev/null", O_RDONLY);
		if (pipex->infile < 0)
			error_and_exit("open /dev/null");
	}
	if (pipe(pipex->fd) == -1)
		error_and_exit("pipe");
}

void	first_child(t_pipex *pipex, char **argv, char **envp)
{
	if (dup2(pipex->infile, STDIN_FILENO) == -1)
		error_and_exit("dup2 infile");
	if (dup2(pipex->fd[1], STDOUT_FILENO) == -1)
		error_and_exit("dup2 pipe write");
	close(pipex->fd[0]);
	close(pipex->fd[1]);
	close(pipex->infile);
	close(pipex->outfile);
	execute_cmd(argv[2], envp);
}

void	second_child(t_pipex *pipex, char **argv, char **envp)
{
	if (dup2(pipex->fd[0], STDIN_FILENO) == -1)
		error_and_exit("dup2 pipe read");
	if (dup2(pipex->outfile, STDOUT_FILENO) == -1)
		error_and_exit("dup2 outfile");
	close(pipex->fd[1]);
	close(pipex->fd[0]);
	close(pipex->infile);
	close(pipex->outfile);
	execute_cmd(argv[3], envp);
}

int	parent_process(t_pipex *pipex)
{
	int	status1;
	int	status2;

	close(pipex->fd[0]);
	close(pipex->fd[1]);
	close(pipex->infile);
	close(pipex->outfile);
	waitpid(pipex->pid1, &status1, 0);
	waitpid(pipex->pid2, &status2, 0);
	if (WIFEXITED(status2))
		return (WEXITSTATUS(status2));
	if (WIFSIGNALED(status2))
		return (128 + WTERMSIG(status2));
	return (1);
}

int	main(int argc, char **argv, char **envp)
{
	t_pipex	pipex;

	if (argc != 5)
	{
		write(2, "Usage: ./pipex infile \"cmd1\" \"cmd2\" outfile\n", 45);
		return (1);
	}
	init_pipex(&pipex, argv);
	pipex.pid1 = fork();
	if (pipex.pid1 < 0)
		error_and_exit("fork");
	if (pipex.pid1 == 0)
		first_child(&pipex, argv, envp);
	pipex.pid2 = fork();
	if (pipex.pid2 < 0)
		error_and_exit("fork");
	if (pipex.pid2 == 0)
		second_child(&pipex, argv, envp);
	return (parent_process(&pipex));
}
