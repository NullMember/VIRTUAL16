# Writing VIRTUAL16 program
Writing VIRTUAL16 program is not different from writing assembly program for another architecture. Since VIRTUAL16 is virtual there are small limitations.  
This document written for using suggested way of assembling VIRTUAL16 program (for more information go to [README](../README.md))

### Never use .ORG statement
VIRTUAL16 have JMP and JSR instructions. You can write subroutines in your program and call them in VIRTUAL16 mode. JMP and JSR instruction calculates real location while executing instruction. If you use .org, calculation result is probably wrong. So never use .org statement for VIRTUAL16 program. You can use .org statement for 6502 routine  

### RET instruction must always last instruction
RET instruction returns from VIRTUAL16. Instruction fetchs last PC from VIRTUAL16 program counter and return 6502 mode. If you place RET instruction between another VIRTUAL16 instructions return address will wrong.

### For INC, DEC, ASR, LSL, LSR, ROR, RRC, ROL, RLC instructions use (#COUNT - 1)
VIRTUAL16 supports incrementing, decrementing and shifting register multiple times in 1 instruction. For technical limitations #count must be 4-bit. Since inc, dec or shift 0 times is meaningless and word width is 16-bit I decided to use #COUNT + 1 while executing instruction. So if you write

    INC R0, #0
it increments R0 1 time.

    INC R0, #15
will increment R0 16 times etc.  
You can use these instructions without #COUNT for inc, dec or shift 1 time.  

    INC R0

### SWAP instruction usage
SWAP instruction have two different usage. First one is

    SWAP Rn, Rm
will swap contents of Rn and Rm . Second one is

    SWAP Rn
will swap MSB and LSB of Rn

### SMUL and UMUL
SMUL and UMUL instructions are 16x16=32-bit and result held by R11 and R12

### 

## Example

    MAIN:
	    MOV #0x0010, R0		;MOV 16 to R0
	    MOV #0x0010, R1		;MOV 16 to R1
	    MOV #0x0010, R2		;MOV 16 to R2
	    JSR ADDR2TIMES		;JUMP ADDR2TIMES subroutine
	    MOV #0x0020, R2		;MOV 32 to R2
	    JSR ADDR2TIMES		;JUMP ADDR2TIMES subroutine
	    JMP END				;JUMP to RET
	ADDR2TIMES:
	    ADD R0, R1			;R0 + R1 = R1
	    DEC R2				;Decrement R2 1 time
	    BNE R2, ADDR2TIMES	;If R2 not equal to zero
	END:
	    RET					;Return to 6502 mode

If you want to assemble your program by hand go to [Instruction Set](instructionset.md)

## Placing VIRTUAL16 program into 6502 program

For placing your program into 6502 source you must assemble and place bytecodes after "JSR VIRTUAL16". For example:  

    .org 0x0200
    VIRTUAL16 equ 0x0400
    
    MAIN:
	    JSR VIRTUAL16
	    DB 0x40, 0x10, 0x00, 0x41, 0x10, 0x00, 0x42, 0x10, 0x00, 0x0d, 0x15, 0x00, 0x42, 0x20, 0x00, 0x0d
	    DB 0x15, 0x00, 0x0f, 0x1b, 0x00, 0x12, 0x01, 0x11, 0x20, 0x82, 0xfa, 0x00
	    BRK

These bytecodes contain the example above.