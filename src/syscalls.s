/* syscalls.s - The Kernel API 
   Handling requests from User Mode.
*/
.syntax unified
.cpu cortex-m4
.thumb

.global SVC_Handler
.equ ICSR, 0xE000ED04
.equ PENDSVSET, (1 << 28)

SVC_Handler:
    tst lr, #4              /* Check Bit 2 of LR: Did we come from PSP or MSP? */
    ite eq
    mrseq r0, msp           /* If 0, we came from MSP (Kernel) */
    mrsne r0, psp           /* If 1, we came from PSP (User) */

    /* r0 now points to the Stack Frame. 
       Stack Layout: R0, R1, R2, R3, R12, LR, PC, xPSR.
       We want PC (Return Address) -> It is at offset 24 (6 words * 4 bytes). */
    
    ldr r1, [r0, #24]       /* Load the Saved PC */
    ldrb r0, [r1, #-2]      /* Read the byte BEFORE the PC (The SVC instruction low byte) */
    
    /* Now R0 contains the SVC Number. Switch logic: */
    cmp r0, #0
    beq svc_yield           /* SVC #0 = Yield */
    
    /* cmp r0, #1 */
    /* beq svc_something_else */

    bx lr                   /* Unknown syscall, ignore */

svc_yield:
    /* Trigger a PendSV to context switch immediately */
    ldr r0, =ICSR
    ldr r1, =PENDSVSET
    str r1, [r0]
    bx lr
