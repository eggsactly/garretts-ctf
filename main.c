#include <stdio.h>
#include "ht.h"
#include "des.h"

typedef struct {
    unsigned char * encrypt_pw;
    size_t len;
} pw_t;

int application(ht* hashTable);
int encrypt(unsigned char* message, size_t message_size, const unsigned char* key, int mode);

const char * username = "bort";
const char password[] = {84,47,-67,-1,-12,50,26,35,107,-114,58,-42,-105,106,42,-52,'\0'};
const unsigned char encrkey [] = {0x1D, 0x05, 0x5C, 0xE1, 0x4A, 0x60, 0xBD, 0x00};
const pw_t user = {(char *) password, 12};

int main ()
{
    ht* hashTable; 
    int retVal = 0;
    const char * copiedKey;
    
    int i;
    hashTable = ht_create();
    copiedKey = ht_set(hashTable, "bort", (void *) &user);
    if(copiedKey == NULL)
    {
        printf("Hash Table not Set\n");
        return 1;
    }
    
    retVal = application(hashTable);
    
    ht_destroy(hashTable);
    
    return retVal;
}

int application(ht* hashTable)
{
    char inputUsername[100] = {0};
    char inputPassword[128] = {0};
    printf("username: ");
    fgets(inputUsername, sizeof(inputUsername), stdin);
    int i;
    int usernameFound = 0;
    int passwordsMatch = 0;
    for(i = 0; i < sizeof(inputUsername); i++)
    {
        if(inputUsername[i] == '\n')
        {
            inputUsername[i] = '\0';
        }
    }
    
    pw_t * output;
    
    output = (pw_t*) ht_get(hashTable, inputUsername);
    
    if(output != NULL)
        usernameFound = 1;

    printf("password: ");
    fgets(inputPassword, sizeof(inputPassword), stdin);
    int sizeOfInputPass = 0;
    for(i = 0; i < sizeof(inputPassword); i++)
    {
        if(inputPassword[i] == '\n')
        {
            inputPassword[i] = '\0';
            if(sizeOfInputPass == 0)
                sizeOfInputPass = i;
                break;
        }
    }
    
    if (usernameFound)
    {
        // message_size_calc rounds size up to next nearest 8th place 
        size_t message_size_calc = output->len + ((output->len%8 > 0)*(8 - output->len%8));
    
        encrypt(inputPassword, sizeOfInputPass, encrkey, ENCRYPTION_MODE);
        int pw_comp = 0;
        for(i = 0; i < message_size_calc; i++)
        {
            if((char)(output->encrypt_pw)[i] != (char)inputPassword[i])
            {
                pw_comp = i;
            }
        }
        
        if(pw_comp)
        {
            passwordsMatch = 0;
        }
        else
        {
            passwordsMatch = 1;
        }
    }
    
    if(usernameFound && passwordsMatch)
    {
        printf("YOu'rE In!!!\n");
        return 0;
    }
    else
    {
        printf("Authentiation Failed.\n");
        return 1;
    }
}

int encrypt(unsigned char* message, size_t message_size, const unsigned char* key, int mode)
{
    static key_set ks[17] = {0};
    static int first = 1;
    if (first)
    {
        generate_sub_keys((unsigned char*)key, ks);
        first = 0;
    }
    unsigned char processed_piece[8] = {0}; 
    volatile int i, j;
    for(i = 0; i < (message_size/8) + (message_size%8>0); i++)
    {
        process_message(message+(i*8), processed_piece, ks, mode);
        for(j = 0; j < 8; j++)
        {
            message[(i*8)+j] = processed_piece[j];
        }
    }
    return 0;
}

