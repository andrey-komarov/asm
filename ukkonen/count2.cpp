#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <cassert>

#define left ololeft
#define right oloright

using namespace std;

typedef int edge;
typedef int vertex;

size_t ID = 0;
const int N = 100;
const int M = 100;
size_t INF;
static const size_t ALPHA = 26;
string s;
edge edges[N][ALPHA];
vertex suf[N];
size_t id[N];
size_t vdepth[N];
size_t vertices = 0;

vertex hell;
vertex root;
vertex current_vertex;
edge current_edge;
size_t depth;
vertex last_vertex;
size_t last_depth;
edge last_edge;
size_t current_letter;

int newVertex(size_t d) 
{
    int i = vertices++;
    id[i] = ID++;
    vdepth[i] = d;
    fill(edges[i], edges[i] + ALPHA, -1);
    suf[i] = -1;
    return i;
}

vertex from[M], to[M];
size_t left[M], right[M];

int edgesCnt = 0;
int newEdge(vertex f, size_t l)
{
    int i = edgesCnt++;
    from[i] = f;
    to[i] = newVertex(INF);
    left[i] = l;
    right[i] = INF;
    return i;
}

int newEdge(vertex f, vertex t, size_t lft, size_t rght)
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

bool can_go(int ch)
{
    if (current_vertex != -1)
        return edges[current_vertex][ch] != -1;
    if (current_edge != -1)
        return s[left[current_edge] + depth] == ch;
    assert (false);
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

        edge new_edge = newEdge(new_vertex, to[current_edge], left[current_edge] + depth, right[current_edge]);
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
        size_t need_left = left[last_edge];
        size_t need_right = need_left + last_depth;
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
}

void suffix_tree(string ss) 
{
    s = ss;
    hell = newVertex(-1);
    root = newVertex(0);
    current_vertex = root;
    current_edge = -1;
    last_vertex = -1;
    INF = s.size();
    for (size_t i = 0; i < s.size (); i++)
        s[i] -= 'a';
    edge from_hell = newEdge(hell, root, -1, 0);
    for (size_t i = 0; i < ALPHA; i++)
        edges[hell][i] = from_hell;
    suf[hell] = hell;
    suf[root] = hell;

    for (current_letter = 0; current_letter < s.size (); current_letter++)
        append(s[current_letter]);
}

long long traverse(vertex v)
{
    long long ans = 1;
    for (size_t i = 0; i < ALPHA; i++)
        if (edges[v][i] != -1)
        {
            edge e = edges[v][i];
            ans += length(e) - 1;
            ans += traverse(to[e]);
        }
	return ans;
}

long long traverse()
{
    return traverse(root);
}


int main()
{
    ifstream in("count.in");
    ofstream out("count.out");
    string s;
    in >> s;
    suffix_tree(s);
    out << traverse() - 1 << "\n";
}
