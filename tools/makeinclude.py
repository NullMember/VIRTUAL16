import os, sys, time

instructions = ['INSADD', 'INSADC', 'INSSUB', 'INSSBC', 'INSSWAP', 'INSUMUL', 'INSSMUL', 'INSAND', 'INSOR', 'INSXOR', 'INSASLLOOP', 'INSASLLOOP', 'INSASRTEST', 'INSLSRLOOP', 'INSROLLOOP', 'INSRORLOOP', 'INSINCREMENT', 'INSDECREMENT']
names = ['ADD16', 'ADC16', 'SUB16', 'SBC16', 'SWAP16', 'UMUL16', 'SMUL16', 'AND16', 'OR16', 'XOR16', 'ASL16', 'LSL16', 'ASR16', 'LSR16', 'RLC16', 'RRC16', 'INC16', 'DEC16']
addresses = []

if os.path.exists('..\\output\\VIRTUAL16.lst'):
    with open('..\\output\\VIRTUAL16.lst', 'r') as f:
        lines = f.readlines()
else:
    input(".lst file not found, please run compile.sh file. Press enter to exit program")
    sys.exit(0)

for line in lines:
    try:
        if line.split()[0] in instructions:
            _index = instructions.index(line.split()[0])
            address = int(line.split()[1], 16)
            addresses.append('.equ ' + names[_index] + ' ' + hex(address))
    except:
        pass

print(addresses)

with open('..\\src\\VIRTUAL16.inc', 'w') as f:
    for address in addresses:
        f.write(address + '\n')