ComplexCC=gcc -O2 -Wall
CFLAGS=
LDFLAGS=
EXEC=main
SRC=./src/Mandelbrot.c ./src/main.c
	
OBJ= $(SRC:.cpp=.o)

CFLAGS=

all: $(EXEC)
	./bin/main

main: $(OBJ)
	$(CC) $(CFLAGS) -o ./bin/$@ $^ $(LDFLAGS)

%.o: %.cpp
	$(CC) $(CFLAGS) -o $@ -c $< $(CFLAGS)

.PHONY: clean mrproper

clean: $(OBJ)
	rm *.o

mrproper: clean
	rm $(EXEC)
