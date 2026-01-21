/* boot.s*/
.syntax unified
.cpu cortex-m4
.thumb

.section .vector_table, "a"
.word _estack
.word Reset_Handler
.word NMI_Handler
.word HardFault_Handler
.word MemManage_Handler   /* Safety Net */
.word 0
.word 0
.word 0
.word 0
.word 0
.word 0
.word SVC_Handler         /* Linker will find this in syscalls.s */
.word 0
.word 0
.word PendSV_Handler      /* Linker will find this in context_switch.s */
.word SysTick_Handler     /* Defined at the bottom of this file */

.section .text.kernel
.global Reset_Handler
.global kernel_main
.global current_tcb_ptr

/* External functions */
.global configure_mpu
.global prepare_tasks
.global init_systick
.global task_landing_gear

Reset_Handler:
    cpsid i
    bl kernel_main
loop_forever:
    b loop_forever

kernel_main:
    /* --- Step 1: Secure Hardware --- */
    bl configure_mpu
    
    /* --- Step 2: Build TCBs --- */
    bl prepare_tasks
    
    /* --- Step 3: Start Timer --- */
    bl init_systick
    
    /* --- Step 4: Switch to PSP --- */
    ldr r0, =current_tcb_ptr
    ldr r0, [r0]            /* Get TCB Address */
    ldr r0, [r0]            /* Get PSP from TCB */
    msr psp, r0

    /* --- Drop Privilege (User Mode) --- */
    mov r0, #3              /* Unprivileged Thread Mode + PSP */
    msr control, r0
    isb

    cpsie i                 /* Enable Interrupts */
    
    /* Jump to first task */
    bl task_landing_gear
    
kernel_idle:
    wfi
    b kernel_idle

/* --- Exception Handlers --- */

.type NMI_Handler, %function
NMI_Handler:
    b .

.type HardFault_Handler, %function
HardFault_Handler:
    b .             /* Note: Real handler is in fault_handler.s if you linked it */

.type MemManage_Handler, %function
MemManage_Handler:
    b .


.type SysTick_Handler, %function
SysTick_Handler:
    /* Trigger PendSV to request a Context Switch */
    ldr r0, =0xE000ED04
    ldr r1, =(1 << 28)
    str r1, [r0]
    bx lr
