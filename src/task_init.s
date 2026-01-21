/* task_init.s - Initialize Stacks & TCBs */
.syntax unified
.cpu cortex-m4
.thumb

.global prepare_tasks
.global tcb_table
.global task_landing_gear
.global task_fuel_system

prepare_tasks:
    /* --- Init Task A --- */
    ldr r0, =0x20002300      /* Top of Task A Stack */
    
    /* Fake Stack Frame */
    mov r1, #0x01000000      /* xPSR */
    str r1, [r0, #-4]!
    ldr r1, =task_landing_gear
    str r1, [r0, #-4]!       /* PC */
    mov r1, #0
    str r1, [r0, #-4]!       /* LR */
    mov r1, #0
    .rept 13                 /* R12, R3-R0, R11-R4 */
    str r1, [r0, #-4]!
    .endr
    
    /* Save PSP to TCB A */
    ldr r1, =tcb_table
    str r0, [r1]             /* tcb_table[0] = PSP */

    /* --- Init Task B --- */
    ldr r0, =0x20002700      /* Top of Task B Stack */
    
    /* Fake Stack Frame */
    mov r1, #0x01000000
    str r1, [r0, #-4]!
    ldr r1, =task_fuel_system
    str r1, [r0, #-4]!
    mov r1, #0
    str r1, [r0, #-4]!
    mov r1, #0
    .rept 13
    str r1, [r0, #-4]!
    .endr
    
    /* Save PSP to TCB B (Offset 16 bytes) */
    ldr r1, =tcb_table
    add r1, r1, #16
    str r0, [r1]

    bx lr
