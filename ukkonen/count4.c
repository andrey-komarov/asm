#include <assert.h>
#include <stdio.h>
#include <stdlib.h>

#define left ololeft
#define right oloright

typedef int edge;
typedef int vertex;

int INF;
static const int ALPHA = 26;
char* s;
edge **edges;
vertex* suf;
int* vdepth;
int vertices = 0;
vertex *from, *to;
int *left, *right;

vertex hell;
vertex root;
vertex current_vertex;
edge current_edge;
int depth;
vertex last_vertex;
int last_depth;
edge last_edge;
int current_letter;
int edgesCnt = 0;

void print_stats()
{
    printf("Edges:\n");
    int i, j;
    for (i = 0; i < vertices; i++)
    {
        for (j = 0; j < 26; j++)
            printf("%d,", edges[i][j]);
        printf("\n");
    }
    printf("Suffices:\n");
    for (i = 0; i < vertices; i++)
        printf("%d,",suf[i]);
    printf("Curr: V:%d, E:%d // Last: V%d, E:%d, D:%d", current_vertex, current_edge, last_vertex, last_edge, last_depth);
    printf("\n");
    printf("Left:");
    for (i = 0;i < edgesCnt; i++)
        printf("%d,", left[i]);
    printf("Right:");
    for (i = 0; i < edgesCnt;i++)
        printf("%d,", right[i]);
    printf("\n\n");
}

void fill(int* a, int n, int val)
{
    int i;
    for (i = 0; i < n; i++)
        a[i] = val;
}

int newVertex(int d) 
{
    int i = vertices++;
    vdepth[i] = d;
    fill(edges[i], ALPHA, -1);
    suf[i] = -1;
    return i;
}


int newEdge(vertex f, int l)
{
    int i = edgesCnt++;
    from[i] = f;
    to[i] = newVertex(INF);
    left[i] = l;
    right[i] = INF;
    return i;
}

int newEdge2(vertex f, vertex t, int lft, int rght)
{
    int i = edgesCnt++;
    from[i] = f;
    to[i] = t;
    left[i] = lft;
    right[i] = rght;
    return i;
}

int length(edge e)
{
    return right[e] - left[e];
}

int can_go(int ch)
{
    if (current_vertex != -1)
        return edges[current_vertex][ch] != -1;
    if (current_edge != -1)
        return s[left[current_edge] + depth] == ch;
    assert (0);
}

void go(int ch)
{
    if (current_vertex != -1)
    {
        current_edge = edges[current_vertex][ch];
        depth = 1;
        current_vertex = -1;
    }
    else if (current_edge != -1)
        depth++;
    if (current_edge != -1 && left[current_edge] + depth == right[current_edge])
    {
        current_vertex = to[current_edge];
        current_edge = -1;
        depth = 0;
    }
}

void create_new_leaf_here(int ch)
{
    assert (!can_go(ch));
    if (current_vertex != -1)
        edges[current_vertex][ch] = newEdge(current_vertex, current_letter);
    else if (current_edge != -1)
    {
        vertex new_vertex = newVertex(vdepth[from[current_edge]] + depth);
        if (last_vertex != -1)
        {
            suf[last_vertex] = new_vertex;
            last_vertex = -1;
        }

        edge new_edge = newEdge2(new_vertex, to[current_edge], left[current_edge] + depth, right[current_edge]);
        int old_symbol = s[left[new_edge]];
        edges[new_vertex][old_symbol] = new_edge;
        edges[new_vertex][ch] = newEdge(new_vertex, current_letter);
        to[current_edge] = new_vertex;
        right[current_edge] = left[current_edge] + depth;
        current_vertex = new_vertex;
        last_edge = current_edge;
        last_depth = depth;
        current_edge = -1;
        depth = 0;
        last_vertex = new_vertex;
    }
}

void jump_suffix_link()
{
    assert (current_vertex != -1);
    if (suf[current_vertex] != -1)
        current_vertex = suf[current_vertex];
    else
    {
        int need_left = left[last_edge];
        int need_right = need_left + last_depth;
        vertex now = suf[from[last_edge]];
        current_edge = edges[now][(int)s[need_left]];
        while (need_right - need_left > length(current_edge))
        {
            need_left += length(current_edge);
            current_edge = edges[to[current_edge]][(int)s[need_left]];
        }
        if (need_right - need_left == length(current_edge))
        {
            current_vertex = to[current_edge];
            current_edge = -1;
            if (last_vertex != -1)
            {
                suf[last_vertex] = current_vertex;
                last_vertex = -1;
            }
        }
        else
        {
            current_vertex = -1;
            depth = need_right - need_left;
        }
    }
}

void append(int ch)
{
    while (!can_go(ch))
    {
        create_new_leaf_here(ch);
        jump_suffix_link();
    }
    go(ch);
    print_stats();
}

void suffix_tree(int n) 
{
    hell = newVertex(-1);
    root = newVertex(0);
    current_vertex = root;
    current_edge = -1;
    last_vertex = -1;
    INF = n;
    int i;
    for (i = 0; i < n; i++)
        s[i] -= 'a';
    edge from_hell = newEdge2(hell, root, -1, 0);
    for (i = 0; i < ALPHA; i++)
        edges[hell][i] = from_hell;
    suf[hell] = hell;
    suf[root] = hell;

    print_stats();

    for (current_letter = 0; current_letter < n; current_letter++)
        append(s[current_letter]);
}

long long traverse2(vertex v)
{
    long long ans = 1;
    int i;
    for (i = 0; i < ALPHA; i++)
        if (edges[v][i] != -1)
        {
            edge e = edges[v][i];
            ans += length(e) - 1;
            ans += traverse2(to[e]);
        }
	return ans;
}

long long traverse()
{
    return traverse2(root);
}


int main()
{
    FILE* in = fopen("count.in", "r");
    int n;
    fscanf(in, "%d\n", &n);
    suf = (int*)malloc(8 * n);
    from = (int*)malloc(8 * n);
    to = (int*)malloc(8 * n);
    left = (int*)malloc(8 * n);
    right = (int*)malloc(8 * n);
    s = (char*)malloc(4 * n);
    vdepth = (int*)malloc(8 * n);
    int *tmp = (int*)malloc(8 * 8 * n * ALPHA);
    edges = (int**)malloc(8 * n);
    int i;
    for (i = 0; i < 2 * n; i++)
        edges[i] = tmp + 8 * 26 * i;
    fscanf(in, "%s", s);
    fclose(in);
    suffix_tree(n);
    printf("%lld\n", traverse() - 1);
    return 0;
}
