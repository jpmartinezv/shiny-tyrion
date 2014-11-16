all: compile interpreter
	
run:
	./interpreter

compile: gen clear interpreter.tab.c
	gcc -o interpreter interpreter.tab.c

gen: interpreter.y
	bison interpreter.y

clear: interpreter
	rm interpreter
