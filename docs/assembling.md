# Writing VIRTUAL16 program
Writing VIRTUAL16 program is not different from writing assembly program for another architecture. Since VIRTUAL16 is virtual there are small limitations.  
This document written for using suggested way of assembling VIRTUAL16 program (for more information go to [README](../README.md))

### Program Counter, Status Register and Stack Pointer

VIRTUAL16 uses highest registers for fixed-purpose. R15 stores PC, LSB of R14 stores SR and MSB of R14 stores SP. Don't write to these registers unless you know what you do!  

### Never use .ORG statement
VIRTUAL16 have JMP and JSR instructions. You can write VIRTUAL16 subroutines in your program. JMP and JSR instruction calculates real location while executing instruction. If you use .org, calculation result is probably wrong. So never use .org statement for VIRTUAL16 program. You can use .org statement for 6502 routine  

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

### UMUL, SMUL and CMP instruction result registers

UMUL and SMUL instructions uses R12(LSW) and R13(MSW) for result. If you use these instructions R12 and R13 content will replaced by instructions.  
CMP instruction uses R13 for result.  
Otherwise you are free to use these registers.  

### NJSR instruction

With NJSR (Native Jump SubRoutine) instruction you can execute native 6502 subroutine without returning from VIRTUAL16 mode. Make sure your subroutine ends with RTS instruction.  

## Example

    MAIN:
	    MOV #0x0010, R0		;MOV 16 to R0
	    MOV R0, R1			;COPY 16 TO R1
	    MOV R0, R2			;COPY 16 TO R2
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

	.ORG 0x0200
	
	MAIN:
		JSR VIRTUAL16
		DB 0x40, 0x10, 0x00, 0x01, 0x01, 0x01, 0x02, 0x0d, 0x13, 0x00, 0x42, 0x20, 0x00, 0x0d, 0x13, 0x00
		DB 0x0f, 0x19, 0x00, 0x12, 0x01, 0x11, 0x20, 0xc2, 0xfa, 0x00
		BRK

These bytecodes contain the example above.