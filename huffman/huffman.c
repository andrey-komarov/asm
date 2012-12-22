#include <stdio.h>
#include <stdlib.h>

#define BUFSIZE (1<<20)
//const int BUFSIZE = 1 << 20;
#define LETTERS 256
#define VERTICES (LETTERS * 2 - 1)

typedef unsigned char uchar;

//FILE* fout;
//uchar outbuffer[BUFSIZE];
int buffer_used = 0;
int buffer1_used = 0;
uchar preoutbuf[LETTERS];
size_t preoutbuf_used;

size_t freq[256];
uchar buffer[BUFSIZE];
short parent[VERTICES];
uchar letter[VERTICES];
int queue[VERTICES];
int weight[VERTICES];
int qsize = 0;
int used = LETTERS;
FILE* file;
int len = 0;

/* void print(uchar ch)
{
    outbuffer[buffer_used] |= ch << buffer1_used;
    if (++buffer1_used == 8)
    {
        buffer1_used = 0;
        if (++buffer_used == BUFSIZE)
        {
            buffer_used = 0;
            fwrite(outbuffer, 1, BUFSIZE, fout);
        }
        outbuffer[buffer_used] = 0;
    }
} */
extern void print_(uchar ch);
void print(uchar ch)
{
    print_(ch);
}

/* void print_encoded(uchar ch)
{
    int p = ch;
    preoutbuf_used = 0;
    while (p != -1)
    {
        preoutbuf[preoutbuf_used++] = letter[p];
        p = parent[p];
    }
    int i;
    for (i = preoutbuf_used - 1; i >= 0; i--)
    {
        print(preoutbuf[i]);
    }
} */
extern void print_encoded_(uchar ch);
void print_encoded(uchar ch)
{
    print_encoded_(ch);
}

/* void push_(int v, int w)
{
    weight[v] = w;
    queue[qsize++] = v;
} */ 
extern void push_(int v, int w);

/* short pop()
{
    int i;
    int best = 0;
    for (i = 0; i < qsize; i++)
        if (weight[queue[i]] < weight[queue[best]])
            best = i;
    qsize--;
    short tmp;
    tmp = queue[best];
    queue[best] = queue[qsize];
    return tmp;
} */
extern int pop_();
int pop()
{
    return pop_();
}

extern int main_(int argc, char** argv);
int main(int argc, char** argv)
{
    main_(argc, argv);
    /*if (argc != 3)
    {
        printf("need two arguments\n");
        return -1;
    }
    FILE* file = fopen(argv[2], "r"); */
    int size;
    /*while ((size = fread(buffer, 1, BUFSIZE, file)))
    {
        int i;
        for (i = 0; i < size; i++)
            freq[buffer[i]]++;
        len += size;
    } */
    int i;
    /* for (i = 0; i < 256; i++)
    {
        parent[i] = -1;
        push_(i, freq[i]);
    } */
    /*while (qsize != 1)
    {
        int v1 = pop();
        int v2 = pop();
        int w1 = weight[v1];
        int w2 = weight[v2];
        parent[v1] = used;
        parent[v2] = used;
        letter[v1] = 1;
        letter[v2] = 0;
        push_(used++, w1 + w2);
    } */
    // parent[pop()] = -1;

    // fclose(file);
    //file = fopen(argv[2], "r");
    //fout = fopen(argv[1], "w");
    //fwrite(parent, 1, sizeof(parent), fout);
    //fwrite(letter, 1, sizeof(letter), fout);
    //fwrite(&len, 1, sizeof(len), fout);
    /*while ((size = fread(buffer, 1, BUFSIZE, file)))
    {
        size_t i;
        for (i = 0; i < size; i++)
            print_encoded(buffer[i]);
    } */
    /*fwrite(outbuffer, 1, buffer_used + 1, fout);
    fclose(file);
    fclose(fout); */
    return 0; 
}
