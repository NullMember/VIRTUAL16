# VIRTUAL16
16-bit virtual microprocessor implemented in MOS6502 assembly, inspired by Steve Wozniak's SWEET16  
If you want to assemble [src/VIRTUAL16.asm](src/VIRTUAL16.asm) file you can use [naken_asm](https://github.com/mikeakohn/naken_asm) or another 6502 assembler.  
For assembling your own VIRTUAL16 code go to [here](https://nullmember.github.io/VIRTUAL16/customasm/), scroll to end of page and write your program there. Make sure you selected "Comma-seperated Hex" option (it's default). And place bytes to your 6502 program. Don't forget to prepend 'DB' each line.  

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