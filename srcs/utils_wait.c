#include "pipex.h"

int	wait_children(pid_t pid1, pid_t pid2)
{
	int	status1;
	int	status2;
	int	exit_code;

	status1 = 0;
	status2 = 0;
	waitpid(pid1, &status1, 0);
	waitpid(pid2, &status2, 0);

	/* Sempre retorna exit code do segundo comando (comportamento shell) */
	if (WIFEXITED(status2))
		exit_code = WEXITSTATUS(status2);
	else
		exit_code = 1;

	/* ÚNICA MUDANÇA: Se segundo teve sucesso MAS primeiro falhou,
	   retorna erro do primeiro (para casos de arquivo inexistente) */
	if (exit_code == 0 && WIFEXITED(status1) && WEXITSTATUS(status1) != 0)
		exit_code = WEXITSTATUS(status1);

	return (exit_code);
}
