#include <stdlib.h>
#include <stdio.h>

#define LETTER 256
#define VERTICES (2 * LETTER - 1)
#define BUFSIZE (1 << 20)
#define TRIE_V (LETTER * LETTER)

typedef unsigned char uchar;

short parent[VERTICES];
uchar letter[VERTICES];

int to_[2][TRIE_V];
uchar trie_letter[TRIE_V];
int trie_used = 1;

uchar tmpbuf[LETTER];
int tmpbuf_used = 0;

FILE* in_;
FILE* out;

uchar buffer[BUFSIZE];
int buffer_pos = BUFSIZE - 1;
int buffer_pos_2 = 8;

uchar outbuffer[BUFSIZE];
int outbuffer_pos = 0;
int len;

extern uchar next_bit_();
uchar next_bit()
{
    return next_bit_();
/*    if (buffer_pos_2 == 8)
    {
        buffer_pos_2 = 0;
        if (buffer_pos == BUFSIZE - 1)
        {
            buffer_pos = 0;
            fread(buffer, 1, BUFSIZE, in_);
        } else {
            buffer_pos++;
        }
    } */
    //return (buffer[buffer_pos] >> buffer_pos_2++) & 1;
}

extern void print_letter_(uchar ch);
void print_letter(uchar ch)
{
    print_letter_(ch);
    /*if (outbuffer_pos == BUFSIZE)
    {
        fwrite(outbuffer, 1, BUFSIZE, out);
        outbuffer_pos = 0;
    } */
    //outbuffer[outbuffer_pos++] = ch;
}

extern main_(int argc, char** argv);
int main(int argc, char** argv)
{
    main_(argc, argv);
/*    if (argc != 3)
    {
        printf("need two arguments\n");
        return -1;
    }
    in_ = fopen(argv[2], "r"); */
    //fread(parent, 1, sizeof(parent), in_);
    //fread(letter, 1, sizeof(letter), in_);
    //fread(&len, 1, sizeof(len), in_);
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
            
            if (to_[tmpbuf[j]][node] == 0)
                to_[tmpbuf[j]][node] = trie_used++;
            node = to_[tmpbuf[j]][node];
        }
        trie_letter[node] = i;
    }
    out = fopen(argv[1], "w");
    int node = 0;
    for (i = 0; i < len;)
    {
        if (to_[0][node] == 0 && to_[1][node] == 0)
        {
            print_letter(trie_letter[node]);
            node = 0;
            i++;
        }
        node = to_[next_bit()][node];
    }
    fwrite(outbuffer, 1, outbuffer_pos, out);
    fclose(in_);
    fclose(out);
    return 0;
}
