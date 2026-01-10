NAME = pipex
CC = gcc
CFLAGS = -Wall -Wextra -Werror
INCLUDES = -I includes

SRCS_DIR = srcs
OBJS_DIR = objs

SRCS = $(SRCS_DIR)/main.c \
       $(SRCS_DIR)/exec_cmd.c \
       $(SRCS_DIR)/errors.c \
       $(SRCS_DIR)/free_utils.c \
       $(SRCS_DIR)/utils_main.c \
       $(SRCS_DIR)/utils_path.c \
       $(SRCS_DIR)/utils_wait.c \
       $(SRCS_DIR)/utils_ftsplit.c \
       $(SRCS_DIR)/utils_ftsplit_helper.c \
       $(SRCS_DIR)/utils_ftsplit_main.c \
	   $(SRCS_DIR)/find_cmd.c \
       $(SRCS_DIR)/utils_ftstrdup.c \
       $(SRCS_DIR)/utils_quotes.c

OBJS = $(patsubst $(SRCS_DIR)/%.c,$(OBJS_DIR)/%.o,$(SRCS))

all: $(NAME)

$(NAME): $(OBJS)
	$(CC) $(CFLAGS) $(OBJS) -o $(NAME)

$(OBJS_DIR)/%.o: $(SRCS_DIR)/%.c
	@mkdir -p $(OBJS_DIR)
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

clean:
	rm -rf $(OBJS_DIR)

fclean: clean
	rm -f $(NAME)

re: fclean all

.PHONY: all clean fclean re
