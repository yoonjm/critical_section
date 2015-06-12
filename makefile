##############################################################################################
#
#       !!!! Do NOT edit this makefile with an editor which replace tabs by spaces !!!!    
#
##############################################################################################
# 
# On command line:
#
# make all = Create project
#
# make clean = Clean project files.
#
# To rebuild project do "make clean" and "make all".
#

##############################################################################################
# Start of default section
#

TOOLCHAIN   = /opt/gcc-arm-none-eabi-4_8-2014q3/bin/arm-none-eabi
CC          = $(TOOLCHAIN)-gcc
AS          = $(TOOLCHAIN)-gcc -x assembler-with-cpp
LD          = $(TOOLCHAIN)-ld 
OBJCOPY     = $(TOOLCHAIN)-objcopy
OBJDUMP     = $(TOOLCHAIN)-objdump
#OBJDUMP		= objdump
AR          = $(TOOLCHAIN)-ar
RANLIB      = $(TOOLCHAIN)-ranlib


MCU  = 	arm7tdmi
CODETYPE = arm

# List all default C defines here, like -D_DEBUG=1
DDEFS =  -DDEBUG=1

# List all default ASM defines here, like -D_DEBUG=1
DADEFS = 

# List all default directories to look for include files here
DINCDIR = 

# List the default directory to look for the libraries here
DLIBDIR =

# List all default libraries here
DLIBS = 

#
# End of default section
##############################################################################################

##############################################################################################
# Start of user section
#

# Define project name here
PROJECT = Critical_Section

# Define linker script file here

#LDSCRIPT= ./prj/lpc2378_ram.ld
LDSCRIPT= ./prj/lpc2378_flash.ld

# List all user C define here, like -D_DEBUG=1
UDEFS = 

# Define ASM defines here
UADEFS = 

# List C source files here
SRC  = 	src/main.c \
		src/init.c \
		src/print.c \
		src/timer.c \
		src/bsp.c \
		src/tasks.c \
		src/critical_section.c

# List ASM source files here
ASRC = src/crt.s \
       src/switch.s

# List all user directories here
UINCDIR = ./inc

# List the user directory to look for the libraries here
ULIBDIR =

# List all user libraries here
ULIBS = 

# Define optimisation level here -O0, -O1, -O2, -Os, or -03
OPT = -O0

#
# End of user defines
##############################################################################################


INCDIR  = 	$(patsubst %,-I%,$(DINCDIR) $(UINCDIR))
LIBDIR  = 	$(patsubst %,-L%,$(DLIBDIR) $(ULIBDIR))
DEFS    = 	$(DDEFS) $(UDEFS)
ADEFS   = 	$(DADEFS) $(UADEFS)
OBJS    = 	$(ASRC:.s=.o) $(SRC:.c=.o)
LIBS    = 	$(DLIBS) $(ULIBS)
MCFLAGS = -mcpu=$(MCU) -m$(CODETYPE)

# -mthumb-interwork
# -mno-thumb-interwork

ASFLAGS = 	$(MCFLAGS) -g -gdwarf-2 -Wa,-amhls=$(<:.s=.lst) $(ADEFS)

CPFLAGS = 	$(MCFLAGS) $(OPT) -gdwarf-2 -fomit-frame-pointer \
			-Wall -Wstrict-prototypes -fverbose-asm -Wa,-ahlms=$(<:.c=.lst) $(DEFS)

LDFLAGS = 	$(MCFLAGS) -nostartfiles -T$(LDSCRIPT) -Wl,-Map=$(PROJECT).map,--cref,--no-warn-mismatch $(LIBDIR)

# Generate dependency information
CPFLAGS += -MD -MP -MF .dep/$(@F).d

#
# makefile rules
#

all: $(OBJS) $(PROJECT).elf $(PROJECT).hex $(PROJECT).bin $(PROJECT).lst

%o : %c
	$(CC) -c $(CPFLAGS) -I . $(INCDIR) $< -o $@

%o : %s
	$(AS) -c $(ASFLAGS) $< -o $@

%elf: $(OBJS)
	$(CC) $(OBJS) $(LDFLAGS) $(LIBS) -o $@

%lst: %elf
	$(OBJDUMP) -dSst $< > $@

%bin: %elf
	$(OBJCOPY) -O binary -S $< $@

%srec: %elf
	$(OBJCOPY) -O srec -S $< $@

%hex: %elf
	$(OBJCOPY) -O ihex -S $< $@

clean:
	-rm -f $(OBJS)
	-rm -f $(PROJECT).elf
	-rm -f $(PROJECT).map
	-rm -f $(PROJECT).hex
	-rm -f $(PROJECT).bin
	-rm -f $(PROJECT).srec
	-rm -f $(PROJECT).lst
	-rm -f $(SRC:.c=.lst)
	-rm -f $(ASRC:.s=.lst)
	-rm -fR .dep

# 
# Include the dependency files, should be the last of the makefile
#
-include $(shell mkdir .dep 2>/dev/null) $(wildcard .dep/*)

# *** EOF ***
