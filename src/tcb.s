/* tcb.s - Task Control Block Definitions */
.syntax unified
.cpu cortex-m4
.thumb

.section .data
.align 4
.global current_tcb_ptr
.global tcb_table

/* Pointer to the currently running TCB */
current_tcb_ptr:
    .word tcb_task_A

/* The TCB Table: [PSP, StackLimit, MPU_Base, MPU_Attr] */
tcb_table:
tcb_task_A:
    .word 0             /* [0] PSP (Filled at runtime) */
    .word 0x20002000    /* [4] Stack Limit (Bottom of Stack) */
    .word 0x08008000    /* [8] MPU Region Base (Task Code) */
    .word 0x0300002F    /* [12] MPU Attr: RO, 32KB */

tcb_task_B:
    .word 0             /* [0] PSP */
    .word 0x20002400    /* [4] Stack Limit */
    .word 0x08010000    /* [8] MPU Region Base */
    .word 0x0300002F    /* [12] MPU Attr */
