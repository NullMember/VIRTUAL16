

## Here is some example programs for VIRTUAL16

### Fibonacci Series

    ; Calculate first 25 numbers of fibonacci series and write them into memory
    ; This program takes ~25000 cycles. For 1Mhz 6502 it means 1 / 40 second
    
    MAIN:
        MOVL #25, R0        ;16-BIT CAN REPRESENT 25th FIBONACCI NUMBER MAXIMUM
        MOVL #0, R1         ;FIRST ARGUMENT
        MOVL #1, R2         ;SECOND ARGUMENT
        MOVL #0x30, R4      ;FIBONACCI SERIES STARTING POINT
        MOV R1, +@R4        ;MOV FIRST ARGUMENT TO ADDRESS HELD BY R3 THEN INCREMENT POINTER
        DEC R0
        MOV R2, +@R4        ;MOV SECOND ARGUMENT TO ADDRESS HELD BY R3 THEN INCREMENT POINTER
        DEC R0
    FIBONACCI:
        MOV R2, R3          ;BACKUP N-1 VALUE
        ADD R1, R2          ;CALCULATE N
        MOV R2, +@R4        ;MOV N TO ADDRESS HELD BY R3 THEN INCREMENT POINTER
        MOV R3, R1          ;MOV N-1 TO N-2
        DEC R0              ;DECREMENT COUNTER (R0)
        BNE R0, FIBONACCI   ;IF COUNTER IS NOT ZERO BRANCH TO FIBONACCI
    END:
        RET					;Return to 6502 mode

Assembled version

    DB 0x20, 0x19, 0x21, 0x00, 0x22, 0x01, 0x24, 0x30, 0x05, 0x14, 0x11, 0x00, 0x05, 0x24, 0x11, 0x00
    DB 0x01, 0x23, 0x12, 0x12, 0x05, 0x24, 0x01, 0x31, 0x11, 0x00, 0x80, 0xf4, 0x00

### Factorial

    ; Calculate 8! and write result into memory
    ; This program takes ~12500 cycles. For 1Mhz 6502 it means 1 / 80 second
    
    MAIN:
        MOVL #8, R0         ;16-BIT CAN REPRESENT 8 FACTORIAL MAXIMUM
        MOVL #1, R1         ;FIRST ARGUMENT
        MOVL #0x30, R3      ;FACTORIAL RESULT
    FACTORIAL:
        INC R2              ;INCREASE MULTIPLIER
        UMUL R1, R2         ;MULTIPLY R1 AND R2
        MOV ML, R1          ;MOV MULTIPLY RESULT LSW TO R1
        CMP R2, R0
        BNE CR, FACTORIAL   ;IF COUNTER IS NOT ZERO BRANCH TO FIBONACCI
        MOV R1, @R3         ;COPY RESULT TO ADDRESS HELD BY R4
    END:
        RET					;Return to 6502 mode

Assembled version

    DB 0x20, 0x08, 0x21, 0x01, 0x23, 0x30, 0x10, 0x20, 0x17, 0x12, 0x01, 0xb1, 0x08, 0x20, 0x8d, 0xf6
    DB 0x03, 0x13, 0x00

### More to come