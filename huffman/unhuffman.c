#include <stdlib.h>
#include <stdio.h>

#define LETTER 256
#define VERTICES (2 * LETTER - 1)
#define BUFSIZE (1 << 20)
#define TRIE_V (LETTER * LETTER)

short parent[VERTICES];
char letter[VERTICES];

int to[2][TRIE_V];
char trie_letter[TRIE_V];
int trie_used = 1;

char tmpbuf[LETTER];
int tmpbuf_used = 0;

FILE* in;
FILE* out;

char buffer[BUFSIZE];
int buffer_pos = BUFSIZE - 1;
int buffer_pos_2 = 8;

char outbuffer[BUFSIZE];
int outbuffer_pos = 0;

char next_bit()
{
    if (buffer_pos_2 == 8)
    {
        buffer_pos_2 = 0;
        if (buffer_pos == BUFSIZE - 1)
        {
            buffer_pos = 0;
            fread(buffer, 1, BUFSIZE, in);
        } else {
            buffer_pos++;
        }
    }
    return (buffer[buffer_pos] >> buffer_pos_2++) & 1;
}

void print_letter(char ch)
{
    if (outbuffer_pos == BUFSIZE)
    {
        fwrite(outbuffer, 1, BUFSIZE, out);
        outbuffer_pos = 0;
    }
    outbuffer[outbuffer_pos++] = ch;
}

int main(int argc, char** argv)
{
    if (argc != 3)
    {
        printf("need two arguments\n");
        return -1;
    }
    in = fopen(argv[2], "r");
    int len;
    fread(parent, 1, sizeof(parent), in);
    fread(letter, 1, sizeof(letter), in);
    fread(&len, 1, sizeof(len), in);
    int i;
    for (i = 0; i < LETTER; i++)
    {
        int p = i;
        tmpbuf_used = 0;
        while (p != -1)
        {
            tmpbuf[tmpbuf_used++] = letter[p];
            p = parent[p];
        }
        int node = 0; // root
        int j;
        for (j = tmpbuf_used - 1; j >= 0; j--)
        {
            
            if (to[tmpbuf[j]][node] == 0)
                to[tmpbuf[j]][node] = trie_used++;
            node = to[tmpbuf[j]][node];
        }
        trie_letter[node] = i;
    }
    out = fopen(argv[1], "w");
    int node = 0;
    for (i = 0; i < len;)
    {
        if (to[0][node] == 0 && to[1][node] == 0)
        {
            print_letter(trie_letter[node]);
            node = 0;
            i++;
        }
        node = to[next_bit()][node];
    }
    fwrite(outbuffer, 1, outbuffer_pos, out);
    fclose(in);
    fclose(out);
    return 0;
}
