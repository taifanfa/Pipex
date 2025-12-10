/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: tmorais- <tmorais-@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/12/02 14:07:08 by tmorais-          #+#    #+#             */
/*   Updated: 2025/12/10 14:44:55 by tmorais-         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

int	main(int argc, char **argv, char **envp)
{
	t_pipex	p;

	if (argc != 5)
		return (write(2, "Usage: ./pipex infile cmd1 cmd2 outfile\n", 41), 1);
	open_files(&p, argv);
	if (pipe(p.fd) == -1)
		error_and_exit("pipe");
	p.pid1 = fork();
	if (p.pid1 == -1)
		error_and_exit("fork");
	if (p.pid1 == 0)
		child_process_one(p.fd, argv, envp, p.infile);
	p.pid2 = fork();
	if (p.pid2 == -1)
		error_and_exit("fork");
	if (p.pid2 == 0)
		child_process_two(p.fd, argv, envp, p.outfile);
	close_pipes(&p);
	return (wait_children(p.pid1, p.pid2));
}
