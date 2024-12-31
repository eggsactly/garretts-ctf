# Compiler 
CC?=gcc
# name of example executable 
EXE:=garretts-ctf
# This make file will build every file it sees in the directory ending with a 
# .c extension 
SRC_EXTENSION:=c
OBJ_EXTENSION:=o
OBJ_DIR:=obj
HT_DIR:=ht
DES_DIR:=DES

# Character separating directory levels can be OS dependent (Linux vs Windows)
# Hard coded / for Linux and Unix systems 
DIR_CHAR:=/

SOURCES:=$(wildcard *.$(SRC_EXTENSION))
SOURCES_HT:=$(wildcard ht$(DIR_CHAR)*.$(SRC_EXTENSION))
SOURCES_DES:=$(wildcard DES$(DIR_CHAR)*.$(SRC_EXTENSION))
SOURCES_DES:=$(filter-out DES/run_des.c,$(SOURCES_DES))
OBJECTS:=$(patsubst %.$(SRC_EXTENSION), $(OBJ_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION), $(SOURCES)) \
$(patsubst $(HT_DIR)$(DIR_CHAR)%.$(SRC_EXTENSION), $(OBJ_DIR)$(DIR_CHAR)$(HT_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION), $(SOURCES_HT)) \
$(patsubst $(DES_DIR)$(DIR_CHAR)%.$(SRC_EXTENSION), $(OBJ_DIR)$(DIR_CHAR)$(DES_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION), $(SOURCES_DES))

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
INCFLAGS:=$(patsubst %, -I%, $(INC_DIR)) -I. -Iht/ -IDES/

# Compile individual sources to .o
$(OBJ_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION): %.$(SRC_EXTENSION) $(OBJ_DIR)
	$(CC) $(DEBUG) -c $(INCFLAGS) $(CFLAGS) $< -o $@ -DAPP_NAME=\"$(EXE)\"

$(OBJ_DIR)$(DIR_CHAR)$(HT_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION): $(HT_DIR)$(DIR_CHAR)%.$(SRC_EXTENSION) $(OBJ_DIR)$(DIR_CHAR)$(HT_DIR)
	$(CC) $(DEBUG) -c $(INCFLAGS) $(CFLAGS) $< -o $@ 
$(OBJ_DIR)$(DIR_CHAR)$(DES_DIR)$(DIR_CHAR)%.$(OBJ_EXTENSION): $(DES_DIR)$(DIR_CHAR)%.$(SRC_EXTENSION) $(OBJ_DIR)$(DIR_CHAR)$(DES_DIR)
	$(CC) $(DEBUG) -c $(INCFLAGS) $(CFLAGS) $< -o $@ 

$(OBJ_DIR):
	mkdir $(OBJ_DIR)
$(OBJ_DIR)$(DIR_CHAR)$(HT_DIR): $(OBJ_DIR)
	mkdir $(OBJ_DIR)$(DIR_CHAR)$(HT_DIR)
$(OBJ_DIR)$(DIR_CHAR)$(DES_DIR): $(OBJ_DIR)
	mkdir $(OBJ_DIR)$(DIR_CHAR)$(DES_DIR)
	
# Clean Directive, remove all generated files 
.PHONY: clean
clean:
ifeq ($(UNAME_S),Windows_NT) 
	DEL /F /s $(EXE) $(TESTDIR)$(DIR_CHAR)$(TEST_EXE)
	rd /q /s $(OBJ_DIR) $(LIB_DIR) $(INC_DIR) $(BIN_DIR)
else
	rm -rf $(EXE) $(OBJ_DIR) $(LIB_DIR) $(INC_DIR) $(BIN_DIR)
endif
