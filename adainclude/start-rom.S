@## -*- asm -*- ##############################################################
@#                                                                           #
@#                 GNAT RUN-TIME LIBRARY (GNARL) COMPONENTS                  #
@#                                                                           #
@#                                 S T A R T                                 #
@#                                                                           #
@#                               Assembly File                               #
@#                                                                           #
@#                      Copyright (C) 2012-2013 AdaCore                      #
@#                                                                           #
@#  GNAT is free software;  you can  redistribute it  and/or modify it under #
@#  terms of the  GNU General Public License as published  by the Free Soft- #
@#  ware  Foundation;  either version 3,  or (at your option) any later ver- #
@#  sion.  GNAT is distributed in the hope that it will be useful, but WITH- #
@#  OUT ANY WARRANTY;  without even the  implied warranty of MERCHANTABILITY #
@#  or FITNESS FOR A PARTICULAR PURPOSE.                                     #
@#                                                                           #
@#  As a special exception under Section 7 of GPL version 3, you are granted #
@#  additional permissions described in the GCC Runtime Library Exception,   #
@#  version 3.1, as published by the Free Software Foundation.               #
@#                                                                           #
@#  You should have received a copy of the GNU General Public License and    #
@#  a copy of the GCC Runtime Library Exception along with this program;     #
@#  see the files COPYING3 and COPYING.RUNTIME respectively.  If not, see    #
@#  <http://www.gnu.org/licenses/>.                                          #
@#                                                                           #
@#############################################################################

	.syntax unified
	.cpu cortex-r4
	.arm
	.text
	.section .vectors,"a"
__vectors:	
	B	_start_rom  /* 1 Reset */
        ldr     PC,=__gnat_undef_trap	@ 4
        ldr     PC, SWI_Addr		@ 8
        ldr     PC, Prefetch_Addr	@ c
        ldr     PC,=__gnat_dabt_trap		@ 10
        nop                             @ Reserved vector 14
        ldr	PC,=__gnat_irq_trap
        ldr 	PC,=__gnat_fiq_trap
        
SWI_Addr:	 .word     SWI_Handler
Prefetch_Addr:	 .word     Prefetch_Handler
	
SWI_Handler:
	b	SWI_Handler
Prefetch_Handler:
	b	Prefetch_Handler
	.text
	.arm

	.globl _start_rom
_start_rom:		
	ldr	r0,=_start_rom_t
	bx	r0
	.thumb
	.thumb_func
	.globl _start_rom_t
_start_rom_t:	
	blx	_coreInitRegisters_
	blx	_coreInitStackPointer_
	/* Copy .data */
	movw	r0,#:lower16:__data_start
	movt	r0,#:upper16:__data_start
	movw	r1,#:lower16:__data_words
	movw	r2,#:lower16:__data_load
	movt	r2,#:upper16:__data_load
	cbz	r1,1f
0:	ldr	r4,[r2],#4
	str	r4,[r0],#4
	subs	r1,r1,#1
	bne	0b

1:
	/* Clear .bss */
	movw	r0,#:lower16:__bss_start
	movt	r0,#:upper16:__bss_start
	movw	r1,#:lower16:__bss_words
	mov	r2,#0
	cbz	r1,1f
0:	str	r2,[r0],#4
	subs	r1,r1,#1
	bne	0b
1:
@	mrc	p15, #0, r3, c0, c0, #0	@ get proc id
@	mov	r0,#1
@spin:		
@	cmp	r0,#0
@	bne	spin

	blx	rm46_init
	
	blx	main
	
	blx	exit

	.global __aeabi_ldiv0
	.global __aeabi_idiv0
	.global __aeabi_unwind_cpp_pr0
	.global __aeabi_unwind_cpp_pr1
	.global __aeabi_unwind_cpp_pr2
__aeabi_unwind_cpp_pr0:
__aeabi_unwind_cpp_pr1:
__aeabi_unwind_cpp_pr2:
__aeabi_ldiv0:
__aeabi_idiv0:

@-------------------------------------------------------------------------------
@ Initialize CPU Registers
@ SourceId : CORE_SourceId_001
@ DesignId : CORE_DesignId_001
@ Requirements: HL_SR477, HL_SR476, HL_SR492
	.arm
	.globl     _coreInitRegisters_
_coreInitRegisters_:	

    @ After reset, the CPU is in the Supervisor mode (M = 10011)
        mov r0, lr
        mov r1, #0x0000
        mov r2, #0x0000
        mov r3, #0x0000
        mov r4, #0x0000
        mov r5, #0x0000
        mov r6, #0x0000
        mov r7, #0x0000
        mov r8, #0x0000
        mov r9, #0x0000
        mov r10, #0x0000
        mov r11, #0x0000
        mov r12, #0x0000
        mov r13, #0x0000
        mrs r1, cpsr
        msr spsr_cxsf, r1 
        @ Switch to FIQ mode (M = 10001)
        cps #17
        mov lr, r0
        mov r8, #0x0000
        mov r9, #0x0000
        mov r10, #0x0000
        mov r11, #0x0000
        mov r12, #0x0000
        mrs r1, cpsr
        msr spsr_cxsf, r1 
        @ Switch to IRQ mode (M = 10010)
        cps #18
        mov lr, r0
        mrs r1,cpsr
        msr spsr_cxsf, r1         
        @ Switch to Abort mode (M = 10111)
        cps #23
        mov lr, r0
        mrs r1,cpsr
        msr spsr_cxsf, r1         
        @ Switch to Undefined Instruction Mode (M = 11011)
        cps #27
        mov lr, r0
        mrs r1,cpsr
        msr spsr_cxsf, r1         
        @ Switch to System Mode ( Shares User Mode registers ) (M = 11111)
        cps #31
        mov lr, r0
        mrs r1,cpsr
        msr spsr_cxsf, r1         


        mrc   p15,#0x00,r2,c1,c0,#0x02
        orr   r2,r2,#0xF00000
        mcr   p15,#0x00,r2,c1,c0,#0x02
        mov   r2,#0x40000000
        fmxr  fpexc,r2

        fmdrr d0,         r1,     r1
        fmdrr d1,         r1,     r1
        fmdrr d2,         r1,     r1
        fmdrr d3,         r1,     r1
        fmdrr d4,         r1,     r1
        fmdrr d5,         r1,     r1
        fmdrr d6,         r1,     r1
        fmdrr d7,         r1,     r1
        fmdrr d8,         r1,     r1
        fmdrr d9,         r1,     r1
        fmdrr d10,        r1,     r1
        fmdrr d11,        r1,     r1
        fmdrr d12,        r1,     r1
        fmdrr d13,        r1,     r1
        fmdrr d14,        r1,     r1
        fmdrr d15,        r1,     r1
        bl    next1
next1:	
        bl    next2
next2:	
        bl    next3
next3:	
        bl    next4
next4:	
        bx    r0

	.globl _coreInitStackPointer_
_coreInitStackPointer_:	
        cps   #17
        ldr   sp,       fiqSp
        cps   #18
        ldr   sp,       irqSp
        cps   #19
        ldr   sp,       svcSp
        cps   #23
        ldr   sp,       abortSp
        cps   #27
        ldr   sp,       undefSp
        cps   #31
        ldr   sp,       userSp
        bx    lr

userSp:	  .word __stack_end-0x00000100-0x00000100-0x00000100-0x00000100-0x00000100
svcSp:	  .word __stack_end-0x00000100-0x00000100-0x00000100-0x00000100
fiqSp:	  .word __stack_end-0x00000100-0x00000100-0x00000100
irqSp:	  .word __stack_end-0x00000100-0x00000100
abortSp:  .word __stack_end-0x00000100
undefSp:  .word __stack_end

.weak __gnat_irq_trap
.type __gnat_irq_trap, %function
__gnat_irq_trap:
0:	b	0b
	.size __gnat_irq_trap, . - __gnat_irq_trap

.weak __gnat_fiq_trap
.type __gnat_fiq_trap, %function
__gnat_fiq_trap:
0:	b	0b
	.size __gnat_fiq_trap, . - __gnat_fiq_trap

.weak __gnat_undef_trap
.type __gnat_undef_trap, %function
__gnat_undef_trap:
0:	b	0b
	.size __gnat_undef_trap, . - __gnat_undef_trap

.weak __gnat_dabt_trap
.type __gnat_dabt_trap, %function
__gnat_dabt_trap:
0:	b	0b
	.size __gnat_dabt_trap, . - __gnat_dabt_trap
