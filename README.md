# About
This is a hack-able, Capture-the-Flag program source code for a program that 
requires login. It allows users to type in their usernames and passwords and 
access a system.

This is designed to make security researchers derive a valid username and 
password combo from scanning the binary. The password is obscured with an 
encryption algorithm. Researchers must find the encrypted password in the 
binary and figure out how to decrypt it. 

# Cloning 
This repo uses sub-modules, when cloning use 
```
git clone git@github.com:eggsactly/garretts-ctf.git --recurse-submodules
```

To get all sub-modules when you clone this repo. 

# Building 
The build process for this project uses Make. There are three targets for this
project

```
make all
make debug
make clean
```

For building for a basic CTF challenge, we recommend using `make debug` because
the resulting binary will contain a debugging symbol table. 

# Plan of Attack

Get read-only data in the binary. If the password is encoded in the binary, in 
any form, it will be in this section of the binary. 
```
$ objdump -sj .rodata garretts-ctf
 4000 01000200 00000000 00000000 00000000  ................
 4010 626f7274 00000000 00000000 00000000  bort............
 4020 542fbdff f4321a23 6b8e3ad6 976a2acc  T/...2.#k.:..j*.
 4030 00000000 00000000 1d055ce1 4a60bd00  ..........\.J`..
 4040 48617368 20546162 6c65206e 6f742053  Hash Table not S
 4050 65740075 7365726e 616d653a 20007061  et.username: .pa
 4060 7373776f 72643a20 00594f75 27724520  ssword: .YOu'rE 
 4070 496e2121 21004175 7468656e 74696174  In!!!.Authentiat
 4080 696f6e20 4661696c 65642e00 68742f68  ion Failed..ht/h
 4090 742e6300 76616c75 6520213d 204e554c  t.c.value != NUL
 40a0 4c006874 5f736574 004b3a20 00253032  L.ht_set.K: .%02
 40b0 58203a20 000a433a 20000a44 3a2000    X : ..C: ..D: 
```

From this list, we get a clue as to what a potential valid username may be for
the application: *bort*. 

We need to find out which offset this is in an executing binary. The 
offsets in the binary where this data resides is in the left most numbers, 
they are expressed as hex. 

We can make some educated guesses as to where the password or encryption keys 
are. They are not going to be anywhere we have readable text. 

Open up gdb, and get the info proc map of the running binary 

```
$ gdb garretts-ctf
(gdb) b main 
Breakpoint 1 at 0x11f1: file main.c, line 21.
(gdb) run
Starting program: 
(gdb) info proc mappings 
process 6930
Mapped address spaces:

          Start Addr           End Addr       Size     Offset  Perms  objfile
      0x555555554000     0x555555555000     0x1000        0x0  r--p   /home/gweaver/Projects/garretts-ctf/garretts-ctf
      0x555555555000     0x555555558000     0x3000     0x1000  r-xp   /home/gweaver/Projects/garretts-ctf/garretts-ctf
      0x555555558000     0x555555559000     0x1000     0x4000  r--p   /home/gweaver/Projects/garretts-ctf/garretts-ctf
      0x555555559000     0x55555555a000     0x1000     0x4000  r--p   /home/gweaver/Projects/garretts-ctf/garretts-ctf
      0x55555555a000     0x55555555b000     0x1000     0x5000  rw-p   /home/gweaver/Projects/garretts-ctf/garretts-ctf
      0x7ffff7db3000     0x7ffff7db6000     0x3000        0x0  rw-p   
      0x7ffff7db6000     0x7ffff7ddc000    0x26000        0x0  r--p   /usr/lib/x86_64-linux-gnu/libc.so.6
      0x7ffff7ddc000     0x7ffff7f31000   0x155000    0x26000  r-xp   /usr/lib/x86_64-linux-gnu/libc.so.6
      0x7ffff7f31000     0x7ffff7f84000    0x53000   0x17b000  r--p   /usr/lib/x86_64-linux-gnu/libc.so.6
      0x7ffff7f84000     0x7ffff7f88000     0x4000   0x1ce000  r--p   /usr/lib/x86_64-linux-gnu/libc.so.6
      0x7ffff7f88000     0x7ffff7f8a000     0x2000   0x1d2000  rw-p   /usr/lib/x86_64-linux-gnu/libc.so.6
      0x7ffff7f8a000     0x7ffff7f97000     0xd000        0x0  rw-p   
      0x7ffff7fc3000     0x7ffff7fc5000     0x2000        0x0  rw-p   
      0x7ffff7fc5000     0x7ffff7fc9000     0x4000        0x0  r--p   [vvar]
      0x7ffff7fc9000     0x7ffff7fcb000     0x2000        0x0  r-xp   [vdso]
      0x7ffff7fcb000     0x7ffff7fcc000     0x1000        0x0  r--p   /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
      0x7ffff7fcc000     0x7ffff7ff1000    0x25000     0x1000  r-xp   /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
      0x7ffff7ff1000     0x7ffff7ffb000     0xa000    0x26000  r--p   /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
      0x7ffff7ffb000     0x7ffff7ffd000     0x2000    0x30000  r--p   /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
      0x7ffff7ffd000     0x7ffff7fff000     0x2000    0x32000  rw-p   /usr/lib/x86_64-linux-gnu/ld-linux-x86-64.so.2
      0x7ffffffde000     0x7ffffffff000    0x21000        0x0  rw-p   [stack]
```

There are two addresses where our .rodata is loaded into in this example 
(yours will be different):0x555555558000 and 0x555555559000, this is because 
there are two start addresses for the offset 0x4000, which is where .rodata 
resides in the binary. 

We can set watch points for address accesses. 
```
(gdb) rwatch *0x555555558020 
(gdb) rwatch *0x555555558030
(gdb) rwatch *0x5555555580b0
```

Warning, you're limited on hardware watch-points, so you may have to make several
iterations of this until you hit a watch point, which will lead you to code that
needs encryption. 

Continue through the application enough and we'll see we hit a watch point. 

```
Hardware read watchpoint 2: *0x555555558020

Value = -4378796
application (hashTable=0x55555555b2a0) at main.c:87
87	            if((char)(output->encrypt_pw)[i] != (char)inputPassword[i])
(gdb) 
```

If we do this enough, we'll find interesting parts of the code

```
(gdb) bt
#0  application (hashTable=0x55555555b2a0) at main.c:87
#1  0x000055555555524b in main () at main.c:33
(gdb) l
82	    
83	        encrypt(inputPassword, sizeOfInputPass, encrkey, ENCRYPTION_MODE);
84	        int pw_comp = 0;
85	        for(i = 0; i < message_size_calc; i++)
86	        {
87	            if((char)(output->encrypt_pw)[i] != (char)inputPassword[i])
88	            {
89	                pw_comp = i;
90	            }
91	        }
(gdb) 
```

For example, we have now found the encryption function `encrypt`, and all of 
its inputs. The most important thing is that we have found the address to the 
encryption key.
```
(gdb) p (void *) encrkey
$6 = (void *) 0x555555558038 <encrkey>
```
which is this part from .rodata

```
 4030 ________ ________ 1d055ce1 4a60bd00  ..........\.J`..
```

We also get clues that this function is reversible if we pass a 0 in for the 
last parameter of encrypt. 

We can also get the size of the encrypted password by printing 
message\_size\_calc

```
(gdb) p message_size_calc 
$10 = 16
```

We can also conclude that the output of encrypt is being compared to an 
already encrypted password. 

Therefore, we can conclude that the already encrypted password for user *bort*
is in address output->encrypt_pw

```
p (char *) output->encrypt_pw 
$11 = 0x555555558020 <password> "T/\275\377\3642\032#k\216:֗j", <incomplete sequence \314>
```
And this does not exceed 16 bytes in size. 

Therefore, the encrypted password is this part of .rodata
```
 4020 542fbdff f4321a23 6b8e3ad6 976a2acc  T/...2.#k.:..j*.
```

We can use the encrypt function to do the decryption for us, but since the 
0x555555558020 address lives in .rodata, we cannot modify that data in-place,
rather we will need to transfer it to another storage location and then run 
encrypt on it. inputPassword will work well as a temporary location. 

If you run this in gdb, this will give you the password for user *bort*.
```
(gdb) set inputPassword[0] = *((char *)0x555555558020)
(gdb) set inputPassword[1] = *((char *)0x555555558021)
(gdb) set inputPassword[2] = *((char *)0x555555558022)
(gdb) set inputPassword[3] = *((char *)0x555555558023)
(gdb) set inputPassword[4] = *((char *)0x555555558024)
(gdb) set inputPassword[5] = *((char *)0x555555558025)
(gdb) set inputPassword[6] = *((char *)0x555555558026)
(gdb) set inputPassword[7] = *((char *)0x555555558027)
(gdb) set inputPassword[8] = *((char *)0x555555558028)
(gdb) set inputPassword[9] = *((char *)0x555555558029)
(gdb) set inputPassword[10] = *((char *)0x55555555802a)
(gdb) set inputPassword[11] = *((char *)0x55555555802b)
(gdb) set inputPassword[12] = *((char *)0x55555555802c)
(gdb) set inputPassword[13] = *((char *)0x55555555802d)
(gdb) set inputPassword[14] = *((char *)0x55555555802e)
(gdb) set inputPassword[15] = *((char *)0x55555555802f)
(gdb) set inputPassword[16] = *((char *)0x555555558030)
(gdb) call encrypt(inputPassword, 16, encrkey, 0)
(gdb) p inputPassword
```

Now you will have the password and you will be able to log in. 

