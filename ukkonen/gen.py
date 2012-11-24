from random import *

n = 1000000
alpha = "abcdefghijklmnopqrstuvwxyz"[:]

print (n)
print ("".join(choice(alpha) for i in range(n)))
