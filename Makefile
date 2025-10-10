all:
	gcc -Wall -O2 -o /vector/output/q1-vector /vector/q1-vector.c
	gcc -Wall -O2 -o /uf8/output/q1-uf8 /uf8/q1-uf8.c
	gcc -Wall -O2 -o /bfloat16/output/q1-bfloat16 /bfloat16/q1-bfloat16.c

clean:
	rm -f /vector/output/q1-vector /uf8/output/q1-uf8 /bfloat16/output/q1-bfloat16
