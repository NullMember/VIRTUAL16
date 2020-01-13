; Copyright (c) 2019 Malik Enes Şafak
;
; Permission is hereby granted, free of charge, to any person obtaining
; a copy of this software and associated documentation files (the
; "Software"), to deal in the Software without restriction, including
; without limitation the rights to use, copy, modify, merge, publish,
; distribute, sublicense, and/or sell copies of the Software, and to
; permit persons to whom the Software is furnished to do so, subject to
; the following conditions:
;
; The above copyright notice and this permission notice shall be
; included in all copies or substantial portions of the Software.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
; EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
; MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
; NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
; LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
; OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
; WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

; Thanks to dp11, BigEd, White Flame, drogon from 6502 forum for their advices

.6502

;FOR CHANGING REGISTER LOCATION ON ZEROPAGE (MAXIMUM 0x100 - 0x30 = D0)
LB equ 0x00
;FOR CHANGING VIRTUAL16 ROUTINES LOCATION
STARTADDR equ 0x0400
;FOR CHANGING STACK PAGE
STACKPAGE equ 0x0100

R0 equ LB+0x00
R1 equ LB+0x02
R2 equ LB+0x04
R3 equ LB+0x06
R4 equ LB+0x08
R5 equ LB+0x0A
R6 equ LB+0x0C
R7 equ LB+0x0E
R8 equ LB+0x10
R9 equ LB+0x12
R10 equ LB+0x14
R11 equ LB+0x16
R12 equ LB+0x18
R13 equ LB+0x1A
R14 equ LB+0x1C
R15 equ LB+0x1E

HB equ LB+0x01
PC equ R15
SR equ LB+R14
SP equ HB+R14
CR equ R13
MH equ R13
ML equ R12
SPPAGE equ LB+0x20
FIRSTPC equ LB+0x22
TEMP equ LB+0x24
ACC equ LB+0x28
XREG equ LB+0x29
YREG equ LB+0x2A
STATUS equ LB+0x2B

.ORG STARTADDR

VIRTUAL16:
SAVE:               ;SAVE 6502 MODE REGISTERS
    STA ACC
    STX XREG
    STY YREG
    PHP
    PLA
    STA STATUS
    CLD
INITSTACK:
    LDA #(STACKPAGE & 0xFF) ;LOAD LSB OF STACKPAGE
    STX SPPAGE      ;STORE IT. WE NEED THIS BECAUSE OF STACK
    LDA #(STACKPAGE >> 8)   ;LOAD MSB OF STACKPAGE
    STX SPPAGE+1    ;STORE IT
    TSX             ;TRANSFER STACK POINTER TO X
    TXA             ;TRANSFER STACK POINTER X TO A
    SEC             ;SET CARRY (CLEAR BORROW)
    SBC #0x10       ;16 BYTE SAFETY AREA
    STA SP          ;STORE IT TO VIRTUAL16S STACK POINTER
LOADPC:
    PLA             ;PULL VIRTUAL PC LOW BYTE FROM STACK
    STA PC          ;STORE IT TO PC REGISTER LOW BYTE
    PLA             ;PULL VIRTUAL PC HIGH BYTE FROM STACK
    STA PC+1        ;STORE IT TO PC REGISTER HIGH BYTE
PREINCPC:
    JSR ABSIMMEND   ;SAVE 4 BYTE
STOREPC:            ;WE NEED THIS ROUTINE BECAUSE OF JSR INSTRUCTION
    LDA PC
    STA FIRSTPC
    LDA PC+1
    STA FIRSTPC+1
FETCH:
    LDA #(EXECUTE >> 8)     ;STORE EXECUTE ADDRESS FOR RETURNING FROM SUBROUTINE - MSB
    PHA
    LDA #(EXECUTE & 0xFF)   ;LSB
    PHA
    LDY #0x01       ;LOAD 1 TO Y
    LDA (PC),Y      ;LOAD REGISTER BYTE
    TAX             ;TRANSFER IT TO X REGISTER
    DEY             ;DECREASE Y
    LDA (PC),Y      ;LOAD INSTRUCTION BYTE
    CMP #0x40       ;IF INSTRUCTION IS IMMEDIATE, ABSOLUTE OR BRANCH
    BCS IMMABSBRN
    CMP #0x24       ;IF NOP
    BCS INSNOP
    ASL             ;MULTIPLY BY 2 FOR PROPER ADDRESS DECODING
    TAY             ;TRANSFER IT TO Y REGISTER
DECODEREG:
    LDA INSTR+1,Y   ;LOAD MSB OF INSTRUCTION ADDRESS
    PHA             ;PUSH TO STACK FOR RTS
    LDA INSTR,Y     ;LOAD LSB OF INSTRUCTION ADDRESS
    PHA             ;PUSH TO STACK FOR RTS
    TXA             ;TRANSFER REGISTER BYTE FROM X TO A
    AND #0x0F       ;GET DESTINATION
    ASL             ;MULTIPLY BY 2
    TAY             ;TRANSFER DST TO Y
    TXA             ;GET REGISTER BYTE AGAIN
    LSR             ;GET SOURCE
    LSR
    LSR
    AND #0x1E
    TAX             ;TRANSFER SRC TO X
RESTORESR:
    LDA SR          ;LOAD SR TO A
    PHA             ;PUSH A TO STACK
    PLP             ;PULL SR FROM STACK
EXECUTE:
    RTS             ;WE TRANSFERRED INSTRUCTION ADDRESS TO STACK SO USE RTS
STORESR:
    PHP             ;PUSH SR TO STACK
    PLA             ;PULL SR FROM STACK TO A
    STA SR
INCPC1:
    INC PC          ;INCREASE PROGRAM COUNTER
    BNE INCPC2
    INC PC+1        ;IF PAGE CROSSED
INCPC2:
    INC PC          ;OUR VIRTUAL16 USES MOSTLY TWO-BYTE INSTRUCTIONS
    BNE NEWINSTR
    INC PC+1        ;IF PAGE CROSSED
NEWINSTR:
    JMP FETCH
    
IMMABSBRN:
    STA TEMP        ;BACKUP INSTRUCTION BYTE
    LSR             ;GET INSTRUCTION INDEX
    LSR
    LSR
    AND #0x1E
    SEC
    SBC #0x0A
    TAY             ;TRANSFER INSTRUCTION INDEX TO Y
    LDA INSTR2+1,Y
    PHA
    LDA INSTR2,Y
    PHA
    LDA TEMP
    STX TEMP        ;COMMON FOR MOST INSTRUCTIONS
    AND #0x0F       ;GET REGISTER ADDRESS
    ASL             ;MULTIPLY BY 2
    TAX             ;TRANSFER TO X REGISTER
    LDA LB,X        ;COMMON FOR SOME BRANCH INSTRUCTIONS
    RTS

INSNOP:
    PLA
    PLA
    JMP INCPC2

INSMOVH:
    INX             ;IF MSB INCREASE X
INSMOVL:
    LDA TEMP
    STA LB,X        ;STORE IMMEDIATE VALUE TO REGISTER
    RTS
INSMOVW:
    LDY #0x02       ;LOAD #0x02 TO Y
    LDA (PC),Y      ;GET MSB OF IMMEDIATE VALUE
    STA HB,X        ;STORE REGISTER MSB
    LDA TEMP        ;LOAD IMMEDIATE LSB
    STA LB,X        ;STORE TO REGISTER LSB
    JMP ABSIMMEND

DECODEABS:          ;DECODE ABSOLUTE MODE ADDRESSING
    LDY #0x02       ;FOR FETCHING ABSOLUTE ADDRESS POINTER MSB
    LDA (PC),Y      ;LOAD 2 TO Y AND FETCH MSB
    STA TEMP+1      ;STORE ABSOLUTE ADDRESS POINTER MSB TO TEMP+1
    DEY             ;WE WILL USE Y TO ACCESS ABSOLUTE ADDRESS
    RTS

INSMOVAR:
    JSR DECODEABS
    LDA (TEMP),Y    ;LOAD MSB FROM ABSOLUTE ADDRESS
    STA HB,X        ;STORE TO REGISTER LSB
    DEY
    LDA (TEMP),Y    ;LOAD LSB FROM ABSOLUTE ADDRESS
    STA LB,X        ;STORE TO REGISTER LSB
    JMP ABSIMMEND

INSMOVRA:
    JSR DECODEABS
    LDA HB,X        ;LOAD REGISTER MSB
    STA (TEMP),Y    ;STORE ABSOLUTE ADDRESS MSB
    DEY
    LDA LB,X        ;LOAD REGISTER LSB
    STA (TEMP),Y    ;STORE ABSOLUTE ADDRESS LSB

ABSIMMEND:          ;BECAUSE IMMEDIATE WORD AND ABSOLUTE MOV INSTRUCTIONS TAKES 3 BYTE
    INC PC          ;INCREASE PROGRAM COUNTER
    BNE ABSIMMRTS
    INC PC+1        ;IF PAGE CROSSED
ABSIMMRTS:
    RTS

;BRANCH INSTRUCTIONS. SOME OF THEM TAKEN FROM SWEET16
INSBNM1:
    AND HB,X        ;CHECK BOTH BYTES FOR NO $FF
    EOR #0xFF
    BNE EXECUTEBRN  ;BRANCH IF NOT MINUS 1
    RTS
INSBM1:
    AND HB,X        ;FOR $FF (MINUS 1)
    EOR #0xFF
    BEQ EXECUTEBRN  ;BRANCH IF SO
    RTS
INSBMI:
    LDA HB,X        ;TEST FOR MINUS
    BMI EXECUTEBRN
    RTS
INSBPL:
    LDA HB,X        ;TEST FOR PLUS
    BPL EXECUTEBRN  ;BRANCH IF SO
    RTS
INSBCC:
    LDA SR          ;LOAD SR TO A
    AND #0x01       ;TEST CARRY BIT
    BEQ INSBRA  ;BRANCH IF CARRY CLEAR
    RTS
INSBCS:
    LDA SR          ;LOAD SR TO A
    AND #0x01       ;TEST CARRY BIT
    BNE INSBRA  ;BRANCH IF CARRY SET
    RTS
INSBNE:
    ORA HB,X        ;(BOTH BYTES)
    BNE EXECUTEBRN  ;BRANCH IF SO
    RTS
INSBEQ:
    ORA HB,X        ;(BOTH BYTES)
    BEQ EXECUTEBRN  ;BRANCH IF SO
    RTS
INSBRA:
    LDY #0x01
    LDA (PC),Y
    STA TEMP
EXECUTEBRN:
    CLC             ;CLEAR CARRY
    LDA PC          ;LOAD PC LSB
    ADC TEMP        ;ADD BRANCH VALUE TO PC
    STA PC          ;STORE IT TO PC LSB
    LDA TEMP        ;LOAD BRANCH VALUE FROM TEMP
    BPL EXECUTEBRNPSTV  ;IF POSITIVE BRANCH POSITIVE OFFSET
EXECUTEBRNNGTV:     ;IF CARRY SET BRANCH NEGATIVE OFFSET
    LDA PC+1        ;LOAD PC MSB
    ADC #0xFF       ;ADD -1 TO PC MSB
    STA PC+1
    RTS
EXECUTEBRNPSTV:
    LDA PC+1        ;LOAD PC MSB
    ADC #0x00
    STA PC+1
    RTS
    
INSDEC:
    TYA             ;TRANSFER INCREMENT COUNTER TO A
    LSR             ;WE MULTIPLIED IT BY 2. REVERSE IT
INSDECREMENT:
    ADC #1          ;ADD 1
    TAY             ;TRANSFER IT TO Y AGAIN
    SEC             ;SET CARRY (RESET BORROW)
    LDA LB,X        ;LOAD LSB OF REGISTER
    STY LB,X        ;STORE DECREMENT VALUE TO REGISTER
    SBC LB,X        ;SUB DECREMENT VALUE FROM REGISTER
    STA LB,X        ;STORE IT TO LSB
    LDA HB,X        ;LOAD MSB
    SBC #0x00       ;IF THERE IS BORROW SUB IT
    STA HB,X        ;STORE IT TO MSB
    RTS

INSRET:             ;RETURN FROM VIRTUAL16
    JSR ABSIMMEND   ;SAVE 4 BYTE
INSRETRESTORE:
    PLA             ;PULL EXECUTE SUBROUTINE ADDRESS
    PLA             ;FOR CLEARING STACK
RESTORE:
    LDA STATUS
    PHA
    LDA ACC
    LDX XREG
    LDY YREG
    PLP
    JMP (PC)        ;GO BACK TO REAL CPU

INSADD:             ;IF INSTRUCTION IS ADD WITHOUT CARRY
    CLC             ;CLEAR CARRY
INSADC:             ;IF INSTRUCTION IS ADD WITH CARRY
    LDA LB,X        ;LOAD DESTINATION LSB
    ADC LB,Y        ;ADD SOURCE LSB TO DESTINATION LSB
    STA LB,X        ;STORE IT TO DESTINATION LSB
    LDA HB,X        ;LOAD DESTINATION MSB
    ADC HB,Y        ;ADD SOURCE MSB TO DESTINATION MSB
    STA HB,X        ;STORE IT TO DESTINATION MSB
    RTS
    
INSPUSH:
    LDY SP          ;LOAD STACK POINTER
    LDA HB,X        ;GET MSB OF REGISTER
    STA (SPPAGE),Y ;PUSH TO STACK
    DEY             ;DECREASE STACK POINTER
    LDA LB,X        ;GET LSB OF REGISTER
    STA (SPPAGE),Y ;PUSH TO STACK
    DEY             ;DECREASE STACK POINTER
    STY SP          ;UPDATE STACK POINTER
    RTS

INSCMP:             ;SUB GIVEN REGISTERS AND STORE RESULT IN R13
    LDA LB,Y
    PHA
    LDA HB,Y
    LDY #CR
    STA HB,Y
    PLA
    STA LB,Y
                    ;EXECUTE INSSUB
INSSUB:             ;IF INSTRUCTION IS SUB WITHOUT BORROW
    SEC             ;SET CARRY (CLEAR BORROW)
INSSBC:             ;IF INSTRUCTION IS SUB WITH BORROW 
    LDA LB,X        ;LOAD DESTINATION LSB
    SBC LB,Y        ;SUB SOURCE LSB FROM DESTINATION LSB
    STA LB,X        ;STORE IT TO DESTINATION LSB
    LDA HB,X        ;LOAD DESTINATION MSB
    SBC HB,Y        ;SUB SOURCE MSB FROM DESTINATION MSB
    STA HB,X        ;STORE IT TO DESTINATION MSB
INSSUBRETURN:
    RTS

INSSWAP:
    STX TEMP
    CPY TEMP
    BEQ INSSWAPBYTE
    LDA LB,X
    PHA
    LDA HB,X
    PHA
    LDA LB,Y
    STA LB,X
    LDA HB,Y
    STA HB,X
    PLA
    STA HB,Y
    PLA
    STA LB,Y
    RTS
INSSWAPBYTE:
    LDY LB,X
    LDA HB,X
    STA LB,X
    STY HB,X
    RTS
    
BACKUPMULREGS:
    STX TEMP        ;BACKUP SOURCE ADDRESS
    STY TEMP+1      ;BACKUP DESTINATION ADDRESS
    JSR INSPUSH     ;PUSH SOURCE TO STACK
    LDX TEMP+1      ;LOAD DESTINATION ADDRESS
    JSR INSPUSH     ;PUSH DESTINATION TO STACK
    LDX TEMP        ;RESTORE SOURCE ADDRESS
    LDY TEMP+1      ;RESTORE DESTINATION ADDRESS
    RTS

INSUMUL:            ;IF UNSIGNED MUL INSTRUCTION CALLED
    JSR BACKUPMULREGS
    LDA #0x01       ;LOAD A TO #0x01 FOR CLEARING NEGATIVE FLAG
    PHP             ;PUSH SR TO STACK
    BPL INSMULCLRMH ;JUMP TO MULTIPLICATION ROUTINE
INSSMUL:            ;IF SIGNED MUL INSTRUCTION CALLED
INSMULBACKUP:       ;IF MULTIPLICAND OR MULTIPLIER IS NEGATIVE
    JSR BACKUPMULREGS
INSMULSIGNTST:
    LDA HB,X        ;IF BOTH MSb OF MSBs IS SAME RESULT WILL BE POSITIVE
    EOR HB,Y        ;ELSE RESULT WILL BE NEGATIVE
    PHP             ;PUSH SR TO STACK. WE WILL USE IT
INSMULSRCTST:       ;TEST IF SOURCE NEGATIVE
    LDA HB,X
    BPL INSMULDSTTST;IF NEGATIVE CONVERT IT TO POSITIVE ELSE JUMP TO DESTINATION TEST
    LDA LB,X
    EOR #0xFF       ;FLIP ALL BITS
    CLC
    ADC #0x01
    STA LB,X
    LDA HB,X
    EOR #0xFF
    ADC #0x00
    STA HB,X
INSMULDSTTST:       ;TEST IF DESTINATION NEGATIVE
    LDA HB,Y
    BPL INSMULCLRMH  ;IF NEGATIVE CONVERT IT TO POSITIVE ELSE JUMP TO MULTIPLICATION ROUTINE
    LDA LB,Y
    EOR #0xFF       ;FLIP ALL BITS
    CLC
    ADC #0x01
    STA LB,Y
    LDA HB,Y
    EOR #0xFF
    ADC #0x00
    STA HB,Y
INSMULCLRMH:
    LDA #0x00       ;CLEAR MUL RESULT REGISTER MSW
    STA MH
    STA MH+1
INSMULCOPY:
    LDA LB,Y        ;COPY DESTINATION LSB TO
    STA ML         ;PRODUCT LSB
    LDA HB,Y        ;COPY DESTINATION MSB TO
    STA ML+1       ;PRODUCT LSB+1 
INSMULINIT:
    LDY #0x10       ;LOAD 0x10 TO Y BECAUSE WE MULTIPLY 16x16-bit
    CLC             ;CLEAR CARRY
INSMULSHIFT:
    ROR MH+1       ;ROTATE RIGHT PRODUCT
    ROR MH         
    ROR ML+1       ;ALSO ROTATE MULTIPLIER
    ROR ML
    BCC INSMULTEST  ;IF ZERO GOTO TEST
    CLC             ;CLEAR CARRY
INSMULADD:
    LDA MH         ;LOAD THIRD BYTE OF PRODUCT
    ADC LB,X        ;ADD MULTIPLICAND LSB
    STA MH         ;STORE SUM TO THIRD BYTE OF PRODUCT
    LDA MH+1       ;LOAD FOURTH BYTE OF PRODUCT
    ADC HB,X        ;ADD MULTIPLICAND MSB
    STA MH+1       ;STORE SUM TO FOURTH BYTE OF PRODUCT
INSMULTEST:
    DEY             ;DECREASE Y (HAS NO EFFECT ON CARRY)
    BNE INSMULSHIFT ;IF COUNTER NOT ZERO GOTO LOOP
    ROR MH+1       ;ROTATE RIGHT PRODUCT
    ROR MH         
    ROR ML+1       ;ALSO ROTATE MULTIPLIER
    ROR ML
INSMULSIGN:
    PLP             ;PULL SR WE PUSHED BEFORE
    BPL INSMULRESTORE;IF SIGN OF RESULT IS POSITIVE (+ . + OR - . -)
    LDA #0x00       ;ELSE TURN POSITIVE RESULT TO NEGATIVE
    TAY
    TAX
    SEC
    PHP
INSMULSIGNLOOP:
    PLP
    SBC ML,X
    STA ML,X
    PHP
    TYA
    INX
    CPX #0x04
    BNE INSMULSIGNLOOP
    PLP
INSMULRESTORE:
    LDX TEMP+1      ;LOAD DESTINATION ADDRESS
    JSR INSPOP      ;POP REGISTER CONTENTS FROM STACK
    LDX TEMP        ;LOAD SOURCE ADDRESS
                    ;EXECUTE INSPOP
INSPOP:
    LDY SP          ;LOAD STACK POINTER
    INY             ;INCREASE STACK POINTER
    LDA (SPPAGE),Y ;POP LSB OF REGISTER
    STA LB,X        ;STORE TO LSB OF REGISTER
    INY             ;INCREASE STACK POINTER
    LDA (SPPAGE),Y ;POP MSB OF REGISTER
    STA HB,X        ;STORE TO MSB OF REGISTER
    STY SP          ;UPDATE STACK POINTER
    RTS

INSAND:
    LDA LB,X
    AND LB,Y
    STA LB,X
    LDA HB,X
    AND HB,Y
    STA HB,X
    RTS
    
INSOR:
    LDA LB,X
    ORA LB,Y
    STA LB,X
    LDA HB,X
    ORA HB,Y
    STA HB,X
    RTS

INSXOR:
    LDA LB,X
    EOR LB,Y
    STA LB,X
    LDA HB,X
    EOR HB,Y
    STA HB,X
    RTS
    
INSASL:
INSLSL:
    TYA
    LSR
    TAY
INSASLLOOP:
    ASL LB,X
    ROL HB,X
    DEY
    BPL INSASLLOOP
    RTS

INSASR:
    TYA
    LSR
    TAY
INSASRTEST:
    LDA HB,X
    CMP #0x80
INSASRLOOP:
    ROR HB,X
    ROR LB,X
    DEY
    BPL INSASRTEST
    RTS

INSLSR:
    TYA
    LSR
    TAY
INSLSRLOOP:
    LSR HB,X
    ROR LB,X
    DEY
    BPL INSLSRLOOP
    RTS
    
INSROL:
    CLC
INSRLC:
    PHP
    TYA
    LSR
    TAY
    PLP
INSROLLOOP:
    ROL LB,X
    ROL HB,X
    DEY
    BPL INSROLLOOP
    RTS

INSROR:
    CLC
INSRRC:
    PHP
    TYA
    LSR
    TAY
    PLP
INSRORLOOP:
    ROR HB,X
    ROR LB,X
    DEY
    BPL INSRORLOOP
    RTS

INSMOVRR:           ;MOV REGISTER TO REGISTER
    LDA LB,X
    STA LB,Y
    LDA HB,X
    STA HB,Y
    RTS

INSMOVMR:           ;MOV POINTER TO REGISTER
    LSR LB,X        ;DESTROY BIT0 OF POINTER
    ASL LB,X        ;SHIFT RIGHT THEN LEFT
    LDA (LB,X)      ;LOAD POINTER LSB
    STA LB,Y        ;STORE REGISTER LSB
    INC LB,X        ;INCREASE POINTER TO ACCESS MSB
    LDA (LB,X)      ;LOAD POINTER MSB
    STA HB,Y        ;STORE REGISTER MSB
    DEC LB,X        ;DECREASE POINTER LSB AGAIN
    RTS
    
INSMOVRM:           ;MOV REGISTER TO POINTER
    STY TEMP        ;SWAP POINTER AND REGISTER
    TXA
    TAY
    LDX TEMP
    LSR LB,X        ;DESTROY BIT0 OF POINTER
    ASL LB,X        ;SHIFT RIGHT THEN LEFT
    LDA LB,Y        ;LOAD REGISTER LSB
    STA (LB,X)      ;STORE POINTER LSB
    INC LB,X        ;INCREASE POINTER TO ACCESS MSB
    LDA HB,Y        ;LOAD REGISTER MSB
    STA (LB,X)      ;STORE POINTER MSB
    DEC LB,X        ;DECREASE POINTER LSB AGAIN
    RTS

INSMOVMRI:          ;MOV POINTER TO REGISTER THEN INCREMENT POINTER
    JSR INSMOVMR
    JMP INSMOVRMIINC

INSMOVRMI:          ;MOV REGISTER TO POINTER THEN INCREMENT POINTER
    JSR INSMOVRM
INSMOVRMIINC:
    LDY #0x01
                    ;EXECUTE INSINC
INSINC:
    TYA             ;TRANSFER INCREMENT COUNTER TO A
    LSR             ;WE MULTIPLIED IT BY 2. REVERSE IT
INSINCREMENT:
    ADC #1          ;MAP 0-15 TO 1-16
    ADC LB,X        ;ADD INCREMENT VALUE TO LSB
    STA LB,X        ;STORE IT
    LDA #0x00       ;IF THERE IS CARRY
    ADC HB,X        ;ADD IT TO MSB
    STA HB,X
    RTS
    
INSJSR:
    LDX #PC     ;#PC (0x1E)
    JSR INSPUSH ;PUSH RETURN PC TO STACK
INSJMP:
    CLC         ;CLEAR CARRY FOR PROPER ADDITION
    LDY #0x01   ;FOR FETCHING JUMP ADDRESS FROM INSTRUCTION
    LDA (PC),Y  ;LOAD FIRST ARGUMENT (LSB OF SUBROUTINE PC)
    ADC FIRSTPC ;ADD LSB OF FIRST VIRTUAL16 INSTRUCTION ADDRESS TO GET PROPER ADDRESS OF SUBROUTINE
    TAX         ;TRANSFER IT TO X
    INY         ;INCREASE Y
    LDA (PC),Y  ;LOAD SECOND ARGUMENT (MSB OF SUBROUTINE PC)
    ADC FIRSTPC+1;ADD MSB OF FIRST VIRTUAL16 INSTRUCTION ADDRESS TO GET PROPER ADDRESS OF SUBROUTINE
    STA PC+1    ;STORE IT TO MSB OF PC
    STX PC      ;STORE X TO LSB OF PC
    PLA         ;PULL RETURN ADDRESS FOR CLEARING STACK
    PLA         ;BECAUSE WE DONT WANT TO INCREMENT PC
    JMP FETCH   ;JUMP TO NEW INSTRUCTION

INSRTS:
    LDX #PC     ;LOAD ADDRESS OF PC
    JSR INSPOP  ;POP RETURN PC FROM STACK
    JMP ABSIMMEND ;SAVE 5 BYTE

INSNJSR:
    LDY #0x01   ;LOAD 1 TO Y
    LDA (PC),Y  ;LOAD LSB OF ADDRESS TO A
    STA TEMP    ;STORE IT TO TEMP
    INY         ;INCREASE Y
    LDA (PC),Y  ;LOAD MSB OF ADDRESS TO A
    STA TEMP+1  ;STORE IT TO TEMP+1
INSNJSRINCPC:
    JSR ABSIMMEND   ;THIS ONE COULD SAVE 4 BYTE. NOTHING SPECIAL
INSNJSRJMP:
    JMP (TEMP)  ;EXECUTE NATIVE SUBROUTINE

INSJMPR:
    JSR INSMOVRR
    PLA
    PLA
    JMP FETCH

INSTR:
    DW INSRET-1   ;0x00
    DW INSMOVRR-1 ;0x01
    DW INSMOVMR-1 ;0x02
    DW INSMOVRM-1 ;0x03
    DW INSMOVMRI-1;0x04
    DW INSMOVRMI-1;0x05
    DW INSPUSH-1  ;0x06
    DW INSPOP-1   ;0x07
    DW INSCMP-1   ;0x08
    DW INSSWAP-1  ;0x09
    DW INSAND-1   ;0x0A
    DW INSOR-1    ;0x0B
    DW INSXOR-1   ;0x0C
    DW INSJSR-1   ;0x0D
    DW INSRTS-1   ;0x0E
    DW INSJMP-1   ;0x0F
    DW INSINC-1   ;0x10
    DW INSDEC-1   ;0x11
    DW INSADD-1   ;0x12
    DW INSADC-1   ;0x13
    DW INSSUB-1   ;0x14
    DW INSSBC-1   ;0x15
    DW INSSMUL-1  ;0x16
    DW INSUMUL-1  ;0x17
    DW INSNJSR-1  ;0x18
    DW INSASR-1   ;0x19
    DW INSLSL-1   ;0x1A
    DW INSLSR-1   ;0x1B
    DW INSROL-1   ;0x1C
    DW INSRLC-1   ;0x1D
    DW INSROR-1   ;0x1E
    DW INSRRC-1   ;0x1F
    DW INSBCC-1   ;0x20
    DW INSBCS-1   ;0x21
    DW INSBRA-1   ;0x22
    DW INSJMPR-1  ;0x23
INSTR2:
    DW INSMOVL-1  ;0x50
    DW INSMOVH-1  ;0x60
    DW INSMOVW-1  ;0x70
    DW INSMOVAR-1 ;0x80
    DW INSMOVRA-1 ;0x90
    DW INSBNM1-1  ;0xA0
    DW INSBM1-1   ;0xB0
    DW INSBMI-1   ;0xC0
    DW INSBPL-1   ;0xD0
    DW INSBNE-1   ;0xE0
    DW INSBEQ-1   ;0xF0
