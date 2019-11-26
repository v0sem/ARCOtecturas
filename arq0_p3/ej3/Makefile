LIBS =
LIB_DIR =
FLAGS = -g -Wall -D_GNU_SOURCE

.PHONY: clean all

all: fast slow mult_matrix mult_trans

mult_trans: mult_trans.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

mult_matrix: mult_matrix.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

fast: fast.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

slow: slow.c arqo3.c
	gcc $(FLAGS) $(LIB_DIR) -o $@ $^ $(LIBS)

clean:
	rm -f *.o *~ fast slow mult_matrix mult_trans
