# The project's name
# _____________________________________________________________________________

PROJ_NAME  = phantax-tinydtls


# The list of source files (wildcards may be used, but NO REVERSE PATHS)
# _____________________________________________________________________________

SRC_FILES  = ./src/aes/*.c
SRC_FILES += ./src/dtls/*.c
SRC_FILES += ./src/ecc/ecc.c
SRC_FILES += ./src/sha2/sha2.c


# The list of include directories
# _____________________________________________________________________________

INC_DIRS   = ./src
INC_DIRS  += ./src/aes
INC_DIRS  += ./src/dtls
INC_DIRS  += ./src/ecc
INC_DIRS  += ./src/sha2


# Preprocessor macro defines
# _____________________________________________________________________________

MACROS   = SHA2_USE_INTTYPES_H


# Compiler prefix
# _____________________________________________________________________________

#C_PREFIX = arm-none-eabi-
C_PREFIX =


# The linker script
# _____________________________________________________________________________

LD_SCRIPTS  = 


# =============================================================================

BUILD_DIR  = build

# _____________________________________________________________________________

CC       = $(C_PREFIX)gcc
CXX      = $(C_PREFIX)g++
OBJCOPY  = $(C_PREFIX)objcopy
OBJDUMP  = $(C_PREFIX)objdump
SIZE	 = $(C_PREFIX)size

# _____________________________________________________________________________

FLAGS    = 

# _____________________________________________________________________________

CFLAGS   = $(FLAGS)
CFLAGS  += -c
CFLAGS  += -g3
CFLAGS  += -O0 
CFLAGS  += -std=gnu99

CFLAGS  += -fdata-sections
CFLAGS  += -ffunction-sections
CFLAGS  += -fno-common
CFLAGS  += -funroll-loops

#CFLAGS  += -Wall

CFLAGS  += $(foreach d, $(INC_DIRS), -I$d)
CFLAGS  += $(foreach d, $(MACROS), -D$d)

# _____________________________________________________________________________

CXXFLAGS  = $(CFLAGS)
CXXFLAGS += -std=c++11
CXXFLAGS += -fno-exceptions

# _____________________________________________________________________________

CFLAGS  += -Wshadow
CFLAGS  += -Wdeclaration-after-statement
CFLAGS  += -Wcast-align 
CFLAGS  += -Wbad-function-cast
#CFLAGS  += -Wstrict-prototypes 
#CFLAGS  += -Wmissing-prototypes
#CFLAGS  += -Wsign-compare
CFLAGS  += -Wno-unused-parameter

# _____________________________________________________________________________

LDFLAGS  = $(FLAGS)
LDFLAGS += $(foreach d, $(LD_SCRIPTS), -T$d)
#LDFLAGS += --specs=nosys.specs
#LDFLAGS += -nodefaultlibs
#LDFLAGS += -nostartfiles
#LDFLAGS += -nostdlib
LDFLAGS += -Wl,-Map=$(BUILD_DIR)/$(PROJ_NAME).map
LDFLAGS += -Xlinker --gc-sections

# _____________________________________________________________________________

OBJ_BASE_DIR  = $(BUILD_DIR)/obj
PREP_BASE_DIR = $(BUILD_DIR)/prep
ASM_BASE_DIR  = $(BUILD_DIR)/asm

EXECUTABLE    = $(BUILD_DIR)/$(PROJ_NAME).elf
LIBRARY       = $(BUILD_DIR)/lib$(PROJ_NAME).a
BINARY        = $(BUILD_DIR)/$(PROJ_NAME).bin

SOURCES       = $(foreach d, $(SRC_FILES), $(shell ls -1 $d))
OBJECTS       = $(addprefix $(OBJ_BASE_DIR)/, $(addsuffix .o, $(SOURCES)))
PREPS         = $(addprefix $(PREP_BASE_DIR)/, $(SOURCES))
ASMS          = $(patsubst $(OBJ_BASE_DIR)/%, $(ASM_BASE_DIR)/%.s, $(OBJECTS))


all: bin size

exec: $(EXECUTABLE) 

lib: $(LIBRARY)  

bin: $(BINARY) 

prep: $(PREPS) 

obj: $(OBJECTS)

asm: $(ASMS)



$(EXECUTABLE): obj
	@echo "\033[01;33m==> Linking files -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(CC) $(OBJECTS) $(LDFLAGS) -o $@
	@echo ""

$(LIBRARY)  : $(OBJECTS)
	@echo "\033[01;33m==> Creating static library '$@':\033[00;00m"
	@mkdir -p $(BUILD_DIR)
	ar rcs $(LIBRARY) $(OBJECTS)
	@echo ""

$(BINARY): $(EXECUTABLE)
	@echo "\033[01;33m==> Creating binary '$(EXECUTABLE)' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(OBJCOPY) -O binary $(EXECUTABLE) $@
	
list: $(EXECUTABLE)
	@echo "\033[01;33m==> Creating listing for '$(EXECUTABLE)' :\033[00;00m"
	$(OBJDUMP) --source --all-headers --demangle --line-number $(EXECUTABLE) > $(EXECUTABLE).lst
	
size : $(EXECUTABLE)
	@echo "\033[01;33m==> Printing size for '$(EXECUTABLE)':\033[00;00m"
	$(SIZE) --format=berkley $(EXECUTABLE)
	
$(OBJ_BASE_DIR)/%.c.o: %.c
	@echo "\033[01;32m==> Compiling C '$<' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@
	@echo ""
	
$(OBJ_BASE_DIR)/%.s.o: %.s
	@echo "\033[01;32m==> Compiling assembler '$<' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -o $@
	@echo ""
	
$(OBJ_BASE_DIR)/%.cpp.o: %.cpp
	@echo "\033[01;32m==> Compiling C++ '$<' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $< -o $@
	@echo ""
	
$(PREP_BASE_DIR)/%: %
	@echo "\033[01;32m==> Preprocessing '$<' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(CC) $(CFLAGS) $< -E > $@
	@echo ""
	
$(ASM_BASE_DIR)/%.s: $(OBJ_BASE_DIR)/%
	@echo "\033[01;32m==> Disassembling '$<' -> '$@':\033[00;00m"
	@mkdir -p $(dir $@)
	$(OBJDUMP) -d -S $< > $@
	@echo ""
	
clean:
	@echo "\033[01;31m==> Cleaning directories:\033[00;00m"
	rm -rf $(BUILD_DIR)/
	@echo ""

