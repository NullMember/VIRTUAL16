; Copyright (c) 2020 Malik Enes Şafak
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

#bits 8

#subruledef reg
{
	R0 => 0x00
	R1 => 0x01
	R2 => 0x02
	R3 => 0x03
	R4 => 0x04
	R5 => 0x05
	R6 => 0x06
	R7 => 0x07
	R8 => 0x08
	R9 => 0x09
	R10 => 0x0A
	R11 => 0x0B
	R12 => 0x0C
	R13 => 0x0D
	R14 => 0x0E
	R15 => 0x0F
	ML => 0x0C
	MH => 0x0D
	CR => 0x0D
	SR => 0x0E
	PC => 0x0F
}

#ruledef
{
	RET				=> 0x00
	RTS				=> 0x01
	CLC				=> 0x02
	SEC				=> 0x03

	MOV  {src: reg}, {dst: reg}	=> 0x04 @ src`4 @ dst`4
	MOV  @{src: reg}, {dst: reg}	=> 0x05 @ src`4 @ dst`4
	MOV  {src: reg}, @{dst: reg}	=> 0x06 @ src`4 @ dst`4
	MOV  +@{src: reg}, {dst: reg}	=> 0x07 @ src`4 @ dst`4
	MOV  {src: reg}, +@{dst: reg}	=> 0x08 @ src`4 @ dst`4
	MOV  {src: reg}.H, {dst: reg}.H	=> 0x09 @ src`4 @ dst`4
	MOV  {src: reg}.H, {dst: reg}.L	=> 0x0A @ src`4 @ dst`4
	MOV  {src: reg}.L, {dst: reg}.H	=> 0x0B @ src`4 @ dst`4
	MOV  {src: reg}.L, {dst: reg}.L	=> 0x0C @ src`4 @ dst`4
	SWAP {src: reg}, {dst: reg} 	=> 0x0D @ src`4 @ dst`4
	SWAP {reg: reg}		 	=> 0x0D @ reg`4 @ reg`4

	AND  {src: reg}, {dst: reg}	=> 0x0E @ dst`4 @ src`4
	OR   {src: reg}, {dst: reg}	=> 0x0F @ dst`4 @ src`4
	XOR  {src: reg}, {dst: reg}	=> 0x10 @ dst`4 @ src`4

	ADD  {src: reg}, {dst: reg}	=> 0x11 @ dst`4 @ src`4
	ADC  {src: reg}, {dst: reg}	=> 0x12 @ dst`4 @ src`4
	SUB  {src: reg}, {dst: reg}	=> 0x13 @ dst`4 @ src`4
	SBC  {src: reg}, {dst: reg}	=> 0x14 @ dst`4 @ src`4
	SMUL {src: reg}, {dst: reg}	=> 0x15 @ dst`4 @ src`4
	UMUL {src: reg}, {dst: reg}	=> 0x16 @ dst`4 @ src`4

	CMP  {src: reg}, {dst: reg}	=> 0x17 @ dst`4 @ src`4
	CMP  {src: reg}			=> 0x17 @ dst`4 @ 13`4

	INC  {dst: reg}, {count: u4}	=> 0x18 @ dst`4 @ count`4
	INC  {dst: reg}			=> 0x18 @ dst`4 @ 0`4
	DEC  {dst: reg}, {count: u4}	=> 0x19 @ dst`4 @ count`4
	DEC  {dst: reg}			=> 0x19 @ dst`4 @ 0`4

	ASR  {dst: reg}, {count: u4}	=> 0x1A @ dst`4 @ count`4
	ASR  {dst: reg}			=> 0x1A @ dst`4 @ 0`4
	LSL  {dst: reg}, {count: u4}	=> 0x1B @ dst`4 @ count`4
	LSL  {dst: reg}			=> 0x1B @ dst`4 @ 0`4
	LSR  {dst: reg}, {count: u4}	=> 0x1C @ dst`4 @ count`4
	LSR  {dst: reg}			=> 0x1C @ dst`4 @ 0`4
	ROL  {dst: reg}, {count: u4}	=> 0x1D @ dst`4 @ count`4
	ROL  {dst: reg}			=> 0x1D @ dst`4 @ 0`4
	RLC  {dst: reg}, {count: u4}	=> 0x1E @ dst`4 @ count`4
	RLC  {dst: reg}			=> 0x1E @ dst`4 @ 0`4
	ROR  {dst: reg}, {count: u4}	=> 0x1F @ dst`4 @ count`4
	ROR  {dst: reg}			=> 0x1F @ dst`4 @ 0`4
	RRC  {dst: reg}, {count: u4}	=> 0x20 @ dst`4 @ count`4
	RRC  {dst: reg}			=> 0x20 @ dst`4 @ 0`4

	JMPR {reg: reg}			=> 0x21 @ reg`4 @ 15`4

	JSR	{addr: u16}		=> 0x22 @ addr[7:0] @ addr[15:8]
	NJSR 	{addr: u16}		=> 0x23 @ addr[7:0] @ addr[15:8]
	JMP	{addr: u16}		=> 0x24 @ addr[7:0] @ addr[15:8]

	BCC	{label}			=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0x25 @ reladdr`8
	}
	BCS	{label}			=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0x26 @ reladdr`8
	}
	BRA	{label}			=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0x27 @ reladdr`8
	}
	
	
	PUSH {reg: reg}			=> 0x3  @ reg`4
	POP  {reg: reg}			=> 0x4  @ reg`4
	MOV  #{value: u8}, {dst: reg}.L	=> 0x5	@ dst`4 @ value`8
	MOV  #{value: u8}, {dst: reg}.H	=> 0x6	@ dst`4 @ value`8
	MOV  #{value: u16}, {dst: reg}	=> 0x7	@ dst`4 @ value[7:0] @ value[15:8]
	MOV  {addr}, {reg: reg}		=> 0x8  @ reg`4 @ addr[7:0] @ addr[15:8]
	MOV  {reg: reg}, {addr}		=> 0x9  @ reg`4 @ addr[7:0] @ addr[15:8]
	BNM1 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xA @ dst`4 @ reladdr`8
	}
	BM1	 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xB @ dst`4 @ reladdr`8
	}
	BMI	 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xC @ dst`4 @ reladdr`8
	}
	BPL	 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xD @ dst`4 @ reladdr`8
	}
	BNE	 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xE @ dst`4 @ reladdr`8
	}
	BEQ	 {dst: reg}, {label}	=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xF @ dst`4 @ reladdr`8
	}
	BNM1 	{label}			=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xAD @ reladdr`8
	}
	BM1	 {label}		=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xBD @ reladdr`8
	}
	BMI	 {label}		=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xCD @ reladdr`8
	}
	BPL	 {label}		=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xDD @ reladdr`8
	}
	BNE	 {label}		=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xED @ reladdr`8
	}
	BEQ	 {label}		=>
	{
		reladdr = label - $ - 2
		assert(reladdr <=  0x7f)
		assert(reladdr >= !0x7f)
		0xFD @ reladdr`8
	}
}

;Write your code below here

MAIN:

LOOP:

END:
	RET
