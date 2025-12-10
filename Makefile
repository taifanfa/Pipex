NAME = pipex
CC = gcc
CFLAGS = -Wall -Wextra -Werror
INCLUDES = -I includes

SRCS = srcs/main.c \
		srcs/exec_cmd.c \
		srcs/utils_path.c \
		srcs/utils_ftsplit.c \
		srcs/utils_ftstrdup.c \
		srcs/errors.c \
		srcs/free_utils.c \
		srcs/utils_main.c

OBJS = $(SRCS:.c=.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -f $(OBJS)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re