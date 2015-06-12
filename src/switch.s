
.set INT_DISABLED,           0xC0    /* Disable both FIQ and IRQ. */
.set MODE_IRQ,               0x12    /* IRQ Mode                  */
.set MODE_SVC,               0x13    /* Supervisor Mode           */

.extern cs
.extern currentSP
.extern scheduler

.global switch_to_current
.global SwitchingIRQHandler
.global SimpleIRQHandler

.code 32

/*
 *  Switch to current task without saving previous context.
 *  Used to run the first task the first time.
 *
 *  Pops the initial context setup up by the initialize_stack function.
 *  That means this function will act like a return to the task.
 *
 */
switch_to_current:
                                      /* Switch to the current task's stack. */
    ldr   r0, =currentSP              /* Load r0 with the address for currentSP */
    ldr   sp, [r0]                    /* Load sp with the value stored at the address */
                                      /* sp now points to the task's stack. */

                                      /* Set SPSR to the CPSR for the task. */
    ldmfd sp!, {r0}                   /* Pop the first value from the stack into r0. */
                                      /* That value was the CPSR for the task. */
    msr   spsr_cxsf, r0               /* Load SPSR with that CPSR value in r0. */

    ldr   r1, =cs
    str   r1, [sp]

                                      /* Run task. */
    ldmfd sp!, {r0-r12, lr, pc}^      /* Pop the rest of the stack setting regs and pc for the task */
                                      /* Acts like a call the task. */


/*
 *  Simple IRQ handler that calls hello_world from the SVC mode.
 *
 *  It saves the context on the IRQ stack.
 *  Switches to the SVC mode and calls hello. Resets SVC LR after call.
 *  Switches back to IRQ mode and pops the context and returns.
 *
 *  Use this as an initial test.
 *
 */
SimpleIRQHandler:
    sub		lr, lr, #4                      /* LR offset to return from this exception: -4. */
    stmfd	sp!, {r0-r12, lr}               /* Push working registers. */

    /* Switch to SVC mode */

    msr		cpsr_c, #(INT_DISABLED | MODE_SVC)


    stmfd  sp!, {lr}                       /* Save LR before the call. */
    bl     hello_world                     /* Call hello_world. The branch w/ link overwrites LR. */
    ldmfd  sp!, {lr}                       /* Restore LR after the call. */

    /* Switch back to IRQ mode */

    msr    cpsr_c, #(INT_DISABLED | MODE_IRQ)

    ldmfd  sp!, {r0-r12, pc}^              /* Pop the context and returning to interrupted code. */


/*
 *  Context switching interrupt handler.
 *
 *  See "Instructions for implementing the context switch.txt" for full instructions.
 *
 *
 */
SwitchingIRQHandler:
    /* IRQ mode with IRQ stack */

    /* Adjust LR back by 4 for use later. */
    sub		lr, lr, #4
    /* Push working registers r0-r2 to the IRQ stack. */
    stmfd	sp!, {r0-r2}

    /*  We'll use r0-r2 as variables. */
    /* Save task's cpsr (stored as the IRQ's spsr) to r0 */
    mrs		r0, spsr
    /* Save lr which is the task's pc to r1 */
    mov		r1, lr
    /* Save exception's stack pointer to r2*/
    mov		r2, sp
    /* Reset exception's stack by adding 12 to it. It's saved in r2 and we'll be going to svc mode and won't come back */
    add		sp, sp, #12

    /* Change to SVC mode with interrupts disabled. */
    msr		cpsr_c, #(INT_DISABLED | MODE_SVC)

    /* SVC mode with SVC stack. This is the stack of interrupted task. */
    /* Push task's PC */
    stmfd	sp!, {r1}
    /* Push task's LR */
    stmfd	sp!, {lr}
    /* Push task's R3-R12 */
    stmfd	sp!, {r3-r12}

    /* We can't push R0-R2 because we've used them as variables. We need to get the values
     * they had from the IRQ stack where we stored them. To do that we can pop them off the
     * IRQ stack using R2 into R3-R5 which are now free to use since we already stored their
     * values to the task's stack.
     */
    /* Pop 3 values from the IRQ stack using R2 as the stack pointer and load them into R3-R5. */
    ldmfd	r2!, {r3-r5}
    /* Push those 3 values to the task's stack */
    stmfd	sp!, {r3-r5}
    /* Push the task's CPSR which is in R0 to the task's stack. */
    stmfd	sp!, {r0}
    /* Call the task scheduler which sets currentSP and resets the timer. */
    mov		r0, sp
    bl		scheduler

    /* Set sp to the new task's sp by reading the value stored in currentSP. */
    ldr		r0, =currentSP
    ldr		sp, [r0]

    /* Pop task's CPSR and restore it to spsr. */
    ldmfd	sp!, {r0}
    msr		spsr_cxsf, r0

    /* spsr will be moved to cpsr when we pop the context with ldmfd */
    /* Pop task's context. Restores regs and cpsr which reenables interrupts. */
    ldmfd	sp!, {r0-r12, lr, pc}^

