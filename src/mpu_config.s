/* mpu_config.s - Static Kernel Protection */
.syntax unified
.cpu cortex-m4
.thumb

.global configure_mpu

/* MPU Registers */
.equ MPU_CTRL, 0xE000ED94
.equ MPU_RNR,  0xE000ED98
.equ MPU_RBAR, 0xE000ED9C
.equ MPU_RASR, 0xE000EDA0

configure_mpu:
    /* Disable MPU */
    ldr r0, =MPU_CTRL
    mov r1, #0
    str r1, [r0]

    /* Region 0: KERNEL FLASH (Read-Only, Privileged) */
    ldr r0, =MPU_RNR
    mov r1, #0
    str r1, [r0]
    ldr r0, =MPU_RBAR
    ldr r1, =0x08000000
    str r1, [r0]
    ldr r0, =MPU_RASR
    ldr r1, =0x0500001F /* RO, PrivOnly, 32KB */
    str r1, [r0]

    /* Region 1: KERNEL RAM (No Access for User) */
    ldr r0, =MPU_RNR
    mov r1, #1
    str r1, [r0]
    ldr r0, =MPU_RBAR
    ldr r1, =0x20000000
    str r1, [r0]
    ldr r0, =MPU_RASR
    ldr r1, =0x10000019 /* XN, NoAccess, 8KB */
    str r1, [r0]
    
    /* Enable MPU + Background Region */
    ldr r0, =MPU_CTRL
    mov r1, #5 
    str r1, [r0]
    
    dsb
    isb
    bx lr
