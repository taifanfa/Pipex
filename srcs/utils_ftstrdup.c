#include "pipex.h"

size_t ft_strlen(const char *s)
{
    size_t  i;

    i = 0;
    while (s && s[i])
        i++;
    return (i);
}

char *ft_strdup(const char *s1)
{
    size_t  len;
    char    *cpy;
    size_t  i;

    len = ft_strlen(s1);
    cpy = malloc(len + 1);
    i = 0;
    if (!cpy)
        return (NULL);
    while (i < len)
    {
        cpy[i] = s1[i];
        i++;
    }
    cpy = '\0';
    return (cpy);
}

char *ft_strjoin(const char *s1, const char *s2)
{
    size_t len1;
    size_t len2;
    char *joined;
    size_t i;

    len1 = ft_strlen(s1);
    len2 = ft_strlen(s2);
    joined = malloc(len1 + len2 + 1);
    i = 0;
    if (!joined)
        return (NULL);
    while (s1 && *s1)
        joined[i++] = *s1++;
    while (s2 && *s2)
        joined[i++] = *s2++;
    joined[i] = '\0';
    return (joined);
}
