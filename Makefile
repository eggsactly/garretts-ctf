# Compiler 
CC?=gcc
# name of example executable 
EXE:=garretts-ctf
# This make file will build every file it sees in the directory ending with a 
# .c extension 
SRC_EXTENSION:=c
OBJ_EXTENSION:=o
OBJ_DIR:=obj

# Character separating directory levels can be OS dependent (Linux vs Windows)
# Hard coded / for Linux and Unix systems 
DIR_CHAR:=/

SOURCES:=$(wildcard *.$(SRC_EXTENSION))
OBJECTS:=$(patsubst %.$(SRC_EXTENSION), $(OBJ_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION), $(SOURCES))

DEBUG:=

all: $(EXE)

$(EXE): $(OBJECTS)
	$(CC) $^ -o $@

# The debug option cleans and builds the application with the -g compile flag
.PHONY: debug
debug: clean 
debug: DEBUG+=-g 
debug: all

# Set compile flags
CFLAGS:=-O3
INCFLAGS:=$(patsubst %, -I%, $(INC_DIR)) -I.

# Compile individual sources to .o
$(OBJ_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION): %.$(SRC_EXTENSION) $(OBJ_DIR) $(LIBINCS)
	$(CC) $(DEBUG) -c $(INCFLAGS) $(CFLAGS) $< -o $@ -DAPP_NAME=\"$(EXE)\"

$(OBJ_DIR):
	mkdir $(OBJ_DIR)

# Clean Directive, remove all generated files 
.PHONY: clean
clean:
ifeq ($(UNAME_S),Windows_NT) 
	DEL /F /s $(EXE) $(TESTDIR)$(DIR_CHAR)$(TEST_EXE)
	rd /q /s $(OBJ_DIR) $(LIB_DIR) $(INC_DIR) $(BIN_DIR)
else
	rm -rf $(EXE) $(OBJ_DIR) $(LIB_DIR) $(INC_DIR) $(BIN_DIR)
endif
