# VIRTUAL16
16-bit virtual microprocessor implemented in MOS6502 assembly, inspired by Steve Wozniak's SWEET16. It's under 1k and ROM friendly.  
If you want to assemble [src/VIRTUAL16.asm](src/VIRTUAL16.asm) file you can use [naken_asm](https://github.com/mikeakohn/naken_asm) or another 6502 assembler.  
For assembling your own VIRTUAL16 code go to [here](https://nullmember.github.io/customasm/web/), scroll to end of page and write your program there. Make sure you selected "Comma-seperated Hex" option (it's default). Press assemble and place bytes to your 6502 program. Don't forget to prepend 'DB' each line.  

## Example

Example 6502 assembly file:  

    .6502
    ;If you're not placed VIRTUAL16 to your ROM/RAM/EEPROM before uncomment include line.
    ;Default location of VIRTUAL16 is 0x0400. If you want to change edit VIRTUAL16.asm file
    ;.include "src/VIRTUAL16.asm"

    ;If you're placed VIRTUAL16 to your ROM/RAM/EEPROM before, uncomment equ line
    ;.EQU VIRTUAL16 0x0400 	;Replace if VIRTUAL16 placed different location
    .ORG 0x0200				;Replace if you want to place your program different location

    MAIN:
        JSR VIRTUAL16
    ;VIRTUAL16 Instructions
        DB 0x70, 0x00, 0x00, 0x10, 0x00, 0xa0, 0xfc, 0x00
    ;VIRTUAL16 Instructions
        BRK

## Using VIRTUAL16 instructions as 6502 subroutine

You can use VIRTUAL16 instructions as native subroutines. Because of fetch and decode stages eliminated, execution speed is much faster than VIRTUAL16 mode. All instructions process 16-bit data. Here is the list of instructions  

    ADD16: ZP,y = ZP,x + ZP,y
    ADC16: ZP,y = ZP,x + ZP,y + Carry
    SUB16: ZP,y = ZP,x - ZP,y
    SBC16: ZP,y = ZP,x - ZP,y - !Carry
    INC16: ZP,x = ZP,x + Acc
    DEC16, ZP,x = ZP,x - Acc
    SWAP16: ZP,y = ZP,x / ZP,x = ZP,y
    SWAP16: ZP,x[0:7] = ZP,x[8:15] / ZP,x[8:15] = ZP,x[0:7]
    UMUL16: 0x18:0x19:0x1A:0x1B = ZP,x * ZP,y (unsigned)
    SMUL16: 0x18:0x19:0x1A:0x1B = ZP,x * ZP,y (signed)
    AND16: ZP,y = ZP,x & ZP,y
    OR16: ZP,y = ZP,x | ZP,y
    XOR16: ZP,y = ZP,x ^ ZP,y
    ASL16: ZP,x = ZP,x << y (ZP,x[0] = 0)
    LSL16: Same as INSASL
    ASR16: ZP,x = ZP,x >> y (ZP,x[15] = 0)
    LSR16: ZP,x = ZP,x >> y (ZP,x[14] = ZP,x[15])
    RLC16: ZP,x = ZP,x << y (ZP,x[0] = Carry)
    RRC16: ZP,x = ZP,x >> y (ZP,x[15] = Carry)

To make include (.inc) file assemble VIRTUAL16 using tools\compile.sh script and run makeinclude.py (python3).

## Documents
Please check [docs folder](docs) for more information  

## TODO
More documentation  
Write tests  

## Known bugs
Nothing yet  

## Warning
This software is still in beta stage. Even ISA is not finalized. Use at your own risk  

## Thanks
Thanks to [mikeakohn](https://github.com/mikeakohn) for [naken_asm](https://github.com/mikeakohn/naken_asm) project  
Thanks to [hlorenzi](https://github.com/hlorenzi) for [customasm](https://github.com/hlorenzi/customasm) project  
Thanks to [6502 community](http://forum.6502.org/)  
