/* tasks.s - The Flight Software Partitions
   Purpose: Two isolated programs that calculate & safely YIELD via System Call.
*/

.syntax unified
.cpu cortex-m4
.thumb

.section .text.user  /* Lives in the 'User Flash' partition defined in linker.ld */

/* --- Task 1: Landing Gear Controller (Simulated) --- */
.global task_landing_gear
task_landing_gear:
    mov r0, #0xAAAA        /* Unique ID for debugging (10101010...) */
task1_loop:
    add r0, r0, #1         /* SIMULATE: Read Sensor & Calculate */
    
    /* THE UPGRADE: */
    svc #0                 /* "Kernel, I am done. Switch to next task." */
    
    b task1_loop           /* Loop back */

/* --- Task 2: Fuel Management System (Simulated) --- */
.global task_fuel_system
task_fuel_system:
    mov r0, #0xBBBB        /* Unique ID for debugging (10111011...) */
task2_loop:
    sub r0, r0, #1         /* SIMULATE: Adjust Valve Flow */
    
    /* THE UPGRADE: */
    svc #0                 /* "Kernel, yielding control." */
    
    b task2_loop           /* Loop back */
