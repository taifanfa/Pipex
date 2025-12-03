NAME = pipex
CC = cc
CFLAGS = -Wall -Wextra -Werror
INCLUDES = -Iincludes

SRCS_DIR = srcs
OBJS_DIR = objs

SRCS = $(SRCS_DIR)/main.c \
		$(SRCS_DIR)/exec_cmd.c \
		$(SRCS_DIR)/utils_path.c \
		$(SRCS_DIR)/utils_ftsplit.c \
		$(SRCS_DIR)/utils_ftstrdup.c \
		$(SRCS_DIR)/errors.c \
		$(SRCS_DIR)/utils_cmd.c \
		$(SRCS_DIR)/free_and_cleans.c

OBJS = $(SRCS:$(SRCS_DIR)/%.c=$(OBJS_DIR)/%.o)

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.c includes/pipex.h
	@mkdir -p $(OBJS_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -rf $(OBJS_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
