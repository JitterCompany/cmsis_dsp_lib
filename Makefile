
TOOLCHAIN_PREFIX=arm-none-eabi-
CC=$(TOOLCHAIN_PREFIX)gcc
AR=$(TOOLCHAIN_PREFIX)ar
LD=$(TOOLCHAIN_PREFIX)ld
SZ=$(TOOLCHAIN_PREFIX)size
RM := rm -rf

ENABLE_FPU = 1

LIBRARY_NAME = cmsis_dsp_lib
SRC_DIR = Source
BUILD_DIR = build/
ILIBS = -I./Include/

CORE = m4
GLOBAL_DEFS = -DARM_MATH_CM4 -D__FPU_PRESENT 
CFLAGS = -O0 -g3 -Wall -c -fmessage-length=100 -fno-builtin -ffunction-sections -fdata-sections -std=gnu99  -mthumb -MMD -MP  -mcpu=cortex-$(CORE) -fdiagnostics-color=auto 

ifeq ($(ENABLE_FPU),1)
	GLOBAL_DEFS += -D__FPU_PRESENT
	CFLAGS += -mfloat-abi=hard -mfpu=fpv4-sp-d16
endif

SRCS = $(shell find $(SRC_DIR) -name '*.c')
OBJS_F :=  $(addprefix $(BUILD_DIR), $(SRCS:.c=.o))

LIBRARY_FILE = "./lib$(LIBRARY_NAME).a"

all: post-build

.SECONDEXPANSION:
$(LIBRARY_FILE) : $$(OBJS_F)
	@mkdir -p "$(BUILD_DIR)"
	@echo 'Building target: $@'
	@echo 'Invoking: MCU Archiver'
	 
	$(AR) -r  $@ $(OBJS_F) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '
	#$(MAKE) --no-print-directory post-build

# Other Targets
clean:
	-$(RM) $(BUILD_DIR)
	-$(RM) $(LIBRARY_FILE)
	-@echo ' '


post-build: $(LIBRARY_FILE)
	-@echo 'Performing post-build steps'
	$(SZ) $(LIBRARY_FILE)
	-@echo ' '
	-@echo ' '
	-@echo ' '

$(BUILD_DIR)%.o: %.c
	mkdir -p '$(dir $@)'
	@echo 'Building file: $@ in $(BUILD_DIR) from $<'
	@echo 'Invoking: MCU C Compiler'
	@echo flags=$(CFLAGS)
	$(CC) $(GLOBAL_DEFS) $(ILIBS) $(CFLAGS) -MF"$(@:%.o=%.d)" -MT"$(@:%.o=%.d)" -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

.PHONY: all post-build clean dependents
.SECONDARY:

