/* context_switch.s  */
.syntax unified
.cpu cortex-m4
.thumb

.global PendSV_Handler
.global current_tcb_ptr
.global tcb_table
.global HardFault_Handler

/* MPU Registers */
.equ MPU_RNR,  0xE000ED98
.equ MPU_RBAR, 0xE000ED9C
.equ MPU_RASR, 0xE000EDA0

PendSV_Handler:
    cpsid i                     /* Critical Section */

    /* --- SAVE CONTEXT --- */
    mrs r0, psp                 /* Get current stack pointer */
    cmp r0, #0                  /* Sanity Check: Is PSP valid? */
    beq HardFault_Handler
    
    stmdb r0!, {r4-r11}         /* Save Callee-Saved Regs */
    
    ldr r1, =current_tcb_ptr    /* Save PSP to current TCB */
    ldr r2, [r1]
    str r0, [r2]                

    /* --- SCHEDULER (Toggle A <-> B) --- */
    ldr r3, =tcb_table
    cmp r2, r3                  
    ite eq
    addeq r2, r3, #16           /* Switch to B */
    subne r2, r3, #0            /* Switch to A */
    str r2, [r1]                /* Update Global Pointer */

    /* --- RECONFIGURE MPU (The Fix) --- */
    ldr r4, =MPU_RNR
    mov r5, #4                  /* Select Region 4 (User Slot) */
    str r5, [r4]
    
    ldr r5, [r2, #8]            /* Load Base Addr from TCB */
    ldr r4, =MPU_RBAR
    str r5, [r4]
    
    ldr r5, [r2, #12]           /* Load Attributes from TCB */
    ldr r4, =MPU_RASR
    str r5, [r4]
    
    dsb
    isb                         /* Apply MPU changes immediately */

    /* --- RESTORE CONTEXT --- */
    ldr r0, [r2]                /* Load new PSP */
    
    /* Stack Overflow Check */
    ldr r3, [r2, #4]            /* Load Stack Limit */
    cmp r0, r3
    blt HardFault_Handler       /* Crash if stack overflowed */

    ldmia r0!, {r4-r11}         /* Restore Regs */
    msr psp, r0
    
    cpsie i
    bx lr
