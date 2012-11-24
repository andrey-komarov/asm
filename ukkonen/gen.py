from random import *

n = 200
alpha = "abcdefghijklmnopqrstuvwxyz"[:2]

print (n)
print ("".join(choice(alpha) for i in range(n)))
