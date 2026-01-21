/* systick.s - The Scheduler Heartbeat
   Purpose: Configure the hardware timer for deterministic task switching
*/

.syntax unified
.cpu cortex-m4
.thumb

/* SysTick Register Addresses */
.equ STK_CTRL,  0xE000E010
.equ STK_LOAD,  0xE000E014
.equ STK_VAL,   0xE000E018

/* Configuration Constants */
/* Assuming a 16MHz internal clock, 16000 cycles = 1ms */
.equ RELOAD_VALUE, 15999 

.section .text.kernel
.global init_systick

init_systick:
    /* 1. Program the Reload Value (The "Tick" interval) */
    ldr r0, =STK_LOAD
    ldr r1, =RELOAD_VALUE
    str r1, [r0]

    /* 2. Clear current value */
    ldr r0, =STK_VAL
    mov r1, #0
    str r1, [r0]

    /* 3. Control Register Settings:
       Bit 0: ENABLE (Start the timer)
       Bit 1: TICKINT (Enable interrupt request when counter hits 0)
       Bit 2: CLKSOURCE (Use processor clock)
    */
    ldr r0, =STK_CTRL
    mov r1, #7              /* Binary 111 -> Enable, Int, Source */
    str r1, [r0]

    bx lr                   /* Return to kernel_main */
