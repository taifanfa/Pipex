/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils_main.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tmorais- <tmorais-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/12/10 14:45:05 by tmorais-          #+#    #+#             */
/*   Updated: 2025/12/10 14:47:06 by tmorais-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

void	child_process_one(int *fd, char **argv, char **envp, int infile)
{
	dup2(infile, STDIN_FILENO);
	dup2(fd[1], STDOUT_FILENO);
	close(fd[0]);
	close(fd[1]);
	close(infile);
	execute_cmd(argv[2], envp);
}

void	child_process_two(int *fd, char **argv, char **envp, int outfile)
{
	dup2(fd[0], STDIN_FILENO);
	dup2(outfile, STDOUT_FILENO);
	close(fd[1]);
	close(fd[0]);
	close(outfile);
	execute_cmd(argv[3], envp);
}

int	wait_children(pid_t pid1, pid_t pid2)
{
	int	status1;
	int	status2;

	waitpid(pid1, &status1, 0);
	waitpid(pid2, &status2, 0);
	if (WIFEXITED(status1) && WEXITSTATUS(status1) != 0)
		return (WEXITSTATUS(status1));
	if (WIFEXITED(status2))
		return (WEXITSTATUS(status2));
	return (1);
}

void	open_files(t_pipex *p, char **argv)
{
	p->infile = open(argv[1], O_RDONLY);
	if (p->infile < 0)
		error_and_exit("infile");
	p->outfile = open(argv[4], O_CREAT | O_WRONLY | O_TRUNC, 0644);
	if (p->outfile < 0)
		error_and_exit("outfile");
}

void	close_pipes(t_pipex *p)
{
	close(p->fd[0]);
	close(p->fd[1]);
	close(p->infile);
	close(p->outfile);
}
