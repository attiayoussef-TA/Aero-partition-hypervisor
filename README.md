# 🛡️ Aero-Partition-Hypervisor: ARINC 653 Style Separation Kernel

![Platform](https://img.shields.io/badge/Platform-STM32F4%20%2F%20Cortex--M4-blue?style=for-the-badge&logo=arm)
![Standard](https://img.shields.io/badge/Standard-ARINC%20653-red?style=for-the-badge&logo=aircraft)

<p align="center">
  <strong>✈️  An Architectural Design Study of a Bare-Metal Partitioning Kernel for Safety-Critical Systems.</strong><br>
  <strong>⚙️ Conceived by Youssef ATTIA</strong>
</p>

---

## ⚡ Executive Summary
This project implements a **Zero-Trust Separation Kernel** for Integrated Modular Avionics (IMA). It addresses the critical failure mode: **"Propagation of Faults"** (e.g., a buggy In-Flight Entertainment system corrupting the memory of the Flight Control Computer).

By exploiting the **ARM Cortex-M4 Memory Protection Unit (MPU)** and the **PendSV Exception Model**, this kernel guarantees strict **Time and Space Partitioning**. It enforces a "Dynamic Iron Curtain" that physically re-wires the memory map every millisecond, ensuring that a crashed user partition cannot affect the kernel or other critical tasks.

---

## 🏗️ Architecture: The "Dynamic Iron Curtain"

The system utilizes a time-triggered architecture where the MPU is dynamically reconfigured at every context switch.

```mermaid
flowchart TD
    %% Define Subgraphs
    subgraph KERNEL [Safe Domain: The Hypervisor]
        direction TB
        Sched(Deterministic Scheduler)
        MPU_Driver(Dynamic MPU Reconfigurator)
        Handler(Fault Handler / Safe Reset)
    end
    
    subgraph USER [Unsafe Domain: User Partitions]
        direction TB
        TaskA(Task A: Landing Gear)
        TaskB(Task B: Fuel System)
    end

    %% Interactions
    Sched -->|SysTick 1ms| MPU_Driver
    MPU_Driver -->|1. Restrict Memory| TaskA
    MPU_Driver -->|2. Restrict Memory| TaskB
    
    TaskA -.->|SVC #0 Yield| Sched
    TaskB -.->|SVC #0 Yield| Sched
    TaskA -- Crash/Overflow --> Handler
    Handler -->|Force Reset| KERNEL

    %% Styling
    style KERNEL fill:#ccffcc,stroke:#333,stroke-width:2px
    style USER fill:#ffcccc,stroke:#333,stroke-width:2px
    style Handler fill:#ff0000,stroke:#333,stroke-width:4px,color:#fff
```
---
## 📂 Project Manifest

Each file in this repository maps to a specific layer of the **ARINC 653** safety hierarchy:

### 🧠 Kernel Core (The "Brain")
* **`src/boot.s`**: The **Root of Trust**. Initializes the vector table, sets up the C-runtime environment (if needed), and hands off control to `kernel_main`.
* **`src/tcb.s`**: The **Scheduler State**. Defines the `Task Control Block` structures that track the Stack Pointer (PSP) and MPU permissions for every active partition.
* **`src/task_init.s`**: The **Loader**. Manually fabricates the initial CPU stack frames, "faking" a suspended state so tasks can be launched via a context restore.
* **`src/systick.s`**: The **Timekeeper**. Configures the hardware timer to trigger the scheduler every 1ms (+/- 0.05%), ensuring deterministic execution slots.

### 🛡️ Safety & Security (The "Shield")
* **`src/mpu_config.s`**: The **Static Defense**. Locks down the Kernel Flash and RAM so that no user task can ever overwrite the operating system code.
* **`src/context_switch.s`**: The **Dynamic Defense**. The "Magic" routine that saves CPU state and **physically re-programs the MPU hardware** on the fly to isolate the next running task.
* **`src/fault_handler.s`**: The **Safety Net**. Catches HardFaults, MemManage Faults, and Stack Overflows, triggering a deterministic System Reset (AIRCR) instead of undefined behavior.

### 🔌 Interfaces (The "Gateway")
* **`src/syscalls.s`**: The **API Gateway**. Implements the `SVC` (Supervisor Call) handler, allowing user tasks to request services (like `Yield`) without elevating privileges.
* **`src/tasks.s`**: The **User Application**. Contains the isolated flight software partitions (Landing Gear, Fuel System) that run in Unprivileged Mode.

### 🏗️ Build & Infrastructure (The "Blueprint")
* **`linker.ld`**: The **Memory Map**. Defines the rigid physical addresses for Kernel vs. User space and contains **Build-Time Assertions** to prevent memory overlap.
* **`Makefile`**: The **Traceability Tool**. Orchestrates the build, generates `.map` files for audit, and performs stack usage analysis (`-fstack-usage`).

* # 🚀 How to Run (Hardware-in-the-Loop)

## 1. Prerequisites

### Hardware
- STM32F4 Discovery (or any Cortex-M4F board)

### Toolchain
- `arm-none-eabi-gcc`
- `make`
- `st-flash` (from `stlink-tools`)

### Debugger (Optional)
- `OpenOCD` or `GDB` (for visualization)

---

## 2. Build & Analyze

This project includes a safety-critical build system that generates stack usage reports.

### Clone the Repository

### STM32 Aero Kernel Build & Debug Guide

## 1. Compile & Verify

Build the project using `make`:

```bash
make
```
## 2. Flash & Observe

Flash the binary to your STM32 device:

```bash
st-flash write aero_kernel.bin 0x08000000
```
## 3. Verify via GDB

### Start the GDB Server
In a separate terminal, start OpenOCD:

```bash
openocd -f board/stm32f4discovery.cfg
```
### Connect and Debug

Launch GDB:

```bash
arm-none-eabi-gdb aero_kernel.elf
```
### Inside GDB

```gdb
(gdb) target remote :3333
(gdb) break PendSV_Handler
(gdb) continue
```
### Observation

Once the breakpoint hits, check the MPU registers:

```gdb
(gdb) print/x *0xE000ED9C  # Check MPU_RBAR (Region Base Address)
(gdb) print/x *0xE000EDA0  # Check MPU_RASR (Region Attribute and Size)
```



