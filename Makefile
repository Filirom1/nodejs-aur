all:
	coffee -o lib -c src

clean:
	rm lib/*.js
