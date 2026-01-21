/* linker.ld - With Safety Assertions */

ENTRY(Reset_Handler)

MEMORY
{
    FLASH_KERNEL (rx) : ORIGIN = 0x08000000, LENGTH = 32K
    FLASH_USER   (rx) : ORIGIN = 0x08008000, LENGTH = 96K
    RAM_KERNEL   (rwx): ORIGIN = 0x20000000, LENGTH = 8K
    RAM_USER     (rwx): ORIGIN = 0x20002000, LENGTH = 24K
}

_estack = ORIGIN(RAM_USER) + LENGTH(RAM_USER); /* End of RAM */

SECTIONS
{
    .vector_table :
    {
        . = ALIGN(4);
        KEEP(*(.vector_table))
        . = ALIGN(4);
    } > FLASH_KERNEL

    .text.kernel :
    {
        . = ALIGN(4);
        *(.text.kernel)
        *(.text*)
        *(.rodata*)
        . = ALIGN(4);
    } > FLASH_KERNEL

    .data :
    {
        . = ALIGN(4);
        *(.data)
        . = ALIGN(4);
    } > RAM_KERNEL

    .text.user :
    {
        . = ALIGN(4);
        *(.text.user)
        . = ALIGN(4);
    } > FLASH_USER
}

/* --- SAFETY ASSERTIONS --- */
/* 1. Check if Kernel RAM overflowed */
ASSERT(SIZEOF(.data) <= LENGTH(RAM_KERNEL), "Error: Kernel Data too large for RAM_KERNEL")

/* 2. Check if Code fits in Flash */
ASSERT(SIZEOF(.text.kernel) <= LENGTH(FLASH_KERNEL), "Error: Kernel Code too large")
ASSERT(SIZEOF(.text.user)   <= LENGTH(FLASH_USER),   "Error: User Code too large")
