


#CFLAGS  += -I./
#LDFLAGS +=  

CROSS_COMPILE ?=

CC = $(CROSS_COMPILE)gcc

app=helloworld
appdep=$(app).c

all:$(app)

$(app):$(appdep)
	$(CC) -o $(app) $(appdep) $(LDFLAGS) $(CFLAGS)

clean:
	rm -f $(app).o
	rm -r $(app)

