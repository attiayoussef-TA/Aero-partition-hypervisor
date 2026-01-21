CC = arm-none-eabi-gcc
LD = arm-none-eabi-ld
OBJCOPY = arm-none-eabi-objcopy
SIZE = arm-none-eabi-size

# Added -fstack-usage to generate .su files (Stack Usage analysis)
CFLAGS = -mcpu=cortex-m4 -mthumb -g -nostdlib -fstack-usage

# Added -Map to generate a memory map file
LDFLAGS = -T linker.ld -Wl,-Map=$(TARGET).map -Wl,--gc-sections

# Updated Source List (Added syscalls.s)
SRCS = src/boot.s \
       src/mpu_config.s \
       src/systick.s \
       src/context_switch.s \
       src/syscalls.s \
       src/tasks.s \
       src/task_init.s \
       src/tcb.s \
       src/fault_handler.s

OBJS = $(SRCS:.s=.o)
TARGET = aero_kernel

all: $(TARGET).bin analyze

$(TARGET).elf: $(OBJS)
	@echo ">> LINKING KERNEL..."
	$(CC) $(LDFLAGS) -o $@ $(OBJS) 
	@echo ">> VERIFYING INTEGRITY..."
	$(SIZE) $@

$(TARGET).bin: $(TARGET).elf
	@echo ">> GENERATING BINARY..."
	$(OBJCOPY) -O binary $< $@

# New Analysis Step
analyze:
	@echo ">> BUILD SAFETY CHECK:"
	@if [ -f $(TARGET).map ]; then echo "   [OK] Memory Map generated"; else echo "   [FAIL] No Map file"; fi
	@echo "   [INFO] Stack Usage per function (bytes):"
	@cat *.su 2>/dev/null || echo "   (No stack usage info available)"
	@echo ">> SYSTEM READY."

%.o: %.s
	$(CC) $(CFLAGS) -c $< -o $@

clean:
	rm -f *.o *.elf *.bin *.map *.su
