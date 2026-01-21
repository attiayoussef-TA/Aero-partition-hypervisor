/* fault_handler.s - Safe Failure Recovery */
.syntax unified
.cpu cortex-m4
.thumb

.global HardFault_Handler
.global MemManage_Handler

.equ SCB_AIRCR, 0xE000ED0C
.equ SYSRESETREQ, 0x05FA0004

HardFault_Handler:
    cpsid i                 /* 1. Disable Interrupts (Containment) */
    ldr r0, =SCB_AIRCR      /* 2. Load Reset Register */
    ldr r1, =SYSRESETREQ    /* 3. Request System Reset */
    str r1, [r0]
    b .                     /* 4. Wait for hardware reset */

MemManage_Handler:
    b HardFault_Handler     /* MPU violation = Immediate Reset */
